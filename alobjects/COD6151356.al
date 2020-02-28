codeunit 6151356 "CS Post - Enqueue"
{
    // NPR5.52/CLVA  /20190904  CASE 365967 Object created - NP Capture Service
    // NPR5.53/CLVA  /20191128  CASE 379973 Added "Earliest Start Date/Time" on RFID Store Counting

    TableNo = "CS Posting Buffer";

    trigger OnRun()
    begin
        EnqueueDoc(Rec);
    end;

    var
        WrongJobQueueStatus: Label 'Job Queue Status shall be Blank or Error on record no. %1';
        Confirmation: Label '%1 has been scheduled for posting;';

    local procedure EnqueueDoc(var CSPostingBuffer: Record "CS Posting Buffer")
    var
        CSSetup: Record "CS Setup";
        RecRef: RecordRef;
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CSSetup.Get;
        with CSPostingBuffer do begin
          if GuiAllowed then
            if not ("Job Queue Status" in ["Job Queue Status"::" ","Job Queue Status"::Error]) then
              Error(WrongJobQueueStatus,Id);
          "Job Queue Status" := "Job Queue Status"::"Scheduled for Posting";
          "Job Queue Entry ID" := CreateGuid;
          Modify;
          RecRef.GetTable(CSPostingBuffer);
          JobQueueEntry.ID := "Job Queue Entry ID";
          JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
          JobQueueEntry."Object ID to Run" := CODEUNIT::"CS Post via Job Queue";
          JobQueueEntry."Record ID to Process" := RecRef.RecordId;
          JobQueueEntry."Job Queue Category Code" := CSSetup."Job Queue Category Code";
          JobQueueEntry."Timeout (sec.)" := 600;
          JobQueueEntry.Priority := CSSetup."Job Queue Priority for Post" + "Job Queue Priority for Post";
          //-NPR5.53 [379973]
          if "Job Type" = "Job Type"::"Approve Counting" then begin
            if CSSetup."Earliest Start Date/Time" <> 0DT then
              JobQueueEntry."Earliest Start Date/Time" := CSSetup."Earliest Start Date/Time";
          end;
          //+NPR5.53 [379973]
          JobQueueEntry.Insert(true);
          CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue",JobQueueEntry);
          if GuiAllowed then
            Message(Confirmation,Id);
        end;
    end;
}

