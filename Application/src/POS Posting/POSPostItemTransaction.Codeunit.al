codeunit 6150620 "NPR POS Post Item Transaction"
{
    Access = Internal;
    TableNo = "NPR POS Entry";

    var
        _POSPostItemEntries: Codeunit "NPR POS Post Item Entries";
        _PostingDate: Date;
        _ReplaceDates: Boolean;
        _ReplaceDocumentDate: Boolean;
        _ReplacePostingDate: Boolean;

    trigger OnRun()
    begin
        Code(Rec);
    end;

    local procedure "Code"(var POSEntry: Record "NPR POS Entry")
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        Clear(_POSPostItemEntries);
        if _ReplaceDates then
            _POSPostItemEntries.SetPostingDate(_ReplacePostingDate, _ReplaceDocumentDate, _PostingDate);

        _POSPostItemEntries.CreateAssemblyOrders(POSEntry);  // Assembly order creation is committed
        if FeatureFlagsManagement.IsEnabled(DisallowCommitsDuringPosItemTransactionsPostingFeatureFlag()) then
            PostNoCommits(POSEntry)
        else
            Post(POSEntry);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure PostNoCommits(var POSEntry: Record "NPR POS Entry")
    begin
        Post(POSEntry);
    end;

    local procedure Post(var POSEntry: Record "NPR POS Entry")
    begin
        // As there may have been a commit on the previous step, lock, re-read and check again if still not posted
        POSEntry.LockTable();
        POSEntry.Find();
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::Unposted, POSEntry."Post Item Entry Status"::"Error while Posting"]) then
            exit;

        _POSPostItemEntries.PostAssemblyOrders(POSEntry);
        _POSPostItemEntries.Run(POSEntry);

        POSEntry.Validate("Post Item Entry Status", POSEntry."Post Item Entry Status"::Posted);
        POSEntry.Modify();
    end;

    internal procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        _ReplaceDates := true;
        _ReplacePostingDate := NewReplacePostingDate;
        _ReplaceDocumentDate := NewReplaceDocumentDate;
        _PostingDate := NewPostingDate;
    end;

    local procedure DisallowCommitsDuringPosItemTransactionsPostingFeatureFlag(): Text[50]
    begin
        exit('disallowCommitsDuringPosItemTransactionsPosting');
    end;
}
