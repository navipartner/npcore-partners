page 6185124 "NPR CloudflareMigrationJob"
{
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR CloudflareMigrationJob";
    CardPageId = "NPR CloudflareMigrationJobCard";

    Editable = false;
    Caption = 'Cloudflare Media Migration Jobs';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Job Id field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(TotalCount; Rec.TotalCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Total Count field.';
                }
                field(EnqueuedCount; Rec.EnqueuedCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enqueued Count field.';
                }

                field(SuccessCount; Rec.SuccessCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Success Count field.';
                }
                field(FailedCount; Rec.FailedCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Failed Count field.';
                }
                field(JobCancelled; Rec.JobCancelled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Job Cancelled field.';
                }
                field(RateLimitPerSecond; Rec.RateLimitPerSecond)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Rate Limit Per Second field.';
                }
                field(BatchId; Rec.BatchId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Batch Id field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(ImportFromFile)
            {
                Caption = 'Import Jobs from File';
                Image = Import;
                ToolTip = 'Imports migration jobs from a file.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                begin
                    CloudflareMedia.CreateMigrationJobFromJsonFileArray(ENUM::"NPR CloudflareMediaSelector"::MEMBER_PHOTO);
                    CurrPage.Update(false);
                end;
            }

            action(AssignToNewBatch)
            {
                Caption = 'Assign to New Batch';
                Image = NewDocument;
                ToolTip = 'Assigns selected jobs to a new batch.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    Jobs: Record "NPR CloudflareMigrationJob";
                    JobLines: Record "NPR CloudflareMigrationJobLine";
                    NewBatchId: Guid;
                begin
                    CurrPage.SetSelectionFilter(Jobs);
                    NewBatchId := CreateGuid();
                    if (Jobs.FindSet()) then
                        repeat
                            JobLines.SetFilter(JobId, '=%1', Jobs.JobId);
                            JobLines.ModifyAll(BatchId, NewBatchId);
                            Jobs.BatchId := NewBatchId;
                            Jobs.Modify();
                        until (Jobs.Next() = 0);
                    CurrPage.Update(false);
                end;
            }

            action(StartMigrationBatch)
            {
                Caption = 'Start Migration (Batch)';
                Image = ImportDatabase;
                ToolTip = 'Starts migration for jobs in same batch.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    Jobs: Record "NPR CloudflareMigrationJob";
                begin
                    if (IsNullGuid(Rec.BatchId)) then
                        Error('Please assign jobs to a batch to start migration in batch mode.');

                    Jobs.SetFilter(BatchId, '=%1', Rec.BatchId);
                    StartMigrationJob(Jobs);
                    CurrPage.Update(false);
                end;
            }

            action(CheckMigrationStatusBatch)
            {
                Caption = 'Check Migration Status (Batch)';
                Image = View;
                ToolTip = 'Checks migration status for jobs in same batch.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    Jobs: Record "NPR CloudflareMigrationJob";
                begin
                    if (IsNullGuid(Rec.BatchId)) then
                        Error('Please assign jobs to a batch to start migration in batch mode.');

                    Jobs.SetFilter(BatchId, '=%1', Rec.BatchId);
                    CheckJobStatus(Jobs);
                    CurrPage.Update(false);
                end;
            }

            action(FetchMigrationResultsBatch)
            {
                Caption = 'Fetch Migration Results (Batch)';
                Image = Download;
                ToolTip = 'Fetches migration results for jobs in same batch.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    Jobs: Record "NPR CloudflareMigrationJob";
                begin
                    if (IsNullGuid(Rec.BatchId)) then
                        Error('Please assign jobs to a batch to start migration in batch mode.');

                    Jobs.SetFilter(BatchId, '=%1', Rec.BatchId);
                    FetchMigrationResult(Jobs);
                    CurrPage.Update(false);
                end;
            }

            action(FinalizeMigrationBatch)
            {
                Caption = 'Finalize Migration (Batch)';
                Image = Approve;
                ToolTip = 'Finalizes migration for jobs in same batch.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    Jobs: Record "NPR CloudflareMigrationJob";
                begin
                    if (IsNullGuid(Rec.BatchId)) then
                        Error('Please assign jobs to a batch to start migration in batch mode.');

                    Jobs.SetFilter(BatchId, '=%1', Rec.BatchId);
                    FinalizeJobs(Jobs);
                    CurrPage.Update(false);
                end;
            }

            group(BatchProcessing)
            {
                Caption = 'Batch Jobs Processing';
                action(DeleteJobsInBatch)
                {
                    Caption = 'Delete Jobs (Batch)';
                    Image = Delete;
                    ToolTip = 'Deletes all jobs in the same batch.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                    begin
                        if (IsNullGuid(Rec.BatchId)) then
                            Error('Please assign jobs to a batch to delete jobs in batch.');

                        if (not Confirm(StrSubstNo('Are you sure you want to delete all jobs in batch %1?', Format(Rec.BatchId, 0, 4).ToLower()), true)) then
                            exit;

                        Jobs.SetFilter(BatchId, '=%1', Rec.BatchId);
                        Jobs.DeleteAll(true);
                        CurrPage.Update(false);
                    end;
                }

                action(SetQueuedToPendingForBatch)
                {
                    Caption = 'Set Queued to Pending (Batch)';
                    Image = Refresh;
                    ToolTip = 'Sets all Queued job lines to Pending for jobs in the same batch.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                        JobLine: Record "NPR CloudflareMigrationJobLine";
                    begin
                        if (IsNullGuid(Rec.BatchId)) then
                            Error('Please assign jobs to a batch to set job line status in batch.');

                        if (not Confirm(StrSubstNo('Are you sure you want to reset all Queued job lines to Pending for jobs in batch %1? If result has not been fetched, the successfully migrated images will be re-migrated.', Format(Rec.BatchId, 0, 4).ToLower()), true)) then
                            exit;

                        Jobs.SetFilter(BatchId, '=%1', Rec.BatchId);
                        if (Jobs.FindSet()) then
                            repeat
                                JobLine.SetFilter(JobLine.JobId, '=%1', Jobs.JobId);
                                JobLine.SetFilter(JobLine.Status, '=%1', JobLine.Status::QUEUED);
                                JobLine.ModifyAll(Status, JobLine.Status::PENDING);
                                Jobs.EnqueuedCount := 0;
                                Jobs.Modify();
                            until (Jobs.Next() = 0);
                        CurrPage.Update(false);
                    end;
                }
            }

            group(SelectedProcessing)
            {
                Caption = 'Selected Jobs Processing';
                action(StartMigrationSelected)
                {
                    Caption = 'Start Migration (Selected)';
                    Image = ImportDatabase;
                    ToolTip = 'Starts migration for selected jobs.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                    begin
                        CurrPage.SetSelectionFilter(Jobs);
                        StartMigrationJob(Jobs);
                        CurrPage.Update(false);
                    end;
                }

                action(CheckMigrationStatusSelected)
                {
                    Caption = 'Check Migration Status (Selected)';
                    Image = View;
                    ToolTip = 'Checks migration status for selected jobs.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                    begin
                        CurrPage.SetSelectionFilter(Jobs);
                        CheckJobStatus(Jobs);
                        CurrPage.Update(false);
                    end;
                }
                action(FetchMigrationResultsSelected)
                {
                    Caption = 'Fetch Migration Results (Selected)';
                    Image = Download;
                    ToolTip = 'Fetches migration results for selected jobs.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                    begin
                        CurrPage.SetSelectionFilter(Jobs);
                        FetchMigrationResult(Jobs);
                        CurrPage.Update(false);
                    end;
                }

                action(FinalizeMigrationSelected)
                {
                    Caption = 'Finalize Migration (Selected)';
                    Image = Approve;
                    ToolTip = 'Finalizes migration for selected jobs.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                    begin
                        CurrPage.SetSelectionFilter(Jobs);
                        FinalizeJobs(Jobs);
                        CurrPage.Update(false);
                    end;
                }

                action(SetQueuedToPendingForSelected)
                {
                    Caption = 'Set Queued to Pending (Selected)';
                    Image = Refresh;
                    ToolTip = 'Sets all Queued job lines to Pending for selected jobs.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                        JobLine: Record "NPR CloudflareMigrationJobLine";
                    begin
                        if (not Confirm('Are you sure you want to reset all Queued job lines to Pending for the selected jobs? If result has not been fetched, the successfully migrated images will be re-migrated.', true)) then
                            exit;

                        CurrPage.SetSelectionFilter(Jobs);
                        if (Jobs.FindSet()) then
                            repeat
                                JobLine.SetFilter(JobLine.JobId, '=%1', Jobs.JobId);
                                JobLine.SetFilter(JobLine.Status, '=%1', JobLine.Status::QUEUED);
                                JobLine.ModifyAll(Status, JobLine.Status::PENDING);
                                Jobs.EnqueuedCount := 0;
                                Jobs.Modify();
                            until (Jobs.Next() = 0);
                        CurrPage.Update(false);
                    end;
                }
                action(DeleteJobsSelected)
                {
                    Caption = 'Delete Jobs (Selected)';
                    Image = Delete;
                    ToolTip = 'Deletes all selected jobs.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                    begin
                        CurrPage.SetSelectionFilter(Jobs);

                        if (not Confirm(StrSubstNo('Are you sure you want to delete %1 jobs?', Jobs.Count()), true)) then
                            exit;

                        Jobs.FindSet();
                        repeat
                            Jobs.Delete(true);
                        until (Jobs.Next() = 0);
                        CurrPage.Update(false);
                    end;
                }

            }

            group(RepeaterProcessing)
            {
                Caption = 'Single Job Processing';
                action(StartMigrationRepeater)
                {
                    Caption = 'Start Migration';
                    Image = ImportDatabase;
                    ToolTip = 'Starts migration for job.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    Scope = Repeater;
                    trigger OnAction()
                    var
                        CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                        JobResponse: JsonObject;
                    begin
                        if (not CloudflareMedia.StartMigrationJob(Rec.JobId, JobResponse)) then
                            Error(GetLastErrorText());
                        CurrPage.Update(false);
                    end;
                }

                action(CheckMigrationStatusRepeater)
                {
                    Caption = 'Check Migration Status';
                    Image = View;
                    ToolTip = 'Checks migration status for job.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    Scope = Repeater;

                    trigger OnAction()
                    var
                        CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                        JobResponse: JsonObject;
                    begin
                        if (not CloudflareMedia.GetMigrationJobStatus(Rec.JobId, JobResponse)) then
                            Error(GetLastErrorText());
                        CurrPage.Update(false);
                    end;
                }

                action(FetchMigrationResultsRepeater)
                {
                    Caption = 'Fetch Migration Results';
                    Image = Download;
                    ToolTip = 'Fetches migration results for job.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    Scope = Repeater;

                    trigger OnAction()
                    var
                        Jobs: Record "NPR CloudflareMigrationJob";
                    begin
                        Jobs.Copy(Rec);
                        Jobs.SetRecFilter();
                        FetchMigrationResult(Jobs);
                        CurrPage.Update(false);
                    end;
                }

                action(FinalizeMigrationRepeater)
                {
                    Caption = 'Finalize Migration';
                    Image = Approve;
                    ToolTip = 'Finalizes migration for job.';
                    ApplicationArea = NPRRetail;
                    Promoted = false;
                    Scope = Repeater;

                    trigger onAction()
                    var
                        CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                    begin
                        if (not CloudflareMedia.FinalizeMigrationJob(Rec.JobId)) then
                            Error(GetLastErrorText());
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    local procedure StartMigrationJob(var Jobs: Record "NPR CloudflareMigrationJob")
    var
        CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
        JobLines: Record "NPR CloudflareMigrationJobLine";
        JobCount, Started, MigrationErrorCount, MigrationSuccessCount : Integer;
        DurationBetweenJobs: Integer;
        JobResponse: JsonObject;
        Dialog: Dialog;
        LastMessage: Text;
        Label: Label 'Starting job: #1####### of #2#######\\Failed: #3#######\\Last Error: #4#################################################################################################################################\\ \\Please wait...';
    begin
        JobCount := Jobs.Count();
        if (JobCount = 0) then
            Error('No jobs selected.');

        if (not Confirm(StrSubstNo('Do you want to start migration for %1 jobs in the selected batch?', JobCount), true)) then
            exit;

        Dialog.Open(Label);
        Dialog.Update(1, Started);
        Dialog.Update(2, JobCount);
        Dialog.Update(3, MigrationErrorCount);
        Dialog.Update(4, '');

        Jobs.FindSet();
        repeat
            Started += 1;

            JobLines.SetFilter(JobLines.JobId, '=%1', Jobs.JobId);
            JobLines.SetFilter(Status, '=%1', JobLines.Status::PENDING);
            if (not JobLines.IsEmpty()) then
                case CloudflareMedia.StartMigrationJob(Jobs.JobId, JobResponse) of
                    true:
                        MigrationSuccessCount += 1;
                    false:
                        begin
                            MigrationErrorCount += 1;
                            LastMessage := GetLastErrorText();
                        end;
                end;

            Dialog.Update(1, Started);
            Dialog.Update(3, MigrationErrorCount);
            Dialog.Update(4, LastMessage);

            JobLines.SetFilter(Status, '=%1', JobLines.Status::QUEUED);
            DurationBetweenJobs := JobLines.Count() / 1000 * 5 * 1000; // 5 seconds per 1000 items
            Sleep(DurationBetweenJobs);

        until (Jobs.Next() = 0);

        Dialog.Close();

        Message('Migration started for %1 jobs. %2 jobs failed to start.//%3', MigrationSuccessCount, MigrationErrorCount, LastMessage);
    end;

    local procedure CheckJobStatus(var Jobs: Record "NPR CloudflareMigrationJob")
    var
        CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
        JobResponse: JsonObject;
        ErrorCount: Integer;
        LastErrorText: Text;
        Dialog: Dialog;
        DialogLabel: Label 'Checking migration status for jobs.\\Job: #1#######\\Please wait...';
        Progress: Integer;
    begin

        Dialog.Open(DialogLabel);

        if (Jobs.FindSet()) then
            repeat
                Progress += 1;
                Dialog.Update(1, Progress);

                if (not CloudflareMedia.GetMigrationJobStatus(Jobs.JobId, JobResponse)) then begin
                    ErrorCount += 1;
                    LastErrorText := GetLastErrorText();
                end;
            until (Jobs.Next() = 0);

        Dialog.Close();

        if (ErrorCount > 0) then
            Message('%1 job(s) failed to retrieve status. Last error seen was %2.', ErrorCount, LastErrorText);

    end;

    local procedure FetchMigrationResult(var Jobs: Record "NPR CloudflareMigrationJob")
    var
        CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
        JobResponse: JsonObject;
        JToken: JsonToken;
        ItemsArray: JsonArray;
        Done: Boolean;
        Dialog: Dialog;
        Label: Label 'Fetching results:\\Success Count: #1#######\\Failed Count: #2#######\\Migrated Count: #3#######\\Please wait...';
    begin
        Dialog.Open(Label);
        Dialog.Update(1, 0);
        Dialog.Update(2, 0);
        Dialog.Update(3, 0);

        if (Jobs.FindSet()) then
            repeat
                repeat
                    CloudflareMedia.GetMigrationJobResults(Jobs.JobId, JobResponse);
                    Commit();

                    Jobs.Get(Jobs.JobId);

                    Dialog.Update(1, Jobs.SuccessCount);
                    Dialog.Update(2, Jobs.FailedCount);
                    Dialog.Update(3, Jobs.TotalCount);

                    Done := true;
                    if (JobResponse.Get('items', JToken)) and (JToken.IsArray()) then begin
                        ItemsArray := JToken.AsArray();
                        Done := (ItemsArray.Count() = 0);
                    end;
                until Done;
            until (Jobs.Next() = 0);
        Dialog.Close();
    end;


    local procedure FinalizeJobs(var Jobs: Record "NPR CloudflareMigrationJob")
    var
        CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
        Dialog: Dialog;
        DialogLabel: Label 'Finalizing migration for jobs.\\Job: #1#######\\Please wait...';
        Progress: Integer;
    begin
        Dialog.Open(DialogLabel);

        if (Jobs.FindSet()) then
            repeat
                Progress += 1;
                Dialog.Update(1, Progress);

                CloudflareMedia.FinalizeMigrationJob(Jobs.JobId);
                Commit();
            until (Jobs.Next() = 0);

        Dialog.Close();
    end;
}

