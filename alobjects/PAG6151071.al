page 6151071 "Retail Replenishment SKU List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Retail Replenishment SKUs';
    PageType = List;
    SourceTable = "Stockkeeping Unit";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Reordering Policy"; "Reordering Policy")
                {
                    ApplicationArea = All;
                }
                field("Reorder Point"; "Reorder Point")
                {
                    ApplicationArea = All;
                }
                field("Replenishment System"; "Replenishment System")
                {
                    ApplicationArea = All;
                }
                field("Reorder Quantity"; "Reorder Quantity")
                {
                    ApplicationArea = All;
                }
                field("Maximum Inventory"; "Maximum Inventory")
                {
                    ApplicationArea = All;
                }
                field("Minimum Order Quantity"; "Minimum Order Quantity")
                {
                    ApplicationArea = All;
                }
                field("Maximum Order Quantity"; "Maximum Order Quantity")
                {
                    ApplicationArea = All;
                }
                field("Safety Stock Quantity"; "Safety Stock Quantity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        ItemHierachy: Code[10];
        DistributionGroup: Code[10];
}

