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
}
