tableextension 6014426 "NPR Item Amount" extends "Item Amount"
{
    // NPR5.52/ZESO/20190722  CASE 361296 New Field Amount3
    // NPR5.52/ZESO/20190917  CASE 361296 Renamed field from 50000 to 6014400
    fields
    {
        field(6014400; "NPR Amount 3"; Decimal)
        {
            Caption = 'Amount 3';
            DataClassification = CustomerContent;
        }
    }
}

