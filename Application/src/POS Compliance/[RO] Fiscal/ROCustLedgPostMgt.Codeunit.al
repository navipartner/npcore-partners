codeunit 6248728 "NPR RO Cust. Ledg. Post. Mgt."
{
    Access = Internal;

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Cust. Ledg. Entry", 'OnBeforeInsertGenJournalLinesForCustLedgEntryPosting', '', false, false)]
    local procedure OnBeforeInsertGenJournalLinesForCustLedgEntryPosting(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    begin
        CheckIfROCustLedgEntryPostingEnabled(CustLedgerEntryPostingEnabled, LegalEntityPostingEnabled, CustomerPostingGroupFilter);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Cust. Ledg. Entry", 'OnBeforeCloseCustLedgerEntries', '', false, false)]
    local procedure OnBeforeCloseCustLedgerEntries(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    begin
        CheckIfROCustLedgEntryPostingEnabled(CustLedgerEntryPostingEnabled, LegalEntityPostingEnabled, CustomerPostingGroupFilter);
    end;

    local procedure CheckIfROCustLedgEntryPostingEnabled(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    var
        ROFiscalisationSetup: Record "NPR RO Fiscalisation Setup";
    begin
        if not IsROFiscalizationEnabled(ROFiscalisationSetup) then
            exit;

        CustLedgerEntryPostingEnabled := ROFiscalisationSetup."Enable POS Entry CLE Posting";
        LegalEntityPostingEnabled := ROFiscalisationSetup."Enable Legal Ent. CLE Posting";
        CustomerPostingGroupFilter := ROFiscalisationSetup."Customer Posting Group Filter";
    end;

    local procedure IsROFiscalizationEnabled(var ROFiscalisationSetup: Record "NPR RO Fiscalisation Setup"): Boolean
    begin
        if not ROFiscalisationSetup.Get() then
            exit(false);

        exit(ROFiscalisationSetup."Enable RO Fiscal");
    end;
#endif
}