page 6151369 "NPR MM AchRewardSetup"
{
    Extensible = False;

    Caption = 'Membership Achievements - Reward Setup';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM AchReward";

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
                field(RewardType; Rec.RewardType)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Type field.';
                }
                field(CouponType; Rec.CouponType)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Type field.';
                }
                field(CollectWithin; Rec.CollectWithin)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Collect Within field.';
                }
                field(NotificationCode; Rec.NotificationCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Notification Code field.';
                }
            }
        }
    }
}