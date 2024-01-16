codeunit 6184726 "NPR BG SIS Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR BG SIS Upgrade', 'OnUpgradeDataPerCompany');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR BG SIS Upgrade", 'add-salesperson-to-bg-sis-audit-log')) then begin
            UpdateSalespersonCodeOnBGSISPOSAuditLog();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR BG SIS Upgrade", 'add-salesperson-to-bg-sis-audit-log'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR BG SIS Upgrade", 'blank-item-description')) then begin
            PopulateBlankItemDescriptionOnPOSEntrySalesLines();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR BG SIS Upgrade", 'blank-item-description'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateSalespersonCodeOnBGSISPOSAuditLog()
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        POSEntry: Record "NPR POS Entry";
    begin
        if BGSISPOSAuditLogAux.FindSet(true) then
            repeat
                if POSEntry.Get(BGSISPOSAuditLogAux."POS Entry No.") then begin
                    BGSISPOSAuditLogAux."Salesperson Code" := POSEntry."Salesperson Code";
                    BGSISPOSAuditLogAux.Modify();
                end;
            until BGSISPOSAuditLogAux.Next() = 0;
    end;

    local procedure PopulateBlankItemDescriptionOnPOSEntrySalesLines()
    var
        Item: Record Item;
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        if not BGFiscalizationSetup.Get() then
            exit;

        if not BGFiscalizationSetup."BG SIS Fiscal Enabled" then
            exit;

        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.SetRange(Description, '');
        if POSEntrySalesLine.FindSet(true) then
            repeat
                if Item.Get(POSEntrySalesLine."No.") then begin
                    POSEntrySalesLine.Description := Item.Description;
                    POSEntrySalesLine.Modify();
                end;
            until POSEntrySalesLine.Next() = 0;
    end;
}
