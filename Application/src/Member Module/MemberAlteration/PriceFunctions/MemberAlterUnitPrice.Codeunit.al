codeunit 6248454 "NPR MemberAlterUnitPrice" implements "NPR IMemberAlterationPriceHandler"
{
    Access = Internal;

    var
        _MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";

    procedure CalculateCancelAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewEndDate: Date) SuggestedPrice: Decimal
    begin
        SuggestedPrice := -1 * MembershipEntry."Unit Price";
    end;

    procedure CalculateRenewAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry") SuggestedPrice: Decimal
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        SuggestedPrice := Item."Unit Price";
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;

    procedure CalculateAutoRenewAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry") SuggestedPrice: Decimal
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        SuggestedPrice := Item."Unit Price";
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;

    procedure CalculateUpgradeAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; ValidFromDate: Date; NewStartDate: Date; NewEndDate: Date) SuggestedPrice: Decimal
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        SuggestedPrice := Item."Unit Price";
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;

    procedure CalculateExtendAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewStartDate: Date; NewEndDate: Date) SuggestedPrice: Decimal
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        SuggestedPrice := Item."Unit Price";
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;
}