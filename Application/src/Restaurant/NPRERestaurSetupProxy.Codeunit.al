codeunit 6150675 "NPR NPRE Restaur. Setup Proxy"
{
    // The purpose of this codeunit is to abstract retrieval of setup.
    var
        NPRESetup: Record "NPR NPRE Restaurant Setup";
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Initialized: Boolean;
        NPRESetupRead: Boolean;

    procedure SetRestaurant(NewRestaurantCode: Code[20])
    begin
        if NewRestaurantCode = Restaurant.Code then
            exit;
        if NewRestaurantCode <> '' then
            Restaurant.Get(NewRestaurantCode)
        else
            Clear(Restaurant);
        Clear(SeatingLocation);
        Initialized := false;
    end;

    procedure SetSeating(NewSeatingCode: Code[20])
    begin
        if NewSeatingCode = Seating.Code then
            exit;
        if NewSeatingCode <> '' then begin
            Seating.Get(NewSeatingCode);
            SetSeatingLocation(Seating."Seating Location");
        end else
            InitializeDefault();
    end;

    procedure SetSeatingLocation(NewSeatingLocation: Code[10])
    begin
        if NewSeatingLocation = SeatingLocation.Code then
            exit;
        if NewSeatingLocation <> '' then begin
            SeatingLocation.Get(NewSeatingLocation);
            if SeatingLocation."Restaurant Code" <> '' then
                Restaurant.Get(SeatingLocation."Restaurant Code")
            else
                Clear(Restaurant);
        end else
            Clear(SeatingLocation);
        if Seating."Seating Location" <> SeatingLocation.Code then
            Clear(Seating);
        Initialized := false;
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

        if Restaurant."Auto Send Kitchen Order" = Restaurant."Auto Send Kitchen Order"::Default then
            Restaurant."Auto Send Kitchen Order" := NPRESetup."Auto Send Kitchen Order" + 1;
        if SeatingLocation."Auto Send Kitchen Order" = SeatingLocation."Auto Send Kitchen Order"::Default then
            SeatingLocation."Auto Send Kitchen Order" := Restaurant."Auto Send Kitchen Order";

        if Restaurant."Resend All On New Lines" = Restaurant."Resend All On New Lines"::Default then
            Restaurant."Resend All On New Lines" := NPRESetup."Resend All On New Lines" + 1;
        if SeatingLocation."Resend All On New Lines" = SeatingLocation."Resend All On New Lines"::Default then
            SeatingLocation."Resend All On New Lines" := Restaurant."Resend All On New Lines";

        if Restaurant."Kitchen Printing Active" = Restaurant."Kitchen Printing Active"::Default then
            if NPRESetup."Kitchen Printing Active" then
                Restaurant."Kitchen Printing Active" := Restaurant."Kitchen Printing Active"::Yes
            else
                Restaurant."Kitchen Printing Active" := Restaurant."Kitchen Printing Active"::No;

        if Restaurant."KDS Active" = Restaurant."KDS Active"::Default then
            if NPRESetup."KDS Active" then
                Restaurant."KDS Active" := Restaurant."KDS Active"::Yes
            else
                Restaurant."KDS Active" := Restaurant."KDS Active"::No;

        if Restaurant."Order ID Assign. Method" = Restaurant."Order ID Assign. Method"::Default then
            Restaurant."Order ID Assign. Method" := NPRESetup."Order ID Assign. Method" + 1;

        if Restaurant."Service Flow Profile" = '' then
            Restaurant."Service Flow Profile" := NPRESetup."Default Service Flow Profile";

        Initialized := true;
    end;

    local procedure MakeSureIsInitialized()
    begin
        if not Initialized then
            InitializeSetup();
    end;

    local procedure GetNPRESetup()
    begin
        if NPRESetupRead then
            exit;
        if not NPRESetup.Get() then
            NPRESetup.Init();
        NPRESetupRead := true;
    end;

    procedure AutoSendKitchenOrder(): Integer
    begin
        MakeSureIsInitialized();
        exit(SeatingLocation."Auto Send Kitchen Order");
    end;

    procedure ResendAllOnNewLines(): Integer
    begin
        MakeSureIsInitialized();
        exit(SeatingLocation."Resend All On New Lines");
    end;

    procedure KitchenPrintingActivated(): Boolean
    begin
        MakeSureIsInitialized();
        exit(Restaurant."Kitchen Printing Active" = Restaurant."Kitchen Printing Active"::Yes);
    end;

    procedure KDSActivated(): Boolean
    begin
        MakeSureIsInitialized();
        exit(Restaurant."KDS Active" = Restaurant."KDS Active"::Yes);
    end;

    procedure OrderIDAssignmentMethod(): Integer
    begin
        MakeSureIsInitialized();
        exit(Restaurant."Order ID Assign. Method");
    end;

    procedure GetServiceFlowProfile(var ServiceFlowProfileOut: Record "NPR NPRE Serv.Flow Profile")
    begin
        MakeSureIsInitialized();
        if not ServiceFlowProfileOut.Get(Restaurant."Service Flow Profile") then
            Clear(ServiceFlowProfileOut);
    end;

    procedure ServingStepDiscoveryMethod(): Integer
    begin
        GetNPRESetup();
        exit(NPRESetup."Serving Step Discovery Method");
    end;
}