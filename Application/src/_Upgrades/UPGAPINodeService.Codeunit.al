codeunit 6150924 "NPR UPG API Node Service"
{
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
        NodeService: Codeunit "NPR API Node Service";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG API Node Service', 'Upgrade');

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG API Node Service", 'API_NODE_SERVICE_INF_721')) then begin
            NodeService.RegisterService();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG API Node Service", 'API_NODE_SERVICE_INF_721'));
        end;

        LogMessageStopwatch.LogFinish();
    end;
}