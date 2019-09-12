page 6014416 "Pakke Foreign Shipment Mapping"
{
    // NPR5.51/BHR /20190719 CASE 362106 Pakkelabels Foreign shipment mapping

    Caption = 'Pakke Foreign Shipment Mapping';
    PageType = List;
    SourceTable = "Pakke Foreign Shipment Mapping";
    SourceTableView = SORTING("Country/Region Code","Base Shipping Agent Code");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Shipment Method Code";"Shipment Method Code")
                {
                }
                field("Shipping Agent Code";"Shipping Agent Code")
                {
                }
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field("Shipping Agent Service Code";"Shipping Agent Service Code")
                {
                }
                field("Base Shipping Agent Code";"Base Shipping Agent Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

