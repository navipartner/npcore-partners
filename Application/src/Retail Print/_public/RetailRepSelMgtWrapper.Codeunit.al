codeunit 6151067 "NPR Retail Rep.Sel.Mgt Wrapper"
{
    Access = Public;

    var
        RetailReportSelectMgt: Codeunit "NPR Retail Report Select. Mgt.";

    procedure RunObjects(var RecRef: RecordRef; ReportType: Integer)
    begin
        RetailReportSelectMgt.RunObjects(RecRef, ReportType);
    end;

    procedure SetRegisterNo(RegisterNoIn: Code[10])
    begin
        RetailReportSelectMgt.SetRegisterNo(RegisterNoIn);
    end;

    procedure SetRequestWindow(ReqWindowIn: Boolean)
    begin
        RetailReportSelectMgt.SetRequestWindow(ReqWindowIn);
    end;

    procedure SetUseSystemPrinter(SystemPrinterIn: Boolean)
    begin
        RetailReportSelectMgt.SetUseSystemPrinter(SystemPrinterIn);
    end;

    procedure SetMatrixPrintIterationFieldNo(FieldNo: Integer)
    begin
        RetailReportSelectMgt.SetMatrixPrintIterationFieldNo(FieldNo);
    end;
}