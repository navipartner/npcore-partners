codeunit 6248441 "NPR UPG BC Health Check WS"
{
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerDatabase()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        BCHealthCheckMgt: Codeunit "NPR BC Health Check Mgt.";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG BC Health Check WS', 'Upgrade');

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG BC Health Check WS", 'RegisterService')) then begin
            BCHealthCheckMgt.RegisterService();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG BC Health Check WS", 'RegisterService'));
        end;

        LogMessageStopwatch.LogFinish();
    end;
#endif
}