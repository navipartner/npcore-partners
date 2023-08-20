codeunit 6151038 "NPR Post Sales Documents JQ"
{
    Access = Internal;

    trigger OnRun()
    var
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntry: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        Hashset: Codeunit "NPR HashSet of [Integer]";
        ErrorCount: Integer;
        ErrMessage: Label '%1 POS entries failed to post.';
        ErrorEntries: List of [Integer];
        POSPostSaleDocumentStatus: Option;
    begin
        if not UnpostedEntriesExist() then
            exit;

        POSPostEntries.SetPostCompressed(false);
        POSPostEntries.SetStopOnError(false);
        POSPostEntries.SetPostPOSEntries(false);
        POSPostEntries.SetPostItemEntries(false);
        POSPostEntries.SetPostPerPeriodRegister(true);
        POSPostEntries.SetJobQueuePosting(true);
        POSPostEntries.SetPostSaleDocuments(true);

        POSEntry.SetCurrentKey("Post Sales Document Status");
        POSEntry.SetLoadFields("POS Period Register No.");
        for POSPostSaleDocumentStatus := POSEntry."Post Sales Document Status"::"Error while Posting" downto POSEntry."Post Sales Document Status"::Unposted do begin
            POSEntry.SetRange("Post Sales Document Status", POSPostSaleDocumentStatus);
            if POSEntry.FindSet() then
                repeat
                    if not Hashset.Contains(POSEntry."POS Period Register No.") then begin
                        Clear(POSEntry2);
                        POSEntry2.SetCurrentKey("POS Period Register No.");
                        POSEntry2.SetFilter("POS Period Register No.", '=%1', POSEntry."POS Period Register No.");
                        POSPostEntries.Run(POSEntry2);
                        Commit();
                        POSPostEntries.GetSaleDocPostingErrorEntries(ErrorEntries);
                        ErrorCount += ErrorEntries.Count;
                        Hashset.Add(POSEntry."POS Period Register No.");
                    end;
                until POSEntry.Next() = 0;
        end;

        if ErrorCount > 0 then
            Message(ErrMessage, ErrorCount);
    end;

    local procedure UnpostedEntriesExist(): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetCurrentKey("Post Sales Document Status");
        POSEntry.SetFilter("Post Sales Document Status", '%1|%2', POSEntry."Post Sales Document Status"::"Error while Posting", POSEntry."Post Sales Document Status"::Unposted);
        if not POSEntry.IsEmpty() then
            exit(true);
    end;
}
