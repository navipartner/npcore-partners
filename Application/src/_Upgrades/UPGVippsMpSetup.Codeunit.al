codeunit 6184752 "NPR UPG Vipps Mp Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        MpVipps: Codeunit "NPR Vipps Mp WebService";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Vipps Mp Setup', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Vipps Mp Setup", 'VippsMobilepaySetup')) then begin
            MpVipps.InitMpVippsWebserviceWebService();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Vipps Mp Setup", 'VippsMobilepaySetup'));
        end;

        LogMessageStopwatch.LogFinish();
    end;


}
