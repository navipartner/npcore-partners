codeunit 6014463 "NPR Sales-Post and Pdf2Nav"
{
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        SalesHeader.Copy(Rec);
        Code;
        Rec := SalesHeader;
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnRcptHeader: Record "Return Receipt Header";
        ReportSelection: Record "Report Selections";
        Selection: Integer;
        Text000: Label '&Ship,&Invoice,Ship &and Invoice';
        Text001: Label 'Do you want to post and print/send the %1?';
        Text002: Label '&Receive,&Invoice,Receive &and Invoice';
        DownloadInvoiceAlsoQst: Label 'You can also download the Sales - Invoice document now. Alternatively, you can access it from the Posted Sales Invoices window later.\\Do you want to download the Sales - Invoice document now?';
        DownloadCrMemoAlsoQst: Label 'You can also download the Sales - Credit Memo document now. Alternatively, you can access it from the Posted Sales Credit Memos window later.\\Do you want to download the Sales - Credit Memo document now?';
        SkipPrintHandling: Boolean;
        Mode: Option Standard,PrepaymentInvoice,PrepaymentCreditMemo;

    local procedure "Code"()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        DocSendProfile: Record "Document Sending Profile";
        SalesPostViaJobQueue: Codeunit "Sales Post via Job Queue";
        SendReportAsEmail: Boolean;
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    Selection := StrMenu(Text000, 3);
                    if Selection = 0 then
                        exit;
                    SalesHeader.Ship := Selection in [1, 3];
                    SalesHeader.Invoice := Selection in [2, 3];
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    Selection := StrMenu(Text002, 3);
                    if Selection = 0 then
                        exit;
                    SalesHeader.Receive := Selection in [1, 3];
                    SalesHeader.Invoice := Selection in [2, 3];
                end
            else
                if not Confirm(ConfirmationMessage, false, SalesHeader."Document Type") then
                    exit;
        end;

        SalesHeader."Print Posted Documents" := true;

        DocSendProfile.GetDefaultForCustomer(SalesHeader."Bill-to Customer No.", DocSendProfile);
        SendReportAsEmail := DocSendProfile."E-Mail" <> DocSendProfile."E-Mail"::No;

        SalesSetup.Get();
        if SalesSetup."Post & Print with Job Queue" and not SendReportAsEmail then
            SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
        else begin
            CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader);
            Mode := Mode::Standard;
            GetReport(SalesHeader);
        end;
        Commit();
    end;

    procedure GetReport(var SalesHeader2: Record "Sales Header")
    var
        OrderPrinted: Boolean;
    begin
        Commit();

        SalesHeader.Copy(SalesHeader2);

        case Mode of
            Mode::PrepaymentInvoice:
                begin
                    SalesInvHeader."No." := SalesHeader."Last Prepayment No.";
                    SalesInvHeader.SetRecFilter();
                    HandleReport(ReportSelection.Usage::"S.Invoice");
                end;
            Mode::PrepaymentCreditMemo:
                begin
                    SalesCrMemoHeader."No." := SalesHeader."Last Prepmt. Cr. Memo No.";
                    SalesCrMemoHeader.SetRecFilter();
                    HandleReport(ReportSelection.Usage::"S.Cr.Memo");
                end;
            Mode::Standard:
                begin
                    case SalesHeader."Document Type" of
                        SalesHeader."Document Type"::Order:
                            begin
                                if SalesHeader.Ship then begin
                                    SalesShptHeader."No." := SalesHeader."Last Shipping No.";
                                    SalesShptHeader.SetRecFilter();
                                    OrderPrinted := HandleReport(ReportSelection.Usage::"S.Shipment");
                                end;
                                if IsPrintingBothDocumentsForNonWindowsClient(SalesHeader.Ship and SalesHeader.Invoice and OrderPrinted) then
                                    if not Confirm(DownloadInvoiceAlsoQst, true) then
                                        exit;
                                if SalesHeader.Invoice then begin
                                    SalesInvHeader."No." := SalesHeader."Last Posting No.";
                                    SalesInvHeader.SetRecFilter();
                                    HandleReport(ReportSelection.Usage::"S.Invoice");
                                end;
                            end;
                        SalesHeader."Document Type"::Invoice:
                            begin
                                if SalesHeader."Last Posting No." = '' then
                                    SalesInvHeader."No." := SalesHeader."No."
                                else
                                    SalesInvHeader."No." := SalesHeader."Last Posting No.";
                                SalesInvHeader.SetRecFilter();

                                HandleReport(ReportSelection.Usage::"S.Invoice");
                            end;
                        SalesHeader."Document Type"::"Return Order":
                            begin
                                if SalesHeader.Receive then begin
                                    ReturnRcptHeader."No." := SalesHeader."Last Return Receipt No.";
                                    ReturnRcptHeader.SetRecFilter();
                                    OrderPrinted := HandleReport(ReportSelection.Usage::"S.Ret.Rcpt.");
                                end;
                                if IsPrintingBothDocumentsForNonWindowsClient(SalesHeader.Ship and SalesHeader.Invoice and OrderPrinted) then
                                    if not Confirm(DownloadCrMemoAlsoQst, true) then
                                        exit;
                                if SalesHeader.Invoice then begin
                                    SalesCrMemoHeader."No." := SalesHeader."Last Posting No.";
                                    SalesCrMemoHeader.SetRecFilter();

                                    HandleReport(ReportSelection.Usage::"S.Cr.Memo");
                                end;
                            end;
                        SalesHeader."Document Type"::"Credit Memo":
                            begin
                                if SalesHeader."Last Posting No." = '' then
                                    SalesCrMemoHeader."No." := SalesHeader."No."
                                else
                                    SalesCrMemoHeader."No." := SalesHeader."Last Posting No.";
                                SalesCrMemoHeader.SetRecFilter();

                                HandleReport(ReportSelection.Usage::"S.Cr.Memo");
                            end;
                    end;
                end;
        end;
    end;

    local procedure ConfirmationMessage(): Text
    begin
        exit(Text001);
    end;

    local procedure IsPrintingBothDocumentsForNonWindowsClient(PrintBothDocuments: Boolean): Boolean
    begin
        exit(PrintBothDocuments and (CurrentClientType <> CLIENTTYPE::Windows));
    end;

    local procedure HandleReport(ReportUsage: Enum "Report Selection Usage") Printed: Boolean
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
        DocSendProfile: Record "Document Sending Profile";
        DoPrint: Boolean;
    begin
        DocSendProfile.Init();
        DocSendProfile.GetDefaultForCustomer(SalesHeader."Bill-to Customer No.", DocSendProfile);
        if DocSendProfile."E-Mail" <> DocSendProfile."E-Mail"::No then
            EmailReport(ReportUsage);
        if DocSendProfile.Printer <> DocSendProfile.Printer::No then
            DoPrint := true;

        if (not DoPrint) then begin
            if not SalesPostandPdf2NavSetup.Get() then
                SalesPostandPdf2NavSetup.Init();
            if (ReportUsage = ReportSelection.Usage::"S.Shipment") and SalesPostandPdf2NavSetup."Always Print Ship" then
                DoPrint := true;
            if (ReportUsage = ReportSelection.Usage::"S.Ret.Rcpt.") and SalesPostandPdf2NavSetup."Always Print Receive" then
                DoPrint := true;
        end;

        if DoPrint then
            Printed := PrintReport(ReportUsage);

        if (DocSendProfile."Electronic Document" <> DocSendProfile."Electronic Document"::No) or
            (DocSendProfile.Disk <> DocSendProfile.Disk::No) then
            OIOReport(ReportUsage, DocSendProfile);
    end;

    local procedure PrintReport(ReportUsage: Enum "Report Selection Usage") Printed: Boolean
    begin
        if SkipPrintHandling then
            exit(false);

        ReportSelection.Reset();
        ReportSelection.SetRange(Usage, ReportUsage);
        ReportSelection.FindSet();
        repeat
            ReportSelection.TestField("Report ID");
            case ReportUsage of
                ReportSelection.Usage::"SM.Invoice":
                    REPORT.Run(ReportSelection."Report ID", false, false, SalesInvHeader);
                ReportSelection.Usage::"SM.Credit Memo":
                    REPORT.Run(ReportSelection."Report ID", false, false, SalesCrMemoHeader);
                ReportSelection.Usage::"S.Invoice":
                    REPORT.Run(ReportSelection."Report ID", false, false, SalesInvHeader);
                ReportSelection.Usage::"S.Cr.Memo":
                    REPORT.Run(ReportSelection."Report ID", false, false, SalesCrMemoHeader);
                ReportSelection.Usage::"S.Shipment":
                    REPORT.Run(ReportSelection."Report ID", false, false, SalesShptHeader);
                ReportSelection.Usage::"S.Ret.Rcpt.":
                    REPORT.Run(ReportSelection."Report ID", false, false, ReturnRcptHeader);
            end;
            Printed := true;
        until ReportSelection.Next() = 0;
    end;

    local procedure EmailReport(ReportUsage: Enum "Report Selection Usage")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        Commit();
        case ReportUsage of
            ReportSelection.Usage::"S.Cr.Memo":
                begin
                    if SalesCrMemoHeader.Get(SalesCrMemoHeader."No.") then
                        EmailDocMgt.SendReport(SalesCrMemoHeader, false);
                end;
            ReportSelection.Usage::"S.Invoice":
                begin
                    if SalesInvHeader.Get(SalesInvHeader."No.") then
                        EmailDocMgt.SendReport(SalesInvHeader, false);
                end;
        end;
    end;

    local procedure OIOReport(ReportUsage: Enum "Report Selection Usage"; DocSendProfilePar: Record "Document Sending Profile")
    begin
        DocSendProfilePar.Printer := DocSendProfilePar.Printer::No;
        DocSendProfilePar."E-Mail" := DocSendProfilePar."E-Mail"::No;

        case ReportUsage of
            ReportSelection.Usage::"S.Cr.Memo":
                begin
                    if SalesCrMemoHeader.Get(SalesCrMemoHeader."No.") then
                        SalesCrMemoHeader.SendProfile(DocSendProfilePar);
                end;
            ReportSelection.Usage::"S.Invoice":
                begin
                    if SalesInvHeader.Get(SalesInvHeader."No.") then
                        SalesInvHeader.SendProfile(DocSendProfilePar);
                end;
        end;
    end;

    procedure DontHandlePrint()
    begin
        SkipPrintHandling := true;
    end;

    procedure SetMode(NewMode: Integer)
    begin
        Mode := NewMode;
    end;
}