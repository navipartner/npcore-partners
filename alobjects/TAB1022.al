tableextension 50003 tableextension50003 extends "Job Planning Line Invoice" 
{
    // NPR5.49/TJ  /20181206 CASE 331208 Added fields "POS Unit No." and "POS Store Code"
    fields
    {
        field(6014400;"POS Unit No.";Code[10])
        {
            Caption = 'Cash Register No.';
            Description = 'NPR5.49';
        }
        field(6014401;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            Description = 'NPR5.49';
        }
    }
}

