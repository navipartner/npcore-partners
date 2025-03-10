codeunit 6150691 "NPR UPG API WS"
{
    Subtype = Upgrade;
    Access = Internal;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    trigger OnUpgradePerDatabase()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        APIRequestProcessor: Codeunit "NPR API Request Processor";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG API WS', 'Upgrade');

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG API WS", 'APIWS_041224_MMV')) then begin
            APIRequestProcessor.RegisterService();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG API WS", 'APIWS_041224_MMV'));
        end;

        LogMessageStopwatch.LogFinish();
    end;
#endif
}