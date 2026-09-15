codeunit 6151236 "NPR Spfy Schedule Detection JQ"
{
    Access = Internal;

    procedure EnsureChangeDetectionJobScheduled()
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        SetupChangeDetectionJobQueue(true);
    end;

    procedure SetupChangeDetectionJobQueue(Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        RunChangeDetectionLbl: Label 'Shopify RowVersion change detection';
    begin
        if not Enable then begin
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, DetectionCodeunitId());
            exit;
        end;

        JobQueueMgt.SetProtected(true);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, DetectionCodeunitId(),
            '', RunChangeDetectionLbl,
            JobQueueMgt.NowWithDelayInSeconds(60), 1,
            '', JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure DetectionCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Spfy Change Detection");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure RefreshChangeDetectionJobQueueEntry()
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        EnsureChangeDetectionJobScheduled();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNprCustomizableJob, '', false, false)]
    local procedure SetAsNprCustomizableJob(JobQueueEntry: Record "Job Queue Entry"; var NprCustomizableJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and (JobQueueEntry."Object ID to Run" = DetectionCodeunitId()) then begin
            NprCustomizableJob := true;
            Handled := true;
        end;
    end;
}
