pageextension 6014408 "NPR Purch.Return Order Subform" extends "Purchase Return Order Subform"
{
    actions
    {
        addafter(DocAttach)
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