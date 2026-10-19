codeunit 85444 "NPR NP Passes Webhook Test"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";
        _Mock: Codeunit "NPR NP Passes Notifier Mock";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NotConfigured_DoesNotNotify()
    var
        Facade: Codeunit "NPR NP Passes Facade";
    begin
        Arrange(false);

        _Assert.IsFalse(Facade.NotifyPassUpdated(CreateGuid()), 'Should not notify when NP Passes is disabled');
        _Assert.AreEqual(0, _Mock.CallCount(), 'Notifier must not be called when disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EmptySerialNumber_DoesNotNotify()
    var
        Facade: Codeunit "NPR NP Passes Facade";
        EmptyGuid: Guid;
    begin
        Arrange(true);

        _Assert.IsFalse(Facade.NotifyPassUpdated(EmptyGuid), 'Should not notify without a serial number');
        _Assert.AreEqual(0, _Mock.CallCount(), 'Notifier must not be called without a serial number');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Configured_NotifiesWithDashlessLowercaseSerial()
    var
        Facade: Codeunit "NPR NP Passes Facade";
        SerialNumber: Guid;
    begin
        Arrange(true);
        SerialNumber := CreateGuid();

        _Assert.IsTrue(Facade.NotifyPassUpdated(SerialNumber), 'Should notify when configured');

        _Assert.AreEqual(1, _Mock.CallCount(), 'Exactly one notification expected');
        _Assert.AreEqual(Serial(SerialNumber), _Mock.LastSerialNumber(), 'Serial number must be the dashless lowercase SystemId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SameCardTwice_SignalsTwice()
    var
        Facade: Codeunit "NPR NP Passes Facade";
        SerialNumber: Guid;
    begin
        Arrange(true);
        SerialNumber := CreateGuid();

        _Assert.IsTrue(Facade.NotifyPassUpdated(SerialNumber), 'First signal is emitted');
        _Assert.IsTrue(Facade.NotifyPassUpdated(SerialNumber), 'Second signal is emitted');

        _Assert.AreEqual(2, _Mock.CallCount(), 'Every call emits; duplicates are collapsed by np-passes, not by BC');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Adapter_MembershipWithTwoCards_NotifiesEachCard()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Card1: Record "NPR MM Member Card";
        Card2: Record "NPR MM Member Card";
        MembershipEntryNo: Integer;
    begin
        Arrange(true);
        MembershipEntryNo := SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56'));
        SeedMemberCard(Card1, MembershipEntryNo, 1, false, false);
        SeedMemberCard(Card2, MembershipEntryNo, 2, false, false);

        Adapter.NotifyMembership(MembershipEntryNo);

        _Assert.AreEqual(2, _Mock.CallCount(), 'Both cards should be notified');
        _Assert.IsTrue(_Mock.WasNotified(Serial(Card1.SystemId)), 'Card 1 should be notified');
        _Assert.IsTrue(_Mock.WasNotified(Serial(Card2.SystemId)), 'Card 2 should be notified');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Adapter_TemporaryCardSkipped_BlockedCardIncluded()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        ActiveCard: Record "NPR MM Member Card";
        TemporaryCard: Record "NPR MM Member Card";
        BlockedCard: Record "NPR MM Member Card";
        MembershipEntryNo: Integer;
    begin
        Arrange(true);
        MembershipEntryNo := SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56'));
        SeedMemberCard(ActiveCard, MembershipEntryNo, 1, false, false);
        SeedMemberCard(TemporaryCard, MembershipEntryNo, 2, true, false);
        SeedMemberCard(BlockedCard, MembershipEntryNo, 3, false, true);

        Adapter.NotifyMembership(MembershipEntryNo);

        _Assert.AreEqual(2, _Mock.CallCount(), 'Active and blocked cards notified, temporary card skipped');
        _Assert.IsTrue(_Mock.WasNotified(Serial(ActiveCard.SystemId)), 'Active card should be notified');
        _Assert.IsTrue(_Mock.WasNotified(Serial(BlockedCard.SystemId)), 'Blocked card should be notified so the pass can show the blocked state');
        _Assert.IsFalse(_Mock.WasNotified(Serial(TemporaryCard.SystemId)), 'Temporary card must not be notified');
        _Assert.IsFalse(Adapter.NotifyCard(TemporaryCard), 'NotifyCard must refuse a temporary card as well');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Adapter_CardNeverOfferedAPass_DoesNotNotify()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        OfferedCard: Record "NPR MM Member Card";
        NeverOfferedCard: Record "NPR MM Member Card";
        MembershipEntryNo: Integer;
    begin
        Arrange(true);
        MembershipEntryNo := SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56'));
        SeedMemberCard(OfferedCard, MembershipEntryNo, 1, false, false);
        SeedMemberCard(NeverOfferedCard, MembershipEntryNo, 2, false, false);
        NeverOfferedCard."NP Passes Link Sent At" := 0DT;
        NeverOfferedCard.Modify();

        Adapter.NotifyMembership(MembershipEntryNo);

        _Assert.AreEqual(1, _Mock.CallCount(), 'Only the card that was offered a pass should be notified');
        _Assert.IsTrue(_Mock.WasNotified(Serial(OfferedCard.SystemId)), 'Offered card should be notified');
        _Assert.IsFalse(_Mock.WasNotified(Serial(NeverOfferedCard.SystemId)), 'A card whose link was never sent has no pass to refresh');
        _Assert.IsFalse(Adapter.NotifyCard(NeverOfferedCard), 'NotifyCard must refuse a card that was never offered a pass');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LayoutHandleChanged_DoesNotSignalUntilWalletsAreUpdated()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberNotification: Codeunit "NPR MM Member Notification";
        Card: Record "NPR MM Member Card";
        MembershipCode: Code[20];
        MembershipEntryNo: Integer;
    begin
        Arrange(true);
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        MembershipEntryNo := SeedMembership(MembershipCode);
        SeedMemberCard(Card, MembershipEntryNo, 1, false, false);

        MembershipSetup.Get(MembershipCode);
        MembershipSetup.Validate("NP Passes Layout Handle", 'aaaa1111bbbb2222cccc3333dddd4444');
        MembershipSetup.Modify(true);
        _Assert.AreEqual(0, _Mock.CallCount(), 'Saving a new handle must not fan out on its own');

        // Same call Update All Wallets makes per role
        MemberNotification.CreateUpdateWalletNotification(MembershipEntryNo, 1, 0, Today());

        _Assert.AreEqual(1, _Mock.CallCount(), 'The issued card is signalled by the wallet update');
        _Assert.AreEqual(Serial(Card.SystemId), _Mock.LastSerialNumber(), 'The issued card is signalled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Adapter_MembershipTypeWithoutHandle_DoesNotNotify()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Card: Record "NPR MM Member Card";
        MembershipEntryNo: Integer;
    begin
        Arrange(true);
        MembershipEntryNo := SeedMembership(CreateMembershipSetupWithHandle(''));
        SeedMemberCard(Card, MembershipEntryNo, 1, false, false);

        Adapter.NotifyMembership(MembershipEntryNo);

        _Assert.AreEqual(0, _Mock.CallCount(), 'No handle configured - notifier must not be called');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletUpdateNotification_WithoutSigningSecret_StillUsesWebhook()
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
        Setup: Record "NPR NP Passes Setup";
        Card: Record "NPR MM Member Card";
        MembershipEntryNo: Integer;
        EntryNo: Integer;
    begin
        Arrange(true);
        Setup.Get();
        Setup.Enabled := false;
        Setup.DeleteSigningSecret();
        Setup.Enabled := true; // enabled without a secret, as a config package or an old row can leave it
        Setup.Modify();
        MembershipEntryNo := SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56'));
        SeedMemberCard(Card, MembershipEntryNo, 1, false, false);

        EntryNo := MemberNotification.CreateUpdateWalletNotification(MembershipEntryNo, 1, 0, Today());

        _Assert.AreEqual(0, EntryNo, 'The secret only guards links: updates must not fall back to legacy notification entries');
        _Assert.AreEqual(1, _Mock.CallCount(), 'The signal is emitted without a secret');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletUpdateNotification_UsesWebhook_WithoutNotificationSetup()
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
        Card: Record "NPR MM Member Card";
        MembershipEntryNo: Integer;
        EntryNo: Integer;
    begin
        Arrange(true);
        MembershipEntryNo := SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56'));
        SeedMemberCard(Card, MembershipEntryNo, 1, false, false);

        EntryNo := MemberNotification.CreateUpdateWalletNotification(MembershipEntryNo, 1, 0, Today());

        _Assert.AreEqual(0, EntryNo, 'No notification entry should be created when the webhook handles the update');
        _Assert.AreEqual(1, _Mock.CallCount(), 'The card pass should be signalled once');
        _Assert.AreEqual(Serial(Card.SystemId), _Mock.LastSerialNumber(), 'Serial must be the card SystemId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockMemberCard_SignalsThePass()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        SeedMemberCard(Card, SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')), 1, false, false);

        MembershipMgt.BlockMemberCard(Card."Entry No.", true);

        _Assert.AreEqual(1, _Mock.CallCount(), 'Blocking a card should signal its pass');
        _Assert.AreEqual(Serial(Card.SystemId), _Mock.LastSerialNumber(), 'Serial must be the card SystemId');
        Card.Get(Card."Entry No.");
        _Assert.IsTrue(Card.Blocked, 'The card is blocked');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockMemberCard_AlreadyInThatState_DoesNotSignal()
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        SeedMemberCard(Card, SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')), 1, false, false);

        MembershipMgt.BlockMemberCard(Card."Entry No.", false);

        _Assert.AreEqual(0, _Mock.CallCount(), 'No state change, no signal');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberEditedFromCode_WatchedField_SignalsPass()
    var
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        SeedMemberWithCard(Member, Card);

        Member.Get(Member."Entry No.");
        Member."First Name" := 'Renamed';
        Member.Modify();

        // Other tests in this codeunit seed cards for literal member numbers; assert this card, not the total count.
        _Assert.IsTrue(_Mock.WasNotified(Serial(Card.SystemId)), 'A name change made from code must signal the pass');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberEditedFromCode_AddressOnPass_SignalsPass()
    var
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        SeedMemberWithCard(Member, Card);

        Member.Get(Member."Entry No.");
        Member.City := 'Elsewhere';
        Member.Modify();

        _Assert.IsTrue(_Mock.WasNotified(Serial(Card.SystemId)), 'Every member field in the card DTO can be bound by a design and must signal the pass');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberEditedFromCode_FieldNotOnPass_DoesNotSignal()
    var
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        SeedMemberWithCard(Member, Card);

        Member.Get(Member."Entry No.");
        Member."Document ID" := 'DOC-1';
        Member.Modify();

        _Assert.AreEqual(0, _Mock.CallCount(), 'A field outside the card DTO must not signal the pass');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MembershipAutoRenewEnabledFromCode_SignalsPass()
    var
        Membership: Record "NPR MM Membership";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        Membership.Get(SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')));
        SeedMemberCard(Card, Membership."Entry No.", 1, false, false);

        Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
        Membership.Modify(true);

        _Assert.AreEqual(1, _Mock.CallCount(), 'Turning auto-renew on from code must signal the pass');
        _Assert.AreEqual(Serial(Card.SystemId), _Mock.LastSerialNumber(), 'Serial must be the card SystemId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MembershipCodeChangedFromCode_SignalsWhenNewTypeIsOnNPPasses()
    var
        Membership: Record "NPR MM Membership";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        Membership.Get(SeedMembership(CreateMembershipSetupWithHandle('')));
        SeedMemberCard(Card, Membership."Entry No.", 1, false, false);

        Membership."Membership Code" := CreateMembershipSetupWithHandle('aaaa1111bbbb2222cccc3333dddd4444');
        Membership.Modify();

        _Assert.AreEqual(1, _Mock.CallCount(), 'The new type decides, not the one stored before the write');
        _Assert.AreEqual(Serial(Card.SystemId), _Mock.LastSerialNumber(), 'Serial must be the card SystemId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MembershipAutoRenewTerminationRequested_DoesNotSignal()
    var
        Membership: Record "NPR MM Membership";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        Membership.Get(SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')));
        Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
        Membership.Modify();
        SeedMemberCard(Card, Membership."Entry No.", 1, false, false);
        _Mock.Reset();

        Membership."Auto-Renew" := Membership."Auto-Renew"::TERMINATION_REQUESTED;
        Membership.Modify();

        _Assert.AreEqual(0, _Mock.CallCount(), 'The pass shows autoRenewalActivated, which stays true while termination is requested');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MembershipDescriptionEdited_DoesNotSignal()
    var
        Membership: Record "NPR MM Membership";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        Membership.Get(SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')));
        SeedMemberCard(Card, Membership."Entry No.", 1, false, false);

        Membership.Description := 'Not on the pass';
        Membership.Modify();

        _Assert.AreEqual(0, _Mock.CallCount(), 'The pass shows the membership type description, not the membership description');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PatchMemberCard_SignalsPass()
    var
        MemberCardApiAgent: Codeunit "NPR MemberCardApiAgent";
        Request: Codeunit "NPR API Request";
        Card: Record "NPR MM Member Card";
        Body: JsonObject;
    begin
        Arrange(true);
        SeedMemberCard(Card, SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')), 1, false, false);
        Body.Add('expiryDate', CalcDate('<+1Y>', Today()));
        InitCardRequest(Request, "Http Method"::PATCH, Card, '', Body);

        MemberCardApiAgent.PatchMemberCard(Request);

        _Assert.AreEqual(1, _Mock.CallCount(), 'Patching the card expiry must signal the pass');
        _Assert.AreEqual(Serial(Card.SystemId), _Mock.LastSerialNumber(), 'Serial must be the card SystemId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetMemberCard_ReturnsCurrentPassDesignHandle()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCardApiAgent: Codeunit "NPR MemberCardApiAgent";
        Request: Codeunit "NPR API Request";
        Response: Codeunit "NPR API Response";
        Card: Record "NPR MM Member Card";
        Body: JsonObject;
        Token: JsonToken;
        MembershipCode: Code[20];
    begin
        Arrange(true);
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        SeedMemberCard(Card, SeedMembership(MembershipCode), 1, false, false);

        // np-passes renders the design returned here, so a switch must show on the next fetch.
        MembershipSetup.Get(MembershipCode);
        MembershipSetup."NP Passes Layout Handle" := 'aaaa1111bbbb2222cccc3333dddd4444';
        MembershipSetup.Modify();

        InitCardRequest(Request, "Http Method"::GET, Card, '', Body);
        Response := MemberCardApiAgent.GetMemberCardById(Request);

        _Assert.IsTrue(Response.GetJson().SelectToken('card.membership.passDesignHandle', Token), 'The card response must carry membership.passDesignHandle');
        _Assert.AreEqual('aaaa1111bbbb2222cccc3333dddd4444', Token.AsValue().AsText(), 'The membership type''s current handle must be returned');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SendToWallet_StampsLinkSentAt()
    var
        MemberCardApiAgent: Codeunit "NPR MemberCardApiAgent";
        Request: Codeunit "NPR API Request";
        Card: Record "NPR MM Member Card";
        Body: JsonObject;
    begin
        Arrange(true);
        SeedMemberCard(Card, SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')), 1, false, false);
        Card."NP Passes Link Sent At" := 0DT;
        Card.Modify();
        InitCardRequest(Request, "Http Method"::POST, Card, 'sendToWallet', Body);

        MemberCardApiAgent.SendToWallet(Request);

        Card.Get(Card."Entry No.");
        _Assert.AreNotEqual(0DT, Card."NP Passes Link Sent At", 'A card handed a landing link must be marked so later updates reach its pass');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SendToWallet_TemporaryCard_NoLink()
    var
        MemberCardApiAgent: Codeunit "NPR MemberCardApiAgent";
        Request: Codeunit "NPR API Request";
        Card: Record "NPR MM Member Card";
        Body: JsonObject;
    begin
        Arrange(true);
        SeedMemberCard(Card, SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')), 990201, true, false);
        Card."NP Passes Link Sent At" := 0DT;
        Card.Modify();
        InitCardRequest(Request, "Http Method"::POST, Card, 'sendToWallet', Body);

        MemberCardApiAgent.SendToWallet(Request);

        Card.Get(Card."Entry No.");
        _Assert.AreEqual(0DT, Card."NP Passes Link Sent At", 'A temporary card never gets updates, so no link is issued for it');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberWithoutPass_EditedFromCode_DoesNotSignal()
    var
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
    begin
        Arrange(true);
        SeedMemberWithCard(Member, Card);
        Card."NP Passes Link Sent At" := 0DT;
        Card.Modify();

        Member.Get(Member."Entry No.");
        Member."First Name" := 'Renamed';
        Member.Modify();

        _Assert.AreEqual(0, _Mock.CallCount(), 'A member without a pass has nothing to refresh');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CardBlockedOnPage_SignalsPass()
    var
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
        xCard: Record "NPR MM Member Card";
        ChangeDetect: Codeunit "NPR MM NP Passes ChangeDetect";
    begin
        Arrange(true);
        SeedMemberWithCard(Member, Card);
        xCard := Card;
        Card.Blocked := true;

        ChangeDetect.SignalCardEdit(Card, xCard);

        _Assert.IsTrue(_Mock.WasNotified(Serial(Card.SystemId)), 'Blocking a card on the page must reach its pass');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CardFieldNotOnPassEditedOnPage_DoesNotSignal()
    var
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
        xCard: Record "NPR MM Member Card";
        ChangeDetect: Codeunit "NPR MM NP Passes ChangeDetect";
    begin
        Arrange(true);
        SeedMemberWithCard(Member, Card);
        xCard := Card;
        Card."Block Reason" := Card."Block Reason"::ANONYMIZED;

        ChangeDetect.SignalCardEdit(Card, xCard);

        _Assert.AreEqual(0, _Mock.CallCount(), 'Only card fields in the card response refresh the pass');
    end;

    local procedure SeedMemberWithCard(var Member: Record "NPR MM Member"; var Card: Record "NPR MM Member Card")
    begin
        Member.Init();
        Member."External Member No." := CopyStr('MM-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(Member."External Member No."));
        Member."First Name" := 'Original';
        Member.Insert();
        SeedMemberCard(Card, SeedMembership(CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56')), Member."Entry No.", false, false);
    end;

    local procedure InitCardRequest(var Request: Codeunit "NPR API Request"; Method: Enum "Http Method"; Card: Record "NPR MM Member Card"; Action: Text; Body: JsonObject)
    var
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        Path: Text;
    begin
        PathSegments.Add('membership');
        PathSegments.Add('card');
        PathSegments.Add(Format(Card.SystemId, 0, 4).ToLower());
        Path := '/membership/card/' + Format(Card.SystemId, 0, 4).ToLower();
        if (Action <> '') then begin
            PathSegments.Add(Action);
            Path += '/' + Action;
        end;
        Request.Init(Method, Path, PathSegments, QueryParams, Headers, Body.AsToken());
    end;

    local procedure Arrange(Enabled: Boolean)
    var
        Facade: Codeunit "NPR NP Passes Facade";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', Enabled);
        _Mock.Reset();
        Facade.SetNotifier(_Mock);
    end;

    local procedure ConfigureSetup(BaseUrl: Text[250]; Enabled: Boolean)
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        if (not Setup.Get()) then begin
            Setup.Init();
            Setup.Insert();
        end;
        Setup.Validate("Base URL", BaseUrl);
        Setup.Enabled := Enabled;
        Setup.SetSigningSecret(SecretStrSubstNo('test-secret-do-not-use'));
        Setup.Modify();
    end;

    local procedure CreateMembershipSetupWithHandle(LayoutHandle: Text[40]) MembershipCode: Code[20]
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipCode := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(MembershipCode));
        MembershipSetup.Init();
        MembershipSetup.Code := MembershipCode;
        MembershipSetup."Enable NP Pass Integration" := true;
        MembershipSetup."NP Passes Layout Handle" := LayoutHandle;
        MembershipSetup.Insert();
    end;

    local procedure SeedMembership(MembershipCode: Code[20]): Integer
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.Init();
        Membership."Membership Code" := MembershipCode;
        Membership."External Membership No." := CopyStr('MS-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(Membership."External Membership No."));
        Membership.Insert();
        exit(Membership."Entry No.");
    end;

    local procedure SeedMemberCard(var MemberCard: Record "NPR MM Member Card"; MembershipEntryNo: Integer; MemberEntryNo: Integer; IsTemporary: Boolean; IsBlocked: Boolean)
    begin
        MemberCard.Init();
        MemberCard."Membership Entry No." := MembershipEntryNo;
        MemberCard."Member Entry No." := MemberEntryNo;
        MemberCard."External Card No." := CopyStr('CARD-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(MemberCard."External Card No."));
        MemberCard."Card Is Temporary" := IsTemporary;
        MemberCard.Blocked := IsBlocked;
        MemberCard."NP Passes Link Sent At" := CurrentDateTime();
        MemberCard.Insert();
    end;

    local procedure Serial(Id: Guid): Text
    begin
        exit(LowerCase(DelChr(Format(Id), '=', '{}-')));
    end;
}
