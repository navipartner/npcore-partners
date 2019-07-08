tableextension 70000025 tableextension70000025 extends "Customer Amount" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014401..6014402
    fields
    {
        field(6014400;Location;Integer)
        {
            Caption = 'Location';
            Description = 'NPR7.100.000';
        }
        field(6014401;"Amount 3 (LCY)";Decimal)
        {
            Caption = 'Amount 3 (LCY)';
            Description = 'NPR7.100.000';
        }
    }
}

