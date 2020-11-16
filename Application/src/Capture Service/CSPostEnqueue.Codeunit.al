codeunit 6151356 "NPR CS Post - Enqueue"
{
    // NPR5.52/CLVA  /20190904  CASE 365967 Object created - NP Capture Service
    // NPR5.53/CLVA  /20191128  CASE 379973 Added "Earliest Start Date/Time" on RFID Store Counting
    // NPR5.54/CLVA  /20200217  CASE 391080 Removed timeout
    // NPR5.54/CLVA  /20200225  CASE Changed posting timing.
    // NPR5.55/CLVA  /20200609  CASE 407858 Changed posting timing.

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
            //-NPR5.54 [391080]
            //JobQueueEntry."Timeout (sec.)" := 600;
            //+NPR5.54 [391080]
            //JobQueueEntry.Priority := CSSetup."Job Queue Priority for Post" + "Job Queue Priority for Post";
            //-NPR5.53 [379973]
            if "Job Type" = "Job Type"::"Approve Counting" then begin
                //-NPR5.54 [392901]
                //IF CSSetup."Earliest Start Date/Time" <> 0DT THEN
                //  JobQueueEntry."Earliest Start Date/Time" := CSSetup."Earliest Start Date/Time";
                JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, 230000T);
                //+NPR5.54 [392901]
            end;
            //+NPR5.53 [379973]
            //-NPR5.55 [407858]
            if "Job Type" = "Job Type"::"Transfer Order" then begin
                JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, 210000T);
            end;
            //+NPR5.55 [407858]
            JobQueueEntry.Insert(true);
            CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
            if GuiAllowed then
                Message(Confirmation, Id);
        end;
    end;
}

