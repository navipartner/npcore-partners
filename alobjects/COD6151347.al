codeunit 6151347 "CS Schedule via Job Queue"
{
    // NPR5.53/CLVA  /20191121  CASE 377467 Object created - NP Capture Service

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        CSCountingschedule: Record "CS Counting schedule";
    begin
        TestData(Rec);
        GetData(Rec,CSCountingschedule);
        Process(CSCountingschedule);
        CleanUp(CSCountingschedule);
    end;

    local procedure TestData(var JobQueueEntry: Record "Job Queue Entry")
    begin
        with JobQueueEntry do
          TestField("Record ID to Process");
    end;

    local procedure GetData(var JobQueueEntry: Record "Job Queue Entry";var CSCountingschedule: Record "CS Counting schedule")
    var
        RecRef: RecordRef;
    begin
        with JobQueueEntry do
          RecRef.Get("Record ID to Process");
        RecRef.SetTable(CSCountingschedule);
        CSCountingschedule.Find;
    end;

    local procedure Process(var CSCountingschedule: Record "CS Counting schedule")
    var
        CSCountingscheduleExecute: Codeunit "CS Counting schedule Execute";
    begin
        SetJobQueueStatus(CSCountingschedule, CSCountingschedule.Status::Running);
        if not CSCountingscheduleExecute.Run(CSCountingschedule) then begin
          SetJobQueueStatus(CSCountingschedule, CSCountingschedule.Status::Error);
          Error(GetLastErrorText);
        end;
    end;

    local procedure CleanUp(var CSCountingschedule: Record "CS Counting schedule")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if CSCountingschedule."Recurring Job" then begin
          SetJobQueueStatus(CSCountingschedule, CSCountingschedule.Status::Scheduled);
          if not IsNullGuid(CSCountingschedule."Job Queue Entry ID") then begin
            if JobQueueEntry.Get(CSCountingschedule."Job Queue Entry ID") then begin
              CSCountingschedule."Earliest Start Date/Time" := JobQueueEntry."Earliest Start Date/Time";
              CSCountingschedule.Modify;
            end;
          end;
        end else
          SetJobQueueStatus(CSCountingschedule, CSCountingschedule.Status::" ");
    end;

    local procedure SetJobQueueStatus(var CSCountingschedule: Record "CS Counting schedule";NewStatus: Option)
    begin
        with CSCountingschedule do begin
          LockTable;
          if Find then begin
            Status := NewStatus;
            "Last Executed" := CurrentDateTime;
            Modify;
            Commit;
          end;
        end;
    end;
}

