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
    end;

    // NOTE: use procedure RefreshExperienceTierCurrentCompany every time new feature is added if you want to update related application area accordingly
    internal procedure AddFeatures()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Feature Management Install', 'AddFeatures');

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Management Install", 'AddFeatures')) then begin
            InitFeatures();
            RefreshExperienceTierCurrentCompany(); // refresh of experience tier has to be done in order to trigger OnGetEssentialExperienceAppAreas publisher

            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Management Install", 'AddFeatures'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure InitFeatures()
    var
        Feature: Enum "NPR Feature";
    begin
        AddFeature(Feature::Retail);
        AddFeature(Feature::"Ticket Essential");
        AddFeature(Feature::"Ticket Advanced");
        AddFeature(Feature::"Ticket Wallet");
        AddFeature(Feature::"Ticket Dynamic Price");
        AddFeature(Feature::NaviConnect);
        AddFeature(Feature::"Membership Essential");
        AddFeature(Feature::"Membership Advanced");
        AddFeature(Feature::HeyLoyalty);
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