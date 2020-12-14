codeunit 6014548 "NPR RP Line Printer Interf."
{
    // Line Printer Interface.
    // 
    // This library is purely an interface between the
    // "Line Print Buffer Mgt." and the printing device. Nothing more.
    // 
    // Extend Construct(), Dispose() and GetDeviceList() for new device codeunits.
    // 
    // If you are wondering why not just use a handled pattern with static instead of manual subscribers:
    // these publishers can be called thousand of times within loops. This way there is the least overhead.
    // If NAV ever gets a proper inheritance feature then refactor this codeunit to use it instead.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Bound: Boolean;
        EpsonVCommandLibrary: Codeunit "NPR RP Epson V Device Lib.";
        BixolonDispCommandLibrary: Codeunit "NPR RP BixolonDisp Device Lib.";
        Error_NoHandler: Label 'No device handler found for ''%1''';
        RipacCommandLibrary: Codeunit "NPR RP Ripac Device Lib.";
        BocaCommandLibrary: Codeunit "NPR RP Boca FGL Device Lib.";
        EpsonVBound: Boolean;
        BixolonBound: Boolean;
        RipacBound: Boolean;
        BocaBound: Boolean;

    procedure Construct(PrinterDevice: Text)
    begin
        if Bound then
            Dispose();

        case true of
            EpsonVCommandLibrary.IsThisDevice(PrinterDevice):
                EpsonVBound := BindSubscription(EpsonVCommandLibrary);
            BixolonDispCommandLibrary.IsThisDevice(PrinterDevice):
                BixolonBound := BindSubscription(BixolonDispCommandLibrary);
            RipacCommandLibrary.IsThisDevice(PrinterDevice):
                RipacBound := BindSubscription(RipacCommandLibrary);
            BocaCommandLibrary.IsThisDevice(PrinterDevice):
                BocaBound := BindSubscription(BocaCommandLibrary);
            else
                Error(Error_NoHandler, PrinterDevice);
        end;

        Bound := true;
    end;

    procedure Dispose()
    var
        HasError: Boolean;
    begin
        if EpsonVBound then
            UnbindSubscription(EpsonVCommandLibrary);
        if BixolonBound then
            UnbindSubscription(BixolonDispCommandLibrary);
        if RipacBound then
            UnbindSubscription(RipacCommandLibrary);
        if BocaBound then
            UnbindSubscription(BocaCommandLibrary);

        ClearAll;
    end;

    procedure GetDeviceList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if Bound then
            Dispose();

        EpsonVBound := BindSubscription(EpsonVCommandLibrary);
        BixolonBound := BindSubscription(BixolonDispCommandLibrary);
        RipacBound := BindSubscription(RipacCommandLibrary);
        BocaBound := BindSubscription(BocaCommandLibrary);

        OnBuildDeviceList(tmpRetailList);

        Dispose();
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLineFeed()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnEndJob()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupFont(var LookupOK: Boolean; var Value: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupCommand(var LookupOK: Boolean; var Value: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupDeviceSetting(var LookupOK: Boolean; var tmpDeviceSetting: Record "NPR RP Device Settings" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetPageWidth(FontFace: Text[30]; var Width: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrepareJobForHTTP(var FormattedTargetEncoding: Text; var HTTPEndpoint: Text; var Supported: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrepareJobForBluetooth(var FormattedTargetEncoding: Text; var Supported: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetPrintBytes(var PrintBytes: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetPrintBytes(var PrintBytes: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBuildDeviceList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
    end;
}

