codeunit 6184711 "NPR MM AchActivityNoOp" implements "NPR MM AchActivity"
{
    Access = Internal;
    internal procedure RegisterActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    var
    begin
        // Implementation for NOOP
    end;

    internal procedure ReverseActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    var
    begin
        // Implementation for NOOP
    end;

    internal procedure InitializeConditions(ActivityCode: Code[20])
    begin
        Message('This activity does not have any conditions to configure.');
    end;

}