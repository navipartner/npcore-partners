codeunit 85302 "NPR Spfy No Store Prefix Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";

    [Test]
    procedure Feature_RegisteredAtInstall()
    var
        Feature: Record "NPR Feature";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
    begin
        // [Scenario] The feature must be registered by FeatureManagementInstall.InitFeatures. This pins that
        //            registration: if the AddFeature(...) line is ever dropped in a merge, the fresh-install
        //            auto-enable silently no-ops (SetFeatureEnabled exits when Get fails), defeating the feature with
        //            no error. Declared first and deliberately does NOT call EnsureFeaturePresent, so it sees only
        //            install state.
        _Assert.IsTrue(Feature.Get(NoStorePrefixFeature.GetFeatureId()),
            'The Shopify store-code-prefix feature should be registered at install by FeatureManagementInstall.');
    end;

    [Test]
    procedure Feature_Toggle_RoundTrips()
    var
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] The flag round-trips through the standard NPR Feature framework via SetFeatureEnabled (direct
        //            Modify - which does not raise the irreversibility guard; that only fires on Validate).
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();

        NoStorePrefixFeature.SetFeatureEnabled(true);
        _Assert.IsTrue(NoStorePrefixFeature.IsFeatureEnabled(), 'Feature should read back as enabled after SetFeatureEnabled(true).');

        NoStorePrefixFeature.SetFeatureEnabled(false);
        _Assert.IsFalse(NoStorePrefixFeature.IsFeatureEnabled(), 'Feature should read back as disabled after SetFeatureEnabled(false).');

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    procedure ManualEnable_DeclineReverts()
    var
        Feature: Record "NPR Feature";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] Manual enable via the Feature Management page raises the guard's confirm; declining it must
        //            leave the feature disabled. Exercises the OnBeforeValidateEvent subscriber and its Rec.Id filter.
        //            Asserted via state, not translatable error text.
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();
        NoStorePrefixFeature.SetFeatureEnabled(false);

        Feature.Get(NoStorePrefixFeature.GetFeatureId());
        Feature.Validate(Enabled, true); // ConfirmHandlerNo declines the guard's confirmation -> guard reverts

        _Assert.IsFalse(NoStorePrefixFeature.IsFeatureEnabled(),
            'Declining the confirmation on manual enable must leave the feature disabled.');

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure CannotDisable_OnceEnabled()
    var
        Feature: Record "NPR Feature";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] The feature's novel safety property: once enabled it cannot be turned back off through the UI
        //            (Validate(Enabled, false) is blocked by the guard). This is the phase-out guarantee.
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();
        NoStorePrefixFeature.SetFeatureEnabled(true);

        Feature.Get(NoStorePrefixFeature.GetFeatureId());
        asserterror Feature.Validate(Enabled, false);

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure ExternalDocumentNo_PrefixedWhenDisabled()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] Disabled = legacy behavior: the store code is prepended to the order number and the Shopify
        //            order name is ignored. Pins backward compatibility for every existing Shopify tenant - a
        //            regression in this branch silently changes document referencing.
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();
        NoStorePrefixFeature.SetFeatureEnabled(false);

        _Assert.AreEqual('MYSTORE-1001', SpfyIntegrationMgt.BuildExternalDocumentNo('MYSTORE', '1001', '#1001', 35),
            'With the feature disabled the store code must be prepended.');

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure ExternalDocumentNo_OrderNameWhenEnabled()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] Enabled: the Shopify order name (which carries the prefix/suffix configured in Shopify and is
        //            therefore unique across stores) is used as-is, with no BC-added prefix. The callers read the name
        //            as a required value, so there is no blank-name case to fall back from.
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();
        NoStorePrefixFeature.SetFeatureEnabled(true);

        _Assert.AreEqual('#1001', SpfyIntegrationMgt.BuildExternalDocumentNo('MYSTORE', '1001', '#1001', 35),
            'With the feature enabled the Shopify order name must be used without the store-code prefix.');

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure ExternalDocumentNo_RespectsMaxLen()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] The built value is truncated to the target field length in both feature states:
        //            disabled 'MYSTORE-1001' (12) at MaxLen 10 -> 'MYSTORE-10'; enabled '#1001' at MaxLen 3 -> '#10'.
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();

        NoStorePrefixFeature.SetFeatureEnabled(false);
        _Assert.AreEqual('MYSTORE-10', SpfyIntegrationMgt.BuildExternalDocumentNo('MYSTORE', '1001', '#1001', 10),
            'The built External Document No. must be truncated to MaxLen.');

        NoStorePrefixFeature.SetFeatureEnabled(true);
        _Assert.AreEqual('#10', SpfyIntegrationMgt.BuildExternalDocumentNo('MYSTORE', '1001', '#1001', 3),
            'The Shopify order name must be truncated to MaxLen.');

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure EcomImport_ExtDocNo_PrefixedWhenDisabled()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] The ecom order import builds the incoming document header through the flag. Disabled = legacy
        //            behavior: the store code is prepended to the Shopify order number. Exercises the real
        //            InitEcommerceHeader production procedure with fabricated data.
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();
        NoStorePrefixFeature.SetFeatureEnabled(false);

        SpfyEcomSalesDocImport.InitEcommerceHeader(EcomImportLogEntry(), EcomSalesHeader, EcomOrderResponse('1001'));

        _Assert.AreEqual(StrSubstNo('%1-1001', StoreCode()), EcomSalesHeader."External Document No.",
            'With the feature disabled the ecom import must prepend the store code to External Document No.');

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [Test]
    procedure EcomImport_ExtDocNo_OrderNameWhenEnabled()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        OriginalEnabled: Boolean;
    begin
        // [Scenario] With the feature enabled the ecom import uses the Shopify order name (Shopify's own
        //            prefix/suffix identifier) instead of the order number.
        EnsureFeaturePresent();
        OriginalEnabled := NoStorePrefixFeature.IsFeatureEnabled();
        NoStorePrefixFeature.SetFeatureEnabled(true);

        SpfyEcomSalesDocImport.InitEcommerceHeader(EcomImportLogEntry(), EcomSalesHeader, EcomOrderResponse('1001'));

        _Assert.AreEqual('#1001', EcomSalesHeader."External Document No.",
            'With the feature enabled the ecom import must use the Shopify order name without the store-code prefix.');

        NoStorePrefixFeature.SetFeatureEnabled(OriginalEnabled);
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerNo(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    local procedure EcomImportLogEntry() LogEntry: Record "NPR Spfy Event Log Entry"
    var
        NpEcStore: Record "NPR NpEc Store";
        ShopifyStore: Record "NPR Spfy Store";
    begin
        // Minimal master data for InitEcommerceHeader: the Shopify store (read by CurrencyBlankForLCY) and an
        // ecommerce store mapped to it (resolved by FindNpEcStore via the JSON sourceName). Idempotent inserts,
        // triggers skipped - only direct field values are needed.
        if not ShopifyStore.Get(StoreCode()) then begin
            ShopifyStore.Init();
            ShopifyStore.Code := StoreCode();
            ShopifyStore.Insert();
        end;
        if not NpEcStore.Get(StoreCode()) then begin
            NpEcStore.Init();
            NpEcStore.Code := StoreCode();
            NpEcStore."Shopify Store Code" := StoreCode();
            NpEcStore."Shopify Source Name" := 'web';
            NpEcStore.Insert();
        end;

        LogEntry.Init();
        LogEntry."Store Code" := StoreCode();
        LogEntry."Shopify ID" := 'TESTGID9999';
        LogEntry."Document Type" := LogEntry."Document Type"::Order;
        LogEntry."Event Date-Time" := CurrentDateTime();
        LogEntry."Closed Date-Time" := LogEntry."Event Date-Time";
    end;

    local procedure EcomOrderResponse(OrderNo: Text) Response: JsonToken
    begin
        // "name" mirrors Shopify's default order naming: '#' + order number.
        Response.ReadFrom(StrSubstNo('{"data":{"order":{"sourceName":"web","number":"%1","name":"#%1"}}}', OrderNo));
    end;

    local procedure StoreCode(): Code[20]
    var
        StoreCodeTok: Label 'SPFYPRFX', Locked = true, MaxLength = 20;
    begin
        exit(StoreCodeTok);
    end;

    local procedure EnsureFeaturePresent()
    var
        Feature: Record "NPR Feature";
        NoStorePrefixFeature: Codeunit "NPR Spfy No Store Code Prefix";
    begin
        // The feature row is normally inserted at install (FeatureManagementInstall). Insert it here if a
        // bare test tenant is missing it, so the toggle helpers are not silent no-ops.
        if not Feature.Get(NoStorePrefixFeature.GetFeatureId()) then
            NoStorePrefixFeature.AddFeature();
    end;
}
