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
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Reordering Policy"; Rec."Reordering Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reordering Policy field';
                }
                field("Reorder Point"; Rec."Reorder Point")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reorder Point field';
                }
                field("Replenishment System"; Rec."Replenishment System")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replenishment System field';
                }
                field("Reorder Quantity"; Rec."Reorder Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reorder Quantity field';
                }
                field("Maximum Inventory"; Rec."Maximum Inventory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Inventory field';
                }
                field("Minimum Order Quantity"; Rec."Minimum Order Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Order Quantity field';
                }
                field("Maximum Order Quantity"; Rec."Maximum Order Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Order Quantity field';
                }
                field("Safety Stock Quantity"; Rec."Safety Stock Quantity")
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

}

