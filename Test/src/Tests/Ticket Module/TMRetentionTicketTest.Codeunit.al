codeunit 85514 "NPR TM Retention Ticket Test"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnusedTicketKeepsEverything()
    var
        Retention: Codeunit "NPR TM Retention Ticket Data";
        Assert: Codeunit Assert;
        TicketNos: List of [Code[20]];
        RequestEntryNos: Dictionary of [Code[20], Integer];
        Before: Dictionary of [Code[20], Text];
        ArchiveBefore: Text;
        TicketNo: Code[20];
        JobId: Code[40];
    begin
        // [GIVEN] 3 imported orders of 5 tickets, none admitted and none blocked
        JobId := ImportOrders(3, 5);
        GetTickets(JobId, '', TicketNos, RequestEntryNos);
        foreach TicketNo in TicketNos do begin
            Before.Add(TicketNo, Footprint(TicketNo, RequestEntryNos.Get(TicketNo)));
            Assert.AreNotEqual(DeletedFootprint(), Before.Get(TicketNo), 'The import must have created the rows this test protects.');
        end;
        ArchiveBefore := ArchiveFootprint(JobId, '');

        // [WHEN] every ticket is offered for retirement
        foreach TicketNo in TicketNos do
            Retention.DeleteOneTicket(TicketNo);

        // [THEN] not one row is gone
        foreach TicketNo in TicketNos do
            Assert.AreEqual(Before.Get(TicketNo), Footprint(TicketNo, RequestEntryNos.Get(TicketNo)), 'An unused ticket that is not blocked must keep every row it owns.');
        Assert.AreEqual(ArchiveBefore, ArchiveFootprint(JobId, ''), 'The import archive must stay while its tickets do.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsedTicketTakesEverythingWithIt()
    var
        Retention: Codeunit "NPR TM Retention Ticket Data";
        Assert: Codeunit Assert;
        TicketNos: List of [Code[20]];
        RequestEntryNos: Dictionary of [Code[20], Integer];
        TicketNo: Code[20];
        JobId: Code[40];
    begin
        // [GIVEN] 3 imported orders of 5 tickets, every ticket admitted
        JobId := ImportOrders(3, 5);
        GetTickets(JobId, '', TicketNos, RequestEntryNos);
        foreach TicketNo in TicketNos do
            Arrive(TicketNo);

        // [WHEN] every ticket is retired
        foreach TicketNo in TicketNos do
            Retention.DeleteOneTicket(TicketNo);

        // [THEN] each ticket took its rows with it, and each order's archive went with its last request
        foreach TicketNo in TicketNos do
            Assert.AreEqual(DeletedFootprint(), Footprint(TicketNo, RequestEntryNos.Get(TicketNo)), 'A used ticket must take every row it owns with it.');
        Assert.AreEqual(EmptyArchive(), ArchiveFootprint(JobId, ''), 'The import archive must go with the last request of its reservation.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockedUnusedTicketIsRetired()
    var
        Retention: Codeunit "NPR TM Retention Ticket Data";
        Assert: Codeunit Assert;
        TicketNos: List of [Code[20]];
        RequestEntryNos: Dictionary of [Code[20], Integer];
        TicketNo: Code[20];
        JobId: Code[40];
    begin
        // [GIVEN] 3 imported orders of 3 tickets, none admitted but all blocked
        JobId := ImportOrders(3, 3);
        GetTickets(JobId, '', TicketNos, RequestEntryNos);
        foreach TicketNo in TicketNos do
            Block(TicketNo);

        // [WHEN] every ticket is offered for retirement
        foreach TicketNo in TicketNos do
            Retention.DeleteOneTicket(TicketNo);

        // [THEN] blocking stands in for use
        foreach TicketNo in TicketNos do
            Assert.AreEqual(DeletedFootprint(), Footprint(TicketNo, RequestEntryNos.Get(TicketNo)), 'A blocked ticket must be retired even though it was never used.');
        Assert.AreEqual(EmptyArchive(), ArchiveFootprint(JobId, ''), 'The import archive must go with the last request of its reservation.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartlyUsedOrderKeepsItsArchive()
    var
        Retention: Codeunit "NPR TM Retention Ticket Data";
        Assert: Codeunit Assert;
        TicketNos: List of [Code[20]];
        RequestEntryNos: Dictionary of [Code[20], Integer];
        Before: Dictionary of [Code[20], Text];
        ArchiveBefore: Text;
        TicketNo: Code[20];
        JobId: Code[40];
        i: Integer;
    begin
        // [GIVEN] 3 imported orders of 5 tickets, and 3 of the first order's tickets admitted
        JobId := ImportOrders(3, 5);
        GetTickets(JobId, '1', TicketNos, RequestEntryNos);
        for i := 1 to 3 do
            Arrive(TicketNos.Get(i));
        for i := 4 to 5 do
            Before.Add(TicketNos.Get(i), Footprint(TicketNos.Get(i), RequestEntryNos.Get(TicketNos.Get(i))));
        ArchiveBefore := ArchiveFootprint(JobId, '1');

        // [WHEN] all 5 tickets of that order are offered for retirement
        foreach TicketNo in TicketNos do
            Retention.DeleteOneTicket(TicketNo);

        // [THEN] the admitted tickets go, the others keep everything, and so does the order's archive
        for i := 1 to 3 do
            Assert.AreEqual(DeletedFootprint(), Footprint(TicketNos.Get(i), RequestEntryNos.Get(TicketNos.Get(i))), 'A used ticket must take every row it owns with it.');
        for i := 4 to 5 do
            Assert.AreEqual(Before.Get(TicketNos.Get(i)), Footprint(TicketNos.Get(i), RequestEntryNos.Get(TicketNos.Get(i))), 'Retiring a ticket must not touch the other tickets of its order.');
        Assert.AreEqual(ArchiveBefore, ArchiveFootprint(JobId, '1'), 'An order with a ticket left must keep its import archive.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PendingDeferralKeepsTicket()
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        Retention: Codeunit "NPR TM Retention Ticket Data";
        Assert: Codeunit Assert;
        PendingTicketNos: List of [Code[20]];
        FinalTicketNos: List of [Code[20]];
        RequestEntryNos: Dictionary of [Code[20], Integer];
        Before: Dictionary of [Code[20], Text];
        TicketNo: Code[20];
        JobId: Code[40];
    begin
        // [GIVEN] 3 imported orders of 3 tickets, all admitted
        JobId := ImportOrders(3, 3);
        GetTickets(JobId, '1', PendingTicketNos, RequestEntryNos);
        GetTickets(JobId, '2', FinalTicketNos, RequestEntryNos);
        foreach TicketNo in PendingTicketNos do
            Arrive(TicketNo);
        foreach TicketNo in FinalTicketNos do
            Arrive(TicketNo);

        // [GIVEN] the first order's deferrals still to be acted on, the second order's settled
        AddDeferral(PendingTicketNos.Get(1), DeferRevenueRequest.Status::REGISTERED);
        AddDeferral(PendingTicketNos.Get(2), DeferRevenueRequest.Status::WAITING);
        AddDeferral(PendingTicketNos.Get(3), DeferRevenueRequest.Status::PENDING_DEFERRAL);
        AddDeferral(FinalTicketNos.Get(1), DeferRevenueRequest.Status::DEFERRED);
        AddDeferral(FinalTicketNos.Get(2), DeferRevenueRequest.Status::IMMEDIATE);
        AddDeferral(FinalTicketNos.Get(3), DeferRevenueRequest.Status::UNRESOLVED);
        foreach TicketNo in PendingTicketNos do
            Before.Add(TicketNo, Footprint(TicketNo, RequestEntryNos.Get(TicketNo)));

        // [WHEN] all six tickets are offered for retirement
        foreach TicketNo in PendingTicketNos do
            Retention.DeleteOneTicket(TicketNo);
        foreach TicketNo in FinalTicketNos do
            Retention.DeleteOneTicket(TicketNo);

        // [THEN] a deferral the engine will still act on keeps its ticket, a settled one goes with it
        foreach TicketNo in PendingTicketNos do begin
            Assert.AreEqual(Before.Get(TicketNo), Footprint(TicketNo, RequestEntryNos.Get(TicketNo)), 'A ticket with a pending deferral must keep every row it owns.');
            Assert.AreEqual(1, CountDeferrals(TicketNo), 'A pending deferral must survive.');
        end;
        foreach TicketNo in FinalTicketNos do begin
            Assert.AreEqual(DeletedFootprint(), Footprint(TicketNo, RequestEntryNos.Get(TicketNo)), 'A ticket whose deferral is settled must be retired.');
            Assert.AreEqual(0, CountDeferrals(TicketNo), 'A settled deferral must go with its ticket.');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SharedRequestCountsDownToItsLastTicket()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Ticket: Record "NPR TM Ticket";
        Retention: Codeunit "NPR TM Retention Ticket Data";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Assert: Codeunit Assert;
        TicketNos: List of [Code[20]];
        RowsOnLine: Dictionary of [Integer, Integer];
        ItemNo: Code[20];
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        Token: Text[100];
        ResponseMessage: Text;
        LineNo: Integer;
        i: Integer;
    begin
        // [GIVEN] a confirmed reservation of 3 lines, each line issuing 3 tickets from a single request
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        Assert.IsTrue(TicketApiLibrary.MakeReservation(3, ItemNo, 3, MemberNumber, ScannerStation, Token, ResponseMessage), ResponseMessage);
        Assert.IsTrue(TicketApiLibrary.ConfirmTicketReservation(Token, 'retention@test.invalid', 'abc', 'Foo Bar Baz', ScannerStation, TmpCreatedTickets, ResponseMessage), ResponseMessage);

        GetTicketsOfLine(Token, 1, TicketNos);
        Assert.AreEqual(3, TicketNos.Count(), 'The first line must have issued 3 tickets, or the ticket type issues one ticket per request.');
        for i := 1 to 3 do
            Assert.AreEqual(0, CountDeferrals(TicketNos.Get(i)), 'The scenario must not raise deferrals of its own.');
        for LineNo := 1 to 3 do begin
            RowsOnLine.Add(LineNo, CountLineRows(Token, LineNo, -1));
            Assert.AreEqual(RowsOnLine.Get(LineNo), CountLineRows(Token, LineNo, 3), 'Every request row of a line must start at the quantity reserved.');
        end;

        for i := 1 to 3 do begin
            // [WHEN] the line's tickets are retired one at a time
            Block(TicketNos.Get(i));
            Retention.DeleteOneTicket(TicketNos.Get(i));

            // [THEN] the ticket is gone, the line counts down until its last ticket takes it, and the other lines are untouched
            Assert.IsFalse(Ticket.Get(TicketNos.Get(i)), 'A retired ticket must be deleted.');
            if (i < 3) then
                Assert.AreEqual(RowsOnLine.Get(1), CountLineRows(Token, 1, 3 - i), 'A request shared by tickets still alive must only lose one from its quantity.')
            else
                Assert.AreEqual(0, CountLineRows(Token, 1, -1), 'The last ticket of a request must take the request with it.');

            for LineNo := 2 to 3 do
                Assert.AreEqual(RowsOnLine.Get(LineNo), CountLineRows(Token, LineNo, 3), 'Retiring a ticket must not touch the requests of other lines.');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GroupTicketTakesItsRequest()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Retention: Codeunit "NPR TM Retention Ticket Data";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        TicketNos: List of [Code[20]];
        RowsOnLine: Dictionary of [Integer, Integer];
        GroupTicketNo: Code[20];
        ItemNo: Code[20];
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        Token: Text[100];
        ResponseMessage: Text;
        RequestEntryNo: Integer;
        LineNo: Integer;
    begin
        // [GIVEN] a confirmed reservation of 3 lines, each a group ticket for 5 people
        ItemNo := CreateScenario_GroupTicket();
        Assert.IsTrue(TicketApiLibrary.MakeReservation(3, ItemNo, 5, MemberNumber, ScannerStation, Token, ResponseMessage), ResponseMessage);
        Assert.IsTrue(TicketApiLibrary.ConfirmTicketReservation(Token, 'retention@test.invalid', 'abc', 'Foo Bar Baz', ScannerStation, TmpCreatedTickets, ResponseMessage), ResponseMessage);

        // [GIVEN] the group shape: one ticket per line, while its request and access entries carry the whole quantity
        GetTicketsOfLine(Token, 1, TicketNos);
        Assert.AreEqual(1, TicketNos.Count(), 'A group line must issue a single ticket for its whole quantity.');
        GroupTicketNo := TicketNos.Get(1);
        Assert.AreEqual(0, CountDeferrals(GroupTicketNo), 'The scenario must not raise deferrals of its own.');

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', GroupTicketNo);
        Assert.IsFalse(TicketAccessEntry.IsEmpty(), 'The group ticket must have access entries.');
        TicketAccessEntry.SetFilter(Quantity, '<>%1', 5);
        Assert.IsTrue(TicketAccessEntry.IsEmpty(), 'Every access entry of a group ticket must carry the whole quantity.');

        for LineNo := 1 to 3 do begin
            RowsOnLine.Add(LineNo, CountLineRows(Token, LineNo, -1));
            Assert.AreEqual(RowsOnLine.Get(LineNo), CountLineRows(Token, LineNo, 5), 'Every request row of a group line must carry the whole quantity.');
        end;

        Ticket.Get(GroupTicketNo);
        RequestEntryNo := Ticket."Ticket Reservation Entry No.";

        // [WHEN] the group ticket is retired
        Block(GroupTicketNo);
        Retention.DeleteOneTicket(GroupTicketNo);

        // [THEN] being the only ticket of its request, it takes the request with it whatever the quantity, and the other lines are untouched
        Assert.AreEqual(DeletedFootprint(), Footprint(GroupTicketNo, RequestEntryNo), 'A group ticket must take every row it owns with it.');
        Assert.AreEqual(0, CountLineRows(Token, 1, -1), 'A group ticket is the only ticket of its request, so the request must go with it.');
        for LineNo := 2 to 3 do
            Assert.AreEqual(RowsOnLine.Get(LineNo), CountLineRows(Token, LineNo, 5), 'Retiring a ticket must not touch the requests of other lines.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetentionJobKeepsTicketsInsideTheCutoff()
    var
        Ticket: Record "NPR TM Ticket";
        Retention: Codeunit "NPR TM Retention Ticket Data";
        Assert: Codeunit Assert;
        ExpiredTicketNos: List of [Code[20]];
        ValidTicketNos: List of [Code[20]];
        RequestEntryNos: Dictionary of [Code[20], Integer];
        Before: Dictionary of [Code[20], Text];
        SecondArchiveBefore: Text;
        ThirdArchiveBefore: Text;
        TicketNo: Code[20];
        JobId: Code[40];
        CutoffDate: Date;
    begin
        // [GIVEN] 3 imported orders of 5 admitted tickets in one job
        JobId := ImportOrders(3, 5);
        GetTickets(JobId, '1', ExpiredTicketNos, RequestEntryNos);
        GetTickets(JobId, '2', ValidTicketNos, RequestEntryNos);
        GetTickets(JobId, '3', ValidTicketNos, RequestEntryNos);
        SetRetentionPeriod('<2Y>');
        CutoffDate := Retention.GetCutoffDate();

        // [GIVEN] the first order's tickets expired before the cutoff, the others still inside it
        foreach TicketNo in ExpiredTicketNos do begin
            Arrive(TicketNo);
            Expire(TicketNo, CalcDate('<-1D>', CutoffDate));
        end;
        foreach TicketNo in ValidTicketNos do begin
            Arrive(TicketNo);
            Ticket.Get(TicketNo);
            Assert.IsTrue(Ticket."Valid To Date" >= CutoffDate, 'A valid ticket must still be inside the retention cutoff, or this test protects nothing.');
            Before.Add(TicketNo, Footprint(TicketNo, RequestEntryNos.Get(TicketNo)));
        end;
        SecondArchiveBefore := ArchiveFootprint(JobId, '2');
        ThirdArchiveBefore := ArchiveFootprint(JobId, '3');

        // [WHEN] the retention job runs
        Retention.Main();

        // [THEN] the expired tickets go and take their order's archive with them
        foreach TicketNo in ExpiredTicketNos do
            Assert.AreEqual(DeletedFootprint(), Footprint(TicketNo, RequestEntryNos.Get(TicketNo)), 'A used ticket expired before the cutoff must be retired.');
        Assert.AreEqual(EmptyArchive(), ArchiveFootprint(JobId, '1'), 'The import archive must go with the last request of its reservation.');

        // [THEN] every ticket inside the cutoff keeps every row, used or not, and so do the other orders of the same job
        foreach TicketNo in ValidTicketNos do
            Assert.AreEqual(Before.Get(TicketNo), Footprint(TicketNo, RequestEntryNos.Get(TicketNo)), 'A ticket inside the retention cutoff must never be touched, even when used.');
        Assert.AreEqual(SecondArchiveBefore, ArchiveFootprint(JobId, '2'), 'Retiring one order must leave the archive of the other orders in its job.');
        Assert.AreEqual(ThirdArchiveBefore, ArchiveFootprint(JobId, '3'), 'Retiring one order must leave the archive of the other orders in its job.');
    end;

    // The smoke-test scenario with a GROUP ticket type: one ticket carries the whole quantity of its line.
    local procedure CreateScenario_GroupTicket() ItemNo: Code[20]
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        TicketTypeCode: Code[10];
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
    begin
        TicketLibrary.CreateMinimalSetup();

        TicketSetup.Init();
        if (not TicketSetup.Insert()) then
            TicketSetup.Get();

        TicketTypeCode := TicketLibrary.CreateTicketType(TicketLibrary.GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::GROUP, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := TicketLibrary.CreateAdmissionCode(TicketLibrary.GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');
        ScheduleCode := TicketLibrary.CreateSchedule(TicketLibrary.GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, Today(), AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000000.010T, 235959.990T, true, true, true, true, true, true, true, '');
        TicketLibrary.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');

        ItemNo := TicketLibrary.CreateItem('', TicketTypeCode, Random(200) + 100);
        TicketLibrary.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, true, Today());
    end;

    local procedure ImportOrders(Orders: Integer; TicketsPerOrder: Integer) JobId: Code[40]
    var
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        ImportTicketTest: Codeunit "NPR TM ImportTicketTest";
        Import: Codeunit "NPR TM Import Ticket Facade";
        Assert: Codeunit Assert;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        ItemNo: Code[20];
        ResponseMessage: Text;
    begin
        ItemNo := ImportTicketTest.SelectImportTestScenario(Schedules);
        Schedules.Get('ALL_DAY', EventTime);

        ImportTicketTest.CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, Orders, TicketsPerOrder, true, TempTicketImport, TempTicketImportLine);
        Assert.IsTrue(Import.ImportTicketsFromJson(ImportTicketTest.GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId), ResponseMessage);
    end;

    // An order id of '' collects the tickets of every order in the job.
    local procedure GetTickets(JobIdParam: Code[40]; OrderIdParam: Code[20]; var TicketNos: List of [Code[20]]; var RequestEntryNos: Dictionary of [Code[20], Integer])
    var
        TicketImportLine: Record "NPR TM ImportTicketLine";
        Ticket: Record "NPR TM Ticket";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        Assert: Codeunit Assert;
    begin
        TicketImportLine.SetFilter(JobId, '=%1', JobIdParam);
        if (OrderIdParam <> '') then
            TicketImportLine.SetFilter(OrderId, '=%1', OrderIdParam);
        Assert.IsTrue(TicketImportLine.FindSet(), 'The import must have archived its lines.');

        repeat
            Ticket.SetFilter("External Ticket No.", '=%1', TicketImportLine.PreAssignedTicketNumber);
            Ticket.FindFirst();
            TicketNos.Add(Ticket."No.");
            RequestEntryNos.Set(Ticket."No.", Ticket."Ticket Reservation Entry No.");

            // A deferral raised by the scenario itself would decide the outcome instead of the rule under test.
            DeferRevenueRequest.SetFilter(TicketNo, '=%1', Ticket."No.");
            Assert.IsTrue(DeferRevenueRequest.IsEmpty(), 'The scenario must not raise deferrals of its own.');
        until (TicketImportLine.Next() = 0);
    end;

    local procedure Arrive(TicketNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
    begin
        Ticket.Get(TicketNo);
        Assert.IsTrue(TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", '', '', ResponseMessage), ResponseMessage);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Access Date", '=%1', 0D);
        Assert.IsTrue(TicketAccessEntry.IsEmpty(), 'Arrival must have dated every access entry, or this is not a used ticket.');
    end;

    local procedure Block(TicketNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.Get(TicketNo);
        Ticket.Blocked := true;
        Ticket."Blocked Date" := Today();
        Ticket.Modify();
    end;

    // The company's own setup may hold a testing value such as <0D>, which would move the cutoff to today.
    local procedure SetRetentionPeriod(Period: Text)
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        TicketSetup.Get();
        Evaluate(TicketSetup."Retire Used Tickets After", Period);
        TicketSetup.Modify();
    end;

    local procedure Expire(TicketNo: Code[20]; ValidTo: Date)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.Get(TicketNo);
        Ticket."Valid To Date" := ValidTo;
        Ticket.Modify();
    end;

    local procedure AddDeferral(TicketNo: Code[20]; Status: Integer)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.FindFirst();

        DeferRevenueRequest.Init();
        DeferRevenueRequest.TicketAccessEntryNo := TicketAccessEntry."Entry No.";
        DeferRevenueRequest.TicketNo := TicketNo;
        DeferRevenueRequest.Status := Status;
        DeferRevenueRequest.Insert();
    end;

    local procedure CountDeferrals(TicketNoParam: Code[20]): Integer
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        DeferRevenueRequest.SetFilter(TicketNo, '=%1', TicketNoParam);
        exit(DeferRevenueRequest.Count());
    end;

    local procedure Footprint(TicketNo: Code[20]; RequestEntryNo: Integer): Text
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        Ticket.SetFilter("No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketRequest.SetFilter("Entry No.", '=%1', RequestEntryNo);
        TicketResponse.SetFilter("Request Entry No.", '=%1', RequestEntryNo);
        TicketNotificationEntry.SetFilter("Ticket No.", '=%1', TicketNo);

        exit(StrSubstNo('ticket=%1 access=%2 detail=%3 request=%4 response=%5 notification=%6',
            Ticket.Count(), TicketAccessEntry.Count(), DetTicketAccessEntry.Count(),
            TicketRequest.Count(), TicketResponse.Count(), TicketNotificationEntry.Count()));
    end;

    local procedure DeletedFootprint(): Text
    begin
        exit('ticket=0 access=0 detail=0 request=0 response=0 notification=0');
    end;

    // An order id of '' covers the archive of every order in the job.
    local procedure ArchiveFootprint(JobIdParam: Code[40]; OrderIdParam: Code[20]): Text
    var
        ImportTicketHeader: Record "NPR TM ImportTicketHeader";
        ImportTicketLine: Record "NPR TM ImportTicketLine";
    begin
        ImportTicketHeader.SetFilter(JobId, '=%1', JobIdParam);
        ImportTicketLine.SetFilter(JobId, '=%1', JobIdParam);
        if (OrderIdParam <> '') then begin
            ImportTicketHeader.SetFilter(OrderId, '=%1', OrderIdParam);
            ImportTicketLine.SetFilter(OrderId, '=%1', OrderIdParam);
        end;

        exit(StrSubstNo('header=%1 lines=%2', ImportTicketHeader.Count(), ImportTicketLine.Count()));
    end;

    local procedure EmptyArchive(): Text
    begin
        exit('header=0 lines=0');
    end;

    local procedure GetTicketsOfLine(Token: Text[100]; LineNo: Integer; var TicketNos: List of [Code[20]])
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.SetFilter("Ext. Line Reference No.", '=%1', LineNo);
        if (not TicketRequest.FindSet()) then
            exit;

        repeat
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
            if (Ticket.FindSet()) then
                repeat
                    TicketNos.Add(Ticket."No.");
                until (Ticket.Next() = 0);
        until (TicketRequest.Next() = 0);
    end;

    // A quantity of -1 counts the rows of the line whatever their quantity.
    local procedure CountLineRows(Token: Text[100]; LineNo: Integer; QuantityParam: Integer): Integer
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.SetFilter("Ext. Line Reference No.", '=%1', LineNo);
        if (QuantityParam >= 0) then
            TicketRequest.SetFilter(Quantity, '=%1', QuantityParam);
        exit(TicketRequest.Count());
    end;
}
