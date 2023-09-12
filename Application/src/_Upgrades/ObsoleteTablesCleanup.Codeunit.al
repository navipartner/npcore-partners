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

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CleanupAuxItemLedgerEntry();
        CleanupAuxValueEntry();
        CleanupAuxGLEntry();
        CleanupAuxItem();
        CleanupAuditRoll();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup"));

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

    local procedure CleanupAuxGLEntry()
    var
        AuxGLEntry: Record "NPR Aux. G/L Entry";
    begin
        AuxGLEntry.DeleteAll(false);
    end;

    local procedure CleanupAuxItem()
    var
        AuxiliaryItem: Record "NPR Auxiliary Item";
    begin
        AuxiliaryItem.DeleteAll(false);
    end;

    local procedure CleanupAuditRoll()
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        AuditRoll.DeleteAll(false);
    end;
}
