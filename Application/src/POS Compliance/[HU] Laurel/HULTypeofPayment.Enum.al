enum 6059871 "NPR HU L Type of Payment"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Ft")
    {
        Caption = 'Ft';
    }
    value(1; "EUR")
    {
        Caption = 'EUR';
    }
    value(2; "Other Non-Foreign")
    {
        Caption = 'Other Non-Foreign';
    }
    value(3; "Foreign")
    {
        Caption = 'Foreign';
    }
}