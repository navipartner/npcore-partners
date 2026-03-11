#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6150992 "NPR API POS Entry Print Mgt."
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        CapturedPrintJob: Text;

    internal procedure GetCapturedPrintJob(): Text
    begin
        exit(CapturedPrintJob);
    end;

    internal procedure HasCapturedJob(): Boolean
    begin
        exit(CapturedPrintJob <> '');
    end;

    internal procedure ClearCapturedJob()
    begin
        Clear(CapturedPrintJob);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendLinePrint', '', false, false)]
    local procedure OnBeforeSendLinePrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR ILine Printer"; NoOfPrints: Integer; var Skip: Boolean)
    begin
        // Capture the print job as base64
        CapturedPrintJob := Printer.GetPrintBufferAsBase64();

        // Skip the actual printing since we're in an API context
        Skip := true;
    end;
}
#endif
