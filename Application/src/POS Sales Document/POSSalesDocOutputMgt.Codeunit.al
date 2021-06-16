codeunit 6014429 "NPR POS Sales Doc. Output Mgt."
{
    // NPR5.52/MMV /20190911 CASE 352473 Created object
    // NPR5.53/MMV /20200102 CASE 377510 Added OnRun trigger for better error handling

    TableNo = "Sales Header";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
    begin
        //-NPR5.53 [377510]
        SalesHeader := Rec;
        SalesHeader.SetRecFilter();

        case OutputMethodType of
            OutputMethodType::Print:
                PrintDocument(SalesHeader, OutputDocumentType);
            OutputMethodType::Send:
                SendDocument(SalesHeader, OutputDocumentType);
            OutputMethodType::Pdf2Nav:
                SendPdf2NavDocument(SalesHeader, OutputDocumentType);
        end;
        //+NPR5.53 [377510]
    end;

    var
        OutputMethodType: Option Send,Print,Pdf2Nav;
        OutputDocumentType: Option Standard,PrepayInvoice,PrepayCredit;

    procedure SetOnRunOperation(OutputMethodTypeIn: Integer; OutputDocumentTypeIn: Integer)
    begin
        //-NPR5.53 [377510]
        OutputMethodType := OutputMethodTypeIn;
        OutputDocumentType := OutputDocumentTypeIn;
        //+NPR5.53 [377510]
    end;

    procedure SendDocument(SalesHeader: Record "Sales Header"; Type: Option Standard,PrepayInvoice,PrepayCredit)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case Type of
            Type::Standard:
                begin
                    case SalesHeader."Document Type" of
                        SalesHeader."Document Type"::Order:
                            begin
                                if SalesHeader.Invoice then begin
                                    SalesInvHeader.Get(SalesHeader."Last Posting No.");
                                    SalesInvHeader.SetRecFilter();
                                    SalesInvHeader.SendRecords();
                                end;
                            end;
                        SalesHeader."Document Type"::Invoice:
                            begin
                                if SalesHeader."Last Posting No." = '' then
                                    SalesInvHeader.Get(SalesHeader."No.")
                                else
                                    SalesInvHeader.Get(SalesHeader."Last Posting No.");
                                SalesInvHeader.SetRecFilter();
                                SalesInvHeader.SendRecords();
                            end;
                        SalesHeader."Document Type"::"Return Order":
                            begin
                                if SalesHeader.Invoice then begin
                                    SalesCrMemoHeader.Get(SalesHeader."Last Posting No.");
                                    SalesCrMemoHeader.SetRecFilter();
                                    SalesCrMemoHeader.SendRecords();
                                end;
                            end;
                        SalesHeader."Document Type"::"Credit Memo":
                            begin
                                if SalesHeader."Last Posting No." = '' then
                                    SalesCrMemoHeader.Get(SalesHeader."No.")
                                else
                                    SalesCrMemoHeader.Get(SalesHeader."Last Posting No.");
                                SalesCrMemoHeader.SetRecFilter();
                                SalesCrMemoHeader.SendRecords();
                            end;
                    end;
                end;
            Type::PrepayInvoice:
                begin
                    SalesInvHeader.Get(SalesHeader."Last Prepayment No.");
                    SalesInvHeader.SetRecFilter();
                    SalesInvHeader.SendRecords();
                end;
            Type::PrepayCredit:
                begin
                    SalesCrMemoHeader.Get(SalesHeader."Last Prepmt. Cr. Memo No.");
                    SalesCrMemoHeader.SetRecFilter();
                    SalesCrMemoHeader.SendRecords();
                end;
        end;
    end;

    procedure PrintDocument(SalesHeader: Record "Sales Header"; Type: Option Standard,PrepayInvoice,PrepayCredit)
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnRcptHeader: Record "Return Receipt Header";
        "Record": Variant;
        ReportUsage: Enum "Report Selection Usage";
        CurstomerNoFieldNo: Integer;
    begin
        //Can be silent in webclient via REPORT.RUN wrapper and does not auto print shipment or receivals unless nothing was invoiced.
        case Type of
            Type::Standard:
                begin
                    case SalesHeader."Document Type" of
                        SalesHeader."Document Type"::Order:
                            begin
                                if SalesHeader.Invoice then begin
                                    SalesInvHeader."No." := SalesHeader."Last Posting No.";
                                    SalesInvHeader.SetRecFilter();
                                    "Record" := SalesInvHeader;
                                    CurstomerNoFieldNo := SalesInvHeader.FieldNo("Bill-to Customer No.");
                                    ReportUsage := ReportUsage::"S.Invoice";
                                end else
                                    if SalesHeader.Ship then begin
                                        SalesShptHeader."No." := SalesHeader."Last Shipping No.";
                                        SalesShptHeader.SetRecFilter();
                                        "Record" := SalesShptHeader;
                                        CurstomerNoFieldNo := SalesShptHeader.FieldNo("Sell-to Customer No.");
                                        ReportUsage := ReportUsage::"S.Shipment";
                                    end;
                            end;
                        SalesHeader."Document Type"::Invoice:
                            begin
                                if SalesHeader."Last Posting No." = '' then
                                    SalesInvHeader."No." := SalesHeader."No."
                                else
                                    SalesInvHeader."No." := SalesHeader."Last Posting No.";
                                SalesInvHeader.SetRecFilter();
                                "Record" := SalesInvHeader;
                                CurstomerNoFieldNo := SalesInvHeader.FieldNo("Bill-to Customer No.");
                                ReportUsage := ReportUsage::"S.Invoice";
                            end;
                        SalesHeader."Document Type"::"Return Order":
                            begin
                                if SalesHeader.Invoice then begin
                                    SalesCrMemoHeader."No." := SalesHeader."Last Posting No.";
                                    SalesCrMemoHeader.SetRecFilter();
                                    "Record" := SalesCrMemoHeader;
                                    CurstomerNoFieldNo := SalesCrMemoHeader.FieldNo("Bill-to Customer No.");
                                    ReportUsage := ReportUsage::"S.Cr.Memo";
                                end else
                                    if SalesHeader.Receive then begin
                                        ReturnRcptHeader."No." := SalesHeader."Last Return Receipt No.";
                                        ReturnRcptHeader.SetRecFilter();
                                        "Record" := ReturnRcptHeader;
                                        CurstomerNoFieldNo := ReturnRcptHeader.FieldNo("Sell-to Customer No.");
                                        ReportUsage := ReportUsage::"S.Ret.Rcpt.";
                                    end;
                            end;
                        SalesHeader."Document Type"::"Credit Memo":
                            begin
                                if SalesHeader."Last Posting No." = '' then
                                    SalesCrMemoHeader."No." := SalesHeader."No."
                                else
                                    SalesCrMemoHeader."No." := SalesHeader."Last Posting No.";
                                SalesCrMemoHeader.SetRecFilter();
                                "Record" := SalesCrMemoHeader;
                                CurstomerNoFieldNo := SalesCrMemoHeader.FieldNo("Bill-to Customer No.");
                                ReportUsage := ReportUsage::"S.Cr.Memo";
                            end;
                    end;
                end;
            Type::PrepayInvoice:
                begin
                    SalesInvHeader."No." := SalesHeader."Last Prepayment No.";
                    SalesInvHeader.SetRecFilter();
                    "Record" := SalesInvHeader;
                    CurstomerNoFieldNo := SalesInvHeader.FieldNo("Bill-to Customer No.");
                    ReportUsage := ReportUsage::"S.Invoice";
                end;
            Type::PrepayCredit:
                begin
                    SalesCrMemoHeader."No." := SalesHeader."Last Prepmt. Cr. Memo No.";
                    SalesCrMemoHeader.SetRecFilter();
                    "Record" := SalesCrMemoHeader;
                    CurstomerNoFieldNo := SalesCrMemoHeader.FieldNo("Bill-to Customer No.");
                    ReportUsage := ReportUsage::"S.Cr.Memo";
                end;
        end;

        PrintReportSelection_Customer(ReportUsage, "Record", CurstomerNoFieldNo);
    end;

    procedure SendPdf2NavDocument(SalesHeader: Record "Sales Header"; Type: Option Standard,PrepayInvoice,PrepayCredit)
    var
        SalesPostandPdf2Nav: Codeunit "NPR Sales-Post and Pdf2Nav";
    begin
        SalesPostandPdf2Nav.DontHandlePrint();
        SalesPostandPdf2Nav.SetMode(Type);
        SalesPostandPdf2Nav.GetReport(SalesHeader);
    end;

    local procedure PrintReportSelection_Customer(ReportUsage: Enum "Report Selection Usage"; var RecordVariant: Variant; CustomerNoFieldNo: Integer)
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        TempReportSelections.FindReportUsageForCust(ReportUsage, GetAccountNo(RecordVariant, CustomerNoFieldNo), TempReportSelections);
        PrintReportSelection(TempReportSelections, RecordVariant);
    end;

    procedure PrintReportSelection(var ReportSelections: Record "Report Selections"; var RecordVariant: Variant)
    var
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
    begin
        if not RecordVariant.IsRecord then
            exit;

        if not ReportSelections.FindSet() then
            exit;

        repeat
            ReportPrinterInterface.RunReport(ReportSelections."Report ID", ReportSelections."Custom Report Layout Code", false, false, RecordVariant);
        until ReportSelections.Next() = 0;
    end;

    local procedure GetAccountNo(var RecordVariant: Variant; AccountNoFieldNo: Integer): Code[20]
    var
        RecRef: RecordRef;
        AccountNoFieldRef: FieldRef;
    begin
        if AccountNoFieldNo <> 0 then begin
            RecRef.GetTable(RecordVariant);
            if RecRef.Find() then begin
                AccountNoFieldRef := RecRef.Field(AccountNoFieldNo);
                exit(CopyStr(AccountNoFieldRef.Value, 1, 20));
            end;
        end;
        exit('');
    end;
}
