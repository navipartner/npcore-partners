codeunit 85256 "NPR Ext JQ Refresher Only Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure Feature_RegisteredAtInstall()
    var
        Feature: Record "NPR Feature";
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
    begin
        // [Scenario] The feature must be registered by FeatureManagementInstall.InitFeatures. This pins that
        //            registration: if the AddFeature(...) line is ever dropped in a merge, the fresh-install
        //            auto-enable silently no-ops (SetFeatureEnabled exits when Get fails), defeating the feature's
        //            purpose with no error. Deliberately does NOT call EnsureFeaturePresent, and is declared first
        //            so it sees only install state (TestIsolation = Codeunit does not roll back between tests in the
        //            same codeunit, so a later EnsureFeaturePresent would otherwise mask a lost registration).
        _Assert.IsTrue(Feature.Get(ExtJQRefresherOnlyFeat.GetFeatureId()),
            'The External-JQ-Refresher-Only feature should be registered at install by FeatureManagementInstall.');
    end;

    [Test]
    procedure Feature_Toggle_RoundTrips()
    var
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] The External-JQ-Refresher-Only feature flag round-trips through the standard
        //            NPR Feature framework: SetFeatureEnabled is reflected by IsFeatureEnabled.
        EnsureFeaturePresent();
        OriginalEnabled := ExtJQRefresherOnlyFeat.IsFeatureEnabled();

        // [When] The feature is turned on
        ExtJQRefresherOnlyFeat.SetFeatureEnabled(true);
        // [Then] It reads back as enabled
        _Assert.IsTrue(ExtJQRefresherOnlyFeat.IsFeatureEnabled(), 'Feature should read back as enabled after SetFeatureEnabled(true).');

        // [When] The feature is turned off
        ExtJQRefresherOnlyFeat.SetFeatureEnabled(false);
        // [Then] It reads back as disabled
        _Assert.IsFalse(ExtJQRefresherOnlyFeat.IsFeatureEnabled(), 'Feature should read back as disabled after SetFeatureEnabled(false).');

        ExtJQRefresherOnlyFeat.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure V1LogonRefresh_DisabledWhenFeatureOn()
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueUserHandler: Codeunit "NPR Job Queue User Handler";
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] When the feature is on, the legacy logon-triggered (non-external) refresher must be reported
        //            as disabled even for a setup that would otherwise be eligible for it. The record is seeded
        //            in-memory (Enabled = true, external = false) so the assertion proves the feature guard fires,
        //            not that the setup happened to be disabled on the test tenant.
        EnsureFeaturePresent();
        OriginalEnabled := ExtJQRefresherOnlyFeat.IsFeatureEnabled();
        ExtJQRefresherOnlyFeat.SetFeatureEnabled(true);

        JobQueueRefreshSetup.Init();
        JobQueueRefreshSetup.Enabled := true;
        JobQueueRefreshSetup."Use External JQ Refresher" := false;

        // [When/Then] The legacy-refresh decision is evaluated for an otherwise-eligible setup
        _Assert.IsFalse(JobQueueUserHandler.IsLegacyRefreshAllowed(JobQueueRefreshSetup),
            'Legacy logon-triggered refresher must be disabled while the External-JQ-Refresher-Only feature is on, even when the setup would otherwise enable it.');

        ExtJQRefresherOnlyFeat.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure V1LogonRefresh_FollowsSetupWhenFeatureOff()
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueUserHandler: Codeunit "NPR Job Queue User Handler";
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] With the feature off (every existing tenant), the legacy-refresh decision must still follow the
        //            original rule: run only when the refresher is Enabled and external mode is off. The record is
        //            seeded in-memory, so no HTTP is triggered and the tenant's persisted setup is never touched.
        EnsureFeaturePresent();
        OriginalEnabled := ExtJQRefresherOnlyFeat.IsFeatureEnabled();
        ExtJQRefresherOnlyFeat.SetFeatureEnabled(false);

        // [Then] Enabled + not external -> legacy refresh allowed
        JobQueueRefreshSetup.Init();
        JobQueueRefreshSetup.Enabled := true;
        JobQueueRefreshSetup."Use External JQ Refresher" := false;
        _Assert.IsTrue(JobQueueUserHandler.IsLegacyRefreshAllowed(JobQueueRefreshSetup),
            'With the feature off, legacy refresh should be allowed when Enabled and external mode is off.');

        // [Then] Not Enabled -> not allowed
        JobQueueRefreshSetup.Enabled := false;
        JobQueueRefreshSetup."Use External JQ Refresher" := false;
        _Assert.IsFalse(JobQueueUserHandler.IsLegacyRefreshAllowed(JobQueueRefreshSetup),
            'With the feature off, legacy refresh should not be allowed when the refresher is not Enabled.');

        // [Then] External mode on -> not allowed (v2 handles it instead)
        JobQueueRefreshSetup.Enabled := true;
        JobQueueRefreshSetup."Use External JQ Refresher" := true;
        _Assert.IsFalse(JobQueueUserHandler.IsLegacyRefreshAllowed(JobQueueRefreshSetup),
            'With the feature off, legacy refresh should not be allowed when the external refresher is in use.');

        ExtJQRefresherOnlyFeat.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure ExternalEnable_ForcesEnabled_PerFeatureState()
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] The auto-management that keeps the web-service gate satisfiable while the Enabled field is
        //            hidden: enabling external must force Enabled = true when the feature is on, and leave the
        //            setup untouched when it is off. Exercised on an in-memory record (no DB writes; it only reads
        //            User Personalization to bootstrap the time zone).
        EnsureFeaturePresent();
        OriginalEnabled := ExtJQRefresherOnlyFeat.IsFeatureEnabled();

        // [When] Feature on and external is being enabled
        ExtJQRefresherOnlyFeat.SetFeatureEnabled(true);
        JobQueueRefreshSetup.Init();
        JobQueueRefreshSetup.Enabled := false;
        JobQueueRefreshSetup.ForceEnabledForExtJQRefresherOnly();
        // [Then] Enabled is forced true so the WS gate ("Use External" and "Enabled") can be satisfied
        _Assert.IsTrue(JobQueueRefreshSetup.Enabled, 'Enabling external with the feature on must force Enabled = true.');

        // [When] Feature off
        ExtJQRefresherOnlyFeat.SetFeatureEnabled(false);
        JobQueueRefreshSetup.Init();
        JobQueueRefreshSetup.Enabled := false;
        JobQueueRefreshSetup.ForceEnabledForExtJQRefresherOnly();
        // [Then] The master switch is left as-is (legacy behavior preserved)
        _Assert.IsFalse(JobQueueRefreshSetup.Enabled, 'With the feature off, enabling external must not force Enabled.');

        ExtJQRefresherOnlyFeat.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    procedure ManualEnable_OnBeforeValidate_DeclineReverts()
    var
        Feature: Record "NPR Feature";
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] Pins the manual-enable guard (OnBeforeValidateEvent on NPR Feature.Enabled) that the other
        //            tests bypass by toggling via SetFeatureEnabled (direct Modify). On a supported host (Cloud,
        //            BC22+ - which the feature targets and the test environment is) validating Enabled = true raises
        //            the guard's confirm; declining it must leave the feature disabled. This exercises the subscriber
        //            wiring and the Rec.Id filter. Asserted via state, not translatable error text.
        EnsureFeaturePresent();
        OriginalEnabled := ExtJQRefresherOnlyFeat.IsFeatureEnabled();
        ExtJQRefresherOnlyFeat.SetFeatureEnabled(false);

        Feature.Get(ExtJQRefresherOnlyFeat.GetFeatureId());
        Feature.Validate(Enabled, true); // ConfirmHandlerNo declines the guard's confirmation -> guard reverts

        _Assert.IsFalse(ExtJQRefresherOnlyFeat.IsFeatureEnabled(),
            'Declining the confirmation on manual enable must leave the feature disabled.');

        ExtJQRefresherOnlyFeat.SetFeatureEnabled(OriginalEnabled);
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerNo(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    local procedure EnsureFeaturePresent()
    var
        Feature: Record "NPR Feature";
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
    begin
        // The feature row is normally inserted at install (FeatureManagementInstall). Insert it here if a
        // bare test tenant is missing it, so the toggle helpers are not silent no-ops.
        if not Feature.Get(ExtJQRefresherOnlyFeat.GetFeatureId()) then
            ExtJQRefresherOnlyFeat.AddFeature();
    end;
}
