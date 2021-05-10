codeunit 6014464 "NPR E-mail Doc. Mgt."
{
    var
        EmailMgt: Codeunit "NPR E-mail Management";
        SalesQuoteLbl: Label 'Sales Quote';
        SalesOrderLbl: Label 'Sales Order';
        SalesShipmentLbl: Label 'Sales Shipment';
        SalesInvoiceLbl: Label 'Sales Invoice';
        SalesCrMemoLbl: Label 'Sales Credit Memo';
        PurchaseQuoteLbl: Label 'Purchase Quote';
        PurchaseOrderLbl: Label 'Purchase Order';
        PurchaseReceiptLbl: Label 'Purchase Receipt';
        PurchaseInvoiceLbl: Label 'Purchase Invoice';
        PurchaseCrMemoLbl: Label 'Purchase Credit Memo';
        ReminderLbl: Label 'Reminder';
        ChargeMemolbl: Label 'Charge Memo';
        StatementLbl: Label 'Statement';
        ServiceQuoteLbl: Label 'Service Quote';
        ServiceOrderLbl: Label 'Service Order';
        ServiceShipmentLbl: Label 'Service Shipment';
        ServiceInvoiceLbl: Label 'Service Invoice';
        POSEntryLbl: Label 'Salesticket';
        EMailSalesReceiptLbl: Label 'E-mail Sales Receipt';

    procedure RunEmailLog(RecVariant: Variant)
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
            DATABASE::Customer:
                SendReportCustomerStatement(RecVariant, Silent);
            DATABASE::"Issued Fin. Charge Memo Header":
                SendReportIssuedFinChrgMemoHdr(RecVariant, Silent);
            DATABASE::"Issued Reminder Header":
                SendReportIssuedReminderHdr(RecVariant, Silent);
            DATABASE::"Purch. Cr. Memo Hdr.":
                SendReportPurchCrMemoHdr(RecVariant, Silent);
            DATABASE::"Purchase Header":
                SendReportPurchHdr(RecVariant, Silent);
            DATABASE::"Purch. Inv. Header":
                SendReportPurchInvHdr(RecVariant, Silent);
            DATABASE::"Purch. Rcpt. Header":
                SendReportPurchRcptHdr(RecVariant, Silent);
            DATABASE::"Sales Cr.Memo Header":
                SendReportSalesCrMemoHdr(RecVariant, Silent);
            DATABASE::"Sales Header":
                SendReportSalesHdr(RecVariant, Silent);
            DATABASE::"Sales Invoice Header":
                SendReportSalesInvHdr(RecVariant, Silent);
            DATABASE::"Sales Shipment Header":
                SendReportSalesShptHdr(RecVariant, Silent);
            DATABASE::"Service Invoice Header":
                SendReportServHdr(RecVariant, Silent);
            DATABASE::"Service Header":
                SendReportServInvHdr(RecVariant, Silent);
            DATABASE::"Service Shipment Header":
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

    local procedure SendReportCustomerStatement(var Customer: Record Customer; Silent: Boolean)
    var
        Customer2: Record Customer;
    begin
        Customer2.Copy(Customer);
        Customer2.SetRecFilter();
        REPORT.RunModal(REPORT::"NPR Statement E-Mail", false, false, Customer2);
    end;

    procedure CreateEmailTemplates() NewEmailTemplateCount: Integer
    var
        TempField: Record "Field" temporary;
        EmailRetailMgt: Codeunit "NPR E-mail Retail Mgt.";
        i: Integer;
    begin
        NewEmailTemplateCount := 0;

        for i := "TemplateType.SalesQuote"() to "TemplateType.GiftVoucher"() do begin
            TempField.Init();
            TempField."No." := i;
            case i of
                "TemplateType.SalesQuote"():
                    begin
                        TempField."Field Caption" := SalesQuoteLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.SalesOrder"():
                    begin
                        TempField."Field Caption" := SalesOrderLbl;
                        TempField.Enabled := true;
                    end;
                "TemplateType.SalesShpt"():
                    begin
                        TempField."Field Caption" := SalesShipmentLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.SalesInv"():
                    begin
                        TempField."Field Caption" := SalesInvoiceLbl;
                        TempField.Enabled := true;
                    end;
                "TemplateType.SalesCrMemo"():
                    begin
                        TempField."Field Caption" := SalesCrMemoLbl;
                        TempField.Enabled := true;
                    end;
                "TemplateType.PurchQuote"():
                    begin
                        TempField."Field Caption" := PurchaseQuoteLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.PurchOrder"():
                    begin
                        TempField."Field Caption" := PurchaseOrderLbl;
                        TempField.Enabled := true;
                    end;
                "TemplateType.PurchRcpt"():
                    begin
                        TempField."Field Caption" := PurchaseReceiptLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.PurchInv"():
                    begin
                        TempField."Field Caption" := PurchaseInvoiceLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.PurchCrMemo"():
                    begin
                        TempField."Field Caption" := PurchaseCrMemoLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.Reminder"():
                    begin
                        TempField."Field Caption" := ReminderLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ChargeMemo"():
                    begin
                        TempField."Field Caption" := ChargeMemolbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.Statement"():
                    begin
                        TempField."Field Caption" := StatementLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServQuote"():
                    begin
                        TempField."Field Caption" := ServiceQuoteLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServOrder"():
                    begin
                        TempField."Field Caption" := ServiceOrderLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServShpt"():
                    begin
                        TempField."Field Caption" := ServiceShipmentLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServInv"():
                    begin
                        TempField."Field Caption" := ServiceInvoiceLbl;
                        TempField.Enabled := false;
                    end;
                "TemplateType.POSEntry"():
                    begin
                        TempField."Field Caption" := POSEntryLbl;
                        TempField.Enabled := false;
                    end;
            end;
            TempField.Insert();
        end;

        if PAGE.RunModal(PAGE::"NPR E-mail Templ. Choice List", TempField) <> ACTION::LookupOK then
            exit(0);

        TempField.SetRange(Enabled, true);
        if TempField.FindSet() then
            repeat
                if CreateEmailTemplate(TempField."No.") <> '' then
                    NewEmailTemplateCount += 1;
            until TempField.Next() = 0;
        exit(NewEmailTemplateCount);
    end;

    procedure CreateEmailTemplate(TemplateType: Integer) NewEmailTemplateCode: Code[20]
    var
        EmailSetup: Record "NPR E-mail Setup";
        EmailTemplate: Record "NPR E-mail Template Header";
        EmailTemplateFilter: Record "NPR E-mail Template Filter";
        PurchHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        ServHeader: Record "Service Header";
        EmailRetailMgt: Codeunit "NPR E-mail Retail Mgt.";
        NewTemplateCode: Code[20];
    begin
        EmailSetup.Get();

        EmailTemplate.Init();
        case TemplateType of
            "TemplateType.SalesQuote"():
                begin
                    NewTemplateCode := UpperCase(SalesQuoteLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := SalesQuoteLbl;
                    EmailTemplate.Subject := SalesQuoteLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Header";
                    EmailTemplate.Filename := SalesQuoteLbl + '-{3}.pdf';
                end;
            "TemplateType.SalesOrder"():
                begin
                    NewTemplateCode := UpperCase(SalesOrderLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := SalesOrderLbl;
                    EmailTemplate.Subject := SalesOrderLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Header";
                    EmailTemplate.Filename := SalesOrderLbl + '-{3}.pdf';
                end;
            "TemplateType.SalesShpt"():
                begin
                    NewTemplateCode := UpperCase(SalesShipmentLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := SalesShipmentLbl;
                    EmailTemplate.Subject := SalesShipmentLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Shipment Header";
                    EmailTemplate.Filename := SalesShipmentLbl + '-{3}.pdf';
                end;
            "TemplateType.SalesInv"():
                begin
                    NewTemplateCode := UpperCase(SalesInvoiceLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := SalesInvoiceLbl;
                    EmailTemplate.Subject := SalesInvoiceLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Invoice Header";
                    EmailTemplate.Filename := SalesInvoiceLbl + '-{3}.pdf';
                end;
            "TemplateType.SalesCrMemo"():
                begin
                    NewTemplateCode := UpperCase(SalesCrMemoLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := SalesCrMemoLbl;
                    EmailTemplate.Subject := SalesCrMemoLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Cr.Memo Header";
                    EmailTemplate.Filename := SalesCrMemoLbl + '-{3}.pdf';
                end;
            "TemplateType.PurchQuote"():
                begin
                    NewTemplateCode := UpperCase(PurchaseQuoteLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := PurchaseQuoteLbl;
                    EmailTemplate.Subject := PurchaseQuoteLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purchase Header";
                    EmailTemplate.Filename := PurchaseQuoteLbl + '-{3}.pdf';
                end;
            "TemplateType.PurchOrder"():
                begin
                    NewTemplateCode := UpperCase(PurchaseOrderLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := PurchaseOrderLbl;
                    EmailTemplate.Subject := PurchaseOrderLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purchase Header";
                    EmailTemplate.Filename := PurchaseOrderLbl + '-{3}.pdf';
                end;
            "TemplateType.PurchRcpt"():
                begin
                    NewTemplateCode := UpperCase(PurchaseReceiptLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := PurchaseReceiptLbl;
                    EmailTemplate.Subject := PurchaseReceiptLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purch. Rcpt. Header";
                    EmailTemplate.Filename := PurchaseReceiptLbl + '-{3}.pdf';
                end;
            "TemplateType.PurchInv"():
                begin
                    NewTemplateCode := UpperCase(PurchaseInvoiceLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := PurchaseInvoiceLbl;
                    EmailTemplate.Subject := PurchaseInvoiceLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purch. Inv. Header";
                    EmailTemplate.Filename := PurchaseInvoiceLbl + '-{3}.pdf';
                end;
            "TemplateType.PurchCrMemo"():
                begin
                    NewTemplateCode := UpperCase(PurchaseCrMemoLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := PurchaseCrMemoLbl;
                    EmailTemplate.Subject := PurchaseCrMemoLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purch. Cr. Memo Hdr.";
                    EmailTemplate.Filename := PurchaseCrMemoLbl + '-{3}.pdf';
                end;
            "TemplateType.Reminder"():
                begin
                    NewTemplateCode := UpperCase(ReminderLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := ReminderLbl;
                    EmailTemplate.Subject := ReminderLbl + ' {1}';
                    EmailTemplate."Table No." := DATABASE::"Issued Reminder Header";
                    EmailTemplate.Filename := ReminderLbl + '-{1}.pdf';
                end;
            "TemplateType.ChargeMemo"():
                begin
                    NewTemplateCode := UpperCase(ChargeMemolbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := ChargeMemolbl;
                    EmailTemplate.Subject := ChargeMemolbl + ' {1}';
                    EmailTemplate."Table No." := DATABASE::"Issued Fin. Charge Memo Header";
                    EmailTemplate.Filename := ChargeMemolbl + '-{1}.pdf';
                end;
            "TemplateType.Statement"():
                begin
                    NewTemplateCode := UpperCase(StatementLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := StatementLbl;
                    EmailTemplate.Subject := StatementLbl + ' {1}';
                    EmailTemplate."Table No." := DATABASE::Customer;
                    EmailTemplate.Filename := StatementLbl + '-{1}.pdf';
                end;
            "TemplateType.ServQuote"():
                begin
                    NewTemplateCode := UpperCase(ServiceQuoteLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := ServiceQuoteLbl;
                    EmailTemplate.Subject := ServiceQuoteLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Header";
                    EmailTemplate.Filename := ServiceQuoteLbl + '-{3}.pdf';
                end;
            "TemplateType.ServOrder"():
                begin
                    NewTemplateCode := UpperCase(ServiceOrderLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := ServiceOrderLbl;
                    EmailTemplate.Subject := ServiceOrderLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Header";
                    EmailTemplate.Filename := ServiceOrderLbl + '-{3}.pdf';
                end;
            "TemplateType.ServShpt"():
                begin
                    NewTemplateCode := UpperCase(ServiceShipmentLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := ServiceShipmentLbl;
                    EmailTemplate.Subject := ServiceShipmentLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Shipment Header";
                    EmailTemplate.Filename := ServiceShipmentLbl + '-{3}.pdf';
                end;
            "TemplateType.ServInv"():
                begin
                    NewTemplateCode := UpperCase(ServiceInvoiceLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := ServiceInvoiceLbl;
                    EmailTemplate.Subject := ServiceInvoiceLbl + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Invoice Header";
                    EmailTemplate.Filename := ServiceInvoiceLbl + '-{3}.pdf';
                end;
            "TemplateType.POSEntry"():
                begin
                    NewTemplateCode := UpperCase(POSEntryLbl);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := POSEntryLbl;
                    EmailTemplate.Subject := POSEntryLbl + ' {1}';
                    EmailTemplate."Table No." := EmailRetailMgt.POSEntryTableId();
                    EmailTemplate.Filename := POSEntryLbl + '-{1}.pdf';
                end;
        end;

        EmailTemplate."Use HTML Template" := false;
        EmailTemplate."Verify Recipient" := true;
        EmailTemplate."Sender as bcc" := true;
        EmailTemplate."From E-mail Address" := EmailSetup."From E-mail Address";
        EmailTemplate."From E-mail Name" := EmailSetup."From Name";
        EmailTemplate.Insert(true);

        case TemplateType of
            "TemplateType.SalesQuote"():
                begin
                    EmailTemplateFilter.Init();
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Sales Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := SalesHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(SalesHeader."Document Type"::Quote.AsInteger());
                    EmailTemplateFilter.Insert();
                end;
            "TemplateType.SalesOrder"():
                begin
                    EmailTemplateFilter.Init();
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Sales Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := SalesHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(SalesHeader."Document Type"::Order.AsInteger());
                    EmailTemplateFilter.Insert();
                end;
            "TemplateType.PurchQuote"():
                begin
                    EmailTemplateFilter.Init();
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Purchase Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := PurchHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(PurchHeader."Document Type"::Quote.AsInteger());
                    EmailTemplateFilter.Insert();
                end;
            "TemplateType.PurchOrder"():
                begin
                    EmailTemplateFilter.Init();
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Purchase Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := PurchHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(PurchHeader."Document Type"::Order.AsInteger());
                    EmailTemplateFilter.Insert();
                end;
            "TemplateType.ServQuote"():
                begin
                    EmailTemplateFilter.Init();
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Service Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := ServHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(ServHeader."Document Type"::Quote.AsInteger());
                    EmailTemplateFilter.Insert();
                end;
            "TemplateType.ServOrder"():
                begin
                    EmailTemplateFilter.Init();
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Service Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := ServHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(ServHeader."Document Type"::Order.AsInteger());
                    EmailTemplateFilter.Insert();
                end;
        end;

        exit(EmailTemplate.Code);
    end;

    procedure "TemplateType.SalesQuote"(): Integer
    begin
        exit(0);
    end;

    procedure "TemplateType.SalesOrder"(): Integer
    begin
        exit(1);
    end;

    procedure "TemplateType.SalesShpt"(): Integer
    begin
        exit(2);
    end;

    procedure "TemplateType.SalesInv"(): Integer
    begin
        exit(3);
    end;

    procedure "TemplateType.SalesCrMemo"(): Integer
    begin
        exit(4);
    end;

    procedure "TemplateType.PurchQuote"(): Integer
    begin
        exit(5);
    end;

    procedure "TemplateType.PurchOrder"(): Integer
    begin
        exit(6);
    end;

    procedure "TemplateType.PurchRcpt"(): Integer
    begin
        exit(7);
    end;

    procedure "TemplateType.PurchInv"(): Integer
    begin
        exit(8);
    end;

    procedure "TemplateType.PurchCrMemo"(): Integer
    begin
        exit(9);
    end;

    procedure "TemplateType.Reminder"(): Integer
    begin
        exit(10);
    end;

    procedure "TemplateType.ChargeMemo"(): Integer
    begin
        exit(11);
    end;

    procedure "TemplateType.Statement"(): Integer
    begin
        exit(12);
    end;

    procedure "TemplateType.ServQuote"(): Integer
    begin
        exit(13);
    end;

    procedure "TemplateType.ServOrder"(): Integer
    begin
        exit(14);
    end;

    procedure "TemplateType.ServShpt"(): Integer
    begin
        exit(15);
    end;

    procedure "TemplateType.ServInv"(): Integer
    begin
        exit(16);
    end;

    procedure "TemplateType.POSEntry"(): Integer
    begin
        exit(17);
    end;

    procedure "TemplateType.CreditVoucher"(): Integer
    begin
        exit(18);
    end;

    procedure "TemplateType.GiftVoucher"(): Integer
    begin
        exit(19);
    end;

    local procedure GetNewTemplateCode(var TemplateCode: Code[20]) NewTemplateCode: Code[20]
    var
        EmailTemplate: Record "NPR E-mail Template Header";
    begin
        NewTemplateCode := TemplateCode;
        if not EmailTemplate.Get(NewTemplateCode) then
            exit(NewTemplateCode);

        NewTemplateCode := NewTemplateCode + '-2';

        while EmailTemplate.Get(NewTemplateCode) do
            NewTemplateCode := IncStr(NewTemplateCode);

        exit(NewTemplateCode);
    end;

    procedure GetMailReceipients(RecRef: RecordRef; ReportID: Integer): Text
    var
        MailReceipients: Text;
    begin
        MailReceipients := EmailMgt.GetCustomReportEmailAddress();

        if MailReceipients = '' then
            MailReceipients := EmailMgt.GetEmailAddressFromRecRef(RecRef);
        exit(MailReceipients);
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'EmailReceiptOnSale' then
            exit;

        Rec.Description := EMailSalesReceiptLbl;
        Rec."Sequence No." := 70;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR E-mail Doc. Mgt.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure EmailReceiptOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        EmailManagement: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        if not POSSalesWorkflowStep.Enabled then
            exit;
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EmailReceiptOnSale' then
            exit;

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

