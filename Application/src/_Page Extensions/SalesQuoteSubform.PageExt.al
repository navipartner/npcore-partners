pageextension 6014488 "NPR Sales Quote Subform" extends "Sales Quote Subform"
{
    actions
    {
        addafter("Item &Tracking Lines")
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