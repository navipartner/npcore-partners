codeunit 6248573 "NPR MemberImageMigrateToCFR2"
{
    Access = Internal;
    Description = 'Migrates member images stored in Media to Cloudflare R2 and removes them from Media.';


    var
        _NotEnabledMsg: Label 'Cloudflare Media feature is not enabled. Please enable the feature to run this job.';
        _IsMigrating: Label 'A migration task is already running. Please wait until it completes before starting a new one or reset the migration start time to be able to force a restart.';
        _CFFeature: Codeunit "NPR MemberImageMediaFeature";

    trigger OnRun()
    begin
        SetMigrationStartTime();
        RunMigration();
        SetMigrationCompletionTime();
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

        TaskGuid := TaskScheduler.CreateTask(Codeunit::"NPR MemberImageMigrateToCFR2", Codeunit::"NPR MemberImageMigrateToCFErr", true, CompanyName(), CurrentDateTime());

        MigrationStatus.TaskId := TaskGuid;
        MigrationStatus.StartTime := CurrentDateTime();
        MigrationStatus.CompletionTime := 0DT;
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


    local procedure RunMigration(): Integer
    var
        Member: Record "NPR MM Member";
        MemberCount, MigratedCount : Integer;
    begin
        if (not _CFFeature.IsFeatureEnabled()) then
            Error(_NotEnabledMsg);

        MemberCount := Member.Count();

        MigratedCount := 0;
        if (Member.FindSet()) then
            repeat
                Commit();
                if (MigrateMemberImage(Member)) then
                    MigratedCount += 1;
            until Member.Next() = 0;


        LogMessage(StrSubstNo('[Member Media] Total members processed: %1, total images migrated: %2', MemberCount, MigratedCount));
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

        // Put member image is relatively slow re-fetching the member record to clear the image
        Member.SetLoadFields("Entry No.", Image, SystemId);
        Member.GetBySystemId(Member.SystemId);
        Clear(Member.Image);
        if (not Member.Modify()) then; // Ignore error - I will get you next time ...

        exit(true);
    end;

    local procedure SetMigrationStartTime()
    var
        MigrationStatus: Record "NPR MemberImageMigrateToCFR2";
    begin
        MigrationStatus.Get();
        MigrationStatus.StartTime := CurrentDateTime();
        MigrationStatus.CompletionTime := 0DT;
        MigrationStatus.Modify();

        LogMessage(StrSubstNo('[Member Media] Migration Started: %1', Format(CurrentDateTime(), 0, 9)));
    end;

    local procedure SetMigrationCompletionTime()
    var
        MigrationStatus: Record "NPR MemberImageMigrateToCFR2";
    begin
        MigrationStatus.Get();
        MigrationStatus.CompletionTime := CurrentDateTime();
        Clear(MigrationStatus.TaskId);
        MigrationStatus.Modify();

        LogMessage(StrSubstNo('[Member Media] Migration Completed: %1', Format(CurrentDateTime(), 0, 9)));
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