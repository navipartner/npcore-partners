interface "NPR ILine Printer"
{
#if not BC17
    Access = Internal;
#endif

    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    procedure LineFeed()
    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    procedure EndJob()
    procedure LookupFont(var Value: Text): Boolean
    procedure LookupCommand(var Value: Text): Boolean
    procedure LookupDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean
    procedure GetPageWidth(FontFace: Text[30]): Integer
    procedure PrepareJobForHTTP(var HTTPEndpoint: Text): Boolean
    procedure PrepareJobForBluetooth(): Boolean
    procedure GetPrintBufferAsBase64(): Text
}