codeunit 6184773 "NPR TM TimeHelper"
{
    Access = Internal;

    var
        _UFormat: Label '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>', Locked = true;
        _UTCTimeZoneCode: Label '+00:00', Locked = true;

    #region Admission
    internal procedure GetLocalTimeAtAdmission(AdmissionCode: Code[20]) LocalDateTime: DateTime
    var
        TimeZoneCodeOut: Code[20];
        IsDaylightSavingsTime: Boolean;
    begin
        LocalDateTime := GetLocalTimeAtAdmission(AdmissionCode, TimeZoneCodeOut, IsDaylightSavingsTime);
    end;


    internal procedure GetLocalTimeAtAdmission(AdmissionCode: Code[20]; var TimeZoneCodeOut: Code[20]; var IsDaylightSavingsTime: Boolean) LocalDateTime: DateTime
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        Admission: Record "NPR TM Admission";
        TimeZoneNo: Integer;
    begin
        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        TimeZoneNo := TicketSetup.ServiceTimeZoneNo;

        if (Admission.Get(AdmissionCode)) then
            if (Admission.TimeZoneNo <> 0) then
                TimeZoneNo := Admission.TimeZoneNo;

        LocalDateTime := GetTimeZoneLocalTime(TimeZoneNo, TimeZoneCodeOut, IsDaylightSavingsTime);
    end;

    internal procedure GetLocalTimeAtAdmissionAsText(AdmissionCode: Code[20]) LocalTimeAsText: Text
    begin
        LocalTimeAsText := GetLocalTimeAtAdmissionAsText(AdmissionCode, _UFormat);
    end;

    internal procedure GetLocalTimeAtAdmissionAsText(AdmissionCode: Code[20]; Format: Text) LocalTimeAsText: Text
    var
        TimeZoneCode: Code[20];
        IsDaylightSavingsTime: Boolean;
    begin
        LocalTimeAsText := Format(GetLocalTimeAtAdmission(AdmissionCode, TimeZoneCode, IsDaylightSavingsTime), 0, Format) + ' ' + TimeZoneCode;
        if (IsDaylightSavingsTime) then
            LocalTimeAsText := LocalTimeAsText + ' DST';
    end;

    #endregion

    #region Service


    internal procedure GetLocalTimeForService(var TimeZoneCode: Code[20]; var IsDaylightSavingsTime: Boolean) LocalDateTime: DateTime
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        LocalDateTime := GetTimeZoneLocalTime(TicketSetup.ServiceTimeZoneNo, TimeZoneCode, IsDaylightSavingsTime);
    end;

    internal procedure GetLocalTimeForServiceAsText() LocalTimeAsText: Text
    begin
        LocalTimeAsText := GetLocalTimeForServiceAsText(_UFormat);
    end;

    internal procedure GetLocalTimeForServiceAsText(Format: Text) LocalTimeAsText: Text
    var
        TimeZoneCode: Code[20];
        IsDaylightSavingsTime: Boolean;
    begin
        LocalTimeAsText := Format(GetLocalTimeForService(TimeZoneCode, IsDaylightSavingsTime), 0, Format) + ' ' + TimeZoneCode;
        if (IsDaylightSavingsTime) then
            LocalTimeAsText := LocalTimeAsText + ' DST';
    end;
    #endregion


    local procedure GetDstOffset(TimeZoneNo: Integer; DateToCheck: Date; var IsDaylightSavingsTime: Boolean): Duration
    begin
        IsDaylightSavingsTime := IsDst(TimeZoneNo, DateToCheck);
        if (IsDaylightSavingsTime) then
            exit(3600000)
        else
            exit(0);
    end;

    local procedure IsDst(TimeZoneNo: Integer; DateToCheck: Date): Boolean
    begin
        case TimeZoneNo of
            48, // UTC +00:00 Europe
            52, 53, 54, 55, // UTC +01:00 Europe
            57, 60, 64: // UTC +02:00 Europe 
                exit(CheckDstEurope(DateToCheck));
            else
                exit(false);
        end;
    end;

    internal procedure CheckDstEurope(DateToCheck: Date): Boolean
    var
        Year: Integer;
        Month: Integer;
    begin
        // Summer time in Europe
        // Last Sunday in March (25-31) to last Sunday in October (25-31)
        Month := Date2DMY(DateToCheck, 2);
        if (Month < 3) or (Month > 10) then exit(false);
        if (Month > 3) and (Month < 10) then exit(true);

        Year := Date2DMY(DateToCheck, 3);
        if (Month = 3) then exit(CalcDate('<+1D-WD7>', DateToCheck) >= Dmy2Date(25, 3, Year));
        if (Month = 10) then exit(CalcDate('<+1D-WD7>', DateToCheck) < Dmy2Date(25, 10, Year));
    end;

    #region UTC

    internal procedure UtcNow(TimeZoneNo: Integer) UtcDateTime: DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        IsDaylightSavingsTime: Boolean;
    begin
        UtcDateTime := TypeHelper.GetCurrUTCDateTime();

        // When BC type casts from .net datetime to datetime in web client, it magically applies the user timezone offset and daylight savings. 
        // So we are not getting UTC time unless we remove those offsets.
        if (CurrentClientType = ClientType::Web) then
            UtcDateTime := UtcDateTime - GetUserTimeZoneOffset() - GetDstOffset(TimeZoneNo, DT2Date(UtcDateTime), IsDaylightSavingsTime);

    end;
    #endregion

    local procedure GetTimeZoneLocalTime(TimeZoneNo: Integer; var TimeZoneCode: Code[20]; var IsDaylightSavingsTime: Boolean) LocalDateTime: DateTime
    var
        TimeZone: Record "Time Zone";
        TimeZoneDuration: Duration;
    begin
        LocalDateTime := UtcNow(TimeZoneNo);
        TimeZoneCode := _UTCTimeZoneCode;

        if (TimeZoneNo = 0) then begin
            TimeZoneCode := GetUserTimeZoneOffsetAsText(TimeZoneDuration);
            LocalDateTime += TimeZoneDuration;
        end;

        if (TimeZone.Get(TimeZoneNo)) then begin
            LocalDateTime += GetDstOffset(TimeZoneNo, DT2Date(LocalDateTime), IsDaylightSavingsTime) + GetTimeZoneOffset(TimeZone.ID);

            if (StrPos(TimeZone."Display Name", ')') > 5) then
                TimeZoneCode := CopyStr(CopyStr(TimeZone."Display Name", 5, StrPos(TimeZone."Display Name", ')') - 5), 1, MaxStrLen(TimeZoneCode));
        end;
    end;

    local procedure GetTimezoneOffset(TimeZoneId: Text) TimezoneOffset: Duration
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        TypeHelper.GetTimezoneOffset(TimeZoneOffset, TimeZoneId);
    end;

    local procedure GetUserTimeZoneOffsetAsText(var TimezoneOffsetMs: Duration) TimeZoneCode: Code[20]
    var
        OffsetSign: Text;
        Hours: Integer;
        Minutes: Integer;
    begin
        TimeZoneCode := _UTCTimeZoneCode;
        TimezoneOffsetMs := GetUserTimeZoneOffset();

        Hours := Round(TimezoneOffsetMs Div 3600000);
        Minutes := Round((Abs(TimezoneOffsetMs) - Abs(Hours * 3600000)) Div 60000);
        OffsetSign := '+';
        if (TimezoneOffsetMs < 0) then
            OffsetSign := '-';
        TimeZoneCode := CopyStr(StrSubstNo('%1%2:%3', OffsetSign, Format(Hours, 0, '<Integer>').PadLeft(2, '0'), Format(Minutes, 0, '<Integer>').PadLeft(2, '0')), 1, MaxStrLen(TimeZoneCode));
    end;

    local procedure GetUserTimeZoneOffset() TimezoneOffset: Duration
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if (not TypeHelper.GetUserTimeZoneOffset(TimezoneOffset)) then
            TimezoneOffset := 0;
    end;
}