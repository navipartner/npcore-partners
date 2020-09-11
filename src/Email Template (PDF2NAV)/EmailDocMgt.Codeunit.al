codeunit 6014464 "NPR E-mail Doc. Mgt."
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - Document Specific E-mail Functions.
    // 
    //   Functions:
    //     --- Send E-mail: Functions for sending an e-mail with a reported (PDF) attachment.
    //     --- Run E-mail Log: Functions for opening associated E-mail Log List.
    // PN1.03/MH/20140814  NAV-AddOn: PDF2NAV
    //   - Added Service Module
    // PN1.04/MH/20140819  NAV-AddOn: PDF2NAV
    //   - Added Audit Roll
    //   - Added Credit Voucher
    //   - Added Gift Voucher
    // PN1.08/TTH/10122015 CASE 229069 Added Customer Statement Sending
    // PN1.08/MHA/20151214 CASE 228859 Pdf2Nav (New Version List), added template insert functions  and moved direct retail references to cu 6014474 "E-mail Retail Management"
    // PN1.10/MHA/20160308 Corrected Statement function to always run REPORT::"Statement E-Mail"
    // PN1.10/MHA/20160314 CASE 236653 Created universal pdf2nav functions and publishers for easier extension
    // NPR5.28/MMV /20161107 CASE 254575 Created event publisher OnBeforeSendReport() to allow for full overruling of PDF2NAV via external mail modules like NaviDocs.
    // NPR5.31/THRO/20170330 CASE 260773 Get Email address from Custom Report Selection
    // NPR5.39/MHA /20180202  CASE 302779 Added OnFinishSale POS Workflow
    // NPR5.43/THRO/20180615  CASE 316218 Customer Statement Report - run without requestpage


    trigger OnRun()
    begin
    end;

    var
        EmailMgt: Codeunit "NPR E-mail Management";
        Text001: Label 'Nothing to print';
        Text002: Label 'No sales from %1';
        Text100: Label 'Sales Quote';
        Text110: Label 'Sales Order';
        Text120: Label 'Sales Shipment';
        Text130: Label 'Sales Invoice';
        Text140: Label 'Sales Credit Memo';
        Text200: Label 'Purchase Quote';
        Text210: Label 'Purchase Order';
        Text220: Label 'Purchase Receipt';
        Text230: Label 'Purchase Invoice';
        Text240: Label 'Purchase Credit Memo';
        Text300: Label 'Reminder';
        Text310: Label 'Charge Memo';
        Text320: Label 'Statement';
        Text400: Label 'Sales Quote';
        Text410: Label 'Sales Order';
        Text420: Label 'Sales Shipment';
        Text430: Label 'Sales Invoice';
        Text500: Label 'Salesticket';
        Text510: Label 'Credit Voucher';
        Text520: Label 'Gift Voucher';
        Text600: Label 'E-mail Sales Receipt';

    procedure RunEmailLog(RecVariant: Variant)
    var
        RecRef: RecordRef;
    begin
        //-PN1.10
        RecRef.GetTable(RecVariant);
        EmailMgt.RunEmailLog(RecRef);
        //+PN1.10
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendReport(RecVariant: Variant; Silent: Boolean; var OverruleMail: Boolean)
    begin
        //-NPR5.28 [254575]
        //+NPR5.28 [254575]
    end;

    procedure SendReport(RecVariant: Variant; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportSent: Boolean;
        OverruleMail: Boolean;
    begin
        //-NPR5.28 [254575]
        OnBeforeSendReport(RecVariant, Silent, OverruleMail);
        if OverruleMail then
            exit;
        //+NPR5.28 [254575]

        //-PN1.10
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
        //+PN1.10
    end;

    [IntegrationEvent(false, false)]
    local procedure SendReportEvent(RecVariant: Variant; Silent: Boolean; var ReportSent: Boolean)
    begin
        //-PN1.10
        //+PN1.10
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
        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,Customer."E-Mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,Customer."E-Mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,PurchCrMemoHeader."Pay-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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
        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,PurchHeader."Pay-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,PurchInvHeader."Pay-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,PurchRcptHeader."Pay-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,SalesCrMemoHeader."Bill-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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
        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,SalesHeader."Bill-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,SalesInvHeader."Bill-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
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

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,SalesShptHeader."Bill-to E-mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
    end;

    local procedure SendReportServHdr(var ServHeader: Record "Service Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        //-PN1.03
        RecRef.GetTable(ServHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,ServHeader."E-Mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
        //+PN1.03
    end;

    local procedure SendReportServInvHdr(var ServInvHeader: Record "Service Invoice Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        //-PN1.03
        RecRef.GetTable(ServInvHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,ServInvHeader."E-Mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
        //+PN1.03
    end;

    local procedure SendReportServShptHdr(var ServShptHeader: Record "Service Shipment Header"; Silent: Boolean)
    var
        RecRef: RecordRef;
        ReportID: Integer;
    begin
        //-PN1.03
        RecRef.GetTable(ServShptHeader);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        //-NPR5.31 [260773]
        //EmailMgt.SendReport(ReportID,RecRef,ServShptHeader."E-Mail",Silent);
        EmailMgt.SendReport(ReportID, RecRef, GetMailReceipients(RecRef, ReportID), Silent);
        //+NPR5.31 [260773]
        //+PN1.03
    end;

    local procedure SendReportCustomerStatement(var Customer: Record Customer; Silent: Boolean)
    var
        Customer2: Record Customer;
    begin
        //-PN1.10
        ////-PN1.08
        //RecRef.GETTABLE(Customer);
        //IF NOT EmailMgt.ConfirmResendEmail(RecRef) THEN
        //  EXIT;
        //
        //ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        //IF ReportID = 0 THEN
        //  EXIT;
        //
        //EmailMgt.SendReport(ReportID,RecRef,Customer."E-Mail",Silent);
        ////+PN1.08
        Customer2.Copy(Customer);
        Customer2.SetRecFilter;
        //-NPR5.43 [316218]
        REPORT.RunModal(REPORT::"NPR Statement E-Mail", false, false, Customer2);
        //+NPR5.43 [316218]
        //+PN1.10
    end;

    local procedure "--- Create Template"()
    begin
    end;

    procedure CreateEmailTemplates() NewEmailTemplateCount: Integer
    var
        TempField: Record "Field" temporary;
        EmailRetailMgt: Codeunit "NPR E-mail Retail Mgt.";
        i: Integer;
    begin
        //-PN1.08
        NewEmailTemplateCount := 0;

        for i := "TemplateType.SalesQuote" to "TemplateType.GiftVoucher" do begin
            TempField.Init;
            TempField."No." := i;
            case i of
                "TemplateType.SalesQuote":
                    begin
                        TempField."Field Caption" := Text100;
                        TempField.Enabled := false;
                    end;
                "TemplateType.SalesOrder":
                    begin
                        TempField."Field Caption" := Text110;
                        TempField.Enabled := true;
                    end;
                "TemplateType.SalesShpt":
                    begin
                        TempField."Field Caption" := Text120;
                        TempField.Enabled := false;
                    end;
                "TemplateType.SalesInv":
                    begin
                        TempField."Field Caption" := Text130;
                        TempField.Enabled := true;
                    end;
                "TemplateType.SalesCrMemo":
                    begin
                        TempField."Field Caption" := Text140;
                        TempField.Enabled := true;
                    end;
                "TemplateType.PurchQuote":
                    begin
                        TempField."Field Caption" := Text200;
                        TempField.Enabled := false;
                    end;
                "TemplateType.PurchOrder":
                    begin
                        TempField."Field Caption" := Text210;
                        TempField.Enabled := true;
                    end;
                "TemplateType.PurchRcpt":
                    begin
                        TempField."Field Caption" := Text220;
                        TempField.Enabled := false;
                    end;
                "TemplateType.PurchInv":
                    begin
                        TempField."Field Caption" := Text230;
                        TempField.Enabled := false;
                    end;
                "TemplateType.PurchCrMemo":
                    begin
                        TempField."Field Caption" := Text240;
                        TempField.Enabled := false;
                    end;
                "TemplateType.Reminder":
                    begin
                        TempField."Field Caption" := Text300;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ChargeMemo":
                    begin
                        TempField."Field Caption" := Text310;
                        TempField.Enabled := false;
                    end;
                "TemplateType.Statement":
                    begin
                        TempField."Field Caption" := Text320;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServQuote":
                    begin
                        TempField."Field Caption" := Text400;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServOrder":
                    begin
                        TempField."Field Caption" := Text410;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServShpt":
                    begin
                        TempField."Field Caption" := Text420;
                        TempField.Enabled := false;
                    end;
                "TemplateType.ServInv":
                    begin
                        TempField."Field Caption" := Text430;
                        TempField.Enabled := false;
                    end;
                "TemplateType.AuditRoll":
                    begin
                        TempField."Field Caption" := Text500;
                        TempField.Enabled := false;
                    end;
                "TemplateType.CreditVoucher":
                    begin
                        TempField."Field Caption" := Text510;
                        TempField.Enabled := false;
                    end;
                "TemplateType.GiftVoucher":
                    begin
                        TempField."Field Caption" := Text520;
                        TempField.Enabled := false;
                    end;
            end;
            TempField.Insert;
        end;

        if not EmailRetailMgt.AuditRollExists() then begin
            TempField.Get(0, "TemplateType.AuditRoll");
            TempField.Delete;
        end;
        if not EmailRetailMgt.CreditVoucherExists() then begin
            TempField.Get(0, "TemplateType.CreditVoucher");
            TempField.Delete;
        end;
        if not EmailRetailMgt.GiftVoucherExists() then begin
            TempField.Get(0, "TemplateType.GiftVoucher");
            TempField.Delete;
        end;

        if PAGE.RunModal(PAGE::"NPR E-mail Templ. Choice List", TempField) <> ACTION::LookupOK then
            exit(0);

        TempField.SetRange(Enabled, true);
        if TempField.FindSet then
            repeat
                if CreateEmailTemplate(TempField."No.") <> '' then
                    NewEmailTemplateCount += 1;
            until TempField.Next = 0;
        exit(NewEmailTemplateCount);
        //+PN1.08
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
    //i: Integer;
    begin
        //-PN1.08
        EmailSetup.Get;

        EmailTemplate.Init;
        case TemplateType of
            "TemplateType.SalesQuote":
                begin
                    NewTemplateCode := UpperCase(Text100);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text100;
                    EmailTemplate.Subject := Text100 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Header";
                    EmailTemplate.Filename := Text100 + '-{3}.pdf';
                end;
            "TemplateType.SalesOrder":
                begin
                    NewTemplateCode := UpperCase(Text110);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text110;
                    EmailTemplate.Subject := Text110 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Header";
                    EmailTemplate.Filename := Text110 + '-{3}.pdf';
                end;
            "TemplateType.SalesShpt":
                begin
                    NewTemplateCode := UpperCase(Text120);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text120;
                    EmailTemplate.Subject := Text120 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Shipment Header";
                    EmailTemplate.Filename := Text120 + '-{3}.pdf';
                end;
            "TemplateType.SalesInv":
                begin
                    NewTemplateCode := UpperCase(Text130);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text130;
                    EmailTemplate.Subject := Text130 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Invoice Header";
                    EmailTemplate.Filename := Text130 + '-{3}.pdf';
                end;
            "TemplateType.SalesCrMemo":
                begin
                    NewTemplateCode := UpperCase(Text140);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text140;
                    EmailTemplate.Subject := Text140 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Sales Cr.Memo Header";
                    EmailTemplate.Filename := Text140 + '-{3}.pdf';
                end;
            "TemplateType.PurchQuote":
                begin
                    NewTemplateCode := UpperCase(Text200);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text200;
                    EmailTemplate.Subject := Text200 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purchase Header";
                    EmailTemplate.Filename := Text200 + '-{3}.pdf';
                end;
            "TemplateType.PurchOrder":
                begin
                    NewTemplateCode := UpperCase(Text210);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text210;
                    EmailTemplate.Subject := Text210 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purchase Header";
                    EmailTemplate.Filename := Text210 + '-{3}.pdf';
                end;
            "TemplateType.PurchRcpt":
                begin
                    NewTemplateCode := UpperCase(Text220);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text220;
                    EmailTemplate.Subject := Text220 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purch. Rcpt. Header";
                    EmailTemplate.Filename := Text220 + '-{3}.pdf';
                end;
            "TemplateType.PurchInv":
                begin
                    NewTemplateCode := UpperCase(Text230);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text230;
                    EmailTemplate.Subject := Text230 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purch. Inv. Header";
                    EmailTemplate.Filename := Text230 + '-{3}.pdf';
                end;
            "TemplateType.PurchCrMemo":
                begin
                    NewTemplateCode := UpperCase(Text240);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text240;
                    EmailTemplate.Subject := Text240 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Purch. Cr. Memo Hdr.";
                    EmailTemplate.Filename := Text240 + '-{3}.pdf';
                end;
            "TemplateType.Reminder":
                begin
                    NewTemplateCode := UpperCase(Text300);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text300;
                    EmailTemplate.Subject := Text300 + ' {1}';
                    EmailTemplate."Table No." := DATABASE::"Issued Reminder Header";
                    EmailTemplate.Filename := Text300 + '-{1}.pdf';
                end;
            "TemplateType.ChargeMemo":
                begin
                    NewTemplateCode := UpperCase(Text310);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text310;
                    EmailTemplate.Subject := Text310 + ' {1}';
                    EmailTemplate."Table No." := DATABASE::"Issued Fin. Charge Memo Header";
                    EmailTemplate.Filename := Text310 + '-{1}.pdf';
                end;
            "TemplateType.Statement":
                begin
                    NewTemplateCode := UpperCase(Text320);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text320;
                    EmailTemplate.Subject := Text320 + ' {1}';
                    EmailTemplate."Table No." := DATABASE::Customer;
                    EmailTemplate.Filename := Text320 + '-{1}.pdf';
                end;
            "TemplateType.ServQuote":
                begin
                    NewTemplateCode := UpperCase(Text400);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text400;
                    EmailTemplate.Subject := Text400 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Header";
                    EmailTemplate.Filename := Text400 + '-{3}.pdf';
                end;
            "TemplateType.ServOrder":
                begin
                    NewTemplateCode := UpperCase(Text410);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text410;
                    EmailTemplate.Subject := Text410 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Header";
                    EmailTemplate.Filename := Text410 + '-{3}.pdf';
                end;
            "TemplateType.ServShpt":
                begin
                    NewTemplateCode := UpperCase(Text420);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text420;
                    EmailTemplate.Subject := Text420 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Shipment Header";
                    EmailTemplate.Filename := Text420 + '-{3}.pdf';
                end;
            "TemplateType.ServInv":
                begin
                    NewTemplateCode := UpperCase(Text430);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text430;
                    EmailTemplate.Subject := Text430 + ' {3}';
                    EmailTemplate."Table No." := DATABASE::"Service Invoice Header";
                    EmailTemplate.Filename := Text430 + '-{3}.pdf';
                end;
            "TemplateType.AuditRoll":
                begin
                    if not EmailRetailMgt.AuditRollExists() then
                        exit('');
                    NewTemplateCode := UpperCase(Text500);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text500;
                    EmailTemplate.Subject := Text500 + ' {1}';
                    EmailTemplate."Table No." := EmailRetailMgt.AuditRollTableId();
                    EmailTemplate.Filename := Text500 + '-{1}.pdf';
                end;
            "TemplateType.CreditVoucher":
                begin
                    if not EmailRetailMgt.CreditVoucherExists() then
                        exit('');
                    NewTemplateCode := UpperCase(Text510);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text510;
                    EmailTemplate.Subject := Text510 + ' {1}';
                    EmailTemplate."Table No." := EmailRetailMgt.CreditVoucherTableId();
                    EmailTemplate.Filename := Text510 + '-{1}.pdf';
                end;
            "TemplateType.GiftVoucher":
                begin
                    if not EmailRetailMgt.GiftVoucherExists() then
                        exit('');
                    NewTemplateCode := UpperCase(Text520);
                    NewTemplateCode := GetNewTemplateCode(NewTemplateCode);
                    EmailTemplate.Code := NewTemplateCode;
                    EmailTemplate.Description := Text520;
                    EmailTemplate.Subject := Text520 + ' {1}';
                    EmailTemplate."Table No." := EmailRetailMgt.GiftVoucherTableId();
                    EmailTemplate.Filename := Text520 + '-{1}.pdf';
                end;
        end;

        EmailTemplate."Use HTML Template" := false;
        EmailTemplate."Verify Recipient" := true;
        EmailTemplate."Sender as bcc" := true;
        EmailTemplate."From E-mail Address" := EmailSetup."From E-mail Address";
        EmailTemplate."From E-mail Name" := EmailSetup."From Name";
        EmailTemplate.Insert(true);

        case TemplateType of
            "TemplateType.SalesQuote":
                begin
                    EmailTemplateFilter.Init;
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Sales Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := SalesHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(SalesHeader."Document Type"::Quote.AsInteger());
                    EmailTemplateFilter.Insert;
                end;
            "TemplateType.SalesOrder":
                begin
                    EmailTemplateFilter.Init;
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Sales Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := SalesHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(SalesHeader."Document Type"::Order.AsInteger());
                    EmailTemplateFilter.Insert;
                end;
            "TemplateType.PurchQuote":
                begin
                    EmailTemplateFilter.Init;
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Purchase Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := PurchHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(PurchHeader."Document Type"::Quote.AsInteger());
                    EmailTemplateFilter.Insert;
                end;
            "TemplateType.PurchOrder":
                begin
                    EmailTemplateFilter.Init;
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Purchase Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := PurchHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(PurchHeader."Document Type"::Order.AsInteger());
                    EmailTemplateFilter.Insert;
                end;
            "TemplateType.ServQuote":
                begin
                    EmailTemplateFilter.Init;
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Service Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := ServHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(ServHeader."Document Type"::Quote.AsInteger());
                    EmailTemplateFilter.Insert;
                end;
            "TemplateType.ServOrder":
                begin
                    EmailTemplateFilter.Init;
                    EmailTemplateFilter."E-mail Template Code" := EmailTemplate.Code;
                    EmailTemplateFilter."Table No." := DATABASE::"Service Header";
                    EmailTemplateFilter."Line No." := 10000;
                    EmailTemplateFilter."Field No." := ServHeader.FieldNo("Document Type");
                    EmailTemplateFilter.Value := Format(ServHeader."Document Type"::Order.AsInteger());
                    EmailTemplateFilter.Insert;
                end;
        end;

        exit(EmailTemplate.Code);
    end;

    procedure "--- Enum"()
    begin
    end;

    procedure "TemplateType.SalesQuote"(): Integer
    begin
        //-PN1.08
        exit(0);
        //+PN1.08
    end;

    procedure "TemplateType.SalesOrder"(): Integer
    begin
        //-PN1.08
        exit(1);
        //+PN1.08
    end;

    procedure "TemplateType.SalesShpt"(): Integer
    begin
        //-PN1.08
        exit(2);
        //+PN1.08
    end;

    procedure "TemplateType.SalesInv"(): Integer
    begin
        //-PN1.08
        exit(3);
        //+PN1.08
    end;

    procedure "TemplateType.SalesCrMemo"(): Integer
    begin
        //-PN1.08
        exit(4);
        //+PN1.08
    end;

    procedure "TemplateType.PurchQuote"(): Integer
    begin
        //-PN1.08
        exit(5);
        //+PN1.08
    end;

    procedure "TemplateType.PurchOrder"(): Integer
    begin
        //-PN1.08
        exit(6);
        //+PN1.08
    end;

    procedure "TemplateType.PurchRcpt"(): Integer
    begin
        //-PN1.08
        exit(7);
        //+PN1.08
    end;

    procedure "TemplateType.PurchInv"(): Integer
    begin
        //-PN1.08
        exit(8);
        //+PN1.08
    end;

    procedure "TemplateType.PurchCrMemo"(): Integer
    begin
        //-PN1.08
        exit(9);
        //+PN1.08
    end;

    procedure "TemplateType.Reminder"(): Integer
    begin
        //-PN1.08
        exit(10);
        //+PN1.08
    end;

    procedure "TemplateType.ChargeMemo"(): Integer
    begin
        //-PN1.08
        exit(11);
        //+PN1.08
    end;

    procedure "TemplateType.Statement"(): Integer
    begin
        //-PN1.08
        exit(12);
        //+PN1.08
    end;

    procedure "TemplateType.ServQuote"(): Integer
    begin
        //-PN1.08
        exit(13);
        //+PN1.08
    end;

    procedure "TemplateType.ServOrder"(): Integer
    begin
        //-PN1.08
        exit(14);
        //+PN1.08
    end;

    procedure "TemplateType.ServShpt"(): Integer
    begin
        //-PN1.08
        exit(15);
        //+PN1.08
    end;

    procedure "TemplateType.ServInv"(): Integer
    begin
        //-PN1.08
        exit(16);
        //+PN1.08
    end;

    procedure "TemplateType.AuditRoll"(): Integer
    begin
        //-PN1.08
        exit(17);
        //+PN1.08
    end;

    procedure "TemplateType.CreditVoucher"(): Integer
    begin
        //-PN1.08
        exit(18);
        //+PN1.08
    end;

    procedure "TemplateType.GiftVoucher"(): Integer
    begin
        //-PN1.08
        exit(19);
        //+PN1.08
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure GetNewTemplateCode(var TemplateCode: Code[20]) NewTemplateCode: Code[20]
    var
        EmailTemplate: Record "NPR E-mail Template Header";
    begin
        //-PN1.08
        NewTemplateCode := TemplateCode;
        if not EmailTemplate.Get(NewTemplateCode) then
            exit(NewTemplateCode);

        NewTemplateCode := NewTemplateCode + '-2';

        while EmailTemplate.Get(NewTemplateCode) do
            NewTemplateCode := IncStr(NewTemplateCode);

        exit(NewTemplateCode);
        //+PN1.08
    end;

    procedure GetMailReceipients(RecRef: RecordRef; ReportID: Integer): Text
    var
        MailReceipients: Text;
    begin
        //-NPR5.31 [260773]
        MailReceipients := EmailMgt.GetCustomReportEmailAddress();

        if MailReceipients = '' then
            MailReceipients := EmailMgt.GetEmailAddressFromRecRef(RecRef);
        exit(MailReceipients);
        //+NPR5.31 [260773]
    end;

    local procedure "--- OnFinishSale Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        //-NPR5.39 [302779]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'EmailReceiptOnSale' then
            exit;

        Rec.Description := Text600;
        Rec."Sequence No." := 70;
        //+NPR5.39 [302779]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.39 [302779]
        exit(CODEUNIT::"NPR E-mail Doc. Mgt.");
        //+NPR5.39 [302779]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure EmailReceiptOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    var
        AuditRoll: Record "NPR Audit Roll";
        Register: Record "NPR Register";
        EmailManagement: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        //-NPR5.39 [302779]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EmailReceiptOnSale' then
            exit;

        if not Register.Get(SalePOS."Register No.") then
            exit;
        if (not SalePOS."Send Receipt Email") and (Register."Sales Ticket Email Output" <> Register."Sales Ticket Email Output"::Auto) then
            exit;
        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        AuditRoll.SetFilter("Customer No.", '<>%1', '');
        if not AuditRoll.FindFirst then
            exit;

        RecRef.GetTable(AuditRoll);
        if EmailManagement.GetEmailAddressFromRecRef(RecRef) = '' then
            exit;

        SendReport(AuditRoll, true);
        //+NPR5.39 [302779]
    end;
}

