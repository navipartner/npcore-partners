pageextension 6014414 pageextension6014414 extends "Posted Purch. Cr. Memo Subform" 
{
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    actions
    {
        addafter(DeferralSchedule)
        {
            action(Variety)
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
            }
        }
    }
}

