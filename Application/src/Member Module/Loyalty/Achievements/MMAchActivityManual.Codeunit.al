codeunit 6184712 "NPR MM AchActivityManual" implements "NPR MM AchActivity"
{
    Access = Internal;

    internal procedure RegisterActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    begin
        FindAndRegisterActivity(MembershipEntryNo, GoalCode, ActivityCode, Constraints, 1);
    end;

    internal procedure ReverseActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    begin
        FindAndRegisterActivity(MembershipEntryNo, GoalCode, ActivityCode, Constraints, -1);
    end;

#pragma warning disable AA0137
    local procedure FindAndRegisterActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]]; Factor: Integer)
    var
        ActivityManagement: Codeunit "NPR MM AchActivityManagement";
        Activity: Record "NPR MM AchActivity";
        ActivityEnum: Enum "NPR MM AchActivity";
        ActivityNotFound: Label 'No manual activation available for goal %1.';
    begin
        Activity.SetFilter(Activity, '=%1', ActivityEnum::MANUAL);
        Activity.SetFilter(EnableFromDate, '<=%1', Today());
        Activity.SetFilter(EnableUntilDate, '>=%1|=%2', Today(), 0D);

        if (GoalCode <> '') then
            Activity.SetFilter(GoalCode, '=%1', GoalCode);

        if (ActivityCode <> '') then
            Activity.SetFilter(Code, '=%1', ActivityCode);

        if (not Activity.FindSet()) then
            if (GoalCode <> '') then
                Error(ActivityNotFound, GoalCode);

        repeat
            ActivityManagement.InsertEntry(MembershipEntryNo, Activity.GoalCode, Activity.Code, Factor);
        until (Activity.Next() = 0);
    end;
#pragma warning restore

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
    end;

}