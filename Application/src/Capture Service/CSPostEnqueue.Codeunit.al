codeunit 6151356 "NPR CS Post - Enqueue"
{
    TableNo = "NPR CS Posting Buffer";

    trigger OnRun()
    begin
        EnqueueDoc(Rec);
    end;

    var
        WrongJobQueueStatus: Label 'Job Queue Status shall be Blank or Error on record no. %1';
        Confirmation: Label '%1 has been scheduled for posting;';

    local procedure EnqueueDoc(var CSPostingBuffer: Record "NPR CS Posting Buffer")
    var
        CSSetup: Record "NPR CS Setup";
        RecRef: RecordRef;
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CSSetup.Get;
        with CSPostingBuffer do begin
            if GuiAllowed then
                if not ("Job Queue Status" in ["Job Queue Status"::" ", "Job Queue Status"::Error]) then
                    Error(WrongJobQueueStatus, Id);
            "Job Queue Status" := "Job Queue Status"::"Scheduled for Posting";
            "Job Queue Entry ID" := CreateGuid;
            Modify;
            RecRef.GetTable(CSPostingBuffer);
            JobQueueEntry.ID := "Job Queue Entry ID";
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := CODEUNIT::"NPR CS Post via Job Queue";
            JobQueueEntry."Record ID to Process" := RecRef.RecordId;
            JobQueueEntry."Job Queue Category Code" := CSSetup."Job Queue Category Code";
            if "Job Type" = "Job Type"::"Approve Counting" then begin
                JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, 230000T);
            end;
            if "Job Type" = "Job Type"::"Transfer Order" then begin
                JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, 210000T);
            end;
            JobQueueEntry.Insert(true);
            CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
            if GuiAllowed then
                Message(Confirmation, Id);
        end;
    end;
}
