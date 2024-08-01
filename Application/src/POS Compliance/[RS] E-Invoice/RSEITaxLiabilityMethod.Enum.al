enum 6014683 "NPR RS EI Tax Liability Method"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "0")
    {
        Caption = 'None';
    }
    value(2; "3")
    {
        Caption = 'According to invoice date';
    }
    value(3; "35")
    {
        Caption = 'According to traffic date';
    }
    value(4; "432")
    {
        Caption = 'According to date of payment';
    }
}