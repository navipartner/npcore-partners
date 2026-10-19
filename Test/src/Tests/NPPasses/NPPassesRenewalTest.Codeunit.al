codeunit 85540 "NPR NP Passes Renewal Test"
{
    // Renewal side of NP Passes: the pass is updated through the webhook, the link goes out in the renewal success
    // mail, and NP Passes types get no wallet mail on renewal.
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";
        _Mock: Codeunit "NPR NP Passes Notifier Mock";
        _ScenarioInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure EndToEnd_RenewalWhileActiveThroughApi_OnlyUpdatesPass()
    var
        Membership: Record "NPR MM Membership";
        Card: Record "NPR MM Member Card";
        MembershipId: Text;
        MemberEntryNo: Integer;
    begin
        ArrangeNPPassesGoldMembership(MembershipId, MemberEntryNo);
        Membership.GetBySystemId(MembershipId);

        RenewThroughApi(MembershipId);

        _Assert.IsFalse(WalletCreateExists(Membership."Entry No."), 'A renewal sends no wallet mail for NP Passes types');
        Card.SetRange("Membership Entry No.", Membership."Entry No.");
        Card.SetRange("Member Entry No.", MemberEntryNo);
        Card.FindLast();
        _Assert.IsTrue(_Mock.WasNotified(Serial(Card.SystemId)), 'The renewal refreshes the existing pass');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure EndToEnd_LateRenewalThroughApi_NoWalletMail()
    var
        Membership: Record "NPR MM Membership";
        MembershipId: Text;
        MemberEntryNo: Integer;
    begin
        // T-GOLD renews ASAP, so the new period starts today.
        ArrangeNPPassesGoldMembership(MembershipId, MemberEntryNo);
        Membership.GetBySystemId(MembershipId);
        EndCurrentPeriodYesterday(Membership."Entry No.");

        RenewThroughApi(MembershipId);

        _Assert.IsFalse(WalletCreateExists(Membership."Entry No."), 'The role''s legacy Wallet Pass Id is empty for NP Passes types, which must not trigger a wallet mail');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure EndToEnd_RenewalThroughApi_RenewalSuccessIncludesNPPass()
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MembershipId: Text;
        MemberEntryNo: Integer;
    begin
        ArrangeNPPassesGoldMembership(MembershipId, MemberEntryNo);
        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Create Renewal Success Notif" := true;
        MembershipSetup.Modify();
        CreateRenewalSuccessNotificationSetup(MembershipSetup."Community Code", MembershipSetup.Code, true);
        Membership.GetBySystemId(MembershipId);

        RenewThroughApi(MembershipId);

        MembershipNotification.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipNotification.SetRange("Notification Trigger", MembershipNotification."Notification Trigger"::RENEWAL_SUCCESS);
        _Assert.IsTrue(MembershipNotification.FindLast(), 'The renewal creates the renewal success mail');
        _Assert.IsTrue(MembershipNotification."Include NP Pass", 'The renewal success mail carries the pass link when its setup includes the NP Pass');
        _Assert.AreEqual(Today(), MembershipNotification."Date To Notify", 'Without a gap the mail goes out today');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalSuccess_SetupWithoutNPPass_NoLink()
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipEntryNo: Integer;
    begin
        MembershipEntryNo := ArrangeRenewalSuccessMembership(false);
        SeedActivePeriod(MembershipEntryNo);
        SeedPeriod(MembershipEntry, MembershipEntryNo, CalcDate('<+1M+1D>', Today()), CalcDate('<+1Y>', Today()));

        MemberNotification.AddMembershipRenewalSuccessNotification(MembershipEntry);

        FindRenewalSuccess(MembershipNotification, MembershipEntryNo);
        _Assert.IsFalse(MembershipNotification."Include NP Pass", 'Without Include NP Pass the renewal success mail stays as before');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalSuccess_EarlyRenewal_SentToday()
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipEntryNo: Integer;
    begin
        MembershipEntryNo := ArrangeRenewalSuccessMembership(true);
        SeedActivePeriod(MembershipEntryNo);
        SeedPeriod(MembershipEntry, MembershipEntryNo, CalcDate('<+1M+1D>', Today()), CalcDate('<+1Y>', Today()));

        MemberNotification.AddMembershipRenewalSuccessNotification(MembershipEntry);

        FindRenewalSuccess(MembershipNotification, MembershipEntryNo);
        _Assert.AreEqual(Today(), MembershipNotification."Date To Notify", 'The membership is valid today, so the mail goes out now even though the new period starts later');
        _Assert.IsTrue(MembershipNotification."Include NP Pass", 'The link is included');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletRequest_ReplacementCard_CreatesLink()
    var
        MembershipRole: Record "NPR MM Membership Role";
        OldCard: Record "NPR MM Member Card";
        NewCard: Record "NPR MM Member Card";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipEntryNo: Integer;
    begin
        MembershipEntryNo := ArrangeMembership();
        SeedActivePeriod(MembershipEntryNo);
        SeedMemberCard(OldCard, MembershipEntryNo, 990113, true);
        SeedMemberCard(NewCard, MembershipEntryNo, 990113, false); // Card Expired Action = NEW
        MembershipRole.Init();
        MembershipRole."Membership Entry No." := MembershipEntryNo;
        MembershipRole."Member Entry No." := 990113;
        MembershipRole."Wallet Pass Id" := 'oldcardserial'; // still the old card's serial
        MembershipRole.Insert();

        MembershipNotification.Get(MemberNotification.CreateWalletWithoutSendingNotification(MembershipEntryNo, 990113, NewCard."Entry No.", Today()));

        _Assert.AreEqual(MembershipNotification."Notification Trigger"::WALLET_CREATE, MembershipNotification."Notification Trigger", 'A card without a link needs one, whatever the role''s pass id says');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SendOrUpdate_LegacyPassIdWithoutNPPass_SendsLink()
    var
        MembershipRole: Record "NPR MM Membership Role";
        Card: Record "NPR MM Member Card";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipEntryNo: Integer;
    begin
        MembershipEntryNo := ArrangeMembership();
        SeedActivePeriod(MembershipEntryNo);
        SeedMemberCard(Card, MembershipEntryNo, 990114, false);
        MembershipRole.Init();
        MembershipRole."Membership Entry No." := MembershipEntryNo;
        MembershipRole."Member Entry No." := 990114;
        MembershipRole."Wallet Pass Id" := 'LEGACYPASSID'; // from the legacy pass server
        MembershipRole.Insert();

        MembershipNotification.Get(MemberNotification.CreateWalletSendOrUpdateNotification(MembershipEntryNo, 990114, Today()));

        _Assert.AreEqual(MembershipNotification."Notification Trigger"::WALLET_CREATE, MembershipNotification."Notification Trigger", 'For NP Passes types the card decides, not the legacy pass id');
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    // T-GOLD from the member module smoke-test scenario, put on NP Passes, with one member whose card was sent a link.
    local procedure ArrangeNPPassesGoldMembership(var MembershipId: Text; var MemberEntryNo: Integer)
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Facade: Codeunit "NPR NP Passes Facade";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        ResponseBody: JsonObject;
        MemberId: Text;
    begin
        if (not _ScenarioInitialized) then begin
            MemberLibrary.Initialize();
            MemberLibrary.CreateScenario_SmokeTest();
            LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Membership');
            _ScenarioInitialized := true;
        end;

        ConfigureSetup();
        _Mock.Reset();
        Facade.SetNotifier(_Mock);

        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Enable NP Pass Integration" := true;
        MembershipSetup."NP Passes Layout Handle" := '9e99360037c446e6836a3c933c721e56';
        MembershipSetup.Modify();
        // A wallet mail setup exists, so a test that finds no wallet mail proves none was created.
        if (not WalletCreateSetupExists('T-GOLD')) then
            CreateWalletCreateNotificationSetup('T-GOLD');

        Body.Add('itemNumber', 'T-320100');
        Body.Add('activationDate', CalcDate('<-6M>', Today()));
        ResponseBody := GetResponseBodyOrError(InvokeApi('POST', 'membership', Body), 'Create membership failed.');
        MembershipId := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipId', true);

        MemberId := AddMemberThroughApi(MembershipId);
        Member.GetBySystemId(MemberId);
        MemberEntryNo := Member."Entry No.";

        Membership.GetBySystemId(MembershipId);
        Card.SetRange("Membership Entry No.", Membership."Entry No.");
        Card.SetRange("Member Entry No.", MemberEntryNo);
        if (not Card.FindLast()) then
            SeedMemberCard(Card, Membership."Entry No.", MemberEntryNo, true)
        else begin
            Card."NP Passes Link Sent At" := CurrentDateTime();
            Card.Modify();
        end;
    end;

    local procedure AddMemberThroughApi(MembershipId: Text): Text
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        JsonHelper: Codeunit "NPR Json Helper";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Body: JsonObject;
        MemberJson: JsonObject;
        ResponseBody: JsonObject;
    begin
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        MemberJson.Add('firstName', MemberInfoCapture."First Name");
        MemberJson.Add('lastName', MemberInfoCapture."Last Name");
        MemberJson.Add('email', MemberInfoCapture."E-Mail Address");
        MemberJson.Add('phoneNo', MemberInfoCapture."Phone No.");
        MemberJson.Add('birthday', CalcDate('<-30Y>', Today()));
        Body.Add('member', MemberJson);

        ResponseBody := GetResponseBodyOrError(InvokeApi('POST', StrSubstNo('membership/%1/addMember', MembershipId), Body), 'Add member failed.');
        exit(JsonHelper.GetJText(ResponseBody.AsToken(), 'member.memberId', true));
    end;

    local procedure EndCurrentPeriodYesterday(MembershipEntryNo: Integer)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        MembershipEntry.SetRange("Membership Entry No.", MembershipEntryNo);
        MembershipEntry.FindLast();
        MembershipEntry."Valid Until Date" := CalcDate('<-1D>', Today());
        MembershipEntry.Modify();
    end;

    local procedure RenewThroughApi(MembershipId: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        ResponseBody: JsonObject;
        RenewBody: JsonObject;
        OptionsToken: JsonToken;
        OptionToken: JsonToken;
    begin
        ResponseBody := GetResponseBodyOrError(InvokeApi('GET', StrSubstNo('membership/%1/renewalOptions', MembershipId), EmptyBody()), 'Get renewal options failed.');
        if (not ResponseBody.AsToken().SelectToken('membership.options', OptionsToken)) then
            Error('No renewal options returned.');
        OptionsToken.AsArray().Get(0, OptionToken);

        RenewBody.Add('optionId', JsonHelper.GetJText(OptionToken, 'optionId', true));
        GetResponseBodyOrError(InvokeApi('POST', StrSubstNo('membership/%1/renew', MembershipId), RenewBody), 'Renew failed.');
    end;

    local procedure InvokeApi(Method: Text; Path: Text; Body: JsonObject): JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Headers.Add('x-api-version', Format(Today(), 0, 9));
        exit(LibraryNPRetailAPI.CallApi(Method, Path, Body, QueryParameters, Headers));
    end;

    local procedure GetResponseBodyOrError(Response: JsonObject; ErrorText: Text) Body: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        ResponseText: Text;
    begin
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        if (not LibraryNPRetailAPI.IsSuccessStatusCode(Response)) then begin
            Body.WriteTo(ResponseText);
            Error('%1 Response: %2', ErrorText, ResponseText);
        end;
    end;

    local procedure EmptyBody(): JsonObject
    var
        Body: JsonObject;
    begin
        exit(Body);
    end;

    local procedure WalletCreateSetupExists(MembershipCode: Code[20]): Boolean
    var
        NotificationSetup: Record "NPR MM Member Notific. Setup";
    begin
        NotificationSetup.SetRange(Type, NotificationSetup.Type::WALLET_CREATE);
        NotificationSetup.SetRange("Membership Code", MembershipCode);
        exit(not NotificationSetup.IsEmpty());
    end;

    local procedure Serial(Id: Guid): Text
    begin
        exit(LowerCase(DelChr(Format(Id), '=', '{}-')));
    end;

    local procedure ArrangeMembership(): Integer
    var
        MembershipCode: Code[20];
    begin
        ConfigureSetup();
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56', '');
        CreateWalletCreateNotificationSetup(MembershipCode);
        exit(SeedMembership(MembershipCode, ''));
    end;

    // An NP Passes type with renewal success mails switched on, and a membership with no periods yet.
    local procedure ArrangeRenewalSuccessMembership(IncludeNPPass: Boolean): Integer
    var
        Community: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipCode: Code[20];
    begin
        ConfigureSetup();
        Community.Init();
        Community.Code := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(Community.Code));
        Community.Insert();
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56', Community.Code);
        MembershipSetup.Get(MembershipCode);
        MembershipSetup."Create Renewal Success Notif" := true;
        MembershipSetup.Modify();
        CreateRenewalSuccessNotificationSetup(Community.Code, MembershipCode, IncludeNPPass);
        exit(SeedMembership(MembershipCode, Community.Code));
    end;

    local procedure WalletCreateExists(MembershipEntryNo: Integer): Boolean
    var
        MembershipNotification: Record "NPR MM Membership Notific.";
    begin
        MembershipNotification.SetRange("Membership Entry No.", MembershipEntryNo);
        MembershipNotification.SetRange("Notification Trigger", MembershipNotification."Notification Trigger"::WALLET_CREATE);
        exit(not MembershipNotification.IsEmpty());
    end;

    local procedure FindRenewalSuccess(var MembershipNotification: Record "NPR MM Membership Notific."; MembershipEntryNo: Integer)
    begin
        MembershipNotification.SetRange("Membership Entry No.", MembershipEntryNo);
        MembershipNotification.SetRange("Notification Trigger", MembershipNotification."Notification Trigger"::RENEWAL_SUCCESS);
        _Assert.IsTrue(MembershipNotification.FindLast(), 'A renewal success mail is created');
    end;

    local procedure ConfigureSetup()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        if (not Setup.Get()) then begin
            Setup.Init();
            Setup.Insert();
        end;
        Setup.Validate("Base URL", 'https://np-passes-generator.example.dev');
        Setup.Enabled := true;
        Setup.SetSigningSecret(SecretStrSubstNo('test-secret-do-not-use'));
        Setup.Modify();
    end;

    local procedure CreateMembershipSetupWithHandle(LayoutHandle: Text[40]; CommunityCode: Code[20]) MembershipCode: Code[20]
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipCode := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(MembershipCode));
        MembershipSetup.Init();
        MembershipSetup.Code := MembershipCode;
        MembershipSetup."Community Code" := CommunityCode;
        MembershipSetup."Enable NP Pass Integration" := true;
        MembershipSetup."NP Passes Layout Handle" := LayoutHandle;
        MembershipSetup.Insert();
    end;

    local procedure CreateWalletCreateNotificationSetup(MembershipCode: Code[20])
    var
        NotificationSetup: Record "NPR MM Member Notific. Setup";
    begin
        NotificationSetup.Init();
        NotificationSetup.Code := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(NotificationSetup.Code));
        NotificationSetup.Type := NotificationSetup.Type::WALLET_CREATE;
        NotificationSetup."Membership Code" := MembershipCode;
        NotificationSetup.Insert();
    end;

    local procedure CreateRenewalSuccessNotificationSetup(CommunityCode: Code[20]; MembershipCode: Code[20]; IncludeNPPass: Boolean)
    var
        NotificationSetup: Record "NPR MM Member Notific. Setup";
    begin
        NotificationSetup.Init();
        NotificationSetup.Code := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(NotificationSetup.Code));
        NotificationSetup.Type := NotificationSetup.Type::RENEWAL_SUCCESS;
        NotificationSetup."Community Code" := CommunityCode;
        NotificationSetup."Membership Code" := MembershipCode;
        NotificationSetup."Include NP Pass" := IncludeNPPass;
        NotificationSetup.Insert();
    end;

    local procedure SeedMembership(MembershipCode: Code[20]; CommunityCode: Code[20]): Integer
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.Init();
        Membership."Membership Code" := MembershipCode;
        Membership."Community Code" := CommunityCode;
        Membership."External Membership No." := CopyStr('MS-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(Membership."External Membership No."));
        Membership.Insert();
        exit(Membership."Entry No.");
    end;

    local procedure SeedActivePeriod(MembershipEntryNo: Integer)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        SeedPeriod(MembershipEntry, MembershipEntryNo, CalcDate('<-1M>', Today()), CalcDate('<+1M>', Today()));
    end;

    local procedure SeedPeriod(var MembershipEntry: Record "NPR MM Membership Entry"; MembershipEntryNo: Integer; ValidFrom: Date; ValidUntil: Date)
    begin
        MembershipEntry.Init();
        MembershipEntry."Membership Entry No." := MembershipEntryNo;
        MembershipEntry.Context := MembershipEntry.Context::NEW;
        MembershipEntry."Valid From Date" := ValidFrom;
        MembershipEntry."Valid Until Date" := ValidUntil;
        MembershipEntry.Insert();
    end;

    local procedure SeedMemberCard(var MemberCard: Record "NPR MM Member Card"; MembershipEntryNo: Integer; MemberEntryNo: Integer; LinkSent: Boolean)
    begin
        MemberCard.Init();
        MemberCard."Membership Entry No." := MembershipEntryNo;
        MemberCard."Member Entry No." := MemberEntryNo;
        MemberCard."External Card No." := CopyStr('CARD-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(MemberCard."External Card No."));
        if (LinkSent) then
            MemberCard."NP Passes Link Sent At" := CurrentDateTime();
        MemberCard.Insert();
    end;
}
