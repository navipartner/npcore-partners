#if not (BC17 or BC18)
codeunit 6151081 "NPR Def. Retail Print Handler" implements "NPR IRetail Print Handler"
{
    Access = Internal;

    var
        _PrintMethodMgt: Codeunit "NPR Print Method Mgt.";

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    begin
        _PrintMethodMgt.PrintBytesLocal(PrinterName, PrintJobBase64);
    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    begin
        _PrintMethodMgt.PrintFileLocal(PrinterName, Stream, FileExtension);
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    begin
        _PrintMethodMgt.PrintBytesHTTP(URL, Endpoint, PrintJobBase64);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    begin
        _PrintMethodMgt.PrintBytesBluetooth(DeviceName, PrintJobBase64);
    end;

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    begin
        _PrintMethodMgt.PrintViaPrintNodeRaw(PrinterID, PrintJobBase64, ObjectType, ObjectID);
    end;
}
#endif
