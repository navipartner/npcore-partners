page 6151071 "NPR Retail Replenish. SKU List"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Retail Replenishment SKUs';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Stockkeeping Unit";
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR24.0';
    ObsoleteReason = 'Retail Replenishment will no longer be supported';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the item number';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the variant code for the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the location code for the item selected';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Reordering Policy"; Rec."Reordering Policy")
                {
                    ToolTip = 'Specifies the reordering policy of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Reorder Point"; Rec."Reorder Point")
                {
                    ToolTip = 'Specifies the reorder point of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Replenishment System"; Rec."Replenishment System")
                {
                    ToolTip = 'Specifies the replenishment system of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Reorder Quantity"; Rec."Reorder Quantity")
                {
                    ToolTip = 'Specifies the reorder quantity of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Inventory"; Rec."Maximum Inventory")
                {
                    ToolTip = 'Specifies the maximum inventory of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Minimum Order Quantity"; Rec."Minimum Order Quantity")
                {
                    ToolTip = 'Specifies the minimum order quantity of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Order Quantity"; Rec."Maximum Order Quantity")
                {
                    ToolTip = 'Specifies the maximum order quantity of the item selected';
                    ApplicationArea = NPRRetail;
                }
                field("Safety Stock Quantity"; Rec."Safety Stock Quantity")
                {
                    ToolTip = 'Specifies the safety stock quantity.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

}

