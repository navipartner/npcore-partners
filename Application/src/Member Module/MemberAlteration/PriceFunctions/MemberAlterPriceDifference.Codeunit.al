codeunit 6248455 "NPR MemberAlterPriceDifference" implements "NPR IMemberAlterationPriceHandler"
{
    Access = Internal;

    var
        _MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";

    procedure CalculateCancelAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewEndDate: Date) SuggestedPrice: Decimal
    var
        CancelledFraction: Decimal;
    begin
        CancelledFraction := 1 - _MembershipMgtInternal.CalculatePeriodStartToDateFraction(MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", NewEndDate);
        SuggestedPrice := Round(-CancelledFraction * MembershipEntry."Unit Price", 1);
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
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
        RemainingFraction: Decimal;
        Item: Record Item;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        RemainingFraction := 1 - _MembershipMgtInternal.CalculatePeriodStartToDateFraction(ValidFromDate, NewEndDate, NewStartDate);
        SuggestedPrice := -RemainingFraction * MembershipEntry."Unit Price (Base)" + RemainingFraction * Item."Unit Price";
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;

    procedure CalculateExtendAlterationPrice(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry"; NewStartDate: Date; NewEndDate: Date) SuggestedPrice: Decimal
    var
        CancelledFraction: Decimal;
        Item: Record Item;
    begin
        Item.SetLoadFields("Unit Price");
        Item.Get(MemberInfoCapture."Item No.");
        CancelledFraction := 1 - _MembershipMgtInternal.CalculatePeriodStartToDateFraction(MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", NewStartDate);
        SuggestedPrice := Round(-CancelledFraction * MembershipEntry."Unit Price (Base)" + Item."Unit Price", 0.01);
        SuggestedPrice += MembershipAlterationSetup."Member Unit Price" * _MembershipMgtInternal.GetMembershipMemberCountForAlteration(MembershipEntry."Membership Entry No.", MembershipAlterationSetup);
    end;
}