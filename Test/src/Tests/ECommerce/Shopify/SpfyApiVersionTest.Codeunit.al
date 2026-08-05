#if not BC17
codeunit 85346 "NPR Spfy Api Version Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";

    [Test]
    procedure Upgrade_ActiveOverride_IsHonoured()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] A baseline that still matches the recommended version means the admin confirmed this override against
        //            the version we currently ship, so the upgrade must leave both fields alone. This is the whole point of
        //            field 31 - before it existed, every deployment silently reverted such an override.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(BelowAnyVersionTok(), RecommendedApiVersion());

        SpfyAppUpgrade.UpdateShopifySetup();

        ShopifySetup.Get();
        _Assert.AreEqual(BelowAnyVersionTok(), ShopifySetup."Shopify Api Version",
            'An override confirmed against the current recommended version must survive the upgrade.');
        _Assert.AreEqual(RecommendedApiVersion(), ShopifySetup."Api Version Override Baseline",
            'The baseline must be retained while it still matches the recommended version.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [Test]
    procedure Upgrade_StaleBaselineBelowRecommended_BumpsAndClears()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] A new recommended version has shipped since the override was confirmed (baseline no longer matches),
        //            and the pinned version is below it, so the override is dropped and the tenant moves forward. This is
        //            the CORE-434 requirement: an override lasts until the recommended version changes, not forever.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(WellBelowAnyVersionTok(), BelowAnyVersionTok());

        SpfyAppUpgrade.UpdateShopifySetup();

        ShopifySetup.Get();
        _Assert.AreEqual(RecommendedApiVersion(), ShopifySetup."Shopify Api Version",
            'A stale override below the recommended version must be replaced by the recommended version.');
        _Assert.AreEqual('', ShopifySetup."Api Version Override Baseline",
            'The baseline must be cleared once it no longer matches the recommended version.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [Test]
    procedure Upgrade_StaleBaselineAboveRecommended_KeepsVersion()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] The never-downgrade invariant. A stale baseline whose pinned version is ABOVE the new recommended one
        //            must not be pulled backwards - only the baseline is dropped. Without this the admin who used the
        //            Confirm dialog would be treated worse than one whose pin predates field 31 (see the blank-baseline
        //            test below), and an app rollback to a build with a lower recommended version would downgrade tenants.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(AboveAnyVersionTok(), BelowAnyVersionTok());

        SpfyAppUpgrade.UpdateShopifySetup();

        ShopifySetup.Get();
        _Assert.AreEqual(AboveAnyVersionTok(), ShopifySetup."Shopify Api Version",
            'The upgrade must never move a tenant to a lower api version than the one it already runs.');
        _Assert.AreEqual('', ShopifySetup."Api Version Override Baseline",
            'A baseline that no longer matches the recommended version is stale and must be cleared.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [Test]
    procedure Upgrade_BlankBaselineBelowRecommended_Bumps()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] Legacy behaviour pin: with no override recorded, a version below the recommended one is moved up. This
        //            is how the fleet-wide rollout works, and it must keep working for tenants that predate field 31.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(BelowAnyVersionTok(), '');

        SpfyAppUpgrade.UpdateShopifySetup();

        ShopifySetup.Get();
        _Assert.AreEqual(RecommendedApiVersion(), ShopifySetup."Shopify Api Version",
            'With no override recorded, a version below the recommended one must be bumped to it.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [Test]
    procedure Upgrade_BlankBaselineAboveRecommended_IsUntouched()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] Legacy behaviour pin: with no override recorded and a version above the recommended one, nothing is
        //            written at all. Pinned with the matching-baseline case above, this is what keeps the two paths
        //            symmetric - a forward pin survives whether or not it went through the Confirm dialog.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(AboveAnyVersionTok(), '');

        SpfyAppUpgrade.UpdateShopifySetup();

        ShopifySetup.Get();
        _Assert.AreEqual(AboveAnyVersionTok(), ShopifySetup."Shopify Api Version",
            'A version above the recommended one with no baseline must be left untouched.');
        _Assert.AreEqual('', ShopifySetup."Api Version Override Baseline",
            'No baseline must be invented for a tenant that has none.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure Validate_AcceptConfirm_RecordsBaseline()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] Confirming a non-recommended version records the recommended version in effect at that moment. This
        //            write is the contract UpdateShopifySetup consumes - if it is ever dropped, overrides get clobbered
        //            again on the next deployment with no error anywhere.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(RecommendedApiVersion(), '');

        ShopifySetup.Get();
        ShopifySetup.Validate("Shopify Api Version", BelowAnyVersionTok());
        ShopifySetup.Modify();

        ShopifySetup.Get();
        _Assert.AreEqual(BelowAnyVersionTok(), ShopifySetup."Shopify Api Version",
            'Confirming the change must keep the entered api version.');
        _Assert.AreEqual(RecommendedApiVersion(), ShopifySetup."Api Version Override Baseline",
            'Confirming a non-recommended version must record the recommended version as the override baseline.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    procedure Validate_DeclineConfirm_RestoresPreviousOverride()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] Declining the change must restore the previous value, not force the recommended version. An admin who
        //            answers No while an override is already in effect expects nothing to change; reverting to the
        //            recommended version would silently destroy the override and its baseline instead.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(AboveAnyVersionTok(), RecommendedApiVersion());

        ShopifySetup.Get();
        ShopifySetup.Validate("Shopify Api Version", BelowAnyVersionTok());
        ShopifySetup.Modify();

        ShopifySetup.Get();
        _Assert.AreEqual(AboveAnyVersionTok(), ShopifySetup."Shopify Api Version",
            'Declining the change must restore the api version that was in effect, not the recommended one.');
        _Assert.AreEqual(RecommendedApiVersion(), ShopifySetup."Api Version Override Baseline",
            'Declining the change must leave the existing override baseline intact.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [Test]
    procedure Validate_BackToRecommended_ClearsBaseline()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        OriginalApiVersion: Text[10];
        OriginalBaseline: Text[10];
    begin
        // [Scenario] Returning to the recommended version withdraws the override, so the baseline must be cleared - the
        //            tenant follows the recommended version again from then on. No Confirm is raised on this path, which is
        //            why this test declares no handler.
        SaveSetup(OriginalApiVersion, OriginalBaseline);
        SetSetup(BelowAnyVersionTok(), RecommendedApiVersion());

        ShopifySetup.Get();
        ShopifySetup.Validate("Shopify Api Version", RecommendedApiVersion());
        ShopifySetup.Modify();

        ShopifySetup.Get();
        _Assert.AreEqual('', ShopifySetup."Api Version Override Baseline",
            'Setting the api version back to the recommended one must clear the override baseline.');

        RestoreSetup(OriginalApiVersion, OriginalBaseline);
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerNo(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    local procedure RecommendedApiVersion(): Text[10]
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        //Read from the field's InitValue rather than hardcoded, so these tests survive the next recommended version bump.
        ShopifySetup.Init();
        exit(ShopifySetup."Shopify Api Version");
    end;

    local procedure BelowAnyVersionTok(): Text[10]
    begin
        //Shopify api versions are YYYY-MM and compare as text, so these sort below and above any version we would ship.
        exit('2020-01');
    end;

    local procedure WellBelowAnyVersionTok(): Text[10]
    begin
        exit('2019-01');
    end;

    local procedure AboveAnyVersionTok(): Text[10]
    begin
        exit('2999-01');
    end;

    local procedure SetSetup(ApiVersion: Text[10]; Baseline: Text[10])
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        if not ShopifySetup.Get() then begin
            ShopifySetup.Init();
            ShopifySetup.Insert();
        end;
        //Direct assignment rather than Validate: the api version OnValidate raises the Confirm dialog, which the
        //Validate_* tests exercise deliberately. Here we only need a starting state.
        ShopifySetup."Shopify Api Version" := ApiVersion;
        ShopifySetup."Api Version Override Baseline" := Baseline;
        ShopifySetup.Modify();
    end;

    local procedure SaveSetup(var ApiVersion: Text[10]; var Baseline: Text[10])
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        if not ShopifySetup.Get() then
            exit;
        ApiVersion := ShopifySetup."Shopify Api Version";
        Baseline := ShopifySetup."Api Version Override Baseline";
    end;

    local procedure RestoreSetup(ApiVersion: Text[10]; Baseline: Text[10])
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        if not ShopifySetup.Get() then
            exit;
        if ApiVersion = '' then begin
            //There was no setup record before the test created one.
            ShopifySetup.Delete();
            exit;
        end;
        ShopifySetup."Shopify Api Version" := ApiVersion;
        ShopifySetup."Api Version Override Baseline" := Baseline;
        ShopifySetup.Modify();
    end;
}
#endif
