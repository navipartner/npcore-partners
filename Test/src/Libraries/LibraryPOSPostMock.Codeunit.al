codeunit 85025 "NPR Library - POS Post Mock"
{
    TableNo = "NPR Sale POS";

    trigger OnRun()
    begin
        PostPOSEntry(Rec);
    end;

    var
        ItemPost: Boolean;
        POSPost: Boolean;
        MissingEntryErr: Label 'Missing %1, %2 %3';
        CouldNotPostErr: Label 'The POS Entry could not be posted.';

    procedure Initialize(_ItemPost: Boolean; _POSPost: Boolean)
    begin
        ItemPost := _ItemPost;
        POSPost := _POSPost;
    end;

    local procedure PostPOSEntry(SalePOS: Record "NPR Sale POS")
    var
        POSPostingControl: Codeunit "NPR POS Posting Control";
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        POSPostEntries: Codeunit "NPR POS Post Entries";
    begin
        if not POSEntryManagement.FindPOSEntryViaDocumentNo(SalePOS."Sales Ticket No.", POSEntry) then
            Error(MissingEntryErr, POSEntry.TableCaption, POSEntry.FieldCaption("Document No."), SalePOS."Sales Ticket No.");

        POSStore.GetProfile(POSEntry."POS Store Code", POSPostingProfile);
        POSEntry.SetRange("Entry No.", POSEntry."Entry No.");

        Commit();
        POSPostEntries.SetPostItemEntries(ItemPost);
        POSPostEntries.SetPostPOSEntries(POSPost);

        if not POSPostEntries.Run(POSEntry) then
            Error(CouldNotPostErr);
    end;
}