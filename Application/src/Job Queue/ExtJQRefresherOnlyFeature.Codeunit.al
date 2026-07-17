codeunit 6151269 "NPR Ext JQ Refresher Only Feat" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature();
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"External JQ Refresher Only");
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

    procedure SetFeatureEnabled(NewEnabled: Boolean);
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
        FeatureIdTok: Label 'ExtJQRefresherOnly', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'External Job Queue Refresher Only', MaxLength = 2048;
    begin
        exit(FeatureDescriptionLbl);
    end;

    // A company created after install (e.g. the production company provisioned after the default company) runs
    // through OnCompanyInitialize, which the install-time new-tenant handler (NPR New Feature Handler) does not cover.
    // "NPR Feature" is per-company, so the new company would otherwise start with the feature off and run the legacy
    // refresher. Inherit the tenant's stance instead: if any sibling company already has it enabled, enable it for the
    // new company too, keeping an external-only tenant consistent across companies.
    internal procedure EnableForNewCompany()
    var
        Company: Record Company;
        Feature: Record "NPR Feature";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        FeatureId: Text[50];
    begin
        if IsFeatureEnabled() then
            exit;

        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Ext JQ Refresher Only Feat', 'EnableForNewCompany');

        FeatureId := GetFeatureId();
        Company.SetFilter(Name, '<>%1', CompanyName());
        if Company.FindSet() then
            repeat
                Feature.ChangeCompany(Company.Name);
                if Feature.Get(FeatureId) and Feature.Enabled then
                    SetFeatureEnabled(true); // operates on the current (new) company
            until (Company.Next() = 0) or IsFeatureEnabled();

        LogMessageStopwatch.LogFinish();
    end;

    // Guards the manual toggle on the NaviPartner Feature Management page. The install/company-init paths enable
    // the feature via SetFeatureEnabled (direct Modify), which does not raise this validate event, so this only
    // affects an admin turning it on by hand. Enabling blocks the legacy refresher and requires the external one,
    // which is Cloud-only - so refuse OnPrem, and warn about the consequence otherwise.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure GuardEnableOnBeforeValidate(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        ConfirmManagement: Codeunit "Confirm Management";
        OnPremErr: Label 'The External Job Queue Refresher is supported only on cloud environments, so this feature cannot be enabled on OnPrem.';
        EnableWarningQst: Label 'Enabling this feature disables the legacy logon-triggered Job Queue Refresher. The External Job Queue Refresher becomes the only refresher and must be enabled on the Job Queue Refresh Setup page, otherwise job queue refreshing will stop.\Do you want to continue?';
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if not Rec.Enabled then
            exit; // disabling (reverting to legacy behavior) is always allowed
        if xRec.Enabled then
            exit; // no change

        if EnvironmentInformation.IsOnPrem() then
            Error(OnPremErr);
        if not ConfirmManagement.GetResponseOrDefault(EnableWarningQst, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;

        // The master "Enabled" switch becomes hidden once this feature is on. If the tenant already had the external
        // refresher on but Enabled off (a valid pre-feature state - the two were uncoupled), the web-service gate
        // ("Use External JQ Refresher" AND Enabled) would silently fail with no way to fix it from the UI. Bring
        // Enabled in line here, at the moment of enabling (the only way an existing tenant reaches feature-on).
        // Set directly rather than via ForceEnabledForExtJQRefresherOnly: the feature flag is not committed yet, so
        // an IsFeatureEnabled() check would still read the old (false) value.
        JobQueueRefreshSetup.GetSetup();
        if JobQueueRefreshSetup."Use External JQ Refresher" and not JobQueueRefreshSetup.Enabled then begin
            JobQueueRefreshSetup.Enabled := true;
            JobQueueRefreshSetup.InitTimeZone();
            JobQueueRefreshSetup.Modify();
        end;
    end;
}
