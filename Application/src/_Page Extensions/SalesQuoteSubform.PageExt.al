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

                ToolTip = 'Executes the Variety action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}