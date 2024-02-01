#pragma warning disable AA0139, AA0217
codeunit 6060147 "NPR MM NPR Membership"
{
    Access = Internal;

    var
        InvalidXml: Label 'An invalid XML was returned:\%1';
        MemberCardValidation: Label 'Service %1 at %2 could not validate membercard %3.';
        _NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

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

        ValidateForeignMemberCard(NPRRemoteEndpointSetup, NoPrefixForeignMemberCardNumber, IsValid, NotValidReason);

        if (IsValid) then
            ReplicateMembership(NPRRemoteEndpointSetup, NoPrefixForeignMemberCardNumber, IncludeMemberImage, IsValid, NotValidReason);

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
    begin
        NPRRemoteEndpointSetup.SetFilter("Community Code", '=%1', CommunityCode);
        NPRRemoteEndpointSetup.SetFilter(Type, '=%1', NPRRemoteEndpointSetup.Type::MemberServices);
        NPRRemoteEndpointSetup.SetFilter(Disabled, '=%1', false);
        if (not NPRRemoteEndpointSetup.FindFirst()) then
            exit(false);

        exit(RequestMemberUpdateWorker(NPRRemoteEndpointSetup, CardNumber, NotValidReason));
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

    local procedure ValidateForeignMemberCard(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        RemoteInfoCapture: Record "NPR MM Member Info Capture";
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

    local procedure ReplicateMembership(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; IncludeMemberImage: Boolean; var IsValid: Boolean; var NotValidReason: Text)
    var
        ForeignMembershipNumber: Code[20];
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        RemoteInfoCapture: Record "NPR MM Member Info Capture";
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

    local procedure ValidateRemoteCardNumber(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin

        MemberCardNumberValidationRequest(ForeignMemberCardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := MemberCardNumberValidationResponse(Prefix, ForeignMemberCardNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (not IsValid) then
            if (NotValidReason = '') then
                NotValidReason := StrSubstNo(MemberCardValidation, SoapAction, NPRRemoteEndpointSetup."Endpoint URI", ForeignMemberCardNumber);

        exit(IsValid);
    end;

    local procedure GetRemoteMembership(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var ForeignMembershipNumber: Code[20]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        GetMembershipRequest(ForeignMemberCardNumber, '', SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetMembershipResponse(Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (StrLen(RemoteInfoCapture."External Card No.") >= 4) then
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(RemoteInfoCapture."External Card No.", StrLen(RemoteInfoCapture."External Card No.") - 4 + 1);

        exit(IsValid);
    end;

    local procedure GetRemoteMember(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; ForeignMembershipNumber: Code[20]; IncludeMemberImage: Boolean; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var TempRequestMemberFieldUpdate: Record "NPR MM Request Member Update" temporary; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        GetMembershipMemberRequest(ForeignMembershipNumber, ForeignMemberCardNumber, '', IncludeMemberImage, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetMembershipMemberResponse(Prefix, XmlDocResponse, NotValidReason, RemoteInfoCapture, TempRequestMemberFieldUpdate);

        exit(IsValid);
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

    local procedure UpdateLocalMembershipPoints(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; MembershipEntryNo: Integer; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
        ForeignMembershipNumber: Code[20];
        RemoteInfoCapture: Record "NPR MM Member Info Capture";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        if (MembershipEntryNo = 0) then
            exit(false);

        GetLoyaltyPointRequest(ForeignMemberCardNumber, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := GetLoyaltyPointResponse(Prefix, ForeignMembershipNumber, XmlDocResponse, NotValidReason, RemoteInfoCapture);

        if (IsValid) then
            LoyaltyPointManagement.SynchronizePointsAbsolute(MembershipEntryNo, Round(RemoteInfoCapture."Initial Loyalty Point Count", 1, '<'), Today);

        exit(IsValid);
    end;

    local procedure CreateRemoteMembershipWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        ScannerStationId: Text;
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin

        ScannerStationId := '';

        CreateMembershipSoapXmlRequest(MembershipInfo, ScannerStationId, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := EvaluateCreateMembershipSoapXmlResponse(MembershipInfo, NotValidReason, XmlDocResponse);
        exit(IsValid);

    end;

    local procedure CreateRemoteMemberWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        MembershipEvents: Codeunit "NPR MM Membership Events";
        ScannerStationId: Text;
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        ScannerStationId := '';
        CreateMemberSoapXmlRequest(MembershipInfo, ScannerStationId, SoapAction, XmlDocRequest);
        MembershipEvents.OnAfterCreateMemberSoapRequest(MembershipInfo, XmlDocRequest, SoapAction);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := EvaluateCreateMemberSoapXmlResponse(MembershipInfo, NotValidReason, XmlDocResponse);
        exit(IsValid);

    end;

    local procedure CreateRemoteAddCardWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; ReplaceCard: Boolean; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        CreateAddReplaceCardSoapXmlRequest(MembershipInfo, ReplaceCard, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := EvaluateAddReplaceCardSoapXmlResponse(MembershipInfo, NotValidReason, XmlDocResponse);
        exit(IsValid);
    end;

    local procedure UpdateMemberFieldWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var RequestMemberFieldUpdate: Record "NPR MM Request Member Update"; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        IsValid := true;
        UpdateMemberFieldSoapXmlRequest(RequestMemberFieldUpdate, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            IsValid := false;

        exit(IsValid);
    end;

    internal procedure SearchForeignMembers(CommunityCode: Code[20]; var ExternalCardNumber: Text[100]): Boolean
    var
        MemberRemoteSearch: Page "NPR MM MemberRemoteSearch";
        PageAction: Action;
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
    begin
        MemberRemoteSearch.SetCommunity(CommunityCode);
        MemberRemoteSearch.LookupMode(true);
        PageAction := MemberRemoteSearch.RunModal();
        if (PageAction = Action::LookupOK) then begin
            MemberRemoteSearch.GetSelectedRecord(TempMemberInfoCapture);
            ExternalCardNumber := TempMemberInfoCapture."External Card No.";
        end;

        exit(ExternalCardNumber <> '');
    end;

    local procedure SearchMemberWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var TmpSearchResult: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text) IsValid: Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        CreateSearchMemberSoapXmlRequest(MembershipInfo, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        IsValid := EvaluateSearchMemberSoapXmlResponse(TmpSearchResult, NotValidReason, XmlDocResponse);
        exit(IsValid);
    end;


    local procedure RequestMemberUpdateWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; CardNumber: Text[100]; var NotValidReason: Text): Boolean
    var
        SoapAction: Text;
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
    begin
        CreateRequestMemberUpdateSoapXmlRequest(CardNumber, SoapAction, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, SoapAction, NotValidReason, XmlDocRequest, XmlDocResponse)) then
            exit(false);

        // Fire & Forget
        exit(true);
    end;

    procedure WebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; SoapAction: Text; var ReasonText: Text; var XmlDocIn: XmlDocument; var XmlDocOut: XmlDocument): Boolean
    begin
        ReasonText := '';
        if (TryWebServiceApi(NPRRemoteEndpointSetup, SoapAction, ReasonText, XmlDocIn, XmlDocOut)) then
            exit(true);

        if (ReasonText = '') then
            ReasonText := GetLastErrorText();
        exit(false);
    end;

    [TryFunction]
    internal procedure TryWebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; SoapAction: Text; var ReasonText: Text; var XmlDocIn: XmlDocument; var XmlDocOut: XmlDocument)
    var
        ResponseText: Text;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        [NonDebuggable]
        Headers: HttpHeaders;
        RequestText: Text;
    begin
        ReasonText := '';

        XmlDocIn.WriteTo(RequestText);
        RequestContent.WriteFrom(RequestText);
        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        ContentHeader.Add('SOAPAction', SoapAction);
        WebRequest.Content(RequestContent);
        WebRequest.GetHeaders(Headers);

        SetRequestHeadersAuthorization(NPRRemoteEndpointSetup, Headers);

        WebRequest.Method := 'POST';
        WebRequest.SetRequestUri(NPRRemoteEndpointSetup."Endpoint URI");
        if (NPRRemoteEndpointSetup."Connection Timeout (ms)" < 100) then
            NPRRemoteEndpointSetup."Connection Timeout (ms)" := 10 * 1000;
        WebClient.Timeout := NPRRemoteEndpointSetup."Connection Timeout (ms)";

        WebClient.Send(WebRequest, WebResponse);
        if (WebResponse.IsSuccessStatusCode) then begin
            WebResponse.Content.ReadAs(ResponseText);
            XmlDocument.ReadFrom(ResponseText, XmlDocOut);
            XmlDocOut.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
            exit;
        end;

        ResponseText := '<webServiceApi><fault>' +
            StrSubstNo('<endpointCode>%1</endpointCode>', NPRRemoteEndpointSetup.Code) +
            StrSubstNo('<endpoint>%1</endpoint>', NPRRemoteEndpointSetup."Endpoint URI") +
            StrSubstNo('<reason>%1</reason>', ReasonText) +
            StrSubstNo('<code>%1</code>', WebResponse.HttpStatusCode()) +
            '</fault></webServiceApi>';
        XmlDocument.ReadFrom(ResponseText, XmlDocOut);
        XmlDocOut.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));

        ReasonText := StrSubstNo('[%1] (%2) %3: %4', NPRRemoteEndpointSetup.Code, WebResponse.HttpStatusCode(), WebResponse.ReasonPhrase(), NPRRemoteEndpointSetup."Endpoint URI");
        Error(ReasonText);
    end;

    procedure MemberCardNumberValidationRequest(ExternalMemberCardNumber: Text[100]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin
        SoapAction := 'MemberCardNumberValidation';
        XmlRequest :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          '      <mem:MemberCardNumberValidation>' +
          '         <mem:externalMemberCardNo>%1</mem:externalMemberCardNo>' +
          '         <mem:scannerStationId>%2</mem:scannerStationId>' +
          '      </mem:MemberCardNumberValidation>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>';
        XmlRequest := StrSubstNo(XmlRequest, ExternalMemberCardNumber, ScannerStationId);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure MemberCardNumberValidationResponse(Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        TextOk: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin
        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);

        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        TextOk := NpXmlDomMgt.GetXmlText(Element, '//MemberCardNumberValidation_Result/return_value', 5, false);
        MemberInfoCapture."External Card No." := Prefix + ForeignMemberCardNumber;
        if (StrLen(ForeignMemberCardNumber) >= 4) then
            MemberInfoCapture."External Card No. Last 4" := CopyStr(ForeignMemberCardNumber, StrLen(ForeignMemberCardNumber) - 4 + 1);

        exit(LowerCase(TextOk) = 'true');
    end;

    local procedure GetMembershipRequest(ExternalMemberCardNumber: Text[100]; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin

        SoapAction := 'GetMembership';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <mem:GetMembership>' +
         '         <mem:membership>' +
         '            <getmembership>' +
         '               <request>' +
         '                  <membernumber></membernumber>' +
         '                  <cardnumber>%1</cardnumber>' +
         '                  <membershipnumber></membershipnumber>' +
         '                  <username></username>' +
         '                  <password></password>' +
         '                  <customernumber></customernumber>' +
         '               </request>' +
         '            </getmembership>' +
         '          </mem:membership>' +
         '         <mem:scannerStationId>%2</mem:scannerStationId>' +
         '      </mem:GetMembership>' +
         '   </soapenv:Body>' +
         '</soapenv:Envelope>';
        XmlRequest := StrSubstNo(XmlRequest, ExternalMemberCardNumber, ScannerStationId);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure GetMembershipResponse(Prefix: Code[10]; var ForeignMembershipNumber: Code[20]; var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        TextOk: Text;
        ElementPath: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin

        // <GetMembership_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/member_services">
        //    <membership>
        //      <getmembership xmlns="urn:microsoft-dynamics-nav/xmlports/x6060129">
        // ...
        // <response>
        //  <status>1</status>
        //  <errordescription/>
        //  <membership>
        //      <communitycode>RIVERLAND</communitycode>
        //      <membershipcode>GOLD</membershipcode>
        //      <membershipnumber>MS-DEMO-00001</membershipnumber>
        //      <issuedate>2017-03-27</issuedate>
        //      <validfromdate>2017-03-27</validfromdate>
        //      <validuntildate>2019-03-26</validuntildate>
        //      <membercardinality>2</membercardinality>
        //      <membercount named="1" anonymous="0">1</membercount>
        //  </membership>
        // </response>

        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);

        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        ElementPath := '//GetMembership_Result/membership/getmembership/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetMembership_Result/membership/getmembership/response/membership/';

        MemberInfoCapture."Membership Code" := Prefix + NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipcode', MaxStrLen(MemberInfoCapture."Membership Code"), false);
        ForeignMembershipNumber := NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);
        MemberInfoCapture."External Membership No." := Prefix + ForeignMembershipNumber;

        exit(true);
    end;

    local procedure GetMembershipMemberRequest(ExternalMembershipNumber: Code[20]; ExternalMemberCardNumber: Text[100]; ScannerStationId: Text; IncludeMemberImage: Boolean; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin

        SoapAction := 'GetMembershipMembers';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <mem:GetMembershipMembers>' +
         '         <mem:member>' +
         '            <getmembers>' +
         '               <request>' +
         '                  <membershipnumber>%1</membershipnumber>' +
         '                  <membernumber></membernumber>' +
         '                  <cardnumber>%2</cardnumber>' +
         '                  <includememberimage>%3</includememberimage>' +
         '               </request>' +
         '            </getmembers>' +
         '         </mem:member>' +
         '         <mem:scannerStationId>%4</mem:scannerStationId>' +
         '      </mem:GetMembershipMembers>' +
         '   </soapenv:Body>' +
         '</soapenv:Envelope>';

        XmlRequest := StrSubstNo(XmlRequest, ExternalMembershipNumber, ExternalMemberCardNumber, IncludeMemberImage, ScannerStationId);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure GetMembershipMemberResponse(Prefix: Code[10]; var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var TempRequestMemberFieldUpdate: Record "NPR MM Request Member Update" temporary): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        Node: XmlNode;
        NodeList: XmlNodeList;
        TextOk: Text;
        ElementPath: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
        TextCountry: Text;
        TextCountryCode: Text;
        CountryRegion: Record "Country/Region";
        Base64Image: Text;
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        // <GetMembershipMembers_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/member_services">
        //    <member>
        //      <getmembers xmlns="urn:microsoft-dynamics-nav/xmlports/x6060130">
        //          <request>
        //
        // <response>
        //  <status>1</status>
        //  <errordescription/>
        //  <member role="Membership Admin">
        //      <membernumber>MM-DEMO-00001</membernumber>
        //      <firstname>Tim</firstname>
        //      <middlename/>
        //      <lastname>Sannes</lastname>
        //      <address/>
        //      <postcode/>
        //      <city/>
        //      <country/>
        //      <birthday/>
        //      <gender>0</gender>
        //      <newsletter>0</newsletter>
        //      <phoneno/>
        //      <email>test0227@test.se</email>
        //      <storecode/>        
        //      <base64Image>/9j/4AAQSkZJRgABAQEAYAB..</base64Image>

        //      <requestfieldupdate>
        //        <field entryno="7" fieldno="35">
        //            <caption>E-Mail Address</caption>
        //            <currentvalue>paxocuco@mailinator.net</currentvalue>
        //        </field>
        //      </requestfieldupdate>
        //  </member>
        // </response>

        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);

        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/member/';
        MemberInfoCapture."External Member No" := Prefix + NpXmlDomMgt.GetXmlText(Element, ElementPath + 'membernumber', MaxStrLen(MemberInfoCapture."External Member No"), true);
        MemberInfoCapture."First Name" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'firstname', MaxStrLen(MemberInfoCapture."First Name"), false);
        MemberInfoCapture."Middle Name" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'middlename', MaxStrLen(MemberInfoCapture."Middle Name"), false);
        MemberInfoCapture."Last Name" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'lastname', MaxStrLen(MemberInfoCapture."Last Name"), false);
        MemberInfoCapture.Address := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'address', MaxStrLen(MemberInfoCapture.Address), false);
        MemberInfoCapture."Post Code Code" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'postcode', MaxStrLen(MemberInfoCapture."Post Code Code"), false);
        MemberInfoCapture.City := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'city', MaxStrLen(MemberInfoCapture.City), false);

        TextCountry := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'country', MaxStrLen(MemberInfoCapture.Country), false);
        TextCountryCode := NpXmlDomMgt.GetAttributeCode(Element, ElementPath + 'country', 'code', MaxStrLen(MemberInfoCapture."Country Code"), false);
        if (TextCountryCode <> '') and (CountryRegion.Get(TextCountryCode)) then begin
            MemberInfoCapture."Country Code" := TextCountryCode;
            MemberInfoCapture.Country := CountryRegion.Name;
        end else begin
            MemberInfoCapture."Country Code" := '';
            MemberInfoCapture.Country := TextCountry;
        end;

        if (Evaluate(MemberInfoCapture.Birthday, NpXmlDomMgt.GetXmlText(Element, ElementPath + 'birthday', 10, false))) then;
        if (Evaluate(MemberInfoCapture.Gender, NpXmlDomMgt.GetXmlText(Element, ElementPath + 'gender', 1, false))) then;
        if (Evaluate(MemberInfoCapture."News Letter", NpXmlDomMgt.GetXmlText(Element, ElementPath + 'newsletter', 1, false))) then;

        MemberInfoCapture."Phone No." := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'phoneno', MaxStrLen(MemberInfoCapture."Phone No."), false);
        MemberInfoCapture."E-Mail Address" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'email', MaxStrLen(MemberInfoCapture."E-Mail Address"), false);
        MemberInfoCapture."Store Code" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'storecode', MaxStrLen(MemberInfoCapture."Store Code"), false);
        Base64Image := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'base64Image', 0, false);
        if Base64Image <> '' then begin
            TempBlob.CreateOutStream(OutStr);
            Base64Convert.FromBase64(Base64Image, OutStr);
            TempBlob.CreateInStream(InStr);
            MemberInfoCapture.Image.ImportStream(InStr, MemberInfoCapture.FieldName(Image));
        end;

        ElementPath := '//GetMembershipMembers_Result/member/getmembers/response/member/requestfieldupdate';
        if (NpXmlDomMgt.FindNode(Element.AsXmlNode(), ElementPath, Node)) then begin
            if (NpXmlDomMgt.FindNodes(Node, 'field', NodeList)) then begin
                foreach Node in NodeList do begin
                    Element := Node.AsXmlElement();
                    TempRequestMemberFieldUpdate."Entry No." := TempRequestMemberFieldUpdate.Count() + 1;
                    TempRequestMemberFieldUpdate."Remote Entry No." := NpXmlDomMgt.GetAttributeInt(Element, '', 'entryno', true);
                    TempRequestMemberFieldUpdate."Field No." := NpXmlDomMgt.GetAttributeInt(Element, '', 'fieldno', true);
                    TempRequestMemberFieldUpdate."Request Datetime" := CurrentDateTime();
                    TempRequestMemberFieldUpdate."Current Value" := NpXmlDomMgt.GetXmlText(Element, '//currentvalue', MaxStrLen(TempRequestMemberFieldUpdate."Current Value"), true);
                    TempRequestMemberFieldUpdate.Caption := NpXmlDomMgt.GetXmlText(Element, '//caption', MaxStrLen(TempRequestMemberFieldUpdate.Caption), true);
                    TempRequestMemberFieldUpdate.Insert();
                end;
            end;
        end;

        exit(true);
    end;

    local procedure GetLoyaltyPointRequest(ExternalMemberCardNumber: Text[100]; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin
        SoapAction := 'GetLoyaltyPoints';
        XmlRequest :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loy="urn:microsoft-dynamics-schemas/codeunit/loyalty_services" xmlns:x60="urn:microsoft-dynamics-nav/xmlports/x6060141">' +
            '   <soapenv:Header/>' +
            '   <soapenv:Body>' +
            '      <loy:GetLoyaltyPoints>' +
            '         <loy:getLoyaltyPoints>' +
            '            <x60:getloyaltypoints>' +
            '               <x60:request>' +
            '                  <x60:cardnumber>%1</x60:cardnumber>' +
            '                  <x60:membershipnumber></x60:membershipnumber>' +
            '                  <x60:customernumber></x60:customernumber>' +
            '               </x60:request>' +
            '             </x60:getloyaltypoints>' +
            '          </loy:getLoyaltyPoints>' +
            '      </loy:GetLoyaltyPoints>' +
            '   </soapenv:Body>' +
            '</soapenv:Envelope>';
        XmlRequest := StrSubstNo(XmlRequest, ExternalMemberCardNumber);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure GetLoyaltyPointResponse(Prefix: Code[10]; var ForeignMembershipNumber: Code[20]; var XmlDoc: XmlDocument; var ResponseText: Text; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        TextOk: Text;
        ElementPath: Text;
        Points: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin

        //  <GetLoyaltyPoints_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/loyalty_services">
        //      <getLoyaltyPoints>
        //        <getloyaltypoints xmlns="urn:microsoft-dynamics-nav/xmlports/x6060141">
        // ...
        // </response>
        //  <status>
        //      <responsecode>OK</responsecode>
        //      <responsemessage/>
        //  </status>
        //  <membership>
        //      <communitycode>LOYALTY_CC</communitycode>
        //      <membershipcode>CC01</membershipcode>
        //      <membershipnumber>MS-DEMO-00027</membershipnumber>
        //      <issuedate>2019-05-22</issuedate>
        //      <validfromdate>2019-05-22</validfromdate>
        //      <validuntildate>2020-05-21</validuntildate>
        //      <pointsummary>
        //        <awarded>
        //            <sales>3196</sales>
        //            <refund>0</refund>
        //        </awarded>
        //        <redeemed>
        //            <withdrawl>0</withdrawl>
        //            <deposit>0</deposit>
        //        </redeemed>
        //        <expired>0</expired>
        //        <remaining>3196</remaining>
        //      </pointsummary>
        //  </membership>
        // </response>

        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);

        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/status/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responsecode', 5, false);
        ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responsemessage', 1000, false);
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//GetLoyaltyPoints_Result/getLoyaltyPoints/getloyaltypoints/response/membership';

        MemberInfoCapture."Membership Code" := Prefix + NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipcode', MaxStrLen(MemberInfoCapture."Membership Code"), false);
        ForeignMembershipNumber := NpXmlDomMgt.GetXmlText(Element, ElementPath + '/membershipnumber', MaxStrLen(MemberInfoCapture."External Membership No."), false);
        MemberInfoCapture."External Membership No." := Prefix + ForeignMembershipNumber;
        Points := NpXmlDomMgt.GetXmlText(Element, ElementPath + '/pointsummary/remaining', 10, false);
        if (not Evaluate(MemberInfoCapture."Initial Loyalty Point Count", Points)) then
            MemberInfoCapture."Initial Loyalty Point Count" := 0;

        exit(true);
    end;

    procedure CreateMembershipSoapXmlRequest(MemberInfoCapture: Record "NPR MM Member Info Capture"; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlText: Text;
    begin
        XmlText :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<mem:CreateMembership>' +
                    '<mem:membership>' +
                    CreateMembershipRequest(MemberInfoCapture) +
                    '</mem:membership>' +
                    StrSubstNo('<mem:scannerStationId>%1</mem:scannerStationId>', ScannerStationId) +
                '</mem:CreateMembership>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        XmlDocument.ReadFrom(XmlText, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));

        SoapAction := 'CreateMembership';
    end;

    procedure CreateMembershipXmlPortRequest(MemberInfoCapture: Record "NPR MM Member Info Capture") XmlText: Text
    begin
        XmlText :=
            '<membership xmlns="urn:microsoft-dynamics-nav/xmlports/x6060127">' +
            CreateMembershipRequest(MemberInfoCapture) +
            '</membership>';
    end;

    local procedure CreateMembershipRequest(MemberInfoCapture: Record "NPR MM Member Info Capture") XmlText: Text
    var
        ActivationDateText: Text;
    begin
        ActivationDateText := '';
        if (MemberInfoCapture."Document Date" > 0D) then
            ActivationDateText := Format(MemberInfoCapture."Document Date", 0, 9);

        XmlText :=
            '<createmembership>' +
            '<request>' +
                StrSubstNo('<membershipsalesitem>%1</membershipsalesitem>', MemberInfoCapture."Item No.") +
                StrSubstNo('<activationdate>%1</activationdate>', ActivationDateText) +
            '</request>' +
            '</createmembership>';
    end;

    local procedure EvaluateCreateMembershipSoapXmlResponse(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text; var XmlDoc: XmlDocument): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        ResponseText: Text;
        TextOk: Text;
        ElementPath: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
        ServerResponseLbl: Label 'Message from Server: %1';
    begin
        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);

        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        ElementPath := '//CreateMembership_Result/membership/createmembership/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, true);
        NotValidReason := StrSubstNo(ServerResponseLbl, NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, true));
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//CreateMembership_Result/membership/createmembership/response/membership/';

        MemberInfoCapture."Membership Code" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'membershipcode',
            MaxStrLen(MemberInfoCapture."Membership Code"), false);
        MemberInfoCapture."External Membership No." := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'membershipnumber',
            MaxStrLen(MemberInfoCapture."External Membership No."), false);

        NotValidReason := '';
        exit(true);
    end;

    local procedure CreateMemberSoapXmlRequest(MemberInfoCapture: Record "NPR MM Member Info Capture"; ScannerStationId: Text; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlText: Text;
    begin
        XmlText :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<mem:AddMembershipMember>' +
                    '<mem:member>' +
                        CreateMemberRequest(MemberInfoCapture) +
                    '</mem:member>' +
                    StrSubstNo('<mem:scannerStationId>%1</mem:scannerStationId>', ScannerStationId) +
                '</mem:AddMembershipMember>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        SoapAction := 'AddMembershipMember';

        XmlDocument.ReadFrom(XmlText, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure CreateMemberRequest(MemberInfoCapture: Record "NPR MM Member Info Capture") XmlText: Text
    var
        MemberCardXml: Text;
        GuardianXml: Text;
        DateText: Text;
    begin

        MemberCardXml := '';
        DateText := '1754-01-01';
        if (MemberInfoCapture."Valid Until" > 0D) then
            DateText := Format(MemberInfoCapture."Valid Until", 0, 9);

        if (MemberInfoCapture."External Card No." <> '') then
            MemberCardXml :=
              '<membercard>' +
                  StrSubstNo('<cardnumber>%1</cardnumber>', XmlSafe(MemberInfoCapture."External Card No.")) +
                  StrSubstNo('<is_permanent>%1</is_permanent>', Format(MemberInfoCapture."Temporary Member Card", 0, 9)) +
                  StrSubstNo('<valid_until>%1</valid_until>', DateText) +
              '</membercard>';

        GuardianXml := '';
        if (MemberInfoCapture."Guardian External Member No." <> '') then
            GuardianXml :=
              '<guardian>' +
                StrSubstNo('<membernumber>%1</membernumber>', XmlSafe(MemberInfoCapture."Guardian External Member No.")) +
                StrSubstNo('<email>%1</email>', MemberInfoCapture."E-Mail Address") +
              '</guardian>';

        DateText := '1754-01-01';
        if (MemberInfoCapture.Birthday > 0D) then
            DateText := Format(MemberInfoCapture.Birthday, 0, 9);

        XmlText :=
        '<addmember>' +
          '<request>' +
            StrSubstNo('<membershipnumber>%1</membershipnumber>', XmlSafe(MemberInfoCapture."External Membership No.")) +
            StrSubstNo('<firstname>%1</firstname>', XmlSafe(MemberInfoCapture."First Name")) +
            StrSubstNo('<middlename>%1</middlename>', XmlSafe(MemberInfoCapture."Middle Name")) +
            StrSubstNo('<lastname>%1</lastname>', XmlSafe(MemberInfoCapture."Last Name")) +
            StrSubstNo('<address>%1</address>', XmlSafe(MemberInfoCapture.Address)) +
            StrSubstNo('<postcode>%1</postcode>', XmlSafe(MemberInfoCapture."Post Code Code")) +
            StrSubstNo('<city>%1</city>', XmlSafe(MemberInfoCapture.City)) +
            StrSubstNo('<country>%1</country>', XmlSafe(MemberInfoCapture."Country Code")) +
            StrSubstNo('<phoneno>%1</phoneno>', XmlSafe(MemberInfoCapture."Phone No.")) +
            StrSubstNo('<email>%1</email>', XmlSafe(MemberInfoCapture."E-Mail Address")) +
            StrSubstNo('<birthday>%1</birthday>', DateText) +
            StrSubstNo('<gender>%1</gender>', Format(MemberInfoCapture.Gender, 0, 9)) +
            StrSubstNo('<newsletter>%1</newsletter>', Format(MemberInfoCapture."News Letter", 0, 0)) +
            StrSubstNo('<username>%1</username>', XmlSafe(MemberInfoCapture."User Logon ID")) +
            StrSubstNo('<password>%1</password>', XmlSafe(MemberInfoCapture."Password SHA1")) +
            StrSubstNo('<store_code>%1</store_code>', XmlSafe(MemberInfoCapture."Store Code")) +
            MemberCardXml +
            GuardianXml +
            StrSubstNo('<gdpr_approval>%1</gdpr_approval>', Format(MemberInfoCapture."GDPR Approval", 0, 9)) +
          '</request>' +
        '</addmember>';
    end;

    local procedure EvaluateCreateMemberSoapXmlResponse(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text; var XmlDoc: XmlDocument): Boolean
    var
        DateText: Text;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        ResponseText: Text;
        TextOk: Text;
        ElementPath: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
        ServerResponseLbl: Label 'Message from Server: %1';
    begin
        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);

        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        ElementPath := '//AddMembershipMember_Result/member/addmember/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, true);
        NotValidReason := StrSubstNo(ServerResponseLbl, NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, true));
        if (TextOk = '0') then
            exit(false);

        ElementPath := '//AddMembershipMember_Result/member/addmember/response/member/';
        MemberInfoCapture."External Member No" := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'membernumber', MaxStrLen(MemberInfoCapture."External Member No"), false);
        MemberInfoCapture."External Card No." := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'card/cardnumber', MaxStrLen(MemberInfoCapture."External Card No."), false);
        DateText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'card/expirydate', 10, false);
        if (not Evaluate(MemberInfoCapture."Valid Until", DateText, 9)) then
            MemberInfoCapture."Valid Until" := 0D;

        NotValidReason := '';
        exit(true);
    end;


    local procedure CreateAddReplaceCardSoapXmlRequest(MemberInfoCapture: Record "NPR MM Member Info Capture"; ReplaceCard: Boolean; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlText: Text;
    begin
        XmlText :=
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services" xmlns:x61="urn:microsoft-dynamics-nav/xmlports/x6151185">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>' +
            '<mem:AddReplaceCard>' +
                '<mem:addReplaceCard>' +
                    '<x61:addreplacecard>' +
                    CreateAddReplaceCardRequest(MemberInfoCapture, ReplaceCard) +
                    '</x61:addreplacecard>' +
                '</mem:addReplaceCard>' +
            '</mem:AddReplaceCard>' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

        SoapAction := 'AddReplaceCard';

        XmlDocument.ReadFrom(XmlText, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure CreateAddReplaceCardRequest(MemberInfoCapture: Record "NPR MM Member Info Capture"; ReplaceCard: Boolean) XmlText: Text
    var
    begin
        if (not ReplaceCard) then
            XmlText :=
              '<x61:request>' +
                StrSubstNo('<x61:add_card membershipnumber="%1" membernumber="%2" new_cardnumber="%3"/>', MemberInfoCapture."External Membership No.", MemberInfoCapture."External Member No", MemberInfoCapture."External Card No.") +
              '</x61:request>';

        if (ReplaceCard) then
            XmlText :=
              '<x61:request>' +
                StrSubstNo('<x61:replace_card old_cardnumber="%1" new_cardnumber="%2"/>', MemberInfoCapture."Replace External Card No.", MemberInfoCapture."External Card No.") +
              '</x61:request>';
    end;

    local procedure EvaluateAddReplaceCardSoapXmlResponse(var TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text; var XmlDoc: XmlDocument): Boolean
    var
        DateText: Text;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        Element2: XmlElement;
        Node: XmlNode;
        ResponseText: Text;
        TextOk: Text;
        ElementPath: Text;
        BoolText: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
        ServerResponseLbl: Label 'Message from Server: %1';
    begin

        //-#471935 [471935]
        //      <AddReplaceCard_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/member_services">
        //         <addReplaceCard>
        //            <addreplacecard xmlns="urn:microsoft-dynamics-nav/xmlports/x6151185">
        //               <request>
        //                  <add_card membershipnumber="" membernumber=""/>
        //                  <replace_card old_cardnumber="4552MC-DEMO-000801"/>
        //               </request>
        //               <response>
        //                  <status>OK</status>
        //                  <errordescription/>
        //                  <member>
        //                     <membernumber>MM-DEMO-00166</membernumber>
        //                     <firstname>Tim</firstname>
        //                     <middlename>H</middlename>
        //                     <lastname>Sannes</lastname>
        //                     <cards>
        //                        <card>
        //                           <cardnumber>4552MC-DEMO-000815</cardnumber>
        //                           <cardsuffix>0815</cardsuffix>
        //                           <validuntil>2022-06-27</validuntil>
        //                           <istemporary>false</istemporary>
        //                        </card>
        //                     </cards>
        //                  </member>
        //               </response>
        //            </addreplacecard>
        //         </addReplaceCard>
        //      </AddReplaceCard_Result>

        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);
        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        ElementPath := '//AddReplaceCard_Result/addReplaceCard/addreplacecard/response/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'status', 5, true);
        NotValidReason := StrSubstNo(ServerResponseLbl, NpXmlDomMgt.GetXmlText(Element, ElementPath + 'errordescription', 1000, true));
        if (TextOk = 'ERROR') then
            exit(false);

        if (NpXmlDomMgt.FindNode(Element.AsXmlNode(), ElementPath + 'member', Node)) then begin
            Element2 := Node.AsXmlElement();
            TmpMemberInfoCapture."External Member No" := NpXmlDomMgt.GetXmlText(Element2, 'membernumber', MaxStrLen(TmpMemberInfoCapture."External Member No"), false);
            TmpMemberInfoCapture."First Name" := NpXmlDomMgt.GetXmlText(Element2, 'firstname', MaxStrLen(TmpMemberInfoCapture."First Name"), false);
            TmpMemberInfoCapture."Last Name" := NpXmlDomMgt.GetXmlText(Element2, 'lastname', MaxStrLen(TmpMemberInfoCapture."Last Name"), false);
            TmpMemberInfoCapture."External Card No." := NpXmlDomMgt.GetXmlText(Element2, 'cards/card/cardnumber', MaxStrLen(TmpMemberInfoCapture."External Card No."), false);
            TmpMemberInfoCapture."External Card No. Last 4" := NpXmlDomMgt.GetXmlText(Element2, 'cards/card/cardsuffix', MaxStrLen(TmpMemberInfoCapture."External Card No. Last 4"), false);

            DateText := NpXmlDomMgt.GetXmlText(Element2, 'cards/card/validuntil', 10, false);
            if (not Evaluate(TmpMemberInfoCapture."Valid Until", DateText, 9)) then
                TmpMemberInfoCapture."Valid Until" := 0D;

            BoolText := NpXmlDomMgt.GetXmlText(Element2, 'cards/card/istemporary', 10, false);
            if (not Evaluate(TmpMemberInfoCapture."Temporary Member Card", BoolText, 9)) then
                TmpMemberInfoCapture."Temporary Member Card" := false;

            TmpMemberInfoCapture."Entry No." := 1;
            TmpMemberInfoCapture.Insert();
        end;

        NotValidReason := '';
        exit(true);
    end;


    local procedure EvaluateSearchMemberSoapXmlResponse(var TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text; XmlDoc: XmlDocument): Boolean
    var
        RootElement: XmlElement;
        ResponseNode: XmlNode;
        XmlMessage: Text;
        ElementPath: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin
        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);
        if (not XmlDoc.GetRoot(RootElement)) then begin
            NotValidReason := StrSubstNo(InvalidXml, _NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        ElementPath := 'descendant::response';
        if (not _NpXmlDomMgt.FindNode(RootElement.AsXmlNode(), ElementPath, ResponseNode)) then begin
            NotValidReason := StrSubstNo(InvalidXml, _NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;

        exit(EvaluateSearchMemberSoapXmlResponse(TmpMemberInfoCapture, NotValidReason, ResponseNode));
    end;

    internal procedure EvaluateSearchMemberSoapXmlResponse(var TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text; ResponseNode: XmlNode): Boolean
    var
        MembershipElement, MemberElement, CardElement : XmlElement;
        MembershipNode, MemberNode, CardNode : XmlNode;
        MembershipNodeList, MemberNodeList, CardNodeList : XmlNodeList;

        ExpiryDate: Date;
        ExpiryDateText: Text;
        Blocked: Boolean;
        BlockedText: Text;

        TextOk: Text;
        ServerResponseLbl: Label 'Message from Server: %1';
    begin
        //               <response>
        //                  <status>0</status>
        //                  <errordescription/>
        //                  <member contactno="C000497">
        //                     <membernumber>MM-DEMO-00319</membernumber>
        //                     <firstname>Avg272</firstname>
        //                     <middlename/>
        //                     <lastname>Test</lastname>
        //                     <address>street</address>
        //                     <postcode>121212</postcode>
        //                     <city>city</city>
        //                     <country>DK</country>
        //                     <birthday>2001-02-16</birthday>
        //                     <gender id="0"/>
        //                     <newsletter id="0"/>
        //                     <phoneno>+4512345678</phoneno>
        //                     <email>avg272@navipartner.dk</email>
        //                     <notificationmethod id="4">Default</notificationmethod>
        //                     <memberships>
        //                        <membership membershipnumber="MS-DEMO-00285">
        //                           <membershipcode>GOLD</membershipcode>
        //                           <role>Member</role>
        //                           <gdpr_approval/>
        //                           <cards>
        //                              <cardnumber>4552MC-DEMO-001857</cardnumber>
        //                              <expirydate>2022-10-25</expirydate>
        //                              <blocked>false</blocked>
        //                           </cards>
        //                        </membership>
        //                     </memberships>
        //                  </member>
        //               </response>

        TextOk := GetXmlText20(ResponseNode.AsXmlElement(), 'status', true);
        NotValidReason := StrSubstNo(ServerResponseLbl, _NpXmlDomMgt.GetXmlText(ResponseNode.AsXmlElement(), 'errordescription', 1000, true));
        if (TextOk = '0') then
            exit(false);

        ResponseNode.SelectNodes('descendant::member', MemberNodeList);
        foreach MemberNode in MemberNodeList do begin
            MemberElement := MemberNode.AsXmlElement();

            TmpMemberInfoCapture.Init();
            TmpMemberInfoCapture."External Member No" := GetXmlText20(MemberElement, 'membernumber', false);
            TmpMemberInfoCapture."First Name" := GetXmlText50(MemberElement, 'firstname', false);
            TmpMemberInfoCapture."Last Name" := GetXmlText50(MemberElement, 'lastname', false);
            TmpMemberInfoCapture."E-Mail Address" := GetXmlText80(MemberElement, 'email', false);
            TmpMemberInfoCapture.Address := GetXmlText100(MemberElement, 'address', false);
            TmpMemberInfoCapture.City := GetXmlText50(MemberElement, 'city', false);
            TmpMemberInfoCapture."Phone No." := GetXmlText30(MemberElement, 'phoneno', false);
            TmpMemberInfoCapture."Post Code Code" := GetXmlText20(MemberElement, 'postcode', false);
            TmpMemberInfoCapture."External Card No." := GetXmlText100(MemberElement, 'cardnumber', false);

            if (TmpMemberInfoCapture."External Card No." <> '') then begin
                TmpMemberInfoCapture."Entry No." := TmpMemberInfoCapture.Count() + 1;
                TmpMemberInfoCapture.Insert();
            end;

            if (TmpMemberInfoCapture."External Card No." = '') then begin
                if (MemberNode.SelectNodes('descendant::memberships/membership', MembershipNodeList)) then begin
                    foreach MembershipNode in MembershipNodeList do begin
                        MembershipElement := MembershipNode.AsXmlElement();

                        TmpMemberInfoCapture."External Membership No." := GetXmlAttributeText20(MembershipElement, 'membershipnumber', true);
                        TmpMemberInfoCapture."Membership Code" := GetXmlText100(MembershipElement, 'membershipcode', false);

                        if (not MembershipNode.SelectNodes('descendant::cards/card', CardNodeList)) then
                            if (not MembershipNode.SelectNodes('descendant::cards', CardNodeList)) then // Legacy card reported as this element
                                Clear(CardNodeList); // card descendent not found

                        foreach CardNode in CardNodeList do begin
                            CardElement := CardNode.AsXmlElement();

                            TmpMemberInfoCapture."External Card No." := GetXmlText100(CardElement, 'cardnumber', false);
                            ExpiryDate := 0D;
                            ExpiryDateText := GetXmlText20(CardElement, 'expirydate', false);
                            if (ExpiryDateText <> '') then
                                Evaluate(ExpiryDate, ExpiryDateText, 9);

                            Blocked := false;
                            BlockedText := GetXmlText20(CardElement, 'blocked', false);
                            if (BlockedText <> '') then
                                Evaluate(Blocked, BlockedText, 9);

                            TmpMemberInfoCapture."Entry No." := TmpMemberInfoCapture.Count() + 1;
                            if (ExpiryDate >= Today()) and (not Blocked) then
                                TmpMemberInfoCapture.Insert();
                        end;
                    end;
                end;
            end;
        end;

        NotValidReason := '';
        exit(true);
    end;


    local procedure UpdateMemberFieldSoapXmlRequest(RequestMemberFieldUpdate: Record "NPR MM Request Member Update"; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlText: Text;
    begin
        XmlText :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<mem:MemberFieldUpdate>' +
                    StrSubstNo('<mem:entryNo>%1</mem:entryNo>', RequestMemberFieldUpdate."Remote Entry No.") +
                    StrSubstNo('<mem:currentValue>%1</mem:currentValue>', RequestMemberFieldUpdate."Current Value") +
                    StrSubstNo('<mem:newValue>%1</mem:newValue>', RequestMemberFieldUpdate."New Value") +
                '</mem:MemberFieldUpdate>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        SoapAction := 'MemberFieldUpdate';

        XmlDocument.ReadFrom(XmlText, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure CreateSearchMemberSoapXmlRequest(MemberInfoCapture: Record "NPR MM Member Info Capture"; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        XmlText: Text;
    begin
        XmlText :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<mem:SearchMembers>' +
                    '<mem:searchMember>' +
                        CreateSearchMemberRequest(MemberInfoCapture) +
                    '</mem:searchMember>' +
                '</mem:SearchMembers>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        SoapAction := 'SearchMember';

        XmlDocument.ReadFrom(XmlText, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;


    local procedure CreateRequestMemberUpdateSoapXmlRequest(CardNumber: Text[100]; var SoapAction: Text[50]; var XmlDoc: XmlDocument)
    var
        NameSpace1, NameSpace2 : Text;
        Request, Body, Envelope : XmlElement;
    begin
        /**
        XmlText :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<mem:RequestMemberFieldUpdate>' +
                    StrSubstNo('<mem:memberCardNumber>%1</mem:memberCardNumber>', CardNumber) +
                    StrSubstNo('<mem:fieldId>%1</mem:fieldId>', 0) + // All fields
                    StrSubstNo('<mem:scannerStationId>%1</mem:scannerStationId>', '') +
                '</mem:RequestMemberFieldUpdate>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        **/
        SoapAction := 'RequestMemberFieldUpdate';
        NameSpace1 := 'http://schemas.xmlsoap.org/soap/envelope/';
        NameSpace2 := 'urn:microsoft-dynamics-schemas/codeunit/member_services';

        Request := XmlElement.Create('RequestMemberFieldUpdate', NameSpace2);
        Request.Add(AddElement('memberCardNumber', CardNumber, NameSpace2));
        Request.Add(AddElement('fieldId', '0', NameSpace2));
        Request.Add(AddElement('scannerStationId', '', NameSpace2));

        Body := XmlElement.Create('Body', NameSpace1);
        Body.Add(Request);

        Envelope := XmlElement.Create('Envelope', NameSpace1);
        Envelope.Add(XmlElement.Create('Header', NameSpace1));
        Envelope.Add(Body);

        XmlDoc := XmlDocument.Create();
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'no'));
        XmlDoc.Add(Envelope);
    end;

    local procedure AddElement(Name: Text; ElementValue: Text; XmlNs: Text): XmlElement
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(Name, XmlNs);
        Element.Add(ElementValue);
        exit(Element);
    end;


    local procedure CreateSearchMemberRequest(MemberInfoCapture: Record "NPR MM Member Info Capture") XmlText: Text
    var
        Buffer: TextBuilder;
    begin
        Buffer.AppendLine('<searchmembers>');
        Buffer.AppendLine('<request>');
        Buffer.AppendLine(StrSubstNo('<firstname>%1</firstname>', XmlSafe(MemberInfoCapture."First Name")));
        Buffer.AppendLine(StrSubstNo('<lastname>%1</lastname>', XmlSafe(MemberInfoCapture."Last Name")));
        Buffer.AppendLine(StrSubstNo('<phonenumber>%1</phonenumber>', XmlSafe(MemberInfoCapture."Phone No.")));
        Buffer.AppendLine(StrSubstNo('<email>%1</email>', XmlSafe(MemberInfoCapture."E-Mail Address")));
        Buffer.AppendLine(StrSubstNo('<membernumber>%1</membernumber>', XmlSafe(MemberInfoCapture."External Member No")));
        Buffer.AppendLine(StrSubstNo('<cardnumber>%1</cardnumber>', XmlSafe(MemberInfoCapture."External Card No.")));
        Buffer.AppendLine(StrSubstNo('<limitresultset>%1</limitresultset>', Format(MemberInfoCapture.Quantity, 0, 9)));
        Buffer.AppendLine('</request>');
        Buffer.AppendLine('</searchmembers>');

        XmlText := Buffer.ToText();
    end;


    procedure XmlSafe(InText: Text): Text
    begin
        exit(DelChr(InText, '<=>', '<>&/'));
    end;

    local procedure SetRequestHeadersAuthorization(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var RequestHeaders: HttpHeaders)
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        iAuth: Interface "NPR API IAuthorization";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        iAuth := NPRRemoteEndpointSetup.AuthType;
        case NPRRemoteEndpointSetup.AuthType of
            NPRRemoteEndpointSetup.AuthType::Basic:
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password Key", AuthParamsBuff);
            NPRRemoteEndpointSetup.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(NPRRemoteEndpointSetup."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;

    procedure TestEndpointConnection(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup")
    var
        SoapAction: Text[50];
        XmlDocRequest: XmlDocument;
        XmlDocResponse: XmlDocument;
        NotValidReason: Text;
        InputTxt: Text;
    begin
        InputTxt := 'test';
        TestEndpointConnectionRequest(SoapAction, InputTxt, XmlDocRequest);
        if (not WebServiceApi(NPRRemoteEndpointSetup, 'Ping', NotValidReason, XmlDocRequest, XmlDocResponse)) then
            Error(NotValidReason)
        else begin
            if TestEndpointConnectionResponse(XmlDocResponse, InputTxt, NotValidReason) then
                Message('Connection OK')
            else
                Message(NotValidReason);
        end;
    end;

    local procedure TestEndpointConnectionRequest(var SoapAction: Text[50]; InputTxt: Text; var XmlDoc: XmlDocument)
    var
        XmlRequest: Text;
    begin
        SoapAction := 'Ping';
        XmlRequest :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mem="urn:microsoft-dynamics-schemas/codeunit/member_services">' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          '      <mem:Ping>' +
          '         <mem:inputTxt>%1</mem:inputTxt>' +
          '      </mem:Ping>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>';
        XmlRequest := StrSubstNo(XmlRequest, InputTxt);
        XmlDocument.ReadFrom(XmlRequest, XmlDoc);
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
    end;

    local procedure TestEndpointConnectionResponse(var XmlDoc: XmlDocument; InputTxt: Text; var ResponseText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        ResultTxt: Text;
        XmlMessage: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin
        XmlDoc.WriteTo(XmlMessage);
        XmlMessage := XmlDomMgt.RemoveNamespaces(XmlMessage);
        XmlDocument.ReadFrom(XmlMessage, XmlDoc);
        if (not XmlDoc.GetRoot(Element)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlMessage));
            exit(false);
        end;
        ResultTxt := NpXmlDomMgt.GetXmlText(Element, '//Ping_Result/return_value', 0, false);
        if ResultTxt = 'Pong:' + InputTxt then
            exit(true)
        else begin
            ResponseText := 'Unexpected Response Text.';
            exit(false);
        end;
    end;

    local procedure GetXmlText20(Element: XmlElement; NodePath: Text; Required: Boolean): Text[20]
    begin
        exit(_NpXmlDomMgt.GetXmlText(Element, NodePath, 20, Required));
    end;

    local procedure GetXmlText30(Element: XmlElement; NodePath: Text; Required: Boolean): Text[30]
    begin
        exit(_NpXmlDomMgt.GetXmlText(Element, NodePath, 30, Required));
    end;

    local procedure GetXmlText50(Element: XmlElement; NodePath: Text; Required: Boolean): Text[50]
    begin
        exit(_NpXmlDomMgt.GetXmlText(Element, NodePath, 50, Required));
    end;

    local procedure GetXmlText80(Element: XmlElement; NodePath: Text; Required: Boolean): Text[80]
    begin
        exit(_NpXmlDomMgt.GetXmlText(Element, NodePath, 80, Required));
    end;

    local procedure GetXmlText100(Element: XmlElement; NodePath: Text; Required: Boolean): Text[100]
    begin
        exit(_NpXmlDomMgt.GetXmlText(Element, NodePath, 100, Required));
    end;

    local procedure GetXmlAttributeText20(Element: XmlElement; AttributeName: Text; Required: Boolean): Text[20]
    begin
        exit(CopyStr(_NpXmlDomMgt.GetXmlAttributeText(Element, AttributeName, Required), 1, 20));
    end;



}
#pragma warning restore
