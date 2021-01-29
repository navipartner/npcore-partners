codeunit 85013 "NPR TM API SmokeTest"
{
    Subtype = Test;

    [Test]
    procedure ListTicketItems()
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];

        TmpItemVariant: Record "Item Variant" temporary;
    begin

        ItemNo := SelectSmokeTestScenario();

        // [Test]
        ReservationOk := TicketApiLibrary.ListTicketItems(TmpItemVariant);
        Assert.IsTrue(ReservationOk, 'Expected service to report at least one ticket item.');

    end;


    [Test]
    procedure MakeTicketReservation()
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        // [Test]
        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

    end;


    [Test]
    procedure ConfirmTicketReservation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');
    end;

    [Test]
    procedure PreConfirmTicketReservation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        ReservationOk := TicketApiLibrary.PreConfirmTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
    end;

    [Test]
    procedure CancelPrelTicketReservation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        ReservationOk := TicketApiLibrary.CancelTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        // Confirming a cancelled reservation should fail
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsFalse(ReservationOk, ResponseMessage);

    end;

    [Test]
    procedure CancelConfirmedTicketReservation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        // Cancelling a confirmed reservation should fail
        ReservationOk := TicketApiLibrary.CancelTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsFalse(ReservationOk, ResponseMessage);

    end;

    [Test]
    procedure GetTicketPrintURL()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        // [TEST]
        // DIY is not setup in this scenario and should fail
        asserterror TicketApiLibrary.GetTicketsPrintURL(TmpCreatedTickets, ResponseMessage);
        ResponseMessage := GetLastErrorText();

        if (StrPos(ResponseMessage, 'Ticket Setup has not been completed in respect to creating online tickets.') = 0) then
            Error(ResponseMessage);
    end;

    [Test]
    procedure GetComplementaryItem()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Item: Record "Item";
        TicketType: Record "NPR TM Ticket Type";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        WebService: Codeunit "NPR TM Ticket WebService";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        Status: Integer;
        ComplementaryItemNo: Code[20];
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        TmpCreatedTickets.FindFirst();

        ComplementaryItemNo := ''; // Consume the setup complementary item
        Status := WebService.GetComplementaryMembershipItemNo(TmpCreatedTickets."External Ticket No.", ComplementaryItemNo);
        Assert.AreEqual(-12, status, 'Action must return status -12 when default complementary item is not setup.');

        Item.Get(ItemNo);
        TicketType.Get(Item."NPR Ticket Type");
        TicketType."Membership Sales Item No." := ItemNo;
        TicketType.Modify();

        ComplementaryItemNo := ''; // Consume the setup complementary item
        Status := WebService.GetComplementaryMembershipItemNo(TmpCreatedTickets."External Ticket No.", ComplementaryItemNo);
        Assert.AreEqual(1, status, 'Action must return status 1 for success.');

    end;

    [Test]
    procedure OfflineValidation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Item: Record "Item";
        TicketType: Record "NPR TM Ticket Type";
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        WebService: Codeunit "NPR TM Ticket WebService";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        Status: Integer;
        ReferenceName: Code[20];
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [TEST]
        ReferenceName := GenerateCode20();
        ReservationOk := TicketApiLibrary.OfflineTicketValidation(TmpCreatedTickets, ReferenceName, ResponseMessage);

        OfflineTicketValidation.SetFilter("Import Reference Name", '=%1', ReferenceName);
        OfflineTicketValidation.SetFilter("Process Status", '=%1', OfflineTicketValidation."Process Status"::VALID);
        Assert.AreEqual(TmpCreatedTickets.Count(), OfflineTicketValidation.Count(), 'The action did not create same number of import lines as tickets provided.');

    end;

    [Test]
    procedure ConsumeComplementaryItem()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Item: Record "Item";
        TicketType: Record "NPR TM Ticket Type";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        WebService: Codeunit "NPR TM Ticket WebService";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        Status: Integer;
        ComplementaryItemNo: Code[20];
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        TmpCreatedTickets.FindFirst();

        Item.Get(ItemNo);
        TicketType.Get(Item."NPR Ticket Type");
        TicketType."Membership Sales Item No." := ItemNo;
        TicketType.Modify();

        ComplementaryItemNo := ''; // Consume the setup complementary item
        Status := WebService.ConsumeComplementaryItem(TmpCreatedTickets."External Ticket No.", ComplementaryItemNo);
        Assert.AreEqual(1, status, 'Action must return status 1 for success.');

        ComplementaryItemNo := ''; // Consume the setup complementary item
        Status := WebService.GetComplementaryMembershipItemNo(TmpCreatedTickets."External Ticket No.", ComplementaryItemNo);
        Assert.AreEqual(-20, status, 'Action must return status -20 when item is consumed.');


        ComplementaryItemNo := 'abc';
        Status := WebService.ConsumeComplementaryItem(TmpCreatedTickets."External Ticket No.", ComplementaryItemNo);
        Assert.AreEqual(1, status, 'Action must return status 1 for success.');

        ComplementaryItemNo := 'abc';
        Status := WebService.GetComplementaryMembershipItemNo(TmpCreatedTickets."External Ticket No.", ComplementaryItemNo);
        Assert.AreEqual(-20, status, 'Action must return status -20 when item is consumed.');

    end;

    [Test]
    procedure AdmissionCapacity()
    var
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ApiOk: Boolean;
    begin

        ItemNo := SelectSmokeTestScenario();
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();

        TicketApiLibrary.AdmissionCapacityCheck(TicketBom."Admission Code", Today, ItemNo, TmpAdmScheduleEntryResponseOut);
        Assert.AreEqual(1, TmpAdmScheduleEntryResponseOut.Count(), 'Invalid response count.');

        // [Test]
        // Smoketest scenario sets up scedules for +5D so, today inclusive, it should be 6 entries
        TicketApiLibrary.AdmissionCapacityCheck(TicketBom."Admission Code", 0D, ItemNo, TmpAdmScheduleEntryResponseOut);
        Assert.AreEqual(6, TmpAdmScheduleEntryResponseOut.Count(), 'Invalid response count.');

    end;

    [Test]
    procedure ValidateTicketArrival()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        PaymentReference: Code[20];
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        // [Test]
        TmpCreatedTickets.FindFirst();
        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

    end;

    [Test]
    procedure ValidateTicketArrivalWithoutPayment()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        PaymentReference: Code[20];
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := ''; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        // [Test]
        TmpCreatedTickets.FindFirst();
        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Ticket must have registered payment to allow arrival.');

    end;

    [Test]
    procedure ValidateTicketDeparture()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        DetailedTicketEntry: Record "NPR TM Det. Ticket AccessEntry";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();
        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        // [Test]
        ApiOk := TicketApiLibrary.ValidateTicketDeparture(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        DetailedTicketEntry.SetFilter("Ticket No.", '=%1', TmpCreatedTickets."No.");
        DetailedTicketEntry.SetFilter(Type, '=%1', DetailedTicketEntry.Type::DEPARTED);
        DetailedTicketEntry.FindFirst();
    end;


    [Test]
    procedure ListTickets()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        DetailedTicketEntry: Record "NPR TM Det. Ticket AccessEntry";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        PaymentReference: Code[20];
        ExternalTicketNumber: Code[20];
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(3) + 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();
        ExternalTicketNumber := TmpCreatedTickets."External Ticket No.";
        if (TmpCreatedTickets.IsTemporary()) then
            TmpCreatedTickets.DeleteAll();

        // [Test 1]
        ApiOk := TicketApiLibrary.ListDetails_Ticket(ExternalTicketNumber, TmpCreatedTickets);
        Assert.IsTrue(ApiOk, 'Ticket was not found when searching using the ListDetails SOAP action.');
        TmpCreatedTickets.FindFirst();
        Assert.AreEqual(ExternalTicketNumber, TmpCreatedTickets."External Ticket No.", 'The found ticket does correspond to ticket searched for.');

        // [Test 2]
        ApiOk := TicketApiLibrary.ListDetails_Token(ResponseToken, TmpCreatedTickets);
        Assert.IsTrue(ApiOk, 'Tickets were not found when searching using the ListDetails SOAP action filtering on token.');
        Assert.AreEqual(NumberOfTicketOrders * TicketQuantityPerOrder, TmpCreatedTickets.Count(), 'The found ticket does correspond to ticket searched for.');

    end;

    [Test]
    procedure GetTicketChangeRequest()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TmpChangeRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        // [Test]
        TmpCreatedTickets.FindFirst();
        ReservationRequest.Get(TmpCreatedTickets."Ticket Reservation Entry No.");
        ApiOk := TicketApiLibrary.GetTicketChangeRequest(TmpCreatedTickets."External Ticket No.", ReservationRequest."Authorization Code", ResponseToken, TmpChangeRequest, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        TmpChangeRequest.FindFirst();
        Assert.AreEqual(TicketBom."Admission Code", TmpChangeRequest."Admission Code", 'The change request included an unexpected admission code.');
        Assert.AreEqual(TicketBom.Count(), TmpChangeRequest.Count(), 'The change request contains the wrong number of lines.');


    end;


    [Test]
    procedure ConfirmTicketChangeRequest()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TmpCurrentRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TmpTargetRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TmpTicketReservationResponse: Record "NPR TM Ticket Reserv. Resp." temporary;
        AdmScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ChangeToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        TmpCreatedTickets.FindFirst();
        ReservationRequest.Get(TmpCreatedTickets."Ticket Reservation Entry No.");
        ApiOk := TicketApiLibrary.GetTicketChangeRequest(TmpCreatedTickets."External Ticket No.", ReservationRequest."Authorization Code", ChangeToken, TmpCurrentRequest, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        // [Test]
        TicketBom.FindFirst();
        TmpCurrentRequest.FindFirst();

        // Select target time slot to be greater in time than the current time slot.
        TmpTargetRequest.TransferFields(TmpCurrentRequest, true);
        AdmScheduleEntry.SetFilter("Admission Code", '=%1', TmpTargetRequest."Admission Code");
        AdmScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmScheduleEntry.SetFilter("External Schedule Entry No.", '>%1', TmpTargetRequest."External Adm. Sch. Entry No.");
        AdmScheduleEntry.FindFirst();
        TmpTargetRequest."External Adm. Sch. Entry No." := AdmScheduleEntry."External Schedule Entry No.";
        TmpTargetRequest.Insert();


        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::NOT_ALLOWED;
        TicketBom.Modify();

        // Should fail
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Confirm Change was expected to fail because policy does not allow change.');

        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::UNTIL_USED;
        TicketBom.Modify();

        // Should be successful
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        // Should fail
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Confirm Change was expected to fail because ticket violates change policy.');

    end;

    [Test]
    procedure SetTicketAttribute()
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];

        AdmissionCodeArray: array[10] of Code[20];
        AttributeCodeArray: array[10] of Code[10];
        ValueArray: array[10] of Text[100];
    begin

        ItemNo := SelectSmokeTestScenario();

        // Define Attributes f.ex. 'TM-1' attached as attribute 1
        AttributeCodeArray[1] := TicketLibrary.CreateAttributeTableLink(TicketLibrary.CreateAttribute('TM', 1, 'Usage Description'), DATABASE::"NPR TM Ticket Reservation Req.", 1);
        AttributeCodeArray[2] := TicketLibrary.CreateAttributeTableLink(TicketLibrary.CreateAttribute('TM', 2, 'Usage Description'), DATABASE::"NPR TM Ticket Reservation Req.", 2);

        ValueArray[1] := 'TM-1 gets this value';
        ValueArray[2] := 'Hello World TM-2';

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        ReservationOk := TicketApiLibrary.SetTicketAttribute(ResponseToken, AdmissionCodeArray, AttributeCodeArray, ValueArray, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        AttributeCodeArray[2] := 'INVALID';
        ReservationOk := TicketApiLibrary.SetTicketAttribute(ResponseToken, AdmissionCodeArray, AttributeCodeArray, ValueArray, ResponseMessage);
        Assert.IsFalse(ReservationOk, 'Provided attribute is not defined and message should have failed.');

    end;

    [Test]
    procedure SendETicket()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        // eTicket is not setup, should return false and message 'Not eTicket'
        ReservationOk := TicketApiLibrary.SendETicket(ResponseToken, ResponseMessage);
        Assert.AreEqual('Not eTicket.', ResponseMessage, ResponseMessage);

    end;

    [Normal]
    local procedure SelectSmokeTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
    end;



    local procedure GenerateCode20(): Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        exit(TicketLibrary.GenerateCode20());
    end;
}