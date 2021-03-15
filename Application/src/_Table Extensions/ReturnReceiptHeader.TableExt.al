tableextension 6014449 "NPR Return Receipt Header" extends "Return Receipt Header"
{
    fields
    {
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }
}

