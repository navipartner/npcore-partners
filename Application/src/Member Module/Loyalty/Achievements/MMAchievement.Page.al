page 6151374 "NPR MM Achievement"
{
    Extensible = False;

    Caption = 'Membership Achievements';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Achievement";

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
                field(AchievedAt; Rec.AchievedAt)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Achieved At field.';
                }
                field(RewardCode; Rec.RewardCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reward Code field.';
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
                }
                field(MembershipEntryNo; Rec.MembershipEntryNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group(PrintGroup)
            {
                Caption = '&Print';
                Image = Print;
                action(Print)
                {
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Prints the selected reward.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        Coupon: Record "NPR NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                    begin
                        if (Coupon.Get(Rec.RewardId)) then
                            NpDcCouponMgt.PrintCoupon(Coupon);
                    end;
                }
            }
        }
    }
}