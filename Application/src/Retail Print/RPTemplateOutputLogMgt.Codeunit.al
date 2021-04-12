codeunit 6014603 "NPR RP Templ. Output Log Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Matrix Print Mgt.", 'OnSendPrintJob', '', false, false)]
    local procedure OnSendMatrixPrintJob(TemplateCode: Text; CodeunitId: Integer; var Printer: Codeunit "NPR RP Matrix Printer Interf."; NoOfPrints: Integer);
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        TargetEncoding: Text;
        PrintBytes: Text;
    begin
        if not RPTemplateHeader.GET(TemplateCode) then
            exit;
        if not RPTemplateHeader."Log Output" then
            exit;

        Printer.OnGetTargetEncoding(TargetEncoding);
        Printer.onGetPrintBytes(PrintBytes);

        LogPrintJob(Templatecode, TargetEncoding, PrintBytes);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnSendPrintJob', '', false, false)]
    local procedure OnSendLinePrintJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Line Printer Interf."; NoOfPrints: Integer);
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        TargetEncoding: Text;
        PrintBytes: Text;
    begin
        if not RPTemplateHeader.GET(TemplateCode) then
            exit;
        if not RPTemplateHeader."Log Output" then
            exit;

        Printer.OnGetTargetEncoding(TargetEncoding);
        Printer.onGetPrintBytes(PrintBytes);

        LogPrintJob(Templatecode, TargetEncoding, PrintBytes);
    end;

    local procedure LogPrintJob(Template: Text; TargetEncoding: Text; PrintJob: Text)
    var
        RPTemplateOutputLog: Record "NPR RP Template Output Log";
        OStream: OutStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        Encoding: DotNet NPRNetEncoding;
        ByteArray: DotNet NPRNetArray;

    begin
        if TargetEncoding = '' then
            TargetEncoding := 'Windows-1252';

        ByteArray := Encoding.GetEncoding(TargetEncoding).GetBytes(PrintJob);
        MemoryStream := MemoryStream.MemoryStream();
        MemoryStream.Write(ByteArray, 0, ByteArray.Length);

        RPTemplateOutputLog.Init();
        RPTemplateOutputLog."Template Name" := Template;
        RPTemplateOutputLog."User ID" := USERID;
        RPTemplateOutputLog."Printed At" := CURRENTDATETIME;
        RPTemplateOutputLog.Output.CREATEOUTSTREAM(OStream);
        COPYSTREAM(OStream, MemoryStream);
        RPTemplateOutputLog.Insert();
    end;
}