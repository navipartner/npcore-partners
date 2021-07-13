page 6151071 "NPR Retail Replenish. SKU List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Retail Replenishment SKUs';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Stockkeeping Unit";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Reordering Policy"; Rec."Reordering Policy")
                {

                    ToolTip = 'Specifies the value of the Reordering Policy field';
                    ApplicationArea = NPRRetail;
                }
                field("Reorder Point"; Rec."Reorder Point")
                {

                    ToolTip = 'Specifies the value of the Reorder Point field';
                    ApplicationArea = NPRRetail;
                }
                field("Replenishment System"; Rec."Replenishment System")
                {

                    ToolTip = 'Specifies the value of the Replenishment System field';
                    ApplicationArea = NPRRetail;
                }
                field("Reorder Quantity"; Rec."Reorder Quantity")
                {

                    ToolTip = 'Specifies the value of the Reorder Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Inventory"; Rec."Maximum Inventory")
                {

                    ToolTip = 'Specifies the value of the Maximum Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Minimum Order Quantity"; Rec."Minimum Order Quantity")
                {

                    ToolTip = 'Specifies the value of the Minimum Order Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Order Quantity"; Rec."Maximum Order Quantity")
                {

                    ToolTip = 'Specifies the value of the Maximum Order Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Safety Stock Quantity"; Rec."Safety Stock Quantity")
                {

                    ToolTip = 'Specifies the value of the Safety Stock Quantity field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

}

