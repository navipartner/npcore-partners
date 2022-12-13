page 6060086 "NPR Retail Jnl. Line FactBox"
{
    Caption = 'Retail Journal Line Additional Info';
    PageType = CardPart;
    SourceTable = "NPR Retail Journal Line";
    InsertAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Net Change"; Rec."Net Change")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Net Change field';
                }
                field("Purchases (Qty.)"; Rec."Purchases (Qty.)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Purchases (Qty.) field';
                }
                field("Sales (Qty.)"; Rec."Sales (Qty.)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales (Qty.) field';
                }

            }
        }
    }
}