codeunit 85372 "NPR NP Passes Dispatch Test"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WithLayoutHandle_HandlesAndFillsLandingUrl()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Entry: Record "NPR MM Member Notific. Entry";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        SeedMemberCard(MembershipCode, 100, 200);
        SeedMembershipRole(100, 200);
        InitNotifEntry(Entry, 1, MembershipCode, 100, 200, Entry."Notification Trigger"::WALLET_CREATE);

        _Assert.IsTrue(Adapter.TryIssuePassLink(Entry), 'Should handle when layout handle is set');
        _Assert.IsTrue(Entry."Wallet Pass Landing URL".StartsWith('https://np-passes-generator.example.dev/l/'),
            'Landing URL should be populated: ' + Entry."Wallet Pass Landing URL");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WithoutLayoutHandle_ReturnsFalse()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Entry: Record "NPR MM Member Notific. Entry";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        MembershipCode := CreateMembershipSetupWithHandle('');
        SeedMemberCard(MembershipCode, 110, 210);
        InitNotifEntry(Entry, 2, MembershipCode, 110, 210, Entry."Notification Trigger"::WALLET_CREATE);

        _Assert.IsFalse(Adapter.TryIssuePassLink(Entry), 'Should not handle when no layout handle');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_SetsWalletPassId_32CharDashless()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Entry: Record "NPR MM Member Notific. Entry";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        SeedMemberCard(MembershipCode, 120, 220);
        SeedMembershipRole(120, 220);
        InitNotifEntry(Entry, 3, MembershipCode, 120, 220, Entry."Notification Trigger"::WALLET_CREATE);

        Adapter.TryIssuePassLink(Entry);

        _Assert.AreEqual(32, StrLen(Entry."Wallet Pass Id"), 'The entry carries the pass serial (dashless GUID)');
        MembershipRole.Get(120, 220);
        _Assert.AreEqual('', MembershipRole."Wallet Pass Id", 'NP Passes does not use the legacy Wallet Pass Id on the role');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_LeavesLegacyPassIdUntouched()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Entry: Record "NPR MM Member Notific. Entry";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        SeedMemberCard(MembershipCode, 130, 230);
        SeedMembershipRole(130, 230);
        MembershipRole.Get(130, 230);
        MembershipRole."Wallet Pass Id" := 'LEGACYPASSID';
        MembershipRole.Modify();
        InitNotifEntry(Entry, 4, MembershipCode, 130, 230, Entry."Notification Trigger"::WALLET_CREATE);

        Adapter.TryIssuePassLink(Entry);

        MembershipRole.Get(130, 230);
        _Assert.AreEqual('LEGACYPASSID', MembershipRole."Wallet Pass Id", 'The legacy pass id is left as it was');
        _Assert.AreNotEqual('LEGACYPASSID', Entry."Wallet Pass Id", 'The entry carries the NP pass serial, not the legacy id');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletUpdate_IsHandledWithoutLegacyFallThrough()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Entry: Record "NPR MM Member Notific. Entry";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        SeedMemberCard(MembershipCode, 140, 240);
        InitNotifEntry(Entry, 6, MembershipCode, 140, 240, Entry."Notification Trigger"::WALLET_UPDATE);

        _Assert.IsTrue(Adapter.TryIssuePassLink(Entry), 'WALLET_UPDATE should return true to prevent legacy fall-through');
        _Assert.AreEqual('', Entry."Wallet Pass Landing URL", 'An update entry must not receive a landing URL');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_WithoutSigningSecret_ReturnsFalse()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Setup: Record "NPR NP Passes Setup";
        Entry: Record "NPR MM Member Notific. Entry";
        MemberCard: Record "NPR MM Member Card";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.DeleteSigningSecret();
        Setup.Enabled := true; // enabled without a secret
        Setup.Modify();
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        SeedMemberCard(MembershipCode, 160, 260);
        SeedMembershipRole(160, 260);
        InitNotifEntry(Entry, 8, MembershipCode, 160, 260, Entry."Notification Trigger"::WALLET_CREATE);

        _Assert.IsFalse(Adapter.TryIssuePassLink(Entry), 'No link can be issued without a signing secret');
        _Assert.AreEqual('', Entry."Wallet Pass Landing URL", 'No unsigned link may be stored');
        MemberCard.SetRange("Membership Entry No.", 160);
        MemberCard.FindFirst();
        _Assert.AreEqual(0DT, MemberCard."NP Passes Link Sent At", 'The card must not be stamped without a link');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_NoEligibleCard_ReturnsFalse()
    var
        Adapter: Codeunit "NPR MM NP Passes Adapter";
        Entry: Record "NPR MM Member Notific. Entry";
        MemberCard: Record "NPR MM Member Card";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        MembershipCode := CreateMembershipSetupWithHandle('9e99360037c446e6836a3c933c721e56');
        SeedMemberCard(MembershipCode, 150, 250);
        MemberCard.SetRange("Membership Entry No.", 150);
        MemberCard.FindFirst();
        MemberCard.Blocked := true;
        MemberCard.Modify();
        InitNotifEntry(Entry, 7, MembershipCode, 150, 250, Entry."Notification Trigger"::WALLET_CREATE);

        _Assert.IsFalse(Adapter.TryIssuePassLink(Entry), 'A blocked card is not eligible for a pass link');
        _Assert.AreEqual('', Entry."Wallet Pass Landing URL", 'No landing URL without an eligible card');
        MemberCard.Get(MemberCard."Entry No.");
        _Assert.AreEqual(0DT, MemberCard."NP Passes Link Sent At", 'The card must not be stamped as offered a pass');
    end;

    local procedure ConfigureSetup(BaseUrl: Text[250]; Enabled: Boolean)
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        if (not Setup.Get()) then begin
            Setup.Init();
            Setup.Insert();
        end;
        if (BaseUrl <> '') then
            Setup.Validate("Base URL", BaseUrl)
        else
            Setup."Base URL" := '';
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

    local procedure SeedMemberCard(MembershipCode: Code[20]; MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.Init();
        MemberCard."Membership Entry No." := MembershipEntryNo;
        MemberCard."Member Entry No." := MemberEntryNo;
        MemberCard."External Card No." := CopyStr('CARD-' + Format(MembershipEntryNo), 1, MaxStrLen(MemberCard."External Card No."));
        MemberCard.Blocked := false;
        MemberCard.Insert();
    end;

    local procedure SeedMembershipRole(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        if (MembershipRole.Get(MembershipEntryNo, MemberEntryNo)) then
            exit;
        MembershipRole.Init();
        MembershipRole."Membership Entry No." := MembershipEntryNo;
        MembershipRole."Member Entry No." := MemberEntryNo;
        MembershipRole.Insert();
    end;

    local procedure InitNotifEntry(var Entry: Record "NPR MM Member Notific. Entry"; EntryNo: Integer; MembershipCode: Code[20]; MembershipEntryNo: Integer; MemberEntryNo: Integer; NotificationTrigger: Enum "NPR MM NotificationTrigger")
    begin
        Entry.Init();
        Entry."Notification Entry No." := EntryNo;
        Entry."Membership Code" := MembershipCode;
        Entry."Membership Entry No." := MembershipEntryNo;
        Entry."Member Entry No." := MemberEntryNo;
        Entry."External Member Card No." := CopyStr('CARD-' + Format(MembershipEntryNo), 1, MaxStrLen(Entry."External Member Card No."));
        Entry."Notification Trigger" := NotificationTrigger;
        Entry.Insert();
    end;
}
