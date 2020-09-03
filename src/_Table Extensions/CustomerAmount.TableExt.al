tableextension 6014425 "NPR Customer Amount" extends "Customer Amount"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014401..6014402
    fields
    {
        field(6014400; "NPR Location"; Integer)
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014401; "NPR Amount 3 (LCY)"; Decimal)
        {
            Caption = 'Amount 3 (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
    }
}

