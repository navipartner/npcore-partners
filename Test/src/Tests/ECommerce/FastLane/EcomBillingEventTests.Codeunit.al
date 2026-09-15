#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85420 "NPR Ecom Billing Event Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    // [FEATURE] Ecommerce Billing Events - COUNT on order import and AMOUNT on capture

    var
        _Assert: Codeunit Assert;
        _LibraryEntria: Codeunit "NPR Library - Entria";
        _LibPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        _LibSales: Codeunit "Library - Sales";
        _LibInventory: Codeunit "Library - Inventory";
        _Initialized: Boolean;
        _StoreCode: Code[20];
        _StoreCodeLbl: Label 'TIV', Locked = true;

    [Test]
    procedure IntakeRegistersExactlyOneCountEvent()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] A goods-only Entria order tendered at 100 is imported. The intake must leave one order event row
        //            for the order, and that order event row IS the order's one COUNT event.

        // [GIVEN] An enabled Entria store and a paid order of 100 created at 09:00 on 1 March 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(1, 3, 2024), 090000T);
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-BILL-COUNT', 'medusa-bill-count', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-BILL-COUNT');

        // [WHEN] The order is imported
        ImportPrebuiltOrder('ZZ-BILL-COUNT', OrdersArr, EcomSalesHeader);

        // [THEN] The intake leaves exactly one order event row keyed by the Entria channel, the store and the
        //        order's "External No." - the display id the payload carries as "custom_display_id", not the
        //        Medusa order id, which the import stores separately as "External Document Id"
        _Assert.IsTrue(GetOrderEvent(EcomBillingEvent, 'ZZ-BILL-COUNT'),
            'The intake must leave an order event row keyed by channel, store code and "External No." - without it neither amount wave can find the order, so the order is silently never amount-billed.');

        // [THEN] The order event row is itself the COUNT event with quantity 1
        _Assert.AreEqual(1, EcomBillingEvent.Amount, 'The COUNT event must carry a quantity of 1 - one row billed per imported order.');
        _Assert.AreEqual(1, CountBillingEventRowsForStore(),
            'The intake must leave exactly ONE row for the order. Together with the zero amount rows asserted below, that is what says the order event and the count event are one and the same row rather than two.');

        // [THEN] Exactly one billing queue entry carries the order event row's own system id as its event id
        AssertSingleQueueEntry(EcomBillingEvent.SystemId, Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT, 1);
        AssertEventIsQueued(EcomBillingEvent,
            'The count event row must be linked to its queue entry - the link is what tells a reader that the event was really queued and not left behind by a suppressed failure.');

        // [THEN] No amount child row exists yet - only the capture and posting waves may create those
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-COUNT');
        _Assert.AreEqual(0, EcomBillingEvent.Count(),
            'Intake must not bill any amount - the amount is billed by the capture and posting waves, so an amount child row here would silently lower the delta they may still register.');
    end;

    [Test]
    procedure ReimportAfterDeleteChangesNothing()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        FirstOrderEventEntryNo: BigInteger;
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] An Entria order is imported and partly billed, its ecommerce document is deleted, and the
        //            order is imported again. The order event is insert-only: a reimport must not touch it, not add
        //            a second one, and not register a second COUNT event or a second amount event.

        // [GIVEN] An enabled Entria store and a paid order of 100 created at 09:00 on 2 March 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(2, 3, 2024), 090000T);
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-BILL-REIMP', 'medusa-bill-reimp', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-BILL-REIMP');

        // [GIVEN] The order has been imported once, and its order event row is known
        ImportPrebuiltOrder('ZZ-BILL-REIMP', OrdersArr, EcomSalesHeader);
        _Assert.IsTrue(GetOrderEvent(EcomBillingEvent, 'ZZ-BILL-REIMP'), 'Setup: the first import must have left an order event row.');
        FirstOrderEventEntryNo := EcomBillingEvent."Entry No.";

        // [GIVEN] 30 of the tender has been captured and billed, so there is something for a reimport to wrongly reset
        SetCapturedAmount(EcomSalesHeader, 30);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-REIMP');
        _Assert.AreEqual(1, EcomBillingEvent.Count(), 'Setup: the capture wave must have billed 30 before the delete, otherwise the carry-forward assertion below cannot fail.');
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [GIVEN] The ecommerce document is deleted, so the reimport creates a brand new document
        EcomSalesHeader.Delete(true);

        // [WHEN] The order is imported again
        Clear(OrdersArr);
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-BILL-REIMP', 'medusa-bill-reimp', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-BILL-REIMP');
        ImportPrebuiltOrder('ZZ-BILL-REIMP', OrdersArr, EcomSalesHeader);

        // [THEN] There is still exactly one order event row, still the original one
        _Assert.AreEqual(1, CountOrderEvents('ZZ-BILL-REIMP'),
            'A reimport of the same Medusa order must not add a second order event row - two order events for one order would let the order be amount-billed twice.');
        _Assert.IsTrue(GetOrderEvent(EcomBillingEvent, 'ZZ-BILL-REIMP'), 'The order event row must still be there after the reimport.');
        _Assert.AreEqual(FirstOrderEventEntryNo, EcomBillingEvent."Entry No.",
            'The reimport must not touch the order event row at all - the order event is insert-only, and a reimport reaching it after a delete is exactly the case that design exists for.');

        // [THEN] Still exactly one COUNT event, and no new queue entry was made by the reimport
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-REIMP', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT);
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'The reimport must not register any billing event - a new one here would either duplicate the COUNT event or re-bill an amount that was already queued once.');

        // [THEN] The 30 already billed before the delete is still there, untouched by the reimport
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-REIMP');
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'The reimport must not touch amount child rows either - a reimport is not a wave and must add or remove nothing beyond the order event row itself.');
        EcomBillingEvent.FindFirst();
        _Assert.AreEqual(30, EcomBillingEvent.Amount,
            'The amount already billed before the delete must survive the reimport unchanged - a reimport is not a wave and never touches amount rows.');
    end;

    [Test]
    procedure PostingWaveBillsOnceAndReplayBillsNothing()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] An Entria order of 100 is captured in full at posting time, and RegisterCapturedAmount then
        //            runs twice - the ordinary outcome of a repost or a replayed call. The amount must be billed
        //            once. Both the capture wave and the posting-time Sales-Post subscriber now go through
        //            RegisterCapturedAmount, so this is what "posting wave" means in the unified design.

        // [GIVEN] An Entria order document tendered at 100 with 100 captured, registered at intake
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-POST', 'medusa-bill-post');
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        EcomBillingMgt.RegisterOrderImported(EcomSalesHeader);

        // [WHEN] RegisterCapturedAmount runs, and then runs a second time on the same document
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        QueueBaselineEntryNo := LastBillingQueueEntryNo();
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Exactly one amount event was registered, for the whole captured amount
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-POST');
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'RegisterCapturedAmount must register exactly one amount event for a stable captured total - a second event for the same order charges the merchant twice for one sale.');
        EcomBillingEvent.FindFirst();
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'The single amount event must carry the whole captured amount, because nothing had been billed before the first call ran.');
        AssertSingleQueueEntry(EcomBillingEvent.SystemId, Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP, 100);
        AssertEventIsQueued(EcomBillingEvent,
            'A queued event must carry the queue entry number - a zero there is exactly how a suppressed registration failure is recognised, so a zero on a successful path would make that signal useless.');

        // [THEN] The second, replayed call added nothing at all
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'A replayed call must register no further billing event - the delta is zero once the captured total is fully billed, and that is the ordinary outcome of a repost.');
    end;

    [Test]
    procedure CaptureAndPostingWavesSumToOrderAmount()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        FirstAmount: Decimal;
        SecondAmount: Decimal;
    begin
        // [SCENARIO] An Entria order of 100 has 30 captured fast-lane, then a further 70 captured at posting time.
        //            Both phases now call RegisterCapturedAmount over the same monotone "Captured Payment Amount"
        //            base. The core invariant: the two calls together bill exactly the final captured total, one
        //            row per delta.

        // [GIVEN] An Entria order tendered at 100 of which 30 has been captured fast-lane, registered at intake
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-TWOWAVE', 'medusa-bill-twowave');
        PlantPaymentLine(EcomSalesHeader, 100, 30);
        EcomBillingMgt.RegisterOrderImported(EcomSalesHeader);

        // [WHEN] The capture wave runs for the captured 30
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [WHEN] The posting-time gateway capture raises "Captured Amount" to the full 100, and the Sales-Post
        //        subscriber (which also goes through RegisterCapturedAmount) runs
        SetCapturedAmount(EcomSalesHeader, 100);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Two amount events were registered: the captured 30 first, then the further 70 captured at posting
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-TWOWAVE');
        _Assert.AreEqual(2, EcomBillingEvent.Count(),
            'The two calls must register exactly two amount events - one per delta that had something new to bill.');
        EcomBillingEvent.FindSet();
        FirstAmount := EcomBillingEvent.Amount;
        _Assert.AreEqual(30, FirstAmount, 'The first call must bill only the fast-lane captured part, not the whole tender.');
        AssertSingleQueueEntry(EcomBillingEvent.SystemId, Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP, 30);
        EcomBillingEvent.Next();
        SecondAmount := EcomBillingEvent.Amount;
        _Assert.AreEqual(70, SecondAmount, 'The posting-time call must bill only the 70 that the gateway captured on top of the first 30.');
        AssertSingleQueueEntry(EcomBillingEvent.SystemId, Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP, 70);

        // [THEN] The two amounts sum to the final "Captured Payment Amount" - the merchant is charged for the
        //        order once, in parts
        _Assert.AreEqual(100, FirstAmount + SecondAmount,
            'The amounts billed by both calls must sum to the final captured total - a sum above it over-charges the merchant and a sum below it under-charges NaviPartner.');

        // [THEN] Still exactly one count event after three registrations touched the same order
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-TWOWAVE', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT);
    end;

    [Test]
    procedure ReturnOrderIsNeverBilled()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] An Entria return order goes through intake registration and through the capture wave. It must
        //            produce no order event row and no billing event of any kind: returns are never billed and never
        //            credited.

        // [GIVEN] An Entria return order carrying a POSITIVE tender of 100. The positive sign is deliberate: the
        // capture flow maps a return order to a refund while keeping "Payment Amount" positive, so the amount is
        // exactly as billable-looking as an order's - the document type guard is the only thing stopping it.
        // "Document Source" is set to Entria on purpose as well, so the channel guard cannot make this test pass
        // for the wrong reason before the document type guard is even reached.
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::"Return Order", 'ZZ-BILL-RETURN', 'medusa-bill-return');
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [WHEN] Intake registration and the capture wave both run on the return order
        EcomBillingMgt.RegisterOrderImported(EcomSalesHeader);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] No order event row was created for the store at all
        _Assert.AreEqual(0, CountOrderEvents('ZZ-BILL-RETURN'),
            'A return order must leave no order event row - a row would make the return look like a billable order to every later wave.');

        // [THEN] No billing event row of any kind was recorded for the store
        _Assert.AreEqual(0, CountBillingEventRowsForStore(),
            'A return order must produce no billing event row - neither the count event nor an amount event, because returns are never billed and never credited.');

        // [THEN] No ecommerce order billing queue entry was registered after the baseline
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'A return order must register nothing in the billing queue - a queued event here would be forwarded to the billing API and charge the merchant for a refund.');
    end;

    [Test]
    procedure ShrunkenTenderRegistersNoNegativeAmount()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] An Entria order of 100 has already been billed in full, and the amount now captured on the
        //            document is only 50 - the tender shrank below what was billed. The delta is negative and
        //            must never be registered.

        // [GIVEN] An Entria order whose tender of 100 is now captured for only 50
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-SHRUNK', 'medusa-bill-shrunk');
        PlantPaymentLine(EcomSalesHeader, 100, 50);

        // [GIVEN] Its order event exists and 100 has already been billed for it, through a queued amount child row of
        // 100. Progress is derived from queued child rows, so the already-billed state has to be a real queued row.
        PlantOrderEvent(OrderEvent, EcomSalesHeader);
        PlantAmountEvent(OrderEvent, 100, true);
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [WHEN] The capture wave runs against the shrunken captured amount
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] No amount event was queued
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'A tender that shrank below the amount already billed must register no billing event - a negative quantity in the billing queue would be forwarded to the billing API as a credit nobody authorised.');

        // [THEN] No new amount event row was recorded either - only the one planted before the wave ran
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-SHRUNK');
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'A negative delta must leave no new billing event row - a tender that shrank below what was already billed is not an anomaly to record, it is simply nothing new to bill, and the engine exits silently on it.');
    end;

    [Test]
    procedure WavesBillNothingWithoutAnOrderEvent()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] An Entria order that has no order event row is captured. RegisterCapturedAmount must not
        //            create the order event and must not bill anything: the order event is the intake's to write,
        //            and billing without one has no identity to hang events on.

        // [GIVEN] An Entria order tendered at 100 and captured for 30, never registered by the intake
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-NOLOG', 'medusa-bill-nolog');
        PlantPaymentLine(EcomSalesHeader, 100, 30);
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [WHEN] RegisterCapturedAmount runs (reached from both the capture wave and the posting-time subscriber)
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] No order event row was created by the wave
        _Assert.AreEqual(0, CountOrderEvents('ZZ-BILL-NOLOG'),
            'A wave must never create the order event row - creating one here would let the wave decide what an order may be billed, which is the intake''s job alone.');

        // [THEN] Nothing was billed and nothing was counted
        _Assert.AreEqual(0, CountBillingEventRowsForStore(),
            'Without an order event row there is nothing to hang an event on, so no billing event row may be written.');
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'An order with no order event row must register nothing at all - RegisterCapturedAmount reports the gap to Sentry instead, so the missing row gets fixed rather than worked around.');
    end;

    [Test]
    procedure UnqueuedAmountRowIsNotProgress()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
    begin
        // [SCENARIO] Progress is derived from queued amount rows only. A row carrying "Billing Queue Entry No." = 0
        //            must not count as progress, so a wave running afterwards must still bill the FULL delta - not
        //            the order amount minus the unqueued row. That is what lets such a row self-heal instead of
        //            silently under-billing forever.

        // [GIVEN] An Entria order of 100 whose order event is registered, tendered at 100 with all 100 captured,
        // but with a 40 amount row left unqueued. The current production chain cannot produce this state: the
        // engine runs inside EcomBillingMgt.RegisterAmountEvent's Codeunit.Run, so a failure anywhere rolls the
        // insert back with it and no row survives. The row is planted directly, and the invariant is kept as
        // defence in depth - for rows left behind by the pre-Codeunit.Run design, and for any future caller that
        // reaches RegisterCapturedAmount outside that boundary.
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-UNQUEUED', 'medusa-bill-unqueued');
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);
        PlantAmountEvent(OrderEvent, 40, false);

        // [WHEN] RegisterCapturedAmount runs
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] The planted unqueued row and the wave's new row both exist - the wave must add a row, not reuse
        // or repair the unqueued one
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-UNQUEUED');
        _Assert.AreEqual(2, EcomBillingEvent.Count(),
            'The wave must add a new amount row rather than reuse the unqueued one it found. The unqueued row was never charged - no billing queue entry carries its event id - so it is worth nothing and the delta has to be registered afresh.');

        // [THEN] The wave's new row carries the FULL 100, not 60 - if the unqueued 40 had counted as progress
        // already made, this row would carry only 60 and the merchant would be silently under-billed
        EcomBillingEvent.SetRange(Amount, 100);
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'The wave must register the FULL captured amount of 100 - an unqueued row must never be counted as progress, or the merchant is silently under-billed by exactly what that row carries.');
        EcomBillingEvent.FindFirst();
        AssertEventIsQueued(EcomBillingEvent,
            'The wave''s new row must be queued - a queued row is what makes it count as progress for any wave that runs after this one.');

        // [THEN] The planted unqueued row is still there, exactly as planted
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-UNQUEUED');
        EcomBillingEvent.SetRange(Amount, 40);
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'The unqueued row must be left exactly as planted - the wave repairs an unqueued row only when a billing queue entry proves it was charged, and nothing charged this one.');
        EcomBillingEvent.FindFirst();
        AssertEventIsNotQueued(EcomBillingEvent,
            'A row nothing charged must stay unqueued - linking it would count it as progress and silently under-bill the order by exactly what it carries.');
    end;

    [Test]
    procedure ChargedButUnlinkedAmountRowCountsAsProgress()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        ChargedQueueEntryNo: BigInteger;
        BilledTotal: Decimal;
    begin
        // [SCENARIO] "Unqueued" and "not charged" are not the same thing. The transport creates the billing queue
        //            entry and the entry number is written back afterwards, so an amount row can be charged and
        //            still read as unqueued. A later wave must find that out before it computes a delta, or it
        //            would register the same amount again on a fresh row with a fresh event id, which the transport
        //            cannot recognise as a duplicate: a double charge.
        //
        //            The split is no longer reachable through the production chain - both writes sit inside the
        //            same Codeunit.Run, so a failure between them rolls back both - but the repair path exists for
        //            rows already left behind, and this is what proves it reads them as charged rather than new.

        // [GIVEN] An Entria order of 100 with 30 captured and billed, so one amount row exists and is queued
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(5, 3, 2024), 090000T);
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-BILL-CHARGED', 'medusa-bill-charged', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-BILL-CHARGED');
        ImportPrebuiltOrder('ZZ-BILL-CHARGED', OrdersArr, EcomSalesHeader);
        SetCapturedAmount(EcomSalesHeader, 30);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [GIVEN] Its queue entry number is cleared, which is the charged-but-unlinked state: the billing queue
        // entry is still there and will still be charged, only this row no longer names it
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-CHARGED');
        _Assert.AreEqual(1, EcomBillingEvent.Count(), 'Setup: the capture wave must have left exactly one amount row.');
        EcomBillingEvent.FindFirst();
        ChargedQueueEntryNo := EcomBillingEvent."Billing Queue Entry No.";
        AssertEventIsQueued(EcomBillingEvent, 'Setup: the capture wave must have queued its amount row, otherwise this scenario is not reachable.');
        EcomBillingEvent."Billing Queue Entry No." := 0;
        EcomBillingEvent.Modify();

        // [WHEN] The posting-time gateway capture raises "Captured Amount" to the full 100 and
        //        RegisterCapturedAmount runs from the Sales-Post subscriber
        SetCapturedAmount(EcomSalesHeader, 100);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] It billed only the remaining 70, because the charged row was recognised as progress despite
        // carrying no queue entry number
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-CHARGED');
        EcomBillingEvent.SetRange(Amount, 70);
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'The posting-time call must bill only the remaining 70. Reading the charged row as unbilled would make it bill 100, so the merchant would be charged 130 for an order of 100 - and the transport could not absorb it, because the second row carries a different event id.');

        // [THEN] The charged row was repaired: it names its billing queue entry again, the same one as before
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-CHARGED');
        EcomBillingEvent.SetRange(Amount, 30);
        EcomBillingEvent.FindFirst();
        _Assert.AreEqual(ChargedQueueEntryNo, EcomBillingEvent."Billing Queue Entry No.",
            'The charged row must be linked back to the very queue entry that carries its event id - writing any other number would point the audit trail at another feature''s charge.');

        // [THEN] The amounts billed for the order still sum to the order amount exactly
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-CHARGED');
        EcomBillingEvent.CalcSums(Amount);
        BilledTotal := EcomBillingEvent.Amount;
        _Assert.AreEqual(100, BilledTotal,
            'Every amount row of the order together must equal the order amount - that sum is what the merchant is charged, and it may never exceed what the order was worth.');
    end;

    [Test]
    procedure IncrementalCapturesAndPostingSumToOrderAmount()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        BilledTotal: Decimal;
    begin
        // [SCENARIO] An order of 100 is captured in three stages - 30, then 60 in total, then the full 100 at
        //            posting. Every call goes through RegisterCapturedAmount over the same monotone
        //            "Captured Payment Amount" base. Each call may bill only what is new, and the amounts must
        //            sum to the final captured total exactly.

        // [GIVEN] An imported Entria order of 100
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(6, 3, 2024), 090000T);
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-BILL-INCR', 'medusa-bill-incr', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-BILL-INCR');
        ImportPrebuiltOrder('ZZ-BILL-INCR', OrdersArr, EcomSalesHeader);

        // [WHEN] 30 is captured, the capture grows to 60, then the invoice posts and the gateway captures the last 40
        SetCapturedAmount(EcomSalesHeader, 30);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        SetCapturedAmount(EcomSalesHeader, 60);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        SetCapturedAmount(EcomSalesHeader, 100);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Three amount events: 30, then only the new 30, then the remaining 40
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-INCR');
        _Assert.AreEqual(3, EcomBillingEvent.Count(),
            'Each call that had something new to bill must register exactly one amount event. A second capture that re-billed its whole captured total, or one that billed nothing at all, would not give three.');
        EcomBillingEvent.FindSet();
        _Assert.AreEqual(30, EcomBillingEvent.Amount, 'The first capture must bill the 30 it captured.');
        EcomBillingEvent.Next();
        _Assert.AreEqual(30, EcomBillingEvent.Amount,
            'The second capture must bill only the 30 that is new. Billing 60 again would charge the first 30 twice.');
        EcomBillingEvent.Next();
        _Assert.AreEqual(40, EcomBillingEvent.Amount, 'The posting-time call must bill only the 40 still remaining.');

        // [THEN] The three amounts sum to the final captured total exactly
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-INCR');
        EcomBillingEvent.CalcSums(Amount);
        BilledTotal := EcomBillingEvent.Amount;
        _Assert.AreEqual(100, BilledTotal,
            'Everything billed for the order must sum to the final "Captured Payment Amount" - never more, and never less.');
    end;

    [Test]
    procedure SuccessfulCaptureAtPostingRegistersCapturedAmount()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
    begin
        // [SCENARIO] The posting-time subscriber runs the engine on an order whose gateway capture at posting just
        //            wrote "Captured Amount" for the whole tender. Exactly one amount event must be registered for
        //            the captured amount. This calls RegisterCapturedAmount directly, which is the tail of the
        //            production chain MagentoPmtMgt.Cu80OnAfterPostSalesInvoice -> RegisterEcomBillingAfterCapture
        //            -> EcomBillingMgt.RegisterAmountEvent -> Commit + Codeunit.Run -> RegisterCapturedAmount, for
        //            an order that never went through a fast-lane capture. The commit and the run boundary are not
        //            exercised here; PostingThroughSalesPostBillsTheCapturedAmount drives the whole chain.

        // [GIVEN] An Entria order of 100 with all 100 captured, order event already registered by intake
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-POSTCAP', 'medusa-bill-postcap');
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);

        // [WHEN] RegisterCapturedAmount runs
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Exactly one amount event was registered for the captured 100
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-POSTCAP');
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'The posting-time call must register exactly one amount event when the gateway captured the full tender.');
        EcomBillingEvent.FindFirst();
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'The amount event must carry the newly captured amount - anything else charges the merchant for a sum they did not collect.');
        AssertEventIsQueued(EcomBillingEvent,
            'The registered event must be linked to its queue entry - a zero would look like a suppressed failure to any wave that runs after this one.');
    end;

    [Test]
    procedure FailedCaptureRegistersNothing()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] The posting-time subscriber runs RegisterCapturedAmount on an order whose capture failed at
        //            posting - the payment line exists but "Captured Amount" is zero. Nothing must be billed:
        //            capture failure means the money never moved.

        // [GIVEN] An Entria order of 100 with 0 captured, order event already registered by intake
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-CAPFAIL', 'medusa-bill-capfail');
        PlantPaymentLine(EcomSalesHeader, 100, 0);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [WHEN] RegisterCapturedAmount runs
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] No amount event was queued - the guiding principle is that we bill what BC recorded as captured
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'A capture that never wrote back to "Captured Amount" must register no billing event - the money never moved, and billing here would charge the merchant for a sale the customer was not charged for.');

        // [THEN] And no amount row either. Asserting only the queue would let an inserted-but-unqueued row pass,
        //        and such a row is invisible to progress, so the next wave would re-register the same delta.
        _Assert.AreEqual(0, CountAmountEvents('ZZ-BILL-CAPFAIL'),
            'A failed capture must leave no amount row at all - an unqueued row is not counted as progress, so leaving one behind means the next wave registers the same amount again on a fresh row.');

        // [THEN] Positive control on the same document. Every assertion above is an absence, so a silent
        //        short-circuit on the very first statement of the engine would satisfy them all. Raising the
        //        captured amount and getting a row proves the engine was alive and reached the delta while
        //        billing nothing on the zero-delta branch above.
        SetCapturedAmount(EcomSalesHeader, 100);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-CAPFAIL', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'Control: once the capture really wrote back, the same engine on the same document must bill the whole 100 - if this fails, the zero-capture assertions above proved nothing because the engine was never reaching the delta.');
    end;

    [Test]
    procedure TwoPartialInvoicesSumToCapturedTotal()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        BilledTotal: Decimal;
    begin
        // [SCENARIO] A mixed order posts in two invoices - virtual items first (say 40 captured), physical goods
        //            later (further 60 captured). Both invoices reach RegisterCapturedAmount from Sales-Post, each
        //            seeing the cumulative "Captured Payment Amount" at its point in time. Each call registers
        //            only its delta and the two must sum to the final captured total.

        // [GIVEN] An Entria order of 100, order event registered, first partial capture of 40 recorded
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-TWOPART', 'medusa-bill-twopart');
        PlantPaymentLine(EcomSalesHeader, 100, 40);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);

        // [WHEN] The first invoice posts and RegisterCapturedAmount runs
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [WHEN] The second invoice posts, further gateway capture raises "Captured Amount" to 100, and
        //        RegisterCapturedAmount runs again
        SetCapturedAmount(EcomSalesHeader, 100);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Two amount events were registered: 40, then 60
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-TWOPART');
        _Assert.AreEqual(2, EcomBillingEvent.Count(),
            'Two partial invoices posting for the same order must each register one amount event over their delta of the cumulative captured total.');
        EcomBillingEvent.FindSet();
        _Assert.AreEqual(40, EcomBillingEvent.Amount, 'The first invoice''s call must bill only its 40.');
        EcomBillingEvent.Next();
        _Assert.AreEqual(60, EcomBillingEvent.Amount, 'The second invoice''s call must bill only its own 60, not the whole cumulative 100.');

        // [THEN] The two deltas sum to the final "Captured Payment Amount"
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-TWOPART');
        EcomBillingEvent.CalcSums(Amount);
        BilledTotal := EcomBillingEvent.Amount;
        _Assert.AreEqual(100, BilledTotal,
            'The sum of the deltas registered by both partial invoices must equal the final captured total exactly.');
    end;

    [Test]
    procedure Matrix_VIOnly_AllTendersFastLaneCapturesPrePost()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
    begin
        // [SCENARIO] VI-only order (Ticket / Membership / Voucher-item / Coupon), any tender (card / voucher / mixed).
        //            In production, the fast lane runs BEFORE any posting and captures the full tender. When the
        //            posting-time subscriber runs later on the VI invoice, "Captured Amount" is unchanged, so the
        //            delta is zero and no further event is queued. The unit-level shape: plant CapturedAmount = full
        //            up front, then run RegisterCapturedAmount twice - once for the fast-lane wave, once for the
        //            posting-time hook - and assert that only the first call bills, and the second bills nothing.

        // [GIVEN] A VI-only Entria order of 100 whose fast lane already captured the whole tender pre-post
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-VIONLY', 'medusa-bill-vionly');
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader.Modify();
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);

        // [WHEN] The fast-lane wave runs first
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Exactly one amount event was queued for the whole captured 100
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-VIONLY', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'The fast-lane wave on a VI-only order must bill the whole tender pre-post - anything less leaves the posting hook to pick up the rest and defeats the pre-post design.');
        AssertEventIsQueued(EcomBillingEvent,
            'The fast-lane event must be queued - it is what the posting hook reads as progress a moment later.');

        // [WHEN] The posting-time subscriber runs afterwards - CapturedAmount is unchanged
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Still exactly one amount event: the posting hook read delta = 0 and queued nothing
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-VIONLY');
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'The posting-time hook on a VI-only order must read delta = 0 - the fast lane already got everything - and queue nothing, or the merchant is billed twice for one sale.');
    end;

    [Test]
    procedure Matrix_RegularOnly_AllTendersCaptureAtPosting()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] Regular-only order (no virtual items), any tender. "Virtual Items Exist" = false means the
        //            auto-post gate skips - the fast lane never fires - so a first RegisterCapturedAmount call
        //            (representing the fast-lane wave that would never run in reality) sees CapturedAmount = 0 and
        //            bills nothing. Later, operator or JQ posts the invoice, the gateway writes back "Captured
        //            Amount", and the Sales-Post subscriber runs RegisterCapturedAmount for the first real time,
        //            billing the whole captured amount as a delta from zero.

        // [GIVEN] A regular-only Entria order of 100 with no capture yet
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-REGONLY', 'medusa-bill-regonly');
        EcomSalesHeader."Virtual Items Exist" := false;
        EcomSalesHeader.Modify();
        PlantPaymentLine(EcomSalesHeader, 100, 0);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [WHEN] The fast-lane wave would run (in reality it never does for regular-only) - CapturedAmount is zero
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] No amount event queued - delta over zero captured is zero
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'A regular-only order with nothing captured must queue no billing event - there is no money for the fast lane to bill, and running through the wave anyway must never invent one.');
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-REGONLY');
        _Assert.AreEqual(0, EcomBillingEvent.Count(),
            'A regular-only order with nothing captured must leave no amount row - the row is what a later wave would read as progress and use to under-bill by exactly that amount.');

        // [GIVEN] The invoice posts later and the gateway writes back the whole captured amount
        SetCapturedAmount(EcomSalesHeader, 100);

        // [WHEN] The posting-time Sales-Post subscriber runs RegisterCapturedAmount for the first real time
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Exactly one amount event was queued for the whole captured 100 - the posting-time hook is the sole trigger
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-REGONLY', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'The posting-time call on a regular-only order must bill the whole captured amount - nothing was billed before, so the delta is the whole capture.');
        AssertEventIsQueued(EcomBillingEvent,
            'The posting-time event must be queued - without a queue entry no charge is made and the whole sale is silently unbilled.');
    end;

    [Test]
    procedure Matrix_MixedCard_FastLaneCapturesFullPostingHookReadsDeltaZero()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
    begin
        // [SCENARIO] Mixed VI + regular goods, card tender. Whatever a wave captured, a later wave that finds the
        //            captured total unchanged must read delta = 0 and queue nothing on top of the first event.
        //            The subject here is the engine's delta arithmetic, not how much the fast lane captures: the
        //            captured total is planted at its final value and the engine is then run twice.
        //
        //            Do not read this as "the fast lane captures the whole card tender". It does not:
        //            EcomCaptureImpl.CalculateAmountToCapture sums only virtual-item and attraction-wallet lines,
        //            and EcomCaptureImpl caps the gateway line at min(that, payment line amount) - so for 100 VI
        //            + 50 goods the fast lane records 100, and the goods remainder is captured at posting.

        // [GIVEN] A mixed Entria order tendered on card at 150, with the full 150 already recorded as captured
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-MIXCARD', 'medusa-bill-mixcard');
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader.Modify();
        PlantPaymentLine(EcomSalesHeader, 150, 150);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);

        // [WHEN] The first wave runs over the captured total
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Exactly one amount event was queued for the whole 150 - the engine bills the aggregate captured total
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-MIXCARD', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(150, EcomBillingEvent.Amount,
            'The first wave must bill the whole captured total - the engine reads "Captured Payment Amount" and never splits it by what the tender was made of.');
        AssertEventIsQueued(EcomBillingEvent,
            'The first event must be queued - the wave that follows reads it as progress a moment later.');

        // [WHEN] A later wave runs and the captured total has not moved
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Still exactly one amount event - the second wave read delta = 0 and queued nothing new
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-MIXCARD');
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            'A wave that finds the captured total unchanged must read delta = 0 - otherwise the merchant is billed a second time for the same sale.');
    end;

    [Test]
    procedure Matrix_MixedVoucher_AutoPostFailsButFastLaneCapturedVoucher()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
    begin
        // [SCENARIO] Mixed VI + goods, voucher tender. The fast lane fires because VI exists and captures the voucher
        //            tender pre-post. Auto-post attempts partial posting (VI lines only) but
        //            CheckIfTotalPaymentWhenVoucherInUse raises "Partial posting is not allowed when vouchers are in
        //            use". EcomSalesDocPost.Run swallows that error via Codeunit.Run at EcomSalesDocImplV2:1484, the
        //            sales order is left unposted, and the posting-time subscriber never fires. Billing was already
        //            registered by the fast-lane wave BEFORE the failed auto-post attempt: billing follows capture,
        //            not posting outcome.

        // [GIVEN] A mixed Entria order tendered on voucher at 100 whose fast lane captured the whole voucher pre-post
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-MIXVCH', 'medusa-bill-mixvch');
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader.Modify();
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);

        // [WHEN] The fast-lane wave runs - the failed auto-post that follows in production never gets to run
        //        RegisterCapturedAmount again, so this one call models the whole billing story for the order
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Exactly one amount event was queued for the voucher tender - billing followed what was captured, not
        //        the later posting outcome
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-MIXVCH', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'The fast-lane wave must bill what was captured - CheckIfTotalPaymentWhenVoucherInUse failing auto-post afterwards must not roll billing back, because the voucher was really captured.');
        AssertEventIsQueued(EcomBillingEvent,
            'The captured voucher must be queued for billing - even when the following auto-post attempt fails, because the voucher was really redeemed.');
        _Assert.AreEqual(1, CountAmountEvents('ZZ-BILL-MIXVCH'),
            'The total AMOUNT_SHOP event count for the order must be one - the posting hook never fires when auto-post is swallowed by Codeunit.Run, and no other path may bill the same sale a second time.');
    end;

    [Test]
    procedure Matrix_MixedCard_PartialGoodsPostingsBillNothingAdditional()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
    begin
        // [SCENARIO] Continuation of the mixed + card matrix cell. Once the captured total stops moving, every
        //            further wave must read delta = 0 and queue nothing, however many of them run - the goods lines
        //            can post in one or several partial invoices, each firing the Sales-Post subscriber. This test
        //            runs the engine four times over an unchanged captured total and asserts only the first bills.
        //            As in the sibling test, the captured total is planted at its final value; how much of it the
        //            fast lane versus the posting capture contributed is not the subject here.

        // [GIVEN] A mixed Entria order tendered on card at 150, with the full 150 already recorded as captured
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-PARTGDS', 'medusa-bill-partgds');
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader.Modify();
        PlantPaymentLine(EcomSalesHeader, 150, 150);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);

        // [WHEN] Four waves run in a row over the same captured total
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Exactly one amount event exists for the order - the first wave billed and every later one read
        //        delta = 0 and queued nothing
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-PARTGDS', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(150, EcomBillingEvent.Amount,
            'The one event must carry the whole captured 150 - the first wave billed it, at the start.');
        AssertEventIsQueued(EcomBillingEvent,
            'The first event must be queued - it is what makes every later wave read delta = 0 rather than re-bill.');
        _Assert.AreEqual(1, CountAmountEvents('ZZ-BILL-PARTGDS'),
            'The total AMOUNT_SHOP event count for the order must be one across all four waves - a second event would double-bill the sale, because the captured total never grew.');
    end;

    [Test]
    procedure Matrix_TenderShapeIsInvariantToBilling()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        OrderEventA: Record "NPR Ecom Billing Event";
        OrderEventB: Record "NPR Ecom Billing Event";
        OrderEventC: Record "NPR Ecom Billing Event";
        EcomSalesHeaderA: Record "NPR Ecom Sales Header";
        EcomSalesHeaderB: Record "NPR Ecom Sales Header";
        EcomSalesHeaderC: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
    begin
        // [SCENARIO] The billing engine reads only the aggregate "Captured Payment Amount" FlowField. Tender shape
        //            (single card, single voucher, or two lines summing to the same total) is invisible to it.
        //            Three orders with the same captured total of 100 must each produce one amount event of 100.
        //            This test would fail if the engine ever became tender-aware or read individual payment lines.

        Initialize();

        // [GIVEN] Sub-A: card-only tender - one payment line of 100 captured for 100
        PlantEntriaEcomDocument(EcomSalesHeaderA, EcomSalesHeaderA."Document Type"::Order, 'ZZ-BILL-TIV-A', 'medusa-bill-tiv-a');
        PlantPaymentLine(EcomSalesHeaderA, 100, 100);
        PlantOrderEvent(OrderEventA, EcomSalesHeaderA);

        // [GIVEN] Sub-B: voucher-only tender - one payment line of 100 captured for 100. At unit level the billing
        //         engine does not read a tender-type field, so one planted payment line represents any single tender.
        PlantEntriaEcomDocument(EcomSalesHeaderB, EcomSalesHeaderB."Document Type"::Order, 'ZZ-BILL-TIV-B', 'medusa-bill-tiv-b');
        PlantPaymentLine(EcomSalesHeaderB, 100, 100);
        PlantOrderEvent(OrderEventB, EcomSalesHeaderB);

        // [GIVEN] Sub-C: mixed tender - two payment lines (60 + 40) each fully captured, aggregate 100 via FlowField
        PlantEntriaEcomDocument(EcomSalesHeaderC, EcomSalesHeaderC."Document Type"::Order, 'ZZ-BILL-TIV-C', 'medusa-bill-tiv-c');
        PlantPaymentLine(EcomSalesHeaderC, 60, 60);
        PlantSecondPaymentLine(EcomSalesHeaderC, 40, 40);
        PlantOrderEvent(OrderEventC, EcomSalesHeaderC);

        // [WHEN] RegisterCapturedAmount runs against all three orders
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeaderA);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeaderB);
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeaderC);

        // [THEN] Sub-A billed exactly 100 as one event
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-TIV-A', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'Sub-A (card only) must bill 100 - the aggregate captured amount, not the tender identity.');

        // [THEN] Sub-B billed exactly 100 as one event
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-TIV-B', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'Sub-B (voucher only) must bill 100 - same shape as Sub-A, same result, because the engine reads only the aggregate FlowField.');

        // [THEN] Sub-C billed exactly 100 as one event, aggregated from two payment lines via the FlowField
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-TIV-C', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'Sub-C (mixed, 60 + 40) must bill 100 - one event over the aggregated FlowField, not one event per line. If the engine ever read individual payment lines, this order would produce two events of 60 and 40 and this assertion would fail.');
    end;

    /// <summary>
    /// Channel guard - RegisterCapturedAmount early-exits for non-Entria Document Source, so a Shopify or API order
    /// that reaches this entry point (via a shared subscriber) registers zero amount events. Complements
    /// Matrix_TenderShapeIsInvariantToBilling by asserting the ONE dimension that IS visible to the engine - channel.
    /// </summary>
    [Test]
    procedure Matrix_NonEntriaDocumentSource_RegistersNothing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrderEvent: Record "NPR Ecom Billing Event";
        PlantedOrderEvent: Record "NPR Ecom Billing Event";
        AmountEvent: Record "NPR Ecom Billing Event";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        ShopifyChannel: Enum "NPR Ecom Sales Doc Source";
    begin
        // [SCENARIO] RegisterCapturedAmount guards on "Document Source" = Entria and early-exits for any other
        //            channel. A Shopify order that reaches this entry point through a shared subscriber must produce
        //            zero amount events. If the guard is ever removed or widened, this test fails by finding an
        //            unexpected amount event.

        Initialize();
        ShopifyChannel := Enum::"NPR Ecom Sales Doc Source"::Shopify;

        // [GIVEN] A non-Entria (Shopify) ecommerce order with a fully captured payment line and an order event row
        //         already planted on the same channel - the exact shape RegisterAmountDelta would bill if it were
        //         reached.
        PlantNonEntriaEcomDocument(EcomSalesHeader, ShopifyChannel, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-NONENT', 'shopify-bill-nonent');
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);
        // Realign the planted order event's Channel to Shopify so the identity lookup would find it if the guard ever
        // stopped early-exiting. PlantOrderEvent hardcodes Channel = Entria on purpose for the Entria-focused suite;
        // rewriting the row here keeps that helper untouched.
        OrderEvent.Channel := ShopifyChannel;
        OrderEvent.Modify();

        // [WHEN] RegisterCapturedAmount runs against the Shopify order
        EcomBillingMgt.RegisterCapturedAmount(EcomSalesHeader);

        // [THEN] Zero amount events were inserted for this order - the channel guard early-exited before RegisterAmountDelta
        AmountEvent.SetRange(Channel, ShopifyChannel);
        AmountEvent.SetRange("Store Code", _StoreCode);
        AmountEvent.SetRange("External No.", 'ZZ-BILL-NONENT');
        AmountEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(0, AmountEvent.Count(),
            'A Shopify order that reaches RegisterCapturedAmount must produce zero amount events - the Document Source guard is the ONE channel signal the engine reads, and it must early-exit for non-Entria orders.');

        // [THEN] The planted order event row still exists - the guard did nothing to it, either
        PlantedOrderEvent.SetRange(Channel, ShopifyChannel);
        PlantedOrderEvent.SetRange("Store Code", _StoreCode);
        PlantedOrderEvent.SetRange("External No.", 'ZZ-BILL-NONENT');
        PlantedOrderEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT);
        _Assert.AreEqual(1, PlantedOrderEvent.Count(),
            'The planted Shopify order event row must be left intact - RegisterCapturedAmount only reads it, and only for Entria.');
    end;

    /// <summary>
    /// The intake twin of Matrix_NonEntriaDocumentSource_RegistersNothing. RegisterOrderImported derives the channel
    /// from "Document Source" and guards on it, because the event types it writes are Entria's: an order of another
    /// channel counted here would be charged under the Entria feature ids, and "NPR Billing Queue Entry" carries
    /// only a feature id and a metadata blob, so the billing backend could not tell the rows apart afterwards.
    /// </summary>
    [Test]
    procedure IntakeRegistersNothingForNonEntriaDocumentSource()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] A Shopify order reaches the intake registration through a shared caller. Nothing may be
        //            registered for it and nothing may be queued.

        // [GIVEN] A non-Entria (Shopify) ecommerce order, with no billing rows of its own
        Initialize();
        PlantNonEntriaEcomDocument(EcomSalesHeader, Enum::"NPR Ecom Sales Doc Source"::Shopify, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-INTNONENT', 'shopify-bill-intnonent');
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [WHEN] The intake registration runs against it
        EcomBillingMgt.RegisterOrderImported(EcomSalesHeader);

        // [THEN] No event row of any kind exists for the order. Deliberately not filtered on channel: with the guard
        //        removed the row would be written under the document's own Shopify channel, and the assertion has to
        //        catch that rather than look past it.
        EcomBillingEvent.SetRange("Store Code", _StoreCode);
        EcomBillingEvent.SetRange("External No.", 'ZZ-BILL-INTNONENT');
        _Assert.AreEqual(0, EcomBillingEvent.Count(),
            'A non-Entria order must register no billing event at intake - the event types written here are Entria''s, so counting another channel bills it under the Entria feature ids with nothing in the queue entry to tell the two apart.');

        // [THEN] Nothing was queued either - the row and the queue entry are written one after the other, so this
        //        fails on its own only if the guard ends up between them
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'A non-Entria order must queue no billing event at intake - a queued event is a charge, and this one would be charged as an Entria order count.');
    end;

    /// <summary>
    /// The only test in this codeunit that reaches the billing engine through Sales-Post, the way the posting wave
    /// does in production, instead of calling "NPR Ecom Billing Mgt." directly.
    /// </summary>
    /// <remarks>
    /// There are two production call sites - MagentoPmtMgt.Cu80OnAfterPostSalesInvoice for the posting wave and
    /// EcomSaleDocCaptureProcess.OnRun for the fast lane - and most tests in this suite call the engine themselves,
    /// so deleting a call site leaves them green while production silently stops billing. This test guards the
    /// posting one (FastLaneCaptureProcessBillsTheCapturedAmount guards the other). It drives the real chain end to
    /// end: Sales-Post posts the invoice, CaptureSalesInvoice captures the payment line through the CI test gateway,
    /// the gateway's success response writes "Captured Amount" back onto the ecommerce payment line, and the
    /// OnAfterPostSalesDoc subscriber then reaches the engine.
    ///
    /// Nothing here plants a billing event or a captured amount. The COUNT row comes from a real Entria import and
    /// the captured amount comes from a real capture, so the whole path is under test rather than described.
    ///
    /// It fails if any link is removed: the subscriber call, the capture, the write-back, or the engine's own
    /// delta. That is the point - the value is in what it refuses to let anyone delete quietly.
    /// </remarks>
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostingThroughSalesPostBillsTheCapturedAmount()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        PaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        GatewayCode: Code[10];
        CapturedTotal: Decimal;
    begin
        // [SCENARIO] A real Entria order is imported, a sales order carrying its ecommerce id is posted, and the
        //            gateway captures the tender during posting. The posting-time subscriber must then bill exactly
        //            what was captured - reached through Sales-Post, not by calling the engine.

        // [GIVEN] An enabled Entria store and an imported Entria order, so a genuine COUNT row exists
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(4, 3, 2024), 090000T);
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-BILL-SPOST', 'medusa-bill-spost', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-BILL-SPOST');
        ImportPrebuiltOrder('ZZ-BILL-SPOST', OrdersArr, EcomSalesHeader);
        _Assert.IsTrue(GetOrderEvent(EcomBillingEvent, 'ZZ-BILL-SPOST'),
            'Setup: the import must have left the COUNT row, otherwise the posting hook exits on the missing order event and this test would pass for the wrong reason.');

        // [GIVEN] The payment line the import itself created, with nothing captured yet - the capture during
        //         posting is what fills it. Nothing is planted here: BuildOrderArrayWithPayments puts a payment in
        //         the payload, so the import already inserted this line at "Line No." 10000 with Amount 100 and
        //         "Captured Amount" 0, which is exactly the state this test needs.
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.FindFirst();

        // [GIVEN] A payment gateway whose capture really succeeds, so the write-back path runs
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");

        // [GIVEN] A sales order carrying the ecommerce document id, tendered by a payment line linked back to the
        //         ecommerce payment line. Both links are load bearing: the sales header id is how the subscriber
        //         finds the ecommerce document, and the payment line id is how the capture write-back finds the
        //         ecommerce payment line that "Captured Payment Amount" sums.
        _LibSales.CreateSalesOrder(SalesHeader);
        SalesHeader."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        SalesHeader.Modify();
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);
        PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        PaymentLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
        PaymentLine.Modify();
        Commit();

        // [WHEN] The sales order is shipped and invoiced through Sales-Post
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] The capture really ran and really wrote back, so there is an amount to bill at all
        EcomSalesHeader.Find();
        EcomSalesHeader.CalcFields("Captured Payment Amount");
        CapturedTotal := EcomSalesHeader."Captured Payment Amount";
        _Assert.AreNotEqual(0, CapturedTotal,
            'Setup: the capture during posting must have written back to "Captured Amount" - with nothing captured the engine correctly bills nothing, and the assertion below would pass without proving the hook ran.');

        // [THEN] Exactly one amount event was billed, for exactly what was captured, reached through Sales-Post
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-SPOST', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(CapturedTotal, EcomBillingEvent.Amount,
            'Posting through Sales-Post must bill exactly the amount the capture wrote back - this is the only assertion in the suite that fails if the posting-time subscriber is removed.');
        AssertEventIsQueued(EcomBillingEvent,
            'The event billed from the posting hook must be queued - an unqueued row charges nothing and is not counted as progress, so the next posting would register the same amount again.');
    end;

    /// <summary>
    /// The only test that reaches the fast-lane call site. Every other test that talks about the fast lane calls
    /// the engine directly, so deleting the call at EcomSaleDocCaptureProcess.OnRun - "if _Success then
    /// RegisterBillingAfterCapture(Rec)", which forwards to EcomBillingMgt.RegisterAmountEvent - leaves all of them
    /// green. A VI-only order does post, and the posting wave then fires on it, but by that point the fast lane has
    /// already captured everything, so the posting wave reads delta = 0: the fast-lane call is the only one that
    /// ever bills such an order. This test drives the process codeunit itself, the same entry point the capture job
    /// queue and the Capture Virtual Items page action use.
    ///
    /// No payment gateway is involved, and that is deliberate: the subject is the billing call at the end of the
    /// process, not the capture. The document carries no sales lines, so CalculateAmountToCapture returns 0 and
    /// the amount still to capture is negative - EcomCaptureImpl.Process short-circuits before the gateway loop.
    /// The payment line is fully captured, which is also what makes ValidateImportedPaymentLines skip per-line
    /// import validation, so the capture reports success.
    /// </summary>
    [Test]
    procedure FastLaneCaptureProcessBillsTheCapturedAmount()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSaleDocCaptureProcess: Codeunit "NPR EcomSaleDocCaptureProcess";
    begin
        // [SCENARIO] A VI-only Entria order whose tender is captured goes through the real fast-lane capture
        //            process. The process must bill the captured amount on its way out.

        // [GIVEN] A VI-only Entria order of 100, fully captured, with its COUNT row in place
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-FASTLANE', 'medusa-bill-fastlane');
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader.Modify();
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);

        // [WHEN] The capture process runs with the flags the capture job queue sets
        EcomSaleDocCaptureProcess.SetUpdateRetryCount(true);
        EcomSaleDocCaptureProcess.SetShowError(false);
        EcomSaleDocCaptureProcess.Run(EcomSalesHeader);

        // [THEN] The capture really succeeded - on failure HandleResponse fills this field, and the assertion
        //        below would then be passing on the guard rather than on the billing call
        EcomSalesHeader.Find();
        _Assert.AreEqual('', EcomSalesHeader."Last Capture Error Message",
            'Setup: the capture must have succeeded, otherwise this test proves only that a failed capture bills nothing - which is the sibling test.');

        // [THEN] Exactly one amount event was billed, for the whole captured tender
        FindSingleEventOfType(EcomBillingEvent, 'ZZ-BILL-FASTLANE', Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        _Assert.AreEqual(100, EcomBillingEvent.Amount,
            'The fast-lane capture process must bill exactly what it captured - this is the only assertion in the suite that fails if the RegisterBillingAfterCapture call in EcomSaleDocCaptureProcess.OnRun is removed.');
        AssertEventIsQueued(EcomBillingEvent,
            'The event billed from the fast lane must be queued - an unqueued row charges nothing and is not counted as progress by the posting wave that follows.');
    end;

    /// <summary>
    /// The other half of the same call site: the "if Success then" guard in front of it. Nothing else in the
    /// suite forces a real capture to fail, so without this test moving the billing call above the guard - or
    /// dropping the guard - goes unnoticed, and a failed capture would bill money the customer never paid.
    ///
    /// The failure is injected through the product's own guard rather than through a gateway: EcomCaptureImpl
    /// refuses a document whose Creation Status is already Created. The billing engine does not read Creation
    /// Status, so if the guard were gone this document would bill its full 100 - which is what makes the
    /// assertion discriminating rather than vacuous.
    /// </summary>
    [Test]
    procedure FastLaneCaptureFailureBillsNothing()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrderEvent: Record "NPR Ecom Billing Event";
        EcomSaleDocCaptureProcess: Codeunit "NPR EcomSaleDocCaptureProcess";
        QueueBaselineEntryNo: BigInteger;
    begin
        // [SCENARIO] The fast-lane capture process runs on a document it must refuse. Nothing may be billed.

        // [GIVEN] A captured Entria order of 100 that the capture process will refuse, with its COUNT row in place
        Initialize();
        PlantEntriaEcomDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, 'ZZ-BILL-FLFAIL', 'medusa-bill-flfail');
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader.Modify();
        PlantPaymentLine(EcomSalesHeader, 100, 100);
        PlantOrderEvent(OrderEvent, EcomSalesHeader);
        QueueBaselineEntryNo := LastBillingQueueEntryNo();

        // [WHEN] The capture process runs, swallowing the error the way the job queue does
        EcomSaleDocCaptureProcess.SetUpdateRetryCount(true);
        EcomSaleDocCaptureProcess.SetShowError(false);
        EcomSaleDocCaptureProcess.Run(EcomSalesHeader);

        // [THEN] The capture really failed - otherwise the assertions below prove nothing
        EcomSalesHeader.Find();
        _Assert.AreNotEqual('', EcomSalesHeader."Last Capture Error Message",
            'Setup: the capture must have failed, otherwise this test asserts that a successful capture bills nothing, which would be the real defect.');

        // [THEN] Nothing was billed and nothing was queued
        FilterAmountEvents(EcomBillingEvent, 'ZZ-BILL-FLFAIL');
        _Assert.AreEqual(0, EcomBillingEvent.Count(),
            'A failed capture must leave no amount row - the money never moved, and a row here would also be read as progress by the posting wave and suppress the real charge later.');
        AssertNoEcomBillingQueueEntryAfter(QueueBaselineEntryNo,
            'A failed capture must queue no billing event - queuing one charges the customer for a capture that did not happen.');
    end;

    local procedure Initialize()
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // Per test, not once per run: TestIsolation = Codeunit rolls back once, at the END of the codeunit, so an
        // event row or an ecommerce document an earlier test left behind - and while the intake path called here
        // commits nothing, the import job queue that calls it in production does - would otherwise decide the
        // outcome of every test declared after it.
        // Both the order event and every child row it owns carry "Store Code", so one sweep by store code clears the
        // whole order for this store - there is no parent table to sweep through any more.
        // "NPR Billing Queue Entry" is deliberately NOT swept: it is shared with every other feature that bills
        // and with other test codeunits, and it needs no sweeping, because every event id this suite asserts on
        // is a GUID created during the test itself.
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCodeLbl);
        EcomSalesHeader.DeleteAll(true);
        EcomBillingEvent.SetRange("Store Code", _StoreCodeLbl);
        EcomBillingEvent.DeleteAll();

        if not _Initialized then begin
            _Initialized := true;
            _LibraryEntria.EnsureSetupExists();
        end;
        _StoreCode := _StoreCodeLbl;
    end;

    local procedure ImportPrebuiltOrder(DocumentNo: Code[20]; OrdersArr: JsonArray; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrderTkn: JsonToken;
    begin
        EntriaStore.Get(_StoreCode);
        OrdersArr.Get(0, OrderTkn);
        EntriaOrderImpl.ImportOrder(OrderTkn, EntriaStore, DocumentNo, EcomSalesHeader);
    end;

    /// <summary>
    /// Inserts a bare Entria ecommerce document of the given type. Written here rather than taken from the Entria
    /// library on purpose: the library's CreateEcomDocumentHeader returns no record, sets no "External Document
    /// Id", and leaves "Document Source" at its API default, which would make every document type guard in this
    /// suite pass on the channel guard instead.
    /// </summary>
    local procedure PlantEntriaEcomDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; DocumentType: Enum "NPR Ecom Sales Doc Type"; ExternalNo: Code[20]; ExternalDocumentId: Text[100])
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."Document Type" := DocumentType;
        EcomSalesHeader."Ecommerce Store Code" := _StoreCode;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."External Document Id" := ExternalDocumentId;
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Entria;
        EcomSalesHeader.Insert();
    end;

    /// <summary>
    /// Sibling of PlantEntriaEcomDocument that takes the channel as a parameter, used to exercise the channel guard
    /// in RegisterCapturedAmount for non-Entria Document Source values (Shopify, API). Kept separate from
    /// PlantEntriaEcomDocument on purpose: many existing tests rely on that helper hardcoding Entria, and its
    /// signature must not change.
    /// </summary>
    local procedure PlantNonEntriaEcomDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; DocumentSource: Enum "NPR Ecom Sales Doc Source"; DocumentType: Enum "NPR Ecom Sales Doc Type"; ExternalNo: Code[20]; ExternalDocumentId: Text[100])
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."Document Type" := DocumentType;
        EcomSalesHeader."Ecommerce Store Code" := _StoreCode;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."External Document Id" := ExternalDocumentId;
        EcomSalesHeader."Document Source" := DocumentSource;
        EcomSalesHeader.Insert();
    end;

    /// <summary>
    /// Gives the document a tender, and optionally a captured part of it. Both "Payment Amount" and "Captured
    /// Payment Amount" on the header are FlowFields over the payment line, so planting the line is the only way
    /// to give a planted document either amount.
    /// </summary>
    local procedure PlantPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; PaymentAmount: Decimal; CapturedAmount: Decimal)
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := 10000;
        EcomSalesPmtLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesPmtLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesPmtLine.Amount := PaymentAmount;
        EcomSalesPmtLine."Captured Amount" := CapturedAmount;
        EcomSalesPmtLine.Insert();
    end;

    /// <summary>
    /// Plants a second payment line on the same document, at "Line No." 20000, so a test can exercise the aggregate
    /// nature of the "Captured Payment Amount" FlowField over more than one line. Kept separate from PlantPaymentLine
    /// on purpose: PlantPaymentLine is called by many existing tests and its signature must not change.
    /// </summary>
    local procedure PlantSecondPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; PaymentAmount: Decimal; CapturedAmount: Decimal)
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := 20000;
        EcomSalesPmtLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesPmtLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesPmtLine.Amount := PaymentAmount;
        EcomSalesPmtLine."Captured Amount" := CapturedAmount;
        EcomSalesPmtLine.Insert();
    end;

    /// <summary>
    /// Plants the order event row directly, without running the intake. Represents an order already registered by
    /// RegisterOrderImported at intake, so a test can reach a capture or posting wave from that state without a
    /// prebuilt Entria import payload. The row carries only identity and the COUNT event type - there is no cap
    /// and no stored progress; progress is derived from the queued amount rows every time.
    /// </summary>
    local procedure PlantOrderEvent(var EcomBillingEvent: Record "NPR Ecom Billing Event"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomBillingEvent.Init();
        EcomBillingEvent.Channel := Enum::"NPR Ecom Sales Doc Source"::Entria;
        EcomBillingEvent."Store Code" := EcomSalesHeader."Ecommerce Store Code";
        EcomBillingEvent."External No." := EcomSalesHeader."External No.";
        EcomBillingEvent."Event Type" := Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT;
        EcomBillingEvent.Amount := 1;
        EcomBillingEvent."Currency Code" := EcomSalesHeader."Currency Code";
        EcomBillingEvent."Registered At" := CurrentDateTime();
        EcomBillingEvent."Billing Queue Entry No." := 0;
        EcomBillingEvent.Insert();
    end;

    /// <summary>
    /// Plants an amount child row directly under an order event, without running a wave. Queued = true represents a
    /// wave that finished and queued its event - the state CalcBilledAmount sums as progress. Queued = false is the
    /// unqueued state: InsertAmountEvent inserts the row before RegisterBillingEvent queues it, and CalcBilledAmount
    /// excludes an unqueued row from progress on purpose, which is what lets the next wave recompute and retry the
    /// same delta. The current production chain cannot leave such a row behind - the two writes share one
    /// Codeunit.Run boundary, so a failure rolls back both - so it has to be planted to be tested at all.
    /// </summary>
    local procedure PlantAmountEvent(OrderEvent: Record "NPR Ecom Billing Event"; Amount: Decimal; Queued: Boolean)
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
    begin
        EcomBillingEvent.Init();
        EcomBillingEvent.Channel := OrderEvent.Channel;
        EcomBillingEvent."Store Code" := OrderEvent."Store Code";
        EcomBillingEvent."External No." := OrderEvent."External No.";
        EcomBillingEvent."Event Type" := Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP;
        EcomBillingEvent.Amount := Amount;
        EcomBillingEvent."Currency Code" := OrderEvent."Currency Code";
        EcomBillingEvent."Registered At" := CurrentDateTime();
        if Queued then
            EcomBillingEvent."Billing Queue Entry No." := -1
        else
            EcomBillingEvent."Billing Queue Entry No." := 0;
        EcomBillingEvent.Insert();
    end;

    /// <summary>
    /// Sets the captured amount on the payment line of an imported document, which is what the capture wave reads
    /// through the header's "Captured Payment Amount" FlowField.
    /// </summary>
    local procedure SetCapturedAmount(EcomSalesHeader: Record "NPR Ecom Sales Header"; CapturedAmount: Decimal)
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.FindFirst();
        EcomSalesPmtLine."Captured Amount" := CapturedAmount;
        EcomSalesPmtLine.Modify();
    end;

    /// <summary>
    /// Finds the order event row by the identity the intake uses: channel, store and "External No.". The primary key
    /// is a surrogate entry number, so it is never the way a row is looked up by business identity.
    /// </summary>
    local procedure GetOrderEvent(var EcomBillingEvent: Record "NPR Ecom Billing Event"; ExternalNo: Code[20]): Boolean
    begin
        EcomBillingEvent.Reset();
        EcomBillingEvent.SetRange(Channel, Enum::"NPR Ecom Sales Doc Source"::Entria);
        EcomBillingEvent.SetRange("Store Code", _StoreCode);
        EcomBillingEvent.SetRange("External No.", ExternalNo);
        EcomBillingEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT);
        exit(EcomBillingEvent.FindFirst());
    end;

    local procedure CountOrderEvents(ExternalNo: Code[20]): Integer
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
    begin
        EcomBillingEvent.SetRange(Channel, Enum::"NPR Ecom Sales Doc Source"::Entria);
        EcomBillingEvent.SetRange("Store Code", _StoreCode);
        EcomBillingEvent.SetRange("External No.", ExternalNo);
        EcomBillingEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT);
        exit(EcomBillingEvent.Count());
    end;

    local procedure CountAmountEvents(ExternalNo: Code[20]): Integer
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
    begin
        EcomBillingEvent.SetRange(Channel, Enum::"NPR Ecom Sales Doc Source"::Entria);
        EcomBillingEvent.SetRange("Store Code", _StoreCode);
        EcomBillingEvent.SetRange("External No.", ExternalNo);
        EcomBillingEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
        exit(EcomBillingEvent.Count());
    end;

    /// <summary>
    /// Counts every billing event row for this store, order event and amount children alike. Both carry "Store Code" in
    /// the single-table model, so one count covers what used to need a count over the log table plus a count over
    /// the event table through its parent.
    /// </summary>
    local procedure CountBillingEventRowsForStore(): Integer
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
    begin
        EcomBillingEvent.SetRange("Store Code", _StoreCode);
        exit(EcomBillingEvent.Count());
    end;

    local procedure FilterAmountEvents(var EcomBillingEvent: Record "NPR Ecom Billing Event"; ExternalNo: Code[20])
    var
        OrderEvent: Record "NPR Ecom Billing Event";
    begin
        _Assert.IsTrue(GetOrderEvent(OrderEvent, ExternalNo),
            StrSubstNo('Setup: an order event row must exist for order %1 before its amount events can be filtered.', ExternalNo));
        EcomBillingEvent.Reset();
        EcomBillingEvent.SetCurrentKey("Entry No.");
        FilterOrderIdentity(EcomBillingEvent, OrderEvent);
        EcomBillingEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
    end;

    /// <summary>
    /// Finds the single event row of one type for one order. A COUNT lookup returns the order event row itself - there
    /// is no separate child row for it. An AMOUNT_SHOP lookup finds the order event first and then its one child row of
    /// that type, matched on the order identity every row of the order carries.
    /// </summary>
    local procedure FindSingleEventOfType(var EcomBillingEvent: Record "NPR Ecom Billing Event"; ExternalNo: Code[20]; EventType: Enum "NPR Billing Event Type")
    var
        OrderEvent: Record "NPR Ecom Billing Event";
    begin
        if EventType = Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT then begin
            // Count first, then locate. GetOrderEvent alone only proves "at least one exists", which cannot detect a
            // second count row - and a second one would let the order be amount-billed twice, because progress is
            // summed from the amount rows hanging off the order event that was found, so each count row carries its
            // own independent progress.
            _Assert.AreEqual(1, CountOrderEvents(ExternalNo),
                StrSubstNo('Exactly one %1 event row must exist for order %2.', Format(EventType), ExternalNo));
            _Assert.IsTrue(GetOrderEvent(EcomBillingEvent, ExternalNo),
                StrSubstNo('The %1 event row for order %2 must be locatable.', Format(EventType), ExternalNo));
            exit;
        end;

        _Assert.IsTrue(GetOrderEvent(OrderEvent, ExternalNo),
            StrSubstNo('Setup: an order event row must exist for order %1 before its amount events can be found.', ExternalNo));
        EcomBillingEvent.Reset();
        FilterOrderIdentity(EcomBillingEvent, OrderEvent);
        EcomBillingEvent.SetRange("Event Type", EventType);
        _Assert.AreEqual(1, EcomBillingEvent.Count(),
            StrSubstNo('Exactly one %1 event row must exist for order %2.', Format(EventType), ExternalNo));
        EcomBillingEvent.FindFirst();
    end;

    /// <summary>
    /// Asserts on a BigInteger field being zero or non-zero through a BigInteger variable, never an Integer
    /// literal.
    /// </summary>
    /// <remarks>
    /// `Assert.Equal` compares numerically only when BOTH sides satisfy `IsNumber`, which the library defines as
    /// `IsDecimal or IsInteger or IsChar`. BigInteger is not in that set, so a BigInteger comparison falls through
    /// to type-and-format equality: `AreEqual(0, &lt;BigInteger&gt;)` fails even when the value really is zero, and
    /// `AreNotEqual(0, &lt;BigInteger&gt;)` PASSES even when it is zero, because the types already differ. Four
    /// assertions in this suite were silently passing that way until the suite was first executed.
    ///
    /// The trap is BigInteger-only. An Integer literal against a Decimal field - `Amount`, `Quantity` - routes
    /// through `EqualNumbers(Decimal, Decimal)` and is a true value comparison, so those assertions elsewhere in
    /// this suite are correct as written and must not be "fixed" into typed locals.
    /// </remarks>
    local procedure AssertEventIsQueued(EcomBillingEvent: Record "NPR Ecom Billing Event"; AssertionMessage: Text)
    var
        Unqueued: BigInteger;
    begin
        Unqueued := 0;
        _Assert.AreNotEqual(Unqueued, EcomBillingEvent."Billing Queue Entry No.", AssertionMessage);
    end;

    local procedure AssertEventIsNotQueued(EcomBillingEvent: Record "NPR Ecom Billing Event"; AssertionMessage: Text)
    var
        Unqueued: BigInteger;
    begin
        Unqueued := 0;
        _Assert.AreEqual(Unqueued, EcomBillingEvent."Billing Queue Entry No.", AssertionMessage);
    end;

    /// <summary>
    /// Filters an event record to every row of one order, matched the way production matches them: on the
    /// identity that the order event and each of its amount rows all carry. There is no parent link to follow.
    /// </summary>
    local procedure FilterOrderIdentity(var EcomBillingEvent: Record "NPR Ecom Billing Event"; OrderEvent: Record "NPR Ecom Billing Event")
    begin
        EcomBillingEvent.Reset();
        EcomBillingEvent.SetRange(Channel, OrderEvent.Channel);
        EcomBillingEvent.SetRange("Store Code", OrderEvent."Store Code");
        EcomBillingEvent.SetRange("External No.", OrderEvent."External No.");
    end;

    /// <summary>
    /// Asserts the queued billing event, scoped to one event id. Never a row count over "NPR Billing Queue
    /// Entry": that table is shared with every other billing feature and other test codeunits delete rows in it,
    /// so a count over the whole table proves nothing and breaks for unrelated reasons.
    /// </summary>
    local procedure AssertSingleQueueEntry(EventId: Guid; EventType: Enum "NPR Billing Event Type"; ExpectedQuantity: Decimal)
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.Reset();
        BillingQueueEntry.SetRange("Event ID", EventId);
        _Assert.AreEqual(1, BillingQueueEntry.Count(),
            StrSubstNo('Exactly one billing queue entry must carry event id %1 - the entry is what is forwarded to the billing API, so a missing one bills nothing and a second one bills twice.', Format(EventId, 0, 4)));
        BillingQueueEntry.FindFirst();
        _Assert.AreEqual(EventType.AsInteger(), BillingQueueEntry."Feature ID",
            'The queued billing event must carry the feature id of the expected event type - the billing system charges by feature id, so a wrong one bills the merchant for another feature.');
        _Assert.AreEqual(ExpectedQuantity, BillingQueueEntry.Quantity,
            'The queued billing event must carry the expected quantity - the quantity is what the merchant is charged for.');
    end;

    local procedure LastBillingQueueEntryNo(): BigInteger
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.Reset();
        if not BillingQueueEntry.FindLast() then
            exit(0);
        exit(BillingQueueEntry."Entry No.");
    end;

    /// <summary>
    /// Asserts that no ecommerce order billing event was queued after the given entry number. Scoped by entry
    /// number and by the two ecommerce order feature ids rather than by store code, because the queue entry keeps
    /// the store code only inside its metadata blob, which cannot be filtered on.
    /// </summary>
    local procedure AssertNoEcomBillingQueueEntryAfter(BaselineEntryNo: BigInteger; AssertionMessage: Text)
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.Reset();
        BillingQueueEntry.SetFilter("Entry No.", '>%1', BaselineEntryNo);
        BillingQueueEntry.SetFilter("Feature ID", '%1|%2',
            Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT.AsInteger(),
            Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP.AsInteger());
        _Assert.IsTrue(BillingQueueEntry.IsEmpty(), AssertionMessage);
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;
}
#endif
