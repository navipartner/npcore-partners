codeunit 61001 "NPR NPRPTE Print As Message"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendLinePrint', '', false, false)]
    local procedure OnBeforeSendLinePrint(var Printer: Interface "NPR ILine Printer"; var Skip: Boolean; TemplateCode: Text; CodeunitId: Integer)
    begin
        Skip := true;
        Message('Line print intercepted:\Template %1\Codeunit %2\\\%3', TemplateCode, CodeunitId, Printer.GetPrintBufferAsBase64());
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendMatrixPrint', '', false, false)]
    local procedure OnBeforeSendMatrixPrint(var Printer: Interface "NPR IMatrix Printer"; var Skip: Boolean; TemplateCode: Text; CodeunitId: Integer)
    begin
        Skip := true;
        Message('Matrix print intercepted:\Template %1\Codeunit %2\\\%3', TemplateCode, CodeunitId, Printer.GetPrintBufferAsBase64());
    end;
}