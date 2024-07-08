enum 6014574 "NPR MM AchActivity" implements "NPR MM AchActivity"
{
    Extensible = false;
    Caption = 'Membership Achievement Activities';
#if not BC17
    Access = Public;
#endif

    value(0; NOOP)
    {
        Caption = 'No Operation';
        Implementation = "NPR MM AchActivity" = "NPR MM AchActivityNoOp";
    }

    value(1; MANUAL)
    {
        Caption = 'Simulate Activity';
        Implementation = "NPR MM AchActivity" = "NPR MM AchActivityManual";
    }

    value(20; MEMBER_ARRIVAL)
    {
        Caption = 'Member Arrival';
        Implementation = "NPR MM AchActivity" = "NPR MM AchActivityMemberAdmit";
    }

    value(30; POINTS_EARNED)
    {
        Caption = 'Earn Points';
        Implementation = "NPR MM AchActivity" = "NPR MM AchActivityNoOp";
    }

    value(40; NAMED_ACHIEVEMENT)
    {
        Caption = 'Achievement Acquired';
        Implementation = "NPR MM AchActivity" = "NPR MM AchActivityAchievement";
    }
}