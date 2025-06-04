codeunit 6248456 "NPR MemberAlterTimeDifference" implements "NPR IMemberAlterationPriceHandler"
{
    Access = Internal;

    var
        _MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";

    procedure CalculateCancelAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewDate: Date): Decimal
    begin
        exit(0);
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
        RemainingFraction: Decimal;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        RemainingFraction := 1 - _MembershipMgtInternal.CalculatePeriodStartToDateFraction(ValidFromDate, NewEndDate, NewStartDate);
        SuggestedPrice := RemainingFraction * Item."Unit Price";
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;

    procedure CalculateExtendAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewStartDate: Date; NewEndDate: Date) SuggestedPrice: Decimal
    var
        NewFraction: Decimal;
        Item: Record Item;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        NewFraction := 1 - _MembershipMgtInternal.CalculatePeriodStartToDateFraction(NewStartDate, NewEndDate, MembershipEntry."Valid Until Date");
        SuggestedPrice := Round(NewFraction * Item."Unit Price", 0.01);
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;
}