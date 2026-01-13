codeunit 85170 "NPR TM AdmissionScheduleTest"
{
    Subtype = Test;
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddScheduleEntryForExistingDay_01()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        i, SlotSize : Integer;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 150000T, 160000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', CalcDate('<+1D>'));
        ScheduleEntry.FindFirst();
        ScheduleEntry.Validate("Admission Is", ScheduleEntry."Admission Is"::CLOSED);
        ScheduleEntry.Modify();
        Assert.AreEqual(ScheduleEntry."Regenerate With"::MANUAL, ScheduleEntry."Regenerate With", 'The schedule entry did not update the "Regenerate With" field.');

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 170000T, 180000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ScheduleEntry."External Schedule Entry No.");
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindFirst();
        Assert.AreEqual(ScheduleEntry."Regenerate With"::MANUAL, ScheduleEntry."Regenerate With", 'The schedule entry did not retain its manual changes.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddScheduleEntryForExistingDay_02()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 150000T, 160000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 170000T, 180000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', CalcDate('<+1D>'));
        ScheduleEntry.FindFirst();
        ScheduleEntry.Validate("Admission Is", ScheduleEntry."Admission Is"::CLOSED);
        ScheduleEntry.Modify();
        Assert.AreEqual(ScheduleEntry."Regenerate With"::MANUAL, ScheduleEntry."Regenerate With", 'The schedule entry did not update the "Regenerate With" field.');

        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ScheduleEntry."External Schedule Entry No.");
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindFirst();
        Assert.AreEqual(ScheduleEntry."Regenerate With"::MANUAL, ScheduleEntry."Regenerate With", 'The schedule entry did not retain its manual changes.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SimpleRegeneration()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount: Integer;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(0, SlotCount, 'No time slots are prior to test.');

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 160000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(5 + 1, SlotCount, 'Unexpected number of time slots (1).');

        SoftRegenerateSchedule(AdmissionCode, Today());
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(5 + 1, SlotCount, 'Unexpected number of time slots (2).');

        ScheduleEntry.FindLast();
        ScheduleEntry."Dynamic Price Profile Code" := 'FOO';
        ScheduleEntry.Modify();

        SoftRegenerateSchedule(AdmissionCode, Today());
        ScheduleEntry.SetFilter(Cancelled, '=%1', true);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(1, SlotCount, 'Unexpected number of time slots (3).');

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(5 + 1, SlotCount, 'Unexpected number of time slots (4).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OnlyOneActiveEntryPerExternalScheduleEntry()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Assert: Codeunit Assert;
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        ActiveExternalIds: Dictionary of [Integer, Boolean];
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);

        SoftRegenerateSchedule(AdmissionCode, Today());
        SoftRegenerateSchedule(AdmissionCode, Today());
        ForceRegenerateSchedule(AdmissionCode, Today());
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', Today());
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (ScheduleEntry.FindSet()) then
            repeat
                if (ActiveExternalIds.ContainsKey(ScheduleEntry."External Schedule Entry No.")) then
                    Assert.Fail(StrSubstNo('Multiple active entries share External Schedule Entry No. %1', ScheduleEntry."External Schedule Entry No."));
                ActiveExternalIds.Add(ScheduleEntry."External Schedule Entry No.", true);
            until (ScheduleEntry.Next() = 0);

        Assert.IsTrue((ActiveExternalIds.Count() > 0), 'Scheduler did not produce any active entries to validate.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockedScheduleLines()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount: Integer;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 10);
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 130000T, 160000T, 10);
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);

        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(2 * (10 + 1), SlotCount, 'Unexpected number of time slots (1).');

        // Blocking the schedule line should cancel the corresponding entries
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine.Validate(Blocked, true); // Validate resets the "Schedule Generated Until" 
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(1 * (10 + 1), SlotCount, 'Unexpected number of time slots (2).');

        // UnBlocking the schedule line should bring them back
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine.Validate(Blocked, false); // Validate resets the "Schedule Generated Until" 
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(2 * (10 + 1), SlotCount, 'Unexpected number of time slots (3).');

        ScheduleEntry.SetFilter(Cancelled, '=%1', true);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(1 * (10 + 1), SlotCount, 'Unexpected number of time slots (4).');

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', Today());
        ScheduleEntry.FindLast();

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ScheduleEntry."External Schedule Entry No.");
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(2, SlotCount, 'Time slot data integrity - the 2 slots must have same external reference.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ForceRegenerate()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);

        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual((5 + 1), SlotCount, 'Unexpected number of time slots (1).');

        ScheduleEntry.FindLast();
        SlotId := ScheduleEntry."External Schedule Entry No.";

        ForceRegenerateSchedule(AdmissionCode, Today());
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual((5 + 1), SlotCount, 'Unexpected number of time slots (2).');

        ForceRegenerateSchedule(AdmissionCode, Today());
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual((5 + 1), SlotCount, 'Unexpected number of time slots (3).');

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(3 * (5 + 1), SlotCount, 'Unexpected number of time slots (4).');

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', SlotId);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(3, SlotCount, 'Unexpected number of time slots (5).');

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(1, SlotCount, 'Unexpected number of time slots (6).');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NothingToGenerate()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        NormalDate := CalcDate('<+1D>');
        EditDate := CalcDate('<+2D>');

        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EditedEntry01()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin

        NormalDate := CalcDate('<+1D>');
        EditDate := CalcDate('<+2D>');

        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);

        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', EditDate);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindFirst();
        ApplyFixedManualChanges(ScheduleEntry);
        ScheduleEntry.Modify();

        SoftRegenerateSchedule(AdmissionCode, Today());
        Assert.IsTrue(CheckFixedManualChanges(ScheduleEntry), 'Manual changes to time slot was lost.');

        ForceRegenerateSchedule(AdmissionCode, Today());
        ScheduleEntry.FindFirst();
        Assert.IsFalse(CheckFixedManualChanges(ScheduleEntry), 'Manual changes should be lost.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EditedEntry02()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin

        NormalDate := CalcDate('<+1D>');
        EditDate := CalcDate('<+2D>');

        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);

        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', EditDate);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindFirst();
        ApplyFixedManualChanges(ScheduleEntry);
        ScheduleEntry.Modify();

        SoftRegenerateSchedule(AdmissionCode, Today());
        Assert.IsTrue(CheckFixedManualChanges(ScheduleEntry), 'Manual changes to time slot was lost.');

        ForceRegenerateSchedule(AdmissionCode, CalcDate('<+1D>', EditDate));
        ScheduleEntry.FindFirst();
        Assert.IsTrue(CheckFixedManualChanges(ScheduleEntry), 'Manual changes to time slot was lost.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EditedEntry03()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin

        NormalDate := CalcDate('<+1D>');
        EditDate := CalcDate('<+2D>');

        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);

        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', EditDate);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindFirst();
        ApplyFixedManualChanges(ScheduleEntry);
        ScheduleEntry.Modify();

        SoftRegenerateSchedule(AdmissionCode, Today());
        Assert.IsTrue(CheckFixedManualChanges(ScheduleEntry), 'Manual changes to time slot was lost.');

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 120000T, 140000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());
        ScheduleEntry.FindFirst();
        Assert.IsTrue(CheckFixedManualChanges(ScheduleEntry), 'Manual changes to time slot was lost (2).');

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 140000T, 180000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());
        ScheduleEntry.FindFirst();
        Assert.IsTrue(CheckFixedManualChanges(ScheduleEntry), 'Manual changes to time slot was lost (3).');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EditedEntry04()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin

        NormalDate := CalcDate('<+1D>');
        EditDate := CalcDate('<+2D>');

        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);

        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', EditDate);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindFirst();
        ApplyFixedManualChanges(ScheduleEntry);
        ScheduleEntry.Modify();

        Schedule.Get(ScheduleCode);
        Schedule."Start Time" := 090000T;
        Schedule."Stop Time" := 130000T;
        Schedule.Modify();

        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.FindFirst();
        Assert.IsTrue(CheckFixedManualChanges(ScheduleEntry), 'Manual changes to time slot was lost.');

        Assert.AreEqual(090000T, ScheduleEntry."Admission Start Time", 'New Start Time was not applied on entry.');
        Assert.AreEqual(130000T, ScheduleEntry."Admission End Time", 'New End Time was not applied on entry.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime01()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 090000T, 100000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 100000T, 110000T, 5);
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5); // Duplicate
        SoftRegenerateSchedule(AdmissionCode, Today());

        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(4 * (5 + 1), SlotCount, 'Unexpected number of time slots.');

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(3 * (5 + 1), SlotCount, 'Unexpected number of time slots (1).');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime02()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ForceRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 090000T, 100000T, 5);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 100000T, 110000T, 5);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5); // Duplicate
        ForceRegenerateSchedule(AdmissionCode, Today());

        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(4 * (5 + 1), SlotCount, 'Unexpected number of time slots.');

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(3 * (5 + 1), SlotCount, 'Unexpected number of time slots (1).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime03()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'FOO';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 070000T, 080000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'XXX';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 140000T, 150000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'XXX';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5); // Duplicate
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAR';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('BAR', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and equal process order, last entry is expected to be retained.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime04()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'FOO';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAR';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        ForceRegenerateSchedule(AdmissionCode, Today());


        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('BAR', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and equal process order, last entry is expected to be retained.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime05()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'FOO';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAR';
        ScheduleLine."Process Order" := 2;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('BAR', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and increasing process order, highest process order must be retained.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime06()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'FOO';
        ScheduleLine."Process Order" := 2;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAR';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        ForceRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('FOO', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and increasing process order, highest process order must be retained.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime07()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'FOO';
        ScheduleLine."Process Order" := 2;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAR';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('FOO', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and increasing process order, highest process order must be retained.');
    end;



    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime08()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'FOO';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAR';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAZ';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('BAZ', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and equal process order, last entry is expected to be retained.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverlappingTime09()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'FOO';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAR';
        ScheduleLine."Process Order" := 2;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 5);
        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        ScheduleLine."Dynamic Price Profile Code" := 'BAZ';
        ScheduleLine."Process Order" := 1;
        ScheduleLine.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('BAR', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and increasing process order, highest process order must be retained.');

        ForceRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.FindLast();
        Assert.AreEqual('BAR', ScheduleEntry."Dynamic Price Profile Code", 'With duplicate time slots and increasing process order, highest process order must be retained.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DualSchedules01()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        NormalDate, EditDate : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        CreateTimeSlotMWFS(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 6);
        CreateTimeSlotTTS(AdmissionCode, ScheduleCode, Today(), 080000T, 120000T, 6);
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual((6 + 1), SlotCount, 'Unexpected number of time slots.');

        ForceRegenerateSchedule(AdmissionCode, Today());
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual((6 + 1), SlotCount, 'Unexpected number of time slots (1).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MultiSchedules01()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        RegenerationDate: Record Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), CalcDate('<+20D>'), 080000T, 100000T, 5); // End date at +20 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), CalcDate('<+7D>'), 110000T, 120000T, 5); // End date +7 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, CalcDate('<+10D>'), CalcDate('<+17D>'), 110000T, 120000T, 5); // Start date +10 days and end date at +17 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 130000T, 140000T, 5); // open end date

        RegenerationDate.SetFilter("Period Type", '=%1', RegenerationDate."Period Type"::Date);
        RegenerationDate.SetFilter("Period Start", '%1..%2', Today(), CalcDate('<+30D>'));
        RegenerationDate.FindSet();

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);

        repeat
            SoftRegenerateSchedule(AdmissionCode, RegenerationDate."Period Start");

            ScheduleEntry.SetFilter("Admission Start Date", '=%1', RegenerationDate."Period Start");
            SlotCount := ScheduleEntry.Count();

            case (RegenerationDate."Period Start") of
                Today() .. CalcDate('<+7D>'):
                    Assert.AreEqual(3, SlotCount, 'Day 0 until 7, there should be 3 active slots per day.');

                CalcDate('<+8D>') .. CalcDate('<+9D>'):
                    Assert.AreEqual(2, SlotCount, 'Day 8 and 9, there should be 2 active slots per day.');

                CalcDate('<+10D>') .. CalcDate('<+17D>'):
                    Assert.AreEqual(3, SlotCount, 'Day 10 until 17, there should be 3 active slots per day.');

                CalcDate('<+18D>') .. CalcDate('<+20D>'):
                    Assert.AreEqual(2, SlotCount, 'Day 18 until 20, there should be 2 active slots per day.');

                CalcDate('<+21D>') .. CalcDate('<+30D>'):
                    Assert.AreEqual(1, SlotCount, 'Day 21 until 30, there should be 1 active slot per day.');
            end;
        until (RegenerationDate.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MultiSchedules02()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        RegenerationDate: Record Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), CalcDate('<+20D>'), 080000T, 100000T, 5); // End date at +20 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), CalcDate('<+7D>'), 110000T, 120000T, 5); // End date +7 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, CalcDate('<+10D>'), CalcDate('<+17D>'), 110000T, 120000T, 5); // Start date +10 days and end date at +17 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 130000T, 140000T, 5); // open end date

        RegenerationDate.SetFilter("Period Type", '=%1', RegenerationDate."Period Type"::Date);
        RegenerationDate.SetFilter("Period Start", '%1..%2', Today(), CalcDate('<+30D>'));
        RegenerationDate.FindSet();

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);

        repeat

            if (RegenerationDate."Period Start" = CalcDate('<+8D>')) then begin
                CreateTimeSlot(AdmissionCode, ScheduleCode, CalcDate('<+10D>'), CalcDate('<+17D>'), 150000T, 160000T, 5); // Start date +10 days and end date at +17 days
                ScheduleLine.Get(AdmissionCode, ScheduleCode);
            end;

            if (RegenerationDate."Period Start" = CalcDate('<+14D>')) then begin
                ScheduleLine.Validate(Blocked, true);
                ScheduleLine.Modify();
            end;

            SoftRegenerateSchedule(AdmissionCode, RegenerationDate."Period Start");

            ScheduleEntry.SetFilter("Admission Start Date", '=%1', RegenerationDate."Period Start");
            SlotCount := ScheduleEntry.Count();

            case (RegenerationDate."Period Start") of
                Today() .. CalcDate('<+7D>'):
                    Assert.AreEqual(3, SlotCount, 'Day 0 until 7, there should be 3 active slots per day.');

                CalcDate('<+8D>') .. CalcDate('<+9D>'):
                    Assert.AreEqual(2, SlotCount, 'Day 8 and 9, there should be 2 active slots per day.');

                CalcDate('<+10D>') .. CalcDate('<+13D>'):
                    Assert.AreEqual(4, SlotCount, 'Day 10 until 13, there should be 4 active slots per day.');

                CalcDate('<+14D>') .. CalcDate('<+17D>'):
                    Assert.AreEqual(3, SlotCount, 'Day 14 until 17, there should be 3 active slots per day.');

                CalcDate('<+18D>') .. CalcDate('<+20D>'):
                    Assert.AreEqual(2, SlotCount, 'Day 18 until 20, there should be 2 active slots per day.');

                CalcDate('<+21D>') .. CalcDate('<+30D>'):
                    Assert.AreEqual(1, SlotCount, 'Day 21 until 30, there should be 1 active slot per day.');
            end;
        until (RegenerationDate.Next() = 0);

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        SlotCount := ScheduleEntry.Count();
        Assert.AreEqual(4, SlotCount, 'Blocking a schedule line should only affect entries going forward and allow past entries to be as they were.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MultiSchedules03()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        RegenerationDate: Record Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), CalcDate('<+20D>'), 080000T, 100000T, 5); // End date at +20 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), CalcDate('<+7D>'), 110000T, 120000T, 5); // End date +7 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, CalcDate('<+10D>'), CalcDate('<+17D>'), 110000T, 120000T, 5); // Start date +10 days and end date at +17 days
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 130000T, 140000T, 5); // open end date

        RegenerationDate.SetFilter("Period Type", '=%1', RegenerationDate."Period Type"::Date);
        RegenerationDate.SetFilter("Period Start", '%1..%2', Today(), CalcDate('<+30D>'));
        RegenerationDate.FindSet();

        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);

        repeat

            if (RegenerationDate."Period Start" = CalcDate('<+8D>')) then begin
                CreateTimeSlot(AdmissionCode, ScheduleCode, CalcDate('<+10D>'), CalcDate('<+17D>'), 150000T, 160000T, 5); // Start date +10 days and end date at +17 days
                Schedule.Get(ScheduleCode);
            end;

            if (RegenerationDate."Period Start" = CalcDate('<+14D>')) then begin
                // Note that this schedule has +3 days schedules generated that must be canceled by schedular.
                Schedule.validate("End After Date", CalcDate('<+14D>'));
                Schedule.Modify();
            end;

            SoftRegenerateSchedule(AdmissionCode, RegenerationDate."Period Start");

            ScheduleEntry.SetFilter("Admission Start Date", '=%1', RegenerationDate."Period Start");
            SlotCount := ScheduleEntry.Count();

            case (RegenerationDate."Period Start") of
                Today() .. CalcDate('<+7D>'):
                    Assert.AreEqual(3, SlotCount, 'Day 0 until 7, there should be 3 active slots per day.');

                CalcDate('<+8D>') .. CalcDate('<+9D>'):
                    Assert.AreEqual(2, SlotCount, 'Day 8 and 9, there should be 2 active slots per day.');

                CalcDate('<+10D>') .. CalcDate('<+14D>'):
                    Assert.AreEqual(4, SlotCount, 'Day 10 until 14, there should be 4 active slots per day.');

                CalcDate('<+15D>') .. CalcDate('<+17D>'):
                    Assert.AreEqual(3, SlotCount, 'Day 15 until 17, there should be 3 active slots per day.');

                CalcDate('<+18D>') .. CalcDate('<+20D>'):
                    Assert.AreEqual(2, SlotCount, 'Day 18 until 20, there should be 2 active slots per day.');

                CalcDate('<+21D>') .. CalcDate('<+30D>'):
                    Assert.AreEqual(1, SlotCount, 'Day 21 until 30, there should be 1 active slot per day.');
            end;
        until (RegenerationDate.Next() = 0);

        ScheduleEntry.Reset();
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        SlotCount := ScheduleEntry.Count();
        // 10, 11, 12, 13, 14 => 5
        Assert.AreEqual(5, SlotCount, 'Setting schedule line end date should only affect entries going forward and allow past entries to be as they were.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DailyScheduleHonorsEverySecondDay()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        Day0, Day1, Day2 : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        Day0 := Today();
        Day1 := CalcDate('<+1D>', Day0);
        Day2 := CalcDate('<+2D>', Day0);

        // only generate one day at a time
        CreateTimeSlotDaily(AdmissionCode, ScheduleCode, Day0, 0D, 100000T, 110000T, 0);

        Schedule.Get(ScheduleCode);
        Schedule."Recurrence Pattern" := Schedule."Recurrence Pattern"::DAILY;
        Schedule."Recur Every N On" := 2; // every other day
        Schedule.Modify();

        SoftRegenerateSchedule(AdmissionCode, Day0);
        CountScheduleEntries(ScheduleEntry, AdmissionCode, ScheduleCode, Day0, 1, 'Day 0 should have one slot');

        SoftRegenerateSchedule(AdmissionCode, Day1);
        CountScheduleEntries(ScheduleEntry, AdmissionCode, ScheduleCode, Day1, 0, 'Day 1 should be skipped');

        SoftRegenerateSchedule(AdmissionCode, Day2);
        CountScheduleEntries(ScheduleEntry, AdmissionCode, ScheduleCode, Day2, 1, 'Day 2 should be generated again');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WeeklyScheduleHonorsEverySecondWeek()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        Week0Monday, Week1Monday, Week2Monday : Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);

        Week0Monday := CalcDate('<CW+1D>', Today()); // this week's Monday
        Week1Monday := CalcDate('<+7D>', Week0Monday);
        Week2Monday := CalcDate('<+14D>', Week0Monday);

        CreateTimeSlot(AdmissionCode, ScheduleCode, Week0Monday, 090000T, 100000T, 0);

        Schedule.Get(ScheduleCode);
        Schedule."Recurrence Pattern" := Schedule."Recurrence Pattern"::WEEKLY;
        Schedule."Recur Every N On" := 2;
        Schedule.Monday := true;
        Schedule.Tuesday := false;
        Schedule.Wednesday := false;
        Schedule.Thursday := false;
        Schedule.Friday := false;
        Schedule.Saturday := false;
        Schedule.Sunday := false;
        Schedule.Modify();

        SoftRegenerateSchedule(AdmissionCode, Week0Monday);
        CountScheduleEntries(ScheduleEntry, AdmissionCode, ScheduleCode, Week0Monday, 1, 'Week 0 Monday should be generated');

        SoftRegenerateSchedule(AdmissionCode, Week1Monday);
        CountScheduleEntries(ScheduleEntry, AdmissionCode, ScheduleCode, Week1Monday, 0, 'Week 1 should be skipped');

        SoftRegenerateSchedule(AdmissionCode, Week2Monday);
        CountScheduleEntries(ScheduleEntry, AdmissionCode, ScheduleCode, Week2Monday, 1, 'Week 2 Monday should be generated again');
    end;

    local procedure CountScheduleEntries(var ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                                         AdmissionCode: Code[20];
                                         ScheduleCode: Code[20];
                                         TargetDate: Date;
                                         Expected: Integer;
                                         Message: Text)
    var
        Assert: Codeunit Assert;
    begin
        ScheduleEntry.Reset();
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", TargetDate);
        ScheduleEntry.SetRange(Cancelled, false);
        Assert.AreEqual(Expected, ScheduleEntry.Count(), Message);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistingSchedulerEntryGetsFullReplaceWhenDifferent()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        Assert: Codeunit Assert;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 090000T, 0);

        // Simulate target having a different Dynamic Price Profile
        ScheduleLine.SetRange("Admission Code", AdmissionCode);
        ScheduleLine.SetRange("Schedule Code", ScheduleCode);
        ScheduleLine.ModifyAll("Dynamic Price Profile Code", 'SAME');
        // Generate initial entry (scheduler-owned)
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.Reset();
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.FindFirst();
        Assert.AreEqual('SAME', ScheduleEntry."Dynamic Price Profile Code", 'Scheduler-owned entry should be replaced when differing.');

        // Simulate target having a different Dynamic Price Profile
        ScheduleLine.SetRange("Admission Code", AdmissionCode);
        ScheduleLine.SetRange("Schedule Code", ScheduleCode);
        ScheduleLine.ModifyAll("Dynamic Price Profile Code", 'DIFF');

        // Soft regenerate should full-replace scheduler-owned entries that differ
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.Reset();
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.FindFirst();
        Assert.AreEqual('DIFF', ScheduleEntry."Dynamic Price Profile Code", 'Scheduler-owned entry should be replaced when differing.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistingManualEntryGetsPartialUpdateWhenDifferent()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        Assert: Codeunit Assert;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 090000T, 0);

        // Simulate target having a different Dynamic Price Profile
        ScheduleLine.SetRange("Admission Code", AdmissionCode);
        ScheduleLine.SetRange("Schedule Code", ScheduleCode);
        ScheduleLine.ModifyAll("Max Capacity Per Sch. Entry", 10);

        // Generate initial entry (scheduler-owned)
        SoftRegenerateSchedule(AdmissionCode, Today());

        // Switch to manual and tweak capacity
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.FindFirst();
        Assert.AreEqual(10, ScheduleEntry."Max Capacity Per Sch. Entry", 'Initial capacity should be as per schedule line.');

        // Switch to manual and tweak times
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.FindFirst();
        ScheduleEntry."Regenerate With" := ScheduleEntry."Regenerate With"::MANUAL;
        ScheduleEntry."Max Capacity Per Sch. Entry" := 7;
        ScheduleEntry.Modify();

        // Target will differ; expect partial update, not full replace
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.Reset();
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.FindFirst();
        Assert.AreEqual(7, ScheduleEntry."Max Capacity Per Sch. Entry", 'Manual-owned entry should be partially updated and retain manual change.');
        Assert.AreEqual(ScheduleEntry."Regenerate With"::MANUAL, ScheduleEntry."Regenerate With", 'Manual ownership should be preserved.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelledExistingDoesNotBlockInsert()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        Assert: Codeunit Assert;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 090000T, 0);

        SoftRegenerateSchedule(AdmissionCode, Today());

        // Cancel the only existing entry
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.FindFirst();
        ScheduleEntry.Cancelled := true;
        ScheduleEntry.Modify();

        // Regenerate should insert a fresh active entry, not be blocked by the cancelled one
        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.Reset();
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.SetRange(Cancelled, false);
        Assert.AreEqual(1, ScheduleEntry.Count(), 'Cancelled existing entry should not block inserting a new active entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistingEntryNotCanceledWhenReferenceAdvances()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        Assert: Codeunit Assert;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 090000T, 0);

        SoftRegenerateSchedule(AdmissionCode, Today());

        // Advance reference so no targets are generated for today
        SoftRegenerateSchedule(AdmissionCode, CalcDate('<+1D>'));

        ScheduleEntry.Reset();
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.SetRange(Cancelled, false);
        Assert.AreEqual(1, ScheduleEntry.Count(), 'Existing entry should not be canceled when reference advances.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EarlyExitBlockedLineUpdatesGeneratedFields()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode1, ScheduleCode2 : Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode1, CalcDate('<-1D>'), 080000T, 090000T, 0);
        CreateTimeSlot(AdmissionCode, ScheduleCode2, CalcDate('<-1D>'), 090000T, 100000T, 0);
        SoftRegenerateSchedule(AdmissionCode, CalcDate('<-1D>'), CalcDate('<-1D>'));

        // Invalidate the schedule by exipiring the line
        Schedule.Get(ScheduleCode2);
        Schedule."Recurrence Until Pattern" := Schedule."Recurrence Until Pattern"::END_DATE;
        Schedule."End After Date" := CalcDate('<-1D>');
        Schedule.Modify();
        SoftRegenerateSchedule(AdmissionCode, Today(), Today());

        // No entries should be created for the blocked line
        ScheduleEntry.Reset();
        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode2);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.SetRange(Cancelled, false);
        Assert.AreEqual(0, ScheduleEntry.Count(), 'Expired schedule line should not generate entries.');

        // Early-exit should still update generation tracking
        ScheduleLine.Get(AdmissionCode, ScheduleCode2);
        Assert.AreEqual(Today(), ScheduleLine."Schedule Generated At", 'Schedule Generated At should be updated on early exit.');
        Assert.AreEqual(CalcDate('<-1D>'), ScheduleLine."Schedule Generated Until", 'Schedule Generated Until should remain last processed day on early exit.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EarlyExitAlreadyGeneratedTodayVsForce()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        CountAfterFirst, CountAfterSecond, CountAfterForce : Integer;
        GeneratedAtBefore: Date;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), 080000T, 090000T, 0);

        SoftRegenerateSchedule(AdmissionCode, Today());

        ScheduleEntry.SetRange("Admission Code", AdmissionCode);
        ScheduleEntry.SetRange("Schedule Code", ScheduleCode);
        ScheduleEntry.SetRange("Admission Start Date", Today());
        ScheduleEntry.SetRange(Cancelled, false);
        CountAfterFirst := ScheduleEntry.Count();

        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        GeneratedAtBefore := ScheduleLine."Schedule Generated At";
        Assert.AreEqual(Today(), GeneratedAtBefore, 'Schedule Generated At should be today after first soft run.');

        // Second soft generate should early-exit (no changes)
        SoftRegenerateSchedule(AdmissionCode, Today());
        CountAfterSecond := ScheduleEntry.Count();

        ScheduleLine.Get(AdmissionCode, ScheduleCode);
        Assert.AreEqual(CountAfterFirst, CountAfterSecond, 'Second soft run should not create new entries.');
        Assert.AreEqual(GeneratedAtBefore, ScheduleLine."Schedule Generated At", 'Schedule Generated At should not change on early exit.');

        // Force regenerate ignores the "already generated today" guard
        ForceRegenerateSchedule(AdmissionCode, Today());
        CountAfterForce := ScheduleEntry.Count();

        Assert.IsTrue(CountAfterForce >= CountAfterSecond, 'Force regenerate should not early-exit and may add/cancel entries.');
    end;



    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Manual_PerformanceRegenerateScheduleEntries()
    var
        AdmissionCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        DurationMs: Integer;
        StartTime, EndTime : Time;
        i: Integer;
        SqlRowCount, SqlStatmentCount : Integer;
        Assert: Codeunit "Assert";
    begin
        CreateMinimalSetup();
        CreateEventWithAdmissionCode(AdmissionCode, TicketTypeCode, ItemNo, AdmissionCode);
        CreateBackToBackSlots(AdmissionCode);
        ForceRegenerate();

        SqlRowCount := SessionInformation.SqlRowsRead();
        SqlStatmentCount := SessionInformation.SqlStatementsExecuted();
        StartTime := Time();

        for i := 1 to 2 do
            SoftRegenerateSchedule(AdmissionCode, Today());

        SqlRowCount := SessionInformation.SqlRowsRead() - SqlRowCount;
        SqlStatmentCount := SessionInformation.SqlStatementsExecuted() - SqlStatmentCount;
        EndTime := Time();
        DurationMs := EndTime - StartTime;

        // 2026-01-13: BC26 - Duration: 3077 ms, SQL Rows: 5744, SQL Statements: 4087
        // Error(StrSubstNo('Duration: %1 ms, SQL Rows: %2, SQL Statements: %3', DurationMs, SqlRowCount, SqlStatmentCount));
    end;


    local procedure CreateBackToBackSlots(AdmissionCode: Code[20])
    var
        ScheduleCode: Code[20];
        i: Integer;
        StartTime, EndTime : Time;
        OneHourMs: Integer;
    begin
        OneHourMs := 60 * 60 * 1000;
        StartTime := 080000T;

        for i := 1 to 10 do begin
            EndTime := StartTime + OneHourMs;
            CreateTimeSlot(AdmissionCode, ScheduleCode, Today(), StartTime, EndTime, 180);
            StartTime := EndTime;
        end;
    end;

    local procedure CreateEventWithAdmissionCode(AdmissionCodeParam: Code[20]; var TicketTypeCode: Code[10]; var ItemNo: Code[20]; var AdmissionCode: Code[20])
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
    begin
        TicketTypeCode := TicketTestLibrary.CreateTicketType(TicketTestLibrary.GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        ItemNo := TicketTestLibrary.CreateItem('', TicketTypeCode, Random(200) + 100);
        AdmissionCode := TicketTestLibrary.CreateAdmissionCode(AdmissionCodeParam, Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY, '', '');
        TicketTestLibrary.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
    end;



    procedure Performance()
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Schedule: Record "NPR TM Admis. Schedule";
        Assert: Codeunit "Assert";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SlotCount, SlotId : Integer;
        RegenerationDate: Record Date;
        StartTime, EndTime : Time;
        Duration: Integer;
        Log: TextBuilder;
        NumberOfSlotsPerDay: Integer;
    begin
        CreateMinimalSetup();
        CreateEvent(TicketTypeCode, ItemNo, AdmissionCode);
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        StartTime := 100000T;
        for NumberOfSlotsPerDay := 1 to 36 do begin
            EndTime := StartTime + 1.5 * 3600 * 1000;
            CreateTimeSlotDaily(AdmissionCode, ScheduleCode, Today(), 0D, StartTime, EndTime, 30); // open end date
            StartTime += 15 * 60 * 1000;
        end;


        // Should take time as all slots needs to created
        StartTime := Time();
        SoftRegenerateSchedule(AdmissionCode, Today());
        EndTime := Time();
        Duration := EndTime - StartTime;
        Log.AppendLine(StrSubstNo('%1: SoftRegenerateSchedule: %2 (ms), new entry count: %3', RegenerationDate."Period Start", Duration, ScheduleEntry.Count() - SlotCount));
        SlotCount := ScheduleEntry.Count();

        // Should ideally only append and not take much time 
        StartTime := Time();
        SoftRegenerateSchedule(AdmissionCode, CalcDate('<+1D>'));
        EndTime := Time();
        Duration := EndTime - StartTime;

        Log.AppendLine(StrSubstNo('%1: SoftRegenerateSchedule: %2 (ms), new entry count: %3', RegenerationDate."Period Start", Duration, ScheduleEntry.Count() - SlotCount));
        SlotCount := ScheduleEntry.Count();

        Error(Log.ToText());
    end;


    local procedure SoftRegenerateSchedule(AdmissionCode: Code[20]; ReferenceDate: Date)
    var
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
    begin
        ScheduleLine.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleLine.SetFilter("Schedule Generated At", '>=%1', ReferenceDate);
        ScheduleLine.ModifyAll("Schedule Generated At", CalcDate('<-1D>', ReferenceDate));

        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, false, ReferenceDate, ReferenceDate);
    end;

    local procedure SoftRegenerateSchedule(AdmissionCode: Code[20]; ReferenceDate: Date; SimulatedTodayDate: Date)
    var
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
    begin
        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, false, ReferenceDate, SimulatedTodayDate);
    end;

    local procedure ForceRegenerateSchedule(AdmissionCode: Code[20]; ReferenceDate: Date)
    var
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
    begin
        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, true, ReferenceDate);
    end;

    local procedure CreateEvent(var TicketTypeCode: Code[10]; var ItemNo: Code[20]; var AdmissionCode: Code[20])
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
    begin
        TicketTypeCode := TicketTestLibrary.CreateTicketType(TicketTestLibrary.GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        ItemNo := TicketTestLibrary.CreateItem('', TicketTypeCode, Random(200) + 100);
        AdmissionCode := (TicketTestLibrary.CreateAdmissionCode(TicketTestLibrary.GenerateCode20(), Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY, '', ''));
        TicketTestLibrary.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
    end;

    local procedure CreateTimeSlot(AdmissionCode: Code[20]; var ScheduleCode: Code[20]; StartFromDate: Date; AdmissionStartTime: Time; AdmissionEndTime: Time; NumberOfDays: Integer)
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        Schedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleCode := TicketTestLibrary.CreateSchedule(
            TicketTestLibrary.GenerateCode20(),
            Schedule."Schedule Type"::"EVENT",
            Schedule."Admission Is"::OPEN,
            StartFromDate,
            Schedule."Recurrence Until Pattern"::NO_END_DATE,
            AdmissionStartTime, AdmissionEndTime, true, true, true, true, true, true, true, '');
        TicketTestLibrary.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::ADMITTED, StrSubstNo('<+%1D>', NumberOfDays), 0, 0, '');
    end;

    local procedure CreateTimeSlot(AdmissionCode: Code[20]; var ScheduleCode: Code[20]; StartFromDate: Date; StopAtDate: Date; AdmissionStartTime: Time; AdmissionEndTime: Time; NumberOfDays: Integer)
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        Schedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleCode := TicketTestLibrary.CreateSchedule(
            TicketTestLibrary.GenerateCode20(),
            Schedule."Schedule Type"::"EVENT",
            Schedule."Admission Is"::OPEN,
            StartFromDate,
            Schedule."Recurrence Until Pattern"::NO_END_DATE,
            AdmissionStartTime, AdmissionEndTime, true, true, true, true, true, true, true, '');

        Schedule.Get(ScheduleCode);
        Schedule."Recurrence Until Pattern" := Schedule."Recurrence Until Pattern"::END_DATE;
        Schedule."End After Date" := StopAtDate;
        Schedule.Modify();

        TicketTestLibrary.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::ADMITTED, StrSubstNo('<+%1D>', NumberOfDays), 0, 0, '');
    end;

    local procedure CreateTimeSlotMWFS(AdmissionCode: Code[20]; var ScheduleCode: Code[20]; StartFromDate: Date; AdmissionStartTime: Time; AdmissionEndTime: Time; NumberOfDays: Integer)
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        Schedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleCode := TicketTestLibrary.CreateSchedule(
            TicketTestLibrary.GenerateCode20(),
            Schedule."Schedule Type"::"EVENT",
            Schedule."Admission Is"::OPEN,
            StartFromDate,
            Schedule."Recurrence Until Pattern"::NO_END_DATE,
            AdmissionStartTime, AdmissionEndTime, true, false, true, false, true, false, true, '');
        TicketTestLibrary.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::ADMITTED, StrSubstNo('<+%1D>', NumberOfDays), 0, 0, '');
    end;

    local procedure CreateTimeSlotTTS(AdmissionCode: Code[20]; var ScheduleCode: Code[20]; StartFromDate: Date; AdmissionStartTime: Time; AdmissionEndTime: Time; NumberOfDays: Integer)
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        Schedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleCode := TicketTestLibrary.CreateSchedule(
            TicketTestLibrary.GenerateCode20(),
            Schedule."Schedule Type"::"EVENT",
            Schedule."Admission Is"::OPEN,
            StartFromDate,
            Schedule."Recurrence Until Pattern"::NO_END_DATE,
            AdmissionStartTime, AdmissionEndTime, false, true, false, true, false, true, false, '');
        TicketTestLibrary.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::ADMITTED, StrSubstNo('<+%1D>', NumberOfDays), 0, 0, '');
    end;

    local procedure CreateTimeSlotDaily(AdmissionCode: Code[20]; var ScheduleCode: Code[20]; StartFromDate: Date; StopAtDate: Date; AdmissionStartTime: Time; AdmissionEndTime: Time; NumberOfDays: Integer)
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        Schedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleCode := TicketTestLibrary.CreateSchedule(
            TicketTestLibrary.GenerateCode20(),
            Schedule."Schedule Type"::"EVENT",
            Schedule."Admission Is"::OPEN,
            StartFromDate,
            Schedule."Recurrence Until Pattern"::NO_END_DATE,
            AdmissionStartTime, AdmissionEndTime, true, true, true, true, true, true, true, '');

        Schedule.Get(ScheduleCode);
        if (StopAtDate > 0D) then begin
            Schedule."Recurrence Until Pattern" := Schedule."Recurrence Until Pattern"::END_DATE;
            Schedule."End After Date" := StopAtDate;
        end;
        Schedule."Recurrence Pattern" := Schedule."Recurrence Pattern"::DAILY;
        Schedule."Event Arrival From Time" := AdmissionStartTime - 2 * 3600 * 1000; // arrive from 2 hours before
        Schedule."Event Arrival Until Time" := AdmissionStartTime + 3600 / 2 * 1000; // arrive
        Schedule."Sales Until Time" := AdmissionStartTime; // stop sale when event starts
        Schedule.Modify();

        TicketTestLibrary.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::Sales, StrSubstNo('<+%1D>', NumberOfDays), 0, 0, '');
    end;

    local procedure ApplyFixedManualChanges(var Entry: Record "NPR TM Admis. Schedule Entry")
    begin
        Entry."Admission Is" := Entry."Admission Is"::CLOSED;
        Entry."Max Capacity Per Sch. Entry" := 42;
        Entry."Visibility On Web" := Entry."Visibility On Web"::HIDDEN;
        Entry."Dynamic Price Profile Code" := 'FOO';
        Entry."Event Arrival From Time" := 010000T;
        Entry."Event Arrival Until Time" := 230000T;
        Entry."Sales From Date" := Today();
        Entry."Sales From Time" := 070000T;
        Entry."Sales Until Date" := CalcDate('<+3D>');
        Entry."Sales Until Time" := 220000T;
        Entry."Regenerate With" := Entry."Regenerate With"::MANUAL;
    end;

    local procedure CheckFixedManualChanges(Entry: Record "NPR TM Admis. Schedule Entry"): Boolean
    var
        TargetEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        ApplyFixedManualChanges(TargetEntry);
        exit((Entry."Admission Is" = TargetEntry."Admission Is")
            and (Entry."Max Capacity Per Sch. Entry" = TargetEntry."Max Capacity Per Sch. Entry")
            and (Entry."Visibility On Web" = TargetEntry."Visibility On Web")
            and (Entry."Dynamic Price Profile Code" = TargetEntry."Dynamic Price Profile Code")
            and (Entry."Event Arrival From Time" = TargetEntry."Event Arrival From Time")
            and (Entry."Event Arrival Until Time" = TargetEntry."Event Arrival Until Time")
            and (Entry."Sales From Date" = TargetEntry."Sales From Date")
            and (Entry."Sales From Time" = TargetEntry."Sales From Time")
            and (Entry."Sales Until Date" = TargetEntry."Sales Until Date")
            and (Entry."Sales Until Time" = TargetEntry."Sales Until Time")
            and (Entry."Regenerate With" = TargetEntry."Regenerate With")
        );
    end;


    local procedure CreateMinimalSetup()
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        TicketTestLibrary.CreateMinimalSetup();
    end;

}