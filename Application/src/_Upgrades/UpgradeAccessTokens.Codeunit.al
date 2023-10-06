codeunit 6184555 "NPR Upgrade Access Tokens"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Access Tokens", 'ClearAccessToken')) then begin
            LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Access Tokens', 'OnUpgradePerCompany');
            ClearAccessToken();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Access Tokens", 'ClearAccessToken'));
            LogMessageStopwatch.LogFinish();
        end;

    end;

    local procedure ClearAccessToken()
    var
        OAuthSetup: Record "NPR OAuth Setup";
    begin
        if not OAuthSetup.FindSet() then
            exit;
        repeat
            if not IsNullGuid(OAuthSetup."Access Token") then
                If IsolatedStorage.Contains(OAuthSetup."Access Token") then begin
                    IsolatedStorage.Delete(OAuthSetup."Access Token", DataScope::Company);
                    OAuthSetup."Access Token Due DateTime" := 0DT;
                    OAuthSetup.Modify();
                end;
        until OAuthSetup.Next() = 0;
    end;

}
