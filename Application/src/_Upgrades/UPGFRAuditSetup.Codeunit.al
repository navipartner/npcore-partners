codeunit 6014670 "NPR UPG FR Audit Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG FR Audit Setup', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        UpgradeData();
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeData()
    var
        FRAuditSetup: Record "NPR FR Audit Setup";
    begin
        if not FRAuditSetup.Get() then
            exit;

        if FRAuditSetup."Item VAT Identifier Filter" = '' then
            exit;

        FRAuditSetup.SetVATIDFilter(FRAuditSetup."Item VAT Identifier Filter");
        FRAuditSetup.Modify();
    end;

}
