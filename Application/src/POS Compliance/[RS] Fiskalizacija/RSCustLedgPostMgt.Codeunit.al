codeunit 6185069 "NPR RS Cust. Ledg. Post. Mgt."
{
    Access = Internal;

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Cust. Ledg. Entry", 'OnBeforeInsertGenJournalLinesForCustLedgEntryPosting', '', false, false)]
    local procedure OnBeforeInsertGenJournalLinesForCustLedgEntryPosting(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    begin
        CheckIfRSCustLedgEntryPostingEnabled(CustLedgerEntryPostingEnabled, LegalEntityPostingEnabled, CustomerPostingGroupFilter);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Cust. Ledg. Entry", 'OnBeforeCloseCustLedgerEntries', '', false, false)]
    local procedure OnBeforeCloseCustLedgerEntries(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    begin
        CheckIfRSCustLedgEntryPostingEnabled(CustLedgerEntryPostingEnabled, LegalEntityPostingEnabled, CustomerPostingGroupFilter);
    end;

    local procedure CheckIfRSCustLedgEntryPostingEnabled(var CustLedgerEntryPostingEnabled: Boolean; var LegalEntityPostingEnabled: Boolean; var CustomerPostingGroupFilter: Text)
    var
        RSFiscalisationSetup: Record "NPR RS Fiscalisation Setup";
    begin
        if not IsRSFiscalizationEnabled(RSFiscalisationSetup) then
            exit;

        CustLedgerEntryPostingEnabled := RSFiscalisationSetup."Enable POS Entry CLE Posting";
        LegalEntityPostingEnabled := RSFiscalisationSetup."Enable Legal Ent. CLE Posting";
        CustomerPostingGroupFilter := RSFiscalisationSetup."Customer Posting Group Filter";
    end;

    local procedure IsRSFiscalizationEnabled(var RSFiscalisationSetup: Record "NPR RS Fiscalisation Setup"): Boolean
    begin
        if not RSFiscalisationSetup.Get() then
            exit(false);

        exit(RSFiscalisationSetup."Enable RS Fiscal");
    end;
#endif
}