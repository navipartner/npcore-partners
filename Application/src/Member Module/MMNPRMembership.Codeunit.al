#pragma warning disable AA0139, AA0217
codeunit 6060147 "NPR MM NPR Membership"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Foreign Members. Mgr.", 'OnDiscoverExternalMembershipMgr', '', true, true)]
    local procedure OnDiscover(var Sender: Record "NPR MM Foreign Members. Setup")
    begin
        Sender.RegisterManager(GetManagerCode(), 'NaviPartner Foreign NPR Membership Management');
    end;

    local procedure GetManagerCode(): Code[20]
    begin
        exit('NPR_MEMBER');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Foreign Members. Mgr.", 'OnDispatchToReplicateForeignMemberCard', '', true, true)]
    local procedure OnValidateAndReplicateForeignMemberCardSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20];
        ForeignMemberCardNumber: Text[100]; IncludeMemberImage: Boolean; var IsValid: Boolean; var NotValidReason: Text; var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        TempRemoteInfoCapture: Record "NPR MM Member Info Capture" temporary;
        NoPrefixForeignMemberCardNumber: Text[100];
    begin
        if (ManagerCode <> GetManagerCode()) then
            exit;

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit;

        IsHandled := true;

        ForeignMembershipSetup.Get(CommunityCode, ManagerCode);

        NoPrefixForeignMemberCardNumber := RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ForeignMemberCardNumber);

        ValidateForeignMemberCard(NPRRemoteEndpointSetup, NoPrefixForeignMemberCardNumber, TempRemoteInfoCapture, IsValid, NotValidReason);

        if (IsValid) then
            ReplicateMembership(NPRRemoteEndpointSetup, NoPrefixForeignMemberCardNumber, IncludeMemberImage, TempRemoteInfoCapture, IsValid, NotValidReason);

        if (not IsValid) then
            if (NoPrefixForeignMemberCardNumber <> ForeignMemberCardNumber) then
                Error(NotValidReason);

        if (IsValid) then
            NotValidReason := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Foreign Members. Mgr.", 'OnFormatForeignCardnumberFromScan', '', true, true)]
    local procedure OnFormatScannedCardNumberSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20]; ScannedCardNumber: Text[100]; var FormattedCardNumber: Text[100]; var IsHandled: Boolean)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        IsHandled := true;

        ForeignMembershipSetup.Get(CommunityCode, ManagerCode);
        FormattedCardNumber := AddLocalPrefix(ForeignMembershipSetup."Append Local Prefix", RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ScannedCardNumber));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Foreign Members. Mgr.", 'OnShowSetup', '', true, true)]
    local procedure OnShowSetupSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20])
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        NPREndpointSetupPage: Page "NPR MM NPR Endpoint Setup";
        Choice: Integer;
        NPRLoyaltyWizard: Codeunit "NPR MM NRP Loyalty Wizard";
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        Choice := StrMenu('View Endpoints,Cross Company Loyalty Client Setup', 1, 'Make your selection:');

        case Choice of
            1:
                begin
                    NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
                    NPREndpointSetupPage.SetTableView(NPRRemoteEndpointSetup);
                    NPREndpointSetupPage.Run();
                end;

            2:
                begin
                    ForeignMembershipSetup.Get(CommunityCode, GetManagerCode());
                    NPRLoyaltyWizard.SetCommunityCode(CommunityCode, ForeignMembershipSetup."Append Local Prefix");
                    NPRLoyaltyWizard.Run();
                end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Foreign Members. Mgr.", 'OnShowDashboard', '', true, true)]
    local procedure OnShowDashboardSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20])
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        // No dashboard yet
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Foreign Members. Mgr.", 'OnSynchronizeLoyaltyPoints', '', true, true)]
    local procedure OnSynchronizeLoyaltyPointsSubscriber(CommunityCode: Code[20]; ManagerCode: Code[20]; MembershipEntryNo: Integer; ScannedCardNumber: Text[100])
    var
        IsValid: Boolean;
        NotValidReason: Text;
    begin

        if (ManagerCode <> GetManagerCode()) then
            exit;

        SynchronizeLoyaltyPointsWorker(CommunityCode, MembershipEntryNo, ScannedCardNumber, IsValid, NotValidReason);

    end;

    local procedure SynchronizeLoyaltyPointsWorker(CommunityCode: Code[20]; MembershipEntryNo: Integer; ForeignMemberCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::LoyaltyServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit;

        ForeignMembershipSetup.Get(CommunityCode, GetManagerCode());
        ForeignMemberCardNumber := RemoveLocalPrefix(ForeignMembershipSetup."Remove Local Prefix", ForeignMemberCardNumber);

        IsValid := UpdateLocalMembershipPoints(NPRRemoteEndpointSetup, MembershipEntryNo, ForeignMembershipSetup."Append Local Prefix",
            ForeignMemberCardNumber, NotValidReason);
    end;

    procedure IsForeignMembershipCommunity(MembershipCode: Code[20]): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        if (not MembershipSetup.Get(MembershipCode)) then
            exit(false);

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', MembershipSetup."Community Code");
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);

        exit(NPRRemoteEndpointSetup.FindFirst());

    end;

    procedure CreateRemoteMembership(CommunityCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        IsValid := CreateRemoteMembershipWorker(NPRRemoteEndpointSetup, MemberInfoCapture, NotValidReason);

    end;

    procedure CreateRemoteMember(CommunityCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        IsValid := CreateRemoteMemberWorker(NPRRemoteEndpointSetup, MemberInfoCapture, NotValidReason);

    end;

    procedure CreateRemoteAddCard(CommunityCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture"; ReplaceCard: Boolean; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        ForeignMembershipSetup.SetFilter("Community Code", '=%1', CommunityCode);
        ForeignMembershipSetup.SetFilter(Disabled, '=%1', false);
        if (not ForeignMembershipSetup.FindFirst()) then
            exit(false);

        MemberInfoCapture."External Membership No." := RemoveLocalPrefix(ForeignMembershipSetup."Append Local Prefix", MemberInfoCapture."External Membership No.");
        MemberInfoCapture."External Member No" := RemoveLocalPrefix(ForeignMembershipSetup."Append Local Prefix", MemberInfoCapture."External Member No");
        MemberInfoCapture."Replace External Card No." := RemoveLocalPrefix(ForeignMembershipSetup."Append Local Prefix", MemberInfoCapture."Replace External Card No.");

        IsValid := CreateRemoteAddCardWorker(NPRRemoteEndpointSetup, MemberInfoCapture, ReplaceCard, NotValidReason);

        MemberInfoCapture."External Membership No." := AddLocalPrefix(ForeignMembershipSetup."Append Local Prefix", MemberInfoCapture."External Membership No.");
        MemberInfoCapture."External Member No" := AddLocalPrefix(ForeignMembershipSetup."Append Local Prefix", MemberInfoCapture."External Member No");
        MemberInfoCapture."Replace External Card No." := AddLocalPrefix(ForeignMembershipSetup."Append Local Prefix", MemberInfoCapture."Replace External Card No.");
        exit(true);
    end;

    procedure UpdateMemberField(CommunityCode: Code[20]; var RequestMemberFieldUpdate: Record "NPR MM Request Member Update"; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        ForeignMembershipSetup.SetFilter("Community Code", '=%1', CommunityCode);
        ForeignMembershipSetup.SetFilter(Disabled, '=%1', false);
        if (not ForeignMembershipSetup.FindFirst()) then
            exit(false);

        IsValid := UpdateMemberFieldWorker(NPRRemoteEndpointSetup, RequestMemberFieldUpdate, NotValidReason);
        exit(IsValid);
    end;

    internal procedure SearchRemoteMember(CommunityCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        IsValid := SearchMemberWorker(NPRRemoteEndpointSetup, MemberInfoCapture, TmpMemberInfoCapture, NotValidReason);
    end;

    internal procedure RequestMemberUpdate(CommunityCode: Code[20]; CardNumber: Text[100]; var NotValidReason: Text) IsValid: Boolean
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
    begin
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        exit(MMMembershipSoapApi.RequestMemberUpdateWorker(NPRRemoteEndpointSetup, CardNumber, NotValidReason));
    end;

    local procedure AddLocalPrefix(Prefix: Text; String: Text): Text
    var
        PrefixLbl: Label '%1%2', Locked = true;
    begin
        exit(StrSubstNo(PrefixLbl, Prefix, String));
    end;

    local procedure RemoveLocalPrefix(Prefix: Text; String: Text) NewString: Text[100]
    begin

        NewString := String;

        if (StrLen(Prefix) = 0) then
            exit(NewString);

        if (StrLen(Prefix) > StrLen(String)) then
            exit(NewString);

        if (CopyStr(String, 1, StrLen(Prefix)) = Prefix) then
            NewString := CopyStr(String, StrLen(Prefix) + 1);

        exit(NewString);
    end;

    local procedure ValidateForeignMemberCard(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";

        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get(NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
            exit;

        if (ForeignMembershipSetup.Disabled) then
            exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        IsValid := ValidateRemoteCardNumber(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, RemoteInfoCapture, NotValidReason);
        if (not IsValid) then
            exit;
    end;

    local procedure ReplicateMembership(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; IncludeMemberImage: Boolean; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipNumber: Code[20];
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        TempRequestMemberFieldUpdate: Record "NPR MM Request Member Update" temporary;
        RequestMemberFieldUpdate: Record "NPR MM Request Member Update";
        Prefix: Code[10];
    begin

        if (not ForeignMembershipSetup.Get(NPRRemoteEndpointSetup."Community Code", GetManagerCode())) then
            exit;

        if (ForeignMembershipSetup.Disabled) then
            exit;

        IsValid := false;
        Prefix := ForeignMembershipSetup."Append Local Prefix";

        if (not GetRemoteMembership(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason)) then
            exit;

        RemoteInfoCapture."External Card No." := Prefix + ForeignMemberCardNumber;
        if (StrLen(ForeignMemberCardNumber) >= 4) then
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(ForeignMemberCardNumber, StrLen(ForeignMemberCardNumber) - 4 + 1);

        MembershipSetup.Get(RemoteInfoCapture."Membership Code");
        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
            if (not (GetRemoteMember(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, ForeignMembershipNumber, IncludeMemberImage, RemoteInfoCapture, TempRequestMemberFieldUpdate, NotValidReason))) then
                exit;

        IsValid := CreateLocalMembership(RemoteInfoCapture);

        if (IsValid) then begin
            if (RequestMemberFieldUpdate.SetCurrentKey("Member Entry No.")) then;
            RequestMemberFieldUpdate.SetFilter("Member Entry No.", '=%1', RemoteInfoCapture."Member Entry No");
            RequestMemberFieldUpdate.SetFilter(Handled, '=%1', false);
            RequestMemberFieldUpdate.DeleteAll();

            if (TempRequestMemberFieldUpdate.FindSet()) then begin
                repeat
                    RequestMemberFieldUpdate.TransferFields(TempRequestMemberFieldUpdate, false);
                    RequestMemberFieldUpdate."Entry No." := 0;
                    RequestMemberFieldUpdate."Member Entry No." := RemoteInfoCapture."Member Entry No";
                    RequestMemberFieldUpdate."Member No." := RemoteInfoCapture."External Member No";
                    RequestMemberFieldUpdate.Insert();
                until (TempRequestMemberFieldUpdate.Next() = 0);
            end;
        end;

    end;

    local procedure ValidateRemoteCardNumber(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        ReturnValue: Boolean;
    begin
        Sentry.StartSpan(Span, 'bc.membership.validateremotecardnumber');
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            ReturnValue := MMMembershipRestApi.ValidateRemoteCardNumber(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, RemoteInfoCapture, NotValidReason)
        else
            ReturnValue := MMMembershipSoapApi.ValidateRemoteCardNumber(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, RemoteInfoCapture, NotValidReason);
        Span.Finish();
        exit(ReturnValue);
    end;

    local procedure GetRemoteMembership(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var ForeignMembershipNumber: Code[20]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        ReturnValue: Boolean;
    begin
        Sentry.StartSpan(Span, 'bc.membership.getremotemembership');
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            ReturnValue := MMMembershipRestApi.GetRemoteMembership(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason)
        else
            ReturnValue := MMMembershipSoapApi.GetRemoteMembership(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, ForeignMembershipNumber, RemoteInfoCapture, NotValidReason);
        Span.Finish();
        exit(ReturnValue);
    end;

    local procedure GetRemoteMember(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; ForeignMembershipNumber: Code[20]; IncludeMemberImage: Boolean; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var TempRequestMemberFieldUpdate: Record "NPR MM Request Member Update" temporary; var NotValidReason: Text): Boolean
    var
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        ReturnValue: Boolean;
    begin
        Sentry.StartSpan(Span, 'bc.membership.getremotemember');
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            ReturnValue := MMMembershipRestApi.GetRemoteMember(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, ForeignMembershipNumber, IncludeMemberImage, RemoteInfoCapture, TempRequestMemberFieldUpdate, NotValidReason)
        else
            ReturnValue := MMMembershipSoapApi.GetRemoteMember(NPRRemoteEndpointSetup, Prefix, ForeignMemberCardNumber, ForeignMembershipNumber, IncludeMemberImage, RemoteInfoCapture, TempRequestMemberFieldUpdate, NotValidReason);
        Span.Finish();
        exit(ReturnValue);
    end;

    local procedure CreateLocalMembership(var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin

        MembershipSalesSetup."Membership Code" := MemberInfoCapture."Membership Code";

        MembershipSalesSetup."Valid From Base" := MembershipSalesSetup."Valid From Base"::SALESDATE;
        MemberInfoCapture."Document Date" := Today();
        MemberInfoCapture."Valid Until" := Today();
        MembershipSalesSetup."Valid Until Calculation" := MembershipSalesSetup."Valid Until Calculation"::DATEFORMULA;
        Evaluate(MembershipSalesSetup."Duration Formula", '<+0D>');

        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::FOREIGN;
        exit(0 <> MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true));
    end;

    local procedure UpdateLocalMembershipPoints(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; MembershipEntryNo: Integer; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var NotValidReason: Text): Boolean
    var
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
    begin
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            exit(MMMembershipRestApi.UpdateLocalMembershipPoints(NPRRemoteEndpointSetup, MembershipEntryNo, ForeignMemberCardNumber, NotValidReason));
        exit(MMMembershipSoapApi.UpdateLocalMembershipPoints(NPRRemoteEndpointSetup, MembershipEntryNo, Prefix, ForeignMemberCardNumber, NotValidReason));
    end;

    local procedure CreateRemoteMembershipWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
    begin
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            exit(MMMembershipRestApi.CreateRemoteMembershipWorker(NPRRemoteEndpointSetup, MembershipInfo, NotValidReason));
        exit(MMMembershipSoapApi.CreateRemoteMembershipWorker(NPRRemoteEndpointSetup, MembershipInfo, NotValidReason));
    end;

    local procedure CreateRemoteMemberWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
    begin
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            exit(MMMembershipRestApi.CreateRemoteMemberWorker(NPRRemoteEndpointSetup, MembershipInfo, NotValidReason));
        exit(MMMembershipSoapApi.CreateRemoteMemberWorker(NPRRemoteEndpointSetup, MembershipInfo, NotValidReason));
    end;

    local procedure CreateRemoteAddCardWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; ReplaceCard: Boolean; var NotValidReason: Text): Boolean
    var
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
    begin
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            exit(MMMembershipRestApi.CreateRemoteAddCardWorker(NPRRemoteEndpointSetup, MembershipInfo, ReplaceCard, NotValidReason));
        exit(MMMembershipSoapApi.CreateRemoteAddCardWorker(NPRRemoteEndpointSetup, MembershipInfo, ReplaceCard, NotValidReason));
    end;

    local procedure UpdateMemberFieldWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var RequestMemberFieldUpdate: Record "NPR MM Request Member Update"; var NotValidReason: Text): Boolean
    var
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
    begin
        exit(MMMembershipSoapApi.UpdateMemberFieldWorker(NPRRemoteEndpointSetup, RequestMemberFieldUpdate, NotValidReason));
    end;

    internal procedure SearchForeignMembers(CommunityCode: Code[20]; var ExternalCardNumber: Text[100]): Boolean
    var
        MemberRemoteSearch: Page "NPR MM MemberRemoteSearch";
        PageAction: Action;
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(Span, 'ui.bc.membership.searchforeignmember');
        MemberRemoteSearch.SetCommunity(CommunityCode);
        MemberRemoteSearch.LookupMode(true);
        PageAction := MemberRemoteSearch.RunModal();
        if (PageAction = Action::LookupOK) then begin
            MemberRemoteSearch.GetSelectedRecord(TempMemberInfoCapture);
            ExternalCardNumber := TempMemberInfoCapture."External Card No.";
        end;
        Span.Finish();
        exit(ExternalCardNumber <> '');
    end;

    local procedure SearchMemberWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var TmpSearchResult: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text): Boolean
    var
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";

    begin
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then
            exit(MMMembershipRestApi.SearchMemberWorker(NPRRemoteEndpointSetup, MembershipInfo, TmpSearchResult, NotValidReason));
        exit(MMMembershipSoapApi.SearchMemberWorker(NPRRemoteEndpointSetup, MembershipInfo, TmpSearchResult, NotValidReason));
    end;

    procedure TestEndpointConnection(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup")
    var
        MMMembershipSoapApi: Codeunit "NPR MMMembershipSoapApi";
        MMMembershipRestApi: Codeunit "NPR MMMembershipRestApi";
        ConnectResult: Text;
        PlaceHolderLbl: Label '%1: %2', Locked = true;
    begin
        ConnectResult := StrSubstNo(PlaceHolderLbl, NPRRemoteEndpointSetup.FieldCaption("Endpoint URI"), MMMembershipSoapApi.TestEndpointConnection(NPRRemoteEndpointSetup));
        if NPRRemoteEndpointSetup."Rest Api Endpoint URI" <> '' then begin
            ConnectResult += '\\';
            ConnectResult += StrSubstNo(PlaceHolderLbl, NPRRemoteEndpointSetup.FieldCaption("Rest Api Endpoint URI"), MMMembershipRestApi.TestEndpointConnection(NPRRemoteEndpointSetup));
        end;
        Message(ConnectResult);
    end;

}
#pragma warning restore
