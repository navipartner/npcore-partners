codeunit 6151410 "NPR Prepayment Subs."
{
    Access = Internal;
#IF NOT BC17
    SingleInstance = true;

    var
        PrepaymentMgt: Codeunit "NPR Prepayment Mgt.";

        RSLocalisationMgt: Codeunit "NPR RS Localisation Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGetVendorPayablesAccount', '', false, false)]
    local procedure OnAfterGetVendorPayablesAccount(GenJournalLine: Record "Gen. Journal Line"; VendorPostingGroup: Record "Vendor Posting Group"; var PayablesAccount: Code[20]);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SetPayablesAccount(GenJournalLine, VendorPostingGroup, PayablesAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromPurchHeader(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line");
    var
        RSPurchaseHeader: Record "NPR RS Purchase Header";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        RSPurchaseHeader.Read(PurchaseHeader.SystemId);
        GenJournalLine.Prepayment := RSPurchaseHeader."Prepayment";
    end;
#ENDIF
}