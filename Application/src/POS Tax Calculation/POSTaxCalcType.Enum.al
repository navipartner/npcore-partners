enum 6150756 "NPR POS Tax Calc. Type" implements "NPR POS ITaxCalc"
{
    Extensible = true;

    value(0; "Normal VAT")
    {
        Caption = 'Normal VAT';
        Implementation = "NPR POS ITaxCalc" = "NPR POS Normal Tax";
    }
    value(1; "Reverse Charge VAT")
    {
        Caption = 'Reverse Charge VAT';
        Implementation = "NPR POS ITaxCalc" = "NPR POS Normal Tax";
    }
    value(2; "Full VAT")
    {
        Caption = 'Full VAT';
        Implementation = "NPR POS ITaxCalc" = "NPR POS Full Tax";
    }
    value(3; "Sales Tax")
    {
        Caption = 'Sales Tax';
        Implementation = "NPR POS ITaxCalc" = "NPR POS Sales Tax";
    }
}