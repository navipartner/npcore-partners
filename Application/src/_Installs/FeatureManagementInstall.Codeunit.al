codeunit 6151434 "NPR Feature Management Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        AddFeatures();
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
#if BC17
        ExistingFeature.SetRange(Feature, Feature::Retail, Feature::HeyLoyalty);
#else
        ExistingFeature.SetRange(Feature, Feature::Retail, Feature::Shopify);
#endif
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