pageextension 6014475 "NPR Sales Price" extends "Sales Prices"
{
    actions
    {
        addafter(ClearFilter)
        {
            group("NPR Variants")
            {
                Caption = 'Variants';
            }
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