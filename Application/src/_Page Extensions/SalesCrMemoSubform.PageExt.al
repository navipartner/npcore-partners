pageextension 6014491 "NPR Sales Cr. Memo Subform" extends "Sales Cr. Memo Subform"
{
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
                ToolTip = 'Executes the Variety action';
            }
        }
    }
}