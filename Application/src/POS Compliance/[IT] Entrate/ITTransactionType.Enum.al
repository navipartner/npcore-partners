enum 6014631 "NPR IT Transaction Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; SALE)
    {
        Caption = 'Sale';
    }
    value(1; REFUND)
    {
        Caption = 'Refund';
    }
}