codeunit 6184716 "NPR MM AchActivityAchievement" implements "NPR MM AchActivity"
{
    Access = Internal;

    internal procedure RegisterActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    var
        ActivityManagement: Codeunit "NPR MM AchActivityManagement";
        Activity: Record "NPR MM AchActivity";
        ActivityEnum: Enum "NPR MM AchActivity";
    begin
        Activity.SetFilter(Activity, '=%1', ActivityEnum::NAMED_ACHIEVEMENT);
        Activity.SetFilter(EnableFromDate, '<=%1', Today());
        Activity.SetFilter(EnableUntilDate, '>=%1|=%2', Today(), 0D);

        if (GoalCode <> '') then
            Activity.SetFilter(GoalCode, '=%1', GoalCode);

        if (ActivityCode <> '') then
            Activity.SetFilter(Code, '=%1', ActivityCode);

        if (not Activity.FindSet()) then
            exit;

        repeat
            if (CheckConstraints(Activity.Code, Constraints)) then
                ActivityManagement.InsertEntry(MembershipEntryNo, Activity.GoalCode, Activity.Code, 1);
        until (Activity.Next() = 0);
    end;

    internal procedure ReverseActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    begin

    end;

    internal procedure InitializeConditions(ActivityCode: Code[20])
    var
        ActivityCondition: Record "NPR MM AchActivityCondition";
        ConditionName: Text[30];
        Conditions: Dictionary of [Text[30], Text[100]];
    begin
        DefaultConditions(Conditions);
        foreach ConditionName in Conditions.Keys() do begin
            ActivityCondition.Init();
            ActivityCondition.ActivityCode := ActivityCode;
            ActivityCondition.ConditionName := ConditionName;
            ActivityCondition.ConditionValue := '';
            ActivityCondition.Description := Conditions.Get(ConditionName);
            if (not ActivityCondition.Insert()) then;
        end;
    end;

    local procedure DefaultConditions(ConditionsOut: Dictionary of [Text[30], Text[100]])
    var
        ActivityManagement: Codeunit "NPR MM AchActivityManagement";
    begin
        ActivityManagement.AddGenericConditions(ConditionsOut);
        ConditionsOut.Add('GoalFilter', 'The code of the goal for which the threshold was reached. Leave blank to match any goal.');
    end;

    local procedure CheckConstraints(ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]]): Boolean
    var
        ActivityCondition: Record "NPR MM AchActivityCondition";
        ConstraintName: Text[30];
    begin
        foreach ConstraintName in Constraints.Keys() do begin
            if (ActivityCondition.Get(ActivityCode, ConstraintName)) then begin
                ActivityCondition.SetRecFilter();
                ActivityCondition.SetFilter(ConditionValue, '=%1|%2', '', '@' + Constraints.Get(ConstraintName));
                if (ActivityCondition.IsEmpty()) then
                    exit(false);
            end;
        end;
        exit(true);
    end;


}