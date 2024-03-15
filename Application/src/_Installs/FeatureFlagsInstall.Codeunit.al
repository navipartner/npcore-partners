codeunit 6151514 "NPR Feature Flags Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        PrepareFeatureFlags();
        PrepareStandardFeatureFlags();
    end;

    local procedure PrepareFeatureFlags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Install", 'PrepareFeatureFlags')) then
            exit;
        FeatureFlagsManagement.InitFeatureFlagSetup();
        FeatureFlagsManagement.ScheduleGetFeatureFlagsIntegration();
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Install", 'PrepareFeatureFlags'));
    end;

    #region MS standard feature flag handling
    //Add standard MS feature flags now to avoid the code running later and causing problems elsewhere
    procedure PrepareStandardFeatureFlags()
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        GLCurrencyRevaluationTxt: Label 'GLCurrencyRevaluation', Locked = true;
#endif
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        FeatureManagementFacade.IsEnabled(GLCurrencyRevaluationTxt);  //Causes a write transaction in one of our try functions when first run (see https://linear.app/navipartner/issue/ISV2-295)
#endif
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        PrepareStandardFeatureFlags();
    end;
    #endregion
}