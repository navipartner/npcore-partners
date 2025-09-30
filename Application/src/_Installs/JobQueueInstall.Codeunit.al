codeunit 6014438 "NPR Job Queue Install"
{
    Access = Internal;
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
        JobQueueMgt: codeunit "NPR Job Queue Management";
    begin
        if not TaskScheduler.CanCreateTask() then
            exit;

        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Job Queue install', 'AddJobQueues');

        //Run this first in order to not affect job queues created by this codeunit further on
        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetManuallySetOnHold')) then begin
            SetManuallySetOnHold();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetManuallySetOnHold'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddJobQueues')) then begin
            UpdateNaviConnectJobQueueCategories();
            UpdateJobQueueEntries();
            AddNcTaskListProcessingJobQueue();
            AddImportListProcessingJobQueue();
            AddJQLogEntryCleanupJobQueue();
            UpgradePOSPostingJobQueues();
            JobQueueMgt.AddPosItemPostingJobQueue();
            JobQueueMgt.AddPosPostingJobQueue();
            AddInventoryAdjmtJobQueues();
            AddSMSJobQueue();
            AddRSAuditJobQueue();
            AddATFiscalJobQueues();
            AddExternalPOSSaleQueues();
            AddESFiscalJobQueues();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddJobQueues'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateJobQueues1')) then begin
            AddTicketDataRetentionJobQueue();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateJobQueues1'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddTaskCountResetJQ')) then begin
            AddNcTaskCountResetJobQueue();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddTaskCountResetJQ'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'NotifyOnSuccessFalse')) then begin
            SetJQNotifyOnSuccessFalse();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'NotifyOnSuccessFalse'));
        end;
        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddPosSaleDocumentPostingJQ')) then begin
            JobQueueMgt.AddPosSaleDocumentPostingJobQueue();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddPosSaleDocumentPostingJQ'));
        end;
#if not BC17
        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'CustomCUforPostInvtCostToGL')) then begin
            SetCustomCUforPostInvtCostToGL();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'CustomCUforPostInvtCostToGL'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateAdjCostJobQueueTimeout')) then begin
            UpdateAdjCostJobQueueTimeout();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateAdjCostJobQueueTimeout'));
        end;
#endif

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'TMRetentionJQCategory')) then begin
            AssignJoqCategoryToTMRetentionJQ();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'TMRetentionJQCategory'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AutoScheduleMembershipStatistics')) then begin
            AutoScheduleMembershipStatistics();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AutoScheduleMembershipStatistics'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", 'NPRUpgradePriceLogTaskQue')) then begin
            UpgradePriceLogTaskQue();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", 'NPRUpgradePriceLogTaskQue'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetAutoRescedulePOSPostGL')) then begin
            SetAutoRescedulePOSPostGL();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetAutoRescedulePOSPostGL'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetEndingTimeForPOSPostGLJQ')) then begin
            SetEndingTimeForPOSPostGLJQ();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetEndingTimeForPOSPostGLJQ'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetEndingTimeForAllWithStartingTime')) then begin
            SetEndingTimeForAllWithStartingTime();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetEndingTimeForAllWithStartingTime'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure AddNcTaskListProcessingJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        NcSetupMgt.SetupTaskProcessingJobQueue(JobQueueEntry, true);
    end;

    local procedure AddNcTaskCountResetJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        NcSetupMgt.SetupTaskCountResetJobQueue(JobQueueEntry, true);
    end;

    local procedure AddImportListProcessingJobQueue()
    var
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        NcSetupMgt.SetupDefaultNcImportListProcessingJobQueue(true);
    end;

    local procedure AddExternalPOSSaleQueues()
    var
        ExtSaleConvertJQ: Codeunit "NPR Ext. Sale Convert JQ";
        ExtSaleEmailJQ: Codeunit "NPR Ext. Sale Email JQ";
        ExtSaleSMSJQ: Codeunit "NPR Ext. Sale SMS JQ";
    begin
        ExtSaleConvertJQ.AddExtPOSSaleConversionJobQueue();
        ExtSaleEmailJQ.AddExtPOSSaleSendEmailReceiptJobQueue();
        ExtSaleSMSJQ.AddExtPOSSaleSMSReceiptJobQueue();
    end;

    local procedure AddJQLogEntryCleanupJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        CleanupJQLogEntries: Codeunit "NPR Cleanup JQ Log Entries";
    begin
        CleanupJQLogEntries.AddJQLogCleanupJob(JobQueueEntry, true);
    end;

    local procedure AddTicketDataRetentionJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TicketSetup: Record "NPR TM Ticket Setup";
        RetentionTicketData: Codeunit "NPR TM Retention Ticket Data";
    begin
        if not TicketSetup.ReadPermission() then
            exit;
        if TicketSetup.Get() then
            RetentionTicketData.AddTicketDataRetentionJobQueue(JobQueueEntry, true);
    end;

    local procedure AddRSAuditJobQueue()
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
    begin
        RSAuditMgt.AddRSAuditBackgroundJobQueue(RSAuditMgt.IsRSFiscalActive(), true);
    end;

    local procedure AddATFiscalJobQueues()
    var
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
    begin
        ATAuditMgt.InitATFiscalJobQueues(ATAuditMgt.IsATFiscalizationEnabled());
    end;

    local procedure AddESFiscalJobQueues()
    var
        ESAuditMgt: Codeunit "NPR ES Audit Mgt.";
    begin
        ESAuditMgt.InitESFiscalJobQueues(ESAuditMgt.IsESFiscalizationEnabled());
    end;

    local procedure AddInventoryAdjmtJobQueues()
    begin
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

    procedure InsertSMSSetup(var SMSSetup: Record "NPR SMS Setup")
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
        JobQueueManagement: codeunit "NPR Job Queue Management";
    begin
        JobQueueManagement.CreateAndAssignJobQueueCategory();

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

    local procedure UpgradePOSPostingJobQueues()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry2: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", 6150631);
        if JobQueueEntry.FindSet(true) then
            repeat
                JobQueueEntry2 := JobQueueEntry;
                case JobQueueEntry2.Description of
                    'POS Entry posting',
                    'POS posting':
                        UpdateAndRescedule(JobQueueEntry2, Codeunit::"NPR POS Post GL Entries JQ", 'POS posting');
                    'POS Entry Item posting',
                    'POS Item posting':
                        UpdateAndRescedule(JobQueueEntry2, Codeunit::"NPR POS Post Item Entries JQ", 'POS Item posting');
                    else
                        JobQueueEntry2.Cancel();
                end;
            until JobQueueEntry.Next() = 0;
    end;

    local procedure UpdateAndRescedule(JobQueueEntry: Record "Job Queue Entry"; ObjectIdToRun: Integer; JobDescription: Text[250])
    var
        JobQueueEntry2: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueEntry2.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run");
        JobQueueEntry2.SetRange("Object ID to Run", ObjectIdToRun);
        JobQueueEntry2.SetFilter(ID, '<>%1', JobQueueEntry.ID);
        if not JobQueueEntry2.IsEmpty() then begin
            JobQueueEntry.Cancel();
            exit;
        end;

        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Validate("Object ID to Run", ObjectIdToRun);
        JobQueueEntry.Description := JobDescription;
        JobQueueEntry."Earliest Start Date/Time" := JobQueueMgt.NowWithDelayInSeconds(600);
        JobQueueEntry.Modify();
        JobQueueEntry.Restart();
    end;

    local procedure SetJQNotifyOnSuccessFalse()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetFilter("Object ID to Run", '6014400..6184471'); //NP object range
        JobQueueEntry.ModifyAll("Notify On Success", false, false); //Make sure not to validate
    end;

#if not BC17
    local procedure SetCustomCUforPostInvtCostToGL()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry2: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Post Inventory Cost to G/L");
        if JobQueueEntry.FindSet(true) then
            repeat
                JobQueueEntry2 := JobQueueEntry;
                JobQueueEntry2."Object ID to Run" := Codeunit::"NPR Post Inventory Cost to G/L";
                JobQueueEntry2."Parameter String" := '';
                JobQueueEntry2.Modify();
            until JobQueueEntry.Next() = 0;
    end;

    local procedure UpdateAdjCostJobQueueTimeout()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobTimeout: Duration;
    begin
        JobTimeout := 4 * 60 * 60 * 1000;  //4 hours
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"Adjust Cost - Item Entries");
        if JobQueueEntry.FindSet(true) then
            repeat
                if (JobQueueEntry."Job Timeout" > JobTimeout) or (JobQueueEntry."Job Timeout" = 0) then begin
                    JobQueueEntry."Job Timeout" := JobTimeout;
                    JobQueueEntry.Modify();
                end;
            until JobQueueEntry.Next() = 0;
    end;
#endif

    local procedure SetAutoRescedulePOSPostGL()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR POS Post GL Entries JQ");
        if JobQueueEntry.FindSet(true) then
            repeat
                JobQueueEntry."NPR Auto-Resched. after Error" := true;
                JobQueueEntry."NPR Auto-Resched. Delay (sec.)" := 45 * 60;  //45 minutes
                JobQueueEntry.Modify();
            until JobQueueEntry.Next() = 0;
    end;

    local procedure SetEndingTimeForPOSPostGLJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR POS Post GL Entries JQ");
        if JobQueueEntry.FindSet(true) then
            repeat
                if (JobQueueEntry."Ending Time" = 0T) and (JobQueueEntry."Starting Time" <> 0T) then begin
                    JobQueueEntry."Ending Time" := JobQueueEntry."Starting Time" + 60 * 60 * 1000;  //+60 minutes
                    JobQueueEntry.Modify();
                end;
            until JobQueueEntry.Next() = 0;
    end;

    local procedure SetEndingTimeForAllWithStartingTime()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetFilter("Starting Time", '<>%1', 0T);
        JobQueueEntry.SetRange("Ending Time", 0T);
        if JobQueueEntry.FindSet(true) then
            repeat
                JobQueueEntry."Ending Time" := JobQueueEntry."Starting Time" + 2 * 60 * 60 * 1000;  //+2h
                JobQueueEntry.Modify();
            until JobQueueEntry.Next() = 0;
    end;

    local procedure SetManuallySetOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry2: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");
        JobQueueEntry.SetRange("NPR Manually Set On Hold", false);
        if JobQueueEntry.FindSet(true) then
            repeat
                if JobQueueManagement.IsNPRecurringJob(JobQueueEntry) then begin
                    JobQueueEntry2.Get(JobQueueEntry.ID);
                    JobQueueEntry2."NPR Manually Set On Hold" := true;
                    JobQueueEntry2.Modify();
                end;
            until JobQueueEntry.Next() = 0;
    end;

    local procedure AssignJoqCategoryToTMRetentionJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategoryTok: Label 'RETENTION', Locked = true, MaxLength = 10;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR TM Retention Ticket Data");
        JobQueueEntry.SetRange("Job Queue Category Code", '');
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.ModifyAll("Job Queue Category Code", JobQueueCategoryTok);
    end;

    local procedure UpgradePriceLogTaskQue()
    var
        PriceLogSetup: Record "NPR Retail Price Log Setup";
        RetailPriceLogMgt: Codeunit "NPR Retail Price Log Mgt.";
    begin
        if not PriceLogSetup.Get() then
            exit;

        if not PriceLogSetup."Task Queue Activated" then
            exit;

        PriceLogSetup."Job Queue Activated" := true;
        PriceLogSetup.Modify();
        RetailPriceLogMgt.CreatePriceLogJobQueue('');
    end;

    local procedure AutoScheduleMembershipStatistics()
    var
        MembershipStatMgmt: Codeunit "NPR MM Membership Stat. Mgmt.";
    begin
        MembershipStatMgmt.CreateJobQueueEntry();
    end;

}
