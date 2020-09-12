pageextension 6014415 "NPR Posted P.Cr. Memo Subform" extends "Posted Purch. Cr. Memo Subform"
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

