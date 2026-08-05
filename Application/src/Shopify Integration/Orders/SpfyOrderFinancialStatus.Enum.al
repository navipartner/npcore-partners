#if not BC17
enum 6059862 "NPR Spfy Order FinancialStatus"
{
    Access = Internal;
    Extensible = false;

    value(10; Authorized)
    {
        Caption = 'Authorized';
    }
    value(20; Paid)
    {
        Caption = 'Paid';
    }
    value(25; "Partially Paid")
    {
        Caption = 'Partially Paid';
    }
    value(30; Pending)
    {
        Caption = 'Pending';
    }
}
#endif