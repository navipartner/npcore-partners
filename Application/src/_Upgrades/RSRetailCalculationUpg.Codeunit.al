codeunit 6248550 "NPR RS Retail Calculation Upg."
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR RS Retail Calculation Upgrade', 'OnUpgradeDataPerCompany');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR RS Retail Calculation Upg.", 'MatchRemainingQtyToRSRetailValueEntryMapping')) then begin
            MatchRemainingQtyToRSRetValueEntryMapping();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR RS Retail Calculation Upg.", 'MatchRemainingQtyToRSRetailValueEntryMapping'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure MatchRemainingQtyToRSRetValueEntryMapping()
    var
        RSRLocalizationSetup: Record "NPR RS R Localization Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        if not RSRLocalizationSetup.Get() then
            exit;
        if not RSRLocalizationSetup."Enable RS Retail Localization" then
            exit;

        RSRetValueEntryMapp.SetRange("Item Ledger Entry Type", RSRetValueEntryMapp."Item Ledger Entry Type"::Transfer);
        RSRetValueEntryMapp.SetRange("Document Type", RSRetValueEntryMapp."Document Type"::"Transfer Receipt");
        RSRetValueEntryMapp.SetRange("COGS Correction", true);
        if RSRetValueEntryMapp.FindSet(true) then
            repeat
                if ItemLedgerEntry.Get(RSRetValueEntryMapp."Item Ledger Entry No.") then begin
                    RSRetValueEntryMapp."Remaining Quantity" := ItemLedgerEntry."Remaining Quantity";
                    if RSRetValueEntryMapp."Remaining Quantity" > 0 then
                        RSRetValueEntryMapp.Open := true;
                    RSRetValueEntryMapp.Modify();
                end;
            until RSRetValueEntryMapp.Next() = 0;
    end;
}