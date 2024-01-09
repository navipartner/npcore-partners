page 6151365 "NPR MM AchGoalSetup"
{
    Extensible = False;

    Caption = 'Membership Achievements - Goal Setup';
    PageType = List;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR MM AchGoal";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
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
                field(Activated; Rec.Activated)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Activated field.';
                }
                field(EnableFromDate; Rec.EnableFromDate)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enable From Date field.';
                }
                field(EnableUntilDate; Rec.EnableUntilDate)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enable Until Date field.';
                }
                field(CommunityCode; Rec.CommunityCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Community Code field.';
                }
                field(MembershipCode; Rec.MembershipCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Membership Code field.';
                }
                field(RewardCode; Rec.RewardCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Code field.';
                }
                field(GroupBy; Rec.GroupBy)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Group By field.';
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
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Activities)
            {
                Caption = 'Activities';
                ToolTip = 'This action opens the Activity Setup page.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SetupLines;
                RunObject = page "NPR MM AchActivitySetup";
                RunPageLink = GoalCode = field(Code);
            }
            action(Rewards)
            {
                Caption = 'Rewards';
                ToolTip = 'This action opens the Rewards Setup page.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SetupLines;
                RunObject = page "NPR MM AchRewardSetup";
            }

            action(Entries)
            {
                Caption = 'Entries';
                ToolTip = 'This action opens the Member Activity Entries page.';
                ApplicationArea = NPRMembershipAdvanced;
                Image = EntriesList;
                RunObject = page "NPR MM AchActivityEntry";
                RunPageLink = GoalCode = field(Code);
            }
            action(Achievements)
            {
                Caption = 'Achievements';
                ToolTip = 'This action opens the Member Achievements page.';
                ApplicationArea = NPRMembershipAdvanced;
                Image = Entry;
                RunObject = page "NPR MM Achievement";
                RunPageLink = GoalCode = field(Code);
            }
        }
    }
}