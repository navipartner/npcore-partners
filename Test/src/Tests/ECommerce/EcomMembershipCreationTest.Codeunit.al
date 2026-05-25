#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85166 "NPR EcomMembershipCreationTest"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _MemberModuleLib: Codeunit "NPR Library - Member Module";
        _LibEcommerce: Codeunit "NPR Library Ecommerce";
        _MemberApiLib: Codeunit "NPR Library - Member XML API";
        _Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmMembership_PreCreatedToken()
    // Test: Membership pre-created via API, membership token passed in ecom line — ConfirmMembership links it to the order.
    var
        Assert: Codeunit Assert;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        // [Given] A GOLD membership pre-created via the membership API
        Assert.IsTrue(MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        // [Given] A member added to the membership
        _MemberModuleLib.SetRandomMemberInfoData(MemberInfoCapture);
        Assert.IsTrue(MemberApiLib.AddMembershipMember(Membership, MemberInfoCapture, MemberEntryNo, ResponseMessage), ResponseMessage);

        // [Given] An ecom sales order with a membership line carrying the token
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-320100', Membership);
        Commit();

        // [When] Process the membership line
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] MembershipEntry."Document No." = EcomSalesHeader."External No."
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        Assert.AreEqual(EcomSalesHeader."External No.", MembershipEntry."Document No.", 'MembershipEntry."Document No." must match EcomSalesHeader."External No."');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmMembership_ZeroUnitPrice_Confirmed()
    // Test: A captured membership line with Unit Price = 0 (free membership) goes through the full
    // ecommerce flow — membership gets linked and the entry is confirmed, with amount = 0,
    // while the underlying item still has its non-zero catalog price.
    var
        Assert: Codeunit Assert;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Item: Record Item;
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        // [Given] The membership item has a non-zero catalog Unit Price
        Item.Get('T-ECOM-ITEM');
        Assert.AreNotEqual(0, Item."Unit Price", 'Precondition: membership item should have a non-zero Unit Price');

        // [Given] A GOLD membership pre-created via the membership API
        Assert.IsTrue(MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        // [Given] An ecom sales order with a captured membership line at Unit Price = 0
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', Membership);
        EcomSalesLine."Unit Price" := 0;
        EcomSalesLine."Line Amount" := 0;
        EcomSalesLine.Modify();

        // [When] Process the membership line
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] Membership is linked to the ecom sale
        Membership.Get(Membership."Entry No.");

        // [Then] Membership entry is confirmed with the ecom order external no.
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        Assert.AreEqual(EcomSalesHeader."External No.", MembershipEntry."Document No.", 'MembershipEntry."Document No." must match EcomSalesHeader."External No."');

        // [Then] Membership entry amounts are 0 because the line was captured at Unit Price = 0
        Assert.AreEqual(0, MembershipEntry.Amount, 'MembershipEntry.Amount should be 0 because the line was captured at Unit Price = 0');
        Assert.AreEqual(0, MembershipEntry."Amount Incl VAT", 'MembershipEntry."Amount Incl VAT" should be 0 because the line was captured at Unit Price = 0');
        Assert.AreNotEqual(0, MembershipEntry."Unit Price", 'Unit Price should remain non-zero');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmMembership_SameOrderIsIdempotent()
    // Test: Calling Process a second time for the same ecom order is idempotent — no error is raised.
    var
        Assert: Codeunit Assert;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        Assert.IsTrue(MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-320100', Membership);
        Commit();

        // [When] Process the line twice for the same order
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        EcomCreateMMShipImpl.Process(EcomSalesLine); // must not raise an error
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmMembership_AlreadyConfirmedByOtherOrder_Errors()
    // Test: A membership already confirmed by order A cannot be confirmed by order B — error fires at import time.
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        Membership: Record "NPR MM Membership";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        // [Given] First order confirms the membership — sets Ecom Sale Id
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-320100', Membership);
        Commit();
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [When/Then] Importing a second order with the same token fails at import (ValidateMembershipToken checks Ecom Sale Id)
        asserterror _LibEcommerce.InsertEcomDocumentWithMembershipToken('TEST-ORDER-B', 'T-320100', Membership.SystemId, EcomSalesHeader2);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_DirectCreation()
    // Test: No pre-existing membership — membership is created directly during ecom processing.
    // Verifies: token set on line, MembershipEntry."Document No." confirmed.
    var
        Assert: Codeunit Assert;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipSystemId: Guid;
        UniqueEmail: Text[80];
    begin
        Initialize();
#pragma warning disable AA0139
        UniqueEmail := CopyStr(DelChr(Format(CreateGuid()), '=', '{}') + '@test.example.com', 1, MaxStrLen(UniqueEmail));
#pragma warning restore

        // [Given] Ecom doc imported via API with member data (no token — direct creation path)
        _LibEcommerce.InsertEcomDocumentWithMemberData('TEST-DIRECT-1', 'T-ECOM-ITEM', 'Jane', 'Doe', UniqueEmail, 1, EcomSalesHeader);

        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader.Modify();

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Membership);
        EcomSalesLine.FindFirst();
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
        Commit();

        // [When] Process the membership line
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] Membership token is now set on the line
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        Assert.IsFalse(IsNullGuid(EcomSalesLine."Membership Id"), 'Membership token must be set after direct creation');

        // [Then] Membership entry is confirmed with the ecom order external no.
        MembershipSystemId := EcomSalesLine."Membership Id";
        Membership.GetBySystemId(MembershipSystemId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        Assert.AreEqual(EcomSalesHeader."External No.", MembershipEntry."Document No.", 'MembershipEntry."Document No." must match EcomSalesHeader."External No." after direct creation');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_DirectCreation_WithMemberAddress()
    // Test: Direct creation with full member address data — MemberInfoCapture is consumed after processing.
    var
        Assert: Codeunit Assert;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipSystemId: Guid;
        UniqueEmail: Text[80];
    begin
        Initialize();
#pragma warning disable AA0139
        UniqueEmail := CopyStr(DelChr(Format(CreateGuid()), '=', '{}') + '@test.example.com', 1, MaxStrLen(UniqueEmail));
#pragma warning restore

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader.Modify();

        _LibEcommerce.CreateCapturedMembershipLineNoToken(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM');
        EcomSalesLine."Member First Name" := 'John';
        EcomSalesLine."Member Last Name" := 'Smith';
#pragma warning disable AA0139
        EcomSalesLine."Member Email" := UniqueEmail;
        EcomSalesLine."Member Phone No." := '+381601234567';
        EcomSalesLine."Member Address" := 'Test Street 1';
        EcomSalesLine."Member City" := 'Belgrade';
        EcomSalesLine."Member Country" := 'RS';
        EcomSalesLine."Member Post Code" := '11000';
#pragma warning restore
        EcomSalesLine.Modify();
        Commit();

        // [When]
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] Token set, membership linked
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        Assert.IsFalse(IsNullGuid(EcomSalesLine."Membership Id"), 'Membership token must be set');
        MembershipSystemId := EcomSalesLine."Membership Id";
        Membership.GetBySystemId(MembershipSystemId);

        // [Then] MemberInfoCapture was consumed (deleted after processing)
        MemberInfoCapture.SetRange("Membership Entry No.", Membership."Entry No.");
        Assert.IsTrue(MemberInfoCapture.IsEmpty(), 'MemberInfoCapture must be deleted after processing');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmMembership_BlockedMembership_Errors()
    // Test: Import fails when the membership token references a blocked membership.
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Membership: Record "NPR MM Membership";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        // [Given] Membership is blocked
        Membership.Blocked := true;
        Membership.Modify();
        Commit();

        // [When/Then] Import fails at validation — membership is blocked
        asserterror _LibEcommerce.InsertEcomDocumentWithMembershipToken('TEST-BLOCKED', 'T-320100', Membership.SystemId, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmMembership_MembershipNotFound_Errors()
    // Test: Import fails when the membership token references no existing membership.
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        RandomToken: Guid;
    begin
        Initialize();

        RandomToken := CreateGuid(); // random — no matching membership

        // [When/Then] Import fails at validation — membership not found
        asserterror _LibEcommerce.InsertEcomDocumentWithMembershipToken('TEST-NOTFOUND', 'T-320100', RandomToken, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_OrderAlreadyCreated_Errors()
    // Test: Process fails when the ecom order has already been converted to a BC sales order (Creation Status = Created).
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        // [Given] BC sales order was already created from this ecom order
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader.Modify();

        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-320100', Membership);
        Commit();

        // [When/Then] Process raises a FieldError on Creation Status
        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_WrongSubtype_Errors()
    // Test: Process fails when the line subtype is not Membership.
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);

        // [Given] Line subtype is Ticket, not Membership
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."Line No." := 10000;
        EcomSalesLine."No." := 'T-320100';
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Ticket;
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 100;
        EcomSalesLine."Line Amount" := 100;
        EcomSalesLine.Captured := true;
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine.Insert(true);
        Commit();

        // [When/Then] FieldError on Subtype
        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_NotCaptured_Errors()
    // Test: Process fails when the line has not been captured (payment not settled).
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);

        // [Given] Membership line with Captured = false
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-320100', Membership);
        EcomSalesLine.Captured := false;
        EcomSalesLine.Modify();
        Commit();

        // [When/Then] FieldError on Captured
        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_GroupMembership_Errors()
    // Test: Import fails when membership item is of type GROUP — only INDIVIDUAL is allowed for direct ecom creation.
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        UniqueEmail: Text;
    begin
        Initialize();
        UniqueEmail := DelChr(Format(CreateGuid()), '=', '{}') + '@test.example.com';

        // [When/Then] Import fails at validation — GROUP membership type not allowed
        asserterror _LibEcommerce.InsertEcomDocumentWithMemberData('TEST-GROUP', 'T-320100', 'Jane', 'Doe', UniqueEmail, 1, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateMembershipToken_QuantityNotOne_Errors()
    // Test: Import fails when quantity is not 1 on a membership line with a token.
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Membership: Record "NPR MM Membership";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        // [When/Then] Import fails at validation — quantity must be 1
        asserterror _LibEcommerce.InsertEcomDocumentWithMembershipTokenQty('TEST-TOKEN-QTY3', 'T-320100', Membership.SystemId, 3, EcomSalesHeader);
    end;

    local procedure Initialize()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ExtendAlterationSetup: Record "NPR MM Members. Alter. Setup";
        ExtendSetupId: Guid;
    begin
        if _IsInitialized then
            exit;

        _MemberModuleLib.Initialize();
        _MemberModuleLib.CreateScenario_SmokeTest();

        // Create an INDIVIDUAL membership for direct-creation ecom tests (SmokeTest only creates GROUP memberships)
        MembershipSetup.Get('T-GOLD');
        // Multi-qty create reuses the line's member fields for every issued membership; the multi-qty tests below cover ecom linking, not member uniqueness/logon.
        MemberCommunity.Get(MembershipSetup."Community Code");
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::NONE;
        MemberCommunity."Member Logon Credentials" := MemberCommunity."Member Logon Credentials"::NA;
        MemberCommunity.Modify();

        _MemberModuleLib.SetupMembership_Simple(MembershipSetup."Community Code", 'T-ECOM', '', 'Ecom Individual Membership');
        MembershipSetup.Get('T-ECOM');
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup.Modify();

        _MemberModuleLib.CreateItem('T-ECOM-ITEM', '', 'Ecom Individual Membership Item', 100);
        _MemberModuleLib.SetupSimpleMembershipSalesItem('T-ECOM-ITEM', 'T-ECOM');

        _MemberModuleLib.SetupRenew_NoGraceNotStackable(
            'T-ECOM',
            _MemberModuleLib.CreateItem('T-ECOM-ITEM-RENEW', '', 'Renew Ecom Membership Item', 100),
            '',
            'Renew Ecom Membership');

        ExtendSetupId := _MemberModuleLib.SetupExtend(
            'T-ECOM',
            _MemberModuleLib.CreateItem('T-ECOM-ITEM-EXTEND', '', 'Extend Ecom Membership Item', 50),
            '',
            '<+1Y>',
            'Extend Ecom Membership');
        ExtendAlterationSetup.GetBySystemId(ExtendSetupId);
        ExtendAlterationSetup."Alteration Activate From" := ExtendAlterationSetup."Alteration Activate From"::DF;
        Evaluate(ExtendAlterationSetup."Alteration Date Formula", '<+1D>');
        ExtendAlterationSetup.Modify();

        _MemberModuleLib.SetupMembership_Simple(MembershipSetup."Community Code", 'T-ECOM-GOLD', '', 'Ecom Gold Membership');
        MembershipSetup.Get('T-ECOM-GOLD');
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup.Modify();

        _MemberModuleLib.SetupUpgrade(
            'T-ECOM',
            _MemberModuleLib.CreateItem('T-ECOM-ITEM-UPGRADE', '', 'Upgrade Ecom Membership Item', 150),
            'T-ECOM-GOLD',
            '<+1Y>',
            'Upgrade Ecom Membership to Gold');

        MembershipSalesSetup.SetRange("Membership Code", 'T-ECOM');
        if MembershipSalesSetup.FindFirst() then begin
            MembershipSalesSetup.Blocked := false;
            MembershipSalesSetup.Modify();
        end;

        _IsInitialized := true;
    end;
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_CreateMembership_Qty1_BackCompat()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] qty=1 CreateMembership → 1 link row, Membership Id written back.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 1, 100);
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesMembershipLink.Count(), 'Expected exactly 1 link row for qty=1.');

        _Assert.IsFalse(IsNullGuid(EcomSalesLine."Membership Id"), 'Membership Id should be set for qty=1.');

        Membership.GetBySystemId(EcomSalesLine."Membership Id");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_CreateMembership_Qty5_HappyPath()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EventCounter: Codeunit "NPR EcomMbrEventCounter";
        EmptyGuid: Guid;
    begin
        // [Scenario] qty=5 CreateMembership → 5 distinct memberships, 5 link rows, Membership Id empty; events fire once per line.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 5, 100);
        Commit();

        BindSubscription(EventCounter);
        EventCounter.ResetCounters();
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        UnbindSubscription(EventCounter);

        EcomSalesLine.Get(EcomSalesLine.RecordId);

        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(5, EcomSalesMembershipLink.Count(), 'Expected 5 link rows for qty=5.');

        _Assert.IsTrue(IsNullGuid(EcomSalesLine."Membership Id"), 'Membership Id should be empty Guid for qty>1.');

        AssertDistinctMembershipIds(EcomSalesMembershipLink);

        _Assert.AreEqual(1, EventCounter.GetCreatedCount(), 'OnAfterMembershipCreatedBeforeCommit must fire exactly once for the line.');
        _Assert.AreEqual(1, EventCounter.GetConfirmedCount(), 'OnAfterMembershipConfirmedBeforeCommit must fire exactly once for the line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_QuantityIngestValidation_ZeroRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] Quantity = 0 is rejected by CheckIfLineCanBeProcessed.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 1, 100);
        EcomSalesLine.Quantity := 0;
        EcomSalesLine."Line Amount" := 0;
        EcomSalesLine.Modify();
        Commit();

        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_QuantityIngestValidation_NegativeRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] Quantity = -1 is rejected by CheckIfLineCanBeProcessed.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 1, 100);
        EcomSalesLine.Quantity := -1;
        EcomSalesLine."Line Amount" := -100;
        EcomSalesLine.Modify();
        Commit();

        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_QuantityIngestValidation_FractionalRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] Fractional Quantity (2.5) is rejected by CheckIfLineCanBeProcessed.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 1, 100);
        EcomSalesLine.Quantity := 2.5;
        EcomSalesLine."Line Amount" := 250;
        EcomSalesLine.Modify();
        Commit();

        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_QuantityIngestValidation_Create5_PassesGate()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] CreateMembership with Quantity=5 passes the operation-conditional qty gate.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 5, 100);
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);   // must NOT error

        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(5, EcomSalesMembershipLink.Count(), 'Create with qty=5 should produce 5 link rows.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_NonCreateOperations_Qty5_ConfirmRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [Scenario] ConfirmMembership with qty=5 → ValidateMembershipForToken raises QuantityErr.
        Initialize();

        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedConfirmMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', Membership, 5, 100);
        Commit();

        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_NonCreateOperations_Qty5_RenewRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [Scenario] RenewMembership with qty=5 → ValidateMembershipAlterationRequest raises QuantityErr.
        Initialize();

        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::RENEW);
        if not AlterationSetup.FindFirst() then
            Error('Renew alteration setup for T-ECOM not found — check Initialize().');

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::RenewMembership, 5, 100);
        Commit();

        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_RaceRecovery_NoDuplicates()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EventCounter: Codeunit "NPR EcomMbrEventCounter";
        ModifiedAtBefore: array[3] of DateTime;
        i: Integer;
    begin
        // [Scenario] First process creates 3 memberships/link rows; race-recovery re-entry is a no-op (calling Process directly bypasses status flip).
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 3, 100);
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");
        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesMembershipLink.FindSet();
        i := 0;
        repeat
            i += 1;
            Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id");
            MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
            MembershipEntry.SetRange(Blocked, false);
            MembershipEntry.FindFirst();
            ModifiedAtBefore[i] := MembershipEntry.SystemModifiedAt;
        until EcomSalesMembershipLink.Next() = 0;

        BindSubscription(EventCounter);
        EventCounter.ResetCounters();
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        UnbindSubscription(EventCounter);

        EcomSalesMembershipLink.Reset();
        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(3, EcomSalesMembershipLink.Count(), 'Race recovery: link count must stay at 3 — no duplicates.');

        EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");
        EcomSalesMembershipLink.FindSet();
        i := 0;
        repeat
            i += 1;
            Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id");
            MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
            MembershipEntry.SetRange(Blocked, false);
            MembershipEntry.FindFirst();
            _Assert.AreEqual(ModifiedAtBefore[i], MembershipEntry.SystemModifiedAt, 'Membership entry must not be modified during race-recovery re-entry.');
        until EcomSalesMembershipLink.Next() = 0;

        _Assert.AreEqual(0, EventCounter.GetCreatedCount(), 'OnAfterMembershipCreatedBeforeCommit must NOT fire during race-recovery re-entry.');
        _Assert.AreEqual(0, EventCounter.GetConfirmedCount(), 'OnAfterMembershipConfirmedBeforeCommit must NOT fire during race-recovery re-entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_AccountingCorrectness_PriceExclVAT()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        LastLinkRow: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        WholeAmount: Decimal;
        WholeAmountInclVAT: Decimal;
        PerMembershipAmount: Decimal;
        PerMembershipAmountInclVAT: Decimal;
        Remainder: Decimal;
        RemainderInclVAT: Decimal;
        QtyToConfirm: Integer;
    begin
        // [Scenario] Price Excl. VAT = true; Line Amount 10.01, VAT 25%, qty=3; last-by-Entry-No carries rounding remainder.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Price Excl. VAT" := true;
        EcomSalesHeader.Modify();

        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 3, 100);
        EcomSalesLine."Line Amount" := 10.01;
        EcomSalesLine."VAT %" := 25;
        EcomSalesLine.Modify();
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);

        TotalAmount := 0;
        TotalAmountInclVAT := 0;
        EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");
        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesMembershipLink.FindSet();
        repeat
            Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id");
            MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
            MembershipEntry.SetRange(Blocked, false);
            MembershipEntry.FindFirst();
            TotalAmount += MembershipEntry.Amount;
            TotalAmountInclVAT += MembershipEntry."Amount Incl VAT";
        until EcomSalesMembershipLink.Next() = 0;

        _Assert.AreEqual(10.01, TotalAmount, 'Sum of Entry.Amount must equal whole-line excl. amount (10.01).');
        _Assert.AreEqual(12.51, TotalAmountInclVAT, 'Sum of Entry."Amount Incl VAT" must equal Round(10.01×1.25, 0.01) = 12.51.');

        QtyToConfirm := 3;
        WholeAmount := 10.01;
        WholeAmountInclVAT := 12.51;
        PerMembershipAmount := Round(WholeAmount / QtyToConfirm, 0.01);
        PerMembershipAmountInclVAT := Round(WholeAmountInclVAT / QtyToConfirm, 0.01);
        Remainder := WholeAmount - (PerMembershipAmount * (QtyToConfirm - 1));
        RemainderInclVAT := WholeAmountInclVAT - (PerMembershipAmountInclVAT * (QtyToConfirm - 1));

        LastLinkRow.SetCurrentKey("Source Line System Id", "Entry No.");
        LastLinkRow.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        LastLinkRow.FindLast();
        Membership.GetBySystemId(LastLinkRow."Membership System Id");
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        _Assert.AreEqual(Remainder, MembershipEntry.Amount, 'Last link row''s membership must carry the rounding remainder on Amount.');
        _Assert.AreEqual(RemainderInclVAT, MembershipEntry."Amount Incl VAT", 'Last link row''s membership must carry the rounding remainder on Amount Incl VAT.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_AccountingCorrectness_PriceInclVAT()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        LastLinkRow: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        WholeAmount: Decimal;
        WholeAmountInclVAT: Decimal;
        PerMembershipAmount: Decimal;
        PerMembershipAmountInclVAT: Decimal;
        Remainder: Decimal;
        RemainderInclVAT: Decimal;
        QtyToConfirm: Integer;
    begin
        // [Scenario] Price Incl. VAT = true; Line Amount 12.51, VAT 25%, qty=3; last-by-Entry-No carries rounding remainder.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Price Excl. VAT" := false;
        EcomSalesHeader.Modify();

        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 3, 100);
        EcomSalesLine."Line Amount" := 12.51;
        EcomSalesLine."VAT %" := 25;
        EcomSalesLine.Modify();
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);

        TotalAmount := 0;
        TotalAmountInclVAT := 0;
        EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");
        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesMembershipLink.FindSet();
        repeat
            Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id");
            MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
            MembershipEntry.SetRange(Blocked, false);
            MembershipEntry.FindFirst();
            TotalAmount += MembershipEntry.Amount;
            TotalAmountInclVAT += MembershipEntry."Amount Incl VAT";
        until EcomSalesMembershipLink.Next() = 0;

        _Assert.AreEqual(12.51, TotalAmountInclVAT, 'Sum of Entry."Amount Incl VAT" must equal whole-line incl. amount (12.51).');
        _Assert.AreEqual(10.01, TotalAmount, 'Sum of Entry.Amount must equal Round(12.51/1.25, 0.01) = 10.01.');

        QtyToConfirm := 3;
        WholeAmountInclVAT := 12.51;
        WholeAmount := 10.01;
        PerMembershipAmountInclVAT := Round(WholeAmountInclVAT / QtyToConfirm, 0.01);
        PerMembershipAmount := Round(WholeAmount / QtyToConfirm, 0.01);
        Remainder := WholeAmount - (PerMembershipAmount * (QtyToConfirm - 1));
        RemainderInclVAT := WholeAmountInclVAT - (PerMembershipAmountInclVAT * (QtyToConfirm - 1));

        LastLinkRow.SetCurrentKey("Source Line System Id", "Entry No.");
        LastLinkRow.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        LastLinkRow.FindLast();
        Membership.GetBySystemId(LastLinkRow."Membership System Id");
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        _Assert.AreEqual(Remainder, MembershipEntry.Amount, 'Last link row''s membership must carry the rounding remainder on Amount (Price Incl. VAT path).');
        _Assert.AreEqual(RemainderInclVAT, MembershipEntry."Amount Incl VAT", 'Last link row''s membership must carry the rounding remainder on Amount Incl VAT (Price Incl. VAT path).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_ConfirmOperation_WritesLinkRow()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EventCounter: Codeunit "NPR EcomMbrEventCounter";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [Scenario] Pre-created membership confirmed → 1 link row, Document No. stamped, Confirmed event fires once.
        Initialize();

        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', Membership);
        Commit();

        BindSubscription(EventCounter);
        EventCounter.ResetCounters();
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        UnbindSubscription(EventCounter);

        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesMembershipLink.Count(), 'ConfirmMembership must write exactly 1 link row.');
        EcomSalesMembershipLink.FindFirst();
        _Assert.AreEqual(Membership.SystemId, EcomSalesMembershipLink."Membership System Id", 'Link row must point at the confirmed membership.');

        EcomSalesLine.Get(EcomSalesLine.RecordId);
        _Assert.AreEqual(Membership.SystemId, EcomSalesLine."Membership Id", 'Membership Id on line must remain set after Confirm.');

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        _Assert.AreEqual(EcomSalesHeader."External No.", MembershipEntry."Document No.", 'MembershipEntry."Document No." must match EcomSalesHeader."External No."');

        _Assert.AreEqual(1, EventCounter.GetConfirmedCount(), 'OnAfterMembershipConfirmedBeforeCommit must fire exactly once for ConfirmMembership.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_AlterationOperation_WritesLinkRow_AndRaceRecovery()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EventCounter: Codeunit "NPR EcomMbrEventCounter";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
        ValidUntilAfterRenew: Date;
        ValidUntilBeforeRenew: Date;
    begin
        // [Scenario] Renew writes 1 link row and updates dates; race-recovery re-entry is a no-op (no second link, no second event).
        Initialize();

        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::RENEW);
        if not AlterationSetup.FindFirst() then
            Error('Renew alteration setup for T-ECOM not found — check Initialize().');

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader.Modify();
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::RenewMembership, 1, 100);
        Commit();

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.FindLast();
        ValidUntilBeforeRenew := MembershipEntry."Valid Until Date";

        BindSubscription(EventCounter);
        EventCounter.ResetCounters();
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        UnbindSubscription(EventCounter);

        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesMembershipLink.Count(), 'First run: exactly 1 link row expected after Renew.');

        MembershipEntry.Reset();
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.FindLast();
        ValidUntilAfterRenew := MembershipEntry."Valid Until Date";
        _Assert.IsTrue(ValidUntilAfterRenew > ValidUntilBeforeRenew, 'Membership Valid Until must advance after Renew.');

        _Assert.AreEqual(1, EventCounter.GetRenewedCount(), 'OnAfterMembershipRenewedBeforeCommit must fire exactly once on first run.');

        EcomSalesLine.Get(EcomSalesLine.RecordId);
        BindSubscription(EventCounter);
        EventCounter.ResetCounters();
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        UnbindSubscription(EventCounter);

        EcomSalesMembershipLink.Reset();
        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesMembershipLink.Count(), 'Race recovery: link count must stay at 1 — no second alteration.');

        MembershipEntry.Reset();
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.FindLast();
        _Assert.AreEqual(ValidUntilAfterRenew, MembershipEntry."Valid Until Date", 'Membership Valid Until must not change on race-recovery re-run.');

        _Assert.AreEqual(0, EventCounter.GetRenewedCount(), 'OnAfterMembershipRenewedBeforeCommit must NOT fire during race-recovery re-entry.');
    end;

    [Test]
    [HandlerFunctions('NprMembershipsPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_ShowRelated_LineLevel_Qty5_OpensListPage()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TempMembership: Record "NPR MM Membership" temporary;
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] qty=5 line processed → 5 membership rows in buffer; ShowRelatedMembershipsAction opens the page.
        Initialize();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 5, 100);
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        EcomCreateMMShipImpl.BuildMembershipTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempMembership);
        _Assert.AreEqual(5, TempMembership.Count(), 'BuildMembershipTempBufferForLine must return 5 rows for qty=5 line.');

        EcomCreateMMShipImpl.ShowRelatedMembershipsAction(EcomSalesLine);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_ThreeSurfaces_Coherent_AllFiveOperations()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LineA: Record "NPR Ecom Sales Line";
        LineB: Record "NPR Ecom Sales Line";
        LineC: Record "NPR Ecom Sales Line";
        LineD: Record "NPR Ecom Sales Line";
        LineE: Record "NPR Ecom Sales Line";
        MembershipB: Record "NPR MM Membership";
        MembershipC: Record "NPR MM Membership";
        MembershipD: Record "NPR MM Membership";
        MembershipE: Record "NPR MM Membership";
        AlterationSetupRenew: Record "NPR MM Members. Alter. Setup";
        AlterationSetupExtend: Record "NPR MM Members. Alter. Setup";
        AlterationSetupUpgrade: Record "NPR MM Members. Alter. Setup";
        TempMembershipDoc: Record "NPR MM Membership" temporary;
        TempMembershipLineA: Record "NPR MM Membership" temporary;
        TempMembershipLineB: Record "NPR MM Membership" temporary;
        TempMembershipLineC: Record "NPR MM Membership" temporary;
        TempMembershipLineD: Record "NPR MM Membership" temporary;
        TempMembershipLineE: Record "NPR MM Membership" temporary;
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        MbrOperation: Enum "NPR ECom Membership Operation";
        MembershipEntryNoB: Integer;
        MembershipEntryNoC: Integer;
        MembershipEntryNoD: Integer;
        MembershipEntryNoE: Integer;
        ResponseMsg: Text;
    begin
        // [Scenario] 5 lines (Create×3, Confirm×1, Renew×1, Extend×1, Upgrade×1) → doc-level buffer has 7 rows; per-line buffers are disjoint and sum to 7.
        Initialize();

        _Assert.IsTrue(MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNoB, ResponseMsg), ResponseMsg);
        MembershipB.Get(MembershipEntryNoB);

        _Assert.IsTrue(MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNoC, ResponseMsg), ResponseMsg);
        MembershipC.Get(MembershipEntryNoC);

        _Assert.IsTrue(MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNoD, ResponseMsg), ResponseMsg);
        MembershipD.Get(MembershipEntryNoD);

        _Assert.IsTrue(MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNoE, ResponseMsg), ResponseMsg);
        MembershipE.Get(MembershipEntryNoE);

        AlterationSetupRenew.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetupRenew.SetRange("Alteration Type", AlterationSetupRenew."Alteration Type"::RENEW);
        if not AlterationSetupRenew.FindFirst() then
            Error('Renew alteration setup for T-ECOM not found — check Initialize().');

        AlterationSetupExtend.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetupExtend.SetRange("Alteration Type", AlterationSetupExtend."Alteration Type"::EXTEND);
        if not AlterationSetupExtend.FindFirst() then
            Error('Extend alteration setup for T-ECOM not found — check Initialize().');

        AlterationSetupUpgrade.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetupUpgrade.SetRange("Alteration Type", AlterationSetupUpgrade."Alteration Type"::UPGRADE);
        if not AlterationSetupUpgrade.FindFirst() then
            Error('Upgrade alteration setup for T-ECOM not found — check Initialize().');

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader.Modify();

        CreateCapturedCreateMembershipLine(LineA, EcomSalesHeader, 'T-ECOM-ITEM', 3, 100);
        CreateCapturedConfirmMembershipLine(LineB, EcomSalesHeader, 'T-ECOM-ITEM', MembershipB, 1, 100);
        CreateCapturedAlterationMembershipLine(LineC, EcomSalesHeader, AlterationSetupRenew."Sales Item No.", MembershipC, AlterationSetupRenew.SystemId, MbrOperation::RenewMembership, 1, 100);
        CreateCapturedAlterationMembershipLine(LineD, EcomSalesHeader, AlterationSetupExtend."Sales Item No.", MembershipD, AlterationSetupExtend.SystemId, MbrOperation::ExtendMembership, 1, 100);
        CreateCapturedAlterationMembershipLine(LineE, EcomSalesHeader, AlterationSetupUpgrade."Sales Item No.", MembershipE, AlterationSetupUpgrade.SystemId, MbrOperation::UpgradeMembership, 1, 100);

        Commit();

        EcomCreateMMShipImpl.Process(LineA);
        LineA.Get(LineA.RecordId);

        EcomCreateMMShipImpl.Process(LineB);
        LineB.Get(LineB.RecordId);

        EcomCreateMMShipImpl.Process(LineC);
        LineC.Get(LineC.RecordId);

        EcomCreateMMShipImpl.Process(LineD);
        LineD.Get(LineD.RecordId);

        EcomCreateMMShipImpl.Process(LineE);
        LineE.Get(LineE.RecordId);

        EcomCreateMMShipImpl.BuildMembershipTempBufferForDoc(EcomSalesHeader, TempMembershipDoc);
        _Assert.AreEqual(7, TempMembershipDoc.Count(), 'Doc-level buffer must contain 7 rows (3 created + 1 confirmed + 1 renewed + 1 extended + 1 upgraded).');

        EcomCreateMMShipImpl.BuildMembershipTempBufferForLine(EcomSalesHeader, LineA, TempMembershipLineA);
        _Assert.AreEqual(3, TempMembershipLineA.Count(), 'Line A buffer must contain 3 rows.');

        EcomCreateMMShipImpl.BuildMembershipTempBufferForLine(EcomSalesHeader, LineB, TempMembershipLineB);
        _Assert.AreEqual(1, TempMembershipLineB.Count(), 'Line B buffer must contain 1 row.');

        EcomCreateMMShipImpl.BuildMembershipTempBufferForLine(EcomSalesHeader, LineC, TempMembershipLineC);
        _Assert.AreEqual(1, TempMembershipLineC.Count(), 'Line C buffer must contain 1 row.');

        EcomCreateMMShipImpl.BuildMembershipTempBufferForLine(EcomSalesHeader, LineD, TempMembershipLineD);
        _Assert.AreEqual(1, TempMembershipLineD.Count(), 'Line D buffer must contain 1 row.');

        EcomCreateMMShipImpl.BuildMembershipTempBufferForLine(EcomSalesHeader, LineE, TempMembershipLineE);
        _Assert.AreEqual(1, TempMembershipLineE.Count(), 'Line E buffer must contain 1 row.');

        _Assert.AreEqual(
            TempMembershipDoc.Count(),
            TempMembershipLineA.Count() + TempMembershipLineB.Count() + TempMembershipLineC.Count() + TempMembershipLineD.Count() + TempMembershipLineE.Count(),
            'Per-line buffer counts must sum to the doc-level buffer count (no overlap).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_QtyMulti_ErrorPolicy_RejectedByValidator()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PrevUniqueIdentity: Option;
        PrevViolation: Option;
    begin
        // [Scenario] qty>1 + community Member Unique Identity = EMAIL + Create Member UI Violation = Error + line carries Email
        // → ValidateMembershipRequestForDirectCreation rejects upfront with QtyMultiNeedsPermissiveCommunityErr.
        Initialize();

        MembershipSetup.Get('T-ECOM');
        MemberCommunity.Get(MembershipSetup."Community Code");
        PrevUniqueIdentity := MemberCommunity."Member Unique Identity";
        PrevViolation := MemberCommunity."Create Member UI Violation";
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::EMAIL;
        MemberCommunity."Create Member UI Violation" := MemberCommunity."Create Member UI Violation"::Error;
        MemberCommunity.Modify();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 3, 100);
        Commit();

        asserterror EcomCreateMMShipImpl.ValidateMembershipRequestForDirectCreation(EcomSalesLine);
        _Assert.ExpectedError('Multi-quantity membership lines with identity fields');

        // Restore community to baseline (NONE/NA) so subsequent tests see the permissive state.
        MemberCommunity."Member Unique Identity" := PrevUniqueIdentity;
        MemberCommunity."Create Member UI Violation" := PrevViolation;
        MemberCommunity.Modify();
        Commit();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_QtyMulti_MergePolicy_AllLinkToOneMember()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        SeenMemberEntryNos: Dictionary of [Integer, Boolean];
        Placeholder: Boolean;
        PrevUniqueIdentity: Option;
        PrevViolation: Option;
        PrevLogonCredentials: Option;
    begin
        // [Scenario] qty=5 + community Member Unique Identity = EMAIL + Create Member UI Violation = Merge + line carries Email
        // → AllowMergeOnConflict opt-in lets the Job Queue flow succeed; all 5 memberships link to one Member entity.
        Initialize();

        MembershipSetup.Get('T-ECOM');
        MemberCommunity.Get(MembershipSetup."Community Code");
        PrevUniqueIdentity := MemberCommunity."Member Unique Identity";
        PrevViolation := MemberCommunity."Create Member UI Violation";
        PrevLogonCredentials := MemberCommunity."Member Logon Credentials";
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::EMAIL;
        MemberCommunity."Create Member UI Violation" := MemberCommunity."Create Member UI Violation"::MERGE_MEMBER;
        MemberCommunity."Member Logon Credentials" := MemberCommunity."Member Logon Credentials"::NA;
        MemberCommunity.Modify();

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 5, 100);
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);

        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(5, EcomSalesMembershipLink.Count(), 'Expected 5 link rows for qty=5 Merge case.');

        EcomSalesMembershipLink.FindSet();
        repeat
            Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id");
            MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
            MembershipRole.SetRange(Blocked, false);
            MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
            if MembershipRole.FindSet() then
                repeat
                    if not SeenMemberEntryNos.ContainsKey(MembershipRole."Member Entry No.") then
                        SeenMemberEntryNos.Add(MembershipRole."Member Entry No.", Placeholder);
                until MembershipRole.Next() = 0;
        until EcomSalesMembershipLink.Next() = 0;

        _Assert.AreEqual(1, SeenMemberEntryNos.Count(), 'All 5 memberships must link to exactly one Member entity.');

        // Restore community to baseline (NONE/NA) so subsequent tests see the permissive state.
        MemberCommunity."Member Unique Identity" := PrevUniqueIdentity;
        MemberCommunity."Create Member UI Violation" := PrevViolation;
        MemberCommunity."Member Logon Credentials" := PrevLogonCredentials;
        MemberCommunity.Modify();
        Commit();
    end;

    [PageHandler]
    procedure NprMembershipsPageHandler(var MembershipsPage: TestPage "NPR MM Memberships")
    begin
        MembershipsPage.Close();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure CreateCapturedCreateMembershipLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    var
        UniqueEmail: Text[80];
    begin
#pragma warning disable AA0139
        UniqueEmail := CopyStr(DelChr(Format(CreateGuid()), '=', '{}') + '@multitest.example.com', 1, MaxStrLen(UniqueEmail));
#pragma warning restore

        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
#pragma warning disable AA0139
        EcomSalesLine."No." := ItemNo;
        EcomSalesLine."Member First Name" := 'Test';
        EcomSalesLine."Member Last Name" := 'User';
        EcomSalesLine."Member Email" := UniqueEmail;
#pragma warning restore
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine."Membership Operation" := EcomSalesLine."Membership Operation"::CreateMembership;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure CreateCapturedConfirmMembershipLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Membership: Record "NPR MM Membership"; Qty: Decimal; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
#pragma warning disable AA0139
        EcomSalesLine."No." := ItemNo;
#pragma warning restore
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine."Membership Operation" := EcomSalesLine."Membership Operation"::ConfirmMembership;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure CreateCapturedAlterationMembershipLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Membership: Record "NPR MM Membership"; AlterationOptionSystemId: Guid; MembershipOperation: Enum "NPR ECom Membership Operation"; Qty: Decimal; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
#pragma warning disable AA0139
        EcomSalesLine."No." := ItemNo;
#pragma warning restore
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine."Alteration Option System Id" := AlterationOptionSystemId;
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine."Membership Operation" := MembershipOperation;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure AssertDistinctMembershipIds(var EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link")
    var
        SeenIds: Dictionary of [Guid, Boolean];
        Placeholder: Boolean;
    begin
        EcomSalesMembershipLink.Reset();
        EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");
        EcomSalesMembershipLink.FindSet();
        repeat
            if SeenIds.ContainsKey(EcomSalesMembershipLink."Membership System Id") then
                Error('Duplicate Membership System Id found in link rows — memberships are not distinct.');
            SeenIds.Add(EcomSalesMembershipLink."Membership System Id", Placeholder);
        until EcomSalesMembershipLink.Next() = 0;
    end;

    local procedure GetNextLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        ExistingLine: Record "NPR Ecom Sales Line";
    begin
        ExistingLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if ExistingLine.FindLast() then
            exit(ExistingLine."Line No." + 10000);
        exit(10000);
    end;
}
#endif
