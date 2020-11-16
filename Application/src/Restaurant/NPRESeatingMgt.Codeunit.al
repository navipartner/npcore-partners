codeunit 6150662 "NPR NPRE Seating Mgt."
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO/20180412 CASE 309869 Added filter parameters to UILookUpSeating
    // NPR5.50/TJ  /20190502 CASE 346384 Setting additional filters for seating
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link (added functionality to get restaurant seating location filter)


    trigger OnRun()
    begin
    end;

    var
        AdditionalFiltersSet: Boolean;
        SeatingFiltersGlobal: Record "NPR NPRE Seating";
        InQuotes: Label '''%1''', Comment = '{Fixed}';
        EmptyCodeINQuotes: Label '''''', Comment = '{Fixed}';

    procedure GetSeatingDescription(SeatingCode: Code[20]) SeatingDescription: Text
    var
        Seating: Record "NPR NPRE Seating";
    begin
        SeatingDescription := '';
        Seating.Reset;
        Seating.SetRange(Code, SeatingCode);
        if not Seating.IsEmpty then begin
            Seating.FindFirst;
            SeatingDescription := Seating.Description;
        end;
    end;

    procedure UILookUpSeating(SeatingCodeFilter: Text; SeatingLocationFilter: Text) SeatingCode: Code[20]
    var
        Seating: Record "NPR NPRE Seating";
        SeatingList: Page "NPR NPRE Seating List";
    begin
        SeatingCode := '';

        Seating.Reset;
        //-NPR5.50 [346384]
        if AdditionalFiltersSet then
            Seating.CopyFilters(SeatingFiltersGlobal);
        //+NPR5.50 [346384]
        //-NPR5.41 [309869]
        if SeatingCodeFilter <> '' then
            Seating.SetFilter(Code, SeatingCodeFilter);
        if SeatingLocationFilter <> '' then
            Seating.SetFilter("Seating Location", SeatingLocationFilter);
        //+NPR5.41 [309869]
        SeatingList.SetTableView(Seating);
        SeatingList.LookupMode := true;
        if SeatingList.RunModal = ACTION::LookupOK then begin
            SeatingList.GetRecord(Seating);
            SeatingCode := Seating.Code;
        end
        //-NPR5.55 [399170]
        else
            Error('');
        //+NPR5.55 [399170]

        exit(SeatingCode);
    end;

    procedure SetAddSeatingFilters(var SeatingHere: Record "NPR NPRE Seating")
    begin
        //-NPR5.50 [346384]
        SeatingFiltersGlobal.CopyFilters(SeatingHere);
        AdditionalFiltersSet := true;
        //+NPR5.50 [346384]
    end;

    procedure TrySetSeatingIsCleared(SeatingCode: Code[10]; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        //-NPR5.55 [399170]
        SetupProxy.SetSeating(SeatingCode);
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        if ServiceFlowProfile."Seating Status after Clearing" = '' then
            exit;

        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange(Closed, false);
        if not SeatingWaiterPadLink.IsEmpty then
            exit;

        SetSeatingStatus(SeatingCode, ServiceFlowProfile."Seating Status after Clearing");
        //+NPR5.55 [399170]
    end;

    procedure SetSeatingIsOccupied(SeatingCode: Code[10])
    var
        RestSetup: Record "NPR NPRE Restaurant Setup";
    begin
        //-NPR5.55 [399170]
        if not RestSetup.Get or (RestSetup."Seat.Status: Occupied" = '') then
            exit;

        SetSeatingStatus(SeatingCode, RestSetup."Seat.Status: Occupied");
        //+NPR5.55 [399170]
    end;

    procedure SetSeatingStatus(SeatingCode: Code[20]; NewStatusCode: Code[10])
    var
        Seating: Record "NPR NPRE Seating";
        xSeating: Record "NPR NPRE Seating";
    begin
        //-NPR5.55 [399170]
        Seating.Get(SeatingCode);
        if Seating.Status = NewStatusCode then
            exit;

        xSeating := Seating;
        Seating.Status := NewStatusCode;
        OnAfterChangeSeatingStatus(xSeating, Seating);
        Seating.Modify;
        //+NPR5.55 [399170]
    end;

    procedure RestaurantSeatingLocationFilter(RestaurantCode: Code[20]): Text
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
        LocationFilter: Text;
    begin
        //-NPR5.55 [414938]
        if RestaurantCode = '' then
            exit('');
        LocationFilter := '';
        SeatingLocation.SetRange("Restaurant Code", RestaurantCode);
        if SeatingLocation.FindSet then
            repeat
                if LocationFilter <> '' then
                    LocationFilter := LocationFilter + '|';
                LocationFilter := LocationFilter + StrSubstNo(InQuotes, SeatingLocation.Code);
            until SeatingLocation.Next = 0;
        exit(LocationFilter);
        //+NPR5.55 [414938]
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterChangeSeatingStatus(xSeating: Record "NPR NPRE Seating"; var Seating: Record "NPR NPRE Seating")
    begin
        //NPR5.55 [399170]
    end;
}

