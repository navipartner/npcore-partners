codeunit 6014438 "NPR Job Queue Install"
{
    Subtype = Install;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";

    trigger OnInstallAppPerCompany()
    begin
        AddJobQueues();
    end;

    procedure AddJobQueues()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if not TaskScheduler.CanCreateTask() then
            exit;

        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Job Queue install', 'AddJobQueues');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateNaviConnectJobQueueCategories();
        UpdateJobQueueEntries();
        AddNcTaskListProcessingJobQueue();
        AddImportListProcessingJobQueue();
        AddJQLogEntryCleanupJobQueue();
        AddPosItemPostingJobQueue();
        AddPosPostingJobQueue();
        AddInventoryAdjmtJobQueues();
        AddSMSJobQueue();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure AddNcTaskListProcessingJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        NcSetupMgt.SetupTaskProcessingJobQueue(JobQueueEntry, true);
    end;

    local procedure AddImportListProcessingJobQueue()
    var
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        NcSetupMgt.SetupDefaultNcImportListProcessingJobQueue(true);
    end;

    local procedure AddJQLogEntryCleanupJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        CleanupJQLogEntries: Codeunit "NPR Cleanup JQ Log Entries";
    begin
        CleanupJQLogEntries.AddJQLogCleanupJob(JobQueueEntry, true);
    end;

    local procedure AddPosItemPostingJobQueue()
    var
        POSPostViaJobQueue: Codeunit "NPR POS Post via Task Queue";
    begin
        POSPostViaJobQueue.AddPosItemPostingJobQueue();
    end;

    local procedure AddPosPostingJobQueue()
    var
        POSPostViaJobQueue: Codeunit "NPR POS Post via Task Queue";
    begin
        POSPostViaJobQueue.AddPosPostingJobQueue();
    end;

    local procedure AddInventoryAdjmtJobQueues()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        POSPostViaJobQueue: Codeunit "NPR POS Post via Task Queue";
    begin
        if SalesSetup.Get() then begin
            POSPostViaJobQueue.AddJobQueueCategory();
            SalesSetup."Job Queue Category Code" := POSPostViaJobQueue.JQCategoryCode();
            SalesSetup.Modify();
        end;
        Codeunit.Run(Codeunit::"NPR Schedule Invt. Cost Adj.");
    end;

    local procedure AddSMSJobQueue()
    var
        SMSSetup: Record "NPR SMS Setup";
        SMSMgt: Codeunit "NPR SMS Management";
    begin
        if not SMSSetup.Get() then
            InsertSMSSetup(SMSSetup);
        if SMSSetup."Job Queue Category Code" <> '' then
            SMSMgt.CreateMessageJob(SMSSetup."Job Queue Category Code")
        else
            SMSSetup.Validate("Job Queue Category Code", SMSMgt.GetJobQueueCategoryCode());
        SMSSetup.Modify();
    end;

    local procedure InsertSMSSetup(var SMSSetup: Record "NPR SMS Setup")
    begin
        SMSSetup.Init();
        SMSSetup."Discard Msg. Older Than [Hrs]" := 24;
        SMSSetup."Auto Send Attempts" := 3;
        SMSSetup.Insert();
    end;

    local procedure UpdateNaviConnectJobQueueCategories()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        if JobQueueCategory.Get('NPR-NC') then
            JobQueueCategory.Delete();

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.TaskListProcessingCodeunit());
        JobQueueEntry.SetFilter("Job Queue Category Code", '<>%1', NcSetupMgt.DefaultNCJQCategoryCode(NcSetupMgt.TaskListProcessingCodeunit()));
        if not JobQueueEntry.IsEmpty then
            JobQueueEntry.ModifyAll("Job Queue Category Code", NcSetupMgt.DefaultNCJQCategoryCode(NcSetupMgt.TaskListProcessingCodeunit()));

        JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.ImportListProcessingCodeunit());
        JobQueueEntry.SetFilter("Job Queue Category Code", '<>%1', NcSetupMgt.DefaultNCJQCategoryCode(NcSetupMgt.ImportListProcessingCodeunit()));
        if not JobQueueEntry.IsEmpty then
            JobQueueEntry.ModifyAll("Job Queue Category Code", NcSetupMgt.DefaultNCJQCategoryCode(NcSetupMgt.ImportListProcessingCodeunit()));
    end;

    local procedure UpdateJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        xJobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        RecomMaxNoOfAttempts: Integer;
        RecomRerunDelay: Integer;
    begin
        RecomMaxNoOfAttempts := 5;
        RecomRerunDelay := 180;

        if JobQueueEntry.FindSet(true) then
            repeat
                xJobQueueEntry := JobQueueEntry;
                if JobQueueEntry."Maximum No. of Attempts to Run" < RecomMaxNoOfAttempts then
                    JobQueueEntry."Maximum No. of Attempts to Run" := RecomMaxNoOfAttempts;
                if JobQueueEntry."Rerun Delay (sec.)" < RecomRerunDelay then
                    JobQueueEntry."Rerun Delay (sec.)" := RecomRerunDelay;

                if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and (JobQueueEntry."No. of Minutes between Runs" < 2) then
                    if (JobQueueEntry."Object ID to Run" in [NcSetupMgt.ImportListProcessingCodeunit(), NcSetupMgt.TaskListProcessingCodeunit()]) then
                        JobQueueEntry."No. of Minutes between Runs" := 2;

                if Format(xJobQueueEntry) <> Format(JobQueueEntry) then
                    JobQueueEntry.Modify();
            until JobQueueEntry.Next() = 0;
    end;
}