page 6151366 "NPR MM AchMemberGoalList"
{
    Extensible = False;

    Caption = 'Membership Achievements';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM AchGoal";
    Editable = false;
    SourceTableView = sorting(GroupBy, RewardThreshold) order(ascending);

    layout
    {
        area(Content)
        {

            repeater(GroupName)
            {
                Caption = 'Goals';
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(RequiresAchievement; Rec.RequiresAchievement)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Requires Achievement field.';
                }
                field(RewardThreshold; Rec.RewardThreshold)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Threshold field.';
                }
                field(ActivityCount; Rec.ActivityCount)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Activity Count field.';
                }
                field(AchievementAcquired; Rec.AchievementAcquired)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Achievement Acquired field.';
                }
                field(RewardCode; Rec.RewardCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Code field.';
                }
                field(RewardCollectedAt; Rec.RewardCollectedAt)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Collected At field.';
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(IncreaseActivityCount)
            {
                Caption = 'Manual Activity (Increase)';
                ToolTip = 'This action will activate the MANUAL activities setup for this goal with increase count.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Entries;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Activity: Record "NPR MM AchActivity";
                    AchievementFacade: Codeunit "NPR MM AchievementFacade";
                    AchievementActivity: Enum "NPR MM AchActivity";
                    Constraints: Dictionary of [Text[30], Text[30]];
                begin
                    Activity.SetFilter(GoalCode, '=%1', Rec.Code);
                    Activity.FindFirst();

                    AchievementFacade.RegisterActivity(AchievementActivity::MANUAL, GetMembershipEntryNo(), Rec.Code, '', Constraints);
                end;
            }

            action(DecreaseActivityCount)
            {
                Caption = 'Manual Activity (Decrease)';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'This action will activate the MANUAL activities setup for this goal with decrease count.';
                Image = Entries;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Activity: Record "NPR MM AchActivity";
                    AchievementFacade: Codeunit "NPR MM AchievementFacade";
                    AchievementActivity: Enum "NPR MM AchActivity";
                    Constraints: Dictionary of [Text[30], Text[30]];
                begin
                    Activity.SetFilter(GoalCode, '=%1', Rec.Code);
                    Activity.FindFirst();

                    AchievementFacade.ReverseActivity(AchievementActivity::MANUAL, GetMembershipEntryNo(), Rec.Code, '', Constraints);
                end;
            }
        }

        area(Navigation)
        {
            action(Entries)
            {
                Caption = 'Entries';
                ToolTip = 'This action will open the members activity entries for the selected goal.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = EntriesList;
                Ellipsis = true;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MemberActivityEntries: Page "NPR MM AchMemberActivityEntry";
                    ActivityEntry: Record "NPR MM AchActivityEntry";
                begin
                    Rec.FilterGroup(248);
                    ActivityEntry.FilterGroup(248);
                    ActivityEntry.SetFilter(MembershipEntryNo, '=%1', GetMembershipEntryNo());
                    ActivityEntry.SetFilter(GoalCode, '=%1', Rec.Code);
                    ActivityEntry.FilterGroup(0);
                    Rec.FilterGroup(0);
                    MemberActivityEntries.SetTableView(ActivityEntry);
                    MemberActivityEntries.Run();
                end;
            }
            action(Achievements)
            {
                Caption = 'Achievement';
                ToolTip = 'This action will open the members achievement details for the selected goal.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Entries;
                Ellipsis = true;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AchievementPage: Page "NPR MM AchMemberAchievement";
                    Achievement: Record "NPR MM Achievement";
                begin
                    Rec.FilterGroup(248);
                    Achievement.FilterGroup(248);
                    Achievement.SetFilter(MembershipEntryNo, '=%1', GetMembershipEntryNo());
                    Achievement.FilterGroup(0);
                    Rec.FilterGroup(0);
                    Achievement.SetFilter(GoalCode, '=%1', Rec.Code);
                    AchievementPage.SetTableView(Achievement);
                    AchievementPage.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetFilter(EnableFromDate, '<=%1', Today());
        Rec.SetFilter(EnableUntilDate, '=%1|>=%2', 0D, Today());
    end;

    local procedure GetMembershipEntryNo() MembershipEntryNo: Integer;
    var
        Group: Integer;
    begin
        Group := Rec.FilterGroup(248);
        if (not Evaluate(MembershipEntryNo, Rec.GetFilter(MembershipEntryNoFilter))) then
            MembershipEntryNo := 0;
        Rec.FilterGroup(Group);

        if (MembershipEntryNo = 0) then
            Error('The membership entry number could not be gotten from the filter. Try opening the page again.');
    end;
}