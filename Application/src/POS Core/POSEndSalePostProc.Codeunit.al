codeunit 6014478 "NPR POS End Sale Post Proc."
{
    TableNo = "NPR Sale POS";

    trigger OnRun()
    begin
        PostPOSEntry(Rec);
    end;

    var
        ERR_MISSING_ENTRY: Label 'Missing %1, %2 %3';

    local procedure PostPOSEntry(SalePOS: Record "NPR Sale POS")
    var
        POSPostingControl: Codeunit "NPR POS Posting Control";
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        if not POSEntryManagement.FindPOSEntryViaDocumentNo(SalePOS."Sales Ticket No.", POSEntry) then
            Error(ERR_MISSING_ENTRY, POSEntry.TableCaption, POSEntry.FieldCaption("Document No."), SalePOS."Sales Ticket No.");
        POSPostingControl.AutomaticPostEntry(POSEntry);
    end;
}

