// Drives the internal parse/persist/invalidate/stats logic of "NPR License Mgt." with seeded data - no HTTP, no
// real User records (license users are seeded with direct field assignment + Insert(false) to bypass OnValidate).
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85301 "NPR Module Licensing Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Parse_MultiModule_BothPoolsMapped()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempPool: Record "NPR License Pool" temporary;
        Assert: Codeunit Assert;
        Json: Text;
    begin
        // [SCENARIO] A response with a pos and a kds pool yields two temp rows mapped to the right module/term.
        Initialize();
        Json := WrapValue(
            PoolJson('11111111-1111-1111-1111-111111111111', 'pos', 'months01', 5, 'active') + ',' +
            PoolJson('22222222-2222-2222-2222-222222222222', 'kds', 'months12', 2, 'active'));

        Assert.IsTrue(LicenseMgt.ParsePoolsJsonToTemp(Json, TempPool), 'parse should succeed');
        Assert.AreEqual(2, TempPool.Count(), 'two pools expected');

        TempPool.SetRange(Module, TempPool.Module::POS);
        Assert.AreEqual(1, TempPool.Count(), 'one POS pool expected');
        TempPool.FindFirst();
        Assert.AreEqual(TempPool."License Term"::months01, TempPool."License Term", 'POS license term');

        TempPool.SetRange(Module, TempPool.Module::KDS);
        Assert.AreEqual(1, TempPool.Count(), 'one KDS pool expected');
        TempPool.FindFirst();
        Assert.AreEqual(TempPool."License Term"::months12, TempPool."License Term", 'KDS license term');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Parse_ForwardTolerance_UnknownModuleAndTypeSkipped()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempPool: Record "NPR License Pool" temporary;
        Assert: Codeunit Assert;
        Json: Text;
    begin
        // [SCENARIO] An unknown module slug (wms) and an unrepresentable license term (months03) are skipped; the
        // valid pool still parses. Guards against rejecting the whole response and against the dropped POS-only filter.
        Initialize();
        Json := WrapValue(
            PoolJson('11111111-1111-1111-1111-111111111111', 'pos', 'months01', 5, 'active') + ',' +
            PoolJson('22222222-2222-2222-2222-222222222222', 'wms', 'months12', 9, 'active') + ',' +
            PoolJson('33333333-3333-3333-3333-333333333333', 'pos', 'months03', 9, 'active'));

        Assert.IsTrue(LicenseMgt.ParsePoolsJsonToTemp(Json, TempPool), 'parse should succeed');
        Assert.AreEqual(1, TempPool.Count(), 'only the valid pos/months01 pool should remain');
        TempPool.FindFirst();
        Assert.AreEqual(TempPool.Module::POS, TempPool.Module, 'remaining pool module');
        Assert.AreEqual(TempPool."License Term"::months01, TempPool."License Term", 'remaining pool term');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Parse_UnknownStatusKept_EmptyEnumRawTextStored()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempPool: Record "NPR License Pool" temporary;
        Assert: Codeunit Assert;
        Json: Text;
    begin
        // [SCENARIO] A non-key descriptive field (status) with an unknown value keeps the row: enum -> empty, raw
        // string preserved in Status (API).
        Initialize();
        Json := WrapValue(PoolJson('11111111-1111-1111-1111-111111111111', 'pos', 'months01', 5, 'frozen'));

        Assert.IsTrue(LicenseMgt.ParsePoolsJsonToTemp(Json, TempPool), 'parse should succeed');
        Assert.AreEqual(1, TempPool.Count(), 'pool kept despite unknown status');
        TempPool.FindFirst();
        Assert.AreEqual(TempPool.Status::_, TempPool.Status, 'enum falls back to empty');
        Assert.AreEqual('frozen', TempPool."Status (API)", 'raw status preserved');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Persist_StalePoolDeleted()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempPool: Record "NPR License Pool" temporary;
        LicensePool: Record "NPR License Pool";
        Assert: Codeunit Assert;
        PoolA: Guid;
        PoolB: Guid;
    begin
        // [SCENARIO] PersistPools deletes pools the API no longer returns.
        Initialize();
        PoolA := '11111111-1111-1111-1111-111111111111';
        PoolB := '22222222-2222-2222-2222-222222222222';

        SeedTempPool(TempPool, PoolA, TempPool.Module::POS, TempPool."License Term"::months12, 3);
        SeedTempPool(TempPool, PoolB, TempPool.Module::KDS, TempPool."License Term"::months12, 1);
        LicenseMgt.PersistPools(TempPool);
        Assert.AreEqual(2, LicensePool.Count(), 'two pools persisted');

        TempPool.DeleteAll();
        SeedTempPool(TempPool, PoolA, TempPool.Module::POS, TempPool."License Term"::months12, 3);
        LicenseMgt.PersistPools(TempPool);
        Assert.AreEqual(1, LicensePool.Count(), 'stale pool deleted');
        LicensePool.FindFirst();
        Assert.AreEqual(PoolA, LicensePool."Pool Id", 'surviving pool is the one still returned');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Invalidate_ExcessActiveUserSuspended()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        LicenseUser: Record "NPR License User";
        Assert: Codeunit Assert;
        OlderUser: Guid;
        NewerUser: Guid;
    begin
        // [SCENARIO] Allowance = 1 for (POS, months12) with 2 active users: the newer activation is suspended,
        // grouped per (Module, License Term); the oldest is kept.
        Initialize();
        SeedRealPoolToday(TempModulePOS(), TempTermMonths12(), 1);
        OlderUser := '11111111-1111-1111-1111-111111111111';
        NewerUser := '22222222-2222-2222-2222-222222222222';
        SeedActiveUser(OlderUser, TempModulePOS(), TempTermMonths12(), CreateDateTime(20260101D, 080000T));
        SeedActiveUser(NewerUser, TempModulePOS(), TempTermMonths12(), CreateDateTime(20260102D, 080000T));

        LicenseMgt.InvalidateLicensedUsers();

        LicenseUser.Get(OlderUser, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::Active, LicenseUser.Status, 'oldest active user kept');
        LicenseUser.Get(NewerUser, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::SuspendedAutomatically, LicenseUser.Status, 'excess user suspended');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Stats_CurrentPeriodOnly_DateDriven()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempStats: Record "NPR License Stats" temporary;
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Effectiveness is decided by date (validSince/validUntil): a pool effective today (total 1) counts,
        // a future-dated pool (total 5) does not. Stats total for (POS, months12) = 1.
        Initialize();
        SeedRealPool(TempModulePOS(), TempTermMonths12(), 1, Today() - 1, Today() + 1);
        SeedRealPool(TempModulePOS(), TempTermMonths12(), 5, Today() + 10, Today() + 40);

        LicenseMgt.GetLicenseStats(TempStats);

        TempStats.SetRange(Module, TempStats.Module::POS);
        TempStats.SetRange("License Term", TempStats."License Term"::months12);
        Assert.IsTrue(TempStats.FindFirst(), 'a stats row for POS/months12 expected');
        Assert.AreEqual(1, TempStats."Total Licenses", 'only the current-period pool counts');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Stats_UsageComputed()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempStats: Record "NPR License Stats" temporary;
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Total/Used/Remaining/Usage % computed per (Module, License Term).
        Initialize();
        SeedRealPoolToday(TempModulePOS(), TempTermMonths12(), 4);
        SeedActiveUser('11111111-1111-1111-1111-111111111111', TempModulePOS(), TempTermMonths12(), CreateDateTime(20260101D, 080000T));

        LicenseMgt.GetLicenseStats(TempStats);

        TempStats.SetRange(Module, TempStats.Module::POS);
        TempStats.SetRange("License Term", TempStats."License Term"::months12);
        Assert.IsTrue(TempStats.FindFirst(), 'a stats row expected');
        Assert.AreEqual(4, TempStats."Total Licenses", 'total');
        Assert.AreEqual(1, TempStats."Used Licenses", 'used');
        Assert.AreEqual(3, TempStats.Remaining, 'remaining');
        Assert.AreEqual(25, TempStats."Usage %", 'usage percent');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Usage_AllModulesReported_ZeroWhenNoUsers()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        Assert: Codeunit Assert;
        UsageArray: JsonArray;
    begin
        // [SCENARIO] With no active users, every known module is still reported with activeSeats = 0 so the
        // portal can clear stale counts.
        Initialize();

        LicenseMgt.BuildUsageArray(UsageArray);

        Assert.AreEqual(3, UsageArray.Count(), 'pos, kds and scanner all reported');
        Assert.AreEqual(0, ActiveSeatsOf(UsageArray, 'pos'), 'pos zero');
        Assert.AreEqual(0, ActiveSeatsOf(UsageArray, 'kds'), 'kds zero');
        Assert.AreEqual(0, ActiveSeatsOf(UsageArray, 'scanner'), 'scanner zero');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Usage_ActiveCountReported()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        Assert: Codeunit Assert;
        UsageArray: JsonArray;
    begin
        // [SCENARIO] One active POS user -> pos activeSeats = 1, other modules still reported as 0.
        Initialize();
        SeedActiveUser('11111111-1111-1111-1111-111111111111', TempModulePOS(), TempTermMonths12(), CreateDateTime(20260101D, 080000T));

        LicenseMgt.BuildUsageArray(UsageArray);

        Assert.AreEqual(1, ActiveSeatsOf(UsageArray, 'pos'), 'one active pos seat');
        Assert.AreEqual(0, ActiveSeatsOf(UsageArray, 'kds'), 'kds zero');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Reactivate_HeadroomRestoresMostRecentFirst()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        LicenseUser: Record "NPR License User";
        Assert: Codeunit Assert;
        OldestUser: Guid;
        MiddleUser: Guid;
        NewestUser: Guid;
    begin
        // [SCENARIO] Allowance 2, one active + two already auto-suspended users (distinct suspend timestamps): the
        // single headroom seat is filled by the MOST-RECENTLY-suspended user, leaving the older suspension in place.
        // The pre-suspended state is seeded directly with explicit timestamps so the MRU-first order is driven by
        // data, not by the sub-millisecond timing of a suspend loop (the Status OnValidate overwrites
        // "Status Changed At" with CurrentDateTime(), so two suspensions in one loop can tie). Suspend-newest-first is
        // already covered by Invalidate_ExcessActiveUserSuspended.
        Initialize();
        SeedRealPoolToday(TempModulePOS(), TempTermMonths12(), 2);
        OldestUser := '11111111-1111-1111-1111-111111111111';
        MiddleUser := '22222222-2222-2222-2222-222222222222';
        NewestUser := '33333333-3333-3333-3333-333333333333';
        SeedActiveUser(OldestUser, TempModulePOS(), TempTermMonths12(), CreateDateTime(20260101D, 080000T));
        SeedUserWithStatus(MiddleUser, TempModulePOS(), TempTermMonths12(), LicenseUser.Status::SuspendedAutomatically, CreateDateTime(20260102D, 080000T));
        SeedUserWithStatus(NewestUser, TempModulePOS(), TempTermMonths12(), LicenseUser.Status::SuspendedAutomatically, CreateDateTime(20260103D, 080000T));

        LicenseMgt.InvalidateLicensedUsers();

        LicenseUser.Get(OldestUser, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::Active, LicenseUser.Status, 'oldest stays active');
        LicenseUser.Get(MiddleUser, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::SuspendedAutomatically, LicenseUser.Status, 'middle stays suspended (only 1 headroom)');
        LicenseUser.Get(NewestUser, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::Active, LicenseUser.Status, 'most-recently-suspended reactivated first');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Reactivate_NeverTouchesDisabledManually()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        LicenseUser: Record "NPR License User";
        Assert: Codeunit Assert;
        DisabledUser: Guid;
    begin
        // [SCENARIO] A DisabledManually user is never auto-reactivated, even with ample headroom (pool total 5).
        Initialize();
        SeedRealPoolToday(TempModulePOS(), TempTermMonths12(), 5);
        DisabledUser := '11111111-1111-1111-1111-111111111111';
        SeedUserWithStatus(DisabledUser, TempModulePOS(), TempTermMonths12(), LicenseUser.Status::DisabledManually, CreateDateTime(20260101D, 080000T));

        LicenseMgt.InvalidateLicensedUsers();

        LicenseUser.Get(DisabledUser, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::DisabledManually, LicenseUser.Status, 'manually disabled user must not be auto-reactivated');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Invalidate_TwoGroups_NoneSuspended()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        LicenseUser: Record "NPR License User";
        Assert: Codeunit Assert;
        PosUserA: Guid;
        PosUserB: Guid;
        KdsUserA: Guid;
        KdsUserB: Guid;
    begin
        // [SCENARIO] Two groups (POS, KDS) each at allowance 2 with 2 active users each: none suspended. Exercises the
        // per-(Module, License Term) AssignedCount reset - a leak there would carry POS's running count into KDS and
        // wrongly suspend the second group's users.
        Initialize();
        SeedRealPoolToday(TempModulePOS(), TempTermMonths12(), 2);
        SeedRealPoolToday(TempModuleKDS(), TempTermMonths12(), 2);
        PosUserA := '11111111-1111-1111-1111-111111111111';
        PosUserB := '22222222-2222-2222-2222-222222222222';
        KdsUserA := '33333333-3333-3333-3333-333333333333';
        KdsUserB := '44444444-4444-4444-4444-444444444444';
        SeedActiveUser(PosUserA, TempModulePOS(), TempTermMonths12(), CreateDateTime(20260101D, 080000T));
        SeedActiveUser(PosUserB, TempModulePOS(), TempTermMonths12(), CreateDateTime(20260102D, 080000T));
        SeedActiveUser(KdsUserA, TempModuleKDS(), TempTermMonths12(), CreateDateTime(20260101D, 080000T));
        SeedActiveUser(KdsUserB, TempModuleKDS(), TempTermMonths12(), CreateDateTime(20260102D, 080000T));

        LicenseMgt.InvalidateLicensedUsers();

        LicenseUser.Get(PosUserA, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::Active, LicenseUser.Status, 'POS user A active');
        LicenseUser.Get(PosUserB, TempModulePOS());
        Assert.AreEqual(LicenseUser.Status::Active, LicenseUser.Status, 'POS user B active');
        LicenseUser.Get(KdsUserA, TempModuleKDS());
        Assert.AreEqual(LicenseUser.Status::Active, LicenseUser.Status, 'KDS user A active');
        LicenseUser.Get(KdsUserB, TempModuleKDS());
        Assert.AreEqual(LicenseUser.Status::Active, LicenseUser.Status, 'KDS user B active');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Parse_ValidityDatesParsed()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempPool: Record "NPR License Pool" temporary;
        Assert: Codeunit Assert;
        Json: Text;
    begin
        // [SCENARIO] validSince/validUntil ISO date strings are parsed into the Date fields, guarding the NPR Json
        // Parser Date overloads against regression. PoolJson hardcodes 2020-01-01 / 2099-12-31.
        Initialize();
        Json := WrapValue(PoolJson('11111111-1111-1111-1111-111111111111', 'pos', 'months01', 5, 'active'));

        Assert.IsTrue(LicenseMgt.ParsePoolsJsonToTemp(Json, TempPool), 'parse should succeed');
        Assert.AreEqual(1, TempPool.Count(), 'one pool expected');
        TempPool.FindFirst();
        Assert.AreEqual(20200101D, TempPool."Valid Since Date", 'valid since date parsed');
        Assert.AreEqual(20991231D, TempPool."Valid Until Date", 'valid until date parsed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Parse_UnparseableValidUntil_FailsWholeSync()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempPool: Record "NPR License Pool" temporary;
        Assert: Codeunit Assert;
        Json: Text;
    begin
        // [SCENARIO] An unparseable validUntil fails the whole parse rather than silently blanking the date, so the
        // caller keeps last-known-good pools instead of dropping the pool and auto-suspending all its users.
        Initialize();
        Json := WrapValue(PoolJsonWithValidity('11111111-1111-1111-1111-111111111111', 'pos', 'months01', 5, 'active',
            '"validSince":"2020-01-01","validUntil":"INVALID",'));

        Assert.IsFalse(LicenseMgt.ParsePoolsJsonToTemp(Json, TempPool), 'parse must fail on unparseable validUntil');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Parse_MissingValidSince_FailsWholeSync()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        TempPool: Record "NPR License Pool" temporary;
        Assert: Codeunit Assert;
        Json: Text;
    begin
        // [SCENARIO] A missing validSince fails the parse instead of defaulting to 0D, which would pass the "<= today"
        // gate and silently over-grant (pool treated as valid since forever).
        Initialize();
        Json := WrapValue(PoolJsonWithValidity('11111111-1111-1111-1111-111111111111', 'pos', 'months01', 5, 'active',
            '"validUntil":"2099-12-31",'));

        Assert.IsFalse(LicenseMgt.ParsePoolsJsonToTemp(Json, TempPool), 'parse must fail on missing validSince');
    end;

    // ----------------------------------------------------------------- Helpers

    local procedure Initialize()
    var
        LicensePool: Record "NPR License Pool";
        LicenseUser: Record "NPR License User";
    begin
        LicensePool.DeleteAll(false);
        LicenseUser.DeleteAll(false);
        if _Initialized then
            exit;
        _Initialized := true;
    end;

    local procedure WrapValue(Inner: Text): Text
    begin
        exit('{"value":[' + Inner + ']}');
    end;

    local procedure PoolJson(Id: Text; ModuleSlug: Text; LicType: Text; Total: Integer; Status: Text): Text
    begin
        exit(PoolJsonWithValidity(Id, ModuleSlug, LicType, Total, Status, '"validSince":"2020-01-01","validUntil":"2099-12-31",'));
    end;

    local procedure PoolJsonWithValidity(Id: Text; ModuleSlug: Text; LicType: Text; Total: Integer; Status: Text; ValidityFragment: Text): Text
    begin
        exit(StrSubstNo(
            '{"pool":{"id":"%1","module":"%2","licenseType":"%3","name":"Test pool","totalLicenses":%4,' +
            '"tenantId":"00000000-0000-0000-0000-000000000001","environmentName":"prod","companyName":"CRONUS",' +
            '"status":"%5","renewalMonth":1,"renewalDay":1,"periodMonths":12,' +
            '%6' +
            '"createdAt":"2026-01-01T00:00:00.000Z","updatedAt":"2026-01-01T00:00:00.000Z"}}',
            Id, ModuleSlug, LicType, Total, Status, ValidityFragment));
    end;

    local procedure SeedTempPool(var TempPool: Record "NPR License Pool" temporary; PoolId: Guid; Module: Enum "NPR License Module"; LicType: Enum "NPR License Term"; Total: Integer)
    begin
        TempPool.Init();
        TempPool."Pool Id" := PoolId;
        TempPool.Module := Module;
        TempPool."License Term" := LicType;
        TempPool."Total Licenses" := Total;
        TempPool."Valid Since Date" := Today() - 1;
        TempPool."Valid Until Date" := Today() + 1;
        TempPool.Insert();
    end;

    local procedure SeedRealPoolToday(Module: Enum "NPR License Module"; LicType: Enum "NPR License Term"; Total: Integer)
    begin
        SeedRealPool(Module, LicType, Total, Today() - 1, Today() + 1);
    end;

    local procedure SeedRealPool(Module: Enum "NPR License Module"; LicType: Enum "NPR License Term"; Total: Integer; ValidSince: Date; ValidUntil: Date)
    var
        LicensePool: Record "NPR License Pool";
    begin
        LicensePool.Init();
        LicensePool."Pool Id" := CreateGuid();
        LicensePool.Module := Module;
        LicensePool."License Term" := LicType;
        LicensePool."Total Licenses" := Total;
        LicensePool."Valid Since Date" := ValidSince;
        LicensePool."Valid Until Date" := ValidUntil;
        LicensePool.Status := LicensePool.Status::Active; // GetAllowanceDictionary/GetLicenseStats filter Status = Active
        LicensePool.Insert();
    end;

    local procedure SeedActiveUser(UserId: Guid; Module: Enum "NPR License Module"; LicType: Enum "NPR License Term"; ChangedAt: DateTime)
    var
        LicenseUser: Record "NPR License User";
    begin
        // Direct field assignment + Insert(false) bypasses the User Security ID OnValidate (which requires a real
        // User record) and the Status OnValidate, so logic can be tested without seeding the User table.
        LicenseUser.Init();
        LicenseUser."User Security ID" := UserId;
        LicenseUser.Module := Module;
        LicenseUser."License Term" := LicType;
        LicenseUser.Status := LicenseUser.Status::Active;
        LicenseUser."Status Changed At" := ChangedAt;
        LicenseUser.Insert(false);
    end;

    local procedure SeedUserWithStatus(UserId: Guid; Module: Enum "NPR License Module"; LicType: Enum "NPR License Term"; Status: Enum "NPR License User Status"; ChangedAt: DateTime)
    var
        LicenseUser: Record "NPR License User";
    begin
        // Same direct-assignment + Insert(false) bypass as SeedActiveUser, but with a caller-supplied Status so tests
        // can seed non-Active states (e.g. DisabledManually) without tripping the Status OnValidate.
        LicenseUser.Init();
        LicenseUser."User Security ID" := UserId;
        LicenseUser.Module := Module;
        LicenseUser."License Term" := LicType;
        LicenseUser.Status := Status;
        LicenseUser."Status Changed At" := ChangedAt;
        LicenseUser.Insert(false);
    end;

    local procedure TempModulePOS(): Enum "NPR License Module"
    begin
        exit("NPR License Module"::POS);
    end;

    local procedure TempModuleKDS(): Enum "NPR License Module"
    begin
        exit("NPR License Module"::KDS);
    end;

    local procedure TempTermMonths12(): Enum "NPR License Term"
    begin
        exit("NPR License Term"::months12);
    end;

    local procedure ActiveSeatsOf(UsageArray: JsonArray; ModuleSlug: Text): Integer
    var
        Token: JsonToken;
        Obj: JsonObject;
        ModuleToken: JsonToken;
        SeatsToken: JsonToken;
    begin
        foreach Token in UsageArray do begin
            Obj := Token.AsObject();
            if Obj.Get('module', ModuleToken) then
                if ModuleToken.AsValue().AsText() = ModuleSlug then begin
                    Obj.Get('activeSeats', SeatsToken);
                    exit(SeatsToken.AsValue().AsInteger());
                end;
        end;
        exit(-1); // slug not present -> force an assert failure
    end;
}
#endif
