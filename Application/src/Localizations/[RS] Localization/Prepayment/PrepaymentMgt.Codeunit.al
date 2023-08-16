codeunit 6151373 "NPR Prepayment Mgt."
{
    Access = Internal;

    internal procedure SetPayablesAccount(GenJournalLine: Record "Gen. Journal Line"; VendorPostingGroup: Record "Vendor Posting Group"; var PayablesAccount: Code[20])
    var
        RSVendorPostingGroup: Record "NPR RS Vendor Posting Group";
    begin
        if not GenJournalLine.Prepayment then
            exit;
        RSVendorPostingGroup.Read(VendorPostingGroup.SystemId);
        RSVendorPostingGroup.TestField("Prepayment Account");
        PayablesAccount := RSVendorPostingGroup."Prepayment Account";
    end;

}