codeunit 6151039 "NPR POS Post Sales Doc. Trans."
{
    Access = Internal;
    TableNo = "NPR POS Entry";

    var
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
        POSPostSalesDocEntries: Codeunit "NPR POS Post Sales Doc.Entries";
        NewPostingDescription: Text;
        PostingFailedErr: Label 'One or more errors occurred while posting related sales documents.';
    begin
        if _ReplaceDates then
            POSPostSalesDocEntries.SetPostingDate(_ReplacePostingDate, _ReplaceDocumentDate, _PostingDate);

        POSPostSalesDocEntries.Run(POSEntry);
        if POSPostSalesDocEntries.ErrorOccured() then
            Error(PostingFailedErr);

        POSEntry.LockTable();
        POSEntry.Find();
        if not (POSEntry."Post Sales Document Status" in [POSEntry."Post Sales Document Status"::Unposted, POSEntry."Post Sales Document Status"::"Error while Posting"]) then
            exit;
        NewPostingDescription := POSPostSalesDocEntries.GetPosEntryDescription();
        if NewPostingDescription <> '' then
            POSEntry.Description := CopyStr(NewPostingDescription, 1, MaxStrLen(POSEntry.Description));
        POSEntry.Validate("Post Sales Document Status", POSEntry."Post Sales Document Status"::Posted);
        POSEntry.Modify();
    end;

    internal procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        _ReplaceDates := true;
        _ReplacePostingDate := NewReplacePostingDate;
        _ReplaceDocumentDate := NewReplaceDocumentDate;
        _PostingDate := NewPostingDate;
    end;
}
