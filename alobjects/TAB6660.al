tableextension 6014448 tableextension6014448 extends "Return Receipt Header" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Field 6014400
    // NPR5.53/MHA /20191211  CASE 380837 Added fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    // NPR5.54/MHA /20200311  CASE 390380 Removed fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    fields
    {
        field(6014400;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
        }
    }
}

