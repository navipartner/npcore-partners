#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059948 "NPR POS Lic. Bill. User Status"
{
    Access = Internal;
    Extensible = false;
    Caption = 'POS License Billing User Status';

    value(0; _)
    {
        Caption = '';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Active)
    {
        Caption = 'Active';
    }
    value(3; DisabledManually)
    {
        Caption = 'Disabled Manually';
    }
    value(4; SuspendedAutomatically)
    {
        Caption = 'Suspended Automatically';
    }
}
#endif