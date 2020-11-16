pageextension 6014408 "NPR Posted S.Cr.Memo Subform" extends "Posted Sales Cr. Memo Subform"
{
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    actions
    {
        addafter(DeferralSchedule)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea = All;
            }
        }
    }
}

