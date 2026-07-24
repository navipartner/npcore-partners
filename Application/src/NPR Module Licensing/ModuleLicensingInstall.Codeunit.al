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
        if not Feature.Get(ModuleLicensingFeat.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
        // No portal-reachability check here: enabling is head-less and must not fail an install on a transient outage.
        // Runtime enforcement is still confined to controlled environments by NPR License Mgt.IsControlledEnvironment().
    end;
}
