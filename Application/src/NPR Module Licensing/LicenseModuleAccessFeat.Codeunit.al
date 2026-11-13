// Rollout switch for the per-user UI hiding CORE-2396 added on top of "NPR Module Licensing" (application-area
// filter, role-center notice, POS page check). Off by default; NP support enables it per company once the
// portal has migrated SKUs and admins have assigned licenses.
// The POS license gate is NOT behind this switch: it is the pre-existing POS gate (feature "NPR Module Licensing"),
// now reading capabilities.
codeunit 6151306 "NPR License Module Access Feat" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        if Feature.Get(GetFeatureId()) then
            exit;
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"License-Based Module Access");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit(false);
        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit;
        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    internal procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'LicenseBasedModuleAccess', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'License-Based Module Access (hide NP Retail UI without an NP license; requires NPR Module Licensing)', MaxLength = 2048;
    begin
        exit(FeatureDescriptionLbl);
    end;
}
