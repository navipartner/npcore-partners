codeunit 85382 "NPR New Company Feature Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure Inherit_EnablesFeatureEnabledInOtherCompany()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        NewPOSEditorFeature: Codeunit "NPR New POS Editor Feature";
        FeatureIds: List of [Text];
    begin
        // [Scenario] A company created after install starts with the install-enabled features off, because
        //            OnCompanyInitialize only re-inserts them with their AddFeature() defaults. When a sibling
        //            company has the feature on, the new company must end up on as well.
        SetEnabled(NewPOSEditorFeature.GetFeatureId(), false);
        FeatureIds.Add(NewPOSEditorFeature.GetFeatureId());

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        _Assert.IsTrue(IsEnabled(NewPOSEditorFeature.GetFeatureId()),
            'A feature that is enabled in another company must be enabled for the new company too.');
    end;

    [Test]
    procedure Inherit_OnlyEnablesFeaturesInTheList()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        NewPOSEditorFeature: Codeunit "NPR New POS Editor Feature";
        POSStatDashboardFeature: Codeunit "NPR POS Stat Dashboard Feature";
        FeatureIds: List of [Text];
    begin
        // [Scenario] Inheriting one feature must not drag the rest along. This is what pins the per-feature
        //            membership check: if the list were only tested for emptiness, every new company would come up
        //            with all features on, including the ones that can never be switched off again.
        SetEnabled(NewPOSEditorFeature.GetFeatureId(), false);
        SetEnabled(POSStatDashboardFeature.GetFeatureId(), false);
        FeatureIds.Add(NewPOSEditorFeature.GetFeatureId());

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        _Assert.IsTrue(IsEnabled(NewPOSEditorFeature.GetFeatureId()),
            'The feature that another company has on should be enabled.');
        _Assert.IsFalse(IsEnabled(POSStatDashboardFeature.GetFeatureId()),
            'A feature no other company has on must stay off, even when another feature was inherited.');
    end;

    [Test]
    procedure Inherit_LeavesFeatureOffWhenNoOtherCompanyHasIt()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        NewPOSEditorFeature: Codeunit "NPR New POS Editor Feature";
        FeatureIds: List of [Text];
    begin
        // [Scenario] A single-company tenant, or a tenant where every company deliberately has the feature off,
        //            must not get the feature switched on behind the admin's back.
        SetEnabled(NewPOSEditorFeature.GetFeatureId(), false);

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        _Assert.IsFalse(IsEnabled(NewPOSEditorFeature.GetFeatureId()),
            'With no other company having the feature on, the new company must keep it off.');
    end;

    [Test]
    procedure Inherit_NeverDisablesFeatureEnabledLocally()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        NewPOSEditorFeature: Codeunit "NPR New POS Editor Feature";
        FeatureIds: List of [Text];
    begin
        // [Scenario] Inheritance is enable-only. A feature that AddFeature() brings up enabled, or that the
        //            admin turned on, must survive even when no other company has it on.
        SetEnabled(NewPOSEditorFeature.GetFeatureId(), true);

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        _Assert.IsTrue(IsEnabled(NewPOSEditorFeature.GetFeatureId()),
            'Inheritance must never switch a feature off.');
    end;

    [Test]
    procedure Inherit_RunsMigrationForPrintExperienceFeature()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        NewZReportExp: Codeunit "NPR New Z-Report Exp";
        FeatureIds: List of [Text];
    begin
        // [Scenario] The print-experience features carry a data migration with two halves: blank the template on the
        //            existing report selections and drop the rows that are then empty, then insert the static print
        //            codeunit. A template row is seeded so both halves are exercised - enabling the flag alone would
        //            leave the new company on template-based print setup.
        SetEnabled(NewZReportExp.GetFeatureId(), false);
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
        ReportSelectionRetail.DeleteAll();
        CreateTemplateReportSelection(ReportSelectionRetail."Report Type"::"Balancing (POS Entry)", 'TESTTMPL');
        FeatureIds.Add(NewZReportExp.GetFeatureId());

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        _Assert.IsTrue(IsEnabled(NewZReportExp.GetFeatureId()), 'The Z-report feature should be enabled.');
        ReportSelectionRetail.SetRange("Print Template", 'TESTTMPL');
        _Assert.IsTrue(ReportSelectionRetail.IsEmpty(),
            'The template-based print selection should have been cleaned up by the migration.');
        ReportSelectionRetail.SetRange("Print Template");
        ReportSelectionRetail.SetRange("Codeunit ID", Codeunit::"NPR Static Z Report");
        _Assert.IsFalse(ReportSelectionRetail.IsEmpty(),
            'The static Z-report print selection should have been inserted by the migration.');
    end;

    [Test]
    procedure Inherit_EnablesEmailFeaturesInDependencyOrder()
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        JQNotifNPEmailFeature: Codeunit "NPR JQNotifNPEmailFeature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        FeatureIds: List of [Text];
    begin
        // [Scenario] The two NP Email child features decide for themselves, exactly as they do on the install path:
        //            on when the parent is on and this company has no legacy setup to preserve. So the child is
        //            deliberately NOT in the inherited list here - a sibling that kept the legacy templates must not
        //            hold a clean new company back. It only works because the parent is handled first.
        JQNotifProfile.DeleteAll();
        SetEnabled(NewEmailExpFeature.GetFeatureId(), false);
        SetEnabled(JQNotifNPEmailFeature.GetFeatureId(), false);
        FeatureIds.Add(NewEmailExpFeature.GetFeatureId());

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        _Assert.IsTrue(IsEnabled(NewEmailExpFeature.GetFeatureId()), 'New Email Experience should be enabled.');
        _Assert.IsTrue(IsEnabled(JQNotifNPEmailFeature.GetFeatureId()),
            'JQ Notifications via NP Email should follow the parent even without a sibling having it on, because this company has no legacy setup.');
    end;

    [Test]
    procedure Inherit_SkipsGatedFeatureWithoutLocalRow()
    var
        Feature: Record "NPR Feature";
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        NewPOSEditorFeature: Codeunit "NPR New POS Editor Feature";
        FeatureIds: List of [Text];
        OriginalEnabled: Boolean;
        RowRecreated: Boolean;
    begin
        // [Scenario] A feature the sibling has on may have no row in this company at all - a row deleted by hand, or
        //            a feature from an extension that is no longer installed. For the sibling-gated features the
        //            inherit path must leave that alone rather than recreating the row or failing company creation.
        //            The two NP Email children are different on purpose: they go through SetFeatureEnabled, which
        //            recreates a missing row. The row is put back before the assert, because test isolation does not
        //            roll back between tests in one codeunit and a failure here would otherwise cascade into every
        //            test that reads this feature.
        OriginalEnabled := IsEnabled(NewPOSEditorFeature.GetFeatureId());
        if Feature.Get(NewPOSEditorFeature.GetFeatureId()) then
            Feature.Delete();
        FeatureIds.Add(NewPOSEditorFeature.GetFeatureId());

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        RowRecreated := Feature.Get(NewPOSEditorFeature.GetFeatureId());
        if not RowRecreated then begin
            NewPOSEditorFeature.AddFeature();
            SetEnabled(NewPOSEditorFeature.GetFeatureId(), OriginalEnabled);
        end;

        _Assert.IsFalse(RowRecreated,
            'A sibling-gated feature with no local row must be left alone rather than recreated by the inherit path.');
    end;

    [Test]
    procedure Inherit_EnablesModuleLicensing()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        ModuleLicensingFeat: Codeunit "NPR Module Licensing Feat.";
        FeatureIds: List of [Text];
    begin
        // [Scenario] Module Licensing is switched on by its own install codeunit on a greenfield install, and never
        //            by the shared feature-install path. A company created later has no install of its own, so
        //            inheriting from a sibling is the only way it can end up enforcing. The arrange forces the flag
        //            off on purpose: a freshly installed tenant already has it on.
        SetEnabled(ModuleLicensingFeat.GetFeatureId(), false);
        FeatureIds.Add(ModuleLicensingFeat.GetFeatureId());

        NewFeatureHandler.EnableForNewCompany(FeatureIds);

        _Assert.IsTrue(IsEnabled(ModuleLicensingFeat.GetFeatureId()),
            'Module Licensing should be inherited by a new company when a sibling company has it on.');
    end;

    local procedure SetEnabled(FeatureId: Text[50]; NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Get(FeatureId);
        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    local procedure CreateTemplateReportSelection(ReportType: Enum "NPR Report Selection Type"; PrintTemplate: Code[20])
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        ReportSelectionRetail.Init();
        ReportSelectionRetail."Report Type" := ReportType;
        ReportSelectionRetail.Sequence := ReportSelectionRetail.GetNextSequence(ReportType);
        ReportSelectionRetail."Print Template" := PrintTemplate;
        ReportSelectionRetail.Insert();
    end;

    local procedure IsEnabled(FeatureId: Text[50]): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(FeatureId) then
            exit(false);
        exit(Feature.Enabled);
    end;
}
