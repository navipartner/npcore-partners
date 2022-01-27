codeunit 6014603 "NPR RP Templ. Output Log Mgt."
{
    Access = Internal;
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
        DotNetEncoding: Codeunit DotNet_Encoding;
        BinaryWriter: Codeunit DotNet_BinaryWriter;
        DotNetStream: Codeunit DotNet_Stream;
        TextEncodingMapper: Codeunit "NPR Text Encoding Mapper";
        OStream: OutStream;
        i: Integer;
    begin
        if TargetEncoding = '' then
            TargetEncoding := 'Windows-1252';

        DotNetEncoding.Encoding(TextEncodingMapper.EncodingNameToCodePageNumber(TargetEncoding));

        RPTemplateOutputLog.Init();
        RPTemplateOutputLog."Template Name" := Template;
        RPTemplateOutputLog."User ID" := USERID;
        RPTemplateOutputLog."Printed At" := CURRENTDATETIME;
        RPTemplateOutputLog.Output.CREATEOUTSTREAM(OStream);

        DotNetStream.FromOutStream(OStream);
        BinaryWriter.BinaryWriterWithEncoding(DotNetStream, DotNetEncoding);
        for i := 1 to StrLen(PrintJob) do
            BinaryWriter.WriteChar(PrintJob[i]);

        RPTemplateOutputLog.Insert();
    end;
}
