codeunit 85361 "NPR TM Ticket Notify Rem Test"
{
    Subtype = Test;

    var
        _PristineTimeZoneNo: Integer;
        _PristineTimeZoneCaptured: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WelcomeNotificationUsesServiceLocalTime()
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        NotifyParticpt: Codeunit "NPR TM Ticket Notify Particpt.";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit "Assert";
        ProfileCode: Code[10];
        Expected: DateTime;
        Actual: DateTime;
    begin
        // [Scenario] A welcome reminder is scheduled on the service local wall clock, not on the clock of the session that creates it.

        // [GIVEN] A service time zone which is hours away from the time zone of the session running the test
        SetServiceTimeZoneToUtcPlus12();

        // [GIVEN] A confirmed ticket whose admission carries a welcome profile without a time offset
        ProfileCode := CreateNotificationProfile(ProfileLine."Notification Trigger"::WELCOME, ProfileLine."Unit of Measure"::DAYS, 0);
        ArrangeConfirmedTicket(ProfileCode, Ticket, TicketAccessEntry);

        // [WHEN] The welcome reminder is created
        Expected := TimeHelper.GetLocalTimeForService();
        NotifyParticpt.CreateAdmissionWelcomeReminder(TicketAccessEntry, Ticket."External Member Card No.");

        // [THEN] The pending welcome notification is scheduled at the service local time
        NotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NotificationEntry.SetFilter("Ticket Trigger Type", '=%1', NotificationEntry."Ticket Trigger Type"::WELCOME);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        Assert.IsTrue(NotificationEntry.FindFirst(), 'Expected a pending WELCOME notification entry.');

        Actual := CreateDateTime(NotificationEntry."Date To Notify", NotificationEntry."Time To Notify");
        RestoreServiceTimeZone();
        Assert.IsTrue(Abs(Actual - Expected) < 60000, StrSubstNo('Expected %1 to be within 60s of the service-local time %2.', Actual, Expected));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RevokeNotificationUsesServiceLocalTime()
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        NotifyParticpt: Codeunit "NPR TM Ticket Notify Particpt.";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit "Assert";
        ProfileCode: Code[10];
        Expected: DateTime;
        Actual: DateTime;
    begin
        // [Scenario] A revoke notification is scheduled on the service local wall clock, not on the clock of the session that creates it.

        // [GIVEN] A service time zone which is hours away from the time zone of the session running the test
        SetServiceTimeZoneToUtcPlus12();

        // [GIVEN] A confirmed ticket whose admission carries a revoke profile without a time offset
        ProfileCode := CreateNotificationProfile(ProfileLine."Notification Trigger"::REVOKE, ProfileLine."Unit of Measure"::DAYS, 0);
        ArrangeConfirmedTicket(ProfileCode, Ticket, TicketAccessEntry);

        // [WHEN] The revoke notification is created
        Expected := TimeHelper.GetLocalTimeForService();
        NotifyParticpt.CreateRevokeNotification(TicketAccessEntry);

        // [THEN] The pending cancellation notification is scheduled at the service local time
        NotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NotificationEntry.SetFilter("Ticket Trigger Type", '=%1', NotificationEntry."Ticket Trigger Type"::CANCEL_RESERVE);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        Assert.IsTrue(NotificationEntry.FindFirst(), 'Expected a pending CANCEL_RESERVE (revoke) notification entry.');

        Actual := CreateDateTime(NotificationEntry."Date To Notify", NotificationEntry."Time To Notify");
        RestoreServiceTimeZone();
        Assert.IsTrue(Abs(Actual - Expected) < 60000, StrSubstNo('Expected %1 to be within 60s of the service-local time %2.', Actual, Expected));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReservationFallbackUsesServiceLocalTime()
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmSchEntry: Record "NPR TM Admis. Schedule Entry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        NotifyParticpt: Codeunit "NPR TM Ticket Notify Particpt.";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit "Assert";
        ProfileCode: Code[10];
        Expected: DateTime;
        Actual: DateTime;
        FutureAdmissionStart: DateTime;
    begin
        // [Scenario] When a reservation reminder computes to a moment which has already passed, it is bumped to the service local wall clock rather than to the clock of the session that creates it.

        // [GIVEN] A service time zone which is hours away from the time zone of the session running the test
        SetServiceTimeZoneToUtcPlus12();

        // [GIVEN] A confirmed reservation whose admission carries a reservation profile with a 48 hour lead time
        ProfileCode := CreateNotificationProfile(ProfileLine."Notification Trigger"::RESERVATION, ProfileLine."Unit of Measure"::HOURS, 48);
        ArrangeConfirmedReservationTicket(ProfileCode, Ticket, TicketAccessEntry);

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        Assert.IsTrue(DetTicketAccessEntry.FindFirst(), 'Expected a RESERVATION detail ticket access entry.');

        AdmSchEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
        AdmSchEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmSchEntry.FindLast(), 'Expected an admission schedule entry linked to the reservation.');

        // [GIVEN] The admission starts in two hours, which puts the 48 hour lead time 46 hours in the past
        Expected := TimeHelper.GetLocalTimeForService();
        FutureAdmissionStart := Expected + (2 * 3600 * 1000);
        AdmSchEntry."Admission Start Date" := DT2Date(FutureAdmissionStart);
        AdmSchEntry."Admission Start Time" := DT2Time(FutureAdmissionStart);
        AdmSchEntry.Modify();

        // [WHEN] The reservation reminder is created
        NotifyParticpt.CreateAdmissionReservationReminder(TicketAccessEntry, Ticket."External Member Card No.");

        // [THEN] The pending reservation notification is bumped to the service local time
        NotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NotificationEntry.SetFilter("Ticket Trigger Type", '=%1', NotificationEntry."Ticket Trigger Type"::RESERVE);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        Assert.IsTrue(NotificationEntry.FindFirst(), 'Expected a pending RESERVE notification entry.');

        Actual := CreateDateTime(NotificationEntry."Date To Notify", NotificationEntry."Time To Notify");
        RestoreServiceTimeZone();
        Assert.IsTrue(Abs(Actual - Expected) < 60000, StrSubstNo('Expected %1 to be within 60s of the service-local time %2.', Actual, Expected));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OnEachAdmissionUsesServiceLocalCreatedTime()
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        NotifyParticpt: Codeunit "NPR TM Ticket Notify Particpt.";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit "Assert";
        ProfileCode: Code[10];
        Expected: DateTime;
        Actual: DateTime;
    begin
        // [Scenario] A post admission reminder is offset from the service local rendering of the admission timestamp, not from the clock of the session that creates it.

        // [GIVEN] A service time zone which is hours away from the time zone of the session running the test
        SetServiceTimeZoneToUtcPlus12();

        // [GIVEN] A confirmed ticket whose admission carries an on each admission profile with a one day offset
        ProfileCode := CreateNotificationProfile(ProfileLine."Notification Trigger"::ON_EACH_ADMISSION, ProfileLine."Unit of Measure"::DAYS, 1);
        ArrangeConfirmedTicket(ProfileCode, Ticket, TicketAccessEntry);

        // [GIVEN] The admission detail entry written by the ticket confirmation
        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        Assert.IsTrue(DetTicketAccessEntry.FindFirst(), 'Expected an INITIAL_ENTRY detail ticket access entry.');

        // [WHEN] The post admission notification is created
        Expected := TimeHelper.GetLocalTimeForService() + (24 * 3600 * 1000);
        NotifyParticpt.CreateOnAdmissionNotification(TicketAccessEntry, DetTicketAccessEntry, false);

        // [THEN] The pending notification is scheduled one day after the service local admission time
        NotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NotificationEntry.SetFilter("Ticket Trigger Type", '=%1', NotificationEntry."Ticket Trigger Type"::ADMIT);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        Assert.IsTrue(NotificationEntry.FindFirst(), 'Expected a pending ADMIT notification entry.');

        Actual := CreateDateTime(NotificationEntry."Date To Notify", NotificationEntry."Time To Notify");
        RestoreServiceTimeZone();
        Assert.IsTrue(Abs(Actual - Expected) < 60000, StrSubstNo('Expected %1 to be within 60s of the service-local time %2.', Actual, Expected));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BatchPickupSelectsServiceLocalDueEntries()
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DueEntry: Record "NPR TM Ticket Notif. Entry";
        NotDueEntry: Record "NPR TM Ticket Notif. Entry";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        NotifyParticpt: Codeunit "NPR TM Ticket Notify Particpt.";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit "Assert";
        ProfileCode: Code[10];
        NowAtService: DateTime;
        DueEntryNo: Integer;
        NotDueEntryNo: Integer;
    begin
        // [Scenario] The batch job selects reminders whose notify moment has passed on the service clock, so the pickup filter reads the same basis that scheduling writes.

        // [GIVEN] A service time zone which is hours away from the time zone of the session running the test
        SetServiceTimeZoneToUtcPlus12();

        // [GIVEN] A pending batch reminder
        ProfileCode := CreateNotificationProfile(ProfileLine."Notification Trigger"::WELCOME, ProfileLine."Unit of Measure"::DAYS, 0);
        ArrangeConfirmedTicket(ProfileCode, Ticket, TicketAccessEntry);

        DueEntryNo := NotifyParticpt.CreateAdmissionWelcomeReminder(TicketAccessEntry, Ticket."External Member Card No.");
        Assert.AreNotEqual(0, DueEntryNo, 'Expected the welcome reminder to be created.');

        DueEntry.Get(DueEntryNo);
        Assert.AreEqual(DueEntry."Notification Process Method"::BATCH, DueEntry."Notification Process Method", 'Expected reminder creation to default to the BATCH process method.');
        Assert.AreEqual(DueEntry."Notification Send Status"::PENDING, DueEntry."Notification Send Status", 'Expected a newly created reminder to start out PENDING.');

        // [GIVEN] Its notify moment is stamped a minute into the service local past, and a copy is stamped three hours into the service local future.
        // The moments are written here rather than derived from creation, so the assertions pin the pickup filter's own basis.
        NowAtService := TimeHelper.GetLocalTimeForService();
        SetNotifyMoment(DueEntryNo, NowAtService - 60000);
        NotDueEntryNo := CopyEntryWithNotifyMoment(DueEntryNo, NowAtService + (3 * 3600 * 1000));

        // [WHEN] The notification batch job runs
        Commit();
        if (not Codeunit.Run(Codeunit::"NPR TM Ticket Notify Particpt.")) then begin
            RestoreServiceTimeZoneAndCommit();
            Error(GetLastErrorText());
        end;

        // [THEN] The due reminder was selected for sending, and the one still ahead on the service clock was left alone
        DueEntry.Get(DueEntryNo);
        NotDueEntry.Get(NotDueEntryNo);
        RestoreServiceTimeZoneAndCommit();

        Assert.AreNotEqual(DueEntry."Notification Send Status"::PENDING, DueEntry."Notification Send Status",
            'A reminder due on the service clock stayed PENDING, so the pickup filter reads a different time basis.');
        Assert.AreEqual(NotDueEntry."Notification Send Status"::PENDING, NotDueEntry."Notification Send Status",
            'A reminder not yet due on the service clock was sent, so the pickup filter is not bounded by the notify moment.');
    end;

    [Normal]
    local procedure SetServiceTimeZoneToUtcPlus12()
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TimeZone: Record "Time Zone";
    begin
        TimeZone.SetRange(ID, 'UTC+12');
        if (not TimeZone.FindFirst()) then
            Error('UTC+12 not found in the Time Zone table. This test requires a BC environment with standard timezone data.');

        if (not TicketSetup.Get()) then begin
            TicketSetup.Init();
            TicketSetup.Insert();
        end;

        // Capture the value from before any test in this codeunit touched it. Codeunit globals survive
        // between test methods, so under a runner that does not roll back this still holds the pristine
        // value instead of the UTC+12 an earlier test left behind.
        if (not _PristineTimeZoneCaptured) then begin
            _PristineTimeZoneNo := TicketSetup.ServiceTimeZoneNo;
            _PristineTimeZoneCaptured := true;
        end;

        TicketSetup.ServiceTimeZoneNo := TimeZone."No.";
        TicketSetup.Modify();
    end;

    [Normal]
    local procedure SetNotifyMoment(EntryNo: Integer; NotifyAt: DateTime)
    var
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        NotificationEntry.Get(EntryNo);
        NotificationEntry."Date To Notify" := DT2Date(NotifyAt);
        NotificationEntry."Time To Notify" := DT2Time(NotifyAt);
        NotificationEntry.Modify();
    end;

    [Normal]
    local procedure CopyEntryWithNotifyMoment(SourceEntryNo: Integer; NotifyAt: DateTime) EntryNo: Integer
    var
        SourceEntry: Record "NPR TM Ticket Notif. Entry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        SourceEntry.Get(SourceEntryNo);
        NotificationEntry := SourceEntry;
        NotificationEntry."Entry No." := 0;
        NotificationEntry."Date To Notify" := DT2Date(NotifyAt);
        NotificationEntry."Time To Notify" := DT2Time(NotifyAt);
        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::PENDING;
        NotificationEntry.Insert();
        EntryNo := NotificationEntry."Entry No.";
    end;

    [Normal]
    local procedure RestoreServiceTimeZone()
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (not _PristineTimeZoneCaptured) then
            exit;

        if (not TicketSetup.Get()) then
            exit;

        TicketSetup.ServiceTimeZoneNo := _PristineTimeZoneNo;
        TicketSetup.Modify();
    end;

    [Normal]
    local procedure RestoreServiceTimeZoneAndCommit()
    begin
        // The batch pickup test commits before running the job, so its restore has to be committed too -
        // otherwise the rollback at test end would drop the restore and keep the committed UTC+12.
        RestoreServiceTimeZone();
        Commit();
    end;

    [Normal]
    local procedure CreateNotificationProfile(NotificationTrigger: Option; UnitOfMeasure: Option; Units: Integer) ProfileCode: Code[10]
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
    begin
        LibTicket.CreateMinimalSetup();
        ProfileCode := LibTicket.GenerateCode10();

        NotificationProfile.Init();
        NotificationProfile."Profile Code" := ProfileCode;
        NotificationProfile.Blocked := false;
        NotificationProfile.Insert();

        ProfileLine.Init();
        ProfileLine."Profile Code" := ProfileCode;
        ProfileLine."Line No." := 100;
        ProfileLine."Notification Trigger" := NotificationTrigger;
        ProfileLine."Unit of Measure" := UnitOfMeasure;
        ProfileLine.Units := Units;
        ProfileLine.Blocked := false;
        ProfileLine.Insert();
    end;

    [Normal]
    local procedure ArrangeConfirmedTicket(ProfileCode: Code[10]; var Ticket: Record "NPR TM Ticket"; var TicketAccessEntry: Record "NPR TM Ticket Access Entry")
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
        TicketApiLibrary: Codeunit "NPR Library-TicketXmlApiPublic";
        Assert: Codeunit "Assert";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        ResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        LibTicket.CreateMinimalSetup();

        TicketTypeCode := LibTicket.CreateTicketType(LibTicket.GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := LibTicket.CreateAdmissionCode(LibTicket.GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');
        ScheduleCode := LibTicket.CreateSchedule(LibTicket.GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, Today(), AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000000.010T, 235959.990T, true, true, true, true, true, true, true, '');
        LibTicket.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');

        ItemNo := LibTicket.CreateItem('', TicketTypeCode, 100);
        LibTicket.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, true, Today());

        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Notification Profile Code" := ProfileCode;
        TicketBom.Modify();

        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, 'test@navipartner.com', 'TM-NOTIFY-REM-TEST', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        TmpCreatedTickets.FindFirst();
        Ticket.Get(TmpCreatedTickets."No.");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        Assert.IsTrue(TicketAccessEntry.FindFirst(), 'Expected a ticket access entry for the confirmed ticket.');
    end;

    [Normal]
    local procedure ArrangeConfirmedReservationTicket(ProfileCode: Code[10]; var Ticket: Record "NPR TM Ticket"; var TicketAccessEntry: Record "NPR TM Ticket Access Entry")
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
        TicketApiLibrary: Codeunit "NPR Library-TicketXmlApiPublic";
        Assert: Codeunit "Assert";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        ReservationDate: Date;
        ResponseToken: Text[100];
        ResponseMessage: Text;
        ApiOk: Boolean;
    begin
        // Only a reservation type admission (OCCASION with Default Schedule::SCHEDULE_ENTRY) yields a RESERVATION detail entry.
        LibTicket.CreateMinimalSetup();

        TicketTypeCode := LibTicket.CreateTicketType(LibTicket.GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := LibTicket.CreateAdmissionCodeReservation(LibTicket.GenerateCode20(), Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY, '', '', '<+5D>');
        ScheduleCode := LibTicket.CreateSchedule(LibTicket.GenerateCode20(), AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, Today(), AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 103000T, 120000T, true, true, true, true, true, true, true, '');
        LibTicket.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');

        ItemNo := LibTicket.CreateItem('', TicketTypeCode, 100);
        LibTicket.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ReservationDate := CalcDate('<+1D>', Today());
        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, true, ReservationDate);

        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Notification Profile Code" := ProfileCode;
        TicketBom.Modify();

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReservationDate);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmissionScheduleEntry.FindFirst(), 'Expected an admission schedule entry for the reservation date.');

        ApiOk := TicketApiLibrary.MakeReservation(1, ItemNo, 1, AdmissionScheduleEntry."External Schedule Entry No.", '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, 'test@navipartner.com', 'TM-NOTIFY-REM-TEST', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        TmpCreatedTickets.FindFirst();
        Ticket.Get(TmpCreatedTickets."No.");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        Assert.IsTrue(TicketAccessEntry.FindFirst(), 'Expected a ticket access entry for the confirmed ticket.');
    end;
}
