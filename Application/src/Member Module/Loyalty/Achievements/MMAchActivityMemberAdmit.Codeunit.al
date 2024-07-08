codeunit 6184719 "NPR MM AchActivityMemberAdmit" implements "NPR MM AchActivity"
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

    local procedure FindAndRegisterActivity(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]]; Factor: Integer)
    var
        ActivityManagement: Codeunit "NPR MM AchActivityManagement";
        Activity: Record "NPR MM AchActivity";
        ActivityEnum: Enum "NPR MM AchActivity";
    begin
        Activity.SetFilter(Activity, '=%1', ActivityEnum::MEMBER_ARRIVAL);
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
                ActivityManagement.InsertEntry(MembershipEntryNo, Activity.GoalCode, Activity.Code, Factor);
        until (Activity.Next() = 0);
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
        ConditionsOut.Add('AdmissionCode', 'The admission code to match. Leave blank to match any admission code.');
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Management", 'OnAfterRegisterArrival', '', true, true)]
    local procedure OnAfterRegisterArrival(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; DetAccessEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Constraints: Dictionary of [Text[30], Text[30]];
    begin
        if (Ticket."External Member Card No." = '') then
            exit;

        if (not DetAccessEntry.Get(DetAccessEntryNo)) then
            exit;

        Member.SetFilter("External Member No.", '=%1', Ticket."External Member Card No.");
        Member.SetFilter(Blocked, '=%1', false);
        if (not Member.FindFirst()) then
            exit;

        Constraints.Add('AdmissionCode', AdmissionCode);

        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindSet()) then begin
            repeat
                if (DetAccessEntry.Quantity > 0) then
                    RegisterActivity(MembershipRole."Membership Entry No.", '', '', Constraints);
                if (DetAccessEntry.Quantity < 0) then
                    ReverseActivity(MembershipRole."Membership Entry No.", '', '', Constraints);
            until (MembershipRole.Next() = 0);
        end;

    end;

}