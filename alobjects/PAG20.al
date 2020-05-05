pageextension 6014421 pageextension6014421 extends "General Ledger Entries" 
{
    // NPR5.54/ANPA/20200504  NPR5.54 Added VAT Business posting group.
    layout
    {
        addafter("FA Entry No.")
        {
            field("VAT Bus. Posting Group";"VAT Bus. Posting Group")
            {
                Visible = false;
            }
        }
    }
}

