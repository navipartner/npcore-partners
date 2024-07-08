codeunit 6060112 "NPR POS Action: Change Loc-B"
{
    Access = Internal;

    procedure ChangeLocation(SaleLine: codeunit "NPR POS Sale Line"; DefaultLocation: Code[10])
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Location: Record Location;
        Locations: Page "Location List";
    begin
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        IF DefaultLocation = '' THEN begin
            Location.SetRange("Use As In-Transit", false);
            Locations.Editable(false);
            Locations.LookupMode(true);
            Locations.SetTableView(Location);
            if Locations.RunModal() <> ACTION::LookupOK then
                exit;
            Locations.GetRecord(Location);
        end else
            Location.Get(DefaultLocation);

        if SaleLinePOS."Location Code" = Location.Code then
            exit;

        SaleLine.SetLocation(Location.Code);
    end;
}
