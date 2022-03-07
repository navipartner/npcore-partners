
codeunit 6014583 "NPR Report Printer Interface"
{
    trigger OnRun()
    begin
    end;

    var
        ReportLayoutSelection: Record "Report Layout Selection";
        LastErrorText: Text;
        RecordSpecified: Boolean;
#if not CLOUD
        Err_ReportPrint: Label 'Error when printing report %1 %2';
        SuppressError: Boolean;
#endif

    procedure RunReport(Number: Integer; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant)
    begin
        RunReport(Number, '', ReqWindow, SystemPrinter, "Record");
    end;

    procedure RunReport(Number: Integer; CustomReportLayoutCode: Code[20]; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant)
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndMgt: Codeunit "NPR POS Front End Management";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        RecordSpecified := Record.IsRecord or Record.IsRecordRef;

        if GuiAllowed then
            if not POSSession.IsActiveSession(POSFrontEndMgt) then begin
                RunStandardReportFlow(Number, CustomReportLayoutCode, ReqWindow, SystemPrinter, Record);
                exit;
            end;

        if not ObjectOutputMgt.TryGetOutputRec(ObjectOutputSelection."Object Type"::Report, Number, '', UserId, ObjectOutputSelection) then begin
            if GuiAllowed then
                RunStandardReportFlow(Number, CustomReportLayoutCode, ReqWindow, SystemPrinter, Record);
            exit;
        end;
#if not CLOUD
        RunCustomReportFlow(Number, CustomReportLayoutCode, ReqWindow, Record, ObjectOutputSelection);
#endif
    end;

    local procedure RunStandardReportFlow(Number: Integer; CustomReportLayoutCode: Code[20]; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant)
    begin
        if CustomReportLayoutCode <> '' then
            ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutCode)
        else
            ReportLayoutSelection.SetTempLayoutSelected('');

        if RecordSpecified then
            REPORT.Run(Number, ReqWindow, SystemPrinter, Record)
        else
            REPORT.Run(Number, ReqWindow, SystemPrinter);

        ReportLayoutSelection.SetTempLayoutSelected('');
    end;
#if not CLOUD
    local procedure RunCustomReportFlow(Number: Integer; CustomReportLayoutCode: Code[20]; ReqWindow: Boolean; "Record": Variant; ObjectOutputSelection: Record "NPR Object Output Selection")
    var
        PDFStream: DotNet NPRNetMemoryStream;
    begin
        if not (ObjectOutputSelection."Output Type" in [ObjectOutputSelection."Output Type"::"Printer Name",
                                                        ObjectOutputSelection."Output Type"::"PrintNode PDF",
                                                        ObjectOutputSelection."Output Type"::"E-mail"]) then
            ObjectOutputSelection.FieldError("Output Type");

        if not CreatePDF(Number, CustomReportLayoutCode, ReqWindow, Record, PDFStream) then
            exit;

        if PDFStream.Length < 1 then
            exit;

        if TryPrintPDF(ObjectOutputSelection."Output Path", PDFStream, ObjectOutputSelection."Output Type", Number) then
            exit;

        LastErrorText := GetLastErrorText();
        if (not SuppressError) and GuiAllowed then begin
            if LastErrorText <> '' then
                LastErrorText := ' - ' + LastErrorText;
            Error(Err_ReportPrint, Format(Number), LastErrorText);
        end;
    end;

    procedure SetSuppressError(SuppressErrorIn: Boolean)
    begin
        SuppressError := SuppressErrorIn;
    end;
#endif

    procedure GetLastError(): Text
    begin
        exit(LastErrorText);
    end;
#if not CLOUD
    local procedure CreatePDF(Number: Integer; CustomReportLayoutCode: Code[20]; ReqWindow: Boolean; var "Record": Variant; var OutPDFStream: DotNet NPRNetMemoryStream): Boolean
    var
        Parameters: Text;
        OutStr: OutStream;
        RecRef: RecordRef;
    begin
        if ReqWindow then begin
            Parameters := REPORT.RunRequestPage(Number);
            if Parameters = '' then
                exit(false);
        end;

        if Record.IsRecord then
            RecRef.GetTable(Record)
        else
            if Record.IsRecordRef then
                RecRef := Record;

        OutPDFStream := OutPDFStream.MemoryStream();
        OutStr := OutPDFStream;

        if CustomReportLayoutCode <> '' then
            ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutCode)
        else
            ReportLayoutSelection.SetTempLayoutSelected('');

        if RecordSpecified then begin
            REPORT.SaveAs(Number, Parameters, REPORTFORMAT::Pdf, OutStr, RecRef)
        end else
            REPORT.SaveAs(Number, Parameters, REPORTFORMAT::Pdf, OutStr);

        ReportLayoutSelection.SetTempLayoutSelected('');
        exit(true);
    end;

    [TryFunction]
    local procedure TryPrintPDF(OutputPath: Text; var Stream: DotNet NPRNetMemoryStream; OutputType: Integer; ObjectID: Integer)
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
    begin
        case OutputType of
            ObjectOutputSelection."Output Type"::"E-mail":
                PrintMethodMgt.PrintViaEmail(OutputPath, Stream);
            ObjectOutputSelection."Output Type"::"Printer Name":
                PrintMethodMgt.PrintFileLocal(OutputPath, Stream, 'pdf');
            ObjectOutputSelection."Output Type"::"PrintNode PDF":
                begin
                    ObjectOutputSelection."Object Type" := ObjectOutputSelection."Object Type"::Report;
                    ObjectOutputSelection."Object ID" := ObjectID;
                    ObjectOutputSelection.GetObjectName();
                    PrintMethodMgt.PrintViaPrintNodePdf(OutputPath, Stream, ObjectOutputSelection."Object Name", 0, ObjectID);
                end;
        end;
    end;
#endif
}
