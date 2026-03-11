#if not (BC17 or BC18)
interface "NPR IRetail Print Handler"
{
    Access = Internal;

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
}
#endif
