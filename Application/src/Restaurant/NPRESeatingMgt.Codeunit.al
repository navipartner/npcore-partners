codeunit 6150662 "NPR NPRE Seating Mgt."
{
    var
        AdditionalFiltersSet: Boolean;
        SeatingFiltersGlobal: Record "NPR NPRE Seating";
        InQuotes: Label '''%1''', Comment = '{Fixed}';

    procedure GetSeatingDescription(SeatingCode: Code[20]) SeatingDescription: Text
    var
        Seating: Record "NPR NPRE Seating";
    begin
        SeatingDescription := '';
        Seating.Reset();
        Seating.SetRange(Code, SeatingCode);
        if not Seating.IsEmpty then begin
            Seating.FindFirst();
            SeatingDescription := Seating.Description;
        end;
    end;

    procedure UILookUpSeating(SeatingCodeFilter: Text; SeatingLocationFilter: Text) SeatingCode: Code[20]
    var
        Seating: Record "NPR NPRE Seating";
        SeatingList: Page "NPR NPRE Seating List";
    begin
        SeatingCode := '';

        Seating.Reset();
        if AdditionalFiltersSet then
            Seating.CopyFilters(SeatingFiltersGlobal);
        if SeatingCodeFilter <> '' then
            Seating.SetFilter(Code, SeatingCodeFilter);
        if SeatingLocationFilter <> '' then
            Seating.SetFilter("Seating Location", SeatingLocationFilter);
        SeatingList.SetTableView(Seating);
        SeatingList.LookupMode := true;
        if SeatingList.RunModal() = ACTION::LookupOK then begin
            SeatingList.GetRecord(Seating);
            SeatingCode := Seating.Code;
        end else
            Error('');

        exit(SeatingCode);
    end;

    procedure SetAddSeatingFilters(var SeatingHere: Record "NPR NPRE Seating")
    begin
        SeatingFiltersGlobal.CopyFilters(SeatingHere);
        AdditionalFiltersSet := true;
    end;

    procedure TrySetSeatingIsCleared(SeatingCode: Code[20]; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        SetupProxy.SetSeating(SeatingCode);
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        if ServiceFlowProfile."Seating Status after Clearing" = '' then
            exit;

        SeatingWaiterPadLink.SetCurrentKey(Closed);
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange(Closed, false);
        if not SeatingWaiterPadLink.IsEmpty then
            exit;

        SetSeatingStatus(SeatingCode, ServiceFlowProfile."Seating Status after Clearing");
    end;

    procedure SetSeatingIsReady(SeatingCode: Code[20])
    var
        RestSetup: Record "NPR NPRE Restaurant Setup";
    begin
        if not RestSetup.Get() or (RestSetup."Seat.Status: Ready" = '') then
            exit;

        SetSeatingStatus(SeatingCode, RestSetup."Seat.Status: Ready");
    end;

    procedure SetSeatingIsOccupied(SeatingCode: Code[20])
    var
        RestSetup: Record "NPR NPRE Restaurant Setup";
    begin
        if not RestSetup.Get() or (RestSetup."Seat.Status: Occupied" = '') then
            exit;

        SetSeatingStatus(SeatingCode, RestSetup."Seat.Status: Occupied");
    end;

    procedure SetSeatingStatus(SeatingCode: Code[20]; NewStatusCode: Code[10])
    var
        Seating: Record "NPR NPRE Seating";
        xSeating: Record "NPR NPRE Seating";
    begin
        Seating.Get(SeatingCode);
        if Seating.Status = NewStatusCode then
            exit;

        xSeating := Seating;
        Seating.Status := NewStatusCode;
        OnAfterChangeSeatingStatus(xSeating, Seating);
        Seating.Modify();
    end;

    procedure RestaurantSeatingLocationFilter(RestaurantCode: Code[20]): Text
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
        LocationFilter: Text;
    begin
        if RestaurantCode = '' then
            exit('');
        LocationFilter := '';
        SeatingLocation.SetRange("Restaurant Code", RestaurantCode);
        if SeatingLocation.FindSet() then
            repeat
                if LocationFilter <> '' then
                    LocationFilter := LocationFilter + '|';
                LocationFilter := LocationFilter + StrSubstNo(InQuotes, SeatingLocation.Code);
            until SeatingLocation.Next() = 0;
        exit(LocationFilter);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterChangeSeatingStatus(xSeating: Record "NPR NPRE Seating"; var Seating: Record "NPR NPRE Seating")
    begin
    end;
}