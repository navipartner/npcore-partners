#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
codeunit 85247 "NPR CM Draft Confirm Test"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DraftThenConfirm_CreatesPaymentEntryOnConfirm()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        Reservation: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO] A draft CM order (no payment reference) leaves its ticket reservation in
        // CONFIRMED+UNPAID with no Det. Ticket Access Entry. Calling ConfirmOrder later (with
        // a payment reference) lifts the reservation back to RESERVED via the auto-flip in
        // SetReservationRequestExtraInfo, re-confirms it with Payment Option = PREPAID, and
        // creates the missing Det entry with Sales Channel No. = the order's DocumentNo.

        // [GIVEN] A ticket smoke-test scenario and a CM partner setup
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] A draft CM order with one non-package ticket line
        CMLibrary.InitOrder(PartnerId, 'TEST-001', '', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);

        // [WHEN] CreateOrder is called
        OrderIssuer.CreateOrder(Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        // [THEN] Order is Draft with DocumentNo + JobId assigned
        Order.Get(OrderId);
        DocumentNo := Order.DocumentNo;
        Assert.AreEqual(Order.Status::Draft, Order.Status, 'Status after draft create');
        Assert.AreNotEqual('', DocumentNo, 'DocumentNo populated');
        Assert.AreNotEqual('', Order.JobId, 'JobId populated');

        // [THEN] Ticket exists with Sales Header No. = DocumentNo
        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetFilter("Sales Header No.", '=%1', DocumentNo);
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket exists with Sales Header No. = DocumentNo');

        // [THEN] Reservation is CONFIRMED + UNPAID with empty External Order No.
        Reservation.Get(Ticket."Ticket Reservation Entry No.");
        Assert.AreEqual(Reservation."Request Status"::CONFIRMED, Reservation."Request Status", 'Reservation Request Status after draft create');
        Assert.AreEqual(Reservation."Payment Option"::UNPAID, Reservation."Payment Option", 'Reservation Payment Option after draft create');
        Assert.AreEqual('', Reservation."External Order No.", 'Reservation External Order No. after draft create');

        // [THEN] No Det. Ticket Access Entry yet (worker skipped because UNPAID)
        DetAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetAccessEntry.Type::Payment, DetAccessEntry.Type::POSTPAID, DetAccessEntry.Type::PREPAID);
        Assert.AreEqual(0, DetAccessEntry.Count(), 'No payment entries on draft');

        // [WHEN] The partner provides a payment reference and ConfirmOrder is called
        Order.PaymentReference := 'PAYREF-001';
        Order.Modify();
        OrderIssuer.ConfirmOrder(Order);

        // [THEN] Order is Issued
        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Issued, Order.Status, 'Status after confirm');

        // [THEN] Reservation now CONFIRMED + PREPAID with External Order No. = DocumentNo
        Reservation.Get(Reservation."Entry No.");
        Assert.AreEqual(Reservation."Request Status"::CONFIRMED, Reservation."Request Status", 'Reservation Request Status after confirm');
        Assert.AreEqual(Reservation."Payment Option"::PREPAID, Reservation."Payment Option", 'Reservation Payment Option after confirm');
        Assert.AreEqual(DocumentNo, Reservation."External Order No.", 'Reservation External Order No. after confirm');

        // [THEN] Det. Ticket Access Entry now exists with Sales Channel No. = DocumentNo
        DetAccessEntry.Reset();
        DetAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::PREPAID);
        Assert.IsTrue(DetAccessEntry.FindFirst(), 'Payment entry created on confirm');
        Assert.AreEqual(DocumentNo, DetAccessEntry."Sales Channel No.", 'Det entry Sales Channel No.');
    end;
}
#endif