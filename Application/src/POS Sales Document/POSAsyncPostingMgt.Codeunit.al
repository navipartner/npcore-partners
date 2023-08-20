codeunit 6151380 "NPR POS Async. Posting Mgt."
{
    Access = Internal;

    internal procedure HandlePosting(SalesHeader: Record "Sales Header"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        Confirmation: Label '%1 %2 has been scheduled for posting.', Comment = '%1=document type, %2=number, e.g. Order 123  or Invoice 234.';
    begin
        case true of
            SaleLinePOS."Sales Document Prepayment":
                AsyncPostPrepaymentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);

            SaleLinePOS."Sales Document Ship",
                   SaleLinePOS."Sales Document Receive",
                   SaleLinePOS."Sales Document Invoice":
                AsyncPostDocumentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);
        end;
        if GuiAllowed then
            Message(Confirmation, SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.");
    end;

    local procedure AsyncPostPrepaymentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
    begin
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);

        if SaleLinePOS."Sales Doc. Prepay Is Percent" then
            POSPrepaymentMgt.SetPrepaymentPercentageToPay(SalesHeader, SaleLinePOS."Sales Doc. Prepayment Value")
        else
            POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, SaleLinePOS."Sales Doc. Prepayment Value");
    end;

    internal procedure ReadyToBePosted(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(SalesHeader.Ship or SalesHeader.Invoice or SalesHeader.Receive);
    end;

    internal procedure GetInvoiceType(POSSaleLine: Record "NPR POS Sale Line"): Enum "NPR Post Sales Posting Type"
    begin
        case true of
            POSSaleLine."Sales Document Prepayment":
                exit(Enum::"NPR Post Sales Posting Type"::Prepayment);
            POSSaleLine."Sales Document Prepay. Refund":
                exit(Enum::"NPR Post Sales Posting Type"::"Prepayment Refund");
            POSSaleLine."Sales Document Ship",
            POSSaleLine."Sales Document Receive",
            POSSaleLine."Sales Document Invoice":
                exit(Enum::"NPR Post Sales Posting Type"::Order);
            else
                exit(Enum::"NPR Post Sales Posting Type"::" ");
        end;
    end;

    local procedure AsyncPostDocumentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SalesHeader.Ship := SaleLinePOS."Sales Document Ship";
        SalesHeader.Invoice := SaleLinePOS."Sales Document Invoice";
        SalesHeader.Receive := SaleLinePOS."Sales Document Receive";
        SalesHeader.Modify(true);
    end;

    internal procedure CreateNotificationOnOpenPage(SalesHeader: Record "Sales Header")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryUnpostedLbl: label 'This document is created from POS and it is scheduled for posting. Changes can cause error in NPR Post Sales Documents JQ.\ Do you want to open a Card of related POS Entry?';
    begin
        if not MandatoryFieldsCheck(SalesHeader) then
            exit;
        FilterPOSEntry(POSEntry, SalesHeader);
        If GuiAllowed then
            if Confirm(POSEntryUnpostedLbl, true) then
                OpenPOSEntryPage(POSEntry)
            else
                CreateNotification();
    end;

    internal procedure FromPOSRelatedPOSTransExist(SalesHeader: Record "Sales Header")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryUnpostedLbl: label 'This document is created from POS and it is scheduled for posting. Changes can cause error in NPR Post Sales Documents JQ.\ Do you want to open a POS Entry card and post it manually?';
    begin
        if not MandatoryFieldsCheck(SalesHeader) then
            exit;
        FilterPOSEntry(POSEntry, SalesHeader);
        If GuiAllowed then
            if Confirm(POSEntryUnpostedLbl, true) then
                OpenPOSEntryPage(POSEntry);
    end;

    internal procedure CheckPostingStatusFromPOS(SalesHeader: Record "Sales Header")
    var
        POSEntry: Record "NPR POS Entry";
        ScheduledErr: Label 'Related transaction hasn''t been posted. Please go to POS Entry No.: %1 and post it.', Comment = '%1=POS Entry No.';
    begin
        if not MandatoryFieldsCheck(SalesHeader) then
            exit;
        FilterPOSEntry(POSEntry, SalesHeader);
        if POSEntry.FindFirst() then
            Error(ScheduledErr, POSEntry."Entry No.");
    end;

    local procedure MandatoryFieldsCheck(SalesHeader: Record "Sales Header"): Boolean
    begin
        if SalesHeader."No." = '' then
            exit;
        SalesHeader.CalcFields("NPR POS Trans. Sch. For Post");
        if not SalesHeader."NPR POS Trans. Sch. For Post" then
            exit;

        exit(true);
    end;

    internal procedure ScheduledTransFromPOSOnDrillDown(SalesHeader: Record "Sales Header")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        SalesHeader.CalcFields("NPR POS Trans. Sch. For Post");
        if not SalesHeader."NPR POS Trans. Sch. For Post" then
            exit;
        FilterPOSEntry(POSEntry, SalesHeader);
        OpenPOSEntryPage(POSEntry);
    end;

    local procedure OpenPOSEntryPage(var POSEntry: Record "NPR POS Entry")
    var
        POSEntryCard: Page "NPR POS Entry Card";
    begin
        POSEntryCard.LookupMode(true);
        POSEntryCard.SetTableView(POSEntry);
        POSEntryCard.RunModal();
    end;

    local procedure FilterPOSEntry(var POSEntry: Record "NPR POS Entry"; SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.SetCurrentKey("Orig. Sales Document No.", "Post Sales Document Status");
        POSEntrySalesDocLink.SetRange("Orig. Sales Document No.", SalesHeader."No.");
        POSEntrySalesDocLink.SetRange("Orig. Sales Document Type", SalesHeader."Document Type");
        POSEntrySalesDocLink.SetFilter("Post Sales Document Status", '%1|%2', POSEntry."Post Sales Document Status"::"Error while Posting", POSEntry."Post Sales Document Status"::Unposted);
        if POSEntrySalesDocLink.FindFirst() then
            POSEntry.SetRange("Entry No.", POSEntrySalesDocLink."POS Entry No.");
    end;

    internal procedure CreateNotification()
    var
        NotificationToSend: Notification;
        POSEntryUnpostedLbl: Label 'This document is created from POS and it is scheduled for posting. Changes can cause error in NPR Post Sales Documents JQ.';
        NotificationGuid: Label 'c75d47de-0d9f-47af-a16b-1ac331f6bce5', Locked = true;
    begin
        NotificationToSend.Id(NotificationGuid);
        If NotificationToSend.Recall() then;
        NotificationToSend.Message(POSEntryUnpostedLbl);
        NotificationToSend.Scope(NotificationScope::LocalScope);
        NotificationToSend.Send();
    end;

    internal procedure SetVisibility(): Boolean
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSPostingProfile.SetCurrentKey("Post POS Sale Doc. With JQ");
        POSPostingProfile.SetRange("Post POS Sale Doc. With JQ", true);
        exit(not POSPostingProfile.IsEmpty());
    end;

    internal procedure IsPostingScheduledFromPOS(SalesLine: Record "Sales Line"): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        If not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;
        SalesHeader.CalcFields("NPR POS Trans. Sch. For Post");
        exit(SalesHeader."NPR POS Trans. Sch. For Post");
    end;

    internal procedure CheckMandatoryLineFields(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Value of %1 can''t be changed before Posting POS Entry.', Comment = '%1 = SalesLine.Quantity,SalesLine.Unit Price,SalesLine.Amount';
    begin
        case True of
            Rec.Quantity <> xRec.Quantity:
                Error(ScheduledErr, Rec.FieldCaption(Quantity));
            Rec."Unit Price" <> xRec."Unit Price":
                Error(ScheduledErr, Rec.FieldCaption("Unit Price"));
            Rec."No." <> xRec."No.":
                Error(ScheduledErr, Rec.FieldCaption("No."));
            Rec."Variant Code" <> xRec."Variant Code":
                Error(ScheduledErr, Rec.FieldCaption("Variant Code"));
            Rec."Line Discount %" <> xRec."Line Discount %":
                Error(ScheduledErr, Rec.FieldCaption("Line Discount %"));
            Rec."Amount Including VAT" <> xRec."Amount Including VAT":
                Error(ScheduledErr, Rec.FieldCaption("Amount Including VAT"));
        end;
    end;

    internal procedure UnpostedPOSEntriesExistError(POSProfileProfile: Record "NPR POS Posting Profile")
    var
        POSStore: Record "NPR POS Store";
        POSEntry: Record "NPR POS Entry";
        POSEntriesExistErr: Label 'There are unposted entries in POS Entry table in POS Store %1. Please post then before updating %2.', Comment = '%1=POSStore.Code,%2=POSProfileProfile.FieldCaption("Async. POS Sale Doc. Posting")';
    begin
        //prevent disabling if exist on related stores
        POSStore.SetCurrentKey("POS Posting Profile");
        POSStore.SetRange("POS Posting Profile", POSProfileProfile.Code);
        if POSStore.FindSet() then
            repeat
                POSEntry.SetCurrentKey("POS Store Code", "Post Sales Document Status");
                POSEntry.SetRange("POS Store Code", POSStore.Code);
                POSEntry.SetRange("Post Sales Document Status", POSEntry."Post Sales Document Status"::Unposted);
                if not POSEntry.IsEmpty() then
                    Error(POSEntriesExistErr,
                        POSStore.Code, POSProfileProfile.FieldCaption("Post POS Sale Doc. With JQ"));
            until POSStore.Next() = 0;
    end;

    internal procedure UnpostedPOSEntriesExistConfirm(POSProfileProfile: Record "NPR POS Posting Profile"): Boolean
    var
        POSStore: Record "NPR POS Store";
        POSEntry: Record "NPR POS Entry";
        ConfirmMgt: Codeunit "Confirm Management";
        OperationAbortedLbl: Label 'Operation aborted by user.';
        POSEntriesExistLbl: Label 'There are entries in the POS Entry table whose posting failed. Do you want to continue?';
    begin
        POSStore.SetCurrentKey("POS Posting Profile");
        POSStore.SetRange("POS Posting Profile", POSProfileProfile.Code);
        if POSStore.FindSet() then
            repeat
                POSEntry.SetCurrentKey("POS Store Code", "Post Sales Document Status");
                POSEntry.SetRange("POS Store Code", POSStore.Code);
                POSEntry.SetRange("Post Sales Document Status", POSEntry."Post Sales Document Status"::"Error while Posting");
                if not POSEntry.IsEmpty() then begin
                    if ConfirmMgt.GetResponse(POSEntriesExistLbl, false) then
                        exit(true);
                    Error(OperationAbortedLbl);
                end;
            until POSStore.Next() = 0;

    end;

    internal procedure AsyncPostingEnabled(POSStoreCode: Code[20]): Boolean
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
    begin
        if not POSStore.Get(POSStoreCode) then
            exit;
        if POSStore.GetProfile(POSPostingProfile) then
            exit(POSPostingProfile."Post POS Sale Doc. With JQ");
    end;

    internal procedure GetPOSSalePostingMandatoryFlow(POSStoreCode: Code[10]): Enum "NPR POS Sales Document Post"
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
    begin
        POSStore.GetProfile(POSStoreCode, POSPostingProfile);
        if POSPostingProfile."Post POS Sale Doc. With JQ" then
            exit(Enum::"NPR POS Sales Document Post"::Asynchronous)
        else
            exit(Enum::"NPR POS Sales Document Post"::Synchronous);
    end;
    //Subscribers region
    //ORDER
    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesOrderLine(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    begin
        if IsPostingScheduledFromPOS(Rec) then
            CheckMandatoryLineFields(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesOrderLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertSalesOrderLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. New Line can''t be added before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenSalesOrder(Rec: Record "Sales Header")
    begin
        CreateNotificationOnOpenPage(Rec);
    end;
    //INVOICE
    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenSalesInvoice(Rec: Record "Sales Header")
    begin
        CreateNotificationOnOpenPage(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesInvoiceLine(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    begin
        if IsPostingScheduledFromPOS(Rec) then
            CheckMandatoryLineFields(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesInvoiceLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertSalesCrMemoLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. New Line can''t be added before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;
    //CREDIT MEMO
    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenSalesCrMemo(Rec: Record "Sales Header")
    begin
        CreateNotificationOnOpenPage(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertCrMemoLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. New Line can''t be added before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesCrMemoLine(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    begin
        if IsPostingScheduledFromPOS(Rec) then
            CheckMandatoryLineFields(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesCrMemoLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;
    //RETURN ORDER
    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenSalesReturnOrder(Rec: Record "Sales Header")
    begin
        CreateNotificationOnOpenPage(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertReturnOrderLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. New Line can''t be added before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesReturnOrderLine(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    begin
        if IsPostingScheduledFromPOS(Rec) then
            CheckMandatoryLineFields(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesReturnOrderLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
    begin
        if IsPostingScheduledFromPOS(Rec) then
            Error(ScheduledErr);
    end;
#IF NOT (BC17 or BC18)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeOnRun', '', false, false)]
    local procedure OnBeforeOnRun(var SalesHeader: Record "Sales Header");
    begin
        FromPOSRelatedPOSTransExist(SalesHeader);
    end;
#ELSE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', false, false)]
    local procedure OnBeforeConfirmSalesPost(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer; var PostAndSend: Boolean);
    begin
        FromPOSRelatedPOSTransExist(SalesHeader);
    end;
#ENDIF
}
