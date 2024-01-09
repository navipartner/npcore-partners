page 6151371 "NPR MM AchMemberAchievement"
{
    Extensible = False;

    Caption = 'Membership Achievements';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Achievement";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(GoalCode; Rec.GoalCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Goal Code field.';
                }
                field(RewardCode; Rec.RewardCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Code field.';
                }
                field(AchievedAt; Rec.AchievedAt)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Achieved At field.';
                }
                field(RewardCollectedAt; Rec.RewardCollectedAt)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Collected At field.';
                }
                field(RewardId; Rec.RewardId)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Id field.';
                }
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }
                field(MembershipEntryNo; Rec.MembershipEntryNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                    Visible = false;
                }
            }
        }
    }

}