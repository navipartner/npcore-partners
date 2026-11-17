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
    procedure PreMadeReservation_UnknownLineId_Error()
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
        UnknownLineId: Guid;
    begin
        // [SCENARIO] The ecom document insertion pipeline errors when ticketReservationLineId matches no reservation request

        // [GIVEN] A reservation made via the Ticket API and a line id with no reservation request
        ScannerStation := 'TEST';
        ItemNo := LibTicket.CreateScenario_SmokeTest();
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'MakeReservation should succeed: ' + ResponseMessage);
        UnknownLineId := CreateGuid();

        // [WHEN] The document is inserted with the token and the unknown line id
        asserterror _Lib.InsertEcomDocumentWithReservationLineId('PREMADE-UNKLINEID', ResponseToken, ItemNo, UnknownLineId, EcomSalesHeader);

        // [THEN] The error names the unknown line id
        Assert.ExpectedError(Format(UnknownLineId));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreMadeReservation_LineIdFromOtherToken_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        ResponseToken: Text[100];
        OtherResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
        ItemNo: Code[20];
        ForeignLineId: Guid;
    begin
        // [SCENARIO] The ecom document insertion pipeline errors when ticketReservationLineId belongs to another token

        // [GIVEN] Two reservations made via the Ticket API, with tokens T1 and T2
        ScannerStation := 'TEST';
        ItemNo := LibTicket.CreateScenario_SmokeTest();
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'MakeReservation should succeed: ' + ResponseMessage);
        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, OtherResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, 'Second MakeReservation should succeed: ' + ResponseMessage);
        Assert.AreNotEqual(ResponseToken, OtherResponseToken, 'Precondition: the two reservations must have different tokens');

        // [GIVEN] The line id of a reservation request of T2
        TicketRequest.SetRange("Session Token ID", OtherResponseToken);
        TicketRequest.FindFirst();
        ForeignLineId := TicketRequest.SystemId;
        Assert.IsFalse(IsNullGuid(ForeignLineId), 'Precondition: the reservation request of T2 must have an id');

        // [WHEN] The document is inserted with T1 and the line id of T2
        asserterror _Lib.InsertEcomDocumentWithReservationLineId('PREMADE-FOREIGNLID', ResponseToken, ItemNo, ForeignLineId, EcomSalesHeader);

        // [THEN] The error names the line id of T2
        Assert.ExpectedError(Format(ForeignLineId));
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmTickets_FCYDocument_TicketAmountsInLCY()
    var
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        LibTicket: Codeunit "NPR Library - Ticket Module";
        ItemNo: Code[20];
    begin
        // [Scenario] Ticket amounts issued from an FCY document are stored in LCY (unit price 100 FCY at factor 0.1
        // -> 1000 LCY excl. VAT, 1250 incl. 25% VAT), matching the POS convention, not the raw FCY line amount.
        _Lib.CreateFCYCurrency(Currency, 0.1);

        ItemNo := LibTicket.CreateScenario_SmokeTest();
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Price Excl. VAT" := true;
        EcomSalesHeader."Currency Code" := Currency.Code;
        EcomSalesHeader."Currency Exchange Rate" := 0.1;
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesHeader.Modify();

        _Lib.CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        EcomSalesLine."VAT %" := 25;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();

        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);

        TicketRequest.SetRange("Session Token ID", EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetRange("Request Status", TicketRequest."Request Status"::Confirmed);
        TicketRequest.FindFirst();

        Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
        Ticket.FindSet();
        repeat
            Assert.AreEqual(1000, Ticket.AmountExclVat, 'AmountExclVat must be the LCY amount (100 FCY / 0.1 = 1000), not the FCY line amount.');
            Assert.AreEqual(1250, Ticket.AmountInclVat, 'AmountInclVat must be the LCY amount grossed up by 25% VAT (1250), not the FCY line amount.');
        until Ticket.Next() = 0;
    end;

    // ---------------------------------------------------------------
    // Ticket Reservation Line Id check in ValidateDocBySource
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDocBySource_ValidReservationLine_Passes()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [SCENARIO] A store order whose ticket line points to a reservation request of the document token passes validation

        // [GIVEN] A captured store ticket order with a captured payment line
        SetupStoreTicketDoc(EcomSalesHeader, EcomSalesLine);
        Assert.IsFalse(IsNullGuid(EcomSalesLine."Ticket Reservation Line Id"), 'Precondition: the ticket line must reference a reservation request');

        // [WHEN] The document is validated
        EcomSalesDocUtils.ValidateDocBySource(EcomSalesHeader);

        // [THEN] No error is raised
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDocBySource_ReservationLineFromOtherToken_Error()
    var
        EcomSalesHeaderA: Record "NPR Ecom Sales Header";
        EcomSalesHeaderB: Record "NPR Ecom Sales Header";
        EcomSalesLineA: Record "NPR Ecom Sales Line";
        EcomSalesLineB: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        ForeignLineId: Guid;
    begin
        // [SCENARIO] A store order whose ticket line points to a reservation request of another document token fails validation

        // [GIVEN] Two captured store ticket orders A and B, each with its own token and reservation request
        SetupStoreTicketDoc(EcomSalesHeaderA, EcomSalesLineA);
        SetupStoreTicketDoc(EcomSalesHeaderB, EcomSalesLineB);
        EcomSalesLineB.Get(EcomSalesLineB.RecordId);
        ForeignLineId := EcomSalesLineB."Ticket Reservation Line Id";
        Assert.IsFalse(IsNullGuid(ForeignLineId), 'Precondition: line B must reference a reservation request');

        // [GIVEN] Line A points to the reservation request of document B
        EcomSalesLineA."Ticket Reservation Line Id" := ForeignLineId;
        EcomSalesLineA.Modify();

        // [WHEN] Document A is validated
        asserterror EcomSalesDocUtils.ValidateDocBySource(EcomSalesHeaderA);

        // [THEN] The error names the reservation line id of document B
        Assert.ExpectedError(Format(ForeignLineId));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDocBySource_ProcessedLineWithForeignId_Passes()
    var
        EcomSalesHeaderA: Record "NPR Ecom Sales Header";
        EcomSalesHeaderB: Record "NPR Ecom Sales Header";
        EcomSalesLineA: Record "NPR Ecom Sales Line";
        EcomSalesLineB: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        ForeignLineId: Guid;
    begin
        // [SCENARIO] A ticket line that is already Processed is not checked against the document token

        // [GIVEN] Two captured store ticket orders A and B
        SetupStoreTicketDoc(EcomSalesHeaderA, EcomSalesLineA);
        SetupStoreTicketDoc(EcomSalesHeaderB, EcomSalesLineB);
        EcomSalesLineB.Get(EcomSalesLineB.RecordId);
        ForeignLineId := EcomSalesLineB."Ticket Reservation Line Id";
        Assert.IsFalse(IsNullGuid(ForeignLineId), 'Precondition: line B must reference a reservation request');

        // [GIVEN] Line A is Processed and points to the reservation request of document B
        EcomSalesLineA."Virtual Item Process Status" := EcomSalesLineA."Virtual Item Process Status"::Processed;
        EcomSalesLineA."Ticket Reservation Line Id" := ForeignLineId;
        EcomSalesLineA.Modify();

        // [WHEN] Document A is validated
        EcomSalesDocUtils.ValidateDocBySource(EcomSalesHeaderA);

        // [THEN] No error is raised
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateDocBySource_AlreadyConfirmedToken_Passes()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        // [SCENARIO] A ticket line of a token already confirmed for the same External No. is not checked against the token

        // [GIVEN] A captured store ticket order whose token is confirmed with the document External No.
        SetupStoreTicketDoc(EcomSalesHeader, EcomSalesLine);
        EcomCreateTicketImpl.ConfirmTickets(EcomSalesHeader);
        TicketRequest.SetRange("Session Token ID", EcomSalesHeader."Ticket Reservation Token");
        TicketRequest.SetRange("Request Status", TicketRequest."Request Status"::CONFIRMED);
        Assert.IsFalse(TicketRequest.IsEmpty(), 'Precondition: the token must have a confirmed reservation request');
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        Assert.IsFalse(IsNullGuid(EcomSalesLine."Ticket Reservation Line Id"), 'Precondition: the ticket line must reference a reservation request');

        // [GIVEN] The unprocessed line points to an id with no reservation request
        EcomSalesLine."Ticket Reservation Line Id" := CreateGuid();
        EcomSalesLine.Modify();

        // [WHEN] The document is validated
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
        EcomSalesDocUtils.ValidateDocBySource(EcomSalesHeader);

        // [THEN] No error is raised
    end;

    // ---------------------------------------------------------------
    // Ticket Reservation Line Id check in ApplyTicketReservationRemap
    // ---------------------------------------------------------------

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTicketReservationRemap_LineIdOfNewToken_Applied()
    var
        EcomSalesHeaderA: Record "NPR Ecom Sales Header";
        EcomSalesHeaderB: Record "NPR Ecom Sales Header";
        EcomSalesLineA: Record "NPR Ecom Sales Line";
        EcomSalesLineB: Record "NPR Ecom Sales Line";
        TempRemapBuffer: Record "NPR Ticket Reservation Buffer" temporary;
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        NewToken: Text[100];
    begin
        // [SCENARIO] Remapping a ticket line to a reservation request of the new token moves the document to that token and resets its ticket status

        // [GIVEN] Two ticket documents A and B, each with its own token and reservation request
        SetupProcessableTicketDoc(EcomSalesHeaderA, EcomSalesLineA);
        SetupProcessableTicketDoc(EcomSalesHeaderB, EcomSalesLineB);
        EcomSalesHeaderB.Get(EcomSalesHeaderB.RecordId);
        EcomSalesLineB.Get(EcomSalesLineB.RecordId);
        NewToken := EcomSalesHeaderB."Ticket Reservation Token";
        Assert.AreNotEqual('', NewToken, 'Precondition: document B must have a reservation token');
        Assert.IsFalse(IsNullGuid(EcomSalesLineB."Ticket Reservation Line Id"), 'Precondition: line B must reference a reservation request');

        // [GIVEN] Document A failed ticket processing
        EcomSalesHeaderA."Ticket Processing Status" := EcomSalesHeaderA."Ticket Processing Status"::Error;
        EcomSalesHeaderA."Ticket Retry Count" := 3;
        EcomSalesHeaderA.Modify();
        EcomSalesLineA."Virtual Item Process ErrMsg" := 'Previous ticket processing error';
        EcomSalesLineA.Modify();

        // [GIVEN] Line A is mapped to the reservation request of document B
        InsertRemapBufferRow(TempRemapBuffer, 1, EcomSalesLineA, EcomSalesLineB."Ticket Reservation Line Id");

        // [WHEN] The remap is applied with the token of document B
        EcomCreateTicketImpl.ApplyTicketReservationRemap(EcomSalesHeaderA, NewToken, TempRemapBuffer);

        // [THEN] Line A and header A carry the new reservation, and the ticket status is reset for a new attempt
        EcomSalesHeaderA.Get(EcomSalesHeaderA.RecordId);
        EcomSalesLineA.Get(EcomSalesLineA.RecordId);
        Assert.AreEqual(EcomSalesLineB."Ticket Reservation Line Id", EcomSalesLineA."Ticket Reservation Line Id", 'Line A should point to the reservation request of document B');
        Assert.AreEqual(NewToken, EcomSalesHeaderA."Ticket Reservation Token", 'Header A should carry the token of document B');
        Assert.AreEqual(EcomSalesHeaderA."Ticket Processing Status"::Pending, EcomSalesHeaderA."Ticket Processing Status", 'Ticket processing status should be Pending');
        Assert.AreEqual(0, EcomSalesHeaderA."Ticket Retry Count", 'Ticket retry count should be reset');
        Assert.AreEqual('', EcomSalesLineA."Virtual Item Process ErrMsg", 'Line A error message should be cleared');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTicketReservationRemap_LineIdOfOtherToken_Error()
    var
        EcomSalesHeaderA: Record "NPR Ecom Sales Header";
        EcomSalesHeaderB: Record "NPR Ecom Sales Header";
        EcomSalesLineA1: Record "NPR Ecom Sales Line";
        EcomSalesLineA2: Record "NPR Ecom Sales Line";
        EcomSalesLineB: Record "NPR Ecom Sales Line";
        TempRemapBuffer: Record "NPR Ticket Reservation Buffer" temporary;
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        ItemNo: Code[20];
        NewToken: Text[100];
    begin
        // [SCENARIO] A remap where one line is mapped to a reservation request outside the new token fails and names that id

        // [GIVEN] Document A with two captured ticket lines and reservation requests for both
        _Lib.ResetEcomSetupToDefaults();
        ItemNo := CreateSmokeTicketItemNo();
        _Lib.CreateEcomSalesHeader(EcomSalesHeaderA);
        _Lib.CreateCapturedTicketLine(EcomSalesLineA1, EcomSalesHeaderA, ItemNo);
        _Lib.CreateCapturedTicketLine(EcomSalesLineA2, EcomSalesHeaderA, ItemNo);
        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeaderA);
        EcomSalesHeaderA.Get(EcomSalesHeaderA.RecordId);
        EcomSalesLineA1.Get(EcomSalesLineA1.RecordId);
        EcomSalesLineA2.Get(EcomSalesLineA2.RecordId);
        Assert.IsFalse(IsNullGuid(EcomSalesLineA2."Ticket Reservation Line Id"), 'Precondition: the second line of document A must reference a reservation request');

        // [GIVEN] Document B with one ticket line and its own token
        SetupProcessableTicketDoc(EcomSalesHeaderB, EcomSalesLineB);
        EcomSalesHeaderB.Get(EcomSalesHeaderB.RecordId);
        EcomSalesLineB.Get(EcomSalesLineB.RecordId);
        NewToken := EcomSalesHeaderB."Ticket Reservation Token";
        Assert.AreNotEqual('', NewToken, 'Precondition: document B must have a reservation token');
        Assert.IsFalse(IsNullGuid(EcomSalesLineB."Ticket Reservation Line Id"), 'Precondition: line B must reference a reservation request');

        // [GIVEN] Line 1 of A is mapped to the request of B, line 2 of A keeps its own request, which is outside the token of B
        InsertRemapBufferRow(TempRemapBuffer, 1, EcomSalesLineA1, EcomSalesLineB."Ticket Reservation Line Id");
        InsertRemapBufferRow(TempRemapBuffer, 2, EcomSalesLineA2, EcomSalesLineA2."Ticket Reservation Line Id");

        // [WHEN] The remap is applied with the token of document B
        asserterror EcomCreateTicketImpl.ApplyTicketReservationRemap(EcomSalesHeaderA, NewToken, TempRemapBuffer);

        // [THEN] The error names the reservation line id of line 2 of A
        Assert.ExpectedError(Format(EcomSalesLineA2."Ticket Reservation Line Id"));
    end;

    [Test]
    [HandlerFunctions('RemapPageHandler,TokenListPageHandler,TicketRequestPageHandler,ConfirmYesHandler,SuccessMessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeTicketReservationToken_OwnTokenAfterReservationUpdate_LinesRelinked()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        NewRequest: Record "NPR TM Ticket Reservation Req.";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        Token: Text[100];
    begin
        // [SCENARIO] After the reservation is updated under the same token, Change Ticket Reservation Token offers the document's own token and relinks the line to the new request

        // [GIVEN] A ticket document with its own token and reservation request
        SetupProcessableTicketDoc(EcomSalesHeader, EcomSalesLine);
        Token := EcomSalesHeader."Ticket Reservation Token";
        Assert.AreNotEqual('', Token, 'Precondition: the document must have a reservation token');

        // [GIVEN] The reservation is updated under the same token, so the line points to a request that no longer exists
        UpdateReservationInPlace(EcomSalesHeader, EcomSalesLine."Ticket Reservation Line Id", NewRequest);

        // [GIVEN] The document failed ticket processing
        EcomSalesHeader."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Error;
        EcomSalesHeader."Ticket Retry Count" := 3;
        EcomSalesHeader.Modify();
        EcomSalesLine."Virtual Item Process ErrMsg" := 'Previous ticket processing error';
        EcomSalesLine.Modify();

        // [GIVEN] The user picks the document's own token and the new request in the remap page
        _ReservationToken := Token;
        _NewRequestEntryNo := NewRequest."Entry No.";

        // [WHEN] The ticket reservation token is changed
        EcomCreateTicketImpl.ChangeEcommerceTicketReservationToken(EcomSalesHeader);

        // [THEN] The line points to the new request, the token is kept, and the ticket status is reset for a new attempt
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        NewRequest.Get(NewRequest."Entry No.");
        Assert.AreEqual(NewRequest.SystemId, EcomSalesLine."Ticket Reservation Line Id", 'The line should point to the new reservation request');
        Assert.AreEqual(Token, EcomSalesHeader."Ticket Reservation Token", 'The header should keep its own token');
        Assert.AreEqual(EcomSalesHeader."Ticket Processing Status"::Pending, EcomSalesHeader."Ticket Processing Status", 'Ticket processing status should be Pending');
        Assert.AreEqual(0, EcomSalesHeader."Ticket Retry Count", 'Ticket retry count should be reset');
        Assert.AreEqual('', EcomSalesLine."Virtual Item Process ErrMsg", 'The line error message should be cleared');
        Assert.AreEqual(EcomSalesHeader.SystemId, NewRequest."Ecom Sales Id", 'The new reservation request should be linked to the document');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTicketReservationRemap_OwnTokenAfterReservationUpdate_Applied()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        NewRequest: Record "NPR TM Ticket Reservation Req.";
        TempRemapBuffer: Record "NPR Ticket Reservation Buffer" temporary;
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        Token: Text[100];
    begin
        // [SCENARIO] A remap to the document's own token is applied after the reservation was updated under that token

        // [GIVEN] A ticket document with its own token and reservation request
        SetupProcessableTicketDoc(EcomSalesHeader, EcomSalesLine);
        Token := EcomSalesHeader."Ticket Reservation Token";
        Assert.AreNotEqual('', Token, 'Precondition: the document must have a reservation token');

        // [GIVEN] The reservation is updated under the same token, so the line points to a request that no longer exists
        UpdateReservationInPlace(EcomSalesHeader, EcomSalesLine."Ticket Reservation Line Id", NewRequest);

        // [GIVEN] The document failed ticket processing
        EcomSalesHeader."Ticket Processing Status" := EcomSalesHeader."Ticket Processing Status"::Error;
        EcomSalesHeader."Ticket Retry Count" := 3;
        EcomSalesHeader.Modify();
        EcomSalesLine."Virtual Item Process ErrMsg" := 'Previous ticket processing error';
        EcomSalesLine.Modify();

        // [GIVEN] The line is mapped to the new request of the same token
        InsertRemapBufferRow(TempRemapBuffer, 1, EcomSalesLine, NewRequest.SystemId);

        // [WHEN] The remap is applied with the document's own token
        EcomCreateTicketImpl.ApplyTicketReservationRemap(EcomSalesHeader, Token, TempRemapBuffer);

        // [THEN] The line points to the new request, the token is kept, and the ticket status is reset for a new attempt
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        NewRequest.Get(NewRequest."Entry No.");
        Assert.AreEqual(NewRequest.SystemId, EcomSalesLine."Ticket Reservation Line Id", 'The line should point to the new reservation request');
        Assert.AreEqual(Token, EcomSalesHeader."Ticket Reservation Token", 'The header should keep its own token');
        Assert.AreEqual(EcomSalesHeader."Ticket Processing Status"::Pending, EcomSalesHeader."Ticket Processing Status", 'Ticket processing status should be Pending');
        Assert.AreEqual(0, EcomSalesHeader."Ticket Retry Count", 'Ticket retry count should be reset');
        Assert.AreEqual('', EcomSalesLine."Virtual Item Process ErrMsg", 'The line error message should be cleared');
        Assert.AreEqual(EcomSalesHeader.SystemId, NewRequest."Ecom Sales Id", 'The new reservation request should be linked to the document');
    end;

    local procedure SetupStoreTicketDoc(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        SetupProcessableTicketDoc(EcomSalesHeader, EcomSalesLine);
        EcomSalesHeader."Ecommerce Store Code" := 'TEST-STORE';
        EcomSalesHeader.Modify();
        CreateCapturedPaymentLine(EcomSalesHeader, EcomSalesLine."Line Amount");
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
        // Captured Amount equals Amount, so ValidateImportedPaymentLines skips the payment-method checks.
        EcomSalesPmtLine."Captured Amount" := PaymentAmount;
        EcomSalesPmtLine.Insert(true);
    end;

    local procedure InsertRemapBufferRow(var TempRemapBuffer: Record "NPR Ticket Reservation Buffer" temporary; EntryNo: Integer; EcomSalesLine: Record "NPR Ecom Sales Line"; ReservationLineId: Guid)
    begin
        TempRemapBuffer.Init();
        TempRemapBuffer."Entry No." := EntryNo;
        TempRemapBuffer."Document Entry No." := EcomSalesLine."Document Entry No.";
        TempRemapBuffer."Sales Line No." := EcomSalesLine."Line No.";
        TempRemapBuffer."Ticket Reservation Line Id" := ReservationLineId;
        TempRemapBuffer.Insert();
    end;

    local procedure SetupProcessableTicketDoc(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        _Lib.ResetEcomSetupToDefaults();
        _Lib.CreateEcomSalesHeader(EcomSalesHeader);
        _Lib.CreateCapturedTicketLine(EcomSalesLine, EcomSalesHeader, CreateSmokeTicketItemNo());
        EcomCreateTicketImpl.CreateRequestsForTicketLines(EcomSalesHeader);
        // CreateRequestsForTicketLines writes the reservation line id through its own record, so re-read the line.
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        MarkTicketDocReadyForProcessing(EcomSalesHeader);
    end;

    local procedure MarkTicketDocReadyForProcessing(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
        EcomSalesHeader."Tickets Exist" := true;
        EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::Processed;
        EcomSalesHeader.Modify();
    end;

    local procedure UpdateReservationInPlace(EcomSalesHeader: Record "NPR Ecom Sales Header"; OldLineId: Guid; var NewRequest: Record "NPR TM Ticket Reservation Req.")
    var
        OldRequest: Record "NPR TM Ticket Reservation Req.";
        TicketingReservationAgent: Codeunit "NPR TicketingReservationAgent";
        Lines: JsonArray;
        Line: JsonObject;
        Token: Text[100];
        ResponseMessage: Text;
        Created: Boolean;
        Success: Boolean;
    begin
        OldRequest.GetBySystemId(OldLineId);
        Line.Add('itemReference', OldRequest."Item No.");
        Line.Add('quantity', OldRequest.Quantity);
        Line.Add('admissionCode', OldRequest."Admission Code");
        // -1 is what the reservation update sends when no time slot is chosen; the ecom request did not choose one either.
        Line.Add('scheduleId', -1);
        Line.Add('externalLineReference', OldRequest."Ext. Line Reference No.");
        Lines.Add(Line);

        Token := EcomSalesHeader."Ticket Reservation Token";
        Created := TicketingReservationAgent.CreateReservation(Lines, Token, '', 0, Success, ResponseMessage);
        Assert.IsTrue(Created and Success, ResponseMessage);
        Assert.AreEqual(EcomSalesHeader."Ticket Reservation Token", Token, 'Precondition: the reservation update must keep the token');
        Assert.IsFalse(OldRequest.GetBySystemId(OldLineId), 'Precondition: the old reservation request must be gone');

        NewRequest.SetRange("Session Token ID", Token);
        NewRequest.SetRange("Entry Type", NewRequest."Entry Type"::PRIMARY);
        NewRequest.SetRange("Request Status", NewRequest."Request Status"::REGISTERED);
        NewRequest.SetRange("Primary Request Line", true);
        Assert.AreEqual(1, NewRequest.Count(), 'Precondition: the token must have exactly one new primary registered request');
        NewRequest.FindFirst();
    end;

    [ModalPageHandler]
    procedure RemapPageHandler(var Remap: TestPage "NPR Ticket Reservation Remap")
    begin
        Remap.NewTicketReservationToken.Drilldown();
        Remap.First();
        Remap."Ticket Reservation Line Id".Drilldown();
        Remap.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure TokenListPageHandler(var TokenList: TestPage "NPR Ticket Reserv. Req. List")
    begin
        Assert.IsTrue(TokenList.FindFirstField(TokenList."Session Token ID", _ReservationToken), 'The token list must offer the document''s own token');
        TokenList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure TicketRequestPageHandler(var TicketRequest: TestPage "NPR TM Ticket Request")
    begin
        Assert.IsTrue(TicketRequest.GoToKey(_NewRequestEntryNo), 'The ticket request list must show the new reservation request');
        TicketRequest.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure SuccessMessageHandler(Message: Text[1024])
    begin
        Assert.IsTrue(Message.Contains(_ReservationToken), 'The success message must name the assigned token');
    end;

    var
        _Lib: Codeunit "NPR Library Ecommerce";
        _LibTicket: Codeunit "NPR Library - Ticket Module";
        _ReservationToken: Text[100];
        _NewRequestEntryNo: Integer;
        Assert: Codeunit "Assert";
}
#endif