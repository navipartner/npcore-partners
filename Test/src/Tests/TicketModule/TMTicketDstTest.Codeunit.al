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