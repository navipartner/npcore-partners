codeunit 6151355 "CS Post via Job Queue"
{
    // NPR5.52/CLVA  /20190904  CASE 365967 Object created - NP Capture Service

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        CSPostingBuffer: Record "CS Posting Buffer";
    begin
        TestData(Rec);
        GetData(Rec,CSPostingBuffer);
        Process(CSPostingBuffer);
        CleanUp(CSPostingBuffer);
    end;

    local procedure TestData(var JobQueueEntry: Record "Job Queue Entry")
    begin
        with JobQueueEntry do
          TestField("Record ID to Process");
    end;

    local procedure GetData(var JobQueueEntry: Record "Job Queue Entry";var CSPostingBuffer: Record "CS Posting Buffer")
    var
        RecRef: RecordRef;
    begin
        with JobQueueEntry do
          RecRef.Get("Record ID to Process");
        RecRef.SetTable(CSPostingBuffer);
        CSPostingBuffer.Find;
    end;

    local procedure Process(var CSPostingBuffer: Record "CS Posting Buffer")
    var
        CSPost: Codeunit "CS Post";
    begin
        SetJobQueueStatus(CSPostingBuffer, CSPostingBuffer."Job Queue Status"::Posting);
        if not CSPost.Run(CSPostingBuffer) then begin
          SetJobQueueStatus(CSPostingBuffer, CSPostingBuffer."Job Queue Status"::Error);
          Error(GetLastErrorText);
        end;
    end;

    local procedure CleanUp(var CSPostingBuffer: Record "CS Posting Buffer")
    begin
        SetJobQueueStatus(CSPostingBuffer, CSPostingBuffer."Job Queue Status"::" ");
    end;

    local procedure SetJobQueueStatus(var CSPostingBuffer: Record "CS Posting Buffer";NewStatus: Option)
    begin
        with CSPostingBuffer do begin
          LockTable;
          if Find then begin
            "Job Queue Status" := NewStatus;
            Executed := true;
            Modify;
            Commit;
          end;
        end;
    end;
}

