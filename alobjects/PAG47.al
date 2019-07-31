pageextension 50044 pageextension50044 extends "Sales Invoice Subform" 
{
    // NPR5.29/TJ/20170113 CASE 262797 Removed unused function and functions used as separators
    actions
    {
        addafter("Related Information")
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

