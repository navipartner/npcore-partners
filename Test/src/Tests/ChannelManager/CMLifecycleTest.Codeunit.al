#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
codeunit 85248 "NPR CM Lifecycle Test"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReplaceOrder_TwoLinesOneWalletEachToOneLineTwoWallets()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        ParsedOrder: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        Ticket: Record "NPR TM Ticket";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
        DocumentNoBefore: Code[20];
        OrderLine: Record "NPR CMOrderLine";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        AffectedAssets: Dictionary of [Guid, Integer];
    begin
        // [SCENARIO] Create a draft order with 2 lines, 1 wallet each (2 tickets total), then
        // replace its contents with 1 line carrying 2 wallets (still 2 tickets). Confirm.
        // Verifies DestroyOrderAssets + IssueForOrder both run cleanly inside ReplaceOrder,
        // and that DocumentNo + Partner stay put across the replacement.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] Draft order: 2 lines × 1 wallet each
        CMLibrary.InitOrder(PartnerId, 'TEST-REPLACE-A', '', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderLine(OrderId, 20000, ItemNo, 1, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);
        CMLibrary.AddOrderWallet(OrderId, 20000, 1, TempOrderWallet);
        OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        Order.Get(OrderId);
        DocumentNoBefore := Order.DocumentNo;
        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetFilter("Sales Header No.", '=%1', DocumentNoBefore);
        Assert.AreEqual(2, Ticket.Count(), '2 tickets after initial draft create');

        // [WHEN] ReplaceOrder with 1 line × 2 wallets
        TempOrderLine.DeleteAll();
        TempOrderComponent.DeleteAll();
        TempOrderWallet.DeleteAll();
        CMLibrary.InitOrder(PartnerId, 'TEST-REPLACE-A', '', ParsedOrder);
        ParsedOrder.OrderId := OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 2, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);
        CMLibrary.AddOrderWallet(OrderId, 10000, 2, TempOrderWallet);
        OrderIssuer.ReplaceOrder(true, Order, ParsedOrder, TempOrderLine, TempOrderComponent, TempOrderWallet);

        // [THEN] Order still has same DocumentNo + Partner
        Order.Get(OrderId);
        Assert.AreEqual(DocumentNoBefore, Order.DocumentNo, 'DocumentNo unchanged across replace');
        Assert.AreEqual(PartnerId, Order.PartnerId, 'PartnerId unchanged across replace');

        // [WHEN] Final confirm
        Order.PaymentReference := 'PAY-REPLACE-A';
        Order.Modify();
        OrderIssuer.ConfirmOrder(Order);

        // [THEN] Order Issued, 2 tickets exist with DocumentNo, payment lines present
        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Issued, Order.Status, 'Status after replace+confirm');

        Ticket.Reset();
        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetFilter("Sales Header No.", '=%1', Order.DocumentNo);
        Assert.AreEqual(2, Ticket.Count(), '2 tickets after replace+confirm');

        DetAccessEntry.Reset();
        if (Ticket.FindSet()) then
            repeat
                DetAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                DetAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetAccessEntry.Type::Payment, DetAccessEntry.Type::POSTPAID, DetAccessEntry.Type::PREPAID);
                Assert.IsTrue(DetAccessEntry.FindFirst(), 'Payment entry exists for ticket ' + Ticket."No.");
                Assert.AreEqual(Order.DocumentNo, DetAccessEntry."Sales Channel No.", 'Det entry Sales Channel No.');
            until (Ticket.Next() = 0);

        // [WHEN/THEN] Within six months of the visit the personal data is kept
        asserterror OrderIssuer.AnonymizeOrder(Order, AffectedAssets);

        // [GIVEN] Six months have passed since the visit
        OrderLine.SetFilter(OrderId, '=%1', OrderId);
        OrderLine.ModifyAll(VisitDate, CalcDate('<-6M-1D>', Today()));

        // [WHEN] The personal data is removed from the issued order
        OrderIssuer.AnonymizeOrder(Order, AffectedAssets);

        // [THEN] Nothing left on the order reaches the customer, and the order is still identifiable
        Order.Get(OrderId);
        Assert.AreEqual('', Order.SellToName, 'Sell-to name cleared');
        Assert.AreEqual(LowerCase(DocumentNoBefore) + '@anonymized.invalid', Order.SellToEmail, 'Sell-to e-mail replaced by the pseudonym');
        Assert.AreEqual(DocumentNoBefore, Order.DocumentNo, 'DocumentNo kept across anonymization');

        OrderLine.SetFilter(OrderId, '=%1', OrderId);
        Assert.IsTrue(OrderLine.FindSet(), 'Order lines still exist after anonymization');
        repeat
            Assert.AreEqual('', OrderLine.Name, 'Line name cleared');
            Assert.AreEqual(LowerCase(DocumentNoBefore) + '@anonymized.invalid', OrderLine.NotificationAddress, 'Line address replaced by the pseudonym');
        until (OrderLine.Next() = 0);

        // [THEN] The clear followed through to the tickets the order issued
        Ticket.FindSet();
        repeat
            TicketRequest.Get(Ticket."Ticket Reservation Entry No.");
            Assert.AreEqual('', TicketRequest.TicketHolderName, 'Ticket holder name cleared');
            Assert.AreNotEqual('test@navipartner.dk', TicketRequest."Notification Address", 'Ticket holder address replaced');
        until (Ticket.Next() = 0);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReplaceOrder_OneLineTwoWalletsToTwoLinesOneWalletEach()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        ParsedOrder: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        Ticket: Record "NPR TM Ticket";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
        DocumentNoBefore: Code[20];
    begin
        // [SCENARIO] Mirror of the previous test in the opposite direction: start with 1 line ×
        // 2 wallets, replace with 2 lines × 1 wallet each. Ticket count stays at 2.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] Draft order: 1 line × 2 wallets
        CMLibrary.InitOrder(PartnerId, 'TEST-REPLACE-B', '', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 2, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);
        CMLibrary.AddOrderWallet(OrderId, 10000, 2, TempOrderWallet);
        OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        Order.Get(OrderId);
        DocumentNoBefore := Order.DocumentNo;
        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetFilter("Sales Header No.", '=%1', DocumentNoBefore);
        Assert.AreEqual(2, Ticket.Count(), '2 tickets after initial draft create');

        // [WHEN] ReplaceOrder with 2 lines × 1 wallet each
        TempOrderLine.DeleteAll();
        TempOrderComponent.DeleteAll();
        TempOrderWallet.DeleteAll();
        CMLibrary.InitOrder(PartnerId, 'TEST-REPLACE-B', '', ParsedOrder);
        ParsedOrder.OrderId := OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderLine(OrderId, 20000, ItemNo, 1, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);
        CMLibrary.AddOrderWallet(OrderId, 20000, 1, TempOrderWallet);
        OrderIssuer.ReplaceOrder(true, Order, ParsedOrder, TempOrderLine, TempOrderComponent, TempOrderWallet);

        // [WHEN] Final confirm
        Order.Get(OrderId);
        Order.PaymentReference := 'PAY-REPLACE-B';
        Order.Modify();
        OrderIssuer.ConfirmOrder(Order);

        // [THEN] Order Issued, 2 tickets, payment lines present, DocumentNo preserved
        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Issued, Order.Status, 'Status after replace+confirm');
        Assert.AreEqual(DocumentNoBefore, Order.DocumentNo, 'DocumentNo unchanged across replace');

        Ticket.Reset();
        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetFilter("Sales Header No.", '=%1', Order.DocumentNo);
        Assert.AreEqual(2, Ticket.Count(), '2 tickets after replace+confirm');

        DetAccessEntry.Reset();
        if (Ticket.FindSet()) then
            repeat
                DetAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                DetAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetAccessEntry.Type::Payment, DetAccessEntry.Type::POSTPAID, DetAccessEntry.Type::PREPAID);
                Assert.IsTrue(DetAccessEntry.FindFirst(), 'Payment entry exists for ticket ' + Ticket."No.");
            until (Ticket.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteIssuedOrder_CancelsKeepsHeaderAndBlocksPartnerDelete()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        OrderLine: Record "NPR CMOrderLine";
        OrderWallet: Record "NPR CMOrderWallet";
        PartnerSetup: Record "NPR CMPartnerSetup";
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
        HeaderDeleted: Boolean;
        AffectedAssets: Dictionary of [Guid, Integer];
    begin
        // [SCENARIO] Deleting an Issued order destroys downstream assets but keeps the order
        // header as a Cancelled audit record. While that header still exists, the partner
        // setup row cannot be deleted (blocked by OnDelete trigger).

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] An Issued order (paid-at-create)
        CMLibrary.InitOrder(PartnerId, 'TEST-DELETE-ISSUED', 'PAY-ISSUED', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);
        OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Issued, Order.Status, 'Pre-delete: Status = Issued');

        // [WHEN] DeleteOrder is called
        HeaderDeleted := OrderIssuer.DeleteOrder(Order);

        // [THEN] Header survives, returned false, transitioned to Cancelled, lifecycle fields cleared
        Assert.AreEqual(false, HeaderDeleted, 'Issued order: header kept');
        Assert.IsTrue(Order.Get(OrderId), 'Header still exists');
        Assert.AreEqual(Order.Status::Cancelled, Order.Status, 'Status = Cancelled after destroy');
        Assert.AreEqual('', Order.JobId, 'JobId cleared');
        Assert.AreEqual('', Order.ManifestUrl, 'ManifestUrl cleared');
        Assert.IsTrue(IsNullGuid(Order.ManifestId), 'ManifestId cleared');

        // [THEN] Lines + wallets gone, header is the only trace
        OrderLine.SetFilter(OrderId, '=%1', OrderId);
        Assert.AreEqual(0, OrderLine.Count(), 'OrderLines deleted');
        OrderWallet.SetFilter(OrderId, '=%1', OrderId);
        Assert.AreEqual(0, OrderWallet.Count(), 'OrderWallets deleted');

        // [WHEN/THEN] Partner setup cannot be deleted while the cancelled order references it
        Commit();
        PartnerSetup.Get(PartnerId);
        asserterror PartnerSetup.Delete(true);
        Assert.ExpectedError('Cannot delete partner');

        // [WHEN/THEN] A cancelled order is final, so the audit row it left behind can still be anonymized
        Order.Get(OrderId);
        OrderIssuer.AnonymizeOrder(Order, AffectedAssets);
        Order.Get(OrderId);
        Assert.AreEqual('', Order.SellToName, 'Sell-to name cleared on the cancelled header');
        Assert.AreNotEqual('test@navipartner.dk', Order.SellToEmail, 'Sell-to e-mail replaced on the cancelled header');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteDraftOrder_RemovesHeaderEntirely()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        Probe: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
        HeaderDeleted: Boolean;
        AffectedAssets: Dictionary of [Guid, Integer];
    begin
        // [SCENARIO] Deleting a Draft order destroys assets and removes the header row too —
        // unlike Issued, no audit row is kept. After the header is gone, the partner setup
        // becomes deletable again.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] A Draft order (no PaymentReference)
        CMLibrary.InitOrder(PartnerId, 'TEST-DELETE-DRAFT', '', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, Today(), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);
        OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Draft, Order.Status, 'Pre-delete: Status = Draft');

        // [WHEN/THEN] A draft can still be processed, so anonymizing it is refused
        asserterror OrderIssuer.AnonymizeOrder(Order, AffectedAssets);
        Assert.ExpectedError('Personal data can only be removed');

        // [WHEN] DeleteOrder is called
        HeaderDeleted := OrderIssuer.DeleteOrder(Order);

        // [THEN] Header row is gone, returned true
        Assert.AreEqual(true, HeaderDeleted, 'Draft order: header deleted');
        Assert.IsFalse(Probe.Get(OrderId), 'Header row no longer exists');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateOrderWithPastVisitDate_LandsInErrorState()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        OtaOrderRunner: Codeunit "NPR CMJobQueueRunner";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
        AffectedAssets: Dictionary of [Guid, Integer];
    begin
        // [SCENARIO] A visit date in the past is rejected by the TM import worker (a guest cannot want to
        // visit in the past). The CMOrderIssuer should catch the failure, commit Status = Error + StatusMessage,
        // and re-raise. The header row should persist with the error state for the partner to inspect and replace.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] A draft order with visit date 5 days in the past — no admission schedule there
        CMLibrary.InitOrder(PartnerId, 'TEST-PAST-VISIT', '', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, CalcDate('<-5D>', Today()), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);

        // [WHEN] order will fail in sync mode - worker errors out
        asserterror OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        // [THEN] Order header committed with Processing status 
        Assert.IsTrue(Order.Get(OrderId), 'Header committed despite worker failure');
        Assert.AreEqual(Order.Status::Processing, Order.Status, 'Status = Processing');
        Assert.AreEqual('', Order.StatusMessage, 'StatusMessage should be empty');

        // [WHEN] processing is not a terminal state, so the JQ runner will attempt to re-process it and hit a invalid state and fail again
        asserterror OtaOrderRunner.ReProcessSingleOrder(Order);

        Order.Get(OrderId);
        Order.Status := Order.Status::Submitted;
        Order.Modify();
        OtaOrderRunner.ReProcessSingleOrder(Order);

        // [THEN] Order header committed with Error status + StatusMessage
        Assert.IsTrue(Order.Get(OrderId), 'Header committed despite worker failure');
        Assert.AreEqual(Order.Status::Error, Order.Status, 'Status = Error');
        Assert.AreNotEqual('', Order.StatusMessage, 'StatusMessage populated with worker error text');

        // [THEN] No JobId persisted (worker cleaned up its import buffers before re-raising)
        Assert.AreEqual('', Order.JobId, 'JobId not set after failure');

        // [WHEN/THEN] An order in Error can be re-processed, so anonymizing it is refused
        asserterror OrderIssuer.AnonymizeOrder(Order, AffectedAssets);
        Assert.ExpectedError('Personal data can only be removed');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateOrderTodaySchedule_ResolvesToCurrentSlot()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
    begin
        // [SCENARIO] A TODAY admission is "now"-based: the imported visit date is not used to pick the slot.
        // An order with a future visit date still mints, and the admission resolves to today's slot - not the
        // future date the partner sent.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest(); // TODAY admission, all-day schedule
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] A paid order whose visit date is 5 days in the future
        CMLibrary.InitOrder(PartnerId, 'TEST-TODAY', 'PAY-TODAY', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, CalcDate('<+5D>', Today()), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);

        // [WHEN] Processed (paid-at-create -> issued)
        OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        // [THEN] Issued, and the admission resolved to today - the future visit date was ignored for selection
        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Issued, Order.Status, 'Status = Issued');
        AssertTicketResolvedToDate(Order.DocumentNo, Today());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateOrderScheduleEntry_BindsProvidedSlot()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        OrderId: Guid;
        PartnerId: Guid;
        ItemNo: Code[20];
    begin
        // [SCENARIO] A SCHEDULE_ENTRY (manual) admission uses the provided visit date/time to bind the matching
        // schedule entry, rather than resolving to "now".

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();

        // [GIVEN] The admission requires a manually selected schedule entry
        TicketBOM.SetFilter("Item No.", '=%1', ItemNo);
        TicketBOM.FindFirst();
        TicketBOM."Ticket Schedule Selection" := TicketBOM."Ticket Schedule Selection"::SCHEDULE_ENTRY;
        TicketBOM.Modify();

        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] A paid order for a future slot
        CMLibrary.InitOrder(PartnerId, 'TEST-MANUAL', 'PAY-MANUAL', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, CalcDate('<+2D>'), 120000T, TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);

        // [WHEN] Processed
        OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        // [THEN] Issued, and the admission bound the schedule entry for the provided date
        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Issued, Order.Status, 'Status = Issued');
        AssertTicketResolvedToDate(Order.DocumentNo, CalcDate('<+2D>'));
    end;

    local procedure AssertTicketResolvedToDate(SalesHeaderNo: Code[20]; ExpectedDate: Date)
    var
        Ticket: Record "NPR TM Ticket";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Assert: Codeunit Assert;
    begin
        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetFilter("Sales Header No.", '=%1', SalesHeaderNo);
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket exists for order');

        DetAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetAccessEntry.SetFilter("External Adm. Sch. Entry No.", '<>%1', 0);
        Assert.IsTrue(DetAccessEntry.FindFirst(), 'Admission entry with a resolved schedule slot exists');

        ScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetAccessEntry."External Adm. Sch. Entry No.");
        Assert.IsTrue(ScheduleEntry.FindFirst(), 'Resolved schedule entry exists');
        Assert.AreEqual(ExpectedDate, ScheduleEntry."Admission Start Date", 'Resolved admission start date');
    end;

    #region Tour Booking
    var
        _POSInitialized: Boolean;
        _POSSession: Codeunit "NPR POS Session";
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _LastMessage: Text;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TourBooking_IssuePayAtPickup_DraftWithOneOrderConfirmation()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        NotifEntry: Record "NPR Digital Notification Entry";
        Reservation: Record "NPR TM Ticket Reservation Req.";
        PartnerSetup: Record "NPR CMPartnerSetup";
        PartnerId: Guid;
        ItemNo: Code[20];
    begin
        // [SCENARIO] A booking paid at pick-up is issued to Draft: its tickets are minted but unpaid, and only the
        // order confirmation is queued, to the booking's e-mail. The wallet mail waits for the confirmation.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        CMLibrary.InitWalletSetup();
        PartnerId := CMLibrary.CreateTourBookingPartner("NPR CMDistribution"::NPMail, 'TEST-OC', 'TEST-WALLET');
        PartnerSetup.Get(PartnerId);
        PartnerSetup.NPDesignerTemplateId := 'TEST-LAYOUT';
        PartnerSetup.Modify();

        // [GIVEN] A pay-at-pick-up booking with one ticket line for today
        CMLibrary.CreateTourBooking(PartnerId, "NPR CMPaymentOption"::PayAtPickup, Order);
        CMLibrary.AddTourBookingLine(Order, 10000, ItemNo, 1, Today(), Time(), OrderLine);

        // [WHEN] Issued
        IssueTourBooking(Order);

        // [THEN] Draft, with an unpaid reservation behind the ticket
        Assert.AreEqual(Order.Status::Draft, Order.Status, 'Status after issue');
        GetBookingReservation(Order, Reservation);
        Assert.AreEqual(Reservation."Payment Option"::UNPAID, Reservation."Payment Option", 'Reservation payment option after issue');

        // [THEN] Exactly one order confirmation, to the booking's e-mail, and no wallet mail
        Assert.AreEqual(1, CountNotifications(Order, "NPR Dig. Notif. Type"::"Order Confirmation"), 'Order confirmations queued');
        Assert.AreEqual(0, CountNotifications(Order, "NPR Dig. Notif. Type"::"Digital Assets"), 'Wallet mails queued');
        NotifEntry.SetFilter("Source Document Id", '=%1', Order.OrderId);
        NotifEntry.SetFilter("Notification Type", '=%1', NotifEntry."Notification Type"::"Order Confirmation");
        Assert.IsTrue(NotifEntry.FindFirst(), 'Order confirmation entry');
        Assert.AreEqual('booker@navipartner.dk', NotifEntry."Recipient E-mail", 'Order confirmation recipient');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TourBooking_ReopenThenIssue_ReleasesReservationAndQueuesNewConfirmation()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        OrderWallet: Record "NPR CMOrderWallet";
        Reservation: Record "NPR TM Ticket Reservation Req.";
        PartnerId: Guid;
        ItemNo: Code[20];
        ReservationEntryNo: Integer;
    begin
        // [SCENARIO] Reopening a Draft booking releases its assets and the capacity they hold, and removes the order
        // confirmation that has not gone out yet. Issuing it again mints new assets and queues a fresh confirmation.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        CMLibrary.InitWalletSetup();
        PartnerId := CMLibrary.CreateTourBookingPartner("NPR CMDistribution"::NPMail, 'TEST-OC', '');

        // [GIVEN] An issued pay-at-pick-up booking with its unsent order confirmation
        CMLibrary.CreateTourBooking(PartnerId, "NPR CMPaymentOption"::PayAtPickup, Order);
        CMLibrary.AddTourBookingLine(Order, 10000, ItemNo, 1, Today(), Time(), OrderLine);
        IssueTourBooking(Order);
        GetBookingReservation(Order, Reservation);
        ReservationEntryNo := Reservation."Entry No.";

        // [WHEN] Reopened
        TourBookingMgt.ReopenOrder(Order);

        // [THEN] Back to WIP: the reservation and wallets are gone, and so is the unsent confirmation
        Order.Get(Order.OrderId);
        Assert.AreEqual(Order.Status::WIP, Order.Status, 'Status after reopen');
        Assert.IsFalse(Reservation.Get(ReservationEntryNo), 'Reservation released by the reopen');
        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        Assert.AreEqual(0, OrderWallet.Count(), 'Wallets released by the reopen');
        Assert.AreEqual(0, CountNotifications(Order, "NPR Dig. Notif. Type"::"Order Confirmation"), 'Unsent order confirmation removed');

        // [WHEN] Issued again
        IssueTourBooking(Order);

        // [THEN] Draft again, with a fresh order confirmation queued
        Assert.AreEqual(Order.Status::Draft, Order.Status, 'Status after the second issue');
        Assert.AreEqual(1, CountNotifications(Order, "NPR Dig. Notif. Type"::"Order Confirmation"), 'Order confirmations after the second issue');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TourBooking_Cancel_RemovesContentAndUnsentMail()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        OrderWallet: Record "NPR CMOrderWallet";
        Reservation: Record "NPR TM Ticket Reservation Req.";
        PartnerId: Guid;
        ItemNo: Code[20];
        ReservationEntryNo: Integer;
    begin
        // [SCENARIO] Cancelling a Draft booking releases its assets, removes its lines and its unsent order
        // confirmation, and keeps the header as a Cancelled record.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        CMLibrary.InitWalletSetup();
        PartnerId := CMLibrary.CreateTourBookingPartner("NPR CMDistribution"::NPMail, 'TEST-OC', '');

        // [GIVEN] An issued pay-at-pick-up booking with its unsent order confirmation
        CMLibrary.CreateTourBooking(PartnerId, "NPR CMPaymentOption"::PayAtPickup, Order);
        CMLibrary.AddTourBookingLine(Order, 10000, ItemNo, 1, Today(), Time(), OrderLine);
        IssueTourBooking(Order);
        GetBookingReservation(Order, Reservation);
        ReservationEntryNo := Reservation."Entry No.";

        // [WHEN] Cancelled
        TourBookingMgt.CancelOrder(Order);

        // [THEN] The header is kept as Cancelled; lines, wallets, reservation and unsent mail are gone
        Order.Get(Order.OrderId);
        Assert.AreEqual(Order.Status::Cancelled, Order.Status, 'Status after cancel');
        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        Assert.AreEqual(0, OrderLine.Count(), 'Lines removed by the cancel');
        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        Assert.AreEqual(0, OrderWallet.Count(), 'Wallets removed by the cancel');
        Assert.IsFalse(Reservation.Get(ReservationEntryNo), 'Reservation released by the cancel');
        Assert.AreEqual(0, CountNotifications(Order, "NPR Dig. Notif. Type"::"Order Confirmation"), 'Unsent order confirmation removed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TourBooking_Issue_RefusesBookingsThatCannotBeIssued()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        Assert: Codeunit Assert;
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        SecondLine: Record "NPR CMOrderLine";
        PartnerSetup: Record "NPR CMPartnerSetup";
        WalletSetup: Record "NPR WalletAssetSetup";
        Admission: Record "NPR TM Admission";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        PartnerId: Guid;
        ItemNo: Code[20];
        TwoAdmissionItemNo: Code[20];
        AdmissionCode: Code[20];
    begin
        // [SCENARIO] Issue refuses a booking that cannot be honoured: prepaid without a payment reference, a visit date
        // in the past, a wallet mail without any design layout. A ticket with more than one admission is refused as
        // soon as it is entered on a line.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        CMLibrary.InitWalletSetup();
        WalletSetup.Get('');
        WalletSetup.NPDesignerTemplateId := '';
        WalletSetup.Modify();
        PartnerId := CMLibrary.CreateTourBookingPartner("NPR CMDistribution"::None, '', '');

        // [GIVEN] A prepaid booking without a payment reference
        CMLibrary.CreateTourBooking(PartnerId, "NPR CMPaymentOption"::Prepaid, Order);
        CMLibrary.AddTourBookingLine(Order, 10000, ItemNo, 1, Today(), Time(), OrderLine);
        Commit();

        // [WHEN/THEN] Prepaid without a payment reference
        asserterror TourBookingMgt.IssueOrder(Order);
        Assert.ExpectedError('before it can be issued');

        // [WHEN/THEN] Paid at pick-up, but for a visit date in the past
        Order.Validate(PaymentOption, Order.PaymentOption::PayAtPickup);
        Order.Modify();
        OrderLine.VisitDate := CalcDate('<-1D>', Today());
        OrderLine.Modify();
        Commit();
        asserterror TourBookingMgt.IssueOrder(Order);
        Assert.ExpectedError('is in the past');

        // [WHEN/THEN] A wallet mail, but no design layout on the partner or in the wallet setup
        OrderLine.VisitDate := Today();
        OrderLine.Modify();
        PartnerSetup.Get(PartnerId);
        PartnerSetup.Distribution := PartnerSetup.Distribution::NPMail;
        PartnerSetup.WalletEmailTemplateId := 'TEST-WALLET';
        PartnerSetup.Modify();
        asserterror TourBookingMgt.IssueOrder(Order);
        Assert.ExpectedError('Attraction Wallet Setup');

        // [WHEN/THEN] A ticket with two admissions is refused when entered on a line
        TwoAdmissionItemNo := TicketLibrary.CreateScenario_SmokeTest();
        AdmissionCode := TicketLibrary.CreateAdmissionCode(TicketLibrary.GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');
        TicketLibrary.CreateTicketBOM(TwoAdmissionItemNo, '', AdmissionCode, '', 1, false, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBOM."Admission Entry Validation"::SINGLE);
        asserterror CMLibrary.AddTourBookingLine(Order, 20000, TwoAdmissionItemNo, 1, Today(), Time(), SecondLine);
        Assert.ExpectedError('Only tickets with one admission are supported');
    end;

    [Test]
    [HandlerFunctions('PickupReviewHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TourBooking_PickupInPos_EndOfSaleConfirmsBooking()
    var
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        PickupB: Codeunit "NPR CMPOSActionTourPickupB";
        Assert: Codeunit Assert;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        PickupLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        Reservation: Record "NPR TM Ticket Reservation Req.";
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] Picking up a Draft booking adds a G/L line per booking line to the sale and locks the booking.
        // Paying and ending the sale confirms it: the receipt becomes its payment reference and its tickets are prepaid.

        // [GIVEN] An issued pay-at-pick-up booking and an open POS sale
        CreatePickupBooking(1, Order);
        StartPosSale(POSSale, POSSaleLine);

        // [WHEN] The booking is picked up by its booking reference
        PickupB.PickupOrder(Order.DocumentNo, POSSale, POSSaleLine);

        // [THEN] Its line is a G/L line in the sale for its one wallet, and the booking is locked
        OrderLine.Get(Order.OrderId, 10000);
        Assert.IsTrue(PickupLine.GetBySystemId(OrderLine.PosSaleLineId), 'Pick-up line in the sale');
        Assert.AreEqual(PickupLine."Line Type"::"GL Payment", PickupLine."Line Type", 'Pick-up line type');
        Assert.AreEqual(1, PickupLine.Quantity, 'Pick-up line quantity');
        Assert.AreEqual("NPR CMOrderLinePickupState"::InPosSale, TourBookingMgt.GetLineState(OrderLine, ReceiptNo), 'Line state in the sale');
        asserterror TourBookingMgt.ReopenOrder(Order);
        Assert.ExpectedError('can no longer be released');

        // [WHEN] The sale is paid and ended
        POSSale.GetCurrentSale(SalePOS);
        PayAndEndSale();

        // [THEN] Confirmed, paid on the receipt, and the tickets are prepaid
        Order.Get(Order.OrderId);
        Assert.AreEqual(Order.Status::Issued, Order.Status, 'Status after the sale');
        Assert.IsTrue(POSEntry.GetBySystemId(SalePOS.SystemId), 'POS entry of the sale');
        Assert.AreEqual(POSEntry."Document No.", Order.PaymentReference, 'Payment reference is the receipt no.');
        GetBookingReservation(Order, Reservation);
        Assert.AreEqual(Reservation."Payment Option"::PREPAID, Reservation."Payment Option", 'Reservation payment option after the sale');
        Assert.AreEqual("NPR CMOrderLinePickupState"::Paid, TourBookingMgt.GetLineState(OrderLine, ReceiptNo), 'Line state after the sale');
    end;

    [Test]
    [HandlerFunctions('PickupReviewHandler,MessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TourBooking_PartialPickup_StaysDraftAndLocked()
    var
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        PickupB: Codeunit "NPR CMPOSActionTourPickupB";
        Assert: Codeunit Assert;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Order: Record "NPR CMOrder";
        FirstLine: Record "NPR CMOrderLine";
        SecondLine: Record "NPR CMOrderLine";
        PickupLine: Record "NPR POS Sale Line";
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] Tickets activate all or nothing. When one of two booking lines is taken out of the sale before
        // payment, the booking stays Draft, the cashier is told, and the booking can neither be reopened nor
        // cancelled, since part of it is paid.

        // [GIVEN] A two-line booking picked up in a POS sale
        CreatePickupBooking(2, Order);
        StartPosSale(POSSale, POSSaleLine);
        PickupB.PickupOrder(Order.DocumentNo, POSSale, POSSaleLine);

        // [GIVEN] The second line is removed from the sale
        SecondLine.Get(Order.OrderId, 20000);
        PickupLine.GetBySystemId(SecondLine.PosSaleLineId);
        Assert.IsTrue(POSSaleLine.SetPosition(PickupLine.GetPosition()), 'Positioned on the second pick-up line');
        POSSaleLine.DeleteLine();

        // [WHEN] The rest is paid and the sale ended
        _LastMessage := '';
        PayAndEndSale();

        // [THEN] Still Draft, and the cashier was told why
        Order.Get(Order.OrderId);
        Assert.AreEqual(Order.Status::Draft, Order.Status, 'Status after a partial pick-up');
        Assert.IsTrue(StrPos(_LastMessage, 'is not fully paid') > 0, 'The cashier is told the booking is not fully paid');

        // [THEN] One line paid, the other open, and the booking locked
        FirstLine.Get(Order.OrderId, 10000);
        SecondLine.Get(Order.OrderId, 20000);
        Assert.AreEqual("NPR CMOrderLinePickupState"::Paid, TourBookingMgt.GetLineState(FirstLine, ReceiptNo), 'Paid line');
        Assert.AreEqual("NPR CMOrderLinePickupState"::Open, TourBookingMgt.GetLineState(SecondLine, ReceiptNo), 'Removed line');
        asserterror TourBookingMgt.ReopenOrder(Order);
        Assert.ExpectedError('can no longer be released');
        asserterror TourBookingMgt.CancelOrder(Order);
        Assert.ExpectedError('can no longer be released');
    end;

    [Test]
    [HandlerFunctions('PickupReviewHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TourBooking_CancelledPosSale_FreesBookingAgain()
    var
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        PickupB: Codeunit "NPR CMPOSActionTourPickupB";
        CancelSale: Codeunit "NPR POSAction: Cancel Sale B";
        Assert: Codeunit Assert;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] Cancelling the POS sale gives the booking back: its line is open again, and the booking can be
        // reopened.

        // [GIVEN] A booking picked up in a POS sale
        CreatePickupBooking(1, Order);
        StartPosSale(POSSale, POSSaleLine);
        PickupB.PickupOrder(Order.DocumentNo, POSSale, POSSaleLine);

        // [WHEN] The sale is cancelled
        Assert.IsTrue(CancelSale.CancelSale(), 'Sale cancelled');

        // [THEN] The line is open again, and the booking can be reopened
        OrderLine.Get(Order.OrderId, 10000);
        Assert.AreEqual("NPR CMOrderLinePickupState"::Open, TourBookingMgt.GetLineState(OrderLine, ReceiptNo), 'Line state after the cancelled sale');
        TourBookingMgt.ReopenOrder(Order);
        Order.Get(Order.OrderId);
        Assert.AreEqual(Order.Status::WIP, Order.Status, 'Status after reopening');
    end;

    [ModalPageHandler]
    procedure PickupReviewHandler(var PickupReview: Page "NPR CMTourBookingPickupReview"; var Response: Action)
    begin
        Response := Action::LookupOK;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        _LastMessage := Message;
    end;

    local procedure CreatePickupBooking(LineCount: Integer; var Order: Record "NPR CMOrder")
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        CMLibrary: Codeunit "NPR Library Channel Manager";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Item: Record Item;
        OrderLine: Record "NPR CMOrderLine";
        PartnerId: Guid;
        ItemNo: Code[20];
        LineIdx: Integer;
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore, _POSPaymentMethod);
        Item.Get(ItemNo);
        LibraryPOSMasterData.CreatePostingSetupForSaleItem(Item, _POSUnit, _POSStore);
        CMLibrary.InitWalletSetup();
        PartnerId := CMLibrary.CreateTourBookingPartner("NPR CMDistribution"::None, '', '');

        CMLibrary.CreateTourBooking(PartnerId, "NPR CMPaymentOption"::PayAtPickup, Order);
        for LineIdx := 1 to LineCount do
            CMLibrary.AddTourBookingLine(Order, LineIdx * 10000, ItemNo, 1, Today(), Time(), OrderLine);
        IssueTourBooking(Order);
    end;

    local procedure StartPosSale(var POSSale: Codeunit "NPR POS Sale"; var POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        _POSSession.GetSaleLine(POSSaleLine);
    end;

    local procedure PayAndEndSale()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        Assert: Codeunit Assert;
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        Subtotal: Decimal;
    begin
        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SaleAmount - PaidAmount, '', false), 'Sale ended');
    end;

    local procedure IssueTourBooking(var Order: Record "NPR CMOrder")
    var
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
    begin
        if (not TourBookingMgt.IssueOrder(Order)) then
            Error('%1', Order.StatusMessage);
        Order.Get(Order.OrderId);
    end;

    local procedure GetBookingReservation(var Order: Record "NPR CMOrder"; var Reservation: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
        Assert: Codeunit Assert;
    begin
        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetFilter("Sales Header No.", '=%1', Order.DocumentNo);
        Assert.IsTrue(Ticket.FindLast(), 'Ticket issued for the booking');
        Reservation.Get(Ticket."Ticket Reservation Entry No.");
    end;

    local procedure CountNotifications(var Order: Record "NPR CMOrder"; NotificationType: Enum "NPR Dig. Notif. Type"): Integer
    var
        NotifEntry: Record "NPR Digital Notification Entry";
    begin
        NotifEntry.SetFilter("Source Document Id", '=%1', Order.OrderId);
        NotifEntry.SetFilter("Notification Type", '=%1', NotificationType);
        exit(NotifEntry.Count());
    end;
    #endregion
}
#endif