page 6014416 "NPR Pakke Foreign Shipm. Map."
{
    // NPR5.51/BHR /20190719 CASE 362106 Pakkelabels Foreign shipment mapping

    Caption = 'Pakke Foreign Shipment Mapping';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Pakke Foreign Shipm. Map.";
    SourceTableView = SORTING("Country/Region Code", "Base Shipping Agent Code");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Country/Region Code field';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field("Base Shipping Agent Code"; Rec."Base Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
            }
        }
    }

    actions
    {
    }
}

