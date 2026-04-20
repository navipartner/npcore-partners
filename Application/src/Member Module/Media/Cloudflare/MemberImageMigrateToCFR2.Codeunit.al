codeunit 6248573 "NPR MemberImageMigrateToCFR2"
{
    Access = Internal;
    Description = 'Migrates member images stored in Media to Cloudflare R2 and removes them from Media.';


    var
        _NotEnabledMsg: Label 'Cloudflare Media feature is not enabled. Please enable the feature to run this job.';
        _IsMigrating: Label 'A migration task is already running. Please wait until it completes before starting a new one.';
        _CFFeature: Codeunit "NPR MemberImageMediaFeature";

    trigger OnRun()
    var
        FullMemberScan: Boolean;
    begin
        if (not _CFFeature.IsFeatureEnabled()) then
            Error(_NotEnabledMsg);

        FullMemberScan := SetMigrationStartTime();

        RunMigrationFromEnqueued();
        if (FullMemberScan) then
            RunMigrationFull();

        SetMigrationCompletionTime(FullMemberScan);
    end;

    internal procedure StartMigrationAsync(): Boolean
    var
        MigrationStatus: Record "NPR MemberImageMigrateToCFR2";
        TaskCreated: Label 'A task to migrate member images to Cloudflare R2 has been created successfully and is scheduled for immediate execution.';
        UnableToCreateTaskMessage: Label 'It is not possible to create a new task at this time due to user/app entitlement limits.';
        TaskGuid: Guid;
    begin
        if (not _CFFeature.IsFeatureEnabled()) then
            Error(_NotEnabledMsg);

        if (not TaskScheduler.CanCreateTask()) then
            Error(UnableToCreateTaskMessage);

        if (not MigrationStatus.Get()) then begin
            MigrationStatus.Init();
            MigrationStatus.Insert();
        end;

        if (IsMigrationRunning()) then
            Error(_IsMigrating);

        MigrationStatus.Get();
        MigrationStatus.StartTime := CurrentDateTime();
        MigrationStatus.CompletionTime := 0DT;
        MigrationStatus.LastFullScanStartTime := 0DT;
        MigrationStatus.Modify();

        TaskGuid := TaskScheduler.CreateTask(Codeunit::"NPR MemberImageMigrateToCFR2", Codeunit::"NPR MemberImageMigrateToCFErr", true, CompanyName(), CurrentDateTime());

        MigrationStatus.Get();
        MigrationStatus.TaskId := TaskGuid;
        MigrationStatus.Modify();
        Commit();

        LogMessage(StrSubstNo('[Member Media] Migration Task created with GUID: %1', Format(TaskGuid, 0, 4).ToLower()));
        Message(TaskCreated);

        exit(true);
    end;


    internal procedure CheckMigrationStatus(): Text
    var
        MigrationStatus: Record "NPR MemberImageMigrateToCFR2";
        NotStartedYet: Label 'No migration has been started yet.';
        NotCompletedYet: Label 'Migration has been started but has not completed yet.';
        Completed: Label 'Last migration completed at %1.';
    begin
        if (not MigrationStatus.Get()) then
            exit(NotStartedYet);

        if (MigrationStatus.StartTime = 0DT) then
            exit(NotStartedYet);

        if (MigrationStatus.CompletionTime = 0DT) then
            exit(NotCompletedYet);

        exit(StrSubstNo(Completed, Format(MigrationStatus.CompletionTime, 0, 9)));
    end;

    local procedure RunMigrationFromEnqueued(): Integer
    var
        MemberMediaUploadQueue: Record "NPR MM MemberMediaUploadQueue";
        Member: Record "NPR MM Member";
        MigratedCount: Integer;
    begin
        if (MemberMediaUploadQueue.FindSet()) then
            repeat
                Commit();
                if (Member.GetBySystemId(MemberMediaUploadQueue.MemberSystemId)) then
                    if (MigrateMemberImage(Member)) then
                        MigratedCount += 1;

                // Regardless of whether migration succeeded or not, we remove the entry from the queue to avoid blocking future attempts for the same member.
                if (not MemberMediaUploadQueue.Delete()) then; // Ignore - record might have been deleted by another process

            until (MemberMediaUploadQueue.Next() = 0);

        if (MigratedCount > 0) then
            LogMessage(StrSubstNo('[Member Media] %1 member images migrated from the queue.', MigratedCount));

        exit(MigratedCount);
    end;


    local procedure RunMigrationFull(): Integer
    var
        Member: Record "NPR MM Member";
        MemberCount, MigratedCount : Integer;
    begin
        MemberCount := Member.Count();

        MigratedCount := 0;
        if (Member.FindSet()) then
            repeat
                Commit();
                if (MigrateMemberImage(Member)) then
                    MigratedCount += 1;
            until (Member.Next() = 0);

        if (MigratedCount > 0) then
            LogMessage(StrSubstNo('[Member Media] %1 members scanned, %2 member images migrated.', MemberCount, MigratedCount));

        exit(MigratedCount);
    end;

    local procedure MigrateMemberImage(Member: Record "NPR MM Member"): Boolean
    var
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InsStr: InStream;
    begin
        if (IsNullGuid(Member.SystemId)) then
            exit(false);

        if (not Member.Image.HasValue()) then
            exit(false);

        TempBlob.CreateOutStream(OutStr);
        Member.Image.ExportStream(OutStr);
        TempBlob.CreateInStream(InsStr);

        if (not MemberMedia.PutMemberImageFromStream(Member.SystemId, '', InsStr)) then
            exit(false);

        Member.SetLoadFields("Entry No.", Image, SystemId);
        Member.GetBySystemId(Member.SystemId);
        Clear(Member.Image);
        if (not Member.Modify()) then; // Ignore error - I will get you next time ...

        exit(true);
    end;

    local procedure SetMigrationStartTime(): Boolean
    var
        MigrationStatus: Record "NPR MemberImageMigrateToCFR2";
    begin
        if (not MigrationStatus.Get()) then begin
            MigrationStatus.Init();
            MigrationStatus.Insert();
        end;
        MigrationStatus.StartTime := CurrentDateTime();
        MigrationStatus.CompletionTime := 0DT;
        MigrationStatus.Modify();

        // exit true for full member scan
        if (MigrationStatus.LastFullScanStartTime = 0DT) then
            exit(true);

        exit((CurrentDateTime() - MigrationStatus.LastFullScanStartTime) > 3600 * 1000);

    end;

    local procedure SetMigrationCompletionTime(FullMemberScan: Boolean)
    var
        MigrationStatus: Record "NPR MemberImageMigrateToCFR2";
    begin
        MigrationStatus.Get();
        MigrationStatus.CompletionTime := CurrentDateTime();
        if (FullMemberScan) then
            MigrationStatus.LastFullScanStartTime := MigrationStatus.CompletionTime;
        Clear(MigrationStatus.TaskId);

        MigrationStatus.Modify();

        if (FullMemberScan) then
            LogMessage(StrSubstNo('[Member Media] Full Migration Completed: %1', Format(CurrentDateTime(), 0, 9)))
        else
            LogMessage(StrSubstNo('[Member Media] Incremental Migration Completed: %1', Format(CurrentDateTime(), 0, 9)));

    end;

    local procedure IsMigrationRunning(): Boolean
    var
        MigrationStatus: Record "NPR MemberImageMigrateToCFR2";
    begin
        if (not MigrationStatus.Get()) then
            exit(false);

        if (IsNullGuid(MigrationStatus.TaskId)) then
            exit(false);

        if (not TaskScheduler.TaskExists(MigrationStatus.TaskId)) then
            exit(false);

        if (Confirm('A migration task is already running, started at %1. Do you want to force a new migration task to start?', false, MigrationStatus.StartTime)) then begin
            TaskScheduler.CancelTask(MigrationStatus.TaskId);
            MigrationStatus.Init();
            MigrationStatus.Modify();
            exit(false);
        end;

        exit(true);
    end;

    local procedure LogMessage(ResponseMessage: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            ActiveSession.Init();

        CustomDimensions.Add('NPR_FunctionName', 'MigrateMemberImage (status)');
        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        Session.LogMessage('NPR_MemberMediaMigration', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;


}