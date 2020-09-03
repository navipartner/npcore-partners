codeunit 6014546 "NPR RP Matrix Printer Interf."
{
    // Matrix Printer Interface.
    // 
    // This library is purely an interface between the
    // "Matrix Print Mgt." and the printing device. Nothing more.
    // 
    // Extend Construct(), Dispose() and GetDeviceList() for new device codeunits.
    // 
    // If you are wondering why not just use a handled pattern with static instead of manual subscribers:
    // these publishers can be called thousand of times within loops. This way there is the least overhead.
    // If NAV ever gets a proper inheritance feature then refactor this codeunit to use it instead.
    // 
    // NPR5.32/MMV /20160603 CASE 241995 Retail Print 2.0
    // NPR5.32.10/MMV /20170613 CASE  270885 Only unbind bound device libraries in dispose(). This is necessary as of NAV 2016 CU16 as UNBINDSUBSCRIPTION has a bug: Even when return value is handled it still
    //                                    overwrites GETLASTERRORTEXT which breaks an assumption made in another NPR module.
    // NPR5.34/MMV /20170724 CASE 284505 Fixed non-robust dispose() unbinds.
    //                                   Added missing bind variables to GetDeviceList().

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Bound: Boolean;
        BlasterCLPCommandLibrary: Codeunit "NPR RP Blaster CPL Device Lib.";
        CitizenCLPCommandLibrary: Codeunit "NPR RP Citizen CLP Device Lib.";
        ZebraZPLCommandLibrary: Codeunit "NPR RP Zebra ZPL Device Lib.";
        EpsonLabelCommandLibrary: Codeunit "NPR RP Epson Label Device Lib.";
        Error_NoHandler: Label 'No device handler found for ''%1''';
        BlasterBound: Boolean;
        CitizenBound: Boolean;
        ZebraBound: Boolean;
        EpsonBound: Boolean;

    procedure Construct(PrinterDevice: Text)
    begin
        if Bound then
            Dispose();

        case true of
            BlasterCLPCommandLibrary.IsThisDevice(PrinterDevice):
                BlasterBound := BindSubscription(BlasterCLPCommandLibrary);
            CitizenCLPCommandLibrary.IsThisDevice(PrinterDevice):
                CitizenBound := BindSubscription(CitizenCLPCommandLibrary);
            ZebraZPLCommandLibrary.IsThisDevice(PrinterDevice):
                ZebraBound := BindSubscription(ZebraZPLCommandLibrary);
            EpsonLabelCommandLibrary.IsThisDevice(PrinterDevice):
                EpsonBound := BindSubscription(EpsonLabelCommandLibrary);
            else
                Error(Error_NoHandler, PrinterDevice);
        end;

        Bound := true;
    end;

    procedure Dispose()
    begin
        //-NPR5.34 [284505]
        // CASE TRUE OF
        //  BlasterBound : UNBINDSUBSCRIPTION(BlasterCLPCommandLibrary);
        //  CitizenBound : UNBINDSUBSCRIPTION(CitizenCLPCommandLibrary);
        //  ZebraBound : UNBINDSUBSCRIPTION(ZebraZPLCommandLibrary);
        //  EpsonBound : UNBINDSUBSCRIPTION(EpsonLabelCommandLibrary);
        // END;
        if BlasterBound then
            UnbindSubscription(BlasterCLPCommandLibrary);
        if CitizenBound then
            UnbindSubscription(CitizenCLPCommandLibrary);
        if ZebraBound then
            UnbindSubscription(ZebraZPLCommandLibrary);
        if EpsonBound then
            UnbindSubscription(EpsonLabelCommandLibrary);
        //-NPR5.34 [284505]

        ClearAll;
    end;

    procedure GetDeviceList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if Bound then
            Dispose();

        //-NPR5.34 [284505]
        // BINDSUBSCRIPTION(BlasterCLPCommandLibrary);
        // BINDSUBSCRIPTION(CitizenCLPCommandLibrary);
        // BINDSUBSCRIPTION(ZebraZPLCommandLibrary);
        // BINDSUBSCRIPTION(EpsonLabelCommandLibrary);
        BlasterBound := BindSubscription(BlasterCLPCommandLibrary);
        CitizenBound := BindSubscription(CitizenCLPCommandLibrary);
        ZebraBound := BindSubscription(ZebraZPLCommandLibrary);
        EpsonBound := BindSubscription(EpsonLabelCommandLibrary);
        //+NPR5.34 [284505]

        OnBuildDeviceList(tmpRetailList);

        Dispose();
    end;

    local procedure "// Print Job"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitJob(var DeviceSettings: Record "NPR RP Device Settings")
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

    local procedure "// Aux"()
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

