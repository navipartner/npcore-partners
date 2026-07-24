codeunit 6248741 "NPR Module Licensing Feat." implements "NPR Feature Management"
{
    Access = Internal;

    var
        FeatureIdTok: Label 'ModuleLicensing', Locked = true, MaxLength = 50;
        FeatureDescriptionLbl: Label 'Module Licensing (POS, KDS, Scanner)', MaxLength = 2024;
        PortalApiNotAccessibleErr: Label 'Cannot enable Module Licensing: the licensing portal API is not reachable. Verify the service and try again.';

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        if Feature.Get(FeatureIdTok) then
            exit;
        Feature.Init();
        Feature.Id := FeatureIdTok;
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, Enum::"NPR Feature"::"NPR Module Licensing");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(FeatureIdTok) then
            exit(false);
        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        if not Feature.Get(FeatureIdTok) then begin
            AddFeature();
            Feature.Get(FeatureIdTok);
        end;
        if Feature.Enabled = NewEnabled then
            exit;

        // The portal-reachability probe (KeyVault fetch + 30s HTTP) must run ONLY when it can matter. AL `and` does
        // not short-circuit, so a flat conjunction would execute the probe on every state change — including the
        // headless install/upgrade re-enable path (FeatureManagementInstall.InitFeatures) and in non-controlled
        // environments. Nesting keeps it interactive + controlled-environment only; the Error can never fail a
        // headless upgrade because GuiAllowed() is false there.
        if NewEnabled then
            if GuiAllowed() then
                if LicenseMgt.IsControlledEnvironment() then
                    if not LicenseMgt.IsPortalApiAccessible() then
                        Error(PortalApiNotAccessibleErr);

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    procedure GetFeatureId(): Text[50]
    begin
        exit(FeatureIdTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure ConfirmModuleLicensingToggle(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DisableConfirmQst: Label 'Disabling Module Licensing turns off POS, KDS and Scanner license enforcement for this company. Are you sure you want to disable it?';
    begin
        if Rec.Id <> FeatureIdTok then
            exit;
        if (CurrFieldNo = 0) or Rec.IsTemporary() then
            exit;
        if Rec.Enabled = xRec.Enabled then
            exit;

        // Confirm on manual disable so it isn't switched off by accident. Not hard-blocked: it's our only kill-switch.
        if not Rec.Enabled then
            if GuiAllowed() then
                if not ConfirmManagement.GetResponseOrDefault(DisableConfirmQst, false) then begin
                    Rec.Enabled := true; // declined -> keep enforcement on
                    Rec.Modify();
                    exit;
                end;

        LogModuleLicensingToggle(Rec.Enabled);
    end;

    local procedure LogModuleLicensingToggle(NewEnabled: Boolean)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ToggleTelemetryTok: Label 'NPR Module Licensing feature Enabled set to %1 by user %2 in company %3.', Locked = true;
    begin
        // Audit trail for enable/disable, so we can detect rather than block a switch-off.
        CustomDimensions.Add('NPR_Enabled', Format(NewEnabled));
        CustomDimensions.Add('NPR_UserID', UserId());
        CustomDimensions.Add('NPR_Company', CompanyName());
        Session.LogMessage('NPR_ModuleLicensingToggle', StrSubstNo(ToggleTelemetryTok, NewEnabled, UserId(), CompanyName()), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}
