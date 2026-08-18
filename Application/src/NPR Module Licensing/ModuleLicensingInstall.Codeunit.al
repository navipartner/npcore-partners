codeunit 6248195 "NPR Module Licensing Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        EnableForFreshInstall();
    end;

    local procedure EnableForFreshInstall()
    var
        POSEntry: Record "NPR POS Entry";
        Feature: Record "NPR Feature";
        DemoTenantMgt: Codeunit "NPR Demo Tenant Mgt.";
        ModuleLicensingFeat: Codeunit "NPR Module Licensing Feat.";
        AppInfo: ModuleInfo;
    begin
        // A 'DataVersion' of 0.0.0.0 indicates a 'fresh/new' install
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() <> Version.Create(0, 0, 0, 0) then
            exit;

        // Greenfield: never auto-enable once POS has been used.
        if not POSEntry.IsEmpty() then
            exit;

        ModuleLicensingFeat.AddFeature(); // ensure registered regardless of install-codeunit ordering

        // MDX (formerly CDX) demo tenants: register the feature but leave it off - it can still be switched on/off for demos.
        if DemoTenantMgt.IsMdxEnvironment() then begin
            LogAutoEnableSkippedForMdx();
            exit;
        end;

        if not Feature.Get(ModuleLicensingFeat.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
        // No portal-reachability check here: enabling is head-less and must not fail an install on a transient outage.
        // Runtime enforcement is still confined to controlled environments by NPR License Mgt.IsControlledEnvironment().
    end;

    local procedure LogAutoEnableSkippedForMdx()
    var
        CustomDimensions: Dictionary of [Text, Text];
        AutoEnableSkippedTok: Label 'NPR Module Licensing left disabled at fresh install: MDX demo tenant detected in company %1.', Locked = true;
    begin
        // A misclassified customer surfaces here instead of silently losing enforcement.
        CustomDimensions.Add('NPR_Company', CompanyName());
        Session.LogMessage('NPR_ModuleLicensingAutoEnableSkipped', StrSubstNo(AutoEnableSkippedTok, CompanyName()), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}
