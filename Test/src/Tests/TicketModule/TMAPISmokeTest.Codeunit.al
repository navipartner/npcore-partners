codeunit 85013 "NPR TM API SmokeTest"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketPatternHexStringToDecimal()
    var
        Assert: Codeunit "Assert";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        i: Integer;
        Digits: Label '0123456789ABCDEF', Locked = true;
    begin

        for i := 0 to 15 do
            Assert.AreEqual(i, TicketManagement.HexStringToDecimal(CopyStr(Digits, i + 1, 1)), 'Incorrectly converting Hex to Dec, position 0');

        for i := 0 to 15 do
            Assert.AreEqual((i * 16) + 1, TicketManagement.HexStringToDecimal(CopyStr(Digits, i + 1, 1) + '1'), 'Incorrectly converting Hex to Dec, position 1');

        for i := 0 to 15 do
            Assert.AreEqual((i * 256) + 1 * 16 + 2, TicketManagement.HexStringToDecimal(CopyStr(Digits, i + 1, 1) + '12'), 'Incorrectly converting Hex to Dec, position 2');

        for i := 0 to 15 do
            Assert.AreEqual((i * 4096) + 1 * 256 + 2 * 16 + 3, TicketManagement.HexStringToDecimal(CopyStr(Digits, i + 1, 1) + '123'), 'Incorrectly converting Hex to Dec, position 3');

        AssertError TicketManagement.HexStringToDecimal('G');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketPatternGenerator()
    var
        Assert: Codeunit "Assert";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        RandomCharacter: Code[1];
        i: Integer;
    begin

        for i := 1 to 100 do begin
            RandomCharacter := TicketManagement.GenerateRandomFromPattern('N');
            Assert.AreEqual('', DelChr(RandomCharacter, '=', '0123456789'), 'Expected a decimal number character.');

            RandomCharacter := TicketManagement.GenerateRandomFromPattern('A');
            Assert.AreEqual('', DelChr(RandomCharacter, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 'Expected a character.');

            RandomCharacter := TicketManagement.GenerateRandomFromPattern('X');
            Assert.AreEqual('', DelChr(RandomCharacter, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 'Expected an alpha-numeric character.');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketPattern()
    var
        Assert: Codeunit "Assert";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Pattern: Code[30];
    begin
        Pattern := TicketManagement.GenerateNumberPattern('[S]', '1234567');
        Assert.AreEqual('1234567', Pattern, 'Expected same pattern to be returned with option S.');

        Pattern := TicketManagement.GenerateNumberPattern('[N*5]', '');
        Assert.AreEqual(5, StrLen(Pattern), 'Incorrect length of pattern.');
        Assert.AreEqual('', DelChr(Pattern, '=', '0123456789'), 'Expected decimal number characters only.');

        Pattern := TicketManagement.GenerateNumberPattern('[A*5]', '');
        Assert.AreEqual(5, StrLen(Pattern), 'Incorrect length of pattern.');
        Assert.AreEqual('', DelChr(Pattern, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 'Expected characters only.');

        Pattern := TicketManagement.GenerateNumberPattern('[X*5]', '');
        Assert.AreEqual(5, StrLen(Pattern), 'Incorrect length of pattern.');
        Assert.AreEqual('', DelChr(Pattern, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 'Expected alpha-numeric characters only.');

        Pattern := TicketManagement.GenerateNumberPattern('TM01-[S]-[N*4]-[A*4]-[X*4]', 'AB12');
        Assert.AreEqual(24, StrLen(Pattern), 'Incorrect length of pattern.');
        Assert.AreEqual('----', DelChr(Pattern, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 'Incorrect pattern created.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListTicketItems()
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ReservationOk: Boolean;

        TmpItemVariant: Record "Item Variant" temporary;
    begin

        ItemNo := SelectSmokeTestScenario();

        // [Test]
        ReservationOk := TicketApiLibrary.ListTicketItems(TmpItemVariant);
        Assert.IsTrue(ReservationOk, 'Expected service to report at least one ticket item.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreConfirmTicketReservation()
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

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        ReservationOk := TicketApiLibrary.PreConfirmTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelPrelTicketReservation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
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

        TicketRequest.SetFilter("Session Token ID", '=%1', ResponseToken);
        TicketRequest.FindFirst();
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();
        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.FindFirst();

        ReservationOk := TicketApiLibrary.CancelTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        // Confirming a cancelled reservation should fail
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsFalse(ReservationOk, ResponseMessage);

        // Test
        // All ticket transactional data should be deleted
        Assert.IsTrue(TmpCreatedTickets.IsEmpty(), 'ConfirmTicketReservation API returned invalid data.');
        Assert.IsTrue(Ticket.IsEmpty(), 'Ticket was not deleted.');
        Assert.IsTrue(TicketAccessEntry.IsEmpty(), 'TicketAccessEntry was not deleted.');
        Assert.IsTrue(DetTicketAccessEntry.IsEmpty(), 'DetailedTicketAccessEntry was not deleted.');
        Assert.IsTrue(TicketRequest.IsEmpty(), 'Ticket Reservation Request was not deleted.')
    end;



    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelPrelTicketReservationStatistics()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        TicketStatistics: Codeunit "NPR TM Ticket Access Stats";
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

        // Aggregate statistics
        TicketStatistics.BuildCompressedStatistics(Today(), false);

        TicketRequest.SetFilter("Session Token ID", '=%1', ResponseToken);
        TicketRequest.FindFirst();
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();
        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.FindFirst();

        ReservationOk := TicketApiLibrary.CancelTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        // Confirming a cancelled reservation should fail
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsFalse(ReservationOk, ResponseMessage);

        // Test
        // All ticket transactional data should be deleted
        Assert.IsTrue(TmpCreatedTickets.IsEmpty(), 'ConfirmTicketReservation API returned invalid data.');
        Assert.IsTrue(Ticket.IsEmpty(), 'Ticket was not deleted.');
        Assert.IsTrue(TicketAccessEntry.IsEmpty(), 'TicketAccessEntry was not deleted.');
        Assert.IsTrue(DetTicketAccessEntry.IsEmpty(), 'DetailedTicketAccessEntry was not deleted.');
        Assert.IsTrue(TicketRequest.IsEmpty(), 'Ticket Reservation Request was not deleted.')
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelReservedTicketReservation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        NumberOfReservations: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
    begin
        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;
        NumberOfReservations := 1;

        ItemNo := SelectSimpleReservationTestScenario(NumberOfReservations);
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();

        TicketApiLibrary.AdmissionCapacityCheck(TicketBom."Admission Code", Today(), ItemNo, TmpAdmScheduleEntryResponseOut);
        Assert.AreEqual(NumberOfReservations, TmpAdmScheduleEntryResponseOut.Count(), 'Invalid response count.');
        TmpAdmScheduleEntryResponseOut.SetFilter("Admission Start Time", '<=%1', Time());
        TmpAdmScheduleEntryResponseOut.SetFilter("Admission End Time", '>=%1', Time());
        TmpAdmScheduleEntryResponseOut.FindFirst();

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, TmpAdmScheduleEntryResponseOut."External Schedule Entry No.", MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        TicketRequest.SetFilter("Session Token ID", '=%1', ResponseToken);
        TicketRequest.FindFirst();
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();
        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.FindFirst();

        // [Test]
        // Cancel is OK.
        ReservationOk := TicketApiLibrary.CancelTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Test
        // All ticket transactional data should be deleted
        Assert.IsTrue(TmpCreatedTickets.IsEmpty(), 'ConfirmTicketReservation API returned invalid data.');
        Assert.IsTrue(Ticket.IsEmpty(), 'Ticket was not deleted.');
        Assert.IsTrue(TicketAccessEntry.IsEmpty(), 'TicketAccessEntry was not deleted.');
        Assert.IsTrue(DetTicketAccessEntry.IsEmpty(), 'DetailedTicketAccessEntry was not deleted.');
        Assert.IsTrue(TicketRequest.IsEmpty(), 'Ticket Reservation Request was not deleted.')
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelReservedTicketReservationStatistics()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketStatistics: Codeunit "NPR TM Ticket Access Stats";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ReservationOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        NumberOfReservations: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
    begin
        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;
        NumberOfReservations := 1;

        ItemNo := SelectSimpleReservationTestScenario(NumberOfReservations);
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();

        TicketApiLibrary.AdmissionCapacityCheck(TicketBom."Admission Code", Today(), ItemNo, TmpAdmScheduleEntryResponseOut);
        Assert.AreEqual(NumberOfReservations, TmpAdmScheduleEntryResponseOut.Count(), 'Invalid response count.');
        TmpAdmScheduleEntryResponseOut.SetFilter("Admission Start Time", '<=%1', Time());
        TmpAdmScheduleEntryResponseOut.SetFilter("Admission End Time", '>=%1', Time());
        TmpAdmScheduleEntryResponseOut.FindFirst();

        ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, TmpAdmScheduleEntryResponseOut."External Schedule Entry No.", MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Aggregate statistics
        TicketStatistics.BuildCompressedStatistics(Today(), false);

        TicketRequest.SetFilter("Session Token ID", '=%1', ResponseToken);
        TicketRequest.FindFirst();
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();
        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.FindFirst();

        // [Test]
        // Cancel is OK.
        ReservationOk := TicketApiLibrary.CancelTicketReservation(ResponseToken, ScannerStation, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Test
        // All ticket transactional data should be deleted
        Assert.IsTrue(TmpCreatedTickets.IsEmpty(), 'ConfirmTicketReservation API returned invalid data.');
        Assert.IsTrue(Ticket.IsEmpty(), 'Ticket was not deleted.');
        Assert.IsTrue(TicketAccessEntry.IsEmpty(), 'TicketAccessEntry was not deleted.');
        Assert.IsTrue(DetTicketAccessEntry.IsEmpty(), 'DetailedTicketAccessEntry was not deleted.');
        Assert.IsTrue(TicketRequest.IsEmpty(), 'Ticket Reservation Request was not deleted.')
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
        TicketSetup: Record "NPR TM Ticket Setup";
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

        if (TicketSetup.Get()) then
            TicketSetup.Delete();

        // [TEST]
        // DIY is not setup in this scenario and should fail
        asserterror TicketApiLibrary.GetTicketsPrintURL(TmpCreatedTickets, ResponseMessage);
        ResponseMessage := GetLastErrorText();

        if (StrPos(ResponseMessage, 'Ticket Setup has not been completed in respect to creating online tickets.') = 0) then
            Error(ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetComplementaryItem()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Item: Record Item;
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure OfflineValidation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConsumeComplementaryItem()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Item: Record Item;
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmissionCapacity()
    var
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
    begin

        ItemNo := SelectSmokeTestScenario();
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();

        TicketApiLibrary.AdmissionCapacityCheck(TicketBom."Admission Code", Today, ItemNo, TmpAdmScheduleEntryResponseOut);
        Assert.AreEqual(1, TmpAdmScheduleEntryResponseOut.Count(), 'Invalid response count.');

        // [Test]
        // Smoketest scenario sets up schedules for +5D so, today inclusive, it should be 6 entries
        TicketApiLibrary.AdmissionCapacityCheck(TicketBom."Admission Code", 0D, ItemNo, TmpAdmScheduleEntryResponseOut);
        Assert.AreEqual(6, TmpAdmScheduleEntryResponseOut.Count(), 'Invalid response count.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateTicketArrivalInvalidAdmission()
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
        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", 'FOOBAR', ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiOk, ResponseMessage);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateTicketArrivalBrokenSetup01()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketBom: Record "NPR TM Ticket Admission BOM";
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

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();
        TicketBom.SetFilter("Item No.", '=%1', TmpCreatedTickets."Item No.");
        TicketBom.DeleteAll();

        // [Test]
        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiOk, ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateTicketArrivalFakeTicket()
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
        ApiOk := TicketApiLibrary.ValidateTicketArrival('BOGUS-1P!"#!"FUBAR', '', ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiOk, 'An invalid ticket should not be allowed entry.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListTickets()
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
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
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
        ChangeToken, SuperseededToken : Text;
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
        ApiOk := TicketApiLibrary.GetTicketChangeRequest(TmpCreatedTickets."External Ticket No.", ReservationRequest."Authorization Code", SuperseededToken, TmpCurrentRequest, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

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

        // Should fail
        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::UNTIL_USED;
        TicketBom.Modify();
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(SuperseededToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Confirm Change was expected to fail since the token used is not valid anymore (superseeded).');

        // Should fail
        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::NOT_ALLOWED;
        TicketBom.Modify();
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Confirm Change was expected to fail because policy does not allow change.');

        // Should be successful
        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::UNTIL_USED;
        TicketBom.Modify();
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        // Should fail
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsFalse(ApiOk, 'Confirm Change was expected to fail because ticket violates change policy.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmTicketChangeRequest_2()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TmpCurrentRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TmpTargetRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TmpTicketReservationResponse: Record "NPR TM Ticket Reserv. Resp." temporary;
        AdmScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DetailedTicketRequest: Record "NPR TM Det. Ticket AccessEntry";
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
        DetailedTicketRequest.SetFilter("Ticket No.", '=%1', TmpCreatedTickets."No.");
        DetailedTicketRequest.SetFilter(Type, '=%1', DetailedTicketRequest.Type::INITIAL_ENTRY);
        DetailedTicketRequest.FindFirst();

        // Manipulate the timeslot to be expired
        AdmScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedTicketRequest."External Adm. Sch. Entry No.");
        AdmScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmScheduleEntry.FindFirst();
        AdmScheduleEntry."Admission Start Date" := CalcDate('<-1D>');
        AdmScheduleEntry."Admission End Date" := CalcDate('<-1D>');
        AdmScheduleEntry.Modify();

        // Getting the request should be ok - there is an element saying change is not allowed
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

        // Should fail
        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::UNTIL_USED;
        TicketBom.Modify();
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsFalse(ApiOk, StrSubstNo('Confirm Change was expected to fail since policy excludes expired timeslots. %1', ResponseMessage));

        // Should be successful
        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::UNTIL_ADMITTED;
        TicketBom.Modify();
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        // Admitt ticket and try again
        // Manipulate the timeslot to be valid again
        AdmScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedTicketRequest."External Adm. Sch. Entry No.");
        AdmScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmScheduleEntry.FindFirst();
        AdmScheduleEntry."Admission Start Date" := Today();
        AdmScheduleEntry."Admission End Date" := Today();
        AdmScheduleEntry.Modify();
        ApiOk := TicketApiLibrary.ValidateTicketArrival(TmpCreatedTickets."External Ticket No.", '', ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        // Getting the request should be ok - there is an element saying change is not allowed
        TmpCurrentRequest.DeleteAll();
        ReservationRequest.Get(TmpCreatedTickets."Ticket Reservation Entry No.");
        ApiOk := TicketApiLibrary.GetTicketChangeRequest(TmpCreatedTickets."External Ticket No.", ReservationRequest."Authorization Code", ChangeToken, TmpCurrentRequest, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        // Select target time slot to be greater in time than the current time slot.
        TmpCurrentRequest.FindFirst();
        TmpTargetRequest.TransferFields(TmpCurrentRequest, true);
        AdmScheduleEntry.SetFilter("Admission Code", '=%1', TmpTargetRequest."Admission Code");
        AdmScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmScheduleEntry.SetFilter("External Schedule Entry No.", '>%1', TmpTargetRequest."External Adm. Sch. Entry No.");
        AdmScheduleEntry.FindFirst();
        TmpTargetRequest."External Adm. Sch. Entry No." := AdmScheduleEntry."External Schedule Entry No.";
        TmpTargetRequest.Insert();

        // Should fail
        ApiOk := TicketApiLibrary.ConfirmChangeTicketReservation(ChangeToken, TmpCurrentRequest, TmpTargetRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsFalse(ApiOk, StrSubstNo('Confirm Change was expected to fail because ticket violates change policy. %1', ResponseMessage));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
    [TestPermissions(TestPermissions::Disabled)]
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


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmissionBaseCalendar()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        CustomizedCalendar: Record "Customized Calendar Change";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        CalendarManager: Codeunit "NPR TMBaseCalendarManager";

        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        CountedEntries: Integer;
    begin
        ItemNo := SelectBaseCalendarTestScenario();

        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();

        Admission.Get(TicketBom."Admission Code");
        AdmissionSchedule.SetFilter("Admission Code", '=%1', Admission."Admission Code");
        AdmissionSchedule.FindFirst();
        Schedule.Get(AdmissionSchedule."Schedule Code");

        ScheduleManager.CreateAdmissionScheduleTestFramework(Admission."Admission Code", true, Today);
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', Admission."Admission Code");
        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', Schedule."Schedule Code");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (AdmissionScheduleEntry.Count() < 10) then
            Error('Less than 10 entries was created but scenaio expects 1 month of entries (>=28).');

        AdmissionScheduleEntry.SetFilter("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::CLOSED);
        CountedEntries := AdmissionScheduleEntry.Count();
        Assert.AreEqual(0, CountedEntries, 'Expected closed entries must be zero at this point.');

        CalendarManager.SetAdmissionCalendar(Admission, CustomizedCalendar);
        CreateNonWorkingEntry(CustomizedCalendar, CalcDate('+3D'));

        ScheduleManager.CreateAdmissionScheduleTestFramework(Admission."Admission Code", true, Today);
        CountedEntries := AdmissionScheduleEntry.Count();
        Assert.AreEqual(1, CountedEntries, 'Customized Calendar for Admision did not impact closed state on timeslot.');

        CalendarManager.SetScheduleCalendar(Schedule, CustomizedCalendar);
        CreateNonWorkingEntry(CustomizedCalendar, CalcDate('+5D'));

        ScheduleManager.CreateAdmissionScheduleTestFramework(Admission."Admission Code", true, Today);
        CountedEntries := AdmissionScheduleEntry.Count();
        Assert.AreEqual(2, CountedEntries, 'Customized Calendar for Schedule did not impact closed state on timeslot.');

        CalendarManager.SetAdmissionScheduleCalendar(AdmissionSchedule, CustomizedCalendar);
        CreateNonWorkingEntry(CustomizedCalendar, CalcDate('+7D'));

        ScheduleManager.CreateAdmissionScheduleTestFramework(Admission."Admission Code", true, Today);
        CountedEntries := AdmissionScheduleEntry.Count();
        Assert.AreEqual(3, CountedEntries, 'Customized Calendar for Admision Schedule did not impact closed state on timeslot.');

    end;

    [Normal]
    local procedure CreateNonWorkingEntry(var CustomizedCalendar: Record "Customized Calendar Change"; Date: Date)
    begin
        CustomizedCalendar.Date := Date;
        CustomizedCalendar.Nonworking := true;
        CustomizedCalendar.Insert();
    end;

    [Normal]
    local procedure SelectSmokeTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
    end;

    [Normal]
    local procedure SelectSimpleReservationTestScenario(NumberOfTimeslots: Integer) ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_ReservationRequired(NumberOfTimeslots)
    end;

    [Normal]
    local procedure GenerateCode20(): Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        exit(TicketLibrary.GenerateCode20());
    end;

    [Normal]
    local procedure SelectBaseCalendarTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_BaseCalendar();
    end;
}