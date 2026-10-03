codeunit 6151170 "NPR Spfy Legacy Return Import"
{
    Access = Internal;
    TableNo = "NPR Spfy Legacy Return Queue";

    trigger OnRun()
    begin
        ImportReturn(Rec);
    end;

    var
        _SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        _SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        _OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _JsonHelper: Codeunit "NPR Json Helper";
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        _ExchangeNotSupportedErr: Label 'Shopify return %1 contains an exchange line. Exchanges are not imported; handle this return manually.', Comment = '%1 = Shopify return name';
        _ReturnNotClosedErr: Label 'Shopify return %1 is %2, not closed, so it is not imported yet. The row is retried; once the return is closed, Discard Draft and Retry queues it again.', Comment = '%1 = Shopify return name, %2 = Shopify return status';
        _NoLocationErr: Label 'No %1 could be resolved for Shopify return %2: none of its restock locations is linked to the store and the %3 has no %4.', Comment = '%1 = Location table caption, %2 = Shopify return name, %3 = NpEc Store table caption, %4 = NpEc Store Location Code field caption';
        _ItemNotFoundErr: Label 'No %1 could be matched for SKU %2 on Shopify return %3.', Comment = '%1 = Item table caption, %2 = SKU, %3 = Shopify return name';
        _NoRefundFoundErr: Label 'Shopify return %1 is closed but carries no completed refund, so a credit memo of %2 cannot be justified. The refund may sit on the order instead of the return, or still be pending.', Comment = '%1 = Shopify return name, %2 = document total';
        _RefundTotalShortErr: Label 'The document total %1 for Shopify return %2 is below the %3 Shopify refunded, short by %4. The usual cause is a refunded shipping cost with no %5 on the %6.', Comment = '%1 = document total, %2 = Shopify return name, %3 = refund total, %4 = difference, %5 = Return Shipping Refund G/L Acc. caption, %6 = Shopify Store table caption';
        _RefundTotalOverErr: Label 'The document total %1 for Shopify return %2 exceeds the %3 Shopify refunded by %4. Crediting more than was refunded would leave the difference open on the customer account; a withheld fee is probably not accounted for.', Comment = '%1 = document total, %2 = Shopify return name, %3 = refund total, %4 = difference';
        _ReturnFeeAccountMissingErr: Label 'Shopify held back %1 of the refund for return %2, but %3 is blank on the %4. Set it so the withheld amount can be posted.', Comment = '%1 = fee amount, %2 = Shopify return name, %3 = Return Fee G/L Account No. caption, %4 = Shopify Store table caption';
        _GiftCardSaleNotFoundErr: Label 'No posted %1 carries Shopify line item %2 of return %3, so the gift card vouchers to revoke cannot be found. Handle this return manually.', Comment = '%1 = Sales Invoice Line table caption, %2 = Shopify order line item id, %3 = Shopify return name';
        _GiftCardUsedErr: Label 'Shopify return %1 returns %2 gift card(s) sold on %3 %4, but only %5 of the vouchers issued for that line are still untouched, not reserved as a payment and not claimed by another open return. Handle this return manually.', Comment = '%1 = Shopify return name, %2 = returned quantity, %3 = Sales Invoice Header table caption, %4 = posted invoice no(s)., %5 = number of vouchers still available';
        _GiftCardNoRefundErr: Label 'Shopify return %1 returns gift card line item %2 but refunds nothing for it, so there is no credit to revoke the vouchers against. Handle this return manually.', Comment = '%1 = Shopify return name, %2 = Shopify order line item id';
        _RefundBeyondLinesErr: Label 'Shopify return %1 refunds %2 beyond its returned lines through an order adjustment paid to the customer. Refunds beyond the lines are not imported; handle this return manually.', Comment = '%1 = Shopify return name, %2 = amount paid beyond the lines';
        _DraftPaymentsMissingErr: Label '%1 %2 of Shopify return %3 no longer carries the payment lines the import created, so it cannot be checked against the refund. Discard the draft and retry.', Comment = '%1 = Sales Header table caption, %2 = Return Order no., %3 = Shopify return name';
        _ShippingRefundLbl: Label 'Shipping refund';
        _ReturnFeeLbl: Label 'Return fee withheld';
        // Locked: the Sentry filter matches the English text.
        _StoreMissingErr: Label 'Legacy return queue row for store %1 and return %2 references a Shopify store that does not exist. This is a programming bug.', Locked = true;

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _SpfyLegacyReturnAPI.SetGraphQLClient(GraphQLClient);
    end;

    local procedure ImportReturn(var QueueRow: Record "NPR Spfy Legacy Return Queue")
    var
        ShopifyStore: Record "NPR Spfy Store";
        NpEcStore: Record "NPR NpEc Store";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        OrderToken: JsonToken;
        LocationCode: Code[10];
        UsedLocationFallback: Boolean;
        DraftExists: Boolean;
    begin
        _SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(QueueRow);
        if _SpfyLegacyReturnMgt.RecordPostedCreditMemo(QueueRow) then
            exit;

        if not ShopifyStore.Get(QueueRow."Shopify Store Code") then
            Error(_StoreMissingErr, QueueRow."Shopify Store Code", QueueRow."Return Id");

        if QueueRow."Sales Header Doc. No." <> '' then
            DraftExists := SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        if DraftExists then
            // Our own draft may have been edited since it was built: it must still cover what Shopify refunded.
            VerifyDocumentCoversRefund(SalesHeader, ShopifyStore, QueueRow."Return Name", PaymentLinesTotal(SalesHeader, QueueRow."Return Name"));
        if not DraftExists then
            if _SpfyLegacyReturnMgt.FindDraftForReturn(QueueRow."Shopify Store Code", QueueRow."Return Id", SalesHeader) then begin
                DraftExists := true;
                // A draft the other engine built must pass the same checks as ours before posting.
                _SpfyLegacyReturnAPI.GetReturnDetail(ShopifyStore.Code, QueueRow."Return Id", TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
                TempReturnBuffer.Get(QueueRow."Return Id");
                CheckReturnIsImportable(TempReturnBuffer);
                VerifyDocumentCoversRefund(SalesHeader, ShopifyStore, TempReturnBuffer."Return Name", RefundTotal(TempRefundTxnBuffer));
                StampRefundDateOnPaymentLines(SalesHeader, TempRefundTxnBuffer);
                SetQuantitiesToPost(SalesHeader);
                // Settlement is ours, as in CreateSalesHeader.
                if SalesHeader."Payment Method Code" <> '' then begin
                    SalesHeader.Validate("Payment Method Code", '');
                    SalesHeader.Modify(true);
                end;
                QueueRow."Sales Header Doc. No." := SalesHeader."No.";
                DeriveRowFieldsFromDetail(QueueRow, ShopifyStore, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
                QueueRow.Modify();
                Commit();
            end;

        if not DraftExists then begin
            _SpfyLegacyReturnAPI.GetReturnDetail(ShopifyStore.Code, QueueRow."Return Id", TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
            TempReturnBuffer.Get(QueueRow."Return Id");
            CheckReturnIsImportable(TempReturnBuffer);
            TempReturnBuffer.GetOrderJson(OrderToken);

            _OrderMgt.FindNpEcStore(ShopifyStore.Code, TempReturnBuffer."Source Name", NpEcStore);
            FindCustomer(NpEcStore, OrderToken, Customer);

            ResolveHeaderLocation(ShopifyStore.Code, NpEcStore, TempReturnBuffer."Return Name", TempLineBuffer, LocationCode, UsedLocationFallback);

            CreateSalesHeader(ShopifyStore, NpEcStore, Customer, LocationCode, TempReturnBuffer, SalesHeader);
            CreateSalesLines(ShopifyStore, TempReturnBuffer."Return Name", TempLineBuffer, SalesHeader);
            CreateGLLine(SalesHeader, ShopifyStore."Ret. Shipping Refund G/L Acc.", TempReturnBuffer."Shipping Refund Amount", _ShippingRefundLbl);
            if TempReturnBuffer."Fee Amount" <> 0 then begin
                if ShopifyStore."Return Fee G/L Account No." = '' then
                    Error(_ReturnFeeAccountMissingErr, TempReturnBuffer."Fee Amount", TempReturnBuffer."Return Name", ShopifyStore.FieldCaption("Return Fee G/L Account No."), ShopifyStore.TableCaption());
                CreateGLLine(SalesHeader, ShopifyStore."Return Fee G/L Account No.", -TempReturnBuffer."Fee Amount", _ReturnFeeLbl);
            end;
            SetQuantitiesToPost(SalesHeader);

            VerifyDocumentCoversRefund(SalesHeader, ShopifyStore, TempReturnBuffer."Return Name", RefundTotal(TempRefundTxnBuffer));
            InsertPaymentLines(SalesHeader, ShopifyStore.Code, QueueRow."Return Id", TempRefundTxnBuffer);

            _SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", QueueRow."Return Id", false);
            _SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", ShopifyStore.Code, false);

            QueueRow."Sales Header Doc. No." := SalesHeader."No.";
            QueueRow."Location Fallback Used" := UsedLocationFallback;
            DeriveRowFieldsFromDetail(QueueRow, ShopifyStore, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
            QueueRow.Modify();
            // The draft must survive a posting failure.
            Commit();
        end;

        if ShopifyStore."Post Returns Automatically" then begin
            PostSalesHeader(SalesHeader);
            // Get, not Find: a page's filter may exclude the row the posting just marked Imported.
            QueueRow.Get(QueueRow."Shopify Store Code", QueueRow."Return Id");
        end;
    end;

    local procedure DeriveRowFieldsFromDetail(var QueueRow: Record "NPR Spfy Legacy Return Queue"; ShopifyStore: Record "NPR Spfy Store"; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        GiftCardId: Text[30];
        GiftCardRefundAmount: Decimal;
        MultipleGiftCards: Boolean;
        StoreCreditSeen: Boolean;
    begin
        QueueRow."Return Name" := TempReturnBuffer."Return Name";
        QueueRow."Order No." := CopyStr(TempReturnBuffer."Order Name", 1, MaxStrLen(QueueRow."Order No."));
        TempLineBuffer.Reset();
        TempLineBuffer.SetRange("Not Restocked", true);
        QueueRow."Not Restocked" := not TempLineBuffer.IsEmpty();
        TempLineBuffer.Reset();
        SummariseGiftCardRefund(TempRefundTxnBuffer, GiftCardId, GiftCardRefundAmount, MultipleGiftCards, StoreCreditSeen);
        QueueRow."Gift Card Refund" := GiftCardRefundAmount > 0;
        QueueRow."Gift Card Refund Amount" := GiftCardRefundAmount;
        // Two gift cards cannot be matched to one voucher, and store credit has no voucher at all: settle, skip the top-up, keep the flag.
        QueueRow."Voucher No." := '';
        if (GiftCardRefundAmount > 0) and not MultipleGiftCards and not StoreCreditSeen then
            QueueRow."Voucher No." := ResolveVoucherNo(ShopifyStore.Code, QueueRow."Order Id", GiftCardId);
    end;

    /// <summary>
    /// Sums the refund money that stays with Shopify as a customer liability: gift cards and store credit.
    /// </summary>
    local procedure SummariseGiftCardRefund(var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary; var GiftCardId: Text[30]; var GiftCardRefundAmount: Decimal; var MultipleGiftCards: Boolean; var StoreCreditSeen: Boolean)
    var
        GiftCardIds: List of [Text];
        UnknownGiftCardCount: Integer;
    begin
        Clear(GiftCardId);
        Clear(GiftCardRefundAmount);
        StoreCreditSeen := false;
        TempRefundTxnBuffer.Reset();
        if TempRefundTxnBuffer.FindSet() then
            repeat
                if _SpfyLegacyReturnMgt.IsStoreCreditRefundTxn(TempRefundTxnBuffer) then begin
                    GiftCardRefundAmount += TempRefundTxnBuffer.Amount;
                    StoreCreditSeen := true;
                end else
                    if _SpfyLegacyReturnMgt.IsGiftCardRefundTxn(TempRefundTxnBuffer) then begin
                        GiftCardRefundAmount += TempRefundTxnBuffer.Amount;
                        // Count cards, not transactions; a gift card transaction without an id counts as its own card.
                        if TempRefundTxnBuffer."Gift Card Id" = '' then
                            UnknownGiftCardCount += 1
                        else
                            if not GiftCardIds.Contains(TempRefundTxnBuffer."Gift Card Id") then
                                GiftCardIds.Add(TempRefundTxnBuffer."Gift Card Id");
                    end;
            until TempRefundTxnBuffer.Next() = 0;
        MultipleGiftCards := GiftCardIds.Count() + UnknownGiftCardCount > 1;
        if (not MultipleGiftCards) and (GiftCardIds.Count() = 1) then
            GiftCardId := CopyStr(GiftCardIds.Get(1), 1, MaxStrLen(GiftCardId));
    end;

    /// <summary>
    /// Refusals before anything is built or adopted: not closed, exchanges, money paid out beyond the lines (no account until CORE-2301).
    /// </summary>
    local procedure CheckReturnIsImportable(var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary)
    begin
        if TempReturnBuffer.Status <> 'CLOSED' then
            Error(_ReturnNotClosedErr, TempReturnBuffer."Return Name", TempReturnBuffer.Status);
        if TempReturnBuffer."Has Exchange Line" then
            Error(_ExchangeNotSupportedErr, TempReturnBuffer."Return Name");
        if TempReturnBuffer."Refund Beyond Lines Amount" <> 0 then
            Error(_RefundBeyondLinesErr, TempReturnBuffer."Return Name", TempReturnBuffer."Refund Beyond Lines Amount");
    end;

    local procedure FindCustomer(NpEcStore: Record "NPR NpEc Store"; OrderToken: JsonToken; var Customer: Record Customer)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        CountryCode: Code[10];
        ShopifyCustomerID: Text[30];
        Email: Text;
        Phone: Text;
        FirstName: Text;
        LastName: Text;
        PostCode: Text;
        BillingAdd1: Text;
        BillingAdd2: Text;
        BillingCity: Text;
        CustomerName: Text;
    begin
        _OrderMgt.GetCustomerIdentifiers(OrderToken, Email, Phone, ShopifyCustomerID, 'customer.defaultAddress.phone', true);
        FirstName := _JsonHelper.GetJText(OrderToken, 'customer.firstName', false);
        LastName := _JsonHelper.GetJText(OrderToken, 'customer.lastName', false);
        if _OrderMgt.TryFindCustomer(NpEcStore, OrderToken, ShopifyCustomerID, Email, Phone, FirstName, LastName, Customer, SpfyStoreCustomerLink) then
            exit;
        CountryCode := _OrderMgt.GetCountryCode(NpEcStore, OrderToken, 'billingAddress.countryCodeV2', false);
        PostCode := _JsonHelper.GetJCode(OrderToken, 'billingAddress.zip', MaxStrLen(Customer."Post Code"), false);
        BillingAdd1 := _JsonHelper.GetJText(OrderToken, 'billingAddress.address1', MaxStrLen(Customer.Address), false);
        BillingAdd2 := _JsonHelper.GetJText(OrderToken, 'billingAddress.address2', MaxStrLen(Customer."Address 2"), false);
        BillingCity := _JsonHelper.GetJText(OrderToken, 'billingAddress.city', MaxStrLen(Customer.City), false);
        CustomerName := (FirstName + ' ' + LastName).Trim();
        _OrderMgt.ResolveCustomer(NpEcStore, Email, Phone, BillingCity, BillingAdd1, BillingAdd2, CountryCode, PostCode, ShopifyCustomerID, CustomerName, Customer, SpfyStoreCustomerLink);
    end;

    local procedure ResolveHeaderLocation(ShopifyStoreCode: Code[20]; NpEcStore: Record "NPR NpEc Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var LocationCode: Code[10]; var UsedFallback: Boolean)
    var
        Location: Record Location;
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        CandidateLocationCode: Code[10];
        FirstResolvedLocationCode: Code[10];
        AllAgree: Boolean;
        AnyResolved: Boolean;
    begin
        AllAgree := true;
        TempLineBuffer.Reset();
        if TempLineBuffer.FindSet() then
            repeat
                if SpfyStoreLinkMgt.FindLocationCodeByShopifyLocationID(ShopifyStoreCode, TempLineBuffer."Disposition Location Id", CandidateLocationCode) then
                    if not AnyResolved then begin
                        FirstResolvedLocationCode := CandidateLocationCode;
                        AnyResolved := true;
                    end else
                        if CandidateLocationCode <> FirstResolvedLocationCode then
                            AllAgree := false;
            until TempLineBuffer.Next() = 0;
        UsedFallback := false;
        if AnyResolved and AllAgree then begin
            LocationCode := FirstResolvedLocationCode;
            exit;
        end;
        UsedFallback := true;
        if NpEcStore.LocationCode <> '' then begin
            LocationCode := NpEcStore.LocationCode;
            exit;
        end;
        if AnyResolved then begin
            LocationCode := FirstResolvedLocationCode;
            exit;
        end;
        Error(_NoLocationErr, Location.TableCaption(), ReturnName, NpEcStore.TableCaption(), NpEcStore.FieldCaption(LocationCode));
    end;

    local procedure CreateSalesHeader(ShopifyStore: Record "NPR Spfy Store"; NpEcStore: Record "NPR NpEc Store"; Customer: Record Customer; LocationCode: Code[10]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var SalesHeader: Record "Sales Header")
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        CurrencyCode: Code[10];
        CurrencyIsLCY: Boolean;
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Validate("Location Code", LocationCode);
        if TempReturnBuffer."Closed At" <> 0DT then
            SalesHeader.Validate("Posting Date", DT2Date(TempReturnBuffer."Closed At"));
        SalesHeader.Validate("Prices Including VAT", true);
        CurrencyCode := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(TempReturnBuffer."Presentment Currency Code", SpfyIntegrationMgt.CurrencyBlankForLCY(ShopifyStore.Code), CurrencyIsLCY);
        if CurrencyCode <> SalesHeader."Currency Code" then
            SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader."External Document No." := CopyStr(SpfyIntegrationMgt.BuildExternalDocumentNo(ShopifyStore.Code, TempReturnBuffer."Order No.", TempReturnBuffer."Order Name", MaxStrLen(SalesHeader."External Document No.")), 1, MaxStrLen(SalesHeader."External Document No."));
        if NpEcStore."Salesperson/Purchaser Code" <> '' then
            SalesHeader.Validate("Salesperson Code", NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");
        // Blank: BC would otherwise balance the credit memo itself and the settlement would fail.
        SalesHeader.Validate("Payment Method Code", '');
        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesLines(ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; SalesHeader: Record "Sales Header")
    var
        LineNo: Integer;
    begin
        TempLineBuffer.Reset();
        if not TempLineBuffer.FindSet() then
            exit;
        repeat
            LineNo += 10000;
            if TempLineBuffer."Gift Card" then
                CreateGiftCardLine(ShopifyStore, ReturnName, TempLineBuffer, SalesHeader, LineNo)
            else
                CreateItemLine(ShopifyStore, ReturnName, TempLineBuffer, SalesHeader, LineNo);
        until TempLineBuffer.Next() = 0;
    end;

    local procedure CreateItemLine(ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; SalesHeader: Record "Sales Header"; LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        LineItemToken: JsonToken;
        Sku: Text;
        LineLocationCode: Code[10];
        UseGenericItem: Boolean;
    begin
        UseGenericItem := UsesGenericItem(ShopifyStore, TempLineBuffer.SKU);
        if UseGenericItem then
            Item.Get(ShopifyStore."Return Generic Item No.")
        else begin
            TempLineBuffer.GetLineItemJson(LineItemToken);
            if not SpfyItemMgt.ParseItemForDocumentImport(ShopifyStore.Code, LineItemToken, ItemVariant, Item, Sku) then
                Error(_ItemNotFoundErr, Item.TableCaption(), TempLineBuffer.SKU, ReturnName);
        end;

        InitSalesLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        if ItemVariant.Code <> '' then
            SalesLine.Validate("Variant Code", ItemVariant.Code);
        if UseGenericItem then begin
            if TempLineBuffer.Title <> '' then
                SalesLine.Description := CopyStr(TempLineBuffer.Title, 1, MaxStrLen(SalesLine.Description));
            SalesLine."Description 2" := CopyStr(TempLineBuffer.SKU, 1, MaxStrLen(SalesLine."Description 2"));
        end;
        if Item.IsInventoriableType() then
            if SpfyStoreLinkMgt.FindLocationCodeByShopifyLocationID(ShopifyStore.Code, TempLineBuffer."Disposition Location Id", LineLocationCode) then
                SalesLine.Validate("Location Code", LineLocationCode);
        SalesLine.Validate(Quantity, TempLineBuffer.Quantity);
        // VAT % stays at the VAT Posting Setup, as on the order import.
        SalesLine.Validate("Unit Price", TempLineBuffer."Unit Price");
        if TempLineBuffer."Line Amount" <> 0 then
            SalesLine.Validate("Line Amount", TempLineBuffer."Line Amount");
        SalesLine.Modify(true);
        if TempLineBuffer."Order Line Item Id" <> '' then
            _SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TempLineBuffer."Order Line Item Id", false);
    end;

    /// <summary>
    /// A returned gift card is credited on the account its sale was posted on, and the vouchers that sale issued are attached for reversal at posting.
    /// </summary>
    local procedure CreateGiftCardLine(ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; SalesHeader: Record "Sales Header"; LineNo: Integer)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceLine: Record "Sales Invoice Line" temporary;
        SalesLine: Record "Sales Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        UnusedCount: Integer;
    begin
        // Without a refund there is nothing to credit, and a zero line would leave the cards active.
        if TempLineBuffer."Line Amount" <= 0 then
            Error(_GiftCardNoRefundErr, ReturnName, TempLineBuffer."Order Line Item Id");
        if not FindPostedGiftCardSaleLines(ShopifyStore.Code, TempLineBuffer."Order Line Item Id", TempSalesInvoiceLine) then
            Error(_GiftCardSaleNotFoundErr, TempSalesInvoiceLine.TableCaption(), TempLineBuffer."Order Line Item Id", ReturnName);
        UnusedCount := CollectUnusedVouchers(TempSalesInvoiceLine, TempLineBuffer.Quantity, TempVoucher);
        if UnusedCount < TempLineBuffer.Quantity then
            Error(_GiftCardUsedErr, ReturnName, TempLineBuffer.Quantity, SalesInvoiceHeader.TableCaption(), InvoiceNos(TempSalesInvoiceLine), UnusedCount);

        // Every sale line of the gift card carries the same account; the first supplies the posting groups.
        TempSalesInvoiceLine.FindFirst();
        InitSalesLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", TempSalesInvoiceLine."No.");
        if SalesLine."Gen. Prod. Posting Group" <> TempSalesInvoiceLine."Gen. Prod. Posting Group" then
            SalesLine.Validate("Gen. Prod. Posting Group", TempSalesInvoiceLine."Gen. Prod. Posting Group");
        if SalesLine."VAT Prod. Posting Group" <> TempSalesInvoiceLine."VAT Prod. Posting Group" then
            SalesLine.Validate("VAT Prod. Posting Group", TempSalesInvoiceLine."VAT Prod. Posting Group");
        SalesLine.Description := TempSalesInvoiceLine.Description;
        SalesLine.Validate(Quantity, TempLineBuffer.Quantity);
        SalesLine.Validate("Unit Price", TempLineBuffer."Unit Price");
        SalesLine.Validate("Line Amount", TempLineBuffer."Line Amount");
        SalesLine.Modify(true);
        _SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TempLineBuffer."Order Line Item Id", false);
        AttachVouchersToRevoke(SalesHeader, SalesLine, TempVoucher);
    end;

    local procedure InitSalesLine(SalesHeader: Record "Sales Header"; LineNo: Integer; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
    end;

    /// <summary>
    /// Collects every posted G/L invoice line of the store that carries the Shopify line item: one line can be invoiced in parts.
    /// </summary>
    local procedure FindPostedGiftCardSaleLines(ShopifyStoreCode: Code[20]; OrderLineItemId: Text[30]; var TempSalesInvoiceLine: Record "Sales Invoice Line" temporary): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RecRef: RecordRef;
    begin
        TempSalesInvoiceLine.Reset();
        TempSalesInvoiceLine.DeleteAll();
        if OrderLineItemId = '' then
            exit(false);
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Invoice Line", "NPR Spfy ID Type"::"Entry ID", OrderLineItemId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesInvoiceLine);
                    if SalesInvoiceLine.Type = SalesInvoiceLine.Type::"G/L Account" then
                        if SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.") then
                            if _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then begin
                                TempSalesInvoiceLine := SalesInvoiceLine;
                                if TempSalesInvoiceLine.Insert() then;
                            end;
                end;
            until ShopifyAssignedID.Next() = 0;
        exit(not TempSalesInvoiceLine.IsEmpty());
    end;

    local procedure InvoiceNos(var TempSalesInvoiceLine: Record "Sales Invoice Line" temporary) Nos: Text
    var
        Seen: List of [Code[20]];
    begin
        TempSalesInvoiceLine.FindSet();
        repeat
            if not Seen.Contains(TempSalesInvoiceLine."Document No.") then begin
                Seen.Add(TempSalesInvoiceLine."Document No.");
                if Nos <> '' then
                    Nos += ', ';
                Nos += TempSalesInvoiceLine."Document No.";
            end;
        until TempSalesInvoiceLine.Next() = 0;
    end;

    /// <summary>
    /// Collects up to MaxCount untouched vouchers of the invoice lines that no open document claims; used, topped-up or revoked cards are skipped.
    /// </summary>
    local procedure CollectUnusedVouchers(var TempSalesInvoiceLine: Record "Sales Invoice Line" temporary; MaxCount: Decimal; var TempVoucher: Record "NPR NpRv Voucher" temporary) Collected: Integer
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
    begin
        TempSalesInvoiceLine.FindSet();
        repeat
            VoucherEntry.Reset();
            VoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.", "Document Line No.");
            VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
            VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
            VoucherEntry.SetRange("Document No.", TempSalesInvoiceLine."Document No.");
            VoucherEntry.SetRange("Document Line No.", TempSalesInvoiceLine."Line No.");
            if VoucherEntry.FindSet() then
                repeat
                    if Collected < MaxCount then
                        if Voucher.Get(VoucherEntry."Voucher No.") then
                            if IsUnusedVoucher(Voucher) then
                                if not IsClaimedByOpenDocument(Voucher."No.") then begin
                                    TempVoucher := Voucher;
                                    TempVoucher.Insert();
                                    Collected += 1;
                                end;
                until VoucherEntry.Next() = 0;
        until TempSalesInvoiceLine.Next() = 0;
    end;

    /// <summary>
    /// A card referenced by an unposted voucher sales line is claimed by an open draft; posting deletes those lines, so a posted return never claims.
    /// </summary>
    local procedure IsClaimedByOpenDocument(VoucherNo: Code[20]): Boolean
    var
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLineRef.SetRange("Voucher No.", VoucherNo);
        NpRvSalesLineRef.SetRange(Posted, false);
        if not NpRvSalesLineRef.FindSet() then
            exit(false);
        repeat
            if NpRvSalesLine.Get(NpRvSalesLineRef."Sales Line Id") then
                if not NpRvSalesLine.Posted then
                    exit(true);
        until NpRvSalesLineRef.Next() = 0;
        exit(false);
    end;

    local procedure IsUnusedVoucher(Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        // A card in use as a payment, reserved by amount or by a global reservation, is spoken for and is left alone.
        Voucher.CalcFields("Reserved Amount", "In-use Quantity");
        if (Voucher."Reserved Amount" <> 0) or (Voucher."In-use Quantity" <> 0) then
            exit(false);
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        if VoucherEntry.Count() <> 1 then
            exit(false);
        VoucherEntry.FindFirst();
        if VoucherEntry."Entry Type" <> VoucherEntry."Entry Type"::"Issue Voucher" then
            exit(false);
        exit(VoucherEntry.Open and (VoucherEntry.Amount > 0) and (VoucherEntry."Remaining Amount" = VoucherEntry.Amount));
    end;

    /// <summary>
    /// Attaches the voucher module's reversal shape: a voucher sales line with one reference per card, posted as a corrective entry on each voucher.
    /// </summary>
    local procedure AttachVouchersToRevoke(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        TempVoucher.Reset();
        TempVoucher.FindSet();
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := SalesLine."Document Type";
        NpRvSalesLine."Document No." := SalesLine."Document No.";
        NpRvSalesLine."Document Line No." := SalesLine."Line No.";
        NpRvSalesLine."External Document No." := SalesHeader."External Document No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := TempVoucher."Voucher Type";
        NpRvSalesLine.Description := CopyStr(SalesLine.Description, 1, MaxStrLen(NpRvSalesLine.Description));
        if TempVoucher.Count() = 1 then begin
            NpRvSalesLine."Voucher No." := TempVoucher."No.";
            NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        end;
        NpRvSalesLine.Insert(true);
        repeat
            Voucher := TempVoucher;
            NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLine, Voucher);
        until TempVoucher.Next() = 0;
    end;

    local procedure UsesGenericItem(ShopifyStore: Record "NPR Spfy Store"; Sku: Text[100]): Boolean
    begin
        if (ShopifyStore."Return Generic SKU Prefix" = '') or (ShopifyStore."Return Generic Item No." = '') or (Sku = '') then
            exit(false);
        exit(UpperCase(CopyStr(Sku, 1, StrLen(ShopifyStore."Return Generic SKU Prefix"))) = UpperCase(ShopifyStore."Return Generic SKU Prefix"));
    end;

    local procedure CreateGLLine(SalesHeader: Record "Sales Header"; GLAccountNo: Code[20]; Amount: Decimal; Description: Text)
    var
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        if (GLAccountNo = '') or (Amount = 0) then
            exit;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            LineNo := SalesLine."Line No.";
        LineNo += 10000;
        InitSalesLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccountNo);
        SalesLine.Description := CopyStr(Description, 1, MaxStrLen(SalesLine.Description));
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", Amount);
        SalesLine.Modify(true);
    end;

    local procedure VerifyDocumentCoversRefund(SalesHeader: Record "Sales Header"; ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; TotalRefund: Decimal)
    var
        SalesLine: Record "Sales Line";
        TotalDocument: Decimal;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.CalcSums("Amount Including VAT");
        TotalDocument := SalesLine."Amount Including VAT";
        if TotalRefund = 0 then
            Error(_NoRefundFoundErr, ReturnName, TotalDocument);
        // Exact: the posting subscriber refuses a credit memo worth more than its payment lines beyond invoice rounding.
        if TotalDocument < TotalRefund then
            Error(_RefundTotalShortErr, TotalDocument, ReturnName, TotalRefund, TotalRefund - TotalDocument, ShopifyStore.FieldCaption("Ret. Shipping Refund G/L Acc."), ShopifyStore.TableCaption());
        if TotalDocument > TotalRefund then
            Error(_RefundTotalOverErr, TotalDocument, ReturnName, TotalRefund, TotalDocument - TotalRefund);
    end;

    local procedure RefundTotal(var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary): Decimal
    begin
        TempRefundTxnBuffer.Reset();
        TempRefundTxnBuffer.CalcSums(Amount);
        exit(TempRefundTxnBuffer.Amount);
    end;

    /// <summary>
    /// What a draft's own payment lines say Shopify refunded, so a reused draft is checked without another Shopify call.
    /// </summary>
    local procedure PaymentLinesTotal(SalesHeader: Record "Sales Header"; ReturnName: Text[50]): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.CalcSums(Amount);
        if PaymentLine.Amount = 0 then
            Error(_DraftPaymentsMissingErr, SalesHeader.TableCaption(), SalesHeader."No.", ReturnName);
        exit(PaymentLine.Amount);
    end;

    local procedure InsertPaymentLines(SalesHeader: Record "Sales Header"; ShopifyStoreCode: Code[20]; ReturnId: Text[30]; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        LineNo: Integer;
    begin
        TempRefundTxnBuffer.Reset();
        if not TempRefundTxnBuffer.FindSet() then
            exit;
        repeat
            LineNo += 10000;
            PaymentLine.Init();
            PaymentLine."Document Table No." := Database::"Sales Header";
            PaymentLine."Document Type" := SalesHeader."Document Type";
            PaymentLine."Document No." := SalesHeader."No.";
            PaymentLine."Line No." := LineNo;
            PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
            PaymentLine.Description := CopyStr(TempRefundTxnBuffer.Gateway + ' ' + ReturnId, 1, MaxStrLen(PaymentLine.Description));
            PaymentLine.Amount := TempRefundTxnBuffer.Amount;
            PaymentLine."Requested Amount" := TempRefundTxnBuffer.Amount;
            PaymentLine."Amount (Store Currency)" := TempRefundTxnBuffer."Amount (Store Currency)";
            PaymentLine."Requested Amt. (Store Curr.)" := TempRefundTxnBuffer."Amount (Store Currency)";
            PaymentLine."Store Currency Code" := TempRefundTxnBuffer."Store Currency Code";
            PaymentLine."Posting Date" := SalesHeader."Posting Date";
            PaymentLine."External Payment Type" := TempRefundTxnBuffer.Kind;
            PaymentLine."External Payment Method Code" := TempRefundTxnBuffer.Gateway;
            PaymentLine."External Payment Gateway" := CopyStr(TempRefundTxnBuffer.Gateway, 1, MaxStrLen(PaymentLine."External Payment Gateway"));
            PaymentLine."External Reference No." := CopyStr(TempRefundTxnBuffer."Transaction Id", 1, MaxStrLen(PaymentLine."External Reference No."));
            PaymentLine."Transaction ID" := TempRefundTxnBuffer."Transaction Id";
            PaymentLine."Payment Gateway Code" := SpfyCapturePayment.ShopifyPaymentGateway(TempRefundTxnBuffer."Store Currency Code");
            PaymentLine."Date Refunded" := RefundDate(TempRefundTxnBuffer."Processed At", TempRefundTxnBuffer."Created At", SalesHeader."Posting Date");
            // Invoice rounding can lift the credit memo above the refund; the mapping's flag lets the posting accept it, as on the order import.
            if SpfyCapturePayment.FindPaymentMapping(TempRefundTxnBuffer.Gateway, TempRefundTxnBuffer."Credit Card Company", ShopifyStoreCode, PaymentMapping) then
                PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
            PaymentLine.Insert(true);
            _SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TempRefundTxnBuffer."Transaction Id", false);
        until TempRefundTxnBuffer.Next() = 0;
    end;

    local procedure StampRefundDateOnPaymentLines(SalesHeader: Record "Sales Header"; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        TransactionId: Text[30];
        ProcessedAt: DateTime;
        CreatedAt: DateTime;
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if not PaymentLine.FindSet(true) then
            exit;
        repeat
            if PaymentLine."Date Refunded" = 0D then begin
                ProcessedAt := 0DT;
                CreatedAt := 0DT;
                TransactionId := _SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                if TransactionId <> '' then begin
                    TempRefundTxnBuffer.Reset();
                    TempRefundTxnBuffer.SetRange("Transaction Id", TransactionId);
                    if TempRefundTxnBuffer.FindFirst() then begin
                        ProcessedAt := TempRefundTxnBuffer."Processed At";
                        CreatedAt := TempRefundTxnBuffer."Created At";
                    end;
                end;
                PaymentLine."Date Refunded" := RefundDate(ProcessedAt, CreatedAt, SalesHeader."Posting Date");
                PaymentLine.Modify(true);
            end;
        until PaymentLine.Next() = 0;
        TempRefundTxnBuffer.Reset();
    end;

    /// <summary>
    /// Refund date for a payment line. Never blank, or posting would ask the payment gateway to refund it again.
    /// </summary>
    local procedure RefundDate(ProcessedAt: DateTime; CreatedAt: DateTime; PostingDate: Date): Date
    begin
        if ProcessedAt <> 0DT then
            exit(DT2Date(ProcessedAt));
        if CreatedAt <> 0DT then
            exit(DT2Date(CreatedAt));
        exit(PostingDate);
    end;

    local procedure ResolveVoucherNo(ShopifyStoreCode: Code[20]; OrderId: Text[30]; GiftCardId: Text[30]): Code[20]
    var
        Voucher: Record "NPR NpRv Voucher";
        Found: Boolean;
    begin
        // No "or": AL evaluates both operands, and both write the voucher.
        Found := FindVoucherByGiftCardId(GiftCardId, Voucher);
        // A card id BC does not know may be a different card, so the order's voucher is only a guess without one.
        if (not Found) and (GiftCardId = '') then
            Found := FindVoucherForShopifyOrder(ShopifyStoreCode, OrderId, Voucher);
        if Found then
            exit(Voucher."No.");
        exit('');
    end;

    local procedure FindVoucherByGiftCardId(GiftCardId: Text[30]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
    begin
        if GiftCardId = '' then
            exit(false);
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR NpRv Voucher", "NPR Spfy ID Type"::"Entry ID", GiftCardId, ShopifyAssignedID);
        if ShopifyAssignedID.FindLast() then
            if Voucher.Get(ShopifyAssignedID."BC Record ID") then
                exit(true);
        // A card spent to zero is archived with its Shopify id; the row carries the card's own number and the posting restores it.
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR NpRv Arch. Voucher", "NPR Spfy ID Type"::"Entry ID", GiftCardId, ShopifyAssignedID);
        if not ShopifyAssignedID.FindLast() then
            exit(false);
        if not ArchVoucher.Get(ShopifyAssignedID."BC Record ID") then
            exit(false);
        Voucher.Init();
        Voucher."No." := ArchVoucher."Arch. No.";
        if Voucher."No." = '' then
            Voucher."No." := ArchVoucher."No.";
        exit(true);
    end;

    local procedure FindVoucherForShopifyOrder(ShopifyStoreCode: Code[20]; OrderId: Text[30]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        VoucherPaymentLine: Record "NPR Magento Payment Line";
        RecRef: RecordRef;
        VoucherLineCount: Integer;
    begin
        if OrderId = '' then
            exit(false);
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Invoice Header", "NPR Spfy ID Type"::"Entry ID", OrderId, ShopifyAssignedID);
        if not ShopifyAssignedID.FindSet() then
            exit(false);
        // Exactly one voucher across the order's invoices, or none: never guess between cards. Partial invoicing keeps the payment lines on one invoice.
        repeat
            if _SpfyAssignedIDMgt.GetAssignedShopifyID(ShopifyAssignedID."BC Record ID", "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                    PaymentLine.SetRange("Document Type", Enum::"Sales Document Type".FromInteger(0));
                    PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
                    if PaymentLine.FindSet() then
                        repeat
                            VoucherLineCount += 1;
                            VoucherPaymentLine := PaymentLine;
                        until PaymentLine.Next() = 0;
                end;
        until ShopifyAssignedID.Next() = 0;
        if VoucherLineCount <> 1 then
            exit(false);
        if VoucherPaymentLine."Source No." <> '' then
            if Voucher.Get(VoucherPaymentLine."Source No.") then
                exit(true);
        if VoucherPaymentLine."No." = '' then
            exit(false);
        Voucher.Reset();
        Voucher.SetRange("Reference No.", VoucherPaymentLine."No.");
        exit(Voucher.FindFirst());
    end;

    /// <summary>
    /// A return is posted in full whatever "Default Quantity to Ship" says: with Blank the platform leaves the quantities to post at zero.
    /// </summary>
    local procedure SetQuantitiesToPost(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>0');
        if not SalesLine.FindSet(true) then
            exit;
        repeat
            if SalesLine."Return Qty. to Receive" <> SalesLine.Quantity then
                SalesLine.Validate("Return Qty. to Receive", SalesLine.Quantity);
            if SalesLine."Qty. to Invoice" <> SalesLine.Quantity then
                SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity);
            SalesLine.Modify(true);
        until SalesLine.Next() = 0;
    end;

    local procedure PostSalesHeader(var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SetQuantitiesToPost(SalesHeader);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();
        Clear(SalesPost);
        SalesPost.Run(SalesHeader);
    end;
}
