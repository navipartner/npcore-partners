codeunit 85343 "NPR JQ Notif NP Email Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure Feature_RegisteredAtInstall()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
    begin
        // Declared first and deliberately without Reset so it sees install state: if the AddFeature(...) line is
        // lost in a merge, SetFeatureEnabled still creates the row and every other test would mask the loss.
        _Assert.IsTrue(Feature.Get(JQNotifNPEmailFeature.GetFeatureId()),
            'The JQ-Notifications-via-NP-Email feature should be registered at install by FeatureManagementInstall.');
    end;

    [Test]
    procedure AutoEnable_SkippedWhenNewEmailExperienceOff()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
    begin
        Reset();

        JQNotifNPEmailFeature.EnableIfNoLegacySetupInUse();

        _Assert.IsFalse(ChildEnabledRaw(), 'The feature must not auto-enable while New Email Experience is off.');
    end;

    [Test]
    procedure AutoEnable_BlockedByLegacyOnlyProfile()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        CreateProfile('LEGACY', true, 'OLDTMPL', '');
        NewEmailExpFeature.SetFeatureEnabled(true);

        JQNotifNPEmailFeature.EnableIfNoLegacySetupInUse();

        _Assert.IsFalse(ChildEnabledRaw(), 'A profile relying only on a legacy template must keep the feature off so its notifications keep working.');
    end;

    [Test]
    procedure AutoEnable_WhenNoProfilesExist()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        NewEmailExpFeature.SetFeatureEnabled(true);

        JQNotifNPEmailFeature.EnableIfNoLegacySetupInUse();

        _Assert.IsTrue(ChildEnabledRaw(), 'With no notification profiles configured the feature should auto-enable.');
    end;

    [Test]
    procedure AutoEnable_WhenProfileAlreadyMigrated()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        CreateProfile('MIGRATED', true, 'OLDTMPL', 'NEWTMPL');
        NewEmailExpFeature.SetFeatureEnabled(true);

        JQNotifNPEmailFeature.EnableIfNoLegacySetupInUse();

        _Assert.IsTrue(ChildEnabledRaw(), 'A profile carrying an NP Email template must not block the auto-enable.');
    end;

    [Test]
    procedure AutoEnable_WhenMixedProfiles()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        // A populated NP Email template can only have been set while the feature was already on, so a mixed
        // company counts as "someone started configuring it" and keeps the feature enabled.
        Reset();
        CreateProfile('LEGACY', true, 'OLDTMPL', '');
        CreateProfile('MIGRATED', true, 'OLDTMPL', 'NEWTMPL');
        NewEmailExpFeature.SetFeatureEnabled(true);

        JQNotifNPEmailFeature.EnableIfNoLegacySetupInUse();

        _Assert.IsTrue(ChildEnabledRaw(), 'A mixed setup must stay enabled, because the populated NP Email template proves the feature was already in use.');
    end;

    [Test]
    procedure AutoEnable_IgnoresProfileNotSendingEmail()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        CreateProfile('NOEMAIL', false, 'OLDTMPL', '');
        NewEmailExpFeature.SetFeatureEnabled(true);

        JQNotifNPEmailFeature.EnableIfNoLegacySetupInUse();

        _Assert.IsTrue(ChildEnabledRaw(), 'A profile that does not send e-mail must not block the auto-enable.');
    end;

    [Test]
    procedure Gate_FollowsNewEmailExperience()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        NewEmailExpFeature.SetFeatureEnabled(true);
        JQNotifNPEmailFeature.SetFeatureEnabled(true);
        _Assert.IsTrue(JQNotifNPEmailFeature.IsFeatureEnabled(), 'Precondition: both features enabled.');

        NewEmailExpFeature.SetFeatureEnabled(false);

        _Assert.IsFalse(JQNotifNPEmailFeature.IsFeatureEnabled(), 'The send path must fall back to legacy when New Email Experience is off.');
        _Assert.IsTrue(ChildEnabledRaw(), 'A direct (non-validated) parent change must leave the feature record itself untouched.');
    end;

    [Test]
    procedure Sync_ParentDisableTurnsFeatureOff()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        NewEmailExpFeature.SetFeatureEnabled(true);
        JQNotifNPEmailFeature.SetFeatureEnabled(true);

        ValidateParentEnabled(false);

        _Assert.IsFalse(ChildEnabledRaw(), 'Disabling New Email Experience on the page must switch this feature off too, so the page cannot show it enabled while it is inactive.');
    end;

    [Test]
    procedure Sync_ParentEnableRunsAutoEnable()
    begin
        Reset();

        ValidateParentEnabled(true);

        _Assert.IsTrue(ChildEnabledRaw(), 'Enabling New Email Experience on the page must evaluate and enable this feature when nothing legacy is in use.');
    end;

    [Test]
    procedure Sync_ParentEnableRespectsLegacyOnlySetup()
    begin
        Reset();
        CreateProfile('LEGACY', true, 'OLDTMPL', '');

        ValidateParentEnabled(true);

        _Assert.IsFalse(ChildEnabledRaw(), 'Enabling New Email Experience must not switch a legacy-only company over to NP Email.');
    end;

    [Test]
    procedure ManualEnable_RequiresNewEmailExperience()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
    begin
        Reset();

        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        asserterror Feature.Validate(Enabled, true);

        _Assert.IsFalse(ChildEnabledRaw(), 'Enabling this feature while New Email Experience is off must be refused.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    procedure ManualEnable_DeclineOnUnconfiguredProfileReverts()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        CreateProfile('EMPTY', true, '', '');
        NewEmailExpFeature.SetFeatureEnabled(true);

        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        Feature.Validate(Enabled, true);

        _Assert.IsFalse(Feature.Enabled, 'Declining the warning about profiles without an NP Email template must revert the enable.');
    end;

    [Test]
    procedure ManualEnable_NoWarningWhenAllProfilesConfigured()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        // No ConfirmHandler is declared, so an unexpected confirmation would fail this test.
        Reset();
        CreateProfile('MIGRATED', true, '', 'NEWTMPL');
        NewEmailExpFeature.SetFeatureEnabled(true);

        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        Feature.Validate(Enabled, true);

        _Assert.IsTrue(Feature.Enabled, 'Enabling with every profile configured must not warn and must stay enabled.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ManualEnable_AcceptOnUnconfiguredProfileProceeds()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        CreateProfile('EMPTY', true, '', '');
        NewEmailExpFeature.SetFeatureEnabled(true);

        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        Feature.Validate(Enabled, true);

        _Assert.IsTrue(Feature.Enabled, 'Accepting the warning must let the enable go through.');
    end;

    [Test]
    procedure ManualDisable_IsAlwaysAllowed()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        // The profile below would trigger the warning on enable; disabling must pass without any confirmation,
        // and no ConfirmHandler is declared so an unexpected dialog would fail this test.
        Reset();
        NewEmailExpFeature.SetFeatureEnabled(true);
        JQNotifNPEmailFeature.SetFeatureEnabled(true);
        CreateProfile('EMPTY', true, '', '');

        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        Feature.Validate(Enabled, false);
        Feature.Modify();

        _Assert.IsFalse(ChildEnabledRaw(), 'Turning the feature off must always be allowed so a tenant can fall back to the legacy path.');
    end;

    [Test]
    procedure AutoEnable_WhenProfileHasNoTemplateAtAll()
    var
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        CreateProfile('EMPTY', true, '', '');
        NewEmailExpFeature.SetFeatureEnabled(true);

        JQNotifNPEmailFeature.EnableIfNoLegacySetupInUse();

        _Assert.IsTrue(ChildEnabledRaw(), 'A profile with no template at all was already failing before this change, so it must not block the auto-enable.');
    end;

    [Test]
    procedure ManualEnable_NoWarningForProfileNotSendingEmail()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        CreateProfile('NOEMAIL', false, '', '');
        NewEmailExpFeature.SetFeatureEnabled(true);

        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        Feature.Validate(Enabled, true);

        _Assert.IsTrue(Feature.Enabled, 'A profile that does not send e-mail must not raise the missing-template warning.');
    end;

    [Test]
    procedure Gate_ReportsDisabledWhenFeatureRowMissing()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Reset();
        NewEmailExpFeature.SetFeatureEnabled(true);
        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        Feature.Delete();

        _Assert.IsFalse(JQNotifNPEmailFeature.IsFeatureEnabled(), 'A missing feature row must read as disabled rather than fail.');

        JQNotifNPEmailFeature.AddFeature();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerNo(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure Reset()
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        EnsureFeaturesPresent();
        NewEmailExpFeature.SetFeatureEnabled(false);
        JQNotifNPEmailFeature.SetFeatureEnabled(false);
        JQNotifProfile.DeleteAll();
    end;

    local procedure EnsureFeaturesPresent()
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        if not Feature.Get(JQNotifNPEmailFeature.GetFeatureId()) then
            JQNotifNPEmailFeature.AddFeature();
        if not Feature.Get(NewEmailExpFeature.GetFeatureId()) then
            NewEmailExpFeature.AddFeature();
    end;

    local procedure CreateProfile(ProfileCode: Code[20]; SendEmail: Boolean; LegacyTemplateCode: Code[20]; NPEmailTemplateId: Code[20])
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
    begin
        JQNotifProfile.Init();
        JQNotifProfile.Code := ProfileCode;
        JQNotifProfile."Send E-mail" := SendEmail;
        JQNotifProfile."E-mail Template Code" := LegacyTemplateCode;
        JQNotifProfile."E-mail Template Id" := NPEmailTemplateId;
        JQNotifProfile.Insert();
    end;

    local procedure ValidateParentEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        Feature.Get(NewEmailExpFeature.GetFeatureId());
        Feature.Validate(Enabled, NewEnabled);
        Feature.Modify();
    end;

    local procedure ChildEnabledRaw(): Boolean
    var
        Feature: Record "NPR Feature";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
    begin
        Feature.Get(JQNotifNPEmailFeature.GetFeatureId());
        exit(Feature.Enabled);
    end;
}
