codeunit 6014412 "NPR MCS Data Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR MCS Data Upgrade', 'OnUpgradeDataPerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR MCS Data Upgrade")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateSetupAPIKeys();
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR MCS Data Upgrade"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateSetupAPIKeys()
    var
        NPRMCSAPISetup: Record "NPR MCS API Setup";
    begin
        if NPRMCSAPISetup.FindSet() then
            repeat
                NPRMCSAPISetup.Validate("Key 1");
                NPRMCSAPISetup.Validate("Key 2");
                NPRMCSAPISetup.Modify(false);
            until NPRMCSAPISetup.Next() = 0;
    end;
}
