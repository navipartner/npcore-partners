enum 6014594 "NPR SI Transaction Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Sale")
    {
        Caption = 'Sale';
    }
    value(1; "Return")
    {
        Caption = 'Return';
    }
}