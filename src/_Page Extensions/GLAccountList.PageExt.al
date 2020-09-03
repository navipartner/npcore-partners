pageextension 6014423 "NPR G/L Account List" extends "G/L Account List"
{
    layout
    {
        addafter("Reconciliation Account")
        {
            field("NPR Retail Payment"; "NPR Retail Payment")
            {
                ApplicationArea = All;
            }
        }
    }
}

