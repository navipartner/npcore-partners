interface "NPR IMemberAlterationPriceHandler"
{
    procedure CalculateCancelAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewEndDate: Date) SuggestedPrice: Decimal

    procedure CalculateRenewAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry") SuggestedPrice: Decimal

    procedure CalculateAutoRenewAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry") SuggestedPrice: Decimal

    procedure CalculateExtendAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewStartDate: Date; NewEndDate: Date) SuggestedPrice: Decimal

    procedure CalculateUpgradeAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; ValidFromDate: Date; NewStartDate: Date; NewEndDate: Date) SuggestedPrice: Decimal
}