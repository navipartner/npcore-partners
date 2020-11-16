tableextension 6014402 "NPR Job Planning Line Invoice" extends "Job Planning Line Invoice"
{
    // NPR5.49/TJ  /20181206 CASE 331208 Added fields "POS Unit No." and "POS Store Code"
    fields
    {
        field(6014400; "NPR POS Unit No."; Code[10])
        {
            Caption = 'Cash Register No.';
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

