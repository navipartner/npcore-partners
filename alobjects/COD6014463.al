codeunit 6014463 "Sales-Post and Pdf2Nav"
{
    // NPR5.36/THRO/20170908 CASE 285645 Codeunit 82 copy with Pdf2Nav
    // NPR5.39/THRO/20171222 CASE 299380 Option to skip handling of Print (Used from POS). Removed the "Download queston"-popup if not printing
    // NPR5.39/TS  /20180221 CASE 294224 Global Variable SalesHeader is not initialised.
    // NPR5.49/BHR /20190118 CASE 341617 Correction to print report based on setup

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

    local procedure "Code"()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesPostViaJobQueue: Codeunit "Sales Post via Job Queue";
        SendReportAsEmail: Boolean;
    begin
        with SalesHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              begin
                Selection := StrMenu(Text000,3);
                if Selection = 0 then
                  exit;
                Ship := Selection in [1,3];
                Invoice := Selection in [2,3];
              end;
            "Document Type"::"Return Order":
              begin
                Selection := StrMenu(Text002,3);
                if Selection = 0 then
                  exit;
                Receive := Selection in [1,3];
                Invoice := Selection in [2,3];
              end
            else
              if not Confirm(ConfirmationMessage,false,"Document Type") then
                exit;
          end;

          "Print Posted Documents" := true;
          SendReportAsEmail := "Document Processing" in ["Document Processing"::Email,"Document Processing"::PrintAndEmail];

          SalesSetup.Get;
          if SalesSetup."Post & Print with Job Queue" and not SendReportAsEmail then
            SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
          else begin
            CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);
            GetReport(SalesHeader);
          end;
          Commit;
        end;
    end;

    procedure GetReport(var SalesHeader2: Record "Sales Header")
    var
        CustomReportSelection: Record "Custom Report Selection";
        CustomReportID: Integer;
        OrderPrinted: Boolean;
    begin
        //-PN1.10
        Commit;
        //+PN1.10
        //-NPR5.39 [294224]
        SalesHeader.Copy(SalesHeader2);
        //+NPR5.39 [294224]
        with SalesHeader do
          case "Document Type" of
            "Document Type"::Order:
              begin
                if Ship then begin
                  SalesShptHeader."No." := "Last Shipping No.";
                  SalesShptHeader.SetRecFilter;
        //-NPR5.39 [299380]
                  OrderPrinted := HandleReport(ReportSelection.Usage::"S.Shipment");
        //+NPR5.39 [299380]
                end;
        //-NPR5.39 [299380]
        //        IF IsPrintingBothDocumentsForNonWindowsClient(Ship AND Invoice) THEN
                if IsPrintingBothDocumentsForNonWindowsClient(Ship and Invoice and OrderPrinted) then
        //+NPR5.39 [299380]
                  if not Confirm(DownloadInvoiceAlsoQst,true) then
                    exit;
                if Invoice then begin
                  SalesInvHeader."No." := "Last Posting No.";
                  SalesInvHeader.SetRecFilter;
                  HandleReport(ReportSelection.Usage::"S.Invoice");
                end;
              end;
            "Document Type"::Invoice:
              begin
                if "Last Posting No." = '' then
                  SalesInvHeader."No." := "No."
                else
                  SalesInvHeader."No." := "Last Posting No.";
                SalesInvHeader.SetRecFilter;

                HandleReport(ReportSelection.Usage::"S.Invoice");
              end;
            "Document Type"::"Return Order":
              begin
                if Receive then begin
                  ReturnRcptHeader."No." := "Last Return Receipt No.";
                  ReturnRcptHeader.SetRecFilter;
        //-NPR5.39 [299380]
                  OrderPrinted := HandleReport(ReportSelection.Usage::"S.Ret.Rcpt.");
        //+NPR5.39 [299380]
                end;
        //-NPR5.39 [299380]
        //        IF IsPrintingBothDocumentsForNonWindowsClient(Ship AND Invoice) THEN
                if IsPrintingBothDocumentsForNonWindowsClient(Ship and Invoice and OrderPrinted) then
        //+NPR5.39 [299380]
                  if not Confirm(DownloadCrMemoAlsoQst,true) then
                    exit;
                if Invoice then begin
                  SalesCrMemoHeader."No." := "Last Posting No.";
                  SalesCrMemoHeader.SetRecFilter;

                  HandleReport(ReportSelection.Usage::"S.Cr.Memo");
                end;
              end;
            "Document Type"::"Credit Memo":
              begin
                if "Last Posting No." = '' then
                  SalesCrMemoHeader."No." := "No."
                else
                  SalesCrMemoHeader."No." := "Last Posting No.";
                SalesCrMemoHeader.SetRecFilter;

                HandleReport(ReportSelection.Usage::"S.Cr.Memo");
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

    local procedure HandleReport(ReportUsage: Integer) Printed: Boolean
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
        DoPrint: Boolean;
    begin
        if SalesHeader."Document Processing" in
          [SalesHeader."Document Processing"::Email,SalesHeader."Document Processing"::PrintAndEmail] then
          EmailReport(ReportUsage);

        if (SalesHeader."Document Processing" in
           [SalesHeader."Document Processing"::Print,SalesHeader."Document Processing"::PrintAndEmail]) then begin
        // -NPR5.49 [341617]
        // DoPrint := TRUE;
        //IF (NOT DoPrint) THEN BEGIN
        // +NPR5.49 [341617]
          if not SalesPostandPdf2NavSetup.Get then
            SalesPostandPdf2NavSetup.Init;
          if (ReportUsage = ReportSelection.Usage::"S.Shipment") and SalesPostandPdf2NavSetup."Always Print Ship" then
            DoPrint := true;
          if (ReportUsage = ReportSelection.Usage::"S.Ret.Rcpt.") and SalesPostandPdf2NavSetup."Always Print Receive" then
            DoPrint := true;
        end;

        if DoPrint then
        //-NPR5.39 [299380]
          Printed := PrintReport(ReportUsage);
        //+NPR5.39 [299380]

        if SalesHeader."Document Processing" = SalesHeader."Document Processing"::OIO then
          OIOReport(ReportUsage);
    end;

    local procedure PrintReport(ReportUsage: Integer) Printed: Boolean
    begin
        //-NPR5.39 [299380]
        if SkipPrintHandling then
          exit(false);
        //+NPR5.39 [299380]

        ReportSelection.Reset;
        ReportSelection.SetRange(Usage,ReportUsage);
        ReportSelection.FindSet;
        repeat
          ReportSelection.TestField("Report ID");
          case ReportUsage of
            ReportSelection.Usage::"SM.Invoice":
              REPORT.Run(ReportSelection."Report ID",false,false,SalesInvHeader);
            ReportSelection.Usage::"SM.Credit Memo":
              REPORT.Run(ReportSelection."Report ID",false,false,SalesCrMemoHeader);
            ReportSelection.Usage::"S.Invoice":
              REPORT.Run(ReportSelection."Report ID",false,false,SalesInvHeader);
            ReportSelection.Usage::"S.Cr.Memo":
              REPORT.Run(ReportSelection."Report ID",false,false,SalesCrMemoHeader);
            ReportSelection.Usage::"S.Shipment":
              REPORT.Run(ReportSelection."Report ID",false,false,SalesShptHeader);
            ReportSelection.Usage::"S.Ret.Rcpt.":
              REPORT.Run(ReportSelection."Report ID",false,false,ReturnRcptHeader);
          end;
        //-NPR5.39 [299380]
          Printed := true;
        //+NPR5.39 [299380]
        until ReportSelection.Next = 0;
    end;

    local procedure EmailReport(ReportUsage: Integer)
    var
        EmailDocMgt: Codeunit "E-mail Document Management";
    begin
        case ReportUsage of
          ReportSelection.Usage::"S.Cr.Memo" :
            begin
              if SalesCrMemoHeader.Get(SalesCrMemoHeader."No.") then
                EmailDocMgt.SendReport(SalesCrMemoHeader,false);
            end;
          ReportSelection.Usage::"S.Invoice" :
            begin
              if SalesInvHeader.Get(SalesInvHeader."No.") then
                EmailDocMgt.SendReport(SalesInvHeader,false);
            end;
        end;
    end;

    local procedure OIOReport(ReportUsage: Integer)
    var
        NPRDocLocalizationProxy: Codeunit "NPR Doc. Localization Proxy";
    begin
        case ReportUsage of
          ReportSelection.Usage::"S.Cr.Memo" :
            begin
              if SalesCrMemoHeader.Get(SalesCrMemoHeader."No.") then
                NPRDocLocalizationProxy.SaveXMLDocument(3,SalesCrMemoHeader."No.");
            end;
          ReportSelection.Usage::"S.Invoice" :
            begin
              if SalesInvHeader.Get(SalesInvHeader."No.") then
                NPRDocLocalizationProxy.SaveXMLDocument(1,SalesInvHeader."No.");
            end;
        end;
    end;

    procedure DontHandlePrint()
    begin
        //-NPR5.39 [299380]
        SkipPrintHandling := true;
        //+NPR5.39 [299380]
    end;
}

