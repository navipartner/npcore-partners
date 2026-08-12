codeunit 85378 "NPR TM Sch Entry Sales Test"
{
    Subtype = Test;

    var
        _LibTicket: Codeunit "NPR Library - Ticket Module";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScheduleRule_ResolvesControlAndCapacityFromSchedule()
    var
        Assert: Codeunit "Assert";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
        CapacityControl: Option;
        RemainingQuantity: Integer;
    begin
        // Capacity limited by SCHEDULE: both the control and the capacity must come off the schedule, even though
        // the admission and the schedule line carry different values.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 2, AdmissionCode, ReferenceDate);
        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);

        Assert.IsTrue(TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, ItemNo, '', ReferenceDate, 120000T, ReasonCode, RemainingQuantity, CapacityControl),
            'The schedule is open for sales.');

        Assert.AreEqual(Admission."Capacity Control"::SALES, CapacityControl, 'Expected the schedule''s capacity control, not the admission''s.');
        Assert.AreEqual(2, RemainingQuantity, 'Expected the schedule''s capacity, nothing sold yet.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ManualRule_TimeSlotCapacityOverridesScheduleLine()
    var
        Assert: Codeunit "Assert";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
        CapacityControl: Option;
        RemainingQuantity: Integer;
    begin
        // Manual capacity: the control comes off the schedule line, but a non-zero capacity on the time slot itself
        // takes precedence over the line's.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Override, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 10, AdmissionCode, ReferenceDate);
        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);

        AdmissionScheduleEntry."Max Capacity Per Sch. Entry" := 3;
        AdmissionScheduleEntry.Modify();

        Assert.IsTrue(TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, ItemNo, '', ReferenceDate, 120000T, ReasonCode, RemainingQuantity, CapacityControl),
            'The schedule is open for sales.');

        Assert.AreEqual(Admission."Capacity Control"::SALES, CapacityControl, 'Expected the schedule line''s capacity control.');
        Assert.AreEqual(3, RemainingQuantity, 'Expected the time slot''s capacity to override the schedule line''s.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScheduleRule_NoneOnScheduleWinsOverAdmission()
    var
        Assert: Codeunit "Assert";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
        CapacityControl: Option;
        RemainingQuantity: Integer;
    begin
        // The mirror case: an unlimited schedule under an admission that says SALES. Callers decide whether to
        // enforce a quantity from this control, so NONE has to survive the admission's value.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::"NONE", Admission."Capacity Control"::SALES, 2, AdmissionCode, ReferenceDate);
        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);

        Assert.IsTrue(TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, ItemNo, '', ReferenceDate, 120000T, ReasonCode, RemainingQuantity, CapacityControl),
            'The schedule is open for sales.');

        Assert.AreEqual(Admission."Capacity Control"::"NONE", CapacityControl, 'Expected the schedule''s NONE, not the admission''s SALES.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockedSchedule_StillReportsCapacityControl()
    var
        Assert: Codeunit "Assert";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
        CapacityControl: Option;
        RemainingQuantity: Integer;
    begin
        // A schedule can be blocked for reasons that have nothing to do with capacity. The control is resolved
        // before those checks run, so a blocked schedule still reports which control applies - otherwise a caller
        // would read the unset value as NONE and present the schedule as having no capacity control at all.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);
        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);

        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Enforce Schedule Sales Limits" := true;
        TicketBom.Modify();

        AdmissionScheduleEntry."Sales Until Date" := CalcDate('<-1D>', ReferenceDate);
        AdmissionScheduleEntry.Modify();

        Assert.IsFalse(TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, ItemNo, '', ReferenceDate, 120000T, ReasonCode, RemainingQuantity, CapacityControl),
            'A schedule whose sales window has ended is not open for sales.');

        Assert.AreEqual(ReasonCode::AdmissionSalesHasEndedDate.AsInteger(), ReasonCode.AsInteger(), 'Expected the sales window to be the blocking reason.');
        Assert.AreEqual(Admission."Capacity Control"::SALES, CapacityControl, 'A blocked schedule must still report the capacity control in effect.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Blocked_ScheduleBeyondTicketDuration()
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
    begin
        // A ticket that is only valid on the day of sale cannot be sold for a slot on a later date.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);

        TicketBom.Get(ItemNo, '', AdmissionCode);
        Evaluate(TicketBom."Duration Formula", '<0D>');
        TicketBom.Modify();

        GetScheduleEntry(AdmissionCode, CalcDate('<+1D>', ReferenceDate), AdmissionScheduleEntry);

        AssertBlockedWith(ReasonCode::ScheduleExceedTicketDuration, AdmissionScheduleEntry, ItemNo, ReferenceDate, 120000T);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Blocked_ActivateOnSalesForAnotherDate()
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
    begin
        // A ticket that is admitted the moment it is sold cannot be sold for another date - it would be admitted now.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);
        SetActivateOnSales(ItemNo, AdmissionCode);

        GetScheduleEntry(AdmissionCode, CalcDate('<+1D>', ReferenceDate), AdmissionScheduleEntry);

        AssertBlockedWith(ReasonCode::EventDateNotReferenceDate, AdmissionScheduleEntry, ItemNo, ReferenceDate, 120000T);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Blocked_ActivateOnSalesBeforeArrivalWindow()
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
    begin
        // Same, on the right date but before the guests may arrive.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);
        SetActivateOnSales(ItemNo, AdmissionCode);

        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);
        AdmissionScheduleEntry."Event Arrival From Time" := 140000T;
        AdmissionScheduleEntry.Modify();

        AssertBlockedWith(ReasonCode::EventAdmissionNotStarted, AdmissionScheduleEntry, ItemNo, ReferenceDate, 100000T);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Blocked_ReservationArrivalWindowHasPassed()
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
    begin
        // For a prebooked occasion the slot closes once the arrival window has passed, even on the right date.
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);

        Admission.Get(AdmissionCode);
        Admission.Type := Admission.Type::OCCASION;
        Admission."Prebook Is Required" := true;
        Admission.Modify();

        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);
        AdmissionScheduleEntry."Event Arrival Until Time" := 100000T;
        AdmissionScheduleEntry.Modify();

        AssertBlockedWith(ReasonCode::EventHasEndedTime, AdmissionScheduleEntry, ItemNo, ReferenceDate, 120000T);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Blocked_SalesHaveNotStartedByDate()
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
    begin
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);
        SetEnforceSalesLimits(ItemNo, AdmissionCode);

        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);
        AdmissionScheduleEntry."Sales From Date" := CalcDate('<+1D>', ReferenceDate);
        AdmissionScheduleEntry.Modify();

        AssertBlockedWith(ReasonCode::AdmissionSaleHasNotStartedDate, AdmissionScheduleEntry, ItemNo, ReferenceDate, 120000T);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Blocked_SalesHaveNotStartedByTime()
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
    begin
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);
        SetEnforceSalesLimits(ItemNo, AdmissionCode);

        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);
        AdmissionScheduleEntry."Sales From Date" := ReferenceDate;
        AdmissionScheduleEntry."Sales From Time" := 140000T;
        AdmissionScheduleEntry.Modify();

        AssertBlockedWith(ReasonCode::AdmissionSaleHasNotStartedTime, AdmissionScheduleEntry, ItemNo, ReferenceDate, 100000T);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Blocked_SalesHaveEndedByTime()
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ReferenceDate: Date;
    begin
        ItemNo := CreateScenario(Admission."Capacity Limits By"::Schedule, Admission."Capacity Control"::SALES, Admission."Capacity Control"::"NONE", 100, AdmissionCode, ReferenceDate);
        SetEnforceSalesLimits(ItemNo, AdmissionCode);

        GetScheduleEntry(AdmissionCode, ReferenceDate, AdmissionScheduleEntry);
        AdmissionScheduleEntry."Sales Until Date" := ReferenceDate;
        AdmissionScheduleEntry."Sales Until Time" := 100000T;
        AdmissionScheduleEntry.Modify();

        AssertBlockedWith(ReasonCode::AdmissionSalesHasEndedTime, AdmissionScheduleEntry, ItemNo, ReferenceDate, 120000T);
    end;

    local procedure AssertBlockedWith(ExpectedReason: Enum "NPR TM Sch. Block Sales Reason"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; ItemNo: Code[20]; ReferenceDate: Date; ReferenceTime: Time)
    var
        Assert: Codeunit "Assert";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        CapacityControl: Option;
        RemainingQuantity: Integer;
        BlockedLbl: Label 'Expected the schedule to be blocked with reason %1, was blocked with %2.', Locked = true;
        OpenLbl: Label 'Expected the schedule to be blocked with reason %1, but it is open for sales.', Locked = true;
    begin
        Assert.IsFalse(TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, ItemNo, '', ReferenceDate, ReferenceTime, ReasonCode, RemainingQuantity, CapacityControl),
            StrSubstNo(OpenLbl, ExpectedReason));
        Assert.AreEqual(ExpectedReason.AsInteger(), ReasonCode.AsInteger(), StrSubstNo(BlockedLbl, ExpectedReason, ReasonCode));
    end;

    local procedure SetActivateOnSales(ItemNo: Code[20]; AdmissionCode: Code[20])
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Activation Method" := "NPR TM ActivationMethod_Bom"::POS;
        TicketBom.Modify();
    end;

    local procedure SetEnforceSalesLimits(ItemNo: Code[20]; AdmissionCode: Code[20])
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Enforce Schedule Sales Limits" := true;
        TicketBom.Modify();
    end;

    /// <summary>
    /// Builds one admission with one schedule, where EffectiveControl is placed on the level the rule points at and
    /// DecoyControl on the other two - so a test fails rather than passes by coincidence if the wrong level is read.
    /// MaxCapacity is placed alongside EffectiveControl.
    /// </summary>
    local procedure CreateScenario(CapacityLimitsBy: Enum "NPR TM CapacityLimit"; EffectiveControl: Option; DecoyControl: Option; MaxCapacity: Integer; var AdmissionCode: Code[20]; var ReferenceDate: Date) ItemNo: Code[20]
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        ScheduleCode: Code[20];
        TicketTypeCode: Code[10];
        AdmissionControl: Option;
        ScheduleControl: Option;
        LineControl: Option;
        AdmissionCapacity: Integer;
        ScheduleCapacity: Integer;
        LineCapacity: Integer;
    begin
        _LibTicket.CreateMinimalSetup();

        AdmissionControl := DecoyControl;
        ScheduleControl := DecoyControl;
        LineControl := DecoyControl;
        case CapacityLimitsBy of
            CapacityLimitsBy::Admission:
                begin
                    AdmissionControl := EffectiveControl;
                    AdmissionCapacity := MaxCapacity;
                end;
            CapacityLimitsBy::Schedule:
                begin
                    ScheduleControl := EffectiveControl;
                    ScheduleCapacity := MaxCapacity;
                end;
            CapacityLimitsBy::Override:
                begin
                    LineControl := EffectiveControl;
                    LineCapacity := MaxCapacity;
                end;
        end;

        TicketTypeCode := _LibTicket.CreateTicketType(_LibTicket.GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL,
            "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);

        AdmissionCode := _LibTicket.CreateAdmissionCode(_LibTicket.GenerateCode20(), Admission.Type::LOCATION, CapacityLimitsBy, Admission."Default Schedule"::TODAY, '', '');

        Admission.Get(AdmissionCode);
        Admission."Capacity Control" := AdmissionControl;
        Admission."Max Capacity Per Sch. Entry" := AdmissionCapacity;
        Admission.Modify();

        // Schedule entries are generated and resolved against the admission time zone, so key the schedule to the
        // same clock rather than to Today() - otherwise the scenario splits across midnight on a non-UTC agent.
        ReferenceDate := DT2Date(TimeHelper.GetLocalTimeAtAdmission(AdmissionCode));

        ScheduleCode := _LibTicket.CreateSchedule(_LibTicket.GenerateCode20(), Schedule."Schedule Type"::LOCATION, Schedule."Admission Is"::OPEN,
            ReferenceDate, Schedule."Recurrence Until Pattern"::NO_END_DATE, 000000.010T, 235959.990T, true, true, true, true, true, true, true, '');

        Schedule.Get(ScheduleCode);
        Schedule."Capacity Control" := ScheduleControl;
        Schedule."Max Capacity Per Sch. Entry" := ScheduleCapacity;
        Schedule.Modify();

        // Inserting the line syncs the admission's or the schedule's values into it, depending on the rule, so the
        // line is written last to keep the decoy in place.
        _LibTicket.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, LineCapacity, LineControl, '<+5D>', 0, 0, '');

        ItemNo := _LibTicket.CreateItem('', TicketTypeCode, 100);
        _LibTicket.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, true, ReferenceDate);
    end;

    local procedure GetScheduleEntry(AdmissionCode: Code[20]; ReferenceDate: Date; var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    var
        Assert: Codeunit "Assert";
    begin
        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmissionScheduleEntry.FindFirst(), 'The scenario generated no schedule entry for the reference date.');
    end;
}
