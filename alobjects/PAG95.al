pageextension 50671 pageextension50671 extends "Sales Quote Subform" 
{
    //  NPR7.100.000/LS/220114  : Retail Merge
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.22/TJ/20160411 CASE 238601 Setting standard captions on all of the actions and action groups
    //                                    Reworked how to check for Retail Setup read permission
    // NPR5.24/JDH/20160720 CASE 241848 Removed code that is not doing anything (removed from OnAfterGetRecord)
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    // NPR5.29/TJ  /20170118 CASE 262797 Removed unused functions, variables and function/variable separators
    actions
    {
        addafter("Item &Tracking Lines")
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

