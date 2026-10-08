codeunit 6151170 "NPR Spfy Legacy Return Import"
{
    Access = Internal;
    TableNo = "NPR Spfy NC Return Queue";

    trigger OnRun()
    begin
        ImportReturn(Rec);
    end;

    var
        _SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        _Builder: Codeunit "NPR Spfy Refund Doc. Builder";
        // Locked: the Sentry filter matches the English text.

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _SpfyLegacyReturnAPI.SetGraphQLClient(GraphQLClient);
    end;

    local procedure ImportReturn(var QueueRow: Record "NPR Spfy NC Return Queue")
    var
        ShopifyStore: Record "NPR Spfy Store";
        SalesHeader: Record "Sales Header";
        Settlement: Record "NPR Spfy Refund Settlement";
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        Outcome: Enum "NPR Spfy Refund Build Outcome";
        OutcomeMessage: Text;
        AppliedAmount: Decimal;
        UsedLocationFallback: Boolean;
        DraftExists: Boolean;
        StoreMissingErr: Label 'Legacy return queue row for store %1 and return %2 references a Shopify store that does not exist. This is a programming bug.', Locked = true;
    begin
        SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(QueueRow);
        if SpfyLegacyReturnMgt.RecordPostedCreditMemo(QueueRow) then
            exit;

        if not ShopifyStore.Get(QueueRow."Shopify Store Code") then
            Error(StoreMissingErr, QueueRow."Shopify Store Code", QueueRow."Source Doc. ID");

        if QueueRow."Sales Header Doc. No." <> '' then
            DraftExists := SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        if DraftExists then begin
            if Settlement.FindForSalesHeader(SalesHeader) then
                AppliedAmount := Settlement."Applied Amount";
            // Our own draft may have been edited since it was built: with what it settles on an open invoice, it must still cover what Shopify refunded.
            _Builder.VerifyDocumentCoversRefund(SalesHeader, ShopifyStore, RowCaption(QueueRow), PaymentLinesTotal(SalesHeader, RowCaption(QueueRow), AppliedAmount) + AppliedAmount);
            _Builder.CheckAppliedInvoiceStillOpen(SalesHeader, RowCaption(QueueRow), AppliedAmount);
        end;
        if not DraftExists then
            if SpfyLegacyReturnMgt.FindDraftForReturn(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID", SalesHeader) then begin
                DraftExists := true;
                // A draft the other engine built must pass the same checks as ours before posting.
                FetchDetail(QueueRow, ShopifyStore.Code, TempReturnBuffer, TempLineBuffer, TempOtherLineBuffer, TempRefundTxnBuffer);
                _Builder.CheckSourceIsImportable(TempReturnBuffer);
                if _Builder.RefundStillPending(TempReturnBuffer, OutcomeMessage) then begin
                    SetOutcome(QueueRow, Outcome::Waiting, OutcomeMessage);
                    exit;
                end;
                _Builder.VerifyDocumentCoversRefund(SalesHeader, ShopifyStore, _SpfyLegacyReturnAPI.DocumentCaption(TempReturnBuffer."Source Type", TempReturnBuffer."Return Name", TempReturnBuffer."Return Id"), _Builder.RefundTotal(TempRefundTxnBuffer));
                _Builder.StampRefundDateOnPaymentLines(SalesHeader, TempRefundTxnBuffer);
                _Builder.SetQuantitiesToPost(SalesHeader);
                // Settlement is ours, as in the builder.
                if SalesHeader."Payment Method Code" <> '' then begin
                    SalesHeader.Validate("Payment Method Code", '');
                    SalesHeader.Modify(true);
                end;
                QueueRow."Sales Header Doc. No." := SalesHeader."No.";
                DeriveRowFieldsFromDetail(QueueRow, TempReturnBuffer, TempLineBuffer);
                _Builder.WriteSettlement(ShopifyStore.Code, SalesHeader, TempReturnBuffer, TempRefundTxnBuffer, 0);
                QueueRow.Modify();
                Commit();
            end;

        if not DraftExists then begin
            // No Shopify call while the row has to wait: a waiting row is looked at on every run. A row with a draft was measured already.
            if MustWait(QueueRow, OutcomeMessage) then begin
                SetOutcome(QueueRow, Outcome::Waiting, OutcomeMessage);
                exit;
            end;
            FetchDetail(QueueRow, ShopifyStore.Code, TempReturnBuffer, TempLineBuffer, TempOtherLineBuffer, TempRefundTxnBuffer);
            Outcome := _Builder.BuildReturnOrder(ShopifyStore, TempReturnBuffer, TempLineBuffer, TempOtherLineBuffer, TempRefundTxnBuffer, SalesHeader, UsedLocationFallback, OutcomeMessage);
            if Outcome <> Outcome::Built then begin
                DeriveRowFieldsFromDetail(QueueRow, TempReturnBuffer, TempLineBuffer);
                SetOutcome(QueueRow, Outcome, OutcomeMessage);
                exit;
            end;
            QueueRow."Sales Header Doc. No." := SalesHeader."No.";
            QueueRow."Location Fallback Used" := UsedLocationFallback;
            QueueRow."Outcome Note" := '';
            DeriveRowFieldsFromDetail(QueueRow, TempReturnBuffer, TempLineBuffer);
            QueueRow.Modify();
            // The draft must survive a posting failure.
            Commit();
        end;

        if ShopifyStore."Post Returns Automatically" then begin
            PostSalesHeader(SalesHeader);
            // Get, not Find: a page's filter may exclude the row the posting just marked Imported.
            QueueRow.Get(QueueRow."Entry No.");
        end;
    end;

    /// <summary>
    /// A refund waits while its order's Sales Order has something left to ship or invoice; any row waits while another draft settles an unpaid invoice of its order. The builder checks again under lock.
    /// </summary>
    local procedure MustWait(QueueRow: Record "NPR Spfy NC Return Queue"; var WaitingMessage: Text): Boolean
    begin
        if QueueRow."Source Doc. Type" = QueueRow."Source Doc. Type"::Refund then
            if _Builder.OrderStillOpen(QueueRow."Shopify Store Code", QueueRow."Order Id", QueueRow."Order No.", WaitingMessage) then
                exit(true);
        exit(_Builder.OtherDraftSettlesOrderInvoice(QueueRow."Shopify Store Code", QueueRow."Order Id", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID", RowCaption(QueueRow), false, WaitingMessage));
    end;

    /// <summary>
    /// A refund that waits or has nothing to credit builds nothing; the row says why.
    /// </summary>
    local procedure SetOutcome(var QueueRow: Record "NPR Spfy NC Return Queue"; Outcome: Enum "NPR Spfy Refund Build Outcome"; OutcomeMessage: Text)
    begin
        case Outcome of
            Outcome::Waiting:
                QueueRow.Validate(Status, QueueRow.Status::Waiting);
            Outcome::"Nothing to Credit":
                QueueRow.Validate(Status, QueueRow.Status::"Nothing to Credit");
        end;
        QueueRow."Outcome Note" := CopyStr(OutcomeMessage, 1, MaxStrLen(QueueRow."Outcome Note"));
        QueueRow."Last Error" := '';
        QueueRow.Modify();
    end;

    local procedure FetchDetail(QueueRow: Record "NPR Spfy NC Return Queue"; ShopifyStoreCode: Code[20]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        RefundId: Text[30];
    begin
        TempOtherLineBuffer.Reset();
        TempOtherLineBuffer.DeleteAll();
        if QueueRow."Source Doc. Type" = QueueRow."Source Doc. Type"::Refund then begin
            RefundId := QueueRow."Source Doc. ID";
            _SpfyLegacyReturnAPI.GetRefundDetail(ShopifyStoreCode, RefundId, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
            // One request per other refund of the order, so only when the builder will use them.
            if _Builder.NeedsOtherRefunds(ShopifyStoreCode, TempReturnBuffer, TempLineBuffer) then
                _SpfyLegacyReturnAPI.GetOtherRefundLines(ShopifyStoreCode, RefundId, TempReturnBuffer, TempOtherLineBuffer);
        end else
            _SpfyLegacyReturnAPI.GetReturnDetail(ShopifyStoreCode, QueueRow."Source Doc. ID", TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        TempReturnBuffer.Get(QueueRow."Source Doc. ID");
    end;

    local procedure RowCaption(QueueRow: Record "NPR Spfy NC Return Queue"): Text[50]
    begin
        exit(_SpfyLegacyReturnAPI.DocumentCaption(QueueRow."Source Doc. Type", QueueRow."Source Doc. Name", QueueRow."Source Doc. ID"));
    end;

    local procedure DeriveRowFieldsFromDetail(var QueueRow: Record "NPR Spfy NC Return Queue"; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    begin
        QueueRow."Source Doc. Name" := TempReturnBuffer."Return Name";
        QueueRow."Order No." := CopyStr(TempReturnBuffer."Order Name", 1, MaxStrLen(QueueRow."Order No."));
        TempLineBuffer.Reset();
        TempLineBuffer.SetRange("Not Restocked", true);
        QueueRow."Not Restocked" := not TempLineBuffer.IsEmpty();
        TempLineBuffer.Reset();
    end;

    /// <summary>
    /// What a draft's own payment lines pay out, so a reused draft is checked without another Shopify call; a draft that settles an open invoice in full has none.
    /// </summary>
    local procedure PaymentLinesTotal(SalesHeader: Record "Sales Header"; ReturnName: Text[50]; AppliedAmount: Decimal): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
        DraftPaymentsMissingErr: Label '%1 %2 of Shopify %3 no longer carries the payment lines the import created, so it cannot be checked against the refund. Discard the draft and retry.', Comment = '%1 = Sales Header table caption, %2 = Return Order no., %3 = Shopify document caption';
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.CalcSums(Amount);
        if (PaymentLine.Amount = 0) and (AppliedAmount = 0) then
            Error(DraftPaymentsMissingErr, SalesHeader.TableCaption(), SalesHeader."No.", ReturnName);
        exit(PaymentLine.Amount);
    end;

    local procedure PostSalesHeader(var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        _Builder.SetQuantitiesToPost(SalesHeader);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();
        Clear(SalesPost);
        SalesPost.Run(SalesHeader);
    end;
}
