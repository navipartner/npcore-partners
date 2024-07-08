page 6059890 "NPR Item Details - Invoicing"
{
    Caption = 'Item Details - Invoicing';
    PageType = CardPart;
    SourceTable = Item;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Item No.';
                ToolTip = 'Specifies the number of the item.';
            }
            field("Costing Method"; Rec."Costing Method")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies how the item''s cost flow is recorded and whether an actual or budgeted value is capitalized and used in the cost calculation.';
            }
            field("Standard Cost"; Rec."Standard Cost")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the unit cost that is used as an estimation to be adjusted with variances later. It is typically used in assembly and production where costs can vary.';
            }
            field("Unit Cost"; Rec."Unit Cost")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
            }
            field("Last Direct Cost"; Rec."Last Direct Cost")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the most recent direct unit cost of the item.';
            }
            field("Profit %"; Rec."Profit %")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the profit margin that you want to sell the item at. You can enter a profit percentage manually or have it entered according to the Price/Profit Calculation field';
            }
            field("Unit Price"; Rec."Unit Price")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
            }

        }
    }
}
