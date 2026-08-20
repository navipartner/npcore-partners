codeunit 85383 "NPR Library - Time Zone"
{
    Access = Internal;

    var
        _WSSessionMock: Codeunit "NPR Library - WS Session Mock";
        TestTimeZoneIdLbl: Label 'Central Pacific Standard Time', Locked = true;
        TestEntraAppDescriptionLbl: Label 'NPR Time Zone Test App', Locked = true;

    procedure SetSessionEntraAppTimeZone()
    begin
        SetSessionEntraAppTimeZone(CopyStr(TestTimeZoneIdLbl, 1, 180));
    end;

    procedure SetSessionEntraAppTimeZone(TimeZoneId: Text[180])
    begin
        SetEntraAppTimeZone(TimeZoneId);
        BindSubscription(_WSSessionMock);
    end;

    procedure SetEntraAppTimeZone()
    begin
        SetEntraAppTimeZone(CopyStr(TestTimeZoneIdLbl, 1, 180));
    end;

    procedure SetEntraAppTimeZone(TimeZoneId: Text[180])
    var
        AADApplication: Record "AAD Application";
    begin
        ClearSessionEntraAppTimeZone();

        AADApplication.Init();
        AADApplication."Client Id" := CreateGuid();
        AADApplication.Description := CopyStr(TestEntraAppDescriptionLbl, 1, MaxStrLen(AADApplication.Description));
        AADApplication."User ID" := UserSecurityId();
        AADApplication."NPR Time Zone Id" := CopyStr(TimeZoneId, 1, MaxStrLen(AADApplication."NPR Time Zone Id"));
        AADApplication.Insert(false);
        Commit();
    end;

    procedure ClearSessionEntraAppTimeZone()
    var
        AADApplication: Record "AAD Application";
    begin
        UnbindSubscription(_WSSessionMock);

        AADApplication.SetRange("User ID", UserSecurityId());
        AADApplication.SetRange(Description, CopyStr(TestEntraAppDescriptionLbl, 1, MaxStrLen(AADApplication.Description)));
        AADApplication.DeleteAll(false);
        Commit();
    end;

    procedure AssertDateTimePartsInTimeZoneRange(ActualDate: Date; ActualTime: Time; FromUtc: DateTime; ToUtc: DateTime; Context: Text)
    var
        Assert: Codeunit Assert;
        ActualLocalDateTime: DateTime;
        FromLocalDateTime: DateTime;
        ToLocalDateTime: DateTime;
    begin
        ActualLocalDateTime := CreateDateTime(ActualDate, ActualTime);
        FromLocalDateTime := GetExpectedLocalWallClockDateTime(FromUtc);
        ToLocalDateTime := GetExpectedLocalWallClockDateTime(ToUtc) + 1000;

        Assert.IsTrue(
            (ActualLocalDateTime >= FromLocalDateTime) and (ActualLocalDateTime <= ToLocalDateTime),
            StrSubstNo('%1 was %2, expected between %3 and %4.', Context, Format(ActualLocalDateTime, 0, 9), Format(FromLocalDateTime, 0, 9), Format(ToLocalDateTime, 0, 9)));
    end;

    procedure AssertTimeInTimeZoneRange(ActualTime: Time; FromUtc: DateTime; ToUtc: DateTime; Context: Text)
    var
        Assert: Codeunit Assert;
        FromLocalDateTime: DateTime;
        ToLocalDateTime: DateTime;
        FromLocalTime: Time;
        ToLocalTime: Time;
        MatchesRange: Boolean;
    begin
        FromLocalDateTime := GetExpectedLocalWallClockDateTime(FromUtc);
        ToLocalDateTime := GetExpectedLocalWallClockDateTime(ToUtc) + 1000;
        FromLocalTime := DT2Time(FromLocalDateTime);
        ToLocalTime := DT2Time(ToLocalDateTime);

        if DT2Date(FromLocalDateTime) = DT2Date(ToLocalDateTime) then
            MatchesRange := (ActualTime >= FromLocalTime) and (ActualTime <= ToLocalTime)
        else
            MatchesRange := (ActualTime >= FromLocalTime) or (ActualTime <= ToLocalTime);

        Assert.IsTrue(
            MatchesRange,
            StrSubstNo('%1 was %2, expected between %3 and %4.', Context, Format(ActualTime), Format(FromLocalTime), Format(ToLocalTime)));
    end;

    local procedure GetExpectedLocalWallClockDateTime(SourceUtcDateTime: DateTime): DateTime
    var
        TestTimeZoneFixedOffsetFromUtcMs: Integer;
    begin
        TestTimeZoneFixedOffsetFromUtcMs := 11 * 60 * 60 * 1000;
        exit(GetUtcWallClockDateTime(SourceUtcDateTime) + TestTimeZoneFixedOffsetFromUtcMs);
    end;

    local procedure GetUtcWallClockDateTime(SourceDateTime: DateTime): DateTime
    var
        UtcDateTimeText: Text;
        UtcDate: Date;
        UtcTime: Time;
    begin
        UtcDateTimeText := DelChr(Format(SourceDateTime, 0, 9), '>', 'Z');
        Evaluate(UtcDate, CopyStr(UtcDateTimeText, 1, 10), 9);
        Evaluate(UtcTime, CopyStr(UtcDateTimeText, 12), 9);
        exit(CreateDateTime(UtcDate, UtcTime));
    end;
}
