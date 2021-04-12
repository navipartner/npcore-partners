codeunit 6014438 "NPR Job Queue Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        AddJobQueues();
    end;

    procedure AddJobQueues()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagLbl: Label 'NPRJobQueueInstall-20210324', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then
            exit;

        AddNcTaskListProcessingJobQueue();
        AddPosItemPostingJobQueue();
        AddPosPostingJobQueue();
        AddSMSJobQueue();

        UpgradeTag.SetUpgradeTag(UpgradeTagLbl);
    end;

    local procedure AddNcTaskListProcessingJobQueue()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        NCTaskProcessor: Record "NPR Nc Task Processor";
        NCSetup: Record "NPR Nc Setup";
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
        ParamString: Text[250];
    begin
        if not NCSetup.FindFirst() then begin
            NCSetup.Init();
            NCSetup.Insert();
        end;

        if not NCTaskProcessor.FindFirst() then begin
            NCTaskProcessor.Init();
            NCTaskProcessor.Code := 'NC';
            NCTaskProcessor.Insert();
        end;

        JobQueueCategory.InsertRec('NPR-NC', 'NaviConnect related tasks');

        ParamString := NcTaskListProcessing.ParamProcessor() + '=' + NcTaskProcessor.Code;
        ParamString += ',' + NcTaskListProcessing.ParamUpdateTaskList();
        ParamString += ',' + NcTaskListProcessing.ParamProcessTaskList();
        ParamString += ',' + NcTaskListProcessing.ParamMaxRetry() + '=3';

        JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"NPR Nc Task List Processing", CurrentDateTime() + 360 * 1000, JobQueueCategory.Code, ParamString);

        JobQueueEntry.Validate(Description, 'Nc Task List processing');
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);
        JobQueueEntry.Validate("No. of Minutes between Runs", 1);
        JobQueueEntry.Validate(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.Modify(true);
    end;

    local procedure AddPosItemPostingJobQueue()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        POSPostViaTaskQueue: Codeunit "NPR POS Post via Task Queue";
        ParamString: Text[250];
    begin
        JobQueueCategory.InsertRec('NPR-POST', 'Posting related tasks');

        // POS Item posting, every minute, every day, compressed and no stopping on error.
        ParamString := POSPostViaTaskQueue.ParamItemPosting();
        ParamString += ',' + POSPostViaTaskQueue.ParamCompressed();

        JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"NPR POS Post via Task Queue", CurrentDateTime() + 360 * 1000, JobQueueCategory.Code, ParamString);

        JobQueueEntry.Validate(Description, 'POS Item posting');
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);
        JobQueueEntry.Validate("No. of Minutes between Runs", 1);
        JobQueueEntry.Validate(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.Modify();
    end;

    local procedure AddPosPostingJobQueue()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        POSPostViaTaskQueue: Codeunit "NPR POS Post via Task Queue";
        DF: DateFormula;
        ParamString: Text[250];
    begin
        JobQueueCategory.InsertRec('NPR-POST', 'Posting related tasks');

        // POS posting, every day at 23:00, compressed and no stopping on error.
        ParamString := POSPostViaTaskQueue.ParamPosPosting();
        ParamString += ',' + POSPostViaTaskQueue.ParamCompressed();

        JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"NPR POS Post via Task Queue", CurrentDateTime() + 360 * 1000, JobQueueCategory.Code, ParamString);

        JobQueueEntry.Validate("Job Queue Category Code", JobQueueCategory.Code);
        JobQueueEntry.Validate(Description, 'POS posting');
        evaluate(DF, '<+1D');
        JobQueueEntry.Validate("Next Run Date Formula", DF);
        JobQueueEntry.Validate("Starting Time", 230000T);
        JobQueueEntry.Validate(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.Modify(true);
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
}