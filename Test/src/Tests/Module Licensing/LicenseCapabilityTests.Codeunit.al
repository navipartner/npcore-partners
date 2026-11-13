// Pins the SKU -> capability matrix from the 24. 8. 2026 meeting and the "any Active row grants" rule.
// License users are seeded with direct assignment + Insert(false), same as ModuleLicensingTests.
codeunit 85516 "NPR License Capability Tests"
{
    // [FEATURE] Module licensing: which capabilities each SKU grants, and which of a user's license rows count

    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Grants_RetailPOS()
    begin
        // [SCENARIO] Retail POS grants Back Office and POS End of Sale, not Ticket Management.
        AssertGrants("NPR License Module"::POS, true, true, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Grants_RetailWithoutPOS()
    begin
        // [SCENARIO] Retail without POS grants Back Office only.
        AssertGrants("NPR License Module"::RetailWithoutPOS, true, false, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Grants_AttractionPOS()
    begin
        // [SCENARIO] Attraction POS grants Back Office, POS End of Sale and Ticket Management.
        AssertGrants("NPR License Module"::AttractionPOS, true, true, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Grants_AttractionWithoutPOS()
    begin
        // [SCENARIO] Attraction without POS grants Back Office and Ticket Management, not POS End of Sale.
        AssertGrants("NPR License Module"::AttractionWithoutPOS, true, false, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Grants_Scanner()
    begin
        // [SCENARIO] A ticket scanner seat grants none of the gated capabilities.
        AssertGrants("NPR License Module"::Scanner, false, false, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Grants_KDS()
    begin
        // [SCENARIO] A KDS seat grants none of the gated capabilities.
        AssertGrants("NPR License Module"::KDS, false, false, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Grants_BlankModule_Nothing()
    begin
        // [SCENARIO] The blank module grants nothing.
        AssertGrants("NPR License Module"::_, false, false, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UserHasCapability_NoRows_False()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A user without license rows has no capability.
        // [GIVEN] No license rows
        Initialize();
        // [WHEN] Asking for Back Office
        // [THEN] It is not granted
        Assert.IsFalse(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::BackOffice), 'no rows -> no capability');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UserHasCapability_ActiveRowGrants()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] An active row grants exactly the capabilities of its SKU.
        // [GIVEN] An active Attraction without POS row
        Initialize();
        SeedUser(UserA(), "NPR License Module"::AttractionWithoutPOS, "NPR License User Status"::Active);
        // [WHEN] Asking for Ticket Management and POS End of Sale
        // [THEN] Ticket Management is granted, POS End of Sale is not
        Assert.IsTrue(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::TicketManagement), 'active attraction row grants ticket management');
        Assert.IsFalse(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::POSEndOfSale), 'attraction without POS does not grant end of sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UserHasCapability_SuspendedRowIgnored()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Only Active rows grant: automatically suspended, pending and manually disabled rows do not.
        // [GIVEN] Three users, each with an Attraction POS row in one of those statuses
        Initialize();
        SeedUser(UserA(), "NPR License Module"::AttractionPOS, "NPR License User Status"::SuspendedAutomatically);
        SeedUser(UserB(), "NPR License Module"::AttractionPOS, "NPR License User Status"::Pending);
        SeedUser(UserC(), "NPR License Module"::AttractionPOS, "NPR License User Status"::DisabledManually);
        // [WHEN] Asking each user for Ticket Management
        // [THEN] None of them has it
        Assert.IsFalse(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::TicketManagement), 'suspended row does not grant');
        Assert.IsFalse(LicenseCapabilityMgt.UserHasCapability(UserB(), "NPR License Capability"::TicketManagement), 'pending row does not grant');
        Assert.IsFalse(LicenseCapabilityMgt.UserHasCapability(UserC(), "NPR License Capability"::TicketManagement), 'manually disabled row does not grant');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UserHasCapability_AnyActiveRowGrants()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A suspended Retail POS row next to an active Attraction POS row still grants.
        // [GIVEN] An automatically suspended Retail POS row and an active Attraction POS row for the same user
        Initialize();
        SeedUser(UserA(), "NPR License Module"::POS, "NPR License User Status"::SuspendedAutomatically);
        SeedUser(UserA(), "NPR License Module"::AttractionPOS, "NPR License User Status"::Active);
        // [WHEN] Asking for POS End of Sale and Ticket Management
        // [THEN] Both are granted by the active row
        Assert.IsTrue(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::POSEndOfSale), 'active attraction POS grants end of sale');
        Assert.IsTrue(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::TicketManagement), 'active attraction POS grants ticket management');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UserHasCapability_OtherUserIgnored()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Another user's row grants nothing to this user.
        // [GIVEN] An active Retail POS row for user B only
        Initialize();
        SeedUser(UserB(), "NPR License Module"::POS, "NPR License User Status"::Active);
        // [WHEN] Asking both users for Back Office
        // [THEN] User A does not have it, user B does
        Assert.IsFalse(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::BackOffice), 'another user''s row does not grant');
        Assert.IsTrue(LicenseCapabilityMgt.UserHasCapability(UserB(), "NPR License Capability"::BackOffice), 'own row grants');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UserHasCapability_AutoSuspended_DoesNotGrant()
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] UserHasCapability is strict: the UI grace of an automatically suspended row does not apply here.
        // [GIVEN] An automatically suspended Retail POS row
        Initialize();
        SeedUser(UserA(), "NPR License Module"::POS, "NPR License User Status"::SuspendedAutomatically);
        // [WHEN] Asking for Back Office
        // [THEN] It is not granted
        Assert.IsFalse(LicenseCapabilityMgt.UserHasCapability(UserA(), "NPR License Capability"::BackOffice), 'strict: auto-suspended does not grant');
    end;

    local procedure AssertGrants(Module: Enum "NPR License Module"; BackOffice: Boolean; POSEndOfSale: Boolean; TicketManagement: Boolean)
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Assert: Codeunit Assert;
    begin
        Assert.AreEqual(BackOffice, LicenseCapabilityMgt.GrantsCapability(Module, "NPR License Capability"::BackOffice), StrSubstNo('%1 BackOffice', Module));
        Assert.AreEqual(POSEndOfSale, LicenseCapabilityMgt.GrantsCapability(Module, "NPR License Capability"::POSEndOfSale), StrSubstNo('%1 POSEndOfSale', Module));
        Assert.AreEqual(TicketManagement, LicenseCapabilityMgt.GrantsCapability(Module, "NPR License Capability"::TicketManagement), StrSubstNo('%1 TicketManagement', Module));
        Assert.IsFalse(LicenseCapabilityMgt.GrantsCapability(Module, "NPR License Capability"::_), StrSubstNo('%1 blank capability never granted', Module));
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

    local procedure UserB(): Guid
    begin
        exit('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');
    end;

    local procedure UserC(): Guid
    begin
        exit('cccccccc-cccc-cccc-cccc-cccccccccccc');
    end;
}
