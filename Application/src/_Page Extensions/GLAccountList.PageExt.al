pageextension 6014423 "NPR G/L Account List" extends "G/L Account List"
{
    layout
    {
        addafter("Reconciliation Account")
        {
            field("NPR Retail Payment"; Rec."NPR Is Retail Payment")
            {

                ToolTip = 'Specifies if the Retail Payment is included on the account';
                Editable = false;
                ApplicationArea = NPRRetail;
            }
        }
    }
}