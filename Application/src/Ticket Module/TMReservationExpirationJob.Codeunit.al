codeunit 6151111 "NPR TMReservationExpirationJob"
{

    Access = Internal;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    trigger OnRun()
    var
        RequestManager: Codeunit "NPR TM Ticket Request Manager";
        IterationCount: Integer;
    begin
        while (RequestManager.ExpireReservationRequestsV2_JobQueue() > 0) do begin
            Commit();
            IterationCount += 1;
            if (IterationCount >= 5) then
                exit; // Exit after 5 iterations to prevent long-running job issues, caps expiration to 150 tokens per run

            sleep(2000); // Sleep for 2 seconds before checking for next batch of 30 tokens
        end;
    end;

#else
    trigger OnRun()
    begin
        Error('This job is only supported in BC versions prior to BC22.');
    end;
#endif


    procedure CreateJobQueue(var JobQueueEntry: Record "Job Queue Entry"; Silent: Boolean): Boolean
    var
        ConfirmJobCreationQst: Label 'This function will add a new periodic job (Job Queue Entry), responsible for expiring reservation requests, (if a similar job already exists, system will not add anything).\Are you sure you want to continue?';
    begin
        if (not Silent) then
            if (not Confirm(ConfirmJobCreationQst, true)) then
                exit(false);

        exit(InitJobQueue(JobQueueEntry));
    end;

    local procedure InitJobQueue(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobQueueCategoryTok: Label 'TM-EXPIRY', Locked = true, MaxLength = 10;
        JobQueueDescriptionLbl: Label 'Expire reservation requests', MaxLength = 250;
    begin
        JobQueueMgt.SetJobTimeout(0, 1);  //1 minute

        JobQueueMgt.SetProtected(true);
        if (JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            codeunit::"NPR TMReservationExpirationJob",
            '',
            JobQueueDescriptionLbl,
            JobQueueMgt.NowWithDelayInSeconds(60), // Start time (current time + 60 seconds)
            000100T,
            235800T,
            1,
            JobQueueCategoryTok,
            JobQueueEntry))
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            exit(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR TM Ticket Setup", 'OnAfterInsertEvent', '', true, false)]
    local procedure AddJobQueueOnTicketSetupInsert(var Rec: Record "NPR TM Ticket Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if (Rec.IsTemporary()) then
            exit;

        CreateJobQueue(JobQueueEntry, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (not TicketSetup.ReadPermission()) then
            exit;

        if (not TicketSetup.Get()) then
            exit;

        CreateJobQueue(JobQueueEntry, true);
    end;

}