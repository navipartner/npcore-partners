codeunit 6150632 "NPR New Feature Handler"
{
    Access = Internal;

    internal procedure HandlePOSEditorFeature()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'POSEditorFeatureHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSEditorFeatureHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        POSEditorFeatureHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSEditorFeatureHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandleScenarioObsoletedFeature()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'ScenarioObsoletedFeatureHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ScenarioObsoletedFeatureHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        ScenarioObsoletedFeatureHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ScenarioObsoletedFeatureHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandlePOSStatisticsDashboardFeature()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'POSStatisticsDashboardFeatureHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSStatisticsDashboardFeatureHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        POSStatisticsDashboardFeatureHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSStatisticsDashboardFeatureHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandlePOSWebserviceSessionsFeature()
    var
        Feature: Record "NPR Feature";
        POSWebserviceSessions: Codeunit "NPR POS Webservice Sessions";
    begin
        if not Feature.Get(POSWebserviceSessions.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure HandleNewEmailFeature()
    var
        NewEmailFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        NewEmailFeature.SetFeatureEnabled(true);
    end;
#endif

    local procedure POSEditorFeatureHandle()
    var
        Feature: Record "NPR Feature";
        NewPOSEditorFeature: Codeunit "NPR New POS Editor Feature";
    begin
        if not Feature.Get(NewPOSEditorFeature.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    local procedure ScenarioObsoletedFeatureHandle()
    var
        Feature: Record "NPR Feature";
        ScenarioObsoletedFeature: Codeunit "NPR Scenario Obsoleted Feature";
    begin
        if not Feature.Get(ScenarioObsoletedFeature.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    local procedure POSStatisticsDashboardFeatureHandle()
    var
        Feature: Record "NPR Feature";
        POSStatisticsDashboardFeature: Codeunit "NPR POS Stat Dashboard Feature";
    begin
        if not Feature.Get(POSStatisticsDashboardFeature.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR New Feature Handler");
    end;
}
