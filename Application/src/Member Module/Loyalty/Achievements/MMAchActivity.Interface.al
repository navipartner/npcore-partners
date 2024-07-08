interface "NPR MM AchActivity"
{
#if not BC17
    Access = Internal;
#endif

    procedure RegisterActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]]);
    procedure ReverseActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]]);

    procedure InitializeConditions(ActivityCode: Code[20]);
}