codeunit 6151348 "CS Counting schedule - Create"
{
    // NPR5.53/CLVA  /20191121  CASE 377467 Object created - NP Capture Service

    TableNo = "CS Counting schedule";

    trigger OnRun()
    var
        CSSetup: Record "CS Setup";
    begin
        CSSetup.Get;
        CSSetup.TestField("Post with Job Queue");

        if (Status in [Status::Running]) then
          Error(WrongJobQueueStatus,Rec."POS Store");

        CreateJob(Rec);
    end;

    var
        Txt001: Label 'Re-Schedule Job Queue Entry for this POS Unit?';
        WrongJobQueueStatus: Label 'Status must not be Running on POS Store %1 when re-scheduling';

    local procedure CreateJob(var CSCountingschedule: Record "CS Counting schedule")
    var
        CSCountingscheduleEnqueue: Codeunit "CS Counting schedule - Enqueue";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not IsNullGuid(CSCountingschedule."Job Queue Entry ID") then begin
          if not Confirm(Txt001,true) then
            exit;
          JobQueueEntry.Get(CSCountingschedule."Job Queue Entry ID");
          JobQueueEntry.Delete(true);
          CSCountingschedule.Status := CSCountingschedule.Status::" ";
          Clear(CSCountingschedule."Job Queue Entry ID");
          CSCountingschedule."Last Executed" := 0DT;
          CSCountingschedule.Modify(true);
          Commit;
        end else begin
          CSCountingschedule."Job Queue Status" := CSCountingschedule."Job Queue Status"::Ready;
          Clear(CSCountingschedule."Job Queue Entry ID");
          CSCountingschedule.Modify(true);
          Commit;
        end;

        CSCountingscheduleEnqueue.Run(CSCountingschedule);
    end;
}

