codeunit 6184713 "NPR MM AchActivityManagement"
{
    Access = Internal;
    internal procedure InsertEntry(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Factor: Integer): Boolean
    var
        ActivityEntry: Record "NPR MM AchActivityEntry";
        Activity: Record "NPR MM AchActivity";
        Goal: Record "NPR MM AchGoal";
    begin


        if (not CheckFirstLevelConstraints(MembershipEntryNo, GoalCode, ActivityCode, Factor)) then
            exit(false);

        if (not CheckGenericConditions(MembershipEntryNo, GoalCode, ActivityCode)) then
            exit(false);

        Activity.Get(ActivityCode);

        ActivityEntry.EntryNo := 0;
        ActivityEntry.MembershipEntryNo := MembershipEntryNo;
        ActivityEntry.GoalCode := GoalCode;
        ActivityEntry.ActivityCode := ActivityCode;
        ActivityEntry.ActivityDescription := Activity.Description;
        ActivityEntry.ActivityDateTime := CurrentDateTime();
        ActivityEntry.ActivityWeight := Factor * Activity.Weight;

        ActivityEntry.Insert();

        Goal.SetFilter(Code, '=%1', GoalCode);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', MembershipEntryNo);
        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.FindFirst();
        if (Factor > 0) then
            if (Goal.ActivityCount >= Goal.RewardThreshold) then
                CreateAchievement(MembershipEntryNo, GoalCode, Goal.RewardCode);

        exit(true);
    end;

    local procedure CreateAchievement(MembershipEntryNo: Integer; GoalCode: Code[20]; RewardCode: Code[20])
    var
        Achievement: Record "NPR MM Achievement";
        AchievementActivity: Enum "NPR MM AchActivity";
        ActivityInterface: Interface "NPR MM AchActivity";
        Conditions: Dictionary of [Text[30], Text[30]];
    begin
        Achievement.SetCurrentKey(MembershipEntryNo, GoalCode);
        Achievement.SetFilter(MembershipEntryNo, '=%1', MembershipEntryNo);
        Achievement.SetFilter(GoalCode, '=%1', GoalCode);
        if (not Achievement.IsEmpty()) then
            exit;

        Achievement.EntryNo := 0;
        Achievement.MembershipEntryNo := MembershipEntryNo;
        Achievement.GoalCode := GoalCode;
        Achievement.RewardCode := RewardCode;
        Achievement.RewardId := ProcessReward(MembershipEntryNo, RewardCode);
        Achievement.AchievedAt := CurrentDateTime();
        Achievement.Insert();

        ActivityInterface := AchievementActivity::NAMED_ACHIEVEMENT;
        Conditions.Add('GoalFilter', GoalCode);
        ActivityInterface.RegisterActivity(MembershipEntryNo, '', '', Conditions);
    end;

    local procedure ProcessReward(MembershipEntryNo: Integer; RewardCode: Code[20]) RewardId: Code[20]
    var
        Reward: Record "NPR MM AchReward";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        RewardNotification: Record "NPR MM Membership Notific.";
        RewardCoupon: Codeunit "NPR MM AchievementCoupon";
    begin
        if (not Reward.Get(RewardCode)) then
            exit;

        case (Reward.RewardType) of
            Reward.RewardType::NO_REWARD:
                exit;
            Reward.RewardType::COUPON:
                RewardId := RewardCoupon.IssueCoupon(MembershipEntryNo, Reward.CouponType);
            else
                Error('Reward type %1 is not implemented', Reward.RewardType);
        end;

        if (Reward.RewardType <> Reward.RewardType::NO_REWARD) then
            if (RewardId = '') then
                exit; // TODO Telemetry on failure

        if (Reward.NotificationCode = '') then
            exit;

        if (not NotificationSetup.Get(Reward.NotificationCode)) then
            exit;

        RewardNotification."Membership Entry No." := MembershipEntryNo;
        RewardNotification."Notification Trigger" := RewardNotification."Notification Trigger"::ACHIEVEMENT;
        RewardNotification."Template Filter Value" := NotificationSetup."Template Filter Value";
        RewardNotification."Target Member Role" := NotificationSetup."Target Member Role";
        RewardNotification."Processing Method" := NotificationSetup."Processing Method";
        RewardNotification."Notification Method Source" := RewardNotification."Notification Method Source"::MEMBER;
        RewardNotification."Date To Notify" := Today() + abs(NotificationSetup."Days Past");
        RewardNotification."Include NP Pass" := NotificationSetup."Include NP Pass";

        RewardNotification."Notification Code" := Reward.NotificationCode;
        RewardNotification."Coupon No." := RewardId;
        if (not RewardNotification.Insert()) then;

    end;

    local procedure CheckFirstLevelConstraints(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Factor: Integer): Boolean
    var
        Activity: Record "NPR MM AchActivity";
        Goal: Record "NPR MM AchGoal";
        Achievement: Record "NPR MM Achievement";
    begin

        if (not Activity.Get(ActivityCode)) then
            exit;

        if (Activity.Weight = 0) then
            exit;

        if (Activity.EnableFromDate > Today()) then
            exit;

        if ((Activity.EnableUntilDate <> 0D) and (Activity.EnableUntilDate < Today())) then
            exit;

        Goal.SetFilter(Code, '=%1', GoalCode);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', MembershipEntryNo);
        Goal.SetAutoCalcFields(ActivityCount);
        if (not Goal.FindFirst()) then
            exit;

        if (not Goal.Activated) then
            exit;

        if (Goal.EnableFromDate > Today()) then
            exit;

        if ((Goal.EnableUntilDate <> 0D) and (Goal.EnableUntilDate < Today())) then
            exit;

        if (Factor > 0) then
            if (Goal.ActivityCount >= Goal.RewardThreshold) then
                exit;

        if (Factor < 0) then
            if (Goal.ActivityCount <= 0) then
                exit;

        if (Goal.RequiresAchievement <> '') then begin
            Achievement.SetCurrentKey(MembershipEntryNo, GoalCode);
            Achievement.SetFilter(MembershipEntryNo, '=%1', MembershipEntryNo);
            Achievement.SetFilter(GoalCode, '=%1', Goal.RequiresAchievement);
            if (Achievement.IsEmpty()) then
                exit;
        end;

        exit(true);
    end;

    local procedure CheckGenericConditions(MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]): Boolean
    var
        ActivityCondition: Record "NPR MM AchActivityCondition";
        MemberActivity: Record "NPR MM AchActivityEntry";
        Df: DateFormula;
    begin

        // Check if there is a previous activity registered within the limiting timeframe with today as relative date.
        if (ActivityCondition.Get(ActivityCode, 'Frequency')) then begin
            if (ActivityCondition.ConditionValue <> '') then begin
                MemberActivity.SetFilter(MembershipEntryNo, '=%1', MembershipEntryNo);
                MemberActivity.SetFilter(ActivityCode, '=%1', ActivityCode);
                MemberActivity.SetFilter(GoalCode, '=%1', GoalCode);
                MemberActivity.SetFilter(ActivityWeight, '>%1', 0);
                if (MemberActivity.FindLast()) then begin
                    case (ActivityCondition.ConditionValue) of
                        'CY':
                            if (DT2Date(MemberActivity.ActivityDateTime) >= CalcDate('<CY-1Y+1D>')) then
                                exit(false);
                        'CM':
                            if (DT2Date(MemberActivity.ActivityDateTime) >= CalcDate('<CM-1M+1D>')) then
                                exit(false);
                        'CW':
                            if (DT2Date(MemberActivity.ActivityDateTime) >= CalcDate('<CW-1W+1D>')) then
                                exit(false);
                        'CD':
                            if (DT2Date(MemberActivity.ActivityDateTime) >= Today()) then
                                exit(false);
                        else
                            if (Evaluate(Df, StrSubstNo('<%1>', ActivityCondition.ConditionValue))) then
                                if (DT2Date(MemberActivity.ActivityDateTime) >= CalcDate(df)) then
                                    exit(false);
                    end;
                end;
            end;
        end;

        // Activity will add to goal when true, Fridays in May. (if above was CW, it would apply once on a Friday in May)
        // Check if this activity applies for todays weekday
        if (ActivityCondition.Get(ActivityCode, 'Weekday')) then
            if (ActivityCondition.ConditionValue <> '') then
                if (ActivityCondition.ConditionValue in ['WD1', 'WD2', 'WD3', 'WD4', 'WD5', 'WD6', 'WD7']) then begin
                    if (not (Today() = CalcDate(StrSubstNo('<CW-1W+%1>', ActivityCondition.ConditionValue)))) then
                        exit(false);
                end else
                    exit(false);

        // Check if this activity applies for todays Month
        if (ActivityCondition.Get(ActivityCode, 'Month')) then
            if (ActivityCondition.ConditionValue <> '') then
                if (ActivityCondition.ConditionValue in ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8', 'M9', 'M10', 'M11', 'M12']) then begin
                    if (not (Date2DMY(Today(), 2) = Date2DMY(CalcDate(StrSubstNo('<%1>', ActivityCondition.ConditionValue)), 2))) then
                        exit(false);
                end else
                    exit(false);

        exit(true);
    end;

    internal procedure AddGenericConditions(ConditionsOut: Dictionary of [Text[30], Text[100]])
    begin
        ConditionsOut.Add('Frequency', 'Register once per [CY, CM, CW, CD = Current Day]. Leave blank for always.');
        ConditionsOut.Add('Weekday', 'Limit to a specific weekday [WD1, WD2..WD7] 1=Monday and 7=Sunday. Leave blank for any day.');
        ConditionsOut.Add('Month', 'Limit to a specific Month [M1, M2..M12] 1=January and 12=December. Leave blank for any month.');
    end;

}