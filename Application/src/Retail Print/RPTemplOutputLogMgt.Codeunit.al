codeunit 6014603 "NPR RP Templ. Output Log Mgt."
{
    Access = Internal;
    procedure LogMatrixPrintJob(TemplateCode: Text; CodeunitId: Integer; var Printer: Interface "NPR IMatrix Printer"; NoOfPrints: Integer);
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        PrintBufferBase64: Text;
    begin
        if not RPTemplateHeader.GET(TemplateCode) then
            exit;
        if not RPTemplateHeader."Log Output" then
            exit;

        PrintBufferBase64 := Printer.GetPrintBufferAsBase64();
        LogPrintJob(Templatecode, PrintBufferBase64);
    end;

    procedure LogLinePrintJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR ILine Printer"; NoOfPrints: Integer);
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        PrintBufferBase64: Text;
    begin
        if not RPTemplateHeader.GET(TemplateCode) then
            exit;
        if not RPTemplateHeader."Log Output" then
            exit;

        PrintBufferBase64 := Printer.GetPrintBufferAsBase64();
        LogPrintJob(Templatecode, PrintBufferBase64);
    end;

    local procedure LogPrintJob(Template: Text; PrintBufferBase64: Text)
    var
        RPTemplateOutputLog: Record "NPR RP Template Output Log";
        OStream: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        RPTemplateOutputLog.Init();
#pragma warning disable AA0139
        RPTemplateOutputLog."Template Name" := Template;
        RPTemplateOutputLog."User ID" := USERID;
#pragma warning restore AA0139
        RPTemplateOutputLog."Printed At" := CURRENTDATETIME;
        RPTemplateOutputLog.Output.CREATEOUTSTREAM(OStream);
        Base64Convert.FromBase64(PrintBufferBase64, OStream);
        RPTemplateOutputLog.Insert();
    end;
}
