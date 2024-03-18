codeunit 85190 "NPR Retail Print Handler"
{
    EventSubscriberInstance = Manual;

    var
        _PrintJobBase64: Text;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendLinePrint', '', false, false)]
    local procedure OnBeforeSendLinePrint(var Printer: Interface "NPR ILine Printer"; var Skip: Boolean)
    begin
        Skip := true;
        _PrintJobBase64 := Printer.GetPrintBufferAsBase64();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendMatrixPrint', '', false, false)]
    local procedure OnBeforeSendMatrixPrint(var Printer: Interface "NPR IMatrix Printer"; var Skip: Boolean)
    begin
        Skip := true;
        _PrintJobBase64 := Printer.GetPrintBufferAsBase64();
    end;

    procedure GetPrintJobBase64(): Text
    begin
        exit(_PrintJobBase64);
    end;

}