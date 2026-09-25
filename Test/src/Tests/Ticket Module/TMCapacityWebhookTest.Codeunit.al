codeunit 85460 "NPR TM CapacityWebhookTest"
{
    Subtype = Test;

    // These tests drive the buffer directly - TouchXxx then EmitTouchedEntries - so they pin the decision
    // logic (notify quantity, debit/credit netting, once-per-flush, capacity-as-of stamp) without going through a sale.
    // Whether the ticket paths actually call TouchXxx is a separate concern, covered by the issuance tests.

    var
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WithinNotifyQuantity_Emits()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Subscriber: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A slot whose remaining capacity is at or below the notify quantity reports itself once.
        Initialize();
        CreateSlot(10, 10, AdmissionScheduleEntry);
        BindSubscription(Subscriber);

        CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 1);
        CapacityWebHook.EmitTouchedEntries();

        Assert.AreEqual(1, Subscriber.EventCount(), 'A slot inside the notify quantity must report once.');
        Assert.AreEqual(AdmissionScheduleEntry."External Schedule Entry No.", Subscriber.LastExternalEntryNo(), 'The event must identify the touched slot.');
        Assert.AreEqual(10, Subscriber.LastRemainingCapacity(), 'Remaining capacity must be the whole slot - no tickets were sold.');
        UnbindSubscription(Subscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AboveNotifyQuantity_Silent()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Subscriber: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A slot with plenty left is not interesting, however much of it was just sold.
        Initialize();
        CreateSlot(10, 3, AdmissionScheduleEntry);
        BindSubscription(Subscriber);

        CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 4);
        CapacityWebHook.EmitTouchedEntries();

        Assert.AreEqual(0, Subscriber.EventCount(), 'A slot above the notify quantity must stay silent.');
        UnbindSubscription(Subscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReleaseBackAboveNotifyQuantity_Emits()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Subscriber: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] The change that lifts a slot back out of the notify quantity is reported, so a consumer
        // told "2 left" learns the seats came back. The release is what places the slot inside the quantity
        // before this request, so the decision rests on the netting rather than on where it ended up.
        Initialize();
        CreateSlot(10, 3, AdmissionScheduleEntry);
        BindSubscription(Subscriber);

        CapacityWebHook.TouchReleasedExternalEntry(AdmissionScheduleEntry."External Schedule Entry No.", 8);
        CapacityWebHook.EmitTouchedEntries();

        Assert.AreEqual(1, Subscriber.EventCount(), 'Leaving the notify quantity must be reported once.');
        Assert.AreEqual(10, Subscriber.LastRemainingCapacity(), 'The event must carry the capacity as it stands after the release.');
        UnbindSubscription(Subscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteAndReissue_NetsToZeroAndStaysSilent()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Subscriber: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] A request that deletes and reissues the same tickets - the SOAP reservation and POS
        // ReconfirmReservation shape - did not move the slot. The notify quantity is set to the whole slot so
        // the silence can only come from the netting, not from the slot being outside the band.
        Initialize();
        CreateSlot(10, 10, AdmissionScheduleEntry);
        BindSubscription(Subscriber);

        CapacityWebHook.TouchReleasedExternalEntry(AdmissionScheduleEntry."External Schedule Entry No.", 8);
        CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 8);
        CapacityWebHook.EmitTouchedEntries();

        Assert.AreEqual(0, Subscriber.EventCount(), 'A net-zero request must not report anything.');
        UnbindSubscription(Subscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NotifyQuantityZero_DisablesTheWebhook()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Subscriber: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Zero is off, even for a slot that is completely sold out.
        Initialize();
        CreateSlot(10, 0, AdmissionScheduleEntry);
        BindSubscription(Subscriber);

        CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 10);
        CapacityWebHook.EmitTouchedEntries();

        Assert.AreEqual(0, Subscriber.EventCount(), 'A notify quantity of zero must disable the webhook for the slot.');
        UnbindSubscription(Subscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ManyTouches_ReportOncePerFlush()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Subscriber: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
        i: Integer;
    begin
        // [SCENARIO] The anti-spam guarantee: a 500-ticket batch on one slot is one event, not 500.
        Initialize();
        CreateSlot(10, 10, AdmissionScheduleEntry);
        BindSubscription(Subscriber);

        for i := 1 to 500 do
            CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 1);
        CapacityWebHook.EmitTouchedEntries();
        Assert.AreEqual(1, Subscriber.EventCount(), 'Repeated touches of one slot must report once per flush.');

        CapacityWebHook.EmitTouchedEntries();
        Assert.AreEqual(1, Subscriber.EventCount(), 'The flush must clear the buffer.');
        UnbindSubscription(Subscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CapacityAsOf_IsPopulated()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Subscriber: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
        FirstCapacityAsOf: DateTime;
    begin
        // [SCENARIO] AL subscribers see the events in call order, so the stamp means nothing to them - it is
        // carried here only so a test can see that the external payload's capacityAsOf is a real value and
        // never goes backwards, which no AL subscriber to the external event could check. Two emits this close
        // together will usually share a stamp - the clock advances in steps far coarser than the gap.
        Initialize();
        CreateSlot(10, 10, AdmissionScheduleEntry);
        BindSubscription(Subscriber);

        CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 1);
        CapacityWebHook.EmitTouchedEntries();
        FirstCapacityAsOf := Subscriber.LastCapacityAsOf();
        Assert.IsTrue(FirstCapacityAsOf > 0DT, 'The capacity-as-of stamp must be populated.');

        CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 1);
        CapacityWebHook.EmitTouchedEntries();

        Assert.IsTrue(Subscriber.LastCapacityAsOf() >= FirstCapacityAsOf, 'The stamp must never go backwards between emits.');
        UnbindSubscription(Subscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ThrowingSubscriber_DoesNotReachTheSale()
    var
        FirstEntry: Record "NPR TM Admis. Schedule Entry";
        SecondEntry: Record "NPR TM Admis. Schedule Entry";
        HostileSubscriber: Codeunit "NPR TM Capacity Hostile Sub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Subscribers run on the sale path, so one that throws must not reach the caller and must not
        // cost the remaining slots their event. Only the hostile one is bound: the event is not isolated, so a
        // throw also cuts off that slot's other subscribers, in an order AL does not let us pin down.
        Initialize();
        CreateSlot(10, 10, FirstEntry);
        CreateSlot(10, 10, SecondEntry);
        HostileSubscriber.SetThrow();
        BindSubscription(HostileSubscriber);

        CapacityWebHook.TouchConsumedEntry(FirstEntry, 1);
        CapacityWebHook.TouchConsumedEntry(SecondEntry, 1);
        CapacityWebHook.EmitTouchedEntries();

        Assert.AreEqual(2, HostileSubscriber.CallCount(), 'Every slot must be offered to the subscriber despite the first one throwing.');
        UnbindSubscription(HostileSubscriber);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommittingSubscriber_IsRefused()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        HostileSubscriber: Codeunit "NPR TM Capacity Hostile Sub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] This event fires mid-sale, so a subscriber that commits has misunderstood it. The commit
        // is refused outright rather than delayed, and the refusal is contained like any other subscriber error.
        Initialize();
        CreateSlot(10, 10, AdmissionScheduleEntry);
        HostileSubscriber.SetCommit();
        BindSubscription(HostileSubscriber);

        CapacityWebHook.TouchConsumedEntry(AdmissionScheduleEntry, 1);
        CapacityWebHook.EmitTouchedEntries();

        Assert.AreEqual(1, HostileSubscriber.CallCount(), 'The committing subscriber must have run.');
        Assert.IsFalse(HostileSubscriber.RanPastCommit(), 'The commit must be refused, not delayed.');
        UnbindSubscription(HostileSubscriber);
    end;

    /// <summary>
    /// Capacity control SALES with nothing sold, so remaining capacity equals MaxCapacity and a test can place
    /// the slot either side of the notify quantity by choosing two numbers instead of issuing tickets. The
    /// admission code is generated per call, so no test can see another's slots.
    /// </summary>
    local procedure CreateSlot(MaxCapacity: Integer; NotifyAtRemainingQty: Integer; var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry") AdmissionCode: Code[20]
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        Assert: Codeunit Assert;
        ScheduleCode: Code[20];
    begin
        AdmissionCode := LibraryTicketModule.CreateAdmissionCode(LibraryTicketModule.GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');
        ScheduleCode := LibraryTicketModule.CreateSchedule(LibraryTicketModule.GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, Today(), AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000000.010T, 235959.990T, true, true, true, true, true, true, true, '');
        LibraryTicketModule.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, MaxCapacity, ScheduleLine."Capacity Control"::SALES, '<+5D>', 0, 0, '');

        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Notify At Remaining Qty." := NotifyAtRemainingQty;
        ScheduleLine.Modify();

        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, true, Today());

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmissionScheduleEntry.FindFirst(), 'The scenario must generate a schedule entry.');
    end;

    local procedure Initialize()
    var
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
    begin
        if (not _Initialized) then begin
            LibraryTicketModule.CreateMinimalSetup();
            _Initialized := true;
        end;

        // The buffer is single instance and survives a test, so a leftover touch would land in the next flush.
        CapacityWebHook.ClearTouchedEntries();
        Commit();
    end;
}
