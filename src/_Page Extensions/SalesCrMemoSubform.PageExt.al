pageextension 6014491 "NPR Sales Cr. Memo Subform" extends "Sales Cr. Memo Subform"
{
    // NPR4.04/JDH /20150427 CASE 212229 Removed references to old Variant solution "Color Size"
    // NPR5.22/TJ  /20160412 CASE 238601 Reworked how to check for Retail Setup read permission
    //                                   Removed unused variable vare
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    // NPR5.29/TJ  /20170118 CASE 262797 Removed unusued varibles/functions and separators
    actions
    {
        addafter(DeferralSchedule)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea=All;
            }
        }
    }
}

