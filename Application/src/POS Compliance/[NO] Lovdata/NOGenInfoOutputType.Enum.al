enum 6014550 "NPR NO Gen. Info Output Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; Total)
    {
        Caption = 'Total';
    }
    value(1; "Per Salesperson")
    {
        Caption = 'Per Salesperson';
    }
}