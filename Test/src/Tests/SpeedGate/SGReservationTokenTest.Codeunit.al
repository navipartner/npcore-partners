codeunit 85229 "NPR SG ReservationTokenTest"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_07_TicketToken_00()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Assert: Codeunit Assert;

        RequestToken: Text[100];
        ExternalTicketNumber: Code[30];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];
        NumberOfTickets: Integer;
    begin
        // ExternalTicketNumber := GetOneTicket();
        NumberOfTickets := 1;
        RequestToken := CreateTicketsFromImport(NumberOfTickets);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', RequestToken);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        Assert.AreEqual(NumberOfTickets, TicketReservationRequest.Quantity * TicketReservationRequest.Count(), 'Number of tickets in request not equal to expected');

        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        TicketProfileCode := SpeedGateLibrary.CreateProfile(); // Do not permit ticket tokens
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', TicketAccessEntry."Admission Code", '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, '');

        asserterror ValidatePermitted(SpeedGate.CreateAdmitToken(RequestToken, '', 'GATE01'), NumberOfTickets);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_07_TicketToken_01()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Assert: Codeunit Assert;

        RequestToken: Text[100];
        ExternalTicketNumber: Code[30];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];
        NumberOfTickets: Integer;
    begin
        // ExternalTicketNumber := GetOneTicket();
        NumberOfTickets := 1;
        RequestToken := CreateTicketsFromImport(NumberOfTickets);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', RequestToken);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        Assert.AreEqual(NumberOfTickets, TicketReservationRequest.Quantity * TicketReservationRequest.Count(), 'Number of tickets in request not equal to expected');

        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        TicketProfileCode := SpeedGateLibrary.CreateProfile(true);
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', TicketAccessEntry."Admission Code", '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, '');

        ValidatePermitted(SpeedGate.CreateAdmitToken(RequestToken, '', 'GATE01'), NumberOfTickets);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_07_TicketToken_02()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Assert: Codeunit Assert;

        RequestToken: Text[100];
        ExternalTicketNumber: Code[30];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];
        NumberOfTickets: Integer;
    begin
        // ExternalTicketNumber := GetOneTicket();
        NumberOfTickets := 3;
        RequestToken := CreateTicketsFromImport(NumberOfTickets);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', RequestToken);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        Assert.AreEqual(NumberOfTickets, TicketReservationRequest.Quantity * TicketReservationRequest.Count(), 'Number of tickets in request not equal to expected');

        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        TicketProfileCode := SpeedGateLibrary.CreateProfile(true);
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', TicketAccessEntry."Admission Code", '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, '');

        ValidatePermitted(SpeedGate.CreateAdmitToken(RequestToken, '', 'GATE01'), NumberOfTickets);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_07_TicketToken_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Assert: Codeunit Assert;

        RequestToken: Text[100];
        ExternalTicketNumber: Code[30];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];
        NumberOfTickets: Integer;
    begin
        // ExternalTicketNumber := GetOneTicket();
        NumberOfTickets := 5;
        RequestToken := CreateTicket(NumberOfTickets);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', RequestToken);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        Assert.AreEqual(NumberOfTickets, TicketReservationRequest.Quantity * TicketReservationRequest.Count(), 'Number of tickets in request not equal to expected');

        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        TicketProfileCode := SpeedGateLibrary.CreateProfile(true);
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', TicketAccessEntry."Admission Code", '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, '');

        ValidatePermitted(SpeedGate.CreateAdmitToken(RequestToken, '', 'GATE01'), NumberOfTickets);
    end;

    [Normal]
    procedure ValidatePermitted(AdmitToken: Guid; NumberOfTickets: Integer)
    var
        EntryLog: Record "NPR SGEntryLog";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        EntryLog.SetCurrentKey(Token);
        EntryLog.SetFilter(Token, '=%1', AdmitToken);
        EntryLog.FindFirst();

        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::TICKET_REQUEST);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::PERMITTED_BY_GATE);

        SpeedGate.Admit(AdmitToken, 1);
        ValidateTicketRequest(EntryLog.ReferenceNo, EntryLog.AdmissionCode, EntryLog.ScannerId, NumberOfTickets);
    end;

    local procedure ValidateTicketRequest(ReservationToken: Text[100]; AdmissionCode: Code[20]; GateCode: Code[10]; NumberOfTickets: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Assert: Codeunit Assert;
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID", "Primary Request Line");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', ReservationToken);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindSet();
        repeat
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            Ticket.FindSet();
            repeat
                ValidateAdmitted(Ticket."No.", AdmissionCode, GateCode);
                NumberOfTickets -= 1;
            until (Ticket.Next() = 0);
        until (TicketReservationRequest.Next() = 0);

        Assert.AreEqual(0, NumberOfTickets, 'Number of tickets in request not equal to expected');

    end;

    local procedure ValidateAdmitted(TicketNo: Code[20]; AdmissionCode: Code[20]; GateCode: Code[10])
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.FindFirst();
        TicketAccessEntry.TestField("Admission Code", AdmissionCode);
        TicketAccessEntry.TestField("Access Date");
        TicketAccessEntry.TestField("Access Time");

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
        if (DetTicketAccessEntry.Count() <> 1) then
            Error('Expected 1 Admitted DetTicketAccessEntry, but found %1', DetTicketAccessEntry.Count());

        //DetTicketAccessEntry.TestField("Scanner Station ID", GateCode);
    end;

    local procedure CreateTicket(NumberOfTickets: Integer) RequestToken: Text[100]
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        SpeedGateTest: Codeunit "NPR SG TicketTest";
    begin
        RequestToken := SpeedGateTest.CreateTicket(NumberOfTickets, TmpCreatedTickets);
    end;

    [Normal]
    local procedure CreateTicketsFromImport(TicketQuantity: Integer): Text[100]
    var
        ImportTestHandler: Codeunit "NPR TM ImportTicketTest";
        Import: Codeunit "NPR TM Import Ticket Facade";
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        ImportJob: Record "NPR TM ImportTicketHeader";

        ItemNo: Code[20];
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        Assert: Codeunit Assert;
    begin
        ItemNo := ImportTestHandler.SelectImportTestScenario(Schedules);
        Schedules.Get('ALL_DAY', EventTime);

        ImportTestHandler.CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 1, TicketQuantity, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(ImportTestHandler.GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ImportJob.SetFilter(JobID, '=%1', JobId);
        ImportJob.FindFirst();
        exit(ImportJob.TicketRequestToken)
    end;



}