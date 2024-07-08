codeunit 85056 "NPR TM Dynamic Ticket Test"
{
    Subtype = Test;

    var
        Initialized: Boolean;
        TicketItemNo: Code[20];

        TicketBOMElements, RequiredBOMElements : Integer;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MakeDynamicTicketReservationAPI()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
    begin
        InitializeData();
        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation(1, TicketItemNo, 1, '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        // Check Reservation Request
        TicketReservationReq.SetRange("Session Token ID", ResponseToken);
        Assert.AreEqual(TicketBOMElements, TicketReservationReq.Count(), 'Reservation request line count not as expected');
        // Check Ticket
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');
        // Check Admissions
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        Assert.AreEqual(RequiredBOMElements, TicketAccessEntry.Count(), 'Ticket admission line count not as expected');
        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', '', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
    end;



    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Make2DynamicTicketsReservationAPI()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
    begin
        InitializeData();
        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation(1, TicketItemNo, 2, '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        // Check Reservation Request
        TicketReservationReq.SetRange("Session Token ID", ResponseToken);
        Assert.AreEqual(TicketBOMElements, TicketReservationReq.Count(), 'Reservation request line count not as expected');
        // Check Ticket
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');
        // Check Admissions
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        Assert.AreEqual(RequiredBOMElements, TicketAccessEntry.Count(), 'Ticket admission line count not as expected');
        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', '', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MakeDynamicTicketReservationAndChangeAPI()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TmpCurrentRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationResponse: Record "NPR TM Ticket Reserv. Resp." temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ChangeToken, ResponseToken, ResponseMessage : Text;
        InitialAdmissionCount, ChangedAmissionCount : Integer;
    begin
        InitializeData();
        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation(1, TicketItemNo, 1, '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', '', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        // Change reservation
        TmpCreatedTickets.FindFirst();
        ReservationRequest.Get(TmpCreatedTickets."Ticket Reservation Entry No.");
        ReservationOk := TicketApiLibrary.GetTicketChangeRequest(TmpCreatedTickets."External Ticket No.", ReservationRequest."Authorization Code", ChangeToken, TmpCurrentRequest, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        TicketAccessEntry.SetRange("Ticket No.", TmpCreatedTickets."No.");
        InitialAdmissionCount := TicketAccessEntry.Count();
        Assert.AreEqual(RequiredBOMElements, InitialAdmissionCount, 'Ticket admission line count not as expected');
        //Confirm change with added 1 admission
        ReservationOk := TicketApiLibrary.ConfirmChangeDynamicTicketReservation(ChangeToken, TmpCurrentRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        //Check result
        TicketAccessEntry.SetRange("Ticket No.", TmpCreatedTickets."No.");
        ChangedAmissionCount := TicketAccessEntry.Count();
        Assert.AreEqual(InitialAdmissionCount + 1, ChangedAmissionCount, 'Ticket admission line count not as expected after change');
    end;


    procedure InitializeData()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        if not Initialized then begin
            TicketBOMElements := 6;
            RequiredBOMElements := 3;

            TicketItemNo := TicketLibrary.CreateDynamicTicketScenario(TicketBOMElements, RequiredBOMElements);
            Initialized := true;
        end;

        Commit();
    end;
}
