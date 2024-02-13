codeunit 6151581 "NPR Obsolete Tables Cleanup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Obsolete Tables Cleanup', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup")) then begin
            CleanupAuxItemLedgerEntry();
            CleanupAuxValueEntry();
            CleanupAuxItem();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup"));
        end;

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup", 'CleanupAuxGLEntry')) then
            if CleanupAuxGLEntry() then
                UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup", 'CleanupAuxGLEntry'));

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup", 'CleanupAuditRoll')) then
            if CleanupAuditRoll() then
                UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup", 'CleanupAuditRoll'));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure CleanupAuxItemLedgerEntry()
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        AuxItemLedgerEntry.DeleteAll(false);
    end;

    local procedure CleanupAuxValueEntry()
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
    begin
        AuxValueEntry.DeleteAll(false);
    end;

    local procedure CleanupAuxGLEntry(): Boolean
    var
        AuxGLEntry: Record "NPR Aux. G/L Entry";
    begin
        if not (AuxGLEntry.ReadPermission() and AuxGLEntry.WritePermission()) then
            exit(false);
        AuxGLEntry.DeleteAll(false);
        exit(true);
    end;

    local procedure CleanupAuxItem()
    var
        AuxiliaryItem: Record "NPR Auxiliary Item";
    begin
        AuxiliaryItem.DeleteAll(false);
    end;

    local procedure CleanupAuditRoll(): Boolean
    var
        AuditRoll: Record "NPR Audit Roll";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(false);
        if not (AuditRoll.ReadPermission() and AuditRoll.WritePermission()) then
            exit(false);
        AuditRoll.DeleteAll(false);
        exit(true);
    end;
}
