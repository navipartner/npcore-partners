codeunit 6014464 "NPR E-mail Doc. Mgt."
{
    var
        EmailMgt: Codeunit "NPR E-mail Management";
        EMailSalesReceiptLbl: Label 'E-mail Sales Receipt';

    internal procedure RunEmailLog(RecVariant: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVariant);
        EmailMgt.RunEmailLog(RecRef);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendReport(RecVariant: Variant; Silent: Boolean; var OverruleMail: Boolean)
    begin
    end;

    procedure SendReport(RecVariant: Variant; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportSent: Boolean;
        OverruleMail: Boolean;
    begin
        OnBeforeSendReport(RecVariant, Silent, OverruleMail);
        if OverruleMail then
            exit;

        ReportSent := false;
        SendReportEvent(RecVariant, Silent, ReportSent);
        if ReportSent then
            exit;

        RecRef.GetTable(RecVariant);
        case RecRef.Number of
            Database::Customer:
                SendReportCustomerStatement(RecVariant);
            Database::"Issued Fin. Charge Memo Header":
                SendReportIssuedFinChrgMemoHdr(RecVariant, Silent);
            Database::"Issued Reminder Header":
                SendReportIssuedReminderHdr(RecVariant, Silent);
            Database::"Purch. Cr. Memo Hdr.":
                SendReportPurchCrMemoHdr(RecVariant, Silent);
            Database::"Purchase Header":
                SendReportPurchHdr(RecVariant, Silent);
            Database::"Purch. Inv. Header":
                SendReportPurchInvHdr(RecVariant, Silent);
            Database::"Purch. Rcpt. Header":
                SendReportPurchRcptHdr(RecVariant, Silent);
            Database::"Sales Cr.Memo Header":
                SendReportSalesCrMemoHdr(RecVariant, Silent);
            Database::"Sales Header":
                SendReportSalesHdr(RecVariant, Silent);
            Database::"Sales Invoice Header":
                SendReportSalesInvHdr(RecVariant, Silent);
            Database::"Sales Shipment Header":
                SendReportSalesShptHdr(RecVariant, Silent);
            Database::"Service Invoice Header":
                SendReportServHdr(RecVariant, Silent);
            Database::"Service Header":
                SendReportServInvHdr(RecVariant, Silent);
            Database::"Service Shipment Header":
                SendReportServShptHdr(RecVariant, Silent);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure SendReportEvent(RecVariant: Variant; Silent: Boolean; var ReportSent: Boolean)
    begin
    end;

    local procedure SendReportIssuedFinChrgMemoHdr(var IssuedFinChrgMemoHeader: Record "Issued Fin. Charge Memo Header"; Silent: Boolean)
    var
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(IssuedFinChrgMemoHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        Clear(Customer);
        if Customer.Get(IssuedFinChrgMemoHeader."Customer No.") then;
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportIssuedReminderHdr(var IssuedReminderHeader: Record "Issued Reminder Header"; Silent: Boolean)
    var
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(IssuedReminderHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        Clear(Customer);
        if Customer.Get(IssuedReminderHeader."Customer No.") then;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportPurchCrMemoHdr(var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(PurchCrMemoHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportPurchHdr(var PurchHeader: Record "Purchase Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(PurchHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportPurchInvHdr(var PurchInvHeader: Record "Purch. Inv. Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(PurchInvHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportPurchRcptHdr(var PurchRcptHeader: Record "Purch. Rcpt. Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(PurchRcptHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportSalesCrMemoHdr(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(SalesCrMemoHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportSalesHdr(var SalesHeader: Record "Sales Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(SalesHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportSalesInvHdr(var SalesInvHeader: Record "Sales Invoice Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(SalesInvHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportSalesShptHdr(var SalesShptHeader: Record "Sales Shipment Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(SalesShptHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportServHdr(var ServHeader: Record "Service Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(ServHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportServInvHdr(var ServInvHeader: Record "Service Invoice Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(ServInvHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportServShptHdr(var ServShptHeader: Record "Service Shipment Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        RecRef.GetTable(ServShptHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
    end;

    local procedure SendReportCustomerStatement(var Customer: Record Customer)
    var
        Customer2: Record Customer;
    begin
        Customer2.Copy(Customer);
        Customer2.SetRecFilter();
        Report.RunModal(Report::"NPR Statement E-Mail", false, false, Customer2);
    end;

    internal procedure "TemplateType.SalesQuote"(): Integer
    begin
        exit(0);
    end;

    internal procedure "TemplateType.SalesOrder"(): Integer
    begin
        exit(1);
    end;

    internal procedure "TemplateType.SalesShpt"(): Integer
    begin
        exit(2);
    end;

    internal procedure "TemplateType.SalesInv"(): Integer
    begin
        exit(3);
    end;

    internal procedure "TemplateType.SalesCrMemo"(): Integer
    begin
        exit(4);
    end;

    internal procedure "TemplateType.PurchQuote"(): Integer
    begin
        exit(5);
    end;

    internal procedure "TemplateType.PurchOrder"(): Integer
    begin
        exit(6);
    end;

    internal procedure "TemplateType.PurchRcpt"(): Integer
    begin
        exit(7);
    end;

    internal procedure "TemplateType.PurchInv"(): Integer
    begin
        exit(8);
    end;

    internal procedure "TemplateType.PurchCrMemo"(): Integer
    begin
        exit(9);
    end;

    internal procedure "TemplateType.Reminder"(): Integer
    begin
        exit(10);
    end;

    internal procedure "TemplateType.ChargeMemo"(): Integer
    begin
        exit(11);
    end;

    internal procedure "TemplateType.Statement"(): Integer
    begin
        exit(12);
    end;

    internal procedure "TemplateType.ServQuote"(): Integer
    begin
        exit(13);
    end;

    internal procedure "TemplateType.ServOrder"(): Integer
    begin
        exit(14);
    end;

    internal procedure "TemplateType.ServShpt"(): Integer
    begin
        exit(15);
    end;

    internal procedure "TemplateType.ServInv"(): Integer
    begin
        exit(16);
    end;

    internal procedure "TemplateType.POSEntry"(): Integer
    begin
        exit(17);
    end;

    internal procedure "TemplateType.CreditVoucher"(): Integer
    begin
        exit(18);
    end;

    internal procedure "TemplateType.GiftVoucher"(): Integer
    begin
        exit(19);
    end;

    internal procedure GetMailReceipients(RecRef: RecordRef; ReportID: Integer): Text[250]
    var
        MailReceipients: Text[250];
    begin
        MailReceipients := CopyStr(EmailMgt.GetCustomReportEmailAddress(), 1, MaxStrLen(MailReceipients));

        if MailReceipients = '' then
            MailReceipients := CopyStr(EmailMgt.GetEmailAddressFromRecRef(RecRef), 1, MaxStrLen(MailReceipients));
        exit(MailReceipients);
    end;

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'EmailReceiptOnSale' then
            exit;

        Rec.Description := EMailSalesReceiptLbl;
        Rec."Sequence No." := 70;
    end;

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR E-mail Doc. Mgt.");
    end;

    procedure SendEmailReceiptOnSale(SalePOS: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
    begin
        If not POSUnit.Get(SalePOS."Register No.") then
            exit;

        if not POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then
            exit;

        if not POSReceiptProfile."E-mail Receipt On Sale" then
            exit;

        SendEmailReceipt(SalePOS);
    end;

    local procedure SendEmailReceipt(var SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        EmailManagement: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.SetFilter("Entry Type", '%1|%2|%3', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::Other);
        if not POSEntry.FindFirst() then
            exit;

        RecRef.GetTable(POSEntry);
        if EmailManagement.GetEmailAddressFromRecRef(RecRef) = '' then
            exit;

        SendReport(POSEntry, true);
    end;
}

