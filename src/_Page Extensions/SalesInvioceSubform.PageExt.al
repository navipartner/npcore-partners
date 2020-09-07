pageextension 6014449 "NPR Sales Invioce Subform" extends "Sales Invoice Subform"
{
    // NPR5.29/TJ/20170113 CASE 262797 Removed unused function and functions used as separators
    actions
    {
        addafter("Related Information")
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                Promoted = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea=All;
            }
        }
    }
}

