pageextension 6014424 pageextension6014424 extends "General Ledger Entries"
{
    // NPR5.54/ANPA/20200504  NPR5.54 Added VAT Business posting group.
    layout
    {
        addafter("FA Entry No.")
        {
            field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
}

