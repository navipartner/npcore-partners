codeunit 6185071 "NPR CRO Cust. Ledg. Post. Mgt."
{
    Access = Internal;

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Cust. Ledg. Entry", 'OnBeforeInsertGenJournalLinesForCustLedgEntryPosting', '', false, false)]
    local procedure OnBeforeInsertGenJournalLinesForCustLedgEntryPosting(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    begin
        CheckIfCROCustLedgEntryPostingEnabled(CustLedgerEntryPostingEnabled, LegalEntityPostingEnabled, CustomerPostingGroupFilter);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Cust. Ledg. Entry", 'OnBeforeCloseCustLedgerEntries', '', false, false)]
    local procedure OnBeforeCloseCustLedgerEntries(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    begin
        CheckIfCROCustLedgEntryPostingEnabled(CustLedgerEntryPostingEnabled, LegalEntityPostingEnabled, CustomerPostingGroupFilter);
    end;

    local procedure CheckIfCROCustLedgEntryPostingEnabled(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
    begin
        if not IsCROFiscalizationEnabled(CROFiscalizationSetup) then
            exit;

        CustLedgerEntryPostingEnabled := CROFiscalizationSetup."Enable POS Entry CLE Posting";
        LegalEntityPostingEnabled := CROFiscalizationSetup."Enable Legal Ent. CLE Posting";
        CustomerPostingGroupFilter := CROFiscalizationSetup."Customer Posting Group Filter";
    end;

    local procedure IsCROFiscalizationEnabled(var CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup"): Boolean
    begin
        if not CROFiscalizationSetup.Get() then
            exit(false);

        exit(CROFiscalizationSetup."Enable CRO Fiscal");
    end;
#endif
}