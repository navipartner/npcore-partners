codeunit 85183 "NPR TM TicketDeferRevenueTest"
{
    Subtype = Test;
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmTicketReservation()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        LibrarySales: Codeunit "Library - Sales";
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
        UnitAmount, UnitAmountInclVat : Decimal;
        SalesHeader: record "Sales Header";
        PostedSalesInv: Code[20];
    begin


        ItemNo := SelectSmokeTestScenario();

        NumberOfTicketOrders := Random(2) + 1;
        TicketQuantityPerOrder := Random(5) + 1;
        UnitAmount := 80;
        UnitAmountInclVat := UnitAmount * 1.25;

        // ReservationOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, 1, TicketQuantityPerOrder, MemberNumber, ScannerStation, UnitAmount, UnitAmountInclVat, ResponseToken, ResponseMessage);
        // Assert.IsTrue(ReservationOk, ResponseMessage);

        // [Test]
        // ExternalOrderNo := 'abc'; // Note: required for deferral 
        // ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, '', ScannerStation, TmpCreatedTickets, ResponseMessage);

        // No tests yet

    end;

    [Normal]
    local procedure SelectSmokeTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
    end;

}