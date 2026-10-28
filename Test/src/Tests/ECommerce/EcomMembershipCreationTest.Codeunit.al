#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85166 "NPR EcomMembershipCreationTest"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _MemberModuleLib: Codeunit "NPR Library - Member Module";
        _LibEcommerce: Codeunit "NPR Library Ecommerce";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _MemberApiLib: Codeunit "NPR Library - Member XML API";
        _LibPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
    procedure ConfirmMembership_FCYDocument_EntryAmountInLCY()
    // Test: A membership confirmed from an FCY ecom document stores the LCY amount on the membership entry
    // (Line Amount 100 FCY at factor 0.1 -> 1000 LCY), matching the POS/retail convention, not the raw FCY line amount.
    var
        Assert: Codeunit Assert;
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();

        // [Given] An FCY currency with exchange-rate factor 0.1 (AmountLCY = AmountFCY / factor)
        _LibEcommerce.CreateFCYCurrency(Currency, 0.1);

        // [Given] A membership pre-created via the membership API
        Assert.IsTrue(MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        // [Given] An FCY ecom sales order carrying the exchange-rate factor, with a captured membership line at Line Amount 100 FCY
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Currency Code" := Currency.Code;
        EcomSalesHeader."Currency Exchange Rate" := 0.1;
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesHeader.Modify();
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', Membership);
        Commit();

        // [When] Process the membership line
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The membership entry carries the LCY amount (100 FCY / 0.1 = 1000), not the raw FCY line amount (100)
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        Assert.AreEqual(EcomSalesHeader."External No.", MembershipEntry."Document No.", 'MembershipEntry."Document No." must match EcomSalesHeader."External No."');
        Assert.AreEqual(1000, MembershipEntry.Amount, 'MembershipEntry.Amount must be the LCY amount (1000), not the FCY line amount.');
        Assert.AreEqual(1000, MembershipEntry."Amount Incl VAT", 'MembershipEntry."Amount Incl VAT" must be the LCY amount (1000), not the FCY line amount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_FCYDocument_EntryAmountInLCY()
    // Test: A membership created directly from an FCY ecom document (no pre-existing token) stores the LCY amount
    // on the membership entry - unit price 100 FCY at factor 0.1, Price Excl. VAT with 25% VAT -> 1000 LCY excl, 1250 LCY incl.
    var
        Assert: Codeunit Assert;
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        UniqueEmail: Text[80];
    begin
        Initialize();

        // [Given] An FCY currency with exchange-rate factor 0.1 (AmountLCY = AmountFCY / factor)
        _LibEcommerce.CreateFCYCurrency(Currency, 0.1);
#pragma warning disable AA0139
        UniqueEmail := CopyStr(DelChr(Format(CreateGuid()), '=', '{}') + '@test.example.com', 1, MaxStrLen(UniqueEmail));
#pragma warning restore

        // [Given] An FCY ecom order with a captured membership line for direct creation (no token), Price Excl. VAT with 25% VAT
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Currency Code" := Currency.Code;
        EcomSalesHeader."Currency Exchange Rate" := 0.1;
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesHeader."Price Excl. VAT" := true;
        EcomSalesHeader.Modify();

        _LibEcommerce.CreateCapturedMembershipLineNoToken(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM');
        EcomSalesLine."Member First Name" := 'Jane';
        EcomSalesLine."Member Last Name" := 'Doe';
#pragma warning disable AA0139
        EcomSalesLine."Member Email" := UniqueEmail;
#pragma warning restore
        EcomSalesLine."VAT %" := 25;
        EcomSalesLine.Modify();
        Commit();

        // [When] Process the membership line (direct creation path: CreateMembership + ConfirmAllMembershipsForLine)
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] Membership was created and the entry carries LCY amounts (100 FCY / 0.1 = 1000 excl, +25% VAT = 1250 incl)
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        Assert.IsFalse(IsNullGuid(EcomSalesLine."Membership Id"), 'Membership Id must be set after direct creation.');
        Membership.GetBySystemId(EcomSalesLine."Membership Id");

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        Assert.AreEqual(EcomSalesHeader."External No.", MembershipEntry."Document No.", 'MembershipEntry."Document No." must match EcomSalesHeader."External No.".');
        Assert.AreEqual(1000, MembershipEntry.Amount, 'MembershipEntry.Amount must be the LCY amount (1000), not the FCY line amount.');
        Assert.AreEqual(1250, MembershipEntry."Amount Incl VAT", 'MembershipEntry."Amount Incl VAT" must be the LCY amount grossed up by 25% VAT (1250).');
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

        _MemberModuleLib.SetupMembership_Simple(MemberCommunity.Code, 'T-ECOM-AGE', '', 'Ecom Age Check Membership');
        MembershipSetup.Get('T-ECOM-AGE');
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup.Modify();

        _MemberModuleLib.CreateItem('T-ECOM-AGE-ITEM', '', 'Ecom Age Check Membership Item', 100);
        _MemberModuleLib.SetupSimpleMembershipSalesItem('T-ECOM-AGE-ITEM', 'T-ECOM-AGE');

        MembershipSalesSetup.SetRange("Membership Code", 'T-ECOM-AGE');
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSalesDocument_IssuedAssets_MembershipIdResolvesToRealMembership()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] A processed qty=1 create-membership line issues a membership + link row. The GET
        // response must emit it under salesDocumentLines[].issuedAssets[], and the emitted id must
        // round-trip: GetBySystemId resolves a real membership whose referenceNo matches its External
        // Membership No. Guards the hoisted per-doc membership link buffer path end-to-end.
        Initialize();
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM', 1, 100);
        Commit();
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [When] the document is read back as Get V2 and as Get V3 build it
        // [Then] each version has exactly one line with exactly one issued asset, the membership
        AssertOneIssuedMembership(_LibDocApi.GetSalesDocumentTextV2(EcomSalesHeader), '(Get V2)');
        AssertOneIssuedMembership(_LibDocApi.GetSalesDocumentTextV3(EcomSalesHeader), '(Get V3)');
    end;

    local procedure AssertOneIssuedMembership(DocumentText: Text; Context: Text)
    var
        Membership: Record "NPR MM Membership";
        RootObject: JsonObject;
        LineObject: JsonObject;
        AssetObject: JsonObject;
        LinesArray: JsonArray;
        AssetsArray: JsonArray;
        JToken: JsonToken;
        LineToken: JsonToken;
        AssetToken: JsonToken;
        AssetId: Guid;
        AssetCount: Integer;
    begin
        RootObject.ReadFrom(DocumentText);

        RootObject.Get('salesDocumentLines', JToken);
        LinesArray := JToken.AsArray();
        _Assert.AreEqual(1, LinesArray.Count(), 'Expected exactly one sales document line. ' + Context);

        LinesArray.Get(0, LineToken);
        LineObject := LineToken.AsObject();
        LineObject.Get('issuedAssets', JToken);
        AssetsArray := JToken.AsArray();
        _Assert.AreEqual(1, AssetsArray.Count(), 'Expected exactly one issued asset for the qty=1 membership line. ' + Context);

        foreach AssetToken in AssetsArray do begin
            AssetObject := AssetToken.AsObject();

            AssetObject.Get('type', JToken);
            _Assert.AreEqual('membership', JToken.AsValue().AsText(), 'Issued asset type should be membership. ' + Context);

            AssetObject.Get('id', JToken);
            _Assert.IsTrue(Evaluate(AssetId, JToken.AsValue().AsText()), 'issuedAssets id must be a valid Guid. ' + Context);

            _Assert.IsTrue(Membership.GetBySystemId(AssetId), 'GetBySystemId must resolve the emitted issuedAssets id to a real membership. ' + Context);
            AssetObject.Get('referenceNo', JToken);
            _Assert.AreEqual(Membership."External Membership No.", JToken.AsValue().AsText(), 'issuedAssets referenceNo must match the resolved membership. ' + Context);

            AssetCount += 1;
        end;
        _Assert.AreEqual(1, AssetCount, 'Exactly one issued asset should have been asserted. ' + Context);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSalesDocument_IssuedAssets_MixedTypes_EachLineResolvesToOwnAsset()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        VoucherLine: Record "NPR Ecom Sales Line";
        CouponLine: Record "NPR Ecom Sales Line";
        MembershipLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] One document carries a voucher line, a coupon line, and a membership line. After each is
        // processed, the GET response must group issued assets correctly per line: the voucher line exposes
        // only its voucher, the coupon line only its coupon, the membership line only its membership — each
        // resolvable via GetBySystemId. This is the integration guard for the hoist: the three doc-wide link
        // buffers are loaded once and filtered in memory per line; a grouping bug would cross-wire assets.
        Initialize();
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);

        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(VoucherLine, EcomSalesHeader, VoucherType.Code, 1, 100);
        CreateCapturedCouponLine(CouponLine, EcomSalesHeader, _LibEcommerce.CreateEcomCouponItem(CouponType), 1, 100);
        CreateCapturedCreateMembershipLine(MembershipLine, EcomSalesHeader, 'T-ECOM-ITEM', 1, 100);
        Commit();

        VchrImpl.Process(VoucherLine);
        CouponImpl.Process(CouponLine);
        EcomCreateMMShipImpl.Process(MembershipLine);

        // [When] the document is read back as Get V2 and as Get V3 build it
        // [Then] in each version every line exposes exactly its own issued asset
        AssertEachLineHasOwnAsset(_LibDocApi.GetSalesDocumentTextV2(EcomSalesHeader), VoucherLine, CouponLine, MembershipLine, '(Get V2)');
        AssertEachLineHasOwnAsset(_LibDocApi.GetSalesDocumentTextV3(EcomSalesHeader), VoucherLine, CouponLine, MembershipLine, '(Get V3)');
    end;

    local procedure AssertEachLineHasOwnAsset(DocumentText: Text; VoucherLine: Record "NPR Ecom Sales Line"; CouponLine: Record "NPR Ecom Sales Line"; MembershipLine: Record "NPR Ecom Sales Line"; Context: Text)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpDcCoupon: Record "NPR NpDc Coupon";
        Membership: Record "NPR MM Membership";
        RootObject: JsonObject;
        LineObject: JsonObject;
        AssetObject: JsonObject;
        LinesArray: JsonArray;
        AssetsArray: JsonArray;
        JToken: JsonToken;
        LineToken: JsonToken;
        VoucherLineId: Text;
        CouponLineId: Text;
        MembershipLineId: Text;
        LineIdText: Text;
        AssetType: Text;
        AssetId: Guid;
        AssetsSeen: Integer;
    begin
        VoucherLineId := Format(VoucherLine.SystemId, 0, 4).ToLower();
        CouponLineId := Format(CouponLine.SystemId, 0, 4).ToLower();
        MembershipLineId := Format(MembershipLine.SystemId, 0, 4).ToLower();

        RootObject.ReadFrom(DocumentText);
        RootObject.Get('salesDocumentLines', JToken);
        LinesArray := JToken.AsArray();
        _Assert.AreEqual(3, LinesArray.Count(), 'Expected exactly three sales document lines. ' + Context);

        foreach LineToken in LinesArray do begin
            LineObject := LineToken.AsObject();
            LineObject.Get('id', JToken);
            LineIdText := JToken.AsValue().AsText();
            LineObject.Get('issuedAssets', JToken);
            AssetsArray := JToken.AsArray();
            _Assert.AreEqual(1, AssetsArray.Count(), StrSubstNo('Each asset-issuing line must expose exactly one issued asset. Line %1 %2', LineIdText, Context));

            AssetsArray.Get(0, JToken);
            AssetObject := JToken.AsObject();
            AssetObject.Get('type', JToken);
            AssetType := JToken.AsValue().AsText();
            AssetObject.Get('id', JToken);
            _Assert.IsTrue(Evaluate(AssetId, JToken.AsValue().AsText()), 'issuedAssets id must be a valid Guid. ' + Context);

            if LineIdText = VoucherLineId then begin
                _Assert.AreEqual('voucher', AssetType, 'Voucher line must expose a voucher asset. ' + Context);
                _Assert.IsTrue(NpRvVoucher.GetBySystemId(AssetId), 'Voucher issuedAssets id must resolve to a real voucher. ' + Context);
            end else
                if LineIdText = CouponLineId then begin
                    _Assert.AreEqual('coupon', AssetType, 'Coupon line must expose a coupon asset. ' + Context);
                    _Assert.IsTrue(NpDcCoupon.GetBySystemId(AssetId), 'Coupon issuedAssets id must resolve to a real coupon. ' + Context);
                end else
                    if LineIdText = MembershipLineId then begin
                        _Assert.AreEqual('membership', AssetType, 'Membership line must expose a membership asset. ' + Context);
                        _Assert.IsTrue(Membership.GetBySystemId(AssetId), 'Membership issuedAssets id must resolve to a real membership. ' + Context);
                    end else
                        Error('Unexpected sales document line id in response: %1 %2', LineIdText, Context);

            AssetsSeen += 1;
        end;
        _Assert.AreEqual(3, AssetsSeen, 'All three lines must have been asserted. ' + Context);
    end;

    local procedure CreateCapturedVoucherLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherTypeCode: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Voucher;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Voucher;
        EcomSalesLine."Voucher Type" := VoucherTypeCode;
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure CreateCapturedCouponLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Coupon;
#pragma warning disable AA0139
        EcomSalesLine."No." := ItemNo;
#pragma warning restore
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Test_ExtendMembership_RevalidatesCleanlyAfterProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [SCENARIO] Validation used to be re-run unconditionally by ValidateDocBySource on every sales-document
        // creation and capture attempt. Because the restriction rules compare the requested period against the
        // membership's LAST entry, and a completed extend makes that entry the one it just created, the line
        // was rejected forever with "period conflicts with the existing one" while already marked Processed.
        // Validation must therefore stand down once the alteration has been recorded.
        Initialize();

        // [GIVEN] A membership and the extend alteration option set up for it
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::EXTEND);
        if not AlterationSetup.FindFirst() then
            Error('Extend alteration setup for T-ECOM not found — check Initialize().');

        // [GIVEN] A captured ecom line asking to extend that membership
        // The document date is pinned, as the sibling alteration tests do: the resolved date drives both the
        // alteration's own start date and the one re-validation recomputes, and leaving it floating would let
        // a run that straddles midnight compute two different dates and mask the defect.
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader.Modify();
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::ExtendMembership, 1, 100);
        Commit();

        // [WHEN] The alteration is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        // [THEN] It is recorded as done
        EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");
        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesMembershipLink.Count(), 'The processed extend must have recorded exactly one membership link row.');

        // [THEN] Re-validating the document does not reject the line. Any error raised here fails the test;
        // before the fix this threw the conflicting-period error raised against the extend's own new entry.
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Test_RenewMembership_RevalidatesCleanlyAfterProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ValidUntilBefore: Date;
        ValidUntilAfter: Date;
        ResponseMessage: Text;
    begin
        // [SCENARIO] Renew: Re-validation compares the entry active today (the old one) against the new future entry and raises "stacking not allowed".
        Initialize();

        // [GIVEN] A membership and the non-stackable renew option set up for it
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
        ValidUntilBefore := LastMembershipEntryValidUntil(Membership);
        Commit();

        // [WHEN] The alteration is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        // [THEN] The renew really happened - without this the test would still pass if Process silently
        // became a no-op, since re-validation of an unaltered membership succeeds anyway
        ValidUntilAfter := LastMembershipEntryValidUntil(Membership);
        _Assert.IsTrue(ValidUntilAfter > ValidUntilBefore, 'Membership Valid Until must advance after Renew.');

        // [THEN] Re-validating the document does not reject the line
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Test_UpgradeMembership_RevalidatesCleanlyAfterProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [SCENARIO] The upgrade rewrites the membership's own Membership Code to the To-code, so on the second pass the alteration
        // setup no longer matches the membership and validation dies on the setup-mismatch check, long before
        // any date rule is reached.
        Initialize();

        // [GIVEN] A membership and the upgrade option that moves it to a different membership code
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::UPGRADE);
        if not AlterationSetup.FindFirst() then
            Error('Upgrade alteration setup for T-ECOM not found — check Initialize().');
        _Assert.AreNotEqual(AlterationSetup."From Membership Code", AlterationSetup."To Membership Code", 'Precondition: the upgrade must change the membership code, or this test proves nothing.');

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader.Modify();
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::UpgradeMembership, 1, 100);
        Commit();

        // [WHEN] The alteration is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        // [THEN] The upgrade really happened - and this is the very state that breaks re-validation, since the
        // setup's "From Membership Code" no longer matches the membership
        Membership.Get(Membership."Entry No.");
        _Assert.AreEqual(AlterationSetup."To Membership Code", Membership."Membership Code", 'The upgrade must have moved the membership to the To Membership Code.');

        // [THEN] Re-validating the document does not reject the line
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Test_ExtendMembership_DocumentValidatesAfterProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [SCENARIO] An ecommerce document containing an already processed membership alteration can be validated successfully before sales order creation.
        Initialize();

        // [GIVEN] A membership and the extend option set up for it
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::EXTEND);
        if not AlterationSetup.FindFirst() then
            Error('Extend alteration setup for T-ECOM not found — check Initialize().');

        // [GIVEN] A document that carries a store code, so ValidateDocBySource does not exit at its own gate
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Ecommerce Store Code" := 'TEST-STORE';
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader.Modify();
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::ExtendMembership, 1, 100);

        // [GIVEN] A matching payment line. ValidateDocBySource validates the whole order, and a non-zero
        // document with no payment lines is rejected by the payment check that runs after the line checks,
        // so the fixture needs one for the call to complete.
        CreateCapturedPaymentLine(EcomSalesHeader, 100);
        Commit();

        // [WHEN] The alteration is provisioned
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        // [THEN] The document validates. Before the fix this raised the conflicting-period error against the
        // extend's own new entry, and kept raising it on every creation and capture attempt.
        EcomSalesDocUtils.ValidateDocBySource(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_AlterationMarker_LinkForDifferentMembership_IsRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipTargeted: Record "NPR MM Membership";
        MembershipOther: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [SCENARIO] A processed-alteration marker is rejected when it points to 
        //a different membership than the one targeted by the ecommerce line.
        Initialize();

        // [GIVEN] Two memberships and an extend option
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        MembershipTargeted.Get(MembershipEntryNo);
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        MembershipOther.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::EXTEND);
        if not AlterationSetup.FindFirst() then
            Error('Extend alteration setup for T-ECOM not found — check Initialize().');

        // [GIVEN] A line targeting the first membership, but a link row recorded against the second
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", MembershipTargeted, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::ExtendMembership, 1, 100);
        InsertMembershipLinkRow(EcomSalesHeader, EcomSalesLine, MembershipOther);

        // [WHEN] The document is validated
        // [THEN] The mismatch is reported rather than treated as completed work
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        _Assert.ExpectedError('points at a different membership');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_AlterationMarker_MultipleLinkRows_AreRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [SCENARIO] An alteration line may produce at most one link row. More than one means the marker has
        // been corrupted, and validation must say so instead of short-circuiting on the first row it finds.
        Initialize();

        // [GIVEN] A membership and an extend option
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::EXTEND);
        if not AlterationSetup.FindFirst() then
            Error('Extend alteration setup for T-ECOM not found — check Initialize().');

        // [GIVEN] A line carrying two link rows for the same membership
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::ExtendMembership, 1, 100);
        InsertMembershipLinkRow(EcomSalesHeader, EcomSalesLine, Membership);
        InsertMembershipLinkRow(EcomSalesHeader, EcomSalesLine, Membership);

        // Deliberately NOT committed: two link rows for one membership is a state AssertDistinctMembershipIds
        // forbids table-wide, so letting the asserterror roll them back keeps them out of later tests.

        // [WHEN] The document is validated
        // [THEN] The corruption is reported
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        _Assert.ExpectedError('link row(s) exist');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_AlterationMarker_DoesNotMaskQuantityViolation()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [SCENARIO] An existing processed-alteration marker does not bypass validation of an invalid alteration quantity.
        Initialize();

        // [GIVEN] A membership and an extend option
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::EXTEND);
        if not AlterationSetup.FindFirst() then
            Error('Extend alteration setup for T-ECOM not found — check Initialize().');

        // [GIVEN] An alteration line with quantity 2 that already carries a valid link row
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::ExtendMembership, 2, 100);
        InsertMembershipLinkRow(EcomSalesHeader, EcomSalesLine, Membership);

        // [WHEN] The document is validated
        // [THEN] The quantity violation still wins over the marker
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        _Assert.ExpectedError('quantity must be 1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Test_AlterationRequest_StillValidatedWhenNotYetApplied()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [SCENARIO] Membership alteration validation is still performed 
        //when the alteration has not yet been processed.
        Initialize();

        // [GIVEN] A blocked membership and an extend option, and NO link row - the alteration has not run
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);
        Membership.Blocked := true;
        Membership.Modify();

        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::EXTEND);
        if not AlterationSetup.FindFirst() then
            Error('Extend alteration setup for T-ECOM not found — check Initialize().');

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::ExtendMembership, 1, 100);
        Commit();

        // [WHEN] The document is validated
        // [THEN] The precondition still bites
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        _Assert.ExpectedError('is blocked');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_AgeVerificationOff_IgnoresAgeConstraint()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] With age verification off, the item's age constraint is not checked.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification off, item requires an age greater than 2 years
        SetAgeVerification(false, MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSalesSetup."Age Constraint Type"::GT, 2);
        // [GIVEN] A member born on 12 December 2024
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(12, 12, 2024), DMY2Date(13, 10, 2026));

        // [WHEN] The line is validated
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);

        // [THEN] No error is raised
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_OlderThanRequired_GT_Passes()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] A member older than the minimum age passes a "greater than" constraint checked on the sales date.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on against the sales date, item requires an age greater than 2 years
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSalesSetup."Age Constraint Type"::GT, 2);
        // [GIVEN] A member born on 12 December 1991
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(12, 12, 1991), DMY2Date(13, 10, 2026));

        // [WHEN] The line is validated
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);

        // [THEN] No error is raised
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_TooOld_LT_Errors()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] A member older than the maximum age fails a "less than" constraint checked on the period start.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on against the period start, item requires an age less than 2 years
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::PERIODBEGIN_YMD, MembershipSalesSetup."Age Constraint Type"::LT, 2);
        // [GIVEN] A member born on 12 December 1991
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(12, 12, 1991), DMY2Date(13, 10, 2026));
        Commit();

        // [WHEN] The line is validated
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        WorkDate(OriginalWorkDate);

        // [THEN] The age requirement error is raised
        _Assert.ExpectedError('Member does not meet the age requirement for membership T-ECOM-AGE');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_YoungEnough_LT_Passes()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] A member younger than the maximum age passes a "less than" constraint checked on the period start.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on against the period start, item requires an age less than 2 years
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::PERIODBEGIN_YMD, MembershipSalesSetup."Age Constraint Type"::LT, 2);
        // [GIVEN] A member born on 12 December 2024
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(12, 12, 2024), DMY2Date(13, 10, 2026));

        // [WHEN] The line is validated
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);

        // [THEN] No error is raised
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_TooYoung_GT_Errors()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] A member younger than the minimum age fails a "greater than" constraint checked on the sales date.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on against the sales date, item requires an age greater than 2 years
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSalesSetup."Age Constraint Type"::GT, 2);
        // [GIVEN] A member born on 12 December 2024
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(12, 12, 2024), DMY2Date(13, 10, 2026));
        Commit();

        // [WHEN] The line is validated
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        WorkDate(OriginalWorkDate);

        // [THEN] The age requirement error is raised
        _Assert.ExpectedError('Member does not meet the age requirement for membership T-ECOM-AGE');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_AgeVerificationOff_NoBirthday_Passes()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] With age verification off, a missing birthday is accepted even when the item has an age constraint.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification off, item requires an age greater than 2 years
        SetAgeVerification(false, MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSalesSetup."Age Constraint Type"::GT, 2);
        // [GIVEN] A member without a birthday
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, 0D, DMY2Date(13, 10, 2026));

        // [WHEN] The line is validated
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);

        // [THEN] No error is raised
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_PeriodEndReference_UsesValidUntilDate()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] Age checked against the period end uses the membership's valid-until date.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on against the period end, item requires an age less than 2 years
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::PERIODEND_YMD, MembershipSalesSetup."Age Constraint Type"::LT, 2);
        // [GIVEN] A member born on 1 January 2025
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(1, 1, 2025), DMY2Date(13, 10, 2026));
        Commit();

        // [WHEN] The line is validated
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        WorkDate(OriginalWorkDate);

        // [THEN] The age requirement error is raised
        _Assert.ExpectedError('Member does not meet the age requirement for membership T-ECOM-AGE');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_AgeVerificationOn_NoBirthday_Errors()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] With age verification on, a missing birthday is rejected even when the item has no age constraint.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on, item has no age constraint
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSalesSetup."Age Constraint Type"::NA, 0);
        // [GIVEN] A member without a birthday
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, 0D, DMY2Date(13, 10, 2026));
        Commit();

        // [WHEN] The line is validated
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        WorkDate(OriginalWorkDate);

        // [THEN] The birthday required error is raised
        _Assert.ExpectedError('Member birthday is required for membership T-ECOM-AGE');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_NoActivationDate_UsesWorkDate()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] An order without an activation date is checked against the work date.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on against the sales date, item requires an age less than 5 years
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSalesSetup."Age Constraint Type"::LT, 5);
        // [GIVEN] A member born on 1 June 2017 and a line without an activation date
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(1, 6, 2017), 0D);

        // [WHEN] The line is validated
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);

        // [THEN] No error is raised, because the member is younger than 5 on the work date
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDirectCreation_ProcessedLine_SkipsAgeRecheck()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] A line whose membership is already issued is not re-checked for age on a later work date.
        Initialize();
        OriginalWorkDate := WorkDate();
        WorkDate(DMY2Date(1, 1, 2020));

        // [GIVEN] Age verification on against the sales date, item requires an age less than 18 years
        SetAgeVerification(true, MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSalesSetup."Age Constraint Type"::LT, 18);
        // [GIVEN] A member born on 2 January 2002, who is 17 on the work date
        CreateAgeCheckLine(EcomSalesHeader, EcomSalesLine, DMY2Date(2, 1, 2002), 0D);
        // [GIVEN] The line passes validation on the work date
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        Commit();

        // [GIVEN] One day later the member is 18, so an unprocessed line fails validation
        WorkDate(DMY2Date(2, 1, 2020));
        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        _Assert.ExpectedError('Member does not meet the age requirement for membership T-ECOM-AGE');

        // [GIVEN] The membership for the line is issued
        EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
        EcomSalesLine.Modify();

        // [WHEN] The line is validated again on the later work date
        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);

        // [THEN] No error is raised, because the age check is skipped for a processed line
        WorkDate(OriginalWorkDate);
    end;

    local procedure SetAgeVerification(Enable: Boolean; ValidateAgainst: Option SALESDATE_Y,PERIODBEGIN_Y,PERIODEND_Y,SALESDATE_YM,PERIODBEGIN_YM,PERIODEND_YM,SALESDATE_YMD,PERIODBEGIN_YMD,PERIODEND_YMD; ConstraintType: Option NA,LT,LTE,GT,GTE,E; Years: Integer)
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin
        MembershipSetup.Get('T-ECOM-AGE');
        MembershipSetup."Enable Age Verification" := Enable;
        MembershipSetup."Validate Age Against" := ValidateAgainst;
        MembershipSetup.Modify();

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, 'T-ECOM-AGE-ITEM');
        MembershipSalesSetup."Age Constraint Type" := ConstraintType;
        MembershipSalesSetup."Age Constraint (Years)" := Years;
        MembershipSalesSetup.Modify();
    end;

    local procedure CreateAgeCheckLine(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line"; Birthday: Date; ActivationDate: Date)
    begin
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCreateMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-ECOM-AGE-ITEM', 1, 100);
        EcomSalesLine."Membership Activation Date" := ActivationDate;
        EcomSalesLine."Member Birthday" := Birthday;
        EcomSalesLine.Modify();
    end;

    local procedure CreateCapturedPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; PaymentAmount: Decimal)
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := 10000;
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::"Payment Method";
        EcomSalesPmtLine.Amount := PaymentAmount;
        // Captured Amount deliberately equals Amount: ValidateImportedPaymentLines only validates a line whose
        // captured amount differs, so this keeps the fixture out of payment-method setup the test is not about.
        EcomSalesPmtLine."Captured Amount" := PaymentAmount;
        EcomSalesPmtLine.Insert(true);
    end;

    local procedure InsertMembershipLinkRow(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; Membership: Record "NPR MM Membership")
    var
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
    begin
        EcomSalesMembershipLink.Init();
        EcomSalesMembershipLink."Source System Id" := EcomSalesHeader.SystemId;
        EcomSalesMembershipLink."Source Line System Id" := EcomSalesLine.SystemId;
        EcomSalesMembershipLink."Membership System Id" := Membership.SystemId;
        EcomSalesMembershipLink.Insert();
    end;

    local procedure LastMembershipEntryValidUntil(Membership: Record "NPR MM Membership"): Date
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        _Assert.IsTrue(MembershipEntry.FindLast(), 'Membership must have at least one non-blocked, non-REGRET entry.');
        exit(MembershipEntry."Valid Until Date");
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_NewMember_GetsOrderLanguage()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] A member created from an ecom order gets the order language as its preferred language.
        Initialize();

        // [GIVEN] Member language 'ZZA' and an order in 'ZZA' that creates a new membership
        EnsureMemberLanguage('ZZA');
        CreateCreateMembershipOrder(EcomSalesHeader, EcomSalesLine, 'ZZA', NewUniqueEmail());
        Commit();

        // [GIVEN] The community has no default member language
        GetCommunity('T-ECOM', SavedCommunity);
        _Assert.AreEqual('', SavedCommunity.MemberDefaultLanguageCode, 'Precondition: the community default member language must be blank. An earlier test leaked it.');
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::NONE, SavedCommunity."Create Member UI Violation", '');

        // [WHEN] The membership line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        MemberLanguageCode := GetMemberLanguage(GetLineMemberEntryNo(EcomSalesLine));
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] The new member's preferred language is the order language
        _Assert.AreEqual('ZZA', MemberLanguageCode, 'The new member must get the order language.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_WithoutConfirm_NewMemberGetsOrderLanguage()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] Creating the membership sets the order language on the new member by itself, before any Confirm step runs.
        Initialize();

        // [GIVEN] Member language 'ZZA' and an order in 'ZZA' that creates a new membership
        EnsureMemberLanguage('ZZA');
        CreateCreateMembershipOrder(EcomSalesHeader, EcomSalesLine, 'ZZA', NewUniqueEmail());
        Commit();

        // [GIVEN] The community has no default member language
        GetCommunity('T-ECOM', SavedCommunity);
        _Assert.AreEqual('', SavedCommunity.MemberDefaultLanguageCode, 'Precondition: the community default member language must be blank. An earlier test leaked it.');
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::NONE, SavedCommunity."Create Member UI Violation", '');

        // [WHEN] Only CreateMembership runs, without ConfirmAllMembershipsForLine
        EcomCreateMMShipImpl.CreateMembership(EcomSalesLine, EcomSalesHeader);
        MemberLanguageCode := GetMemberLanguage(GetLineMemberEntryNo(EcomSalesLine));
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] The new member already has the order language
        _Assert.AreEqual('ZZA', MemberLanguageCode, 'CreateMembership must set the order language on the new member.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_ReusedMember_OrderLanguageOverwrites()
    var
        EcomSalesHeader1: Record "NPR Ecom Sales Header";
        EcomSalesLine1: Record "NPR Ecom Sales Line";
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberEmail: Text[80];
        FirstMemberEntryNo: Integer;
        SecondMemberEntryNo: Integer;
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] When a later order reuses an existing member, the later order's language replaces the member's language.
        Initialize();

        // [GIVEN] Two orders for the same member email: order 1 in 'ZZA', order 2 in 'ZZB'
        EnsureMemberLanguage('ZZA');
        EnsureMemberLanguage('ZZB');
        MemberEmail := NewUniqueEmail();
        CreateCreateMembershipOrder(EcomSalesHeader1, EcomSalesLine1, 'ZZA', MemberEmail);
        CreateCreateMembershipOrder(EcomSalesHeader2, EcomSalesLine2, 'ZZB', MemberEmail);
        Commit();

        // [GIVEN] The community reuses members by email and has no default member language
        GetCommunity('T-ECOM', SavedCommunity);
        _Assert.AreEqual('', SavedCommunity.MemberDefaultLanguageCode, 'Precondition: the community default member language must be blank. An earlier test leaked it.');
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::EMAIL, SavedCommunity."Create Member UI Violation"::REUSE, '');

        // [GIVEN] Order 1 creates the member
        EcomCreateMMShipImpl.Process(EcomSalesLine1);
        FirstMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine1);

        // [WHEN] Order 2 is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine2);
        SecondMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine2);
        MemberLanguageCode := GetMemberLanguage(FirstMemberEntryNo);
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] Order 2 reused the member and wrote its language
        _Assert.AreEqual(FirstMemberEntryNo, SecondMemberEntryNo, 'Order 2 must reuse the member created by order 1.');
        _Assert.AreEqual('ZZB', MemberLanguageCode, 'The reused member must get the language of the later order.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_ReusedMember_BlankOrderLanguageKeepsExisting()
    var
        EcomSalesHeader1: Record "NPR Ecom Sales Header";
        EcomSalesLine1: Record "NPR Ecom Sales Line";
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberEmail: Text[80];
        FirstMemberEntryNo: Integer;
        SecondMemberEntryNo: Integer;
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] An order without a language does not wipe the language of a reused member, and the community default does not replace it either.
        Initialize();

        // [GIVEN] Two orders without a language for the same member email
        EnsureMemberLanguage('ZZA');
        EnsureMemberLanguage('ZZC');
        MemberEmail := NewUniqueEmail();
        CreateCreateMembershipOrder(EcomSalesHeader1, EcomSalesLine1, '', MemberEmail);
        CreateCreateMembershipOrder(EcomSalesHeader2, EcomSalesLine2, '', MemberEmail);
        Commit();

        // [GIVEN] The community reuses members by email and has default member language 'ZZC'
        GetCommunity('T-ECOM', SavedCommunity);
        _Assert.AreEqual('', SavedCommunity.MemberDefaultLanguageCode, 'Precondition: the community default member language must be blank. An earlier test leaked it.');
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::EMAIL, SavedCommunity."Create Member UI Violation"::REUSE, 'ZZC');

        // [GIVEN] Order 1 creates the member, and the member's language is then set to 'ZZA'
        EcomCreateMMShipImpl.Process(EcomSalesLine1);
        FirstMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine1);
        _Assert.AreEqual('ZZC', GetMemberLanguage(FirstMemberEntryNo), 'A new member under REUSE must get the community default member language.');
        SetMemberLanguage(FirstMemberEntryNo, 'ZZA');

        // [WHEN] Order 2 is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine2);
        SecondMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine2);
        MemberLanguageCode := GetMemberLanguage(FirstMemberEntryNo);
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] Order 2 reused the member and kept its language
        _Assert.AreEqual(FirstMemberEntryNo, SecondMemberEntryNo, 'Order 2 must reuse the member created by order 1.');
        _Assert.AreEqual('ZZA', MemberLanguageCode, 'An order without a language must keep the reused member''s language, not wipe it or apply the community default.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_ReusedMember_UnknownOrderLanguageKeepsExisting()
    var
        EcomSalesHeader1: Record "NPR Ecom Sales Header";
        EcomSalesLine1: Record "NPR Ecom Sales Line";
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberEmail: Text[80];
        FirstMemberEntryNo: Integer;
        SecondMemberEntryNo: Integer;
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] An order language that is not set up as a member language is ignored, so a reused member keeps its language.
        Initialize();

        // [GIVEN] Language 'ZZX' exists but is not a member language
        EnsureMemberLanguage('ZZA');
        EnsureLanguage('ZZX');
        AssertNotMemberLanguage('ZZX');

        // [GIVEN] Order 1 without a language and order 2 in 'ZZX', for the same member email
        MemberEmail := NewUniqueEmail();
        CreateCreateMembershipOrder(EcomSalesHeader1, EcomSalesLine1, '', MemberEmail);
        CreateCreateMembershipOrder(EcomSalesHeader2, EcomSalesLine2, 'ZZX', MemberEmail);
        Commit();

        // [GIVEN] The community reuses members by email and has no default member language
        GetCommunity('T-ECOM', SavedCommunity);
        _Assert.AreEqual('', SavedCommunity.MemberDefaultLanguageCode, 'Precondition: the community default member language must be blank. An earlier test leaked it.');
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::EMAIL, SavedCommunity."Create Member UI Violation"::REUSE, '');

        // [GIVEN] Order 1 creates the member, and the member's language is then set to 'ZZA'
        EcomCreateMMShipImpl.Process(EcomSalesLine1);
        FirstMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine1);
        SetMemberLanguage(FirstMemberEntryNo, 'ZZA');

        // [WHEN] Order 2 is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine2);
        SecondMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine2);
        MemberLanguageCode := GetMemberLanguage(FirstMemberEntryNo);
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] Order 2 reused the member and kept its language
        _Assert.AreEqual(FirstMemberEntryNo, SecondMemberEntryNo, 'Order 2 must reuse the member created by order 1.');
        _Assert.AreEqual('ZZA', MemberLanguageCode, 'An order language that is not a member language must not change the reused member''s language.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewMembership_OrderLanguageDoesNotChangeMembers()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo: Integer;
        MemberEntryNoA: Integer;
        MemberEntryNoB: Integer;
        LanguageCodeA: Code[10];
        LanguageCodeB: Code[10];
        ValidUntilBefore: Date;
        ValidUntilAfter: Date;
        ResponseMessage: Text;
    begin
        // [SCENARIO] A renew order does not change member language, as on POS and in auto-renew.
        Initialize();

        // [GIVEN] A membership with active members A and B in 'ZZA'
        EnsureMemberLanguage('ZZA');
        EnsureMemberLanguage('ZZB');
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-ECOM-ITEM', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        MemberEntryNoA := CreateMemberWithLanguage('ZZA');
        LibraryMemberGDPR.AddMemberRole(Membership."Entry No.", MemberEntryNoA);
        MemberEntryNoB := CreateMemberWithLanguage('ZZA');
        LibraryMemberGDPR.AddMemberRole(Membership."Entry No.", MemberEntryNoB);

        // [GIVEN] A renew order in 'ZZB' for that membership
        AlterationSetup.SetRange("From Membership Code", 'T-ECOM');
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::RENEW);
        if not AlterationSetup.FindFirst() then
            Error('Renew alteration setup for T-ECOM not found — check Initialize().');

        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader."Language Code" := 'ZZB';
        EcomSalesHeader.Modify();
        CreateCapturedAlterationMembershipLine(EcomSalesLine, EcomSalesHeader, AlterationSetup."Sales Item No.", Membership, AlterationSetup.SystemId, EcomSalesLine."Membership Operation"::RenewMembership, 1, 100);
        ValidUntilBefore := LastMembershipEntryValidUntil(Membership);
        Commit();

        // [GIVEN] The community has no default member language
        GetCommunity('T-ECOM', SavedCommunity);
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity", SavedCommunity."Create Member UI Violation", '');

        // [WHEN] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        ValidUntilAfter := LastMembershipEntryValidUntil(Membership);
        LanguageCodeA := GetMemberLanguage(MemberEntryNoA);
        LanguageCodeB := GetMemberLanguage(MemberEntryNoB);
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] The renew ran
        _Assert.IsTrue(ValidUntilAfter > ValidUntilBefore, 'Membership Valid Until must advance after Renew.');

        // [THEN] Members A and B keep their language
        _Assert.AreEqual('ZZA', LanguageCodeA, 'A renew order must not change the language of member A.');
        _Assert.AreEqual('ZZA', LanguageCodeB, 'A renew order must not change the language of member B.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmMembership_DoesNotChangeMemberLanguage()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
        MemberLanguageCode: Code[10];
        ResponseMessage: Text;
    begin
        // [SCENARIO] Confirming a pre-created membership from an ecom order does not change the language of its existing member.
        // Confirm applies neither the order language nor the community default.
        Initialize();

        // [GIVEN] A membership pre-created via the membership API, with one active member in 'ZZA'
        EnsureMemberLanguage('ZZA');
        EnsureMemberLanguage('ZZB');
        EnsureMemberLanguage('ZZC');
        _Assert.IsTrue(_MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _MemberModuleLib.SetRandomMemberInfoData(MemberInfoCapture);
        MemberInfoCapture.PreferredLanguageCode := 'ZZA';
        _Assert.IsTrue(_MemberApiLib.AddMembershipMember(Membership, MemberInfoCapture, MemberEntryNo, ResponseMessage), ResponseMessage);
        _Assert.AreEqual('ZZA', GetMemberLanguage(MemberEntryNo), 'Precondition: the member must start in ''ZZA''.');

        // [GIVEN] An ecom order in 'ZZB' with a membership line carrying the membership token
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Language Code" := 'ZZB';
        EcomSalesHeader.Modify();
        _LibEcommerce.CreateCapturedMembershipLine(EcomSalesLine, EcomSalesHeader, 'T-320100', Membership);
        Commit();

        // [GIVEN] The community has default member language 'ZZC'
        SavedCommunity.Get(Membership."Community Code");
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity", SavedCommunity."Create Member UI Violation", 'ZZC');

        // [WHEN] The membership line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        MemberLanguageCode := GetMemberLanguage(MemberEntryNo);
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] The confirm ran
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        _Assert.AreEqual(EcomSalesHeader."External No.", MembershipEntry."Document No.", 'MembershipEntry."Document No." must match EcomSalesHeader."External No."');

        // [THEN] The member keeps 'ZZA'
        _Assert.AreEqual('ZZA', MemberLanguageCode, 'Confirming a membership must not change the language of its existing member.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_NewMember_NoOrderLanguage_GetsCommunityDefault()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] A new member from an order without a language gets the community default member language.
        Initialize();

        // [GIVEN] An order without a language that creates a new membership
        EnsureMemberLanguage('ZZC');
        CreateCreateMembershipOrder(EcomSalesHeader, EcomSalesLine, '', NewUniqueEmail());
        Commit();

        // [GIVEN] The community has default member language 'ZZC'
        GetCommunity('T-ECOM', SavedCommunity);
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::NONE, SavedCommunity."Create Member UI Violation", 'ZZC');

        // [WHEN] The membership line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        MemberLanguageCode := GetMemberLanguage(GetLineMemberEntryNo(EcomSalesLine));
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] The new member gets the community default
        _Assert.AreEqual('ZZC', MemberLanguageCode, 'A new member from an order without a language must get the community default member language.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_NewMember_UnknownOrderLanguage_GetsCommunityDefault()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] A new member from an order whose language is not a member language gets the community default member language.
        Initialize();

        // [GIVEN] Language 'ZZX' exists but is not a member language
        EnsureMemberLanguage('ZZC');
        EnsureLanguage('ZZX');
        AssertNotMemberLanguage('ZZX');

        // [GIVEN] An order in 'ZZX' that creates a new membership
        CreateCreateMembershipOrder(EcomSalesHeader, EcomSalesLine, 'ZZX', NewUniqueEmail());
        Commit();

        // [GIVEN] The community has default member language 'ZZC'
        GetCommunity('T-ECOM', SavedCommunity);
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::NONE, SavedCommunity."Create Member UI Violation", 'ZZC');

        // [WHEN] The membership line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        MemberLanguageCode := GetMemberLanguage(GetLineMemberEntryNo(EcomSalesLine));
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] The new member gets the community default
        _Assert.AreEqual('ZZC', MemberLanguageCode, 'A new member from an order with an unknown language must get the community default member language.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_NewMember_InvalidCommunityDefault_StaysBlank()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] A community default that is not a member language is not given to a new member.
        // Passes even without the fallback; it guards the MMLanguage.Get check in GetFallbackMemberLanguageCode.
        Initialize();

        // [GIVEN] Language 'ZZX' exists but is not a member language
        EnsureLanguage('ZZX');
        AssertNotMemberLanguage('ZZX');

        // [GIVEN] An order without a language that creates a new membership
        CreateCreateMembershipOrder(EcomSalesHeader, EcomSalesLine, '', NewUniqueEmail());
        Commit();

        // [GIVEN] The community has default member language 'ZZX'
        GetCommunity('T-ECOM', SavedCommunity);
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::NONE, SavedCommunity."Create Member UI Violation", 'ZZX');

        // [WHEN] The membership line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);
        MemberLanguageCode := GetMemberLanguage(GetLineMemberEntryNo(EcomSalesLine));
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] The new member has no language
        _Assert.AreEqual('', MemberLanguageCode, 'A community default that is not a member language must not be given to a new member.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership_ReusedMember_Merge_BlankOrderLanguageKeepsExisting()
    var
        EcomSalesHeader1: Record "NPR Ecom Sales Header";
        EcomSalesLine1: Record "NPR Ecom Sales Line";
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        SavedCommunity: Record "NPR MM Member Community";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberEmail: Text[80];
        FirstMemberEntryNo: Integer;
        SecondMemberEntryNo: Integer;
        MemberLanguageCode: Code[10];
    begin
        // [SCENARIO] Under MERGE_MEMBER, an order without a language keeps the conflicting member's language and does not apply the community default.
        // Guard only: it also passes before the preset member fix.
        Initialize();

        // [GIVEN] Two orders without a language for the same member email
        EnsureMemberLanguage('ZZA');
        EnsureMemberLanguage('ZZC');
        MemberEmail := NewUniqueEmail();
        CreateCreateMembershipOrder(EcomSalesHeader1, EcomSalesLine1, '', MemberEmail);
        CreateCreateMembershipOrder(EcomSalesHeader2, EcomSalesLine2, '', MemberEmail);
        Commit();

        // [GIVEN] The community merges members by email and has default member language 'ZZC'
        GetCommunity('T-ECOM', SavedCommunity);
        _Assert.AreEqual('', SavedCommunity.MemberDefaultLanguageCode, 'Precondition: the community default member language must be blank. An earlier test leaked it.');
        SetCommunity(SavedCommunity.Code, SavedCommunity."Member Unique Identity"::EMAIL, SavedCommunity."Create Member UI Violation"::MERGE_MEMBER, 'ZZC');

        // [GIVEN] Order 1 creates the member, and the member's language is then set to 'ZZA'
        EcomCreateMMShipImpl.Process(EcomSalesLine1);
        FirstMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine1);
        _Assert.AreEqual('ZZC', GetMemberLanguage(FirstMemberEntryNo), 'A new member under MERGE_MEMBER must get the community default member language.');
        SetMemberLanguage(FirstMemberEntryNo, 'ZZA');

        // [WHEN] Order 2 is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine2);
        SecondMemberEntryNo := GetLineMemberEntryNo(EcomSalesLine2);
        MemberLanguageCode := GetMemberLanguage(FirstMemberEntryNo);
        RestoreCommunity(SavedCommunity);
        Commit();

        // [THEN] Order 2 used the conflicting member and kept its language
        _Assert.AreEqual(FirstMemberEntryNo, SecondMemberEntryNo, 'Order 2 must use the member created by order 1.');
        _Assert.AreEqual('ZZA', MemberLanguageCode, 'An order without a language must keep the conflicting member''s language under MERGE_MEMBER, not wipe it or apply the community default.');
    end;

    local procedure EnsureLanguage(LanguageCode: Code[10])
    var
        Language: Record Language;
    begin
        if Language.Get(LanguageCode) then
            exit;
        Language.Init();
        Language.Code := LanguageCode;
        Language.Insert();
    end;

    local procedure EnsureMemberLanguage(LanguageCode: Code[10])
    var
        MMLanguage: Record "NPR MM Language";
    begin
        EnsureLanguage(LanguageCode);
        if MMLanguage.Get(LanguageCode) then
            exit;
        MMLanguage.Init();
        MMLanguage.LanguageCode := LanguageCode;
        MMLanguage.Insert();
    end;

    local procedure AssertNotMemberLanguage(LanguageCode: Code[10])
    var
        MMLanguage: Record "NPR MM Language";
    begin
        _Assert.IsFalse(MMLanguage.Get(LanguageCode), StrSubstNo('Precondition: ''%1'' must not be a member language.', LanguageCode));
    end;

    local procedure NewUniqueEmail() UniqueEmail: Text[80]
    begin
