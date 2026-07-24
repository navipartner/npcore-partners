enum 6059784 "NPR License User Status"
{
    Access = Internal;
    Extensible = false;
    Caption = 'NPR License User Status';

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
