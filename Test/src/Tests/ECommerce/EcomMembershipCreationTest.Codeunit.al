#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85166 "NPR EcomMembershipCreationTest"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _MemberModuleLib: Codeunit "NPR Library - Member Module";
        _LibEcommerce: Codeunit "NPR Library Ecommerce";

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
    procedure ValidateDirectCreation_QuantityNotOne_Errors()
    // Test: Import fails when quantity is not 1 on a direct-creation membership line.
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        UniqueEmail: Text;
    begin
        Initialize();
        UniqueEmail := DelChr(Format(CreateGuid()), '=', '{}') + '@test.example.com';

        // [When/Then] Import fails at validation — quantity must be 1
        asserterror _LibEcommerce.InsertEcomDocumentWithMemberData('TEST-QTY2', 'T-320100', 'Jane', 'Doe', UniqueEmail, 2, EcomSalesHeader);
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
    begin
        if _IsInitialized then
            exit;

        _MemberModuleLib.Initialize();
        _MemberModuleLib.CreateScenario_SmokeTest();

        // Create an INDIVIDUAL membership for direct-creation ecom tests (SmokeTest only creates GROUP memberships)
        MembershipSetup.Get('T-GOLD');
        _MemberModuleLib.SetupMembership_Simple(MembershipSetup."Community Code", 'T-ECOM', '', 'Ecom Individual Membership');
        MembershipSetup.Get('T-ECOM');
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup.Modify();

        _MemberModuleLib.CreateItem('T-ECOM-ITEM', '', 'Ecom Individual Membership Item', 100);
        _MemberModuleLib.SetupSimpleMembershipSalesItem('T-ECOM-ITEM', 'T-ECOM');

        _IsInitialized := true;
    end;
}
#endif
