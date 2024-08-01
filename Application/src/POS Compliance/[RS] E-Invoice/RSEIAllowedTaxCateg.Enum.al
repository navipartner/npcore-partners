enum 6014695 "NPR RS EI Allowed Tax Categ."
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "S")
    {
        Caption = 'Standard VAT calculation';
    }
    value(2; "AE")
    {
        Caption = 'Reverse VAT calculation';
    }
    value(3; "Z")
    {
        Caption = 'Tax Exemption with the right to deduct previous tax';
    }
    value(4; "E")
    {
        Caption = 'Tax Exemption without the right to deduct previous tax;';
    }
    value(5; "R")
    {
        Caption = 'Exemption from VAT';
    }
    value(6; "O")
    {
        Caption = 'Not subject to VAT taxation';
    }
    value(7; "OE")
    {
        Caption = 'Not subject to VAT 2 taxation';
    }
    value(8; "SS")
    {
        Caption = 'Special taxation procedures';
    }
    value(9; "N")
    {
        Caption = 'Anullment';
    }
}