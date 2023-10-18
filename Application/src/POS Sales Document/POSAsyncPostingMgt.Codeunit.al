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
    begin
        exit(AsyncPostingEnabled());
    end;

    internal procedure IsPostingScheduledFromPOS(SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"): Boolean
    begin
        If not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;
        SalesHeader.CalcFields("NPR POS Trans. Sch. For Post");
        exit(SalesHeader."NPR POS Trans. Sch. For Post");
    end;

    local procedure CheckIsModificationAllowed(var SalesHeader: Record "Sales Header"): Boolean
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.SetCurrentKey("Orig. Sales Document No.", "Orig. Sales Document Type", "Post Sales Invoice Type");
        POSEntrySalesDocLink.SetRange("Orig. Sales Document No.", SalesHeader."No.");
        POSEntrySalesDocLink.SetRange("Orig. Sales Document Type", SalesHeader."Document Type");
        POSEntrySalesDocLink.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::Unposted);
        exit(POSEntrySalesDocLink.IsEmpty());
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
            Rec."Qty. to Invoice" <> xRec."Qty. to Invoice":
                Error(ScheduledErr, Rec.FieldCaption("Qty. to Invoice"));
            Rec."Qty. to Ship" <> xRec."Qty. to Ship":
                Error(ScheduledErr, Rec.FieldCaption("Qty. to Ship"));
            Rec."Return Qty. to Receive" <> xRec."Return Qty. to Receive":
                Error(ScheduledErr, Rec.FieldCaption("Return Qty. to Receive"));
        end;
    end;

    internal procedure AsyncPostingEnabled(): Boolean
    var
        POSSalesDocumentSetup: Record "NPR POS Sales Document Setup";
    begin
        if not POSSalesDocumentSetup.Get() then
            exit(false);
        exit(POSSalesDocumentSetup."Post with Job Queue");
    end;

    internal procedure GetPOSSalePostingMandatoryFlow(): Enum "NPR POS Sales Document Post"
    begin
        if AsyncPostingEnabled() then
            exit(Enum::"NPR POS Sales Document Post"::Asynchronous)
        else
            exit(Enum::"NPR POS Sales Document Post"::Synchronous);
    end;

    internal procedure InsertPOSEntrySalesLineRelation(POSSaleLine: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; SalesLine: Record "Sales Line"; BufferPOSEntrySalesLine: Record "NPR POS Entry Sales Line")
    var
        POSEntrySLineRelation: Record "NPR POS Entry S.Line Relation";
    begin
        POSEntrySLineRelation.Init();
        POSEntrySLineRelation."POS Entry No." := POSEntry."Entry No.";
        POSEntrySLineRelation."Line No." := GetLastPOSEntrySaleLineRelationLineNo(POSEntry);
        POSEntrySLineRelation."POS Entry Reference Type" := POSEntrySLineRelation."POS Entry Reference Type"::SALESLINE;
        POSEntrySLineRelation."POS Entry Reference Line No." := POSSaleLine."Line No.";
        POSEntrySLineRelation."POS Entry Buff.Sales Line No." := BufferPOSEntrySalesLine."Line No.";
        InsertPOSEntrySLRelationFromSaleLine(POSEntrySLineRelation, SalesLine);
        POSEntrySLineRelation.Insert();
    end;

    internal procedure InsertPOSEntrySalesLineHeaderRelation(POSEntry: Record "NPR POS Entry"; SalesHeader: Record "Sales Header")
    var
        POSEntrySLineRelation: Record "NPR POS Entry S.Line Relation";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        SalesLine: Record "Sales Line";
    begin
        //relation 1:1
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        if not POSEntrySalesDocLink.FindFirst() then
            exit;
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        if SalesLine.FindSet() then
            repeat
                POSEntrySLineRelation.Init();
                POSEntrySLineRelation."POS Entry No." := POSEntry."Entry No.";
                POSEntrySLineRelation."Line No." := GetLastPOSEntrySaleLineRelationLineNo(POSEntry);
                POSEntrySLineRelation."POS Entry Reference Line No." := POSEntrySalesDocLink."POS Entry Reference Line No.";
                POSEntrySLineRelation."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::HEADER;
                POSEntrySLineRelation."POS Entry Buff.Sales Line No." := SalesLine."Line No.";
                InsertPOSEntrySLRelationFromSaleLine(POSEntrySLineRelation, SalesLine);
                POSEntrySLineRelation.Insert();
            until SalesLine.Next() = 0;
    end;

    local procedure InsertPOSEntrySLRelationFromSaleLine(var POSEntrySLineRelation: Record "NPR POS Entry S.Line Relation"; SalesLine: Record "Sales Line")
    begin
        POSEntrySLineRelation."Sale Line No." := SalesLine."Line No.";
        POSEntrySLineRelation."Sale Document No." := SalesLine."Document No.";
        POSEntrySLineRelation."Sale Document Type" := SalesLine."Document Type";
        POSEntrySLineRelation.Quantity := SalesLine.Quantity;
        POSEntrySLineRelation."No." := SalesLine."No.";
        POSEntrySLineRelation."Qty. to Ship" := SalesLine."Qty. to Ship";
        POSEntrySLineRelation."Qty. to Invoice" := SalesLine."Qty. to Invoice";
        POSEntrySLineRelation."Return Qty. to Receive" := SalesLine."Return Qty. to Receive";
        POSEntrySLineRelation.Description := SalesLine.Description;
    end;

    local procedure DisableControlAfterModification(SalesLine: Record "Sales Line")
    var
        POSEntrySLineRelation: Record "NPR POS Entry S.Line Relation";
    begin
        POSEntrySLineRelation.SetRange("Sale Document No.", SalesLine."Document No.");
        POSEntrySLineRelation.SetRange("Sale Document Type", SalesLine."Document Type");
        POSEntrySLineRelation.SetRange("Sale Line No.", SalesLine."Line No.");
        if POSEntrySLineRelation.FindFirst() then begin
            POSEntrySLineRelation.Enabled := false;
            POSEntrySLineRelation.Modify();
        end;
    end;

    local procedure GetLastPOSEntrySaleLineRelationLineNo(POSEntry: Record "NPR POS Entry"): Integer
    var
        POSEntrySLineRelation: Record "NPR POS Entry S.Line Relation";
    begin
        POSEntrySLineRelation.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntrySLineRelation.FindLast() then
            exit(POSEntrySLineRelation."Line No." + 10000)
        else
            exit(10000)
    end;
    //Subscribers region
    //ORDER
    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesOrderLine(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            if CheckIsModificationAllowed(SalesHeader) then //allow if status is Error
                DisableControlAfterModification(Rec)
            else
                CheckMandatoryLineFields(Rec, xRec)
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesOrderLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertSalesOrderLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. New Line can''t be added before Posting POS Entry.';
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
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
    var
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            if CheckIsModificationAllowed(SalesHeader) then //allow if status is Error
                DisableControlAfterModification(Rec)
            else
                CheckMandatoryLineFields(Rec, xRec)
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesInvoiceLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertSalesCrMemoLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. New Line can''t be added before Posting POS Entry.';
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
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
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesCrMemoLine(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            if CheckIsModificationAllowed(SalesHeader) then //allow if status is Error
                DisableControlAfterModification(Rec)
            else
                CheckMandatoryLineFields(Rec, xRec)
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesCrMemoLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
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
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesReturnOrderLine(Rec: Record "Sales Line"; xRec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            if CheckIsModificationAllowed(SalesHeader) then //allow if status is Error
                DisableControlAfterModification(Rec)
            else
                CheckMandatoryLineFields(Rec, xRec)
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesReturnOrderLine(Rec: Record "Sales Line")
    var
        ScheduledErr: Label 'This document is created from POS and it is scheduled for posting. Line can''t be deleted before Posting POS Entry.';
        SalesHeader: Record "Sales Header";
    begin
        if IsPostingScheduledFromPOS(Rec, SalesHeader) then
            Error(ScheduledErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterDeleteAfterPosting', '', false, false)]
    local procedure OnAfterDeleteAfterPosting(SalesHeader: Record "Sales Header"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; CommitIsSuppressed: Boolean);
    var
        POSEntrySLineRelation: Record "NPR POS Entry S.Line Relation";
    begin
        POSEntrySLineRelation.SetCurrentKey("Sale Document No.", "Sale Document Type");
        POSEntrySLineRelation.SetRange("Sale Document No.", SalesHeader."No.");
        POSEntrySLineRelation.SetRange("Sale Document Type", SalesHeader."Document Type");
        POSEntrySLineRelation.DeleteAll(true);
    end;
#IF NOT (BC17 or BC18)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeOnRun', '', false, false)]
    local procedure OnBeforeOnRun(var SalesHeader: Record "Sales Header");
    begin
        if not CheckIsModificationAllowed(SalesHeader) then//raise message if status is unposted
            FromPOSRelatedPOSTransExist(SalesHeader);
    end;
#ELSE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', false, false)]
    local procedure OnBeforeConfirmSalesPost(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer; var PostAndSend: Boolean);
    begin
         if not CheckIsModificationAllowed(SalesHeader) then    //raise message if status is unposted
            FromPOSRelatedPOSTransExist(SalesHeader);
    end;
#ENDIF
}
