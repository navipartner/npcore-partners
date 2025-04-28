enum 6059859 "NPR HU L Paym. Currency Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Ft.")
    {
        Caption = 'Ft.', Locked = true;
    }
    value(1; "EUR")
    {
        Caption = 'EUR', Locked = true;
    }
    value(2; "Other (non-foreign)")
    {
        Caption = 'Other (non-foreign)';
    }
    value(3; "Foreign")
    {
        Caption = 'Foreign';
    }
}