codeunit 6060145 "NPR MM Foreign Members. Mgr."
{

    trigger OnRun()
    begin
    end;

    var
        NotHandled: Label 'A request to validate foreign member card number %1 was attempted for %2 %3 but no handler responded with handled. This is a setup error, disable this community for remote validation.';

    local procedure "--API"()
    begin
    end;

    procedure RediscoverNewManagers()
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin

        OnDiscoverExternalMembershipMgr(ForeignMembershipSetup);
    end;

    procedure FormatForeignCardnumberFromScan(CommunityCode: Code[20]; ManagerCode: Code[20]; ScannedCardnumber: Text[100]; var FormatedCardnumber: Text[100])
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

    procedure DispatchToReplicateForeignMemberCard(CommunityCode: Code[20]; ForeignMembercardNumber: Text[100]; var FormatedCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text) MembershipEntryNo: Integer
    var
        ForeignValidationSetup: Record "NPR MM Foreign Members. Setup";
        IsHandled: Boolean;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
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
                OnDispatchToReplicateForeignMemberCard(ForeignValidationSetup."Community Code", ForeignValidationSetup."Manager Code", ForeignMembercardNumber, IsValid, NotValidReason, IsHandled);

                if (not IsHandled) then
                    Error(NotHandled, ForeignMembercardNumber, ForeignValidationSetup.FieldCaption("Community Code"), ForeignValidationSetup."Community Code");

            until ((ForeignValidationSetup.Next() = 0) or (IsValid));
        end;

        if (IsValid) then begin

            FormatForeignCardnumberFromScan(ForeignValidationSetup."Community Code", ForeignValidationSetup."Manager Code", ForeignMembercardNumber, FormatedCardNumber);

            //MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo (ForeignMembercardNumber, TODAY, NotValidReason);
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(FormatedCardNumber, Today, NotValidReason);

        end;
    end;

    procedure SynchronizeLoyaltyPoints(CommunityCode: Code[20]; ManagerCode: Code[20]; MembershipEntryNo: Integer; ScannedCardNumber: Text[100])
    begin

        OnSynchronizeLoyaltyPoints(CommunityCode, ManagerCode, MembershipEntryNo, ScannedCardNumber);
    end;

    procedure ShowSetup(ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup")
    begin

        OnShowSetup(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code");
    end;

    procedure ShowDashboard(ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup")
    begin

        OnShowDashboard(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code");
    end;

    local procedure "--Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverExternalMembershipMgr(var Sender: Record "NPR MM Foreign Members. Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDispatchToReplicateForeignMemberCard(CommunityCode: Code[20]; ManagerCode: Code[20]; ForeignMembercardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text; var IsHandled: Boolean)
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

