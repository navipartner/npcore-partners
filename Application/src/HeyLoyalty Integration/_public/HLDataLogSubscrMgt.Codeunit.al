codeunit 6151398 "NPR HL Data Log Subscr. Mgt."
{
    Access = Public;

    procedure AddDataLogSetupEntity(IntegrationArea: Enum "NPR HL Integration Area"; TableId: Integer; LogInsertion: Integer; LogModification: Integer; LogDeletion: Integer; KeepLogFor: Duration)
    var
        HLDataLogSubscrMgt: Codeunit "NPR HL DLog Subscr. Mgt. Impl.";
    begin
        HLDataLogSubscrMgt.AddDataLogSetupEntity(IntegrationArea, TableId, LogInsertion, LogModification, LogDeletion, KeepLogFor);
    end;

    [Obsolete('Use Codeunit::[NPR Job Queue Management].DaysToDuration(NoOfDays: Integer) instead', 'NPR32.0')]
    procedure DaysToDuration(NoOfDays: Integer): Duration
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        exit(JobQueueMgt.DaysToDuration(NoOfDays));
    end;
}