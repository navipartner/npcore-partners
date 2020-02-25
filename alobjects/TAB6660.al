tableextension 6014449 tableextension6014449 extends "Return Receipt Header" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Field 6014400
    // NPR5.53/MHA /20191211  CASE 380837 Added fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    fields
    {
        field(6014400;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
        }
        field(6151300;"NpEc Store Code";Code[20])
        {
            Caption = 'E-commerce Store Code';
            Description = 'NPR5.53';
            TableRelation = "NpEc Store";
        }
        field(6151305;"NpEc Document No.";Code[50])
        {
            Caption = 'E-commerce Document No.';
            Description = 'NPR5.53';
        }
    }
}

