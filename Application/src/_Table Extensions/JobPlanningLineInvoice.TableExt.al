tableextension 6014402 "NPR Job Planning Line Invoice" extends "Job Planning Line Invoice"
{
    fields
    {
        field(6014400; "NPR POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            Description = 'NPR5.49';
            DataClassification = CustomerContent;
        }
        field(6014401; "NPR POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            Description = 'NPR5.49';
            DataClassification = CustomerContent;
        }
    }
}