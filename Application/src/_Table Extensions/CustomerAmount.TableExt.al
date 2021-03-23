tableextension 6014425 "NPR Customer Amount" extends "Customer Amount"
{
    fields
    {
        field(6014400; "NPR Location"; Integer)
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014401; "NPR Amount 3 (LCY)"; Decimal)
        {
            Caption = 'Amount 3 (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }
}