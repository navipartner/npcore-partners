enum 6059875 "NPR MM MembershipAutoRenew"
{
    Extensible = true;

    // NO,YES_INTERNAL,YES_EXTERNAL;
    value(0; NO)
    {
        Caption = 'No';
    }
    value(1; YES_INTERNAL)
    {
        Caption = 'Yes (internal)';
    }
    value(2; YES_EXTERNAL)
    {
        Caption = 'Yes (external)';
    }
    value(3; TERMINATION_REQUESTED)
    {
        Caption = 'Termination Requested';
    }
}