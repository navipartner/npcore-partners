#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85160 "NPR Ecommerce Ticket Tests"
{
    Subtype = Test;

    // ---------------------------------------------------------------
    // CheckIfLineCanBeProcessed
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_NotCaptured_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
    begin
        // [Scenario] CheckIfLineCanBeProcessed raises error when ticket line is not captured
        LibTicket.CreateMinimalSetup();
        ItemNo := LibTicket.CreateItem('', LibTicket.CreateTicketType(LibTicket.GenerateCode10(), '<+7D>', 0, 0, "NPR TM ActivationMethod_Type"::SCAN, 0, 0), 100);

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 1, 100, false);

        asserterror EcomCreateTicketImpl.CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_WrongType_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        ItemNo: Code[20];
    begin
        // [Scenario] CheckIfLineCanBeProcessed raises error when line subtype is not Ticket
        ItemNo := CreateSmokeTicketItemNo();

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 1, 100, true);
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::" ";
        EcomSalesLine.Modify();

        asserterror EcomCreateTicketImpl.CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_ZeroQuantity_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        ItemNo: Code[20];
    begin
        // [Scenario] CheckIfLineCanBeProcessed raises error when quantity is 0
        ItemNo := CreateSmokeTicketItemNo();

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 0, 100, true);

        asserterror EcomCreateTicketImpl.CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_ReturnOrder_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        ItemNo: Code[20];
    begin
        // [Scenario] CheckIfLineCanBeProcessed raises error for Return Order document type
        ItemNo := CreateSmokeTicketItemNo();

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 1, 100, true);
        EcomSalesLine."Document Type" := EcomSalesLine."Document Type"::"Return Order";
        EcomSalesLine.Modify();

        asserterror EcomCreateTicketImpl.CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_AlreadyProcessed_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        ItemNo: Code[20];
    begin
        // [Scenario] CheckIfLineCanBeProcessed raises error when line is already processed
        ItemNo := CreateSmokeTicketItemNo();

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 1, 100, true);
        EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
        EcomSalesLine.Modify();

        asserterror EcomCreateTicketImpl.CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_HeaderAlreadyCreated_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        ItemNo: Code[20];
    begin
        // [Scenario] CheckIfLineCanBeProcessed raises error when sales document is already created
        ItemNo := CreateSmokeTicketItemNo();

        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader.Modify();

        _Lib.CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();

        asserterror EcomCreateTicketImpl.CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfLineCanBeProcessed_ZeroUnitPrice_Ok()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        ItemNo: Code[20];
    begin
        // [Scenario] CheckIfLineCanBeProcessed succeeds when unit price is 0 (free tickets are allowed)
        ItemNo := CreateSmokeTicketItemNo();

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 1, 0, true);

        EcomCreateTicketImpl.CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);
    end;

    // ---------------------------------------------------------------
    // ValidTicketRequest
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidTicketRequest_AdmissionWithScheduleEntry_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        Admission: Record "NPR TM Admission";
        AdmissionCode: Code[20];
        ItemNo: Code[20];
    begin
        // [Scenario] ValidTicketRequest raises error for admission requiring a specific schedule entry
        // Only NEXT_AVAILABLE, NONE, and TODAY are allowed for simple ecommerce ticket creation
        ItemNo := CreateSmokeTicketItemNo();
        AdmissionCode := _Lib.CreateAdmissionWithDefaultSchedule('ADM-SCH', Admission."Default Schedule"::SCHEDULE_ENTRY);
        _LibTicket.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 1, 100, false);

        asserterror EcomCreateTicketImpl.ValidTicketRequest(EcomSalesLine, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidTicketRequest_AdmissionWithCapacityControl_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        Admission: Record "NPR TM Admission";
        AdmissionCode: Code[20];
        ItemNo: Code[20];
    begin
        // [Scenario] ValidTicketRequest raises error for admission with capacity control set
        // Capacity control must be NONE for simple ecommerce ticket creation
        ItemNo := CreateSmokeTicketItemNo();
        AdmissionCode := _Lib.CreateAdmissionWithCapacityControl('ADM-CAP', Admission."Capacity Control"::SALES);
        _LibTicket.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);

        SetupEcomHeaderAndTicketLine(EcomSalesHeader, EcomSalesLine, ItemNo, 1, 100, false);

        asserterror EcomCreateTicketImpl.ValidTicketRequest(EcomSalesLine, EcomSalesHeader);
    end;

    // ---------------------------------------------------------------
    // ConfirmTickets
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmTickets_MissingProcessingToken_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        // [Scenario] ConfirmTickets raises error when processing token is empty
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        // Processing Token is empty by default

        asserterror EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmTickets_NoReservationsFound_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        // [Scenario] ConfirmTickets raises error when no ticket reservations exist for token
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Ticket Reservation Token" := EcomCreateTicketImpl.GenerateToken(EcomSalesHeader."Ticket Reservation Token");
        EcomSalesHeader.Modify();

        asserterror EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateTickets_CaptureNotProcessed_Skipped()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        // [Scenario] CreateTickets exits without processing when payment has not been captured yet.
        // The guard must prevent ticket creation: no processing token is generated
        // and the ticket processing status remains Pending.
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Tickets Exist" := true;
        EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::Pending;
        EcomSalesHeader.Modify();

        EcomVirtualItemMgt.CreateTickets(EcomSalesHeader, true, false);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        Assert.AreEqual('', EcomSalesHeader."Ticket Reservation Token", 'No processing token should be generated when capture is pending');
        Assert.AreEqual(EcomSalesHeader."Ticket Processing Status"::Pending, EcomSalesHeader."Ticket Processing Status", 'Ticket processing status should remain Pending when capture has not been processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateDocStatus_TicketError_ReturnsError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Result: Enum "NPR EcomVirtualItemDocStatus";
    begin
        // [Scenario] Status is Error when ticket processing failed
        EcomSalesHeader."Tickets Exist" := true;
        EcomSalesHeader."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Error;

        Result := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);

        Assert.AreEqual(Result::Error, Result, 'Expected Error status when ticket processing failed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateDocStatus_VoucherError_ReturnsError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Result: Enum "NPR EcomVirtualItemDocStatus";
    begin
        // [Scenario] Status is Error when voucher processing failed
        EcomSalesHeader."Vouchers Exist" := true;
        EcomSalesHeader."Voucher Processing Status" := EcomSalesHeader."Voucher Processing Status"::Error;

        Result := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);

        Assert.AreEqual(Result::Error, Result, 'Expected Error status when voucher processing failed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateDocStatus_BothProcessed_ReturnsProcessed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Result: Enum "NPR EcomVirtualItemDocStatus";
    begin
        // [Scenario] Status is Processed when both vouchers and tickets are fully processed
        EcomSalesHeader."Vouchers Exist" := true;
        EcomSalesHeader."Tickets Exist" := true;
        EcomSalesHeader."Voucher Processing Status" := EcomSalesHeader."Voucher Processing Status"::Processed;
        EcomSalesHeader."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Processed;

        Result := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);

        Assert.AreEqual(Result::Processed, Result, 'Expected Processed status when both are processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateDocStatus_OnlyTicketsProcessed_NoVouchers_ReturnsProcessed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Result: Enum "NPR EcomVirtualItemDocStatus";
    begin
        // [Scenario] Status is Processed when only tickets exist and they are processed
        EcomSalesHeader."Vouchers Exist" := false;
        EcomSalesHeader."Tickets Exist" := true;
        EcomSalesHeader."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Processed;

        Result := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);

        Assert.AreEqual(Result::Processed, Result, 'Expected Processed status when only tickets exist and are processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateDocStatus_VouchersPartiallyProcessed_ReturnsPartiallyProcessed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Result: Enum "NPR EcomVirtualItemDocStatus";
    begin
        // [Scenario] Status is PartiallyProcessed when vouchers are partially processed
        EcomSalesHeader."Vouchers Exist" := true;
        EcomSalesHeader."Tickets Exist" := false;
        EcomSalesHeader."Voucher Processing Status" := EcomSalesHeader."Voucher Processing Status"::"Partially Processed";

        Result := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);

        Assert.AreEqual(Result::"Partially Processed", Result, 'Expected Partially Processed status');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateDocStatus_VouchersProcessedTicketsPending_ReturnsPartiallyProcessed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Result: Enum "NPR EcomVirtualItemDocStatus";
    begin
        // [Scenario] Status is PartiallyProcessed when vouchers done but tickets still pending
        EcomSalesHeader."Vouchers Exist" := true;
        EcomSalesHeader."Tickets Exist" := true;
        EcomSalesHeader."Voucher Processing Status" := EcomSalesHeader."Voucher Processing Status"::Processed;
        EcomSalesHeader."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Pending;

        Result := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);

        Assert.AreEqual(Result::"Partially Processed", Result, 'Expected Partially Processed when tickets still pending');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateDocStatus_NeitherExist_ReturnsPending()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Result: Enum "NPR EcomVirtualItemDocStatus";
    begin
        // [Scenario] Status is Pending when no virtual items exist
        EcomSalesHeader."Vouchers Exist" := false;
        EcomSalesHeader."Tickets Exist" := false;

        Result := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader);

        Assert.AreEqual(Result::Pending, Result, 'Expected Pending status when no virtual items');
    end;

    // ---------------------------------------------------------------
    // ExpiryDate
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExpiryDate_AllLinesCaptured_SetTo10Years()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        MinExpiry: DateTime;
        MaxExpiry: DateTime;
    begin
        // [Scenario] When all ticket lines are captured, reservation expiry is set 10 years ahead
        // This long expiry signals the ticket is fully paid and no longer at risk of cancellation

        // [Given] EcomSalesHeader with a processing token
        CreateEcomHeaderWithToken(EcomSalesHeader);

        // [Given] One captured ticket line
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, CreateSmokeTicketItemNo());

        // [Given] A REGISTERED reservation request for the same token
        InsertTicketReservationRequest(TicketRequest, EcomSalesHeader."Ticket Reservation Token", EcomSalesHeader.SystemId);

        // [When] Update expiry based on captured status
        EcomCreateTicketImpl.UpdateExpiryTimeBasedOnCapturedStatus(EcomSalesHeader);

        // [Then] Expiry date is within the expected day window (10 years from today)
        TicketRequest.Get(TicketRequest."Entry No.");

        MinExpiry := CreateDateTime(CalcDate('<+10Y>', Today()), 000000T);
        MaxExpiry := CreateDateTime(CalcDate('<+10Y+1D>', Today()), 000000T);
        Assert.IsTrue((TicketRequest."Expires Date Time" >= MinExpiry) and (TicketRequest."Expires Date Time" < MaxExpiry), 'Expiry should be on the date ~10 years from today when all lines are captured');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExpiryDate_NotAllLinesCaptured_SetTo30Days()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        MinExpiry: DateTime;
        MaxExpiry: DateTime;
        ItemNo: Code[20];
    begin
        // [Scenario] When ticket lines are not yet captured, reservation expiry is set 30 days ahead
        // This shorter expiry allows the reservation to be cleaned up if payment never completes

        // [Given] EcomSalesHeader with a processing token
        CreateEcomHeaderWithToken(EcomSalesHeader);

        // [Given] One NOT captured ticket line
        _Lib.CreateTicketLine(EcomSalesLine, EcomSalesHeader, CreateSmokeTicketItemNo(), 1, 100);
        // Captured = false by default

        // [Given] A REGISTERED reservation request for the same token
        InsertTicketReservationRequest(TicketRequest, EcomSalesHeader."Ticket Reservation Token", EcomSalesHeader.SystemId);

        // [When] Update expiry based on captured status
        EcomCreateTicketImpl.UpdateExpiryTimeBasedOnCapturedStatus(EcomSalesHeader);

        // [Then] Expiry date is within the expected day window (30 days from today)
        TicketRequest.Get(TicketRequest."Entry No.");

        MinExpiry := CreateDateTime(CalcDate('<+30D>', Today()), 000000T);
        MaxExpiry := CreateDateTime(CalcDate('<+30D+1D>', Today()), 000000T);

        Assert.IsTrue((TicketRequest."Expires Date Time" >= MinExpiry) and (TicketRequest."Expires Date Time" < MaxExpiry), 'Expiry should be on the date ~30 days from today when lines are not yet captured');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExpiryDate_MixedCapturedLines_SetTo30Days()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        MinExpiry: DateTime;
        MaxExpiry: DateTime;
        ItemNo: Code[20];
    begin
        // [Scenario] When some ticket lines are captured and some are not,
        // expiry is still 30 days (not all captured = short expiry)

        // [Given] EcomSalesHeader with a processing token
        CreateEcomHeaderWithToken(EcomSalesHeader);

        // [Given] One captured and one not-captured ticket line
        ItemNo := CreateSmokeTicketItemNo();
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo);
        _Lib.CreateTicketLine(EcomSalesLine2, EcomSalesHeader, ItemNo, 1, 50);

        // [Given] A REGISTERED reservation request for the same token
        InsertTicketReservationRequest(TicketRequest, EcomSalesHeader."Ticket Reservation Token", EcomSalesHeader.SystemId);

        // [When] Update expiry based on captured status
        EcomCreateTicketImpl.UpdateExpiryTimeBasedOnCapturedStatus(EcomSalesHeader);

        // [Then] Expiry date is within the expected day window (30 days from today)
        TicketRequest.Get(TicketRequest."Entry No.");

        MinExpiry := CreateDateTime(CalcDate('<+30D>', Today()), 000000T);
        MaxExpiry := CreateDateTime(CalcDate('<+30D+1D>', Today()), 000000T);
        Assert.IsTrue((TicketRequest."Expires Date Time" >= MinExpiry) and (TicketRequest."Expires Date Time" < MaxExpiry), 'Expiry should be on the date ~30 days from today when not all lines are captured');
    end;

    // ---------------------------------------------------------------
    // Integration: Ecommerce ticket flow paired with ticket module validation
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomTicketFlow_CreateAndConfirm_TicketValidForArrival()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Ticket: Record "NPR TM Ticket";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ScannerStation: Code[10];
        AdmissionCode: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // [Scenario] Tickets created via the ecommerce fast lane flow are valid for arrival
        SetupAndConfirmEcomTicketOrder(EcomSalesHeader, Ticket, AdmissionCode);

        ScannerStation := 'TEST';
        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomTicketFlow_DoubleArrival_SecondArrivalFails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Ticket: Record "NPR TM Ticket";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ScannerStation: Code[10];
        AdmissionCode: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // [Scenario] A ticket created via the ecommerce flow can be scanned for arrival exactly once.
        // A second arrival scan is rejected because the ticket type uses SINGLE entry validation.

        SetupAndConfirmEcomTicketOrder(EcomSalesHeader, Ticket, AdmissionCode);

        ScannerStation := 'TEST';

        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, 'First arrival scan should succeed: ' + ResponseMessage);

        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Second arrival scan should be rejected for a SINGLE-validation ticket');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomTicketFlow_ArrivalAndDeparture_DepartureLogged()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Ticket: Record "NPR TM Ticket";
        DetailedTicketEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ScannerStation: Code[10];
        AdmissionCode: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // [Scenario] After arrival, a departure scan on a ticket created via the ecommerce flow
        // is accepted and logs a DEPARTED detailed access entry.

        SetupAndConfirmEcomTicketOrder(EcomSalesHeader, Ticket, AdmissionCode);

        ScannerStation := 'TEST';

        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, 'Arrival should succeed before testing departure: ' + ResponseMessage);

        ApiOk := TicketApiLibrary.ValidateTicketDeparture(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);

        Assert.IsTrue(ApiOk, 'Departure scan should succeed: ' + ResponseMessage);
        DetailedTicketEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetailedTicketEntry.SetFilter(Type, '=%1', DetailedTicketEntry.Type::DEPARTED);
        Assert.IsFalse(DetailedTicketEntry.IsEmpty(), 'A DEPARTED detailed access entry should exist after departure scan');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomTicketFlow_MultipleLines_AllTicketsConfirmed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
        ConfirmedRequestCount: Integer;
        TotalTicketCount: Integer;
    begin
        // [Scenario] An ecommerce order with two captured ticket lines results in two separate
        // ticket reservation requests, both confirmed, producing two usable tickets.

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo);
        _Lib.CreateCapturedTicketLine(EcomSalesLine2, EcomSalesHeader, ItemNo);

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);

        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::Confirmed);
        ConfirmedRequestCount := TicketRequest.Count();
        Assert.AreEqual(2, ConfirmedRequestCount, 'Both reservation requests should be in Confirmed status');

        if TicketRequest.FindSet() then
            repeat
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
                TotalTicketCount += Ticket.Count();
            until TicketRequest.Next() = 0;

        Assert.AreEqual(2, TotalTicketCount, 'One ticket should have been created per confirmed reservation request');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomTicketFlow_ZeroUnitPrice_TicketConfirmed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Item: Record Item;
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        EcomCreateTicketTryProcess: Codeunit "NPR EcomCreateTicketTryProcess";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
    begin
        // [Scenario] A captured ticket line with Unit Price = 0 (free ticket) goes through the full
        // ecommerce fast lane flow and ends up with a Confirmed reservation request,
        // and the resulting ticket amount is 0 even though the underlying item still has a non-zero price.

        // [Given] A smoke-test ticket item (item Unit Price is non-zero) and an ecom header
        ItemNo := LibTicket.CreateScenario_SmokeTest();
        Item.Get(ItemNo);
        Assert.AreNotEqual(0, Item."Unit Price", 'Precondition: smoke-test item should have a non-zero Unit Price');

        _Lib.CreateEcomSalesHeader(EcomSalesHeader);

        // [Given] A captured ticket line with Unit Price = 0
        _Lib.CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 0);
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();

        // [When] The fast lane flow creates reservation requests and confirms the tickets
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        EcomCreateTicketTryProcess.Run(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        // [Then] The reservation request for this token is in Confirmed status
        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.FindFirst();
        Assert.AreEqual(TicketRequest."Request Status"::Confirmed, TicketRequest."Request Status", 'Reservation request for a 0-price ticket line should be Confirmed at the end of the flow');

        // [Then] The created ticket carries a 0 amount, while the item price is unchanged (non-zero)
        Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
        Ticket.FindFirst();
        Assert.AreEqual(0, Ticket.AmountInclVat, 'Ticket AmountInclVat should be 0 because the ecom line was captured at Unit Price = 0');
        Assert.AreEqual(0, Ticket.AmountExclVat, 'Ticket AmountExclVat should be 0 because the ecom line was captured at Unit Price = 0');
    end;

    // ---------------------------------------------------------------
    // Ticket price update after ConfirmTickets
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmTickets_PricesExclVat_TicketAmountsSetCorrectly()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
        ExpectedAmountExclVat: Decimal;
        ExpectedAmountInclVat: Decimal;
    begin
        // [Scenario] When Price Excl. VAT is true, ConfirmTickets sets ticket AmountExclVat
        // from line amount / quantity and calculates AmountInclVat by applying VAT %.

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Price Excl. VAT" := true;
        EcomSalesHeader.Modify();

        _Lib.CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, 2, 100);
        EcomSalesLine."VAT %" := 25;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();

        ExpectedAmountExclVat := 100;
        ExpectedAmountInclVat := 125;

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);

        TicketRequest.SetRange("Session Token ID", EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetRange("Request Status", TicketRequest."Request Status"::Confirmed);
        TicketRequest.FindFirst();

        Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
        Ticket.FindSet();
        repeat
            Assert.AreEqual(ExpectedAmountExclVat, Ticket.AmountExclVat, 'AmountExclVat should be line amount / quantity');
            Assert.AreEqual(ExpectedAmountInclVat, Ticket.AmountInclVat, 'AmountInclVat should be AmountExclVat * (1 + VAT%)');
        until Ticket.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmTickets_PricesInclVat_TicketAmountsSetCorrectly()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
        ExpectedAmountExclVat: Decimal;
        ExpectedAmountInclVat: Decimal;
    begin
        // [Scenario] When Price Excl. VAT is false, ConfirmTickets sets ticket AmountInclVat
        // from line amount / quantity and calculates AmountExclVat by removing VAT %.

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Price Excl. VAT" := false;
        EcomSalesHeader.Modify();

        _Lib.CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, 2, 125);
        EcomSalesLine."VAT %" := 25;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();

        // LineAmount = 250, Qty = 2 ; per ticket: InclVat = 125, ExclVat = 100
        ExpectedAmountInclVat := 125;
        ExpectedAmountExclVat := 100;

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);

        TicketRequest.SetRange("Session Token ID", EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetRange("Request Status", TicketRequest."Request Status"::Confirmed);
        TicketRequest.FindFirst();

        Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
        Ticket.FindSet();
        repeat
            Assert.AreEqual(ExpectedAmountInclVat, Ticket.AmountInclVat, 'AmountInclVat should be line amount / quantity');
            Assert.AreEqual(ExpectedAmountExclVat, Ticket.AmountExclVat, 'AmountExclVat should be AmountInclVat / (1 + VAT%)');
        until Ticket.Next() = 0;
    end;

    // ---------------------------------------------------------------
    // Pre-made reservation: token created via Ticket API and sent with the ecom order
    // ValidateAndUpdateRequestsWithEcommerceDocNo
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreMadeReservation_ValidToken_ExpiryUpdatedAndConfirmSucceeds()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        ResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
        ItemNo: Code[20];
        ExpiryBeforeCapture: DateTime;
    begin
        // [Scenario] Customer reserves a ticket via the Ticket API before placing the ecom order.
        // The reservation token is sent in the ecom order JSON payload and validated by the
        // full ecom document insertion pipeline. After capture, expiry is extended and
        // ConfirmTickets produces a valid ticket.

        ScannerStation := 'TEST';

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'MakeReservation should succeed: ' + ResponseMessage);

        _Lib.InsertEcomDocumentWithReservationToken('PREMADE-VALID', ResponseToken, ItemNo, true, EcomSalesHeader);

        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::REGISTERED);
        Assert.IsFalse(TicketRequest.IsEmpty(), 'Reservation should remain in REGISTERED status after document insertion');
        TicketRequest.FindFirst();
        ExpiryBeforeCapture := TicketRequest."Expires Date Time";

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();

        EcomCreateTicketImpl.UpdateExpiryTimeBasedOnCapturedStatus(EcomSalesHeader);

        TicketRequest.Get(TicketRequest."Entry No.");
        Assert.IsTrue(TicketRequest."Expires Date Time" > ExpiryBeforeCapture, 'Expiry should be extended after capture');

        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);

        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::Confirmed);
        Assert.IsFalse(TicketRequest.IsEmpty(), 'Reservation should be Confirmed');
        TicketRequest.FindFirst();

        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        Ticket.FindFirst();

        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", TicketRequest."Admission Code", ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreMadeReservation_TokenNotFound_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        FakeToken: Text[100];
        ItemNo: Code[20];
    begin
        // [Scenario] The ecom document insertion pipeline errors when the reservation token
        // in the payload does not match any existing ticket reservation.

        FakeToken := EcomCreateTicketImpl.GenerateToken('');
        asserterror _Lib.InsertEcomDocumentWithReservationToken('PREMADE-NOTFOUND', FakeToken, CreateSmokeTicketItemNo(), false, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreMadeReservation_MissingLineId_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        ResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
        ItemNo: Code[20];
    begin
        // [Scenario] The ecom document insertion pipeline errors when ticketReservationToken is set in the
        // header but ticketReservationLineId is missing on the sales line.

        ScannerStation := 'TEST';
        ItemNo := LibTicket.CreateScenario_SmokeTest();
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'MakeReservation should succeed: ' + ResponseMessage);

        asserterror _Lib.InsertEcomDocumentWithReservationToken('PREMADE-NOLINEID', ResponseToken, ItemNo, false, EcomSalesHeader);
        Assert.ExpectedError('ticketReservationLineId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreMadeReservation_AlreadyConfirmedSameDoc_Succeeds()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        ResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
        ItemNo: Code[20];
    begin
        // [Scenario] Reservation was already confirmed via the Ticket API with the same external
        // document number that the ecom order carries. Re-submitting the same token is idempotent
        // and must NOT error — the document insertion pipeline accepts it.

        ScannerStation := 'TEST';

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'MakeReservation should succeed: ' + ResponseMessage);

        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', 'PRE-CONF-SAME', ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, 'ConfirmTicketReservation should succeed: ' + ResponseMessage);

        _Lib.InsertEcomDocumentWithReservationToken('PRE-CONF-SAME', ResponseToken, ItemNo, true, EcomSalesHeader);

        Assert.AreNotEqual(0, EcomSalesHeader."Entry No.", 'Ecom document have been inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreMadeReservation_AlreadyConfirmedDifferentDoc_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        ResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
        ItemNo: Code[20];
    begin
        // [Scenario] Reservation was already confirmed via the Ticket API for a DIFFERENT external
        // document number. Submitting this token in a new ecom order must error because the
        // reservation belongs to another order.

        ScannerStation := 'TEST';

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'MakeReservation should succeed: ' + ResponseMessage);

        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', 'OTHER-DOC', ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, 'ConfirmTicketReservation should succeed: ' + ResponseMessage);

        asserterror _Lib.InsertEcomDocumentWithReservationToken('PRE-CONF-DIFF', ResponseToken, ItemNo, true, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreMadeReservation_CancelledToken_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        ResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
        ItemNo: Code[20];
    begin
        // [Scenario] Customer reserves via Ticket API but the reservation is cancelled
        // (e.g. timeout or abandoned checkout) before the ecom order is submitted.
        // Submitting the cancelled token in the ecom document payload must error.

        ScannerStation := 'TEST';

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'MakeReservation should succeed: ' + ResponseMessage);

        ApiOk := TicketApiLibrary.CancelTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, 'CancelTicketReservation should succeed: ' + ResponseMessage);

        asserterror _Lib.InsertEcomDocumentWithReservationToken('PREMADE-CANCELLED', ResponseToken, ItemNo, true, EcomSalesHeader);
    end;

    // ---------------------------------------------------------------
    // Ecommerce direct (no reservation) - with explicit admission code
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_WithAdmCode_TicketValidForArrival()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Ticket: Record "NPR TM Ticket";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ScannerStation: Code[10];
        AdmissionCode: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // [Scenario] When an admission code is explicitly set on the ecommerce line,
        // the created ticket is for that specific admission and is valid for arrival.

        SetupAndConfirmEcomTicketOrderWithAdmCode(EcomSalesHeader, Ticket, AdmissionCode);

        ScannerStation := 'TEST';
        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_WithAdmCode_DoubleArrivalFails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Ticket: Record "NPR TM Ticket";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ScannerStation: Code[10];
        AdmissionCode: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // [Scenario] A ticket created with an explicit admission code uses SINGLE
        // entry validation: a second arrival scan on the same ticket is rejected.

        SetupAndConfirmEcomTicketOrderWithAdmCode(EcomSalesHeader, Ticket, AdmissionCode);

        ScannerStation := 'TEST';

        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, 'First arrival scan should succeed: ' + ResponseMessage);

        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Second arrival scan should be rejected (SINGLE validation)');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_WithAdmCode_ArrivalAndDeparture()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Ticket: Record "NPR TM Ticket";
        DetailedTicketEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ScannerStation: Code[10];
        AdmissionCode: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // [Scenario] A ticket created with an explicit admission code supports
        // a full arrival → departure cycle, logging a DEPARTED access entry.

        SetupAndConfirmEcomTicketOrderWithAdmCode(EcomSalesHeader, Ticket, AdmissionCode);

        ScannerStation := 'TEST';

        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, 'Arrival should succeed before testing departure: ' + ResponseMessage);

        ApiOk := TicketApiLibrary.ValidateTicketDeparture(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, 'Departure scan should succeed: ' + ResponseMessage);

        DetailedTicketEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetailedTicketEntry.SetFilter(Type, '=%1', DetailedTicketEntry.Type::DEPARTED);
        Assert.IsFalse(DetailedTicketEntry.IsEmpty(), 'A DEPARTED detailed access entry should exist after departure scan');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_ApiInsert_PosActivationOnBOM_CreateRequestsFails()
    var
        Admission: Record "NPR TM Admission";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        ItemNo: Code[20];
        AdmCode: Code[20];
    begin
        // [Scenario] The BOM entry linking the item to the admission has Activation Method = POS.
        // Tickets with POS-only activation cannot be admitted via scan.
        // Document insertion via the API must fail.

        ItemNo := _LibTicket.CreateScenario_SmokeTest();
        AdmCode := _Lib.CreateAdmissionWithDefaultSchedule('API-POS-ADM', Admission."Default Schedule"::TODAY);
        _LibTicket.CreateTicketBOM(ItemNo, '', AdmCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::POS, TicketBOM."Admission Entry Validation"::SINGLE);

        asserterror _Lib.InsertEcomDocument('POS-ACT', ItemNo, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_TodayAdmNoOpenSchedule_ValidTicketRequestFails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        ItemNo: Code[20];
        AdmCode: Code[20];
    begin
        // [Scenario] The admission has Default Schedule = TODAY but has no open schedule entry
        // for today. Tickets for this admission cannot be scanned and are therefore useless.
        // ValidTicketRequest must reject this.

        ItemNo := _LibTicket.CreateScenario_SmokeTest();
        AdmCode := _Lib.CreateAdmissionWithDefaultSchedule('NOSCH-TODAY', Admission."Default Schedule"::TODAY);
        _LibTicket.CreateTicketBOM(ItemNo, '', AdmCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);

        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo);

        asserterror EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_NextAvailAdmNoOpenSchedule_ValidTicketRequestFails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        ItemNo: Code[20];
        AdmCode: Code[20];
    begin
        // [Scenario] The admission has Default Schedule = NEXT_AVAILABLE but has no open
        // schedule entries at all. There is no slot the ticket could ever be used in.
        // ValidTicketRequest must reject this.

        ItemNo := _LibTicket.CreateScenario_SmokeTest();
        AdmCode := _Lib.CreateAdmissionWithDefaultSchedule('NOSCH-NEXT', Admission."Default Schedule"::NEXT_AVAILABLE);
        _LibTicket.CreateTicketBOM(ItemNo, '', AdmCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo);

        asserterror EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_ApiInsert_TodayAdmNoOpenSchedule_CreateRequestsFails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        ItemNo: Code[20];
        AdmCode: Code[20];
    begin
        // [Scenario] The item's default admission has Default Schedule = TODAY but no open
        // schedule entry for today. Document insertion via the API must fail.

        ItemNo := _LibTicket.CreateScenario_SmokeTest();
        AdmCode := _Lib.CreateAdmissionWithDefaultSchedule('API-SCH-TODAY', Admission."Default Schedule"::TODAY);

        _LibTicket.CreateTicketBOM(ItemNo, '', AdmCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);

        asserterror _Lib.InsertEcomDocument('API-SCH-T', ItemNo, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_ApiInsert_NextAvailAdmNoOpenSchedule_CreateRequestsFails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        ItemNo: Code[20];
        AdmCode: Code[20];
    begin
        // [Scenario] The item's default admission has Default Schedule = NEXT_AVAILABLE but no
        // open schedule entries. Document insertion via the API must fail.
        ItemNo := _LibTicket.CreateScenario_SmokeTest();
        AdmCode := _Lib.CreateAdmissionWithDefaultSchedule('API-SCH-NEXT', Admission."Default Schedule"::NEXT_AVAILABLE);
        _LibTicket.CreateTicketBOM(ItemNo, '', AdmCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);

        asserterror _Lib.InsertEcomDocument('API-SCH-N', ItemNo, EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_ApiInsert_AdmWithDependency_CreateRequestsFails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        ItemNo: Code[20];
        AdmCode: Code[20];
    begin
        // [Scenario] The item's default admission has a Dependency Code, which is not supported
        // for ecommerce tickets. Document insertion via the API must fail.

        ItemNo := _LibTicket.CreateScenario_SmokeTest();
        AdmCode := _Lib.CreateAdmissionWithDefaultSchedule('API-DEP-ADM', Admission."Default Schedule"::NONE);

        Admission.Get(AdmCode);
        Admission."Dependency Code" := 'ANY-DEP';
        Admission.Modify();

        _LibTicket.CreateTicketBOM(ItemNo, '', AdmCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);
        asserterror _Lib.InsertEcomDocument('API-DEP-TEST', ItemNo, EcomSalesHeader);
    end;

    // ---------------------------------------------------------------
    // Ecommerce direct (no reservation) - without admission code (auto-detect from BOM)
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_NoAdmCode_TicketValidForArrival()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Ticket: Record "NPR TM Ticket";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ScannerStation: Code[10];
        AdmissionCode: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // [Scenario] The system auto-assigns the default admission from the item BOM and the resulting ticket
        // is valid for arrival — the full flow without any explicit admission code.

        SetupAndConfirmEcomTicketOrder(EcomSalesHeader, Ticket, AdmissionCode);

        ScannerStation := 'TEST';
        ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EcomDirect_CreateRequests_CalledTwice_NoDuplicateRequests()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
        TokenBeforeSecondCall: Text[100];
    begin
        // [Scenario] Calling CreateRequestsForTicketLines twice on the same ecom header
        // is idempotent: the second call exits early because the Processing Token is already
        // set, and no duplicate reservation requests are created.

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo);

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");

        TokenBeforeSecondCall := EcomSalesHeader."Ticket Reservation Token";

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");

        Assert.AreEqual(TokenBeforeSecondCall, EcomSalesHeader."Ticket Reservation Token", 'Processing Token must remain unchanged on repeated CreateRequestsForTicketLines call');

        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        Assert.AreEqual(1, TicketRequest.Count(), 'Calling CreateRequestsForTicketLines twice must not create duplicate reservation requests');
    end;

    local procedure SetupAndConfirmEcomTicketOrderWithAdmCode(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var FirstTicket: Record "NPR TM Ticket"; var AdmissionCode: Code[20])
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
    begin
        ItemNo := LibTicket.CreateScenario_SmokeTest();

        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo);

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");

        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);

        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::Confirmed);
        TicketRequest.FindFirst();
        AdmissionCode := TicketRequest."Admission Code";

        FirstTicket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        FirstTicket.FindFirst();
    end;

    local procedure SetupAndConfirmEcomTicketOrder(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var FirstTicket: Record "NPR TM Ticket"; var AdmissionCode: Code[20])
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
    begin
        ItemNo := LibTicket.CreateScenario_SmokeTest();

        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo);

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");

        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);

        TicketRequest.SetFilter("Session Token ID", '=%1', EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::Confirmed);
        TicketRequest.FindFirst();
        AdmissionCode := TicketRequest."Admission Code";

        FirstTicket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        FirstTicket.FindFirst();
    end;

    local procedure CreateSmokeTicketItemNo(): Code[20]
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
    begin
        exit(LibTicket.CreateScenario_SmokeTest());
    end;

    local procedure CreateEcomHeaderWithToken(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Ticket Reservation Token" := EcomCreateTicketImpl.GenerateToken(EcomSalesHeader."Ticket Reservation Token");
        EcomSalesHeader.Modify();
    end;

    local procedure InsertTicketReservationRequest(var TicketRequest: Record "NPR TM Ticket Reservation Req."; Token: Text[100]; EcomSalesId: Guid)
    begin
        TicketRequest.Init();
        TicketRequest."Session Token ID" := Token;
        TicketRequest."Request Status" := TicketRequest."Request Status"::REGISTERED;
        TicketRequest."Request Status Date Time" := CurrentDateTime();
        TicketRequest."Created Date Time" := CurrentDateTime();
        TicketRequest."Ecom Sales Id" := EcomSalesId;
        TicketRequest.Insert();
    end;

    local procedure SetupEcomHeaderAndTicketLine(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line"; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal; Captured: Boolean)
    begin
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, Qty, UnitPrice);
        if Captured then begin
            EcomSalesLine.Captured := true;
            EcomSalesLine.Modify();
        end;
    end;

    local procedure UpdateDefaultBOM(ItemNo: Code[20]; ChangeDefault: Boolean; AdmCode: Code[20]; ActivationMethod: Enum "NPR TM ActivationMethod_Bom")
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBOM.SetRange("Item No.", ItemNo);
        TicketBOM.SetRange(Default, true);
        TicketBOM.FindFirst();
        if ChangeDefault then begin
            TicketBOM.Default := false;
            TicketBOM.Modify();
        end;
    end;

    var
        _Lib: Codeunit "NPR Library Ecommerce";
        _LibTicket: Codeunit "NPR Library - Ticket Module";
        Assert: Codeunit "Assert";
}
#endif