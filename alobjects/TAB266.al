tableextension 6014425 tableextension6014425 extends "Customer Amount"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014401..6014402
    fields
    {
        field(6014400; Location; Integer)
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014401; "Amount 3 (LCY)"; Decimal)
        {
            Caption = 'Amount 3 (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
    }
}

