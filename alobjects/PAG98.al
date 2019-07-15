pageextension 50699 pageextension50699 extends "Purch. Cr. Memo Subform" 
{
    // NPR4.13/MMV /20150708 CASE 214173 Changed "No." to variable to handle barcode scanning OnValidate trigger.
    // NPR4.16/TS  /20151021 CASE 214173 Removed Code related to release 4.13
    // NPR5.22/TJ  /20160411 CASE 238601 Setting standard captions on all of the actions and action groups
    //                                   Setting back default control ID to field No.
    //                                   Reworked how to check for Retail Setup read permission
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    // NPR5.29/TJ  /20170118 CASE 262797 Removed unusued varibles/functions and separators
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

