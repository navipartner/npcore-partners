#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85656 "NPR APIPOSSale AgeCheck"
{
    // [FEATURE] Age check on self-service sales: ageLimit on sale lines, ageCheck on the sale,
    // POST /pos/sale/:saleId/age-check, and enforcement at payment and completion.

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _CashPaymentMethod: Record "NPR POS Payment Method";
        _EFTPaymentMethod: Record "NPR POS Payment Method";
        _PlainItem: Record Item;
        _Item16: Record Item;
        _Item18: Record Item;
        _Salesperson: Record "Salesperson/Purchaser";
        _SalespersonPin: Code[20];
        _OtherPOSUnit: Record "NPR POS Unit";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestrictedLine_ReportsAgeLimitOnLineAndSale()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        ResponseBody: JsonObject;
        SaleId: Guid;
    begin
        // [SCENARIO] A line in a category with an age limit carries ageLimit, and the sale reports the limit as required and unapproved.
        Initialize();
        SaleId := CreateSale();

        Response := AddItemLine(SaleId, _Item18, CreateGuid());
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Add sale line should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.AreEqual(18, GetInteger(AgeCheckOf(ResponseBody), 'requiredLimit'), 'requiredLimit should be the line limit');
        Assert.AreEqual(0, GetInteger(AgeCheckOf(ResponseBody), 'approvedLimit'), 'approvedLimit should be 0 before approval');
        Assert.IsFalse(GetBoolean(AgeCheckOf(ResponseBody), 'approved'), 'approved should be false before approval');
        Assert.AreEqual(18, FirstLineAgeLimit(ResponseBody, 'refreshedSaleLines'), 'Refreshed line should carry ageLimit');

        ResponseBody := GetSale(SaleId);
        Assert.AreEqual(18, FirstLineAgeLimit(ResponseBody, 'saleLines'), 'Sale lines should carry ageLimit');
        Assert.AreEqual(18, GetInteger(AgeCheckOf(ResponseBody), 'requiredLimit'), 'GET sale should report requiredLimit');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnrestrictedSale_NeedsNoApproval_AndCompletes()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        ResponseBody: JsonObject;
        POSEntry: Record "NPR POS Entry";
        SaleId: Guid;
    begin
        // [SCENARIO] A sale without restricted items reports no required limit and pays and completes without an approval.
        Initialize();
        SaleId := CreateSale();

        Response := AddItemLine(SaleId, _PlainItem, CreateGuid());
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Add sale line should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.AreEqual(0, GetInteger(AgeCheckOf(ResponseBody), 'requiredLimit'), 'requiredLimit should be 0');
        Assert.IsTrue(GetBoolean(AgeCheckOf(ResponseBody), 'approved'), 'approved should be true when nothing is restricted');
        Assert.AreEqual(0, FirstLineAgeLimit(ResponseBody, 'refreshedSaleLines'), 'Unrestricted line should carry ageLimit 0');

        Response := PayCash(SaleId, _PlainItem."Unit Price");
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cash payment should succeed');

        Response := CompleteSale(SaleId);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete should succeed');

        FindPOSEntry(Response, POSEntry);
        Assert.AreEqual(POSEntry."Age Check Method"::None, POSEntry."Age Check Method", 'POS Entry should record no age check');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLine_WithoutApproval_ReturnsAgeCheckRequired()
    var
        Response: JsonObject;
        SaleId: Guid;
    begin
        // [SCENARIO] A payment on a restricted sale is refused with age_check_required until the check is approved.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := PayCash(SaleId, _Item18."Unit Price");
        AssertErrorResponse(Response, 400, 'age_check_required');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLine_EFTWithoutApproval_IsRecordedAndCompletionStillRefused()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSEntry: Record "NPR POS Entry";
        Response: JsonObject;
        SaleId: Guid;
        PspReference: Text;
    begin
        // [SCENARIO] A card result captured outside BC is stored even without an approval; the gate stays at completion.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());
        PspReference := CopyStr('PSP-' + UpperCase(FormatGuid(CreateGuid())), 1, 16);

        Response := PayEFT(SaleId, _Item18."Unit Price", PspReference);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'An EFT result must be recorded even when the age check is open');

        EFTTransactionRequest.SetRange("PSP Reference", PspReference);
        Assert.IsFalse(EFTTransactionRequest.IsEmpty(), 'The EFT transaction request should be stored');

        Response := CompleteSale(SaleId);
        AssertErrorResponse(Response, 400, 'age_check_required');

        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Approval should succeed after the card payment');

        Response := CompleteSale(SaleId);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete should succeed once the paid sale is approved');

        FindPOSEntry(Response, POSEntry);
        Assert.AreEqual(POSEntry."Age Check Method"::Staff, POSEntry."Age Check Method", 'POS Entry should record the staff method');
        Assert.AreEqual(18, POSEntry."Age Check Approved Limit", 'POS Entry should record the approved limit');
        Assert.AreEqual(_Salesperson.Code, POSEntry."Age Check Salesperson Code", 'POS Entry should record the approving salesperson');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApproveAgeCheck_WithValidPin_RecordsApprovalAndAllowsCompletion()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        ResponseBody: JsonObject;
        POSEntry: Record "NPR POS Entry";
        SaleId: Guid;
    begin
        // [SCENARIO] Staff approval with a valid PIN marks the sale approved, lets it pay and complete, and lands on the POS Entry.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Approval should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(GetBoolean(AgeCheckOf(ResponseBody), 'approved'), 'approved should be true after approval');
        Assert.AreEqual(18, GetInteger(AgeCheckOf(ResponseBody), 'approvedLimit'), 'approvedLimit should be the required limit');
        Assert.AreEqual(18, FirstLineAgeLimit(ResponseBody, 'saleLines'), 'Approval response should include the lines');

        Response := PayCash(SaleId, _Item18."Unit Price");
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cash payment should succeed after approval');

        Response := CompleteSale(SaleId);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete should succeed after approval');

        FindPOSEntry(Response, POSEntry);
        Assert.AreEqual(POSEntry."Age Check Method"::Staff, POSEntry."Age Check Method", 'POS Entry should record the staff method');
        Assert.AreEqual(18, POSEntry."Age Check Approved Limit", 'POS Entry should record the approved limit');
        Assert.AreEqual(_Salesperson.Code, POSEntry."Age Check Salesperson Code", 'POS Entry should record the approving salesperson');
        Assert.AreNotEqual(0DT, POSEntry."Age Check Approved At", 'POS Entry should record when the check was approved');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApproveAgeCheck_WithWrongPin_Returns403AndLeavesSaleUnapproved()
    var
        Assert: Codeunit Assert;
        Response: JsonObject;
        SaleId: Guid;
    begin
        // [SCENARIO] An unknown PIN is rejected with 403 age_check_rejected and the sale stays blocked.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'staff', 'NOPE' + UniquePin());
        AssertErrorResponse(Response, 403, 'age_check_rejected');

        Assert.IsFalse(GetBoolean(AgeCheckOf(GetSale(SaleId)), 'approved'), 'Sale should stay unapproved');

        Response := PayCash(SaleId, _Item18."Unit Price");
        AssertErrorResponse(Response, 400, 'age_check_required');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApproveAgeCheck_BlockedSalesperson_Returns403()
    var
        LibrarySales: Codeunit "Library - Sales";
        BlockedSalesperson: Record "Salesperson/Purchaser";
        Response: JsonObject;
        SaleId: Guid;
        BlockedPin: Code[20];
    begin
        // [SCENARIO] A blocked salesperson cannot approve an age check.
        Initialize();
        LibrarySales.CreateSalesperson(BlockedSalesperson);
        BlockedPin := UniquePin();
        BlockedSalesperson."NPR Register Password" := BlockedPin;
        BlockedSalesperson.Blocked := true;
        BlockedSalesperson.Modify();
        Commit();

        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'staff', BlockedPin);
        AssertErrorResponse(Response, 403, 'age_check_rejected');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApproveAgeCheck_UnsupportedMethod_Returns400()
    var
        Response: JsonObject;
        SaleId: Guid;
    begin
        // [SCENARIO] Only the staff method is supported in v1.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'altid', _SalespersonPin);
        AssertErrorResponse(Response, 400, 'generic_error');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HigherLimitLineAfterApproval_NeedsNewApproval()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        ResponseBody: JsonObject;
        SaleId: Guid;
    begin
        // [SCENARIO] An approval covers the limit at approval time; a line with a higher limit added later needs a new approval.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item16, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Approval should succeed');
        Assert.AreEqual(16, GetInteger(AgeCheckOf(LibraryNPRetailAPI.GetResponseBody(Response)), 'approvedLimit'), 'Approval should cover 16');

        Response := AddItemLine(SaleId, _Item18, CreateGuid());
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.AreEqual(18, GetInteger(AgeCheckOf(ResponseBody), 'requiredLimit'), 'requiredLimit should rise to 18');
        Assert.AreEqual(16, GetInteger(AgeCheckOf(ResponseBody), 'approvedLimit'), 'approvedLimit should stay at 16');
        Assert.IsFalse(GetBoolean(AgeCheckOf(ResponseBody), 'approved'), 'Sale should need a new approval');

        Response := PayCash(SaleId, _Item16."Unit Price" + _Item18."Unit Price");
        AssertErrorResponse(Response, 400, 'age_check_required');

        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Second approval should succeed');
        Assert.AreEqual(18, GetInteger(AgeCheckOf(LibraryNPRetailAPI.GetResponseBody(Response)), 'approvedLimit'), 'Second approval should cover 18');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RemovingHigherLimitLine_ExistingApprovalCoversRemainingLimit()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        LineId: Guid;
    begin
        // [SCENARIO] Removing the line with the highest limit lowers the required limit, and the recorded approval still covers what remains.
        Initialize();
        SaleId := CreateSale();
        LineId := CreateGuid();
        AddItemLine(SaleId, _Item18, LineId);
        AddItemLine(SaleId, _Item16, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Approval should succeed');
        Assert.AreEqual(18, GetInteger(AgeCheckOf(LibraryNPRetailAPI.GetResponseBody(Response)), 'approvedLimit'), 'Approval should cover 18');

        Response := LibraryNPRetailAPI.CallApi('DELETE', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(LineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Delete sale line should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.AreEqual(16, GetInteger(AgeCheckOf(ResponseBody), 'requiredLimit'), 'requiredLimit should drop to the remaining 16 line');
        Assert.AreEqual(18, GetInteger(AgeCheckOf(ResponseBody), 'approvedLimit'), 'approvedLimit should keep the recorded approval');
        Assert.IsTrue(GetBoolean(AgeCheckOf(ResponseBody), 'approved'), 'The approval for 18 should still satisfy the 16 line');

        Response := PayCash(SaleId, _Item16."Unit Price");
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cash payment should succeed on the still approved sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSale_DropsTheApproval()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        Response: JsonObject;
        ResponseBody: JsonObject;
        SaleId: Guid;
        ParkedSaleId: Guid;
        ResumedSaleId: Guid;
    begin
        // [SCENARIO] An approval does not survive park and resume, so a resumed sale has to be approved again.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());
        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Approval should succeed');

        ParkedSaleId := ParkSale(SaleId);
        Response := ResumeSale(ParkedSaleId);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Resume should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.AreEqual(18, GetInteger(AgeCheckOf(ResponseBody), 'requiredLimit'), 'The restricted line should still require a check');
        Assert.AreEqual(0, GetInteger(AgeCheckOf(ResponseBody), 'approvedLimit'), 'The approval should not come back with the parked sale');
        Assert.IsFalse(GetBoolean(AgeCheckOf(ResponseBody), 'approved'), 'A resumed sale should need a new approval');

        Evaluate(ResumedSaleId, GetText(ResponseBody, 'saleId'));
        POSSale.GetBySystemId(ResumedSaleId);
        Assert.AreEqual(POSSale."Age Check Method"::None, POSSale."Age Check Method", 'The method should be cleared on the resumed sale');
        Assert.AreEqual(0, POSSale."Age Check Approved Limit", 'The approved limit should be cleared on the resumed sale');
        Assert.AreEqual('', POSSale."Age Check Salesperson Code", 'The approver should be cleared on the resumed sale');
        Assert.AreEqual(0DT, POSSale."Age Check Approved At", 'The approval time should be cleared on the resumed sale');

        Response := PayCash(ResumedSaleId, _Item18."Unit Price");
        AssertErrorResponse(Response, 400, 'age_check_required');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_ApprovalCleared_ReturnsAgeCheckRequired()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        Response: JsonObject;
        SaleId: Guid;
    begin
        // [SCENARIO] Completion is refused when a paid restricted sale has no approval on record.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Approval should succeed');
        Response := PayCash(SaleId, _Item18."Unit Price");
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cash payment should succeed after approval');

        POSSale.GetBySystemId(SaleId);
        POSSale."Age Check Method" := POSSale."Age Check Method"::None;
        POSSale."Age Check Approved Limit" := 0;
        POSSale."Age Check Salesperson Code" := '';
        POSSale."Age Check Approved At" := 0DT;
        POSSale.Modify();
        Commit();

        Response := CompleteSale(SaleId);
        AssertErrorResponse(Response, 400, 'age_check_required');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApproveAgeCheck_SalespersonOutsideUnitGroup_Returns403()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        GroupedSalesperson: Record "Salesperson/Purchaser";
        POSUnitGroup: Record "NPR POS Unit Group";
        Response: JsonObject;
        SaleId: Guid;
        GroupedPin: Code[20];
    begin
        // [SCENARIO] A salesperson whose POS Unit Group excludes the kiosk cannot approve on it until the kiosk joins the group.
        Initialize();
        CreateSalespersonInUnitGroup(GroupedSalesperson, POSUnitGroup, _OtherPOSUnit."No.", GroupedPin);

        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := ApproveAgeCheck(SaleId, 'staff', GroupedPin);
        AssertErrorResponse(Response, 403, 'age_check_rejected');
        Assert.IsFalse(GetBoolean(AgeCheckOf(GetSale(SaleId)), 'approved'), 'Sale should stay unapproved');

        AddPOSUnitToGroup(POSUnitGroup."No.", _POSUnit."No.");

        Response := ApproveAgeCheck(SaleId, 'staff', GroupedPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'A salesperson whose group includes the kiosk should be able to approve');
        Assert.IsTrue(GetBoolean(AgeCheckOf(LibraryNPRetailAPI.GetResponseBody(Response)), 'approved'), 'Sale should be approved');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrepareEFT_WithoutApproval_ReturnsAgeCheckRequired()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        SaleId: Guid;
    begin
        // [SCENARIO] A card prepare on a restricted sale is refused without creating a transaction request, and succeeds once the check is approved.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := PrepareEFT(SaleId, _Item18."Unit Price");
        AssertErrorResponse(Response, 400, 'age_check_required');

        POSSale.GetBySystemId(SaleId);
        EFTTransactionRequest.SetRange("Register No.", POSSale."Register No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        Assert.IsTrue(EFTTransactionRequest.IsEmpty(), 'No EFT Transaction Request must exist for the sale after a refused prepare');

        Response := ApproveAgeCheck(SaleId, 'staff', _SalespersonPin);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Approval should succeed');

        Response := PrepareEFT(SaleId, _Item18."Unit Price");
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare should succeed after approval');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StartEFT_RestrictedLineAddedAfterPrepare_ReturnsAgeCheckRequired()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        SaleId: Guid;
        TransactionId: Text;
        TransactionGuid: Guid;
    begin
        // [SCENARIO] A restricted line added after prepare blocks start, and the transaction is not marked started.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _PlainItem, CreateGuid());

        Response := PrepareEFT(SaleId, _PlainItem."Unit Price");
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare should succeed on an unrestricted sale');
        TransactionId := GetText(LibraryNPRetailAPI.GetResponseBody(Response), 'transactionId');

        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := StartEFT(SaleId, TransactionId);
        AssertErrorResponse(Response, 400, 'age_check_required');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.AreEqual(0DT, EFTTransactionRequest.Started, 'The transaction must not be marked started when the age check blocks it');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BuildEFTRequest_RestrictedLineAddedAfterPrepare_ReturnsAgeCheckRequired()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        SaleId: Guid;
        TransactionId: Text;
        TransactionGuid: Guid;
    begin
        // [SCENARIO] A restricted line added after prepare blocks buildRequest, and the transaction is not marked started.
        Initialize();
        SaleId := CreateSale();
        AddItemLine(SaleId, _PlainItem, CreateGuid());

        Response := PrepareEFT(SaleId, _PlainItem."Unit Price");
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare should succeed on an unrestricted sale');
        TransactionId := GetText(LibraryNPRetailAPI.GetResponseBody(Response), 'transactionId');

        AddItemLine(SaleId, _Item18, CreateGuid());

        Response := BuildEFTRequest(SaleId, TransactionId);
        AssertErrorResponse(Response, 400, 'age_check_required');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.AreEqual(0DT, EFTTransactionRequest.Started, 'The transaction must not be marked started when the age check blocks it');
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibrarySales: Codeunit "Library - Sales";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        UserSetup: Record "User Setup";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');

        LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        LibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        LibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);
        _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
        _POSUnit.Modify();
        LibraryPOSMasterData.CreatePOSUnit(_OtherPOSUnit, _POSStore.Code, POSPostingProfile.Code);

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();

        LibraryPOSMasterData.CreateItemForPOSSaleUsage(_PlainItem, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item16, _POSUnit, _POSStore);
        AssignAgeLimitedCategory(_Item16, 16);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item18, _POSUnit, _POSStore);
        AssignAgeLimitedCategory(_Item18, 18);

        _CashPaymentMethod.SetRange("Processing Type", _CashPaymentMethod."Processing Type"::CASH);
        _CashPaymentMethod.FindFirst();
        LibraryPOSMasterData.CreatePOSPaymentMethod(_EFTPaymentMethod, _EFTPaymentMethod."Processing Type"::EFT, '', false);
        SetupSelfserviceCardPayment();

        LibrarySales.CreateSalesperson(_Salesperson);
        _SalespersonPin := UniquePin();
        _Salesperson."NPR Register Password" := _SalespersonPin;
        _Salesperson.Modify();

        CreateCleanupJobQueueEntry();

        _Initialized := true;
        Commit();
    end;

    local procedure SetupSelfserviceCardPayment()
    var
        SSProfile: Record "NPR SS Profile";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        SSProfile.Init();
        SSProfile.Code := 'AGECHECK';
        SSProfile.Description := 'Age Check API Test Profile';
        SSProfile."Selfservice Card Payment Meth." := _EFTPaymentMethod.Code;
        if not SSProfile.Insert() then
            SSProfile.Modify();

        _POSUnit."POS Self Service Profile" := SSProfile.Code;
        _POSUnit.Modify();

        if not EFTSetup.Get(_EFTPaymentMethod.Code, _POSUnit."No.") then begin
            EFTSetup.Init();
            EFTSetup."Payment Type POS" := _EFTPaymentMethod.Code;
            EFTSetup."POS Unit No." := _POSUnit."No.";
            EFTSetup.Insert();
        end;
        EFTSetup."EFT Integration Type" := EFTAdyenIntegration.CloudIntegrationType();
        EFTSetup.Modify();
    end;

    local procedure CreateSalespersonInUnitGroup(var Salesperson: Record "Salesperson/Purchaser"; var POSUnitGroup: Record "NPR POS Unit Group"; POSUnitNo: Code[10]; var Pin: Code[20])
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        POSUnitGroup.Init();
        POSUnitGroup."No." := CopyStr('AGE' + UniquePin(), 1, MaxStrLen(POSUnitGroup."No."));
        POSUnitGroup.Insert();
        AddPOSUnitToGroup(POSUnitGroup."No.", POSUnitNo);

        LibrarySales.CreateSalesperson(Salesperson);
        Pin := UniquePin();
        Salesperson."NPR Register Password" := Pin;
        Salesperson."NPR POS Unit Group" := POSUnitGroup."No.";
        Salesperson.Modify();
        Commit();
    end;

    local procedure AddPOSUnitToGroup(GroupNo: Code[20]; POSUnitNo: Code[10])
    var
        POSUnitGroupLine: Record "NPR POS Unit Group Line";
    begin
        POSUnitGroupLine.Init();
        POSUnitGroupLine."No." := GroupNo;
        POSUnitGroupLine."POS Unit" := POSUnitNo;
        POSUnitGroupLine.Insert();
        Commit();
    end;

    local procedure PrepareEFT(SaleId: Guid; Amount: Decimal) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('amount', Amount);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);
    end;

    local procedure StartEFT(SaleId: Guid; TransactionId: Text) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
    end;

    local procedure BuildEFTRequest(SaleId: Guid; TransactionId: Text) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/local/buildRequest', Body, QueryParams, Headers);
    end;

    local procedure AssignAgeLimitedCategory(var Item: Record Item; AgeLimit: Integer)
    var
        ItemCategory: Record "Item Category";
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
    begin
        NPRLibraryInventory.CreateItemCategory(ItemCategory);
        ItemCategory."NPR Age Limit" := AgeLimit;
        ItemCategory.Modify();
        Item."Item Category Code" := ItemCategory.Code;
        Item.Modify();
    end;

    local procedure UniquePin(): Code[20]
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        exit(Format(LibraryRandom.RandIntInRange(100000000, 999999999)));
    end;

    local procedure CreateSale() SaleId: Guid
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        SaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');
    end;

    local procedure AddItemLine(SaleId: Guid; Item: Record Item; LineId: Guid) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('type', 'Item');
        Body.Add('code', Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(LineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Add sale line should succeed');
    end;

    local procedure ApproveAgeCheck(SaleId: Guid; Method: Text; Credential: Text) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('method', Method);
        Body.Add('credential', Credential);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/age-check', Body, QueryParams, Headers);
    end;

    local procedure PayCash(SaleId: Guid; Amount: Decimal) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', Amount);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
    end;

    local procedure PayEFT(SaleId: Guid; Amount: Decimal; PspReference: Text) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', Amount);
        Body.Add('maskedCardNo', '************1234');
        Body.Add('pspReference', PspReference);
        Body.Add('success', true);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
    end;

    local procedure ParkSale(SaleId: Guid) ParkedSaleId: Guid
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/park', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Park should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Evaluate(ParkedSaleId, GetText(ResponseBody, 'saleId'));
    end;

    local procedure ResumeSale(ParkedSaleId: Guid) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ParkedSaleId) + '/resume', Body, QueryParams, Headers);
    end;

    local procedure CompleteSale(SaleId: Guid) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
    end;

    local procedure GetSale(SaleId: Guid) ResponseBody: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        QueryParams.Add('withLines', 'true');
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
    end;

    local procedure FindPOSEntry(CompleteResponse: JsonObject; var POSEntry: Record "NPR POS Entry")
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        ResponseBody: JsonObject;
    begin
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(CompleteResponse);
        POSEntry.SetRange("Document No.", GetText(ResponseBody, 'documentNo'));
        Assert.IsTrue(POSEntry.FindFirst(), 'POS Entry should be created');
    end;

    local procedure AssertErrorResponse(Response: JsonObject; ExpectedStatusCode: Integer; ExpectedCode: Text)
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        JToken: JsonToken;
    begin
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        Assert.AreEqual(ExpectedStatusCode, JToken.AsValue().AsInteger(), 'Unexpected status code');
        Assert.AreEqual(ExpectedCode, GetText(LibraryNPRetailAPI.GetResponseBody(Response), 'code'), 'Unexpected error code');
    end;

    local procedure AgeCheckOf(Body: JsonObject): JsonObject
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
    begin
        Assert.IsTrue(Body.Get('ageCheck', JToken), 'Response should contain ageCheck');
        exit(JToken.AsObject());
    end;

    local procedure FirstLineAgeLimit(Body: JsonObject; ArrayName: Text): Integer
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
        LineToken: JsonToken;
    begin
        Assert.IsTrue(Body.Get(ArrayName, JToken), StrSubstNo('Response should contain %1', ArrayName));
        Assert.IsTrue(JToken.AsArray().Get(0, LineToken), StrSubstNo('%1 should contain a line', ArrayName));
        exit(GetInteger(LineToken.AsObject(), 'ageLimit'));
    end;

    local procedure GetInteger(Body: JsonObject; PropertyName: Text): Integer
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
    begin
        Assert.IsTrue(Body.Get(PropertyName, JToken), StrSubstNo('Response should contain %1', PropertyName));
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure GetBoolean(Body: JsonObject; PropertyName: Text): Boolean
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
    begin
        Assert.IsTrue(Body.Get(PropertyName, JToken), StrSubstNo('Response should contain %1', PropertyName));
        exit(JToken.AsValue().AsBoolean());
    end;

    local procedure GetText(Body: JsonObject; PropertyName: Text): Text
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
    begin
        Assert.IsTrue(Body.Get(PropertyName, JToken), StrSubstNo('Response should contain %1', PropertyName));
        exit(JToken.AsValue().AsText());
    end;

    local procedure CreateCleanupJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR JQ Cleanup Dead POS Sales");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR JQ Cleanup Dead POS Sales";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(true);
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif
