codeunit 6060145 "NPR MM Foreign Members. Mgr."
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        NotHandled: Label 'A request to validate foreign member card number %1 was attempted for %2 %3 but no handler responded with handled. This is a setup error, disable this community for remote validation.';

    procedure RediscoverNewManagers()
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin

        OnDiscoverExternalMembershipMgr(ForeignMembershipSetup);
    end;

    procedure FormatForeignCardNumberFromScan(CommunityCode: Code[20]; ManagerCode: Code[20]; ScannedCardnumber: Text[100]; var FormatedCardnumber: Text[100])
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        IsHandled: Boolean;
    begin

        IsHandled := false;
        // XYZ FormatedCardnumber := ScannedCardnumber;

        if (not ForeignMembershipSetup.Get(CommunityCode, ManagerCode)) then
            exit;

        if (ForeignMembershipSetup.Disabled) then
            exit;

        OnFormatForeignCardnumberFromScan(CommunityCode, ManagerCode, ScannedCardnumber, FormatedCardnumber, IsHandled);
    end;

    procedure DispatchToReplicateForeignMemberCard(CommunityCode: Code[20]; ForeignMembercardNumber: Text[100]; IncludeMemberImage: Boolean; var FormatedCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text) MembershipEntryNo: Integer
    var
        ForeignValidationSetup: Record "NPR MM Foreign Members. Setup";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        IsHandled: Boolean;
    begin

        MembershipEntryNo := 0;
        ForeignValidationSetup.SetCurrentKey("Invokation Priority");

        if (StrLen(ForeignMembercardNumber) <= MaxStrLen(FormatedCardNumber)) then
            FormatedCardNumber := ForeignMembercardNumber;

        ForeignValidationSetup.SetFilter("Community Code", '<>%1', '');
        if (CommunityCode <> '') then
            ForeignValidationSetup.SetFilter("Community Code", '=%1', CommunityCode);

        ForeignValidationSetup.SetFilter(Disabled, '=%1', false);

        if (ForeignValidationSetup.FindSet()) then begin
            repeat
                Sentry.StartSpan(Span, 'bc.membership.ondispatchtoreplicateforeignmembercard');
                OnDispatchToReplicateForeignMemberCard(ForeignValidationSetup."Community Code", ForeignValidationSetup."Manager Code", ForeignMembercardNumber, IncludeMemberImage, IsValid, NotValidReason, IsHandled);

                if (not IsHandled) then begin
                    Span.Finish();
                    Error(NotHandled, ForeignMembercardNumber, ForeignValidationSetup.FieldCaption("Community Code"), ForeignValidationSetup."Community Code");
                end;
                if (IsValid) then begin
                    FormatForeignCardNumberFromScan(ForeignValidationSetup."Community Code", ForeignValidationSetup."Manager Code", ForeignMembercardNumber, FormatedCardNumber);
                    MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(FormatedCardNumber, Today, NotValidReason);
                    if (MembershipEntryNo <> 0) and (ForeignMembercardNumber = FormatedCardNumber) then
                        ForeignMembershipMgr.SynchronizeLoyaltyPoints(ForeignValidationSetup."Community Code", ForeignValidationSetup."Manager Code", MembershipEntryNo, ForeignMembercardNumber);
                end;
                Span.Finish();

            until ((ForeignValidationSetup.Next() = 0) or (IsValid));
        end;

    end;

    procedure SynchronizeLoyaltyPoints(CommunityCode: Code[20]; ManagerCode: Code[20]; MembershipEntryNo: Integer; ScannedCardNumber: Text[100])
    var
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(Span, 'bc.membership.onsynchronizeloyaltypoints');
        OnSynchronizeLoyaltyPoints(CommunityCode, ManagerCode, MembershipEntryNo, ScannedCardNumber);
        Span.Finish();
    end;

    procedure ShowSetup(ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup")
    begin

        OnShowSetup(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code");
    end;

    procedure ShowDashboard(ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup")
    begin

        OnShowDashboard(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverExternalMembershipMgr(var Sender: Record "NPR MM Foreign Members. Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDispatchToReplicateForeignMemberCard(CommunityCode: Code[20]; ManagerCode: Code[20]; ForeignMembercardNumber: Text[100]; IncludeMemberImage: Boolean; var IsValid: Boolean; var NotValidReason: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFormatForeignCardnumberFromScan(CommunityCode: Code[20]; ManagerCode: Code[20]; ScannedCardNumber: Text[100]; var FormattedCardNumber: Text[100]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSynchronizeLoyaltyPoints(CommunityCode: Code[20]; ManagerCode: Code[20]; MembershipEntryNo: Integer; ScannedCardNumber: Text[100])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowSetup(CommunityCode: Code[20]; ManagerCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowDashboard(CommunityCode: Code[20]; ManagerCode: Code[20])
    begin
    end;
}

