// Pins the pure filtering rule: an NP tag survives when any of the user's seats grants the capability that owns
// it (ticket tags: Ticket Management; every other NP tag: Back Office); Microsoft tags, casing and order are
// untouched. Auto-suspended rows count (UI grace), Pending and manually disabled rows do not; a non-empty input
// never becomes empty. The inventory test checks that some SKU unlocks every NP application area, so tags moved into
// a capability nobody sells fail the build. Feature/environment switches are not part of this function.
codeunit 85517 "NPR License App Area Tests"
{
    // [FEATURE] Module licensing: removing the NP application areas a user's seats do not grant

    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_NoLicense_RemovesTicketTags()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Without a seat every NP area is removed; Microsoft areas stay, in their order.
        // [GIVEN] No seat
        Initialize();
        // [WHEN] Filtering Microsoft, back-office and ticketing areas
        // [THEN] Only the Microsoft areas remain
        Assert.AreEqual(
            '#Basic,#Suite',
            FilterFor('#Basic,#Suite,#NPRRetail,#NPRTicketEssential,#NPRTicketAdvanced,#NPRTicketWallet,#NPRTicketDynamicPrice,#NPRMembershipEssential', UserA()),
            'no seat hides every NP area, Microsoft tags kept in order');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_RetailPOS_RemovesTicketTags()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Retail POS keeps the back office and removes the ticketing areas.
        // [GIVEN] An active Retail POS seat
        Initialize();
        SeedUser(UserA(), "NPR License Module"::POS, "NPR License User Status"::Active);
        // [WHEN] Filtering back-office and ticketing areas
        // [THEN] The ticketing areas are removed
        Assert.AreEqual(
            '#Basic,#NPRRetail',
            FilterFor('#Basic,#NPRRetail,#NPRTicketEssential,#NPRTicketAdvanced', UserA()),
            'retail POS has no ticket management');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_AttractionPOS_KeepsTicketTags()
    var
        Assert: Codeunit Assert;
        Areas: Text;
    begin
        // [SCENARIO] Attraction POS keeps the back office and the ticketing areas.
        // [GIVEN] An active Attraction POS seat
        Initialize();
        SeedUser(UserA(), "NPR License Module"::AttractionPOS, "NPR License User Status"::Active);
        // [WHEN] Filtering back-office and ticketing areas
        // [THEN] Nothing is removed
        Areas := '#Basic,#NPRRetail,#NPRTicketEssential,#NPRTicketAdvanced,#NPRTicketWallet,#NPRTicketDynamicPrice';
        Assert.AreEqual(Areas, FilterFor(Areas, UserA()), 'attraction keeps everything');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_EmptyInput_ReturnsEmpty()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] An empty area string stays empty.
        // [GIVEN] No seat
        Initialize();
        // [WHEN] Filtering an empty string
        // [THEN] The result is empty
        Assert.AreEqual('', FilterFor('', UserA()), 'empty stays empty');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_IsCaseInsensitiveAndKeepsOrder()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Odd casing and spaces around commas must not leak a ticket tag through.
        // [GIVEN] No seat
        Initialize();
        // [WHEN] Filtering NP areas written in odd casing and with spaces
        // [THEN] They are removed, the rest is trimmed and keeps its order
        Assert.AreEqual(
            '#Suite,#Basic',
            FilterFor('#Suite, #nprticketessential ,#NPRRetail,#NPRTICKETADVANCED,#Basic', UserA()),
            'case-insensitive removal, trimmed, order kept');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_MixedRows_AnyActiveGrantingRowKeepsTags()
    var
        Assert: Codeunit Assert;
        Areas: Text;
    begin
        // [SCENARIO] An active Retail POS row next to an active Attraction without POS row keeps the ticket tags.
        // [GIVEN] Active Retail POS and Attraction without POS seats
        Initialize();
        SeedUser(UserA(), "NPR License Module"::POS, "NPR License User Status"::Active);
        SeedUser(UserA(), "NPR License Module"::AttractionWithoutPOS, "NPR License User Status"::Active);
        // [WHEN] Filtering back-office and ticketing areas
        // [THEN] Nothing is removed
        Areas := '#Basic,#NPRRetail,#NPRTicketEssential,#NPRTicketAdvanced';
        Assert.AreEqual(Areas, FilterFor(Areas, UserA()), 'any active granting row keeps ticket tags');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_ScannerOnly_RemovesAllNPTags()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A ticket scanner seat alone unlocks no NP area.
        // [GIVEN] An active scanner seat only
        Initialize();
        SeedUser(UserA(), "NPR License Module"::Scanner, "NPR License User Status"::Active);
        // [WHEN] Filtering back-office and ticketing areas
        // [THEN] Every NP area is removed
        Assert.AreEqual('#Basic', FilterFor('#Basic,#NPRRetail,#NPRTicketEssential', UserA()), 'scanner seat alone hides every NP area');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_RetailWithoutPOS_KeepsRetailDropsTickets()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Retail without POS keeps every back-office area, membership included, and removes the ticketing areas.
        // [GIVEN] An active Retail without POS seat
        Initialize();
        SeedUser(UserA(), "NPR License Module"::RetailWithoutPOS, "NPR License User Status"::Active);
        // [WHEN] Filtering back-office, membership and ticketing areas
        // [THEN] Only the ticketing areas are removed
        Assert.AreEqual('#Basic,#NPRRetail,#NPRMembershipEssential', FilterFor('#Basic,#NPRRetail,#NPRTicketEssential,#NPRMembershipEssential,#NPRTicketWallet', UserA()), 'back office kept, ticketing removed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_PrefixIsCaseInsensitiveAndAnchored()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] '#nprretail' is removed; a tag merely containing NPR later in its name is not an NP tag.
        // [GIVEN] No seat
        Initialize();
        // [WHEN] Filtering a lower-case NP tag and a tag with NPR in the middle
        // [THEN] Only the NP tag is removed
        Assert.AreEqual('#Basic,#SomethingNPR', FilterFor('#Basic,#nprretail,#SomethingNPR', UserA()), 'anchored, case-insensitive prefix');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_WouldBeEmpty_FallsBackToInput()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] An empty area string would disable Microsoft's filtering entirely, so the input wins.
        // [GIVEN] No seat
        Initialize();
        // [WHEN] Filtering a string of NP areas only
        // [THEN] The input is returned unchanged instead of an empty string
        Assert.AreEqual('#NPRRetail,#NPRTicketEssential', FilterFor('#NPRRetail,#NPRTicketEssential', UserA()), 'never return empty for a non-empty input');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_AutoSuspendedBackOffice_GraceKeepsNPTags()
    var
        Assert: Codeunit Assert;
        Areas: Text;
    begin
        // [SCENARIO] An automatically suspended seat still counts for the UI (grace), so the back office stays visible.
        // [GIVEN] An automatically suspended Retail POS seat
        Initialize();
        SeedUser(UserA(), "NPR License Module"::POS, "NPR License User Status"::SuspendedAutomatically);
        // [WHEN] Filtering a back-office area
        // [THEN] It is kept
        Areas := '#Basic,#NPRRetail';
        Assert.AreEqual(Areas, FilterFor(Areas, UserA()), 'auto-suspended row keeps the back office visible');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_ManuallyDisabledBackOffice_RemovesNPTags()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A manually disabled seat gets no grace.
        // [GIVEN] A manually disabled Retail POS seat
        Initialize();
        SeedUser(UserA(), "NPR License Module"::POS, "NPR License User Status"::DisabledManually);
        // [WHEN] Filtering a back-office area
        // [THEN] It is removed
        Assert.AreEqual('#Basic', FilterFor('#Basic,#NPRRetail', UserA()), 'manual disable is not grace');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_PendingRow_RemovesNPTags()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A seat that was never activated grants nothing.
        // [GIVEN] A pending Attraction POS seat
        Initialize();
        SeedUser(UserA(), "NPR License Module"::AttractionPOS, "NPR License User Status"::Pending);
        // [WHEN] Filtering back-office and ticketing areas
        // [THEN] Every NP area is removed
        Assert.AreEqual('#Basic', FilterFor('#Basic,#NPRRetail,#NPRTicketEssential', UserA()), 'pending is not a seat');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_SeatsAddUp_NoSeatTakesAway()
    var
        Assert: Codeunit Assert;
        Areas: Text;
    begin
        // [SCENARIO] Retail without POS + Attraction without POS + a device seat: the union of what they unlock.
        // [GIVEN] Active Retail without POS, Attraction without POS and KDS seats
        Initialize();
        SeedUser(UserA(), "NPR License Module"::RetailWithoutPOS, "NPR License User Status"::Active);
        SeedUser(UserA(), "NPR License Module"::AttractionWithoutPOS, "NPR License User Status"::Active);
        SeedUser(UserA(), "NPR License Module"::KDS, "NPR License User Status"::Active);
        // [WHEN] Filtering back-office, ticketing and membership areas
        // [THEN] Nothing is removed
        Areas := '#Basic,#NPRRetail,#NPRTicketEssential,#NPRMembershipEssential';
        Assert.AreEqual(Areas, FilterFor(Areas, UserA()), 'seats add up');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Filter_FullAccess_NormalizesSpacingOnly()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Even a user who keeps every tag gets a trimmed string without empty tokens; casing and order stay.
        // [GIVEN] An active Attraction POS seat
        Initialize();
        SeedUser(UserA(), "NPR License Module"::AttractionPOS, "NPR License User Status"::Active);
        // [WHEN] Filtering areas with spaces and an empty token
        // [THEN] The string is trimmed and the empty token dropped; nothing else changes
        Assert.AreEqual('#Basic,#nprRetail,#NPRTicketEssential', FilterFor('#Basic, , #nprRetail ,#NPRTicketEssential', UserA()), 'trimmed, empties dropped, nothing else changed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Inventory_EveryNPAreaIsUnlockedBySomeSKU()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
        ApplicationAreaSetup: RecordRef;
        AreaField: FieldRef;
        Module: Enum "NPR License Module";
        Owner: Enum "NPR License Capability";
        FieldNo: Integer;
        Ordinal: Integer;
        Tag: Text;
        Unlocked: Boolean;
        Counted: Integer;
    begin
        // [SCENARIO] For every NP field of "Application Area Setup", some SKU grants the capability CapabilityForTag
        // gives it. Fails when tags are moved into a capability no SKU grants yet: those pages would be hidden from everyone.
        // [GIVEN] The NP fields of "Application Area Setup"
        ApplicationAreaSetup.Open(Database::"Application Area Setup");
        // [WHEN] Looking up each field's owning capability and the SKUs that grant it
        // [THEN] At least one SKU grants it, and at least one NP field was checked
        for FieldNo := 1 to ApplicationAreaSetup.FieldCount() do begin
            AreaField := ApplicationAreaSetup.FieldIndex(FieldNo);
            if AreaField.Name.StartsWith('NPR ') then begin
                Tag := '#' + DelChr(AreaField.Name, '=', ' ');
                Owner := LicenseCapabilityMgt.CapabilityForTag(Tag);
                Unlocked := false;
                foreach Ordinal in Module.Ordinals() do begin
                    Module := Enum::"NPR License Module".FromInteger(Ordinal);
                    if LicenseCapabilityMgt.GrantsCapability(Module, Owner) then
                        Unlocked := true;
                end;
                Assert.IsTrue(Unlocked, StrSubstNo('NP application area "%1" (tag %2) belongs to capability %3, which no SKU grants (GrantsCapability).', AreaField.Name, Tag, Owner));
                Counted += 1;
            end;
        end;
        Assert.IsTrue(Counted > 0, 'the NP application areas were walked');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CapabilityForTag_PinnedExamples()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A few owners pinned by hand: the ticket prefix group, the back office, and the default for a tag nobody named.
        // [WHEN] Asking for the owner of ticketing, back-office and unknown NP tags
        // [THEN] Ticketing tags belong to Ticket Management, every other NP tag to Back Office
        Assert.AreEqual("NPR License Capability"::TicketManagement, LicenseCapabilityMgt.CapabilityForTag('#NPRTicketEssential'), '#NPRTicketEssential');
        Assert.AreEqual("NPR License Capability"::TicketManagement, LicenseCapabilityMgt.CapabilityForTag('#NPRTicketDynamicPrice'), '#NPRTicketDynamicPrice');
        Assert.AreEqual("NPR License Capability"::TicketManagement, LicenseCapabilityMgt.CapabilityForTag('#nprticketwallet'), 'compared case-insensitively');
        Assert.AreEqual("NPR License Capability"::BackOffice, LicenseCapabilityMgt.CapabilityForTag('#NPRRetail'), '#NPRRetail');
        Assert.AreEqual("NPR License Capability"::BackOffice, LicenseCapabilityMgt.CapabilityForTag('#NPRMembershipEssential'), '#NPRMembershipEssential');
        Assert.AreEqual("NPR License Capability"::BackOffice, LicenseCapabilityMgt.CapabilityForTag('#NPRSomethingNew'), 'a new NP area belongs to the back office');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Policy_TicketManagementImpliesBackOffice()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
        Module: Enum "NPR License Module";
        Ordinal: Integer;
    begin
        // [SCENARIO] Today's packaging policy: no SKU unlocks the ticketing areas without the back office. Remove this
        // test deliberately if a ticket-only SKU is ever approved; the filter itself does not assume it.
        // [WHEN] Checking every SKU that grants Ticket Management
        // [THEN] It also grants Back Office
        foreach Ordinal in Module.Ordinals() do begin
            Module := Enum::"NPR License Module".FromInteger(Ordinal);
            if LicenseCapabilityMgt.GrantsCapability(Module, "NPR License Capability"::TicketManagement) then
                Assert.IsTrue(LicenseCapabilityMgt.GrantsCapability(Module, "NPR License Capability"::BackOffice), StrSubstNo('%1 grants Ticket Management but not Back Office', Module));
        end;
    end;

    // The user's rows as a session would read them, then the filter.
    local procedure FilterFor(ApplicationAreas: Text; UserSecID: Guid): Text
    var
        AppAreaFilter: Codeunit "NPR License App Area Filter";
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Modules: List of [Enum "NPR License Module"];
    begin
        LicenseCapabilityMgt.GetModulesCountingForUI(UserSecID, Modules);
        exit(AppAreaFilter.FilterApplicationAreas(ApplicationAreas, Modules));
    end;

    local procedure Initialize()
    var
        LicenseUser: Record "NPR License User";
    begin
        LicenseUser.DeleteAll(false);
    end;

    local procedure SeedUser(UserSecID: Guid; Module: Enum "NPR License Module"; Status: Enum "NPR License User Status")
    var
        LicenseUser: Record "NPR License User";
    begin
        LicenseUser.Init();
        LicenseUser."User Security ID" := UserSecID;
        LicenseUser.Module := Module;
        LicenseUser."License Term" := "NPR License Term"::months12;
        LicenseUser.Status := Status;
        LicenseUser."Status Changed At" := CurrentDateTime();
        LicenseUser.Insert(false);
    end;

    local procedure UserA(): Guid
    begin
        exit('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    end;
}
