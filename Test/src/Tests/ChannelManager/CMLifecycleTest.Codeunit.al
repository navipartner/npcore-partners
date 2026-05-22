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
        OrderIssuer.CreateOrder(Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

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
        OrderIssuer.ReplaceOrder(Order, ParsedOrder, TempOrderLine, TempOrderComponent, TempOrderWallet);

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
        OrderIssuer.CreateOrder(Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

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
        OrderIssuer.ReplaceOrder(Order, ParsedOrder, TempOrderLine, TempOrderComponent, TempOrderWallet);

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
        OrderIssuer.CreateOrder(Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

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
        PartnerSetup.Get(PartnerId);
        asserterror PartnerSetup.Delete(true);
        Assert.ExpectedError('Cannot delete partner');
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
        OrderIssuer.CreateOrder(Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        Order.Get(OrderId);
        Assert.AreEqual(Order.Status::Draft, Order.Status, 'Pre-delete: Status = Draft');

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
        // [SCENARIO] A visit date before the admission schedule's start date has no matching
        // schedule entry, so the TM import worker fails. The CMOrderIssuer should catch the
        // failure, commit Status = Error + StatusMessage, and re-raise. The header row should
        // persist with the error state for the partner to inspect and replace.

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        PartnerId := CMLibrary.CreatePartner();
        CMLibrary.InitWalletSetup();

        // [GIVEN] A draft order with visit date 5 days in the past — no admission schedule there
        CMLibrary.InitOrder(PartnerId, 'TEST-PAST-VISIT', '', Order);
        OrderId := Order.OrderId;
        CMLibrary.AddOrderLine(OrderId, 10000, ItemNo, 1, CalcDate('<-5D>', Today()), Time(), TempOrderLine);
        CMLibrary.AddOrderWallet(OrderId, 10000, 1, TempOrderWallet);

        // [WHEN] CreateOrder is called — worker errors out
        asserterror OrderIssuer.CreateOrder(Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        // [THEN] Order header committed with Error status + StatusMessage
        Assert.IsTrue(Order.Get(OrderId), 'Header committed despite worker failure');
        Assert.AreEqual(Order.Status::Error, Order.Status, 'Status = Error');
        Assert.AreNotEqual('', Order.StatusMessage, 'StatusMessage populated with worker error text');

        // [THEN] No JobId persisted (worker cleaned up its import buffers before re-raising)
        Assert.AreEqual('', Order.JobId, 'JobId not set after failure');
    end;
}
#endif