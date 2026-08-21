#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6248182 "NPR Entria Order Imp. Status"
{
    Extensible = false;
    Access = Internal;
    value(0; Pending)
    {
        Caption = 'Pending';
    }
    value(1; Error)
    {
        Caption = 'Error';
    }
    value(2; Skipped)
    {
        Caption = 'Skipped';
    }
}
#endif
