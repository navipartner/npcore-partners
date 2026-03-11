#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151083 "NPR API Retail Print Handler" implements "NPR IRetail Print Handler"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _SelfAsHandler: Interface "NPR IRetail Print Handler";
        _CapturedJobs: JsonArray;
        _UnsupportedOutputLbl: Label 'Output type %1 is not supported for API printing. This is a programming bug.';

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    var
        Job: JsonObject;
    begin
        Job.Add('type', 'windows_spooler');
        Job.Add('printerName', PrinterName);
        Job.Add('printJob', PrintJobBase64);
        _CapturedJobs.Add(Job);
    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    begin
        Error(_UnsupportedOutputLbl, 'FileLocal');
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    var
        Job: JsonObject;
    begin
        Job.Add('type', 'http');
        Job.Add('url', URL + Endpoint);
        Job.Add('printJob', PrintJobBase64);
        _CapturedJobs.Add(Job);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    begin
        Error(_UnsupportedOutputLbl, 'Bluetooth');
    end;

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    begin
        Error(_UnsupportedOutputLbl, 'PrintNode');
    end;

    internal procedure GetCapturedJobs(): JsonArray
    begin
        exit(_CapturedJobs);
    end;

    internal procedure HasCapturedJobs(): Boolean
    begin
        exit(_CapturedJobs.Count() > 0);
    end;

    internal procedure InitSelfReference(Handler: Interface "NPR IRetail Print Handler")
    begin
        _SelfAsHandler := Handler;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnResolveRetailPrintHandler', '', false, false)]
    local procedure OnResolveRetailPrintHandler(var Handler: Interface "NPR IRetail Print Handler")
    begin
        Handler := _SelfAsHandler;
    end;
}
#endif
