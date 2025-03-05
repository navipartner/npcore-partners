codeunit 6150675 "NPR NPRE Restaur. Setup Proxy"
{
    Access = Internal;
    // The purpose of this codeunit is to abstract retrieval of setup.
    var
        _NPRESetup: Record "NPR NPRE Restaurant Setup";
        _Restaurant: Record "NPR NPRE Restaurant";
        _Seating: Record "NPR NPRE Seating";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _Initialized: Boolean;
        _NPRESetupRead: Boolean;

    procedure SetRestaurant(NewRestaurantCode: Code[20])
    begin
        if NewRestaurantCode = _Restaurant.Code then
            exit;
        if NewRestaurantCode <> '' then
            _Restaurant.Get(NewRestaurantCode)
        else
            Clear(_Restaurant);
        Clear(_SeatingLocation);
        _Initialized := false;
    end;

    procedure SetSeating(NewSeatingCode: Code[20])
    begin
        if NewSeatingCode = _Seating.Code then
            exit;
        if NewSeatingCode <> '' then begin
            _Seating.Get(NewSeatingCode);
            SetSeatingLocation(_Seating."Seating Location");
        end else
            InitializeDefault();
    end;

    procedure SetSeatingLocation(NewSeatingLocation: Code[10])
    begin
        if NewSeatingLocation = _SeatingLocation.Code then
            exit;
        if NewSeatingLocation <> '' then begin
            _SeatingLocation.Get(NewSeatingLocation);
            if _SeatingLocation."Restaurant Code" <> '' then
                _Restaurant.Get(_SeatingLocation."Restaurant Code")
            else
                Clear(_Restaurant);
        end else
            Clear(_SeatingLocation);
        if _Seating."Seating Location" <> _SeatingLocation.Code then
            Clear(_Seating);
        _Initialized := false;
    end;

    procedure InitializeUsingWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPad.CalcFields("Current Seating FF");
        SetSeating(WaiterPad."Current Seating FF");
    end;

    procedure InitializeDefault()
    begin
        ClearAll();
    end;

    local procedure InitializeSetup()
    begin
        GetNPRESetup();

        if _Restaurant."Auto Send Kitchen Order" = _Restaurant."Auto Send Kitchen Order"::Default then
            _Restaurant."Auto Send Kitchen Order" := _NPRESetup."Auto-Send Kitchen Order";
        if _SeatingLocation."Auto Send Kitchen Order" = _SeatingLocation."Auto Send Kitchen Order"::Default then
            _SeatingLocation."Auto Send Kitchen Order" := _Restaurant."Auto Send Kitchen Order";

        if _Restaurant."Resend All On New Lines" = _Restaurant."Resend All On New Lines"::Default then
            _Restaurant."Resend All On New Lines" := _NPRESetup."Re-send All on New Lines";
        if _SeatingLocation."Resend All On New Lines" = _SeatingLocation."Resend All On New Lines"::Default then
            _SeatingLocation."Resend All On New Lines" := _Restaurant."Resend All On New Lines";

        if _Restaurant."Default Number of Guests" = _Restaurant."Default Number of Guests"::Default then
            _Restaurant."Default Number of Guests" := _NPRESetup."Default Number of Guests";
        if _SeatingLocation."Default Number of Guests" = _SeatingLocation."Default Number of Guests"::Default then
            _SeatingLocation."Default Number of Guests" := _Restaurant."Default Number of Guests";

        if _Restaurant."Kitchen Printing Active" = _Restaurant."Kitchen Printing Active"::Default then
            if _NPRESetup."Kitchen Printing Active" then
                _Restaurant."Kitchen Printing Active" := _Restaurant."Kitchen Printing Active"::Yes
            else
                _Restaurant."Kitchen Printing Active" := _Restaurant."Kitchen Printing Active"::No;

        if _Restaurant."Print on POS Sale Cancel" = _Restaurant."Print on POS Sale Cancel"::Default then
            if _NPRESetup."Print on POS Sale Cancel" then
                _Restaurant."Print on POS Sale Cancel" := _Restaurant."Print on POS Sale Cancel"::Yes
            else
                _Restaurant."Print on POS Sale Cancel" := _Restaurant."Print on POS Sale Cancel"::No;

        if _Restaurant."KDS Active" = _Restaurant."KDS Active"::Default then
            if _NPRESetup."KDS Active" then
                _Restaurant."KDS Active" := _Restaurant."KDS Active"::Yes
            else
                _Restaurant."KDS Active" := _Restaurant."KDS Active"::No;

        if _Restaurant."Order ID Assign. Method" = _Restaurant."Order ID Assign. Method"::Default then
            _Restaurant."Order ID Assign. Method" := _NPRESetup."Order ID Assignment Method";

        if _Restaurant."Service Flow Profile" = '' then
            _Restaurant."Service Flow Profile" := _NPRESetup."Default Service Flow Profile";

        if _Restaurant."Station Req. Handl. On Serving" = _Restaurant."Station Req. Handl. On Serving"::Default then
            _Restaurant."Station Req. Handl. On Serving" := _NPRESetup."Kitchen Req. Handl. On Serving";

        if _Restaurant."Order Is Ready For Serving" = _Restaurant."Order Is Ready For Serving"::Default then
            _Restaurant."Order Is Ready For Serving" := _NPRESetup."Order Is Ready For Serving";

        _Initialized := true;
    end;

    local procedure MakeSureIsInitialized()
    begin
        if not _Initialized then
            InitializeSetup();
    end;

    local procedure GetNPRESetup()
    begin
        if _NPRESetupRead then
            exit;
        if not _NPRESetup.Get() then
            _NPRESetup.Init();
        _NPRESetupRead := true;
    end;

    procedure AutoSendKitchenOrder(): Enum "NPR NPRE Auto Send Kitch.Order"
    begin
        MakeSureIsInitialized();
        exit(_SeatingLocation."Auto Send Kitchen Order");
    end;

    procedure ResendAllOnNewLines(): Enum "NPR NPRE Send All on New Lines"
    begin
        MakeSureIsInitialized();
        exit(_SeatingLocation."Resend All On New Lines");
    end;

    procedure DefaultNumberOfGuests(): Enum "NPR NPRE Default No. of Guests"
    begin
        MakeSureIsInitialized();
        exit(_SeatingLocation."Default Number of Guests");
    end;

    procedure KitchenPrintingActivated(): Boolean
    begin
        MakeSureIsInitialized();
        exit(_Restaurant."Kitchen Printing Active" = _Restaurant."Kitchen Printing Active"::Yes);
    end;

    procedure PrintOnSaleCancelActivated(): Boolean
    begin
        MakeSureIsInitialized();
        exit(_Restaurant."Print on POS Sale Cancel" = _Restaurant."Print on POS Sale Cancel"::Yes);
    end;

    procedure KDSActivated(): Boolean
    begin
        MakeSureIsInitialized();
        exit(_Restaurant."KDS Active" = _Restaurant."KDS Active"::Yes);
    end;

    procedure KDSActivatedForAnyRestaurant(): Boolean
    var
        Restaurant: Record "NPR NPRE Restaurant";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        if Restaurant.IsEmpty() then
            exit(RestaurantSetup.Get() and RestaurantSetup."KDS Active");

        Restaurant.SetRange("KDS Active", Restaurant."KDS Active"::Yes);
        if not Restaurant.IsEmpty() then
            exit(true);

        Restaurant.SetRange("KDS Active", Restaurant."KDS Active"::Default);
        exit(RestaurantSetup.Get() and RestaurantSetup."KDS Active" and not Restaurant.IsEmpty());
    end;

    procedure OrderIDAssignmentMethod(): Enum "NPR NPRE Ord.ID Assign. Method"
    begin
        MakeSureIsInitialized();
        exit(_Restaurant."Order ID Assign. Method");
    end;

    procedure GetServiceFlowProfile(var ServiceFlowProfileOut: Record "NPR NPRE Serv.Flow Profile")
    begin
        MakeSureIsInitialized();
        if not ServiceFlowProfileOut.Get(_Restaurant."Service Flow Profile") then
            Clear(ServiceFlowProfileOut);
    end;

    procedure ServingStepDiscoveryMethod(): Enum "NPR NPRE Serv.Step Discovery"
    begin
        GetNPRESetup();
        exit(_NPRESetup."Serving Step Discovery Method");
    end;

    procedure StationReqHandlingOnServing(): Enum "NPR NPRE Req.Handl.on Serving"
    begin
        MakeSureIsInitialized();
        exit(_Restaurant."Station Req. Handl. On Serving");
    end;

    procedure KitchenOrderIsReadyForServingOn(): Enum "NPR NPRE Order Ready Serving"
    begin
        MakeSureIsInitialized();
        exit(_Restaurant."Order Is Ready For Serving");
    end;

    procedure GetRestaurantList(var TempRestaurant: Record "NPR NPRE Restaurant")
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        if not TempRestaurant.IsTemporary() then
            ThrowNonTempException('CU6150675.GetRestaurantList');
        if not TempRestaurant.IsEmpty() then
            exit;
        if Restaurant.IsEmpty() then begin
            TempRestaurant.Init();
            TempRestaurant.Code := '';
            TempRestaurant.Insert();
            exit;
        end;
        Restaurant.FindSet();
        repeat
            TempRestaurant := Restaurant;
            TempRestaurant.Insert();
        until Restaurant.Next() = 0;
    end;

    procedure ThrowNonTempException(CallerName: Text)
    var
        MustBeTempMsg: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        Error(MustBeTempMsg, CallerName);
    end;

    procedure GetRestaurantLayoutType(): Enum "NPR NPRE Restaur. Layout Type"
    begin
        GetNPRESetup();
        exit(_NPRESetup."Restaurant View Layout");
    end;

    #region Microsoft Entra application
    internal procedure CreateAzureADApplication()
    var
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        PermissionSets: List of [Code[20]];
        AppDisplayNameLbl: Label 'NaviPartner KDS', MaxLength = 50, Locked = true;
    begin
        PermissionSets.Add('NPR KDS WebService');
        AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayNameLbl, SecretDisplayName(), PermissionSets);
    end;

    internal procedure CreateAzureADApplicationSecret()
    var
        AppInfo: ModuleInfo;
        AADApplication: Record "AAD Application";
        AADApplicationList: Page "AAD Application List";
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        NoAppsToManageErr: Label 'No Micrsoft Entra Applications with App Name like %1 to manage.';
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        AADApplication.SetFilter("App Name", '@' + AppInfo.Name);
        if AADApplication.IsEmpty() then
            Error(NoAppsToManageErr, AppInfo.Name);

        AADApplicationList.LookupMode(true);
        AADApplicationList.SetTableView(AADApplication);
        if AADApplicationList.RunModal() <> Action::LookupOK then
            exit;

        AADApplicationList.GetRecord(AADApplication);
        AADApplicationMgt.CreateAzureADSecret(AADApplication."Client Id", SecretDisplayName());
    end;

    local procedure SecretDisplayName(): Text
    var
        SecretDisplayNameLbl: Label 'NaviPartner KDS - %1', Comment = '%1 = today’s date', Locked = true;
    begin
        exit(StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
    end;
    #endregion
}
