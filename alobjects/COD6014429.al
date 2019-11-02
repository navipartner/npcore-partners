codeunit 6014429 "POS Sales Document Output Mgt."
{
    // NPR5.52/MMV /20190911 CASE 352473 Created object


    trigger OnRun()
    begin
    end;

    procedure SendDocument(SalesHeader: Record "Sales Header";Type: Option Standard,PrepayInvoice,PrepayCredit)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        with SalesHeader do begin
          case Type of
            Type::Standard :
              begin
                case "Document Type" of
                  "Document Type"::Order:
                    begin
                      if Invoice then begin
                        SalesInvHeader.Get("Last Posting No.");
                        SalesInvHeader.SetRecFilter;
                        SalesInvHeader.SendRecords();
                      end;
                    end;
                  "Document Type"::Invoice:
                    begin
                      if "Last Posting No." = '' then
                        SalesInvHeader.Get("No.")
                      else
                        SalesInvHeader.Get("Last Posting No.");
                      SalesInvHeader.SetRecFilter;
                      SalesInvHeader.SendRecords();
                    end;
                  "Document Type"::"Return Order":
                    begin
                      if Invoice then begin
                        SalesCrMemoHeader.Get("Last Posting No.");
                        SalesCrMemoHeader.SetRecFilter;
                        SalesCrMemoHeader.SendRecords();
                      end;
                    end;
                  "Document Type"::"Credit Memo":
                    begin
                      if "Last Posting No." = '' then
                        SalesCrMemoHeader.Get("No.")
                      else
                        SalesCrMemoHeader.Get("Last Posting No.");
                      SalesCrMemoHeader.SetRecFilter;
                      SalesCrMemoHeader.SendRecords();
                    end;
                end;
              end;
            Type::PrepayInvoice :
              begin
                SalesInvHeader.Get("Last Prepayment No.");
                SalesInvHeader.SetRecFilter;
                SalesInvHeader.SendRecords();
              end;
            Type::PrepayCredit :
              begin
                SalesCrMemoHeader.Get("Last Prepmt. Cr. Memo No.");
                SalesCrMemoHeader.SetRecFilter;
                SalesCrMemoHeader.SendRecords();
              end;
          end;
        end;
    end;

    procedure PrintDocument(SalesHeader: Record "Sales Header";Type: Option Standard,PrepayInvoice,PrepayCredit)
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnRcptHeader: Record "Return Receipt Header";
        ReportSelection: Record "Report Selections";
        "Record": Variant;
        ReportPrinterInterface: Codeunit "Report Printer Interface";
    begin
        //Can be silent in webclient via REPORT.RUN wrapper and does not auto print shipment or receivals unless nothing was invoiced.

        with SalesHeader do begin
          case Type of
            Type::Standard :
              begin
                case "Document Type" of
                  "Document Type"::Order:
                    begin
                      if Invoice then begin
                        SalesInvHeader."No." := "Last Posting No.";
                        SalesInvHeader.SetRecFilter;
                        Record := SalesInvHeader;
                        ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Invoice");
                      end else if Ship then begin
                        SalesShptHeader."No." := "Last Shipping No.";
                        SalesShptHeader.SetRecFilter;
                        Record := SalesShptHeader;
                        ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Shipment");
                      end;
                    end;
                  "Document Type"::Invoice:
                    begin
                      if "Last Posting No." = '' then
                        SalesInvHeader."No." := "No."
                      else
                        SalesInvHeader."No." := "Last Posting No.";
                      SalesInvHeader.SetRecFilter;
                      Record := SalesInvHeader;
                      ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Invoice");
                    end;
                  "Document Type"::"Return Order":
                    begin
                      if Invoice then begin
                        SalesCrMemoHeader."No." := "Last Posting No.";
                        SalesCrMemoHeader.SetRecFilter;
                        Record := SalesCrMemoHeader;
                        ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Cr.Memo");
                      end else if Receive then begin
                        ReturnRcptHeader."No." := "Last Return Receipt No.";
                        ReturnRcptHeader.SetRecFilter;
                        Record := ReturnRcptHeader;
                        ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Ret.Rcpt.");
                      end;
                    end;
                  "Document Type"::"Credit Memo":
                    begin
                      if "Last Posting No." = '' then
                        SalesCrMemoHeader."No." := "No."
                      else
                        SalesCrMemoHeader."No." := "Last Posting No.";
                      SalesCrMemoHeader.SetRecFilter;
                      Record := SalesCrMemoHeader;
                      ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Cr.Memo");
                    end;
                end;
              end;
            Type::PrepayInvoice :
              begin
                ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Invoice");
                SalesInvHeader."No." := SalesHeader."Last Prepayment No.";
                SalesInvHeader.SetRecFilter;
                Record := SalesInvHeader;
              end;
            Type::PrepayCredit :
              begin
                ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Cr.Memo");
                SalesCrMemoHeader."No." := SalesHeader."Last Prepmt. Cr. Memo No.";
                SalesCrMemoHeader.SetRecFilter;
                Record := SalesCrMemoHeader;
              end;
          end;
        end;

        PrintReportSelection(ReportSelection, Record);
    end;

    procedure SendPdf2NavDocument(SalesHeader: Record "Sales Header";Type: Option Standard,PrepayInvoice,PrepayCredit)
    var
        SalesPostandPdf2Nav: Codeunit "Sales-Post and Pdf2Nav";
    begin
        SalesPostandPdf2Nav.DontHandlePrint;
        SalesPostandPdf2Nav.SetMode(Type);
        SalesPostandPdf2Nav.GetReport(SalesHeader);
    end;

    procedure PrintReportSelection(var ReportSelections: Record "Report Selections";var RecordVariant: Variant)
    var
        ReportPrinterInterface: Codeunit "Report Printer Interface";
    begin
        if not RecordVariant.IsRecord then
          exit;

        if not ReportSelections.FindSet then
          exit;

        repeat
          ReportPrinterInterface.RunReport(ReportSelections."Report ID", false, false, RecordVariant);
        until ReportSelections.Next = 0;
    end;
}

