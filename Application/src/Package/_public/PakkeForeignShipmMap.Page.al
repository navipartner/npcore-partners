page 6014416 "NPR Pakke Foreign Shipm. Map."
{
    Extensible = true;

    Caption = 'NPR Package Foreign Countries';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Package Foreign Countries";
    ApplicationArea = NPRRetail;



    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {

                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Ship-to Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

