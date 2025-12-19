#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059932 "NPR SpfyEventLogProcessStatus"
{
    Extensible = false;
    Access = Internal;

    value(0; "Ready")
    {
        Caption = 'Ready';
    }
    value(1; "Processed")
    {
        Caption = 'Processed';
    }
    value(4; "Error")
    {
        Caption = 'Error';
    }
    value(5; "Postponed")
    {
        Caption = 'Postponed';
    }
}
#endif