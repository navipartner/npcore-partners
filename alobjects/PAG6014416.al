page 6014416 "Pakke Foreign Shipment Mapping"
{
    // NPR5.51/BHR /20190719 CASE 362106 Pakkelabels Foreign shipment mapping

    Caption = 'Pakke Foreign Shipment Mapping';
    PageType = List;
    SourceTable = "Pakke Foreign Shipment Mapping";
    SourceTableView = SORTING("Country/Region Code", "Base Shipping Agent Code");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
                field("Base Shipping Agent Code"; "Base Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

