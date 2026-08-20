codeunit 6151157 "NPR Time Zone Mgt."
{
    Access = Internal;

    internal procedure GetLocalDateTime(SourceDateTime: DateTime; var LocalDate: Date; var LocalTime: Time)
    var
        LocalDateTime: DateTime;
    begin
        if GetLocalWallClockDateTime(SourceDateTime, LocalDateTime) then begin
            LocalDate := DT2Date(LocalDateTime);
            LocalTime := DT2Time(LocalDateTime);
            exit;
        end;

        LocalDate := DT2Date(SourceDateTime);
        LocalTime := DT2Time(SourceDateTime);
    end;

    internal procedure GetLocalTime(SourceDateTime: DateTime): Time
    var
        LocalDate: Date;
        LocalTime: Time;
    begin
        GetLocalDateTime(SourceDateTime, LocalDate, LocalTime);
        exit(LocalTime);
    end;

    local procedure GetLocalWallClockDateTime(SourceDateTime: DateTime; var LocalDateTime: DateTime): Boolean
    var
        TimeZone: Codeunit "Time Zone";
        TimeZoneId: Text[180];
    begin
        LocalDateTime := 0DT;
        if SourceDateTime = 0DT then
            exit(false);
        if not IsWebserviceSession() then
            exit(false);

        TimeZoneId := GetWebserviceSessionTimeZoneId();
        if TimeZoneId = '' then
            exit(false);

        LocalDateTime := GetUtcWallClockDateTime(SourceDateTime) + TimeZone.GetTimezoneOffset(SourceDateTime, TimeZoneId);
        exit(true);
    end;

    local procedure IsWebserviceSession() Result: Boolean
    begin
        Result := CurrentClientType() in [ClientType::Api, ClientType::OData, ClientType::ODataV4, ClientType::SOAP];
        OnAfterIsWebserviceSession(Result);
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterIsWebserviceSession(var IsWebserviceSession: Boolean)
    begin
    end;

    local procedure GetWebserviceSessionTimeZoneId(): Text[180]
    var
        AADApplication: Record "AAD Application";
    begin
        if not AADApplication.ReadPermission() then
            exit('');

        AADApplication.SetLoadFields("NPR Time Zone Id");
        AADApplication.SetRange("User ID", UserSecurityId());
        if not AADApplication.FindFirst() then
            exit('');

        exit(AADApplication."NPR Time Zone Id");
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
