codeunit 6151434 "NPR Feature Management Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        AddFeatures();
        HandleNewFeatures();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, false)]
    local procedure HandleOnCompanyInitialize()
    begin
        InitFeatures();
        RefreshExperienceTierCurrentCompany();
    end;

    // NOTE: use procedure RefreshExperienceTierCurrentCompany every time new feature is added if you want to update related application area accordingly
    internal procedure AddFeatures()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Feature Management Install', 'AddFeatures');

        InitFeatures();
        RefreshExperienceTierCurrentCompany(); // refresh of experience tier has to be done in order to trigger OnGetEssentialExperienceAppAreas publisher

        LogMessageStopwatch.LogFinish();
    end;

    local procedure InitFeatures()
    var
        ExistingFeature: Record "NPR Feature";
        TempExistingFeature: Record "NPR Feature" temporary;
        FeatureManagement: Interface "NPR Feature Management";
        Feature: Enum "NPR Feature";
    begin
        if ExistingFeature.FindSet() then
            repeat
                TempExistingFeature := ExistingFeature;
                TempExistingFeature.Insert();
            until ExistingFeature.Next() = 0;
        ExistingFeature.DeleteAll();

        AddFeature(Feature::Retail);
        AddFeature(Feature::"Ticket Essential");
        AddFeature(Feature::"Ticket Advanced");
        AddFeature(Feature::"Ticket Wallet");
        AddFeature(Feature::"Ticket Dynamic Price");
        AddFeature(Feature::NaviConnect);
        AddFeature(Feature::"Membership Essential");
        AddFeature(Feature::"Membership Advanced");
        AddFeature(Feature::HeyLoyalty);
#if not BC17
        AddFeature(Feature::Shopify);
#endif
        AddFeature(Feature::"POS Scenarios Obsoleted");
        AddFeature(Feature::"New POS Editor");
        AddFeature(Feature::"POS Statistics Dashboard");
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        AddFeature(Feature::"NP Email");
        AddFeature(Feature::"New Email Experience");
#endif
        AddFeature(Feature::"POS Webservice Sessions");
        AddFeature(Feature::"New Sales Receipt Experience");
        AddFeature(Feature::"New EFT Receipt Experience");
        AddFeature(Feature::Magento);

        if ExistingFeature.FindSet() then
            repeat
                TempExistingFeature.SetRange(Feature, ExistingFeature.Feature);
                if TempExistingFeature.FindFirst() and TempExistingFeature.Enabled then begin
                    FeatureManagement := ExistingFeature.Feature;
                    if not FeatureManagement.IsFeatureEnabled() then
                        FeatureManagement.SetFeatureEnabled(true);
                end;
            until ExistingFeature.Next() = 0;
    end;

    local procedure HandleNewFeatures()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
    begin
        NewFeatureHandler.HandlePOSEditorFeature();
        NewFeatureHandler.HandleScenarioObsoletedFeature();
        NewFeatureHandler.HandlePOSStatisticsDashboardFeature();
        NewFeatureHandler.HandlePOSWebserviceSessionsFeature();
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        NewFeatureHandler.HandleNewEmailFeature();
#endif
        NewFeatureHandler.HandleNewSalesReceiptExperience();
        NewFeatureHandler.HandleNewEFTReceiptExperience();
        NewFeatureHandler.HandleNewMagentoFeature();
        RefreshExperienceTierCurrentCompany();
    end;

    local procedure AddFeature(FeatureToAdd: Enum "NPR Feature")
    var
        FeatureManagement: Interface "NPR Feature Management";
    begin
        FeatureManagement := FeatureToAdd;
        FeatureManagement.AddFeature();
    end;

    // this procedure should be called every time new feature is added if you want to update related application area accordingly
    local procedure RefreshExperienceTierCurrentCompany()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}