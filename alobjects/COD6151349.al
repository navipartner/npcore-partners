codeunit 6151349 "CS Counting schedule - Enqueue"
{
    // NPR5.53/CLVA  /20191121  CASE 377467 Object created - NP Capture Service

    TableNo = "CS Counting schedule";

    trigger OnRun()
    begin
        EnqueueDoc(Rec);
    end;

    var
        WrongJobQueueStatus: Label 'Status must not be Running on POS Store %1 when re-scheduling';
        Confirmation: Label '%1 has been scheduled for Counting';

    local procedure EnqueueDoc(var CSCountingschedule: Record "CS Counting schedule")
    var
        CSSetup: Record "CS Setup";
        RecRef: RecordRef;
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CSSetup.Get;
        with CSCountingschedule do begin
          if (Status in [Status::Running]) then
            Error(WrongJobQueueStatus,CSCountingschedule."POS Store");
          Status := Status::Scheduled;
          "Job Queue Entry ID" := CreateGuid;
          "Job Queue Created" := true;
          Modify;
          RecRef.GetTable(CSCountingschedule);
          JobQueueEntry.ID := "Job Queue Entry ID";
          JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
          JobQueueEntry."Object ID to Run" := CODEUNIT::"CS Schedule via Job Queue";
          JobQueueEntry."Record ID to Process" := RecRef.RecordId;
          JobQueueEntry."Job Queue Category Code" := CSSetup."Job Queue Category Code";
          JobQueueEntry."Timeout (sec.)" := 600;
          JobQueueEntry.Priority := CSSetup."Job Queue Priority for Post" + "Job Queue Priority for Post";
          JobQueueEntry."Parameter String" := "POS Store";
          JobQueueEntry."Earliest Start Date/Time" := "Earliest Start Date/Time";
          JobQueueEntry."Expiration Date/Time" := "Expiration Date/Time";
          if "Recurring Job" then begin
            JobQueueEntry."Recurring Job" := "Recurring Job";
            JobQueueEntry."Run on Mondays" := "Run on Mondays";
            JobQueueEntry."Run on Tuesdays" := "Run on Tuesdays";
            JobQueueEntry."Run on Wednesdays" := "Run on Wednesdays";
            JobQueueEntry."Run on Thursdays" := "Run on Thursdays";
            JobQueueEntry."Run on Fridays" := "Run on Fridays";
            JobQueueEntry."Run on Saturdays" := "Run on Saturdays";
            JobQueueEntry."Run on Sundays" := "Run on Sundays";
            JobQueueEntry."Starting Time" := "Starting Time";
            JobQueueEntry."Ending Time" := "Ending Time";
            JobQueueEntry."No. of Minutes between Runs" := "No. of Minutes between Runs";
          end;
          JobQueueEntry.Insert(true);
          CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue",JobQueueEntry);
          if GuiAllowed then
            Message(Confirmation,"POS Store");
        end;
    end;
}

