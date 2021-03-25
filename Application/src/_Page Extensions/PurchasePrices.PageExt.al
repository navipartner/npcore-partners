pageextension 6014476 "NPR Purchase Prices" extends "Purchase Prices"
{
    actions
    {
        addafter(CopyPrices)
        {
            group("NPR Variants")
            {
                Caption = 'Variants';
                action("NPR Variety")
                {
                    Caption = 'Variety';
                    Image = ItemVariant;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Alt+V';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety action';
                }
            }
        }
    }
}