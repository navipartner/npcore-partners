codeunit 6151149 "NPR Spfy Legacy Return Mgt."
{
    Access = Internal;

    /// <summary>
    /// The ID type a Shopify return or refund is stamped with on its documents: a return keeps the Entry ID, a refund has a type of its own, since its number may equal a return's.
    /// </summary>
    internal procedure SourceDocIdType(SourceDocType: Enum "NPR Spfy Legacy Return Source"): Enum "NPR Spfy ID Type"
    begin
        if SourceDocType = SourceDocType::Refund then
            exit("NPR Spfy ID Type"::"Refund ID");
        exit("NPR Spfy ID Type"::"Entry ID");
    end;

    /// <summary>
    /// The Shopify return or refund a document is stamped with: a refund id first, else the Entry ID as a return's.
    /// </summary>
    internal procedure GetSourceDocStamp(DocumentRecordId: RecordId; var SourceDocType: Enum "NPR Spfy Legacy Return Source"; var ShopifyId: Text[30]): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        ShopifyId := SpfyAssignedIDMgt.GetAssignedShopifyID(DocumentRecordId, SourceDocIdType(SourceDocType::Refund));
        if ShopifyId <> '' then begin
            SourceDocType := SourceDocType::Refund;
            exit(true);
        end;
        SourceDocType := SourceDocType::Return;
        ShopifyId := SpfyAssignedIDMgt.GetAssignedShopifyID(DocumentRecordId, SourceDocIdType(SourceDocType::Return));
        exit(ShopifyId <> '');
    end;

    /// <summary>
    /// The Shopify order line a document line belongs to: its Entry ID, or the line a discount given after the sale credits.
    /// </summary>
    internal procedure GetOrderLineItemStamp(DocumentLineRecordId: RecordId): Text[30]
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        LineItemId: Text[30];
    begin
        LineItemId := SpfyAssignedIDMgt.GetAssignedShopifyID(DocumentLineRecordId, "NPR Spfy ID Type"::"Entry ID");
        if LineItemId = '' then
            LineItemId := SpfyAssignedIDMgt.GetAssignedShopifyID(DocumentLineRecordId, "NPR Spfy ID Type"::"Post-Sale Disc. Line Item ID");
        exit(LineItemId);
    end;

    internal procedure FindPostedDocumentForReturn(ShopifyStoreCode: Code[20]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; ShopifyId: Text[30]; var PostedDocNo: Code[20]): Boolean
    var
        IsCreditMemo: Boolean;
    begin
        exit(FindPostedDocumentForReturn(ShopifyStoreCode, SourceDocType, ShopifyId, PostedDocNo, IsCreditMemo));
    end;

    /// <summary>
    /// Finds a posted credit memo or return receipt stamped with the return or refund, credit memo first.
    /// </summary>
    internal procedure FindPostedDocumentForReturn(ShopifyStoreCode: Code[20]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; ShopifyId: Text[30]; var PostedDocNo: Code[20]; var IsCreditMemo: Boolean): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        RecRef: RecordRef;
    begin
        Clear(PostedDocNo);
        IsCreditMemo := false;
        if ShopifyId = '' then
            exit(false);
        // Table 114 sorts before 6660, so a credit memo is found first.
        ShopifyAssignedID.SetCurrentKey("Table No.", "Shopify ID Type", "Shopify ID");
        ShopifyAssignedID.SetFilter("Table No.", '%1|%2', Database::"Sales Cr.Memo Header", Database::"Return Receipt Header");
        ShopifyAssignedID.SetRange("Shopify ID Type", SourceDocIdType(SourceDocType));
        ShopifyAssignedID.SetRange("Shopify ID", ShopifyId);
        if not ShopifyAssignedID.FindSet() then
            exit(false);
        repeat
            if SpfyAssignedIDMgt.GetAssignedShopifyID(ShopifyAssignedID."BC Record ID", "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then
                    case ShopifyAssignedID."Table No." of
                        Database::"Sales Cr.Memo Header":
                            begin
                                RecRef.SetTable(SalesCrMemoHeader);
                                PostedDocNo := SalesCrMemoHeader."No.";
                                IsCreditMemo := true;
                                exit(true);
                            end;
                        Database::"Return Receipt Header":
                            begin
                                RecRef.SetTable(ReturnReceiptHeader);
                                PostedDocNo := ReturnReceiptHeader."No.";
                                exit(true);
                            end;
                    end;
        until ShopifyAssignedID.Next() = 0;
        exit(false);
    end;

    internal procedure FindDraftForReturn(ShopifyStoreCode: Code[20]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; ShopifyId: Text[30]; var SalesHeader: Record "Sales Header"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        RecRef: RecordRef;
    begin
        if ShopifyId = '' then
            exit(false);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Header", SourceDocIdType(SourceDocType), ShopifyId, ShopifyAssignedID);
        if not ShopifyAssignedID.FindSet() then
            exit(false);
        repeat
            if SpfyAssignedIDMgt.GetAssignedShopifyID(ShopifyAssignedID."BC Record ID", "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesHeader);
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
                        exit(true);
                end;
        until ShopifyAssignedID.Next() = 0;
        exit(false);
    end;

    /// <summary>
    /// The queue row behind a Return Order, selected by its number and the return or refund the header carries and confirmed by the store.
    /// </summary>
    internal procedure FindQueueRowBySalesHeader(SalesHeader: Record "Sales Header"; var QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    var
        SourceDocType: Enum "NPR Spfy Legacy Return Source";
        ShopifyId: Text[30];
    begin
        if SalesHeader."No." = '' then
            exit(false);
        if not GetSourceDocStamp(SalesHeader.RecordId(), SourceDocType, ShopifyId) then
            exit(false);
        QueueRow.Reset();
        QueueRow.SetCurrentKey("Sales Header Doc. No.");
        QueueRow.SetRange("Sales Header Doc. No.", SalesHeader."No.");
        QueueRow.SetRange("Source Doc. Type", SourceDocType);
        QueueRow.SetRange("Source Doc. ID", ShopifyId);
        if not QueueRow.FindFirst() then
            exit(false);
        exit(CarriesReturnIds(SalesHeader.RecordId(), QueueRow));
    end;

    /// <summary>
    /// Records the posted document on the queue row inside the posting transaction; settlement is the posting codeunit's.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure RecordPostedDocumentOnQueueRow(var SalesHeader: Record "Sales Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var PreviewMode: Boolean)
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
    begin
        if PreviewMode then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Return Order" then
            exit;
        if not FindQueueRowBySalesHeader(SalesHeader, QueueRow) then
            exit;
        if SalesCrMemoHeader."No." <> '' then begin
            QueueRow."Posted Doc. No." := SalesCrMemoHeader."No.";
            QueueRow.Validate(Status, QueueRow.Status::Imported);
            QueueRow."Last Error" := '';
        end else
            if ReturnReceiptHeader."No." <> '' then
                QueueRow."Posted Doc. No." := ReturnReceiptHeader."No."
            else
                exit;
        QueueRow.Modify();
    end;

    local procedure RowCaption(QueueRow: Record "NPR Spfy NC Return Queue"): Text[50]
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
    begin
        exit(SpfyLegacyReturnAPI.DocumentCaption(QueueRow."Source Doc. Type", QueueRow."Source Doc. Name", QueueRow."Source Doc. ID"));
    end;

    internal procedure ErrorIfAlreadyPosted(QueueRow: Record "NPR Spfy NC Return Queue")
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        AlreadyPostedErr: Label 'Shopify %1 is already posted as %2 and cannot be processed again.', Comment = '%1 = Shopify document caption, %2 = posted document no.';
    begin
        if QueueRow."Posted Doc. No." = '' then
            exit;
        if not IsCreditMemoPosted(QueueRow) then
            if ReturnReceiptHeader.Get(QueueRow."Posted Doc. No.") then
                if CarriesReturnIds(ReturnReceiptHeader.RecordId(), QueueRow) then
                    ErrorReceivedNotInvoiced(QueueRow, ReturnReceiptHeader);
        Error(AlreadyPostedErr, RowCaption(QueueRow), QueueRow."Posted Doc. No.");
    end;

    /// <summary>
    /// Records a posted credit memo on the row and returns true. A return receipt alone raises the received-but-not-invoiced error.
    /// </summary>
    internal procedure RecordPostedCreditMemo(var QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        PostedDocNo: Code[20];
        IsCreditMemo: Boolean;
    begin
        if not FindPostedDocumentForReturn(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID", PostedDocNo, IsCreditMemo) then
            exit(false);
        if not IsCreditMemo then begin
            ReturnReceiptHeader.Get(PostedDocNo);
            ErrorReceivedNotInvoiced(QueueRow, ReturnReceiptHeader);
        end;
        QueueRow."Posted Doc. No." := PostedDocNo;
        QueueRow.Modify();
        exit(true);
    end;

    local procedure ErrorReceivedNotInvoiced(QueueRow: Record "NPR Spfy NC Return Queue"; ReturnReceiptHeader: Record "Return Receipt Header")
    var
        SalesHeader: Record "Sales Header";
        AlreadyReceivedErr: Label 'Shopify %1 has been received as %2 but not yet invoiced, so the customer has not been credited. Invoice %3 %4 to raise the credit memo.', Comment = '%1 = Shopify document caption, %2 = return receipt no., %3 = Sales Header table caption, %4 = Return Order no.';
        InvoicedElsewhereErr: Label 'Shopify %1 was received as %2, and %3 %4 no longer exists, so it was invoiced outside this import. Settle the refund by hand and dismiss the queue row.', Comment = '%1 = Shopify document caption, %2 = return receipt no., %3 = Sales Header table caption, %4 = Return Order no.';
        DismissedInvoicedElsewhereErr: Label 'Shopify %1 is dismissed: it was received as %2 and invoiced outside this import, so it cannot be queued again.', Comment = '%1 = Shopify document caption, %2 = return receipt no.';
    begin
        if not ReturnOrderAwaitsInvoice(ReturnReceiptHeader) then begin
            if QueueRow.Status = QueueRow.Status::Dismissed then
                Error(DismissedInvoicedElsewhereErr, RowCaption(QueueRow), ReturnReceiptHeader."No.");
            Error(InvoicedElsewhereErr, RowCaption(QueueRow), ReturnReceiptHeader."No.", SalesHeader.TableCaption(), ReturnReceiptHeader."Return Order No.");
        end;
        Error(AlreadyReceivedErr, RowCaption(QueueRow), ReturnReceiptHeader."No.", SalesHeader.TableCaption(), ReturnReceiptHeader."Return Order No.");
    end;

    /// <summary>
    /// True while the receipt's Return Order still exists; once it is invoiced and gone, the row has nothing left to settle.
    /// </summary>
    local procedure ReturnOrderAwaitsInvoice(ReturnReceiptHeader: Record "Return Receipt Header"): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", ReturnReceiptHeader."Return Order No."));
    end;

    /// <summary>
    /// True when the row's posted document is a credit memo carrying this return's ids; a receipt and a credit memo can share a number.
    /// </summary>
    internal procedure IsCreditMemoPosted(QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if QueueRow."Posted Doc. No." = '' then
            exit(false);
        if not SalesCrMemoHeader.Get(QueueRow."Posted Doc. No.") then
            exit(false);
        exit(CarriesReturnIds(SalesCrMemoHeader.RecordId(), QueueRow));
    end;

    local procedure CarriesReturnIds(PostedRecordId: RecordId; QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        if SpfyAssignedIDMgt.GetAssignedShopifyID(PostedRecordId, SourceDocIdType(QueueRow."Source Doc. Type")) <> QueueRow."Source Doc. ID" then
            exit(false);
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(PostedRecordId, "NPR Spfy ID Type"::"Store Code") = QueueRow."Shopify Store Code");
    end;

    /// <summary>
    /// Refuses to delete a store that still has unfinished returns in the queue, and removes its finished ones (imported, dismissed, nothing to credit), which own no draft.
    /// </summary>
    internal procedure DeleteQueueRowsOfStore(ShopifyStoreCode: Code[20])
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        Settlement: Record "NPR Spfy Refund Settlement";
        UnfinishedReturnsErr: Label '%1 %2 still has returns or refunds in the %3 that are not imported, dismissed or found to have nothing to credit. Import, dismiss or delete them before deleting the store.', Comment = '%1 = Shopify Store table caption, %2 = Shopify store code, %3 = Shopify Legacy Return Queue table caption';
    begin
        // The poll locks the store row before it inserts: a row committed first refuses the delete, a delete committed first leaves the poll no store.
        ShopifyStore.LockTable();
        if ShopifyStore.Get(ShopifyStoreCode) then;
        QueueRow.SetRange("Shopify Store Code", ShopifyStoreCode);
        QueueRow.SetFilter(Status, '<>%1&<>%2&<>%3', QueueRow.Status::Imported, QueueRow.Status::Dismissed, QueueRow.Status::"Nothing to Credit");
        if not QueueRow.IsEmpty() then
            Error(UnfinishedReturnsErr, ShopifyStore.TableCaption(), ShopifyStoreCode, QueueRow.TableCaption());
        QueueRow.SetRange(Status);
        QueueRow.DeleteAll(false);
        Settlement.SetRange("Shopify Store Code", ShopifyStoreCode);
        Settlement.DeleteAll();
    end;

    internal procedure MarkImportedIfCreditMemoPosted(var QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    begin
        if not IsCreditMemoPosted(QueueRow) then
            exit(false);
        if (QueueRow.Status <> QueueRow.Status::Imported) or (QueueRow."Last Error" <> '') then begin
            QueueRow.Validate(Status, QueueRow.Status::Imported);
            QueueRow."Last Error" := '';
            QueueRow.Modify();
        end;
        exit(true);
    end;

    /// <summary>
    /// Locks the setup row the feature switch locks while it checks the queue, so whoever holds it sees the other side's result; then reads the feature.
    /// </summary>
    internal procedure FeatureSwitchedOn(): Boolean
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        Feature: Record "NPR Feature";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        SpfyIntegrationSetup.LockTable();
        if SpfyIntegrationSetup.Get() then;
        // Without waiting: a switch being saved holds the feature row and waits for this lock. Seeing its unsaved "on" only skips a pass.
        Feature.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not Feature.Get(ShopifyEcommOrderExp.GetFeatureId()) then
            exit(false);
        exit(Feature.Enabled);
    end;

    internal procedure DiscardDraft(var QueueRow: Record "NPR Spfy NC Return Queue")
    begin
        // A New row written after the switch would be stranded, so the feature is read under the switch's lock.
        if FeatureSwitchedOn() then
            ErrorIfEcommerceFeatureEnabled();
        // The caller's copy may be stale: a page shows the row as it was, the job may hold it now.
        QueueRow.LockTable();
        QueueRow.Get(QueueRow."Entry No.");
        ErrorIfBeingProcessed(QueueRow);
        ErrorIfAlreadyPosted(QueueRow);
        if RecordPostedCreditMemo(QueueRow) then begin
            MarkImportedIfCreditMemoPosted(QueueRow);
            Commit();
            ErrorIfAlreadyPosted(QueueRow);
        end;
        DeleteDraftDocument(QueueRow);
    end;

    /// <summary>
    /// Marks a return as handled outside the import: the row stays, so the poll does not queue the return again, and the job leaves it alone.
    /// </summary>
    internal procedure DismissReturn(var QueueRow: Record "NPR Spfy NC Return Queue")
    var
        SalesHeader: Record "Sales Header";
        Settlement: Record "NPR Spfy Refund Settlement";
        PostedDocNo: Code[20];
        OpenReturnOrderNo: Code[20];
        IsCreditMemo: Boolean;
        DismissImportedErr: Label 'Shopify %1 is imported as %2, so there is nothing to dismiss.', Comment = '%1 = Shopify document caption, %2 = posted credit memo no.';
        DismissWithDocumentErr: Label 'Shopify %1 still has %2 %3. Discard the draft, or invoice it if the goods have been received, before dismissing it.', Comment = '%1 = Shopify document caption, %2 = Sales Header table caption, %3 = Return Order no.';
    begin
        QueueRow.LockTable();
        QueueRow.Get(QueueRow."Entry No.");
        ErrorIfBeingProcessed(QueueRow);
        if FindPostedDocumentForReturn(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID", PostedDocNo, IsCreditMemo) then
            if IsCreditMemo then begin
                QueueRow."Posted Doc. No." := PostedDocNo;
                MarkImportedIfCreditMemoPosted(QueueRow);
                Commit();
                Error(DismissImportedErr, RowCaption(QueueRow), PostedDocNo);
            end;
        OpenReturnOrderNo := FindOpenReturnOrderNo(QueueRow);
        if OpenReturnOrderNo <> '' then
            Error(DismissWithDocumentErr, RowCaption(QueueRow), SalesHeader.TableCaption(), OpenReturnOrderNo);
        // No draft and no credit memo is left, so nothing is settled by the row any more.
        if Settlement.Get(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID") then
            Settlement.Delete();
        QueueRow.Validate(Status, QueueRow.Status::Dismissed);
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
    end;

    /// <summary>
    /// A dismissed return is reopened through Discard Draft and Retry only, so Process refuses it.
    /// </summary>
    internal procedure ErrorIfDismissed(QueueRow: Record "NPR Spfy NC Return Queue")
    var
        DismissedErr: Label 'Shopify %1 is dismissed. Use Discard Draft and Retry to queue it again before processing it.', Comment = '%1 = Shopify document caption';
    begin
        if QueueRow.Status = QueueRow.Status::Dismissed then
            Error(DismissedErr, RowCaption(QueueRow));
    end;

    /// <summary>
    /// The return's open Return Order: the row's draft, a draft carrying its ids, or the order its receipt awaits an invoice for.
    /// </summary>
    local procedure FindOpenReturnOrderNo(QueueRow: Record "NPR Spfy NC Return Queue"): Code[20]
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesHeader: Record "Sales Header";
        PostedDocNo: Code[20];
        IsCreditMemo: Boolean;
    begin
        if QueueRow."Sales Header Doc. No." <> '' then
            if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.") then
                exit(SalesHeader."No.");
        if FindDraftForReturn(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID", SalesHeader) then
            exit(SalesHeader."No.");
        if FindPostedDocumentForReturn(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID", PostedDocNo, IsCreditMemo) then
            if not IsCreditMemo then
                if ReturnReceiptHeader.Get(PostedDocNo) then
                    if ReturnOrderAwaitsInvoice(ReturnReceiptHeader) then
                        exit(ReturnReceiptHeader."Return Order No.");
        exit('');
    end;

    /// <summary>
    /// A deleted row takes its unposted draft with it; a received or dismissed return keeps its row.
    /// </summary>
    internal procedure OnDeleteQueueRow(var QueueRow: Record "NPR Spfy NC Return Queue")
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesHeader: Record "Sales Header";
        PostedDocNo: Code[20];
        IsCreditMemo: Boolean;
        ReceivedRowDeleteErr: Label 'Shopify %1 has been received as %2 but not yet invoiced, so its queue row cannot be deleted: the credit memo that invoices %3 %4 is settled through the row.', Comment = '%1 = Shopify document caption, %2 = return receipt no., %3 = Sales Header table caption, %4 = Return Order no.';
        DismissedRowDeleteErr: Label 'Shopify %1 is dismissed, so its queue row is kept and it is not queued again. Use Discard Draft and Retry to queue it again.', Comment = '%1 = Shopify document caption';
    begin
        ErrorIfBeingProcessed(QueueRow);
        if QueueRow.Status = QueueRow.Status::Dismissed then
            Error(DismissedRowDeleteErr, RowCaption(QueueRow));
        if IsCreditMemoPosted(QueueRow) then
            exit;
        if FindPostedDocumentForReturn(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID", PostedDocNo, IsCreditMemo) then begin
            if IsCreditMemo then
                exit;
            if ReturnReceiptHeader.Get(PostedDocNo) then
                if ReturnOrderAwaitsInvoice(ReturnReceiptHeader) then
                    Error(ReceivedRowDeleteErr, RowCaption(QueueRow), ReturnReceiptHeader."No.", SalesHeader.TableCaption(), ReturnReceiptHeader."Return Order No.");
        end;
        DeleteDraftDocument(QueueRow);
    end;

    local procedure DeleteDraftDocument(var QueueRow: Record "NPR Spfy NC Return Queue")
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        Settlement: Record "NPR Spfy Refund Settlement";
    begin
        if QueueRow."Sales Header Doc. No." <> '' then begin
            PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
            PaymentLine.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
            PaymentLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
            PaymentLine.DeleteAll(true);
            if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.") then
                SalesHeader.Delete(true);
        end;
        if Settlement.Get(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID") then
            Settlement.Delete();
        QueueRow."Sales Header Doc. No." := '';
        QueueRow."Location Fallback Used" := false;
        QueueRow."Not Restocked" := false;
        QueueRow.Modify();
    end;

    internal procedure OpenRelatedDocument(QueueRow: Record "NPR Spfy NC Return Queue")
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        PostedDocNotFoundErr: Label 'Posted document %1 could not be found as a %2 or a %3.', Comment = '%1 = document no., %2 = Sales Cr.Memo Header caption, %3 = Return Receipt Header caption';
        DraftDocNotFoundErr: Label '%1 %2 could not be found. It may have been deleted or posted outside the queue.', Comment = '%1 = Sales Header table caption, %2 = document no.';
        NoDocumentYetErr: Label 'No document has been created for this return or refund yet.';
    begin
        if QueueRow."Posted Doc. No." <> '' then begin
            if IsCreditMemoPosted(QueueRow) then begin
                SalesCrMemoHeader.Get(QueueRow."Posted Doc. No.");
                Page.Run(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
                exit;
            end;
            if ReturnReceiptHeader.Get(QueueRow."Posted Doc. No.") then begin
                Page.Run(Page::"Posted Return Receipt", ReturnReceiptHeader);
                exit;
            end;
            Error(PostedDocNotFoundErr, QueueRow."Posted Doc. No.", SalesCrMemoHeader.TableCaption(), ReturnReceiptHeader.TableCaption());
        end;
        if QueueRow."Sales Header Doc. No." <> '' then begin
            if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.") then begin
                Page.Run(Page::"Sales Return Order", SalesHeader);
                exit;
            end;
            Error(DraftDocNotFoundErr, SalesHeader.TableCaption(), QueueRow."Sales Header Doc. No.");
        end;
        Error(NoDocumentYetErr);
    end;

    /// <summary>
    /// Guards the manual actions while the Ecommerce feature handles returns.
    /// </summary>
    internal procedure ErrorIfEcommerceFeatureEnabled()
    var
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        EcommerceFeatureOwnsReturnsErr: Label 'The %1 feature is enabled, so returns and refunds are handled through e-commerce documents and this action is not available on the %2.', Comment = '%1 = feature description, %2 = Shopify Legacy Return Queue table caption';
    begin
        if not ShopifyEcommOrderExp.IsFeatureEnabled() then
            exit;
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Error(EcommerceFeatureOwnsReturnsErr, Feature.Description, QueueRow.TableCaption());
    end;

    /// <summary>
    /// Refuses a row another session set to Processing, unless that attempt is old enough to count as dead; the process job applies the same age.
    /// </summary>
    internal procedure ErrorIfBeingProcessed(QueueRow: Record "NPR Spfy NC Return Queue")
    var
        BeingProcessedErr: Label 'Shopify %1 is being processed by another session. Wait for it to finish before trying again.', Comment = '%1 = Shopify document caption';
    begin
        if IsBeingProcessed(QueueRow) then
            Error(BeingProcessedErr, RowCaption(QueueRow));
    end;

    /// <summary>
    /// True while another session holds the row: Processing and attempted within the stale limit.
    /// </summary>
    internal procedure IsBeingProcessed(QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    begin
        if QueueRow.Status <> QueueRow.Status::Processing then
            exit(false);
        exit(QueueRow."Processed At" >= StaleBefore(ProcessJobIntervalMinutes()));
    end;

    /// <summary>
    /// A Processing row attempted before this moment belongs to a session that died: twice the process job interval.
    /// </summary>
    internal procedure StaleBefore(IntervalMinutes: Integer): DateTime
    begin
        if IntervalMinutes <= 0 then
            IntervalMinutes := DefaultProcessJobIntervalMinutes();
        exit(CurrentDateTime() - (2 * IntervalMinutes * 60 * 1000));
    end;

    /// <summary>
    /// The interval the process job is registered with; the stale rule falls back to it while no job entry exists.
    /// </summary>
    internal procedure DefaultProcessJobIntervalMinutes(): Integer
    begin
        exit(5);
    end;

    local procedure ProcessJobIntervalMinutes(): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        if JobQueueEntry.FindFirst() then
            exit(JobQueueEntry."No. of Minutes between Runs");
        exit(0);
    end;

    /// <summary>
    /// True when the store exists and return import is not enabled for it. A missing store is left to the import, which reports it as a programming bug.
    /// </summary>
    internal procedure ReturnsSwitchedOff(ShopifyStoreCode: Code[20]): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if not ShopifyStore.Get(ShopifyStoreCode) then
            exit(false);
        exit(not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Returns", ShopifyStore));
    end;

    internal procedure ErrorIfReturnsSwitchedOff(ShopifyStoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
        ReturnsSwitchedOffErr: Label 'Return import is not enabled for %1 %2: the Shopify integration, the store or its %3 is switched off. Enable it to process this return or refund.', Comment = '%1 = Shopify Store table caption, %2 = store code, %3 = Sales Return Order Integration field caption';
    begin
        if ReturnsSwitchedOff(ShopifyStoreCode) then
            Error(ReturnsSwitchedOffErr, ShopifyStore.TableCaption(), ShopifyStoreCode, ShopifyStore.FieldCaption("Sales Return Order Integration"));
    end;

    internal procedure IsGiftCardRefundTxn(var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary): Boolean
    begin
        exit((TempRefundTxnBuffer."Gift Card Id" <> '') or (StrPos(UpperCase(TempRefundTxnBuffer.Gateway), 'GIFT') > 0));
    end;

    /// <summary>
    /// Shopify store credit is a customer liability like a gift card, but has no retail voucher behind it.
    /// </summary>
    internal procedure IsStoreCreditRefundTxn(var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary): Boolean
    begin
        exit(StrPos(UpperCase(TempRefundTxnBuffer.Gateway), 'STORE_CREDIT') > 0);
    end;

    /// <summary>
    /// Reports the last error to Sentry when it is a programming bug, tagged with the store and the return; true when it reported.
    /// </summary>
    internal procedure ReportProgrammingBugToSentry(ShopifyStoreCode: Code[20]; ReturnId: Text[30]; TransactionName: Text; Operation: Text): Boolean
    var
        Sentry: Codeunit "NPR Sentry";
        SentryErrorHandling: Codeunit "NPR Sentry Error Handling";
    begin
        if not SentryErrorHandling.IsLastErrorAProgrammingBug() then
            exit(false);
        Sentry.InitScopeAndTransaction(TransactionName, Operation);
        Sentry.AddTransactionTag('shopify.store_code', ShopifyStoreCode);
        if ReturnId <> '' then
            Sentry.AddTransactionTag('shopify.return_id', ReturnId);
        Sentry.AddLastErrorIfProgrammingBug();
        Sentry.FinalizeScope();
        exit(true);
    end;
}
