codeunit 6014548 "RP Line Printer Interface"
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
    // 
    // NPR5.32/MMV /20160603 CASE 241995 Retail Print 2.0
    // NPR5.32.10/MMV /20170613 CASE  270885 Only unbind bound device libraries in dispose(). This is necessary as of NAV 2016 CU16 as UNBINDSUBSCRIPTION has a bug: Even when return value is handled it still
    //                                    overwrites GETLASTERRORTEXT which breaks an assumption made in another NPR module.
    // NPR5.34/MMV /20170724 CASE 284505 Fixed non-robust dispose() unbinds.
    //                                   Added missing bind variables to GetDeviceList().
    // NPR5.34.02/MMV /20170816 CASE 287060 Fixed invalid unbound call.
    // NPR5.37/MMV /20171002 CASE 269767 Added ripac device library.
    // NPR5.54/MITH/20200129 CASE 369235 Added Boca Device Library.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Bound: Boolean;
        EpsonVCommandLibrary: Codeunit "RP Epson V Device Library";
        BixolonDispCommandLibrary: Codeunit "RP Bixolon Disp. Device Lib.";
        Error_NoHandler: Label 'No device handler found for ''%1''';
        RipacCommandLibrary: Codeunit "RP Ripac Device Library";
        BocaCommandLibrary: Codeunit "RP Boca FGL Device Library";
        EpsonVBound: Boolean;
        BixolonBound: Boolean;
        RipacBound: Boolean;
        BocaBound: Boolean;

    procedure Construct(PrinterDevice: Text)
    begin
        if Bound then
          Dispose();

        case true of
          EpsonVCommandLibrary.IsThisDevice(PrinterDevice) : EpsonVBound := BindSubscription(EpsonVCommandLibrary);
          BixolonDispCommandLibrary.IsThisDevice(PrinterDevice) : BixolonBound := BindSubscription(BixolonDispCommandLibrary);
          //-NPR5.37 [269767]
          RipacCommandLibrary.IsThisDevice(PrinterDevice) : RipacBound := BindSubscription(RipacCommandLibrary);
          //+NPR5.37 [269767]
          //-NPR5.54
          BocaCommandLibrary.IsThisDevice(PrinterDevice) : BocaBound := BindSubscription(BocaCommandLibrary);
          //+NPR5.54
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
        //-NPR5.37 [269767]
        if RipacBound then
          UnbindSubscription(RipacCommandLibrary);
        //+NPR5.37 [269767]
        //-NPR5.54
        if BocaBound then
          UnbindSubscription(BocaCommandLibrary);
        //+NPR5.54

        ClearAll;
    end;

    procedure GetDeviceList(var tmpRetailList: Record "Retail List" temporary)
    begin
        if Bound then
          Dispose();

        EpsonVBound := BindSubscription(EpsonVCommandLibrary);
        BixolonBound := BindSubscription(BixolonDispCommandLibrary);
        //-NPR5.37 [269767]
        RipacBound := BindSubscription(RipacCommandLibrary);
        //+NPR5.37 [269767]
        //-NPR5.54
        BocaBound := BindSubscription(BocaCommandLibrary);
        //+NPR5.54

        OnBuildDeviceList(tmpRetailList);

        Dispose();
    end;

    local procedure "// Create Job"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitJob(var DeviceSettings: Record "RP Device Settings")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLineFeed()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrintData(var POSPrintBuffer: Record "RP Print Buffer" temporary)
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
    procedure OnLookupFont(var LookupOK: Boolean;var Value: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupCommand(var LookupOK: Boolean;var Value: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupDeviceSetting(var LookupOK: Boolean;var tmpDeviceSetting: Record "RP Device Settings" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetPageWidth(FontFace: Text[30];var Width: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrepareJobForHTTP(var FormattedTargetEncoding: Text;var HTTPEndpoint: Text;var Supported: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrepareJobForBluetooth(var FormattedTargetEncoding: Text;var Supported: Boolean)
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
    procedure OnBuildDeviceList(var tmpRetailList: Record "Retail List" temporary)
    begin
    end;
}

