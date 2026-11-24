codeunit 85568 "NPR JQ Refresh Order Recorder"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _ParameterPrefix: Text;
        _FailingParameterString: Text;
        _FailureText: Text;
        _SlowParameterString: Text;
        _SlowRefreshMs: Integer;
        _DeleteJobBeforeLock: Boolean;
        _Recorded: List of [Text];
        _Renewals: Integer;
        _DefinitionUpdates: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeRestoreJobQueueEntryFromMonitored, '', false, false)]
    local procedure RecordRefreshedEntry(var JobQueueEntry: Record "Job Queue Entry"; MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    begin
        if not MonitoredJQEntry."Parameter String".StartsWith(_ParameterPrefix) then
            exit;
        _Recorded.Add(MonitoredJQEntry."Parameter String");
        if MonitoredJQEntry."Parameter String" = _SlowParameterString then
            Sleep(_SlowRefreshMs);
        if MonitoredJQEntry."Parameter String" = _FailingParameterString then
            Error(_FailureText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeModifyUpdatedJobQueueEntry, '', false, false)]
    local procedure DeleteStoredJobBeforeTheLock(var JobQueueEntry: Record "Job Queue Entry")
    var
        StoredJobQueueEntry: Record "Job Queue Entry";
    begin
        if not JobQueueEntry."Parameter String".StartsWith(_ParameterPrefix) then
            exit;
        _DefinitionUpdates += 1;
        if not _DeleteJobBeforeLock then
            exit;
        if StoredJobQueueEntry.Get(JobQueueEntry.ID) then
            StoredJobQueueEntry.Delete();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure CountRenewal()
    begin
        _Renewals += 1;
    end;

    internal procedure SetParameterPrefix(ParameterPrefix: Text)
    begin
        _ParameterPrefix := ParameterPrefix;
    end;

    internal procedure FailRefreshOf(ParameterString: Text; FailureText: Text)
    begin
        _FailingParameterString := ParameterString;
        _FailureText := FailureText;
    end;

    internal procedure SlowDownRefreshOf(ParameterString: Text; RefreshMs: Integer)
    begin
        _SlowParameterString := ParameterString;
        _SlowRefreshMs := RefreshMs;
    end;

    internal procedure DeleteJobBeforeItIsLocked()
    begin
        _DeleteJobBeforeLock := true;
    end;

    internal procedure GetRecorded(): List of [Text]
    begin
        exit(_Recorded);
    end;

    internal procedure GetRenewals(): Integer
    begin
        exit(_Renewals);
    end;

    internal procedure GetDefinitionUpdates(): Integer
    begin
        exit(_DefinitionUpdates);
    end;
}
