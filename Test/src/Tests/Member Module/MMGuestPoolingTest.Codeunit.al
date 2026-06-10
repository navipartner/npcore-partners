#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85264 "NPR MM GuestPoolingTest"
{
    // Covers the guest-cardinality pooling modes on "NPR MM Membership Setup"."Guest Cardinality Pooling",
    // exercised through MemberTicketManager.GetPooledGuestAllowance (the value the SpeedGate/POS APIs expose as
    // maxNumberOfGuests).
    //
    // Scenario for the CROSS modes: one member belongs to two active memberships (T-GOLD allows 1 of a guest band,
    // T-SILVER allows 4). The swiped membership's mode governs:
    //   PER_MEMBER            -> just the swiped membership's own band max (today's behavior)
    //   CROSS_MEMBERSHIP_SUM  -> 1 + 4 = 5
    //   CROSS_MEMBERSHIP_MAX  -> max(1, 4) = 4
    //   Unlimited on any pooled membership -> IsUnlimited (no cap)
    // No guests are admitted in these tests, so the admitted-count is 0 and the assertions isolate the pooling math.

    Subtype = Test;

    var
        _MemberLib: Codeunit "NPR Library - Member Module";
        _Assert: Codeunit Assert;
        _Initialized: Boolean;
        _GuestAdmissionCodeTok: Label 'GUEST-ADM', Locked = true;
        _GuestBandItemTok: Label 'T-GUEST8', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GuestPooling_PerMember_ReturnsSwipedMembershipMax()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        GoldEntryNo, SilverEntryNo, MemberEntryNo : Integer;
        EffectiveMax: Integer;
        IsUnlimited: Boolean;
    begin
        Initialize();
        SetupMemberInTwoMemberships(GoldEntryNo, SilverEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 1);
        SetGuestBand('T-SILVER', 4);

        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Guest Cardinality Pooling" := MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER;
        MembershipSetup.Modify();

        EffectiveMax := MemberTicketManager.GetPooledGuestAllowance(GoldEntryNo, MemberEntryNo, _GuestAdmissionCodeTok, _GuestBandItemTok, IsUnlimited);

        _Assert.IsFalse(IsUnlimited, 'PER_MEMBER limited band should not be unlimited.');
        _Assert.AreEqual(1, EffectiveMax, 'PER_MEMBER should return only the swiped (GOLD) membership max of 1, ignoring the member''s other memberships.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GuestPooling_CrossSum_SumsBandAcrossMemberships()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        GoldEntryNo, SilverEntryNo, MemberEntryNo : Integer;
        EffectiveMax: Integer;
        IsUnlimited: Boolean;
    begin
        Initialize();
        SetupMemberInTwoMemberships(GoldEntryNo, SilverEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 1);
        SetGuestBand('T-SILVER', 4);

        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Guest Cardinality Pooling" := MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER_CROSS_MEMBERSHIP_SUM;
        MembershipSetup.Modify();

        EffectiveMax := MemberTicketManager.GetPooledGuestAllowance(GoldEntryNo, MemberEntryNo, _GuestAdmissionCodeTok, _GuestBandItemTok, IsUnlimited);

        _Assert.IsFalse(IsUnlimited, 'CROSS_MEMBERSHIP_SUM with two limited bands should not be unlimited.');
        _Assert.AreEqual(5, EffectiveMax, 'CROSS_MEMBERSHIP_SUM should pool the band: GOLD(1) + SILVER(4) = 5.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GuestPooling_CrossMax_TakesHighestBand()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        GoldEntryNo, SilverEntryNo, MemberEntryNo : Integer;
        EffectiveMax: Integer;
        IsUnlimited: Boolean;
    begin
        Initialize();
        SetupMemberInTwoMemberships(GoldEntryNo, SilverEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 1);
        SetGuestBand('T-SILVER', 4);

        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Guest Cardinality Pooling" := MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER_CROSS_MEMBERSHIP_MAX;
        MembershipSetup.Modify();

        EffectiveMax := MemberTicketManager.GetPooledGuestAllowance(GoldEntryNo, MemberEntryNo, _GuestAdmissionCodeTok, _GuestBandItemTok, IsUnlimited);

        _Assert.IsFalse(IsUnlimited, 'CROSS_MEMBERSHIP_MAX with two limited bands should not be unlimited.');
        _Assert.AreEqual(4, EffectiveMax, 'CROSS_MEMBERSHIP_MAX should take the highest band: max(GOLD 1, SILVER 4) = 4.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GuestPooling_CrossSum_UnlimitedAbsorbs()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        GoldEntryNo, SilverEntryNo, MemberEntryNo : Integer;
        EffectiveMax: Integer;
        IsUnlimited: Boolean;
    begin
        Initialize();
        SetupMemberInTwoMemberships(GoldEntryNo, SilverEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 1);
        SetGuestBand('T-SILVER', -1); // -1 => Unlimited cardinality

        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Guest Cardinality Pooling" := MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER_CROSS_MEMBERSHIP_SUM;
        MembershipSetup.Modify();

        EffectiveMax := MemberTicketManager.GetPooledGuestAllowance(GoldEntryNo, MemberEntryNo, _GuestAdmissionCodeTok, _GuestBandItemTok, IsUnlimited);

        _Assert.IsTrue(IsUnlimited, 'An Unlimited band on any pooled membership should make the pooled band unlimited.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GuestPooling_BandOnlyOnSwiped_PoolsThatMembershipOnly()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        GoldEntryNo, SilverEntryNo, MemberEntryNo : Integer;
        EffectiveMax: Integer;
        IsUnlimited: Boolean;
    begin
        // SILVER grants no band for this admission/item; a membership lacking the band must not break pooling.
        Initialize();
        SetupMemberInTwoMemberships(GoldEntryNo, SilverEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 3);

        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Guest Cardinality Pooling" := MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER_CROSS_MEMBERSHIP_SUM;
        MembershipSetup.Modify();

        EffectiveMax := MemberTicketManager.GetPooledGuestAllowance(GoldEntryNo, MemberEntryNo, _GuestAdmissionCodeTok, _GuestBandItemTok, IsUnlimited);

        _Assert.IsFalse(IsUnlimited, 'Single     limited band should not be unlimited.');
        _Assert.AreEqual(3, EffectiveMax, 'SILVER has no band for this admission/item, so the pool is just GOLD (3).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GuestPooling_InactiveMembershipExcludedFromPool()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        ActiveEntryNo, MemberEntryNo : Integer;
        EffectiveMax: Integer;
        IsUnlimited: Boolean;
    begin
        // Member belongs to the active GOLD (swiped) and an inactive SILVER. Only active memberships contribute.
        Initialize();
        SetupMemberWithInactiveSecond(ActiveEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 1);
        SetGuestBand('T-SILVER', 4);

        MembershipSetup.Get('T-GOLD');
        MembershipSetup."Guest Cardinality Pooling" := MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER_CROSS_MEMBERSHIP_SUM;
        MembershipSetup.Modify();

        EffectiveMax := MemberTicketManager.GetPooledGuestAllowance(ActiveEntryNo, MemberEntryNo, _GuestAdmissionCodeTok, _GuestBandItemTok, IsUnlimited);

        _Assert.IsFalse(IsUnlimited, 'Two limited bands should not be unlimited.');
        _Assert.AreEqual(1, EffectiveMax, 'Inactive SILVER must be excluded; only the active swiped GOLD band (1) counts.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreValidate_PooledBandCapEnforcedThroughEntryPoint()
    var
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        Member: Record "NPR MM Member";
        TempReq: Record "NPR TM Ticket Reservation Req." temporary;
        GoldEntryNo, SilverEntryNo, MemberEntryNo : Integer;
    begin
        // Drive the real entry point (not GetPooledGuestAllowance directly) to cover the per-band pooled check and the
        // success return. Both memberships share the mode so the derived (first-role) membership is deterministic.
        Initialize();
        SetupMemberInTwoMemberships(GoldEntryNo, SilverEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 1);
        SetGuestBand('T-SILVER', 4);
        SetCrossSumPooling('T-GOLD');
        SetCrossSumPooling('T-SILVER');

        Member.Get(MemberEntryNo);

        BuildGuestRequest(TempReq, Member."External Member No.", 5);
        _Assert.IsTrue(MemberTicketManager.PreValidateMemberGuestTicketRequest(TempReq, false), 'Quantity 5 is within the pooled cap (1+4) and should validate.');

        BuildGuestRequest(TempReq, Member."External Member No.", 6);
        _Assert.IsFalse(MemberTicketManager.PreValidateMemberGuestTicketRequest(TempReq, false), 'Quantity 6 exceeds the pooled cap (5) and should fail validation.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreValidate_PerAdmissionTotalCapEnforced()
    var
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        Member: Record "NPR MM Member";
        TempReq: Record "NPR TM Ticket Reservation Req." temporary;
        GoldEntryNo, SilverEntryNo, MemberEntryNo : Integer;
    begin
        // Per-band allows 5, but the admission's total (NA) cap is 3. Both memberships configured identically so the
        // derived membership is deterministic; PER_MEMBER (default) keeps the total scoped to that one membership.
        Initialize();
        SetupMemberInTwoMemberships(GoldEntryNo, SilverEntryNo, MemberEntryNo);
        SetGuestBand('T-GOLD', 5);
        SetGuestBand('T-SILVER', 5);
        SetGuestTotalCap('T-GOLD', 3);
        SetGuestTotalCap('T-SILVER', 3);

        Member.Get(MemberEntryNo);

        BuildGuestRequest(TempReq, Member."External Member No.", 3);
        _Assert.IsTrue(MemberTicketManager.PreValidateMemberGuestTicketRequest(TempReq, false), 'Total 3 within the admission total cap (3) should validate.');

        BuildGuestRequest(TempReq, Member."External Member No.", 4);
        _Assert.IsFalse(MemberTicketManager.PreValidateMemberGuestTicketRequest(TempReq, false), 'Total 4 exceeds the admission total cap (3) and should fail.');
    end;

    local procedure SetupMemberWithInactiveSecond(var ActiveMembershipEntryNo: Integer; var MemberEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        ActiveId, InactiveId, MemberId, MembershipNumber, MemberNumber : Text;
        InactiveEntryNo: Integer;
    begin
        // GOLD active (swiped) + member; SILVER created with a future activation date so it is not active today.
        CreateMembership('T-320100', ActiveId, MembershipNumber);
        AddMember(ActiveId, MemberId, MemberNumber);
        CreateMembershipActivatedOn('T-320101', CalcDate('<+6M>', WorkDate()), InactiveId);

        Membership.GetBySystemId(ActiveId);
        ActiveMembershipEntryNo := Membership."Entry No.";
        Membership.GetBySystemId(InactiveId);
        InactiveEntryNo := Membership."Entry No.";
        Member.GetBySystemId(MemberId);
        MemberEntryNo := Member."Entry No.";

        if (MemberManagement.IsMembershipActive(InactiveEntryNo, WorkDate(), false)) then
            Error('Test setup failure: membership should be inactive.');

        MembershipRole.Init();
        MembershipRole."Membership Entry No." := InactiveEntryNo;
        MembershipRole."Member Role" := MembershipRole."Member Role"::MEMBER;
        MembershipRole."Member Entry No." := MemberEntryNo;
        MembershipRole.Insert(true);
    end;

    local procedure CreateMembershipActivatedOn(SalesItem: Code[20]; ActivationDate: Date; var MembershipId: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        ResponseBody: JsonObject;
    begin
        Body.Add('itemNumber', SalesItem);
        Body.Add('activationDate', ActivationDate);
        ResponseBody := GetResponseBodyOrError(InvokeApi('POST', 'membership', Body), 'Create membership failed.');
        MembershipId := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipId', true);
    end;

    local procedure SetCrossSumPooling(MembershipCode: Code[20])
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipSetup.Get(MembershipCode);
        MembershipSetup."Guest Cardinality Pooling" := MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER_CROSS_MEMBERSHIP_SUM;
        MembershipSetup.Modify();
    end;

    local procedure SetGuestTotalCap(MembershipCode: Code[20]; MaxTotal: Integer)
    var
        MembersAdmisSetup: Record "NPR MM Members. Admis. Setup";
    begin
        // The NA-type row (blank ticket no.) is the per-(membership, admission) total cap across all guest bands.
        _MemberLib.CreateMembershipGuestAdmissionSetup(MembershipCode, _GuestAdmissionCodeTok, MembersAdmisSetup."Ticket No. Type"::NA, '', MaxTotal, 'Total');
    end;

    local procedure BuildGuestRequest(var TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; ExternalMemberNo: Code[20]; Qty: Integer)
    begin
        TempTicketReservationRequest.Reset();
        TempTicketReservationRequest.DeleteAll();
        TempTicketReservationRequest.Init();
        TempTicketReservationRequest."Entry No." := 1;
        TempTicketReservationRequest."External Member No." := ExternalMemberNo;
        TempTicketReservationRequest."Admission Code" := _GuestAdmissionCodeTok;
        TempTicketReservationRequest."External Item Code" := _GuestBandItemTok;
        TempTicketReservationRequest."Item No." := _GuestBandItemTok;
        TempTicketReservationRequest.Quantity := Qty;
        TempTicketReservationRequest.Insert();
    end;

    local procedure SetGuestBand(MembershipCode: Code[20]; MaxGuestCount: Integer)
    var
        MembersAdmisSetup: Record "NPR MM Members. Admis. Setup";
    begin
        // Same admission + same guest item across memberships - that shared band is what the pooling matches on.
        _MemberLib.CreateMembershipGuestAdmissionSetup(MembershipCode, _GuestAdmissionCodeTok, MembersAdmisSetup."Ticket No. Type"::ITEM, _GuestBandItemTok, MaxGuestCount, '8+');
    end;

    local procedure DeleteAdmissionSetup()
    var
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
    begin
        MembershipAdmissionSetup.DeleteAll();
    end;

    local procedure SetupMemberInTwoMemberships(var GoldEntryNo: Integer; var SilverEntryNo: Integer; var MemberEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        GoldMembershipId, SilverMembershipId, MemberId, MembershipNumber, MemberNumber : Text;
    begin
        // Two active memberships via the proven membership API, then one member shared across both via a role link.
        CreateMembership('T-320100', GoldMembershipId, MembershipNumber);   // T-GOLD
        AddMember(GoldMembershipId, MemberId, MemberNumber);
        CreateMembership('T-320101', SilverMembershipId, MembershipNumber);  // T-SILVER

        Membership.GetBySystemId(GoldMembershipId);
        GoldEntryNo := Membership."Entry No.";
        Membership.GetBySystemId(SilverMembershipId);
        SilverEntryNo := Membership."Entry No.";
        Member.GetBySystemId(MemberId);
        MemberEntryNo := Member."Entry No.";

        // Link the GOLD member into the SILVER membership so the member belongs to both.
        MembershipRole.Init();
        MembershipRole."Membership Entry No." := SilverEntryNo;
        MembershipRole."Member Role" := MembershipRole."Member Role"::MEMBER;
        MembershipRole."Member Entry No." := MemberEntryNo;
        MembershipRole.Insert(true);
    end;

    local procedure CreateMembership(SalesItem: Code[20]; var MembershipId: Text; var MembershipNumber: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        ResponseBody: JsonObject;
    begin
        Body.Add('itemNumber', SalesItem);
        Body.Add('activationDate', CalcDate('<-6M>', WorkDate()));
        ResponseBody := GetResponseBodyOrError(InvokeApi('POST', 'membership', Body), 'Create membership failed.');
        MembershipId := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipId', true);
        MembershipNumber := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipNumber', true);
    end;

    local procedure AddMember(MembershipId: Text; var MemberId: Text; var MemberNumber: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Body: JsonObject;
        MemberJson: JsonObject;
        ResponseBody: JsonObject;
    begin
        _MemberLib.SetRandomMemberInfoData(MemberInfoCapture);
        MemberJson.Add('firstName', MemberInfoCapture."First Name");
        MemberJson.Add('lastName', MemberInfoCapture."Last Name");
        MemberJson.Add('email', MemberInfoCapture."E-Mail Address");
        MemberJson.Add('birthday', CalcDate('<-30Y>'));
        Body.Add('member', MemberJson);
        ResponseBody := GetResponseBodyOrError(InvokeApi('POST', StrSubstNo('membership/%1/addMember', MembershipId), Body), 'Add member failed.');
        MemberId := JsonHelper.GetJText(ResponseBody.AsToken(), 'member.memberId', true);
        MemberNumber := JsonHelper.GetJText(ResponseBody.AsToken(), 'member.memberNumber', true);
    end;

    local procedure InvokeApi(Method: Text; Path: Text; Body: JsonObject) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Headers.Add('x-api-version', Format(WorkDate(), 0, 9));
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

    local procedure Initialize()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    begin
        DeleteAdmissionSetup();
        ResetMembershipPooling();
        if (_Initialized) then
            exit;
        _MemberLib.Initialize();
        _MemberLib.CreateScenario_SmokeTest();
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Membership');
        _Initialized := true;
    end;

    local procedure ResetMembershipPooling()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipSetup.ModifyAll("Guest Cardinality Pooling", MembershipSetup."Guest Cardinality Pooling"::PER_MEMBER);
    end;
}
#endif
