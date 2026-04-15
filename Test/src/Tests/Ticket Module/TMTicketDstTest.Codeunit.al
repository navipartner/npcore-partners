codeunit 85191 "NPR TM TicketDstTest"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestDaylightSavingTimeEurope()
    begin

        /* 
            https://en.wikipedia.org/wiki/Summer_time_in_Europe

            Start	End
            31 March 2019	27 October 2019
            29 March 2020	25 October 2020
            28 March 2021	31 October 2021
            27 March 2022	30 October 2022
            26 March 2023	29 October 2023
            31 March 2024	27 October 2024
            30 March 2025	26 October 2025
            29 March 2026 ?	25 October 2026
            28 March 2027 ?	31 October 2027
            26 March 2028 ?	29 October 2028
            25 March 2029 ?	28 October 2029
        */

        CheckDstEurope(DMY2Date(31, 3, 2019), DMY2Date(27, 10, 2019));
        CheckDstEurope(DMY2Date(29, 3, 2020), DMY2Date(25, 10, 2020));
        CheckDstEurope(DMY2Date(28, 3, 2021), DMY2Date(31, 10, 2021));
        CheckDstEurope(DMY2Date(27, 3, 2022), DMY2Date(30, 10, 2022));
        CheckDstEurope(DMY2Date(26, 3, 2023), DMY2Date(29, 10, 2023));
        CheckDstEurope(DMY2Date(31, 3, 2024), DMY2Date(27, 10, 2024));
        CheckDstEurope(DMY2Date(30, 3, 2025), DMY2Date(26, 10, 2025));
        CheckDstEurope(DMY2Date(29, 3, 2026), DMY2Date(25, 10, 2026));
        CheckDstEurope(DMY2Date(28, 3, 2027), DMY2Date(31, 10, 2027));
        CheckDstEurope(DMY2Date(26, 3, 2028), DMY2Date(29, 10, 2028));
        CheckDstEurope(DMY2Date(25, 3, 2029), DMY2Date(28, 10, 2029));

    end;

    [Normal]
    local procedure CheckDstEurope(DstStart: Date; DstEnd: Date)
    var
        DateRec: Record Date;
    begin

        // Beginning of year to DST start
        DateRec.SetFilter("Period Type", '=%1', DateRec."Period Type"::Date);
        DateRec.SetFilter("Period Start", '%1..%2', CalcDate('<CY-1Y+1D>', DstStart), CalcDate('<-1D>', DstStart));
        DateRec.FindSet();
        repeat
            VerifyNotDstEurope(DateRec."Period Start");
        until (DateRec.Next() = 0);

        // DST Period
        DateRec.SetFilter("Period Type", '=%1', DateRec."Period Type"::Date);
        DateRec.SetFilter("Period Start", '%1..%2', DstStart, CalcDate('<-1D>', DstEnd));
        DateRec.FindSet();
        repeat
            VerifyDstEurope(DateRec."Period Start");
        until (DateRec.Next() = 0);

        // DST end until end of year
        DateRec.SetFilter("Period Type", '=%1', DateRec."Period Type"::Date);
        DateRec.SetFilter("Period Start", '%1..%2', DstEnd, CalcDate('<CY>', DstEnd));
        DateRec.FindSet();
        repeat
            VerifyNotDstEurope(DateRec."Period Start");
        until (DateRec.Next() = 0);
    end;


#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    [Test]
    procedure DaysSinceUnixEpoch_SmokeTests()
    var
        Assert: Codeunit "Assert";
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        // https://howardhinnant.github.io/date_algorithms.html#days_from_civil

        Assert.AreEqual(0, MediaImpl.DaysSinceUnixEpoch(1970, 1, 1), '1970-01-01 must be day 0');
        Assert.AreEqual(1, MediaImpl.DaysSinceUnixEpoch(1970, 1, 2), '1970-01-02 must be day 1');
        Assert.AreEqual(-1, MediaImpl.DaysSinceUnixEpoch(1969, 12, 31), '1969-12-31 must be day -1');
        Assert.AreEqual(31, MediaImpl.DaysSinceUnixEpoch(1970, 2, 1), '1970-02-01 must be day 31');
        Assert.AreEqual(59, MediaImpl.DaysSinceUnixEpoch(1970, 3, 1), '1970-03-01 must be day 59');
        Assert.AreEqual(365, MediaImpl.DaysSinceUnixEpoch(1971, 1, 1), '1971-01-01 must be day 365');

        Assert.AreEqual(788, MediaImpl.DaysSinceUnixEpoch(1972, 2, 28), '1972-02-28 must be day 788');
        Assert.AreEqual(789, MediaImpl.DaysSinceUnixEpoch(1972, 2, 29), '1972-02-29 must be day 789');
        Assert.AreEqual(790, MediaImpl.DaysSinceUnixEpoch(1972, 3, 1), '1972-03-01 must be day 790');
        Assert.AreEqual(789, MediaImpl.DaysSinceUnixEpoch(1972, 2, 29), '1972-02-29 must be day 789');
        Assert.AreEqual(11016, MediaImpl.DaysSinceUnixEpoch(2000, 2, 29), '2000-02-29 must be day 11016');
        Assert.AreEqual(47541, MediaImpl.DaysSinceUnixEpoch(2100, 3, 1), '2100-03-01 must be day 47541');
    end;
