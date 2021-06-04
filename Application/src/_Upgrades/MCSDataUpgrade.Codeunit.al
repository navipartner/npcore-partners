codeunit 6014412 "NPR MCS Data Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR MCS Data Upgrade', 'OnUpgradeDataPerCompany');

        if UpgradeTagMgt.HasUpgradeTag(GetMagentoPassUpgradeTag()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateSetupAPIKeys();
        UpgradeTagMgt.SetUpgradeTag(GetMagentoPassUpgradeTag());

        LogMessageStopwatch.LogFinish();
    end;

    local procedure GetMagentoPassUpgradeTag(): Text
    begin
        exit('NPR_MCS_Data_Upgrade');
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
