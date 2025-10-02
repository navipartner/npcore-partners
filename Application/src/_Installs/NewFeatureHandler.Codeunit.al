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

    internal procedure HandleNewSalesReceiptExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewSalesReceiptExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewSalesReceiptExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewSalesReceiptExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewSalesReceiptExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandleNewEFTReceiptExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewEFTReceiptExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewEFTReceiptExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewEFTReceiptExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewEFTReceiptExperienceHandle'));
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

    internal procedure HandleNewMagentoFeature()
    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeStep: Text;
    begin
        UpgradeStep := 'EnableMagentoFeature';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep)) then
            exit;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep));
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    internal procedure HandleNewPOSLicenseBillingFeature()
    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeStep: Text;
    begin
        UpgradeStep := 'AddPOSBillingFeature';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep)) then
            exit;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep));
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

    local procedure NewSalesReceiptExperienceHandle()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Feature: Record "NPR Feature";
        NewSalesReceiptExp: Codeunit "NPR New Sales Receipt Exp";
    begin
        if not Feature.Get(NewSalesReceiptExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
        ReportSelectionRetail.ModifyAll("Print Template", '');
    end;

    local procedure NewEFTReceiptExperienceHandle()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Feature: Record "NPR Feature";
        NewEFTReceiptExp: Codeunit "NPR New EFT Receipt Exp";
    begin
        if not Feature.Get(NewEFTReceiptExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Terminal Receipt");
        ReportSelectionRetail.ModifyAll("Print Template", '');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR New Feature Handler");
    end;
}