#pragma warning disable AA0139
        UniqueEmail := CopyStr(DelChr(Format(CreateGuid()), '=', '{}') + '@test.example.com', 1, MaxStrLen(UniqueEmail));
#pragma warning restore AA0139
    end;

    local procedure CreateCreateMembershipOrder(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line"; LanguageCode: Code[10]; MemberEmail: Text[80])
    begin
        _LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader."Language Code" := LanguageCode;
        EcomSalesHeader.Modify();

        _LibEcommerce.CreateCapturedMembershipLineNoToken(EcomSalesLine, EcomSalesHeader, 'T-ECOM-ITEM');
        EcomSalesLine."Member First Name" := 'Jane';
        EcomSalesLine."Member Last Name" := 'Doe';
#pragma warning disable AA0139
        EcomSalesLine."Member Email" := MemberEmail;
#pragma warning restore AA0139
        EcomSalesLine.Modify();
    end;

    local procedure CreateMemberWithLanguage(LanguageCode: Code[10]): Integer
    var
        Member: Record "NPR MM Member";
    begin
        Member.Init();
        Member."First Name" := 'Test';
        Member.PreferredLanguageCode := LanguageCode;
        Member.Insert(true);
        exit(Member."Entry No.");
    end;

    local procedure SetMemberLanguage(MemberEntryNo: Integer; LanguageCode: Code[10])
    var
        Member: Record "NPR MM Member";
    begin
        Member.Get(MemberEntryNo);
        Member.PreferredLanguageCode := LanguageCode;
        Member.Modify();
    end;

    local procedure GetMemberLanguage(MemberEntryNo: Integer): Code[10]
    var
        Member: Record "NPR MM Member";
    begin
        Member.Get(MemberEntryNo);
        exit(Member.PreferredLanguageCode);
    end;

    local procedure GetLineMemberEntryNo(EcomSalesLine: Record "NPR Ecom Sales Line"): Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
    begin
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        _Assert.IsTrue(Membership.GetBySystemId(EcomSalesLine."Membership Id"), 'The line must point at the created membership.');
        MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipRole.SetFilter("Member Entry No.", '<>%1', 0);
        _Assert.IsTrue(MembershipRole.FindFirst(), 'The created membership must have a member.');
        exit(MembershipRole."Member Entry No.");
    end;

    local procedure GetCommunity(MembershipCode: Code[20]; var Community: Record "NPR MM Member Community")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipSetup.Get(MembershipCode);
        Community.Get(MembershipSetup."Community Code");
    end;

    local procedure SetCommunity(CommunityCode: Code[20]; UniqueIdentity: Enum "NPR MM Member Unique Identity"; UIViolation: Option ERROR,CONFIRM,REUSE,MERGE_MEMBER; DefaultLanguageCode: Code[10])
    var
        Community: Record "NPR MM Member Community";
    begin
        Community.Get(CommunityCode);
        Community."Member Unique Identity" := UniqueIdentity;
        Community."Create Member UI Violation" := UIViolation;
        Community."Member Logon Credentials" := Community."Member Logon Credentials"::NA;
        Community.MemberDefaultLanguageCode := DefaultLanguageCode;
        Community.Modify();
    end;

    local procedure RestoreCommunity(SavedCommunity: Record "NPR MM Member Community")
    var
        Community: Record "NPR MM Member Community";
    begin
        Community.Get(SavedCommunity.Code);
        Community."Member Unique Identity" := SavedCommunity."Member Unique Identity";
        Community."Create Member UI Violation" := SavedCommunity."Create Member UI Violation";
        Community."Member Logon Credentials" := SavedCommunity."Member Logon Credentials";
        Community.MemberDefaultLanguageCode := SavedCommunity.MemberDefaultLanguageCode;
        Community.Modify();
    end;

}
#endif
