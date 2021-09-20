codeunit 6059770 "NPR POS Post Item Entries JQ"
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
    begin
        POSPostEntries.SetPostCompressed(true);
        POSPostEntries.SetStopOnError(false);
        POSPostEntries.SetPostPOSEntries(false);
        POSPostEntries.SetPostItemEntries(true);

        POSEntry.SetFilter("Post Item Entry Status", '<%1', 2);
        POSEntry.SetCurrentKey("Post Item Entry Status");
        if not POSEntry.FindSet() then
            exit;

        repeat
            if not Hashset.Contains(POSEntry."POS Period Register No.") then begin
                Clear(POSEntry2);
                POSEntry2.SetCurrentKey("POS Period Register No.");
                POSEntry2.SetFilter("POS Period Register No.", '=%1', POSEntry."POS Period Register No.");
                POSPostEntries.Run(POSEntry2);
                Commit();
                POSPostEntries.GetItemPostingErrorEntries(ErrorEntries);
                ErrorCount += ErrorEntries.Count;
                Hashset.Add(POSEntry."POS Period Register No.");
            end;
        until POSEntry.Next() = 0;

        if ErrorCount > 0 then begin
            Error(ErrMessage, ErrorCount);
        end
    end;
}