#endif

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestAdmissionLocalDateTimeToUtc_RoundTrip()
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
        Admission: Record "NPR TM Admission";
        TimeZone: Record "Time Zone";
        AdmissionCode: Code[20];
    begin
        // Verifies that AdmissionLocalDateTimeToUtc and AdjustZuluToAdmissionLocalDateTime are true
        // inverses across all DST boundary dates for Europe 2026:
        //   Spring forward: March 29, 2026  |  Autumn back: October 25, 2026

        LibTicket.CreateMinimalSetup();
        AdmissionCode := LibTicket.CreateAdmissionCode('DST-RT-ADM', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');

        TimeZone.SetRange(ID, 'W. Europe Standard Time');
        if (not TimeZone.FindFirst()) then
            Error('W. Europe Standard Time not found in the Time Zone table. This test requires a BC environment with standard timezone data.');

        Admission.Get(AdmissionCode);
        Admission.TimeZoneNo := TimeZone."No.";
        Admission.Modify();

        // Winter (UTC+1, no DST)
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(15, 1, 2026), 140000T);
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(15, 12, 2026), 140000T);

        // Day before spring forward (still UTC+1) → spring forward day (UTC+2)
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(28, 3, 2026), 140000T);
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(29, 3, 2026), 140000T);

        // Summer (UTC+2, DST active)
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(15, 7, 2026), 140000T);

        // Day before autumn back (still UTC+2) → autumn back day (UTC+1)
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(24, 10, 2026), 140000T);
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(25, 10, 2026), 140000T);

        // Just past midnight – exercises date boundary arithmetic
        // TODO code does not handle spring forward at 2:00, so this test currently fails. 
        // VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(29, 3, 2026), 000100T);
        // TODO code does not handle autumn back at 3:00, so this test currently fails.
        // VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(25, 10, 2026), 000100T);

        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(29, 3, 2026), 050000T);
        VerifyLocalToUtcRoundTrip(AdmissionCode, DMY2Date(25, 10, 2026), 050000T);


    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestAdmissionLocalDateTimeToUtc_UtcOffsets()
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit Assert;
        Admission: Record "NPR TM Admission";
        TimeZone: Record "Time Zone";
        AdmissionCode: Code[20];
        TestTime: Time;
        OneHour: Duration;
        TwoHours: Duration;
    begin
        // Verifies the exact UTC values produced by AdmissionLocalDateTimeToUtc for
        // W. Europe Standard Time (Sweden/Denmark/Germany: UTC+1 winter, UTC+2 summer DST).
        //
        // The DST assertions (UTC-2h) require that this timezone's record No. in the Time Zone
        // table falls within the set {48, 52-55, 57, 60, 64} in TMTimeHelper.IsDst. 
        LibTicket.CreateMinimalSetup();
        AdmissionCode := LibTicket.CreateAdmissionCode('DST-OV-ADM', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');

        TimeZone.SetRange(ID, 'W. Europe Standard Time');
        if (not TimeZone.FindFirst()) then
            Error('W. Europe Standard Time not found in the Time Zone table. This test requires a BC environment with standard timezone data.');

        Admission.Get(AdmissionCode);
        Admission.TimeZoneNo := TimeZone."No.";
        Admission.Modify();

        TestTime := 140000T;
        OneHour := 3600000;
        TwoHours := 7200000;

        // Winter: UTC = local − 1h  (base offset UTC+1, no DST)
        Assert.AreEqual(CreateDateTime(DMY2Date(15, 1, 2026), TestTime) - OneHour,
            TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, DMY2Date(15, 1, 2026), TestTime),
            'Jan (winter): local 14:00 must map to 13:00 UTC');
        Assert.AreEqual(CreateDateTime(DMY2Date(28, 3, 2026), TestTime) - OneHour,
            TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, DMY2Date(28, 3, 2026), TestTime),
            'Mar 28 (day before spring forward): local 14:00 must map to 13:00 UTC');

        // Spring forward and summer: UTC = local − 2h  (UTC+1 base + 1h DST)
        Assert.AreEqual(CreateDateTime(DMY2Date(29, 3, 2026), TestTime) - TwoHours,
            TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, DMY2Date(29, 3, 2026), TestTime),
            'Mar 29 (spring forward): local 14:00 must map to 12:00 UTC');
        Assert.AreEqual(CreateDateTime(DMY2Date(15, 7, 2026), TestTime) - TwoHours,
            TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, DMY2Date(15, 7, 2026), TestTime),
            'Jul (summer): local 14:00 must map to 12:00 UTC');
        Assert.AreEqual(CreateDateTime(DMY2Date(24, 10, 2026), TestTime) - TwoHours,
            TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, DMY2Date(24, 10, 2026), TestTime),
            'Oct 24 (day before autumn back): local 14:00 must map to 12:00 UTC');

        // Autumn back and winter: back to UTC = local − 1h
        Assert.AreEqual(CreateDateTime(DMY2Date(25, 10, 2026), TestTime) - OneHour,
            TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, DMY2Date(25, 10, 2026), TestTime),
            'Oct 25 (autumn back): local 14:00 must map to 13:00 UTC');
        Assert.AreEqual(CreateDateTime(DMY2Date(15, 12, 2026), TestTime) - OneHour,
            TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, DMY2Date(15, 12, 2026), TestTime),
            'Dec (winter): local 14:00 must map to 13:00 UTC');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestGetNextScheduleStartDateTime_UtcOffsetApplied()
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit Assert;
        Admission: Record "NPR TM Admission";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TimeZone: Record "Time Zone";
        AdmissionCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        SuggestedNextUpdateTime: DateTime;
        ResultAdmissionLocal: DateTime;
        ResultLocalTime: Time;
    begin
        LibTicket.CreateMinimalSetup();

        AdmissionCode := LibTicket.CreateAdmissionCode('DST-SCH-ADM', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');
        TimeZone.SetRange(ID, 'W. Europe Standard Time');
        TimeZone.FindFirst();
        Admission.Get(AdmissionCode);
        Admission.TimeZoneNo := TimeZone."No.";
        Admission.Modify();

        // Two schedules at different times of day, running every day from a past start date
        LibTicket.CreateSchedule('DST-S-0900', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN,
            DMY2Date(1, 1, 2020), AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE,
            090000T, 100000T, true, true, true, true, true, true, true, '');
        LibTicket.CreateScheduleLine(AdmissionCode, 'DST-S-0900', 1, false, 999, ScheduleLine."Capacity Control"::ADMITTED, '<+7D>', 0, 0, '');

        LibTicket.CreateSchedule('DST-S-1500', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN,
            DMY2Date(1, 1, 2020), AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE,
            150000T, 160000T, true, true, true, true, true, true, true, '');
        LibTicket.CreateScheduleLine(AdmissionCode, 'DST-S-1500', 2, false, 999, ScheduleLine."Capacity Control"::ADMITTED, '<+7D>', 0, 0, '');

        TicketTypeCode := LibTicket.CreateTicketType('DST-TT1', '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL,
            "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE,
            TicketType."Ticket Configuration Source"::TICKET_BOM);
        ItemNo := LibTicket.CreateItem('', TicketTypeCode, 100);
        LibTicket.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0,
            "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        // Ceiling: two days from now – comfortably beyond any same-day or next-day schedule
        SuggestedNextUpdateTime := CreateDateTime(CalcDate('<+2D>', Today()), 235959T);

        // Execute
        TicketManagement.GetNextPossibleAdmissionScheduleStartDateTime(ItemNo, '', SuggestedNextUpdateTime);

        // SuggestedNextUpdateTime is in user-local time (= UTC next schedule + user_offset).
        Assert.IsTrue(SuggestedNextUpdateTime > CurrentDateTime(), 'Next schedule time must be in the future');

        // Convert back to admission-local for assertion: 
        // subtract user offset to get UTC, then add admission offset.
        ResultAdmissionLocal := TimeHelper.AdjustZuluToAdmissionLocalDateTime(AdmissionCode, SuggestedNextUpdateTime - (CurrentDateTime() - TimeHelper.UtcNow()));
        ResultLocalTime := DT2Time(ResultAdmissionLocal);

        // Within 10 seconds of either 09:00 or 15:00 admission-local time to allow some jitter, verifying UTC offset is correctly applied.
        Assert.IsTrue(
            (Abs(ResultLocalTime - 090000T) < 10000) or (Abs(ResultLocalTime - 150000T) < 10000),
            StrSubstNo('Expected next schedule at 09:00 or 15:00 admission-local time, got %1', Format(ResultLocalTime)));
    end;

    [Normal]
    local procedure VerifyLocalToUtcRoundTrip(AdmissionCode: Code[20]; LocalDate: Date; LocalTime: Time)
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Assert: Codeunit Assert;
        UtcDateTime: DateTime;
    begin
        UtcDateTime := TimeHelper.AdjustAdmissionLocalDateTimeToUtc(AdmissionCode, LocalDate, LocalTime);
        Assert.AreEqual(
            CreateDateTime(LocalDate, LocalTime),
            TimeHelper.AdjustZuluToAdmissionLocalDateTime(AdmissionCode, UtcDateTime),
            StrSubstNo('Round-trip failed for %1 %2', Format(LocalDate, 0, 9), Format(LocalTime)));
    end;

    [Normal]
    local procedure VerifyNotDstEurope(TestDate: Date)
    var
        Assert: Codeunit "Assert";
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        Assert.IsFalse(TimeHelper.CheckDstEurope(TestDate), 'Date ' + Format(TestDate, 0, 9) + ' is reported as DST but it is not.');
    end;

    [Normal]
    local procedure VerifyDstEurope(TestDate: Date)
    var
        Assert: Codeunit "Assert";
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        Assert.IsTrue(TimeHelper.CheckDstEurope(TestDate), 'Date ' + Format(TestDate, 0, 9) + ' is not reported as DST but it is.');
    end;

}