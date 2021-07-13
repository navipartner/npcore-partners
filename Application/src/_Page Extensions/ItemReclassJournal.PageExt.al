pageextension 6014437 "NPR Item Reclass. Journal" extends "Item Reclass. Journal"
{
    actions
    {
        addafter("Get Bin Content")
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'Executes the Variety action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}