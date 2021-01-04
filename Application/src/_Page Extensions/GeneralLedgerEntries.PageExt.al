pageextension 6014424 "NPR General Ledger Entries" extends "General Ledger Entries"
{
    // NPR5.54/ANPA/20200504  NPR5.54 Added VAT Business posting group.
    layout
    {
        addafter("FA Entry No.")
        {
            field("NPR VAT Bus. Posting Group"; "VAT Bus. Posting Group")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
            }
        }
    }
}

