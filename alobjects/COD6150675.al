codeunit 6150675 "NPRE Restaurant Setup Proxy"
{
    // The purpose of this codeunit is to abstract retrieval of setup.
    // 
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant


    trigger OnRun()
    begin
    end;

    var
        HospitalitySetup: Record "NPRE Restaurant Setup";
        Restaurant: Record "NPRE Restaurant";
        SeatingLocation: Record "NPRE Seating Location";
        Initialized: Boolean;

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
        Initialized := false;
    end;

    procedure InitializeUsingWaiterPad(var WaiterPad: Record "NPRE Waiter Pad")
    var
        Seating: Record "NPRE Seating";
    begin
        WaiterPad.CalcFields("Current Seating FF");
        if not Seating.Get(WaiterPad."Current Seating FF") then
          Seating.Init;
        SetSeatingLocation(Seating."Seating Location");
    end;

    procedure InitializeDefault()
    begin
        ClearAll;
    end;

    local procedure InitializeSetup()
    begin
        if not HospitalitySetup.Get then
          HospitalitySetup.Init;

        if Restaurant."Auto Send Kitchen Order" = Restaurant."Auto Send Kitchen Order"::Default then
          Restaurant."Auto Send Kitchen Order" := HospitalitySetup."Auto Send Kitchen Order" + 1;
        if SeatingLocation."Auto Send Kitchen Order" = SeatingLocation."Auto Send Kitchen Order"::Default then
          SeatingLocation."Auto Send Kitchen Order" := Restaurant."Auto Send Kitchen Order";

        if Restaurant."Resend All On New Lines" = Restaurant."Resend All On New Lines"::Default then
          Restaurant."Resend All On New Lines" := HospitalitySetup."Resend All On New Lines" + 1;
        if SeatingLocation."Resend All On New Lines" = SeatingLocation."Resend All On New Lines"::Default then
          SeatingLocation."Resend All On New Lines" := Restaurant."Resend All On New Lines";

        if Restaurant."Kitchen Printing Active" = Restaurant."Kitchen Printing Active"::Default then
          if HospitalitySetup."Kitchen Printing Active" then
            Restaurant."Kitchen Printing Active" := Restaurant."Kitchen Printing Active"::Yes
          else
            Restaurant."Kitchen Printing Active" := Restaurant."Kitchen Printing Active"::No;

        if Restaurant."KDS Active" = Restaurant."KDS Active"::Default then
          if HospitalitySetup."KDS Active" then
            Restaurant."KDS Active" := Restaurant."KDS Active"::Yes
          else
            Restaurant."KDS Active" := Restaurant."KDS Active"::No;

        if Restaurant."Order ID Assign. Method" = Restaurant."Order ID Assign. Method"::Default then
          Restaurant."Order ID Assign. Method" := HospitalitySetup."Order ID Assign. Method" + 1;

        Initialized := true;
    end;

    local procedure MakeSureIsInitialized()
    begin
        if not Initialized then
          InitializeSetup;
    end;

    procedure AutoSendKitchenOrder(): Integer
    begin
        MakeSureIsInitialized;
        exit(SeatingLocation."Auto Send Kitchen Order");
    end;

    procedure ResendAllOnNewLines(): Integer
    begin
        MakeSureIsInitialized;
        exit(SeatingLocation."Resend All On New Lines");
    end;

    procedure KitchenPrintingActivated(): Boolean
    begin
        MakeSureIsInitialized;
        exit(Restaurant."Kitchen Printing Active" = Restaurant."Kitchen Printing Active"::Yes);
    end;

    procedure KDSActivated(): Boolean
    begin
        MakeSureIsInitialized;
        exit(Restaurant."KDS Active" = Restaurant."KDS Active"::Yes);
    end;

    procedure OrderIDAssignmentMethod(): Integer
    begin
        MakeSureIsInitialized;
        exit(Restaurant."Order ID Assign. Method");
    end;
}

