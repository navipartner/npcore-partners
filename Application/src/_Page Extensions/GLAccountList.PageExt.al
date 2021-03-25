pageextension 6014423 "NPR G/L Account List" extends "G/L Account List"
{
    layout
    {
        addafter("Reconciliation Account")
        {
            field("NPR Retail Payment"; Rec."NPR Is Retail Payment")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Retail Payment field';
                Editable = false;
            }
        }
    }
}