pageextension 6014475 "NPR Price List Line Review" extends "Price List Line Review"
{
    actions
    {
        addlast(Navigation)
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
                trigger OnAction()
                var
                    VRTWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VRTWrapper.PriceShowVariety(Rec, 0);
                end;
            }
        }
    }
}