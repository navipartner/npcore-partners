codeunit 6014583 "NPR Report Printer Interface"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Wrapper object is no longer required - our custom report printing logic is subscribing to built in BC print events. Call Report.Run() instead';
    var
        ReportLayoutSelection: Record "Report Layout Selection";

    procedure RunReport(Number: Integer; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant)
    begin
        RunReport(Number, '', ReqWindow, SystemPrinter, "Record");
    end;

    procedure RunReport(Number: Integer; CustomReportLayoutCode: Code[20]; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant)
    begin
        if CustomReportLayoutCode <> '' then
            ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutCode)
        else
            ReportLayoutSelection.SetTempLayoutSelected('');

        if (Record.IsRecord or Record.IsRecordRef) then
            REPORT.Run(Number, ReqWindow, SystemPrinter, Record)
        else
            REPORT.Run(Number, ReqWindow, SystemPrinter);

        ReportLayoutSelection.SetTempLayoutSelected('')
    end;
    
    procedure GetLastError(): Text
    begin
        Error('GetLastError text in ReportPrinterInterface codeunit is no longer supported');
    end;    
}
