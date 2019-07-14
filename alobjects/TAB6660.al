tableextension 50048 tableextension50048 extends "Return Receipt Header" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Field 6014400
    fields
    {
        field(6014400;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
        }
    }
}

