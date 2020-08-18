pageextension 6014437 pageextension6014437 extends "Item Reclass. Journal" 
{
    // NPR5.36/JDH /20170921 CASE 288696 Variety Action added
    actions
    {
        addafter("Get Bin Content")
        {
            action(Variety)
            {
                Caption = 'Variety';
                Image = ItemVariant;
                Promoted = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';
            }
        }
    }
}

