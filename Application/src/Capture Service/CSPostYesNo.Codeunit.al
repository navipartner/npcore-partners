codeunit 6151358 "NPR CS Post (Yes/No)"
{
    // NPR5.52/JAKUBV/20191022  CASE 365967-01 Transport NPR5.52 - 22 October 2019

    TableNo = "NPR CS Posting Buffer";

    trigger OnRun()
    begin
        if ("Job Queue Status" in ["Job Queue Status"::" ", "Job Queue Status"::"Scheduled for Posting", "Job Queue Status"::Posting]) then
            exit;

        if Confirm(Txt001, true) then
            PostDoc(Rec);
    end;

    var
        Txt001: Label 'Post document?';
        Txt002: Label 'Delete Job Queue Entry for this document?';

    local procedure PostDoc(var CSPostingBuffer: Record "NPR CS Posting Buffer")
    var
        CSSetup: Record "NPR CS Setup";
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
        CSPost: Codeunit "NPR CS Post";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not IsNullGuid(CSPostingBuffer."Job Queue Entry ID") then begin
            if not Confirm(Txt002, true) then
                exit;
            JobQueueEntry.Get(CSPostingBuffer."Job Queue Entry ID");
            JobQueueEntry.Delete(true);
            CSPostingBuffer."Job Queue Status" := CSPostingBuffer."Job Queue Status"::" ";
            Clear(CSPostingBuffer."Job Queue Entry ID");
            CSPostingBuffer.Executed := false;
            CSPostingBuffer.Modify(true);
            Commit;
        end;

        CSSetup.Get;
        if CSSetup."Post with Job Queue" then begin
            CSPostEnqueue.Run(CSPostingBuffer);
        end else begin
            if CSPost.Run(CSPostingBuffer) then begin
                CSPostingBuffer.Executed := true;
                CSPostingBuffer.Modify(true);
            end;
        end;
    end;
}

