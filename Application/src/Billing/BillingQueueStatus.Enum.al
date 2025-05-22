#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059856 "NPR Billing Queue Status"
{
    Access = Internal;
    Caption = 'Billing Queue Status';
    Extensible = false;

    value(0; "Pending")
    {
        Caption = 'Pending';
    }
    value(1; "Done")
    {
        Caption = 'Done';
    }
}
#endif