page 6151071 "NPR Retail Replenish. SKU List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Retail Replenishment SKUs';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Reordering Policy"; "Reordering Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reordering Policy field';
                }
                field("Reorder Point"; "Reorder Point")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reorder Point field';
                }
                field("Replenishment System"; "Replenishment System")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replenishment System field';
                }
                field("Reorder Quantity"; "Reorder Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reorder Quantity field';
                }
                field("Maximum Inventory"; "Maximum Inventory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Inventory field';
                }
                field("Minimum Order Quantity"; "Minimum Order Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Order Quantity field';
                }
                field("Maximum Order Quantity"; "Maximum Order Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Order Quantity field';
                }
                field("Safety Stock Quantity"; "Safety Stock Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Safety Stock Quantity field';
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

