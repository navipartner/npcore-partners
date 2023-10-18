page 6151284 "NPR DS Ext.Fld. Location Setup"
{
    Extensible = False;
    Caption = 'POS DS Exten.Field Parameters';
    InstructionalText = 'Please specify additional parameters for the POS data source extension field.';
    PageType = ConfirmationDialog;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field(LocationFrom; LocationFrom)
            {
                Caption = 'Location From';
                ToolTip = 'Specifies the source for location filter.';
                ApplicationArea = NPRRetail;
            }
            field(LocationFilter; LocationFilter)
            {
                Caption = 'Location Filter';
                ToolTip = 'Specifies the location filter string, if "Location From" is set to value "Location Filter".';
                ApplicationArea = NPRRetail;
                Enabled = LocationFrom = LocationFrom::LocationFilter;

                trigger OnValidate()
                begin
                    if LocationFilter <> '' then
                        LocationFrom := LocationFrom::LocationFilter;
                end;

                trigger OnLookup(var Text: Text): Boolean
                var
                    Location: Record Location;
                    LocationList: Page "Location List";
                begin
                    Clear(LocationList);
                    Location.SetRange("Use As In-Transit", false);
                    LocationList.SetTableView(Location);
                    LocationList.LookupMode(true);
                    if LocationList.RunModal() = Action::LookupOK then begin
                        Text := LocationList.GetSelectionFilter();
                        exit(true);
                    end;
                    exit(false);
                end;
            }
        }
    }

    var
        LocationFrom: Enum "NPR Location Filter From";
        LocationFilter: Text;

    procedure SetLocationFilterParamValues(LocationFromIn: Enum "NPR Location Filter From"; LocationFilterIn: Text)
    begin
        LocationFrom := LocationFromIn;
        LocationFilter := LocationFilterIn;
    end;

    procedure GetLocationFilterParamValues(var LocationFromOut: Enum "NPR Location Filter From"; var LocationFilterOut: Text)
    begin
        LocationFromOut := LocationFrom;
        LocationFilterOut := LocationFilter;
    end;
}