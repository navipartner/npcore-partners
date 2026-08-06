codeunit 85358 "NPR PayByLinkNPEmailTests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FeatureFlagGating()
    var
        Feature: Record "NPR Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
    begin
        // [Given] no feature record
        if Feature.Get(PayByLinkNPEmailFeature.GetFeatureId()) then
            Feature.Delete();
        Assert.IsFalse(PayByLinkNPEmailFeature.IsFeatureEnabled(), 'A missing feature record should report disabled.');

        // [Then] the flag alone is not enough: New Email Experience gates it
        NewEmailExpFeature.SetFeatureEnabled(false);
        PayByLinkNPEmailFeature.SetFeatureEnabled(true);
        Assert.IsFalse(PayByLinkNPEmailFeature.IsFeatureEnabled(), 'The feature must report disabled while New Email Experience is off.');

        NewEmailExpFeature.SetFeatureEnabled(true);
        Assert.IsTrue(PayByLinkNPEmailFeature.IsFeatureEnabled(), 'The feature must report enabled when both flags are on.');

        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        Assert.IsFalse(PayByLinkNPEmailFeature.IsFeatureEnabled(), 'The feature must report disabled after SetFeatureEnabled(false).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutoEnableRespectsLegacySetup()
    var
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
    begin
        // [Then] no auto-enable while New Email Experience is off
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        RemoveAdyenSetup();
        PayByLinkNPEmailFeature.EnableIfNoLegacySetupInUse(false);
        Assert.IsFalse(FeatureFlagEnabled(), 'Auto-enable must not run while New Email Experience is off.');

        // [Then] no Adyen setup at all -> enable
        PayByLinkNPEmailFeature.EnableIfNoLegacySetupInUse(true);
        Assert.IsTrue(FeatureFlagEnabled(), 'Auto-enable should turn the flag on when no Adyen setup exists.');

        // [Then] Pay by Link disabled in setup -> enable (legacy template not in use)
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        EnsureAdyenSetup(false, 'LEGACY', '');
        PayByLinkNPEmailFeature.EnableIfNoLegacySetupInUse(true);
        Assert.IsTrue(FeatureFlagEnabled(), 'Auto-enable should turn the flag on when Pay by Link is disabled in setup.');

        // [Then] live legacy-only setup -> stay off, the customer keeps their old e-mail flow
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        EnsureAdyenSetup(true, 'LEGACY', '');
        PayByLinkNPEmailFeature.EnableIfNoLegacySetupInUse(true);
        Assert.IsFalse(FeatureFlagEnabled(), 'Auto-enable must not switch over a tenant with a legacy-only Pay by Link e-mail setup.');

        // [Then] no template configured at all -> enable
        EnsureAdyenSetup(true, '', '');
        PayByLinkNPEmailFeature.EnableIfNoLegacySetupInUse(true);
        Assert.IsTrue(FeatureFlagEnabled(), 'Auto-enable should turn the flag on when no e-mail template is configured.');

        // [Then] NP template already selected -> enable
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        EnsureAdyenSetup(true, 'LEGACY', 'NPTEMPL');
        PayByLinkNPEmailFeature.EnableIfNoLegacySetupInUse(true);
        Assert.IsTrue(FeatureFlagEnabled(), 'Auto-enable should turn the flag on when an NP Email template is already selected.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpgradeHandlerDoesNotReEnable()
    var
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        // [Given] a tenant where the upgrade step has already run once
        NewEmailExpFeature.SetFeatureEnabled(true);
        RemoveAdyenSetup();
        if not UpgradeTag.HasUpgradeTag('NPR-PayByLinkNPEmailHandle-20260805') then
            NewFeatureHandler.HandlePayByLinkNPEmail();
        Assert.IsTrue(UpgradeTag.HasUpgradeTag('NPR-PayByLinkNPEmailHandle-20260805'), 'The upgrade tag should be set after the handler has run.');

        // [Given] the customer has since disabled the feature by hand
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);

        // [When] the handler runs again (e.g. next upgrade)
        NewFeatureHandler.HandlePayByLinkNPEmail();

        // [Then] the customer's choice is kept
        Assert.IsFalse(FeatureFlagEnabled(), 'A re-run of the upgrade handler must not re-enable a feature the customer disabled.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EnableRequiresNewEmailExperience()
    var
        Feature: Record "NPR Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
    begin
        // [Given] New Email Experience is off and the feature record exists, disabled
        NewEmailExpFeature.SetFeatureEnabled(false);
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        Feature.Get(PayByLinkNPEmailFeature.GetFeatureId());

        // [When] the user ticks Enabled on the Feature Management page
        asserterror Feature.Validate(Enabled, true);

        // [Then] the guard blocks it
        Assert.IsTrue(StrPos(GetLastErrorText(), 'New Email Experience') > 0, 'Enabling must be blocked with the New Email Experience prerequisite error.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EnableWithBlankTemplateConfirmNo()
    var
        Feature: Record "NPR Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
    begin
        // [Given] Pay by Link enabled in setup but no NP template selected yet
        NewEmailExpFeature.SetFeatureEnabled(true);
        EnsureAdyenSetup(true, 'LEGACY', '');
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        Feature.Get(PayByLinkNPEmailFeature.GetFeatureId());

        // [When] the user ticks Enabled and answers No to the missing-template warning
        Feature.Validate(Enabled, true);

        // [Then] the feature stays disabled, in memory and in the database
        Assert.IsFalse(Feature.Enabled, 'Answering No to the warning must leave the record disabled in memory.');
        Assert.IsFalse(FeatureFlagEnabled(), 'Answering No to the warning must leave the feature disabled in the database.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EnableWithBlankTemplateConfirmYes()
    var
        Feature: Record "NPR Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
    begin
        // [Given] the same unconfigured setup
        NewEmailExpFeature.SetFeatureEnabled(true);
        EnsureAdyenSetup(true, 'LEGACY', '');
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        Feature.Get(PayByLinkNPEmailFeature.GetFeatureId());

        // [When] the user ticks Enabled and confirms the warning
        Feature.Validate(Enabled, true);
        Feature.Modify();

        // [Then] the feature is enabled
        Assert.IsTrue(PayByLinkNPEmailFeature.IsFeatureEnabled(), 'Answering Yes to the warning must enable the feature.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NewEmailExperienceToggleSyncs()
    var
        Feature: Record "NPR Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
    begin
        // [Given] both features off and a live legacy-only setup
        NewEmailExpFeature.SetFeatureEnabled(false);
        PayByLinkNPEmailFeature.SetFeatureEnabled(false);
        EnsureAdyenSetup(true, 'LEGACY', '');
        Feature.Get(NewEmailExpFeature.GetFeatureId());

        // [When] New Email Experience is enabled from the Feature Management page
        Feature.Validate(Enabled, true);

        // [Then] the legacy-only tenant is not switched over
        Assert.IsFalse(FeatureFlagEnabled(), 'Enabling New Email Experience must not switch over a tenant with a legacy-only setup.');

        // [When] toggled off and on again with no legacy setup in use
        RemoveAdyenSetup();
        Feature.Validate(Enabled, false);
        Feature.Validate(Enabled, true);

        // [Then] the Pay by Link NP Email flag follows
        Assert.IsTrue(FeatureFlagEnabled(), 'Enabling New Email Experience should auto-enable Pay by Link NP Email when no legacy setup is in use.');

        // [When] New Email Experience is disabled again
        Feature.Validate(Enabled, false);

        // [Then] the Pay by Link NP Email flag is switched off with it
        Assert.IsFalse(FeatureFlagEnabled(), 'Disabling New Email Experience must also disable Pay by Link NP Email.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetContentSalesOrderAndExampleParity()
    var
        Customer: Record Customer;
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        NPEmailPayByLinkDataProv: Codeunit "NPR NPEmailPayByLinkDataProv";
        LibrarySales: Codeunit "Library - Sales";
        ContentObject: JsonObject;
        ExampleObject: JsonObject;
        JsonKey: Text;
    begin
        // [Given] a sales order with currency, language and a bill-to customer e-mail
        LibrarySales.CreateSalesOrder(SalesHeader);
        EnsureLanguage('DAN', 1030);
        SalesHeader."Currency Code" := 'TSTCUR';
        SalesHeader."Language Code" := 'DAN';
        SalesHeader.Modify();
        Customer.Get(SalesHeader."Bill-to Customer No.");
        Customer."E-Mail" := 'order-customer@example.com';
        Customer.Modify();
        InitPaymentLine(MagentoPaymentLine, Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.");

        // [When] the data provider builds the template content
        ContentObject := GetContent(MagentoPaymentLine);

        // [Then] document, customer and payment line fields are filled from the order
        AssertDocumentFields(ContentObject, SalesHeader."Bill-to Name", 'order-customer@example.com');
        AssertPaymentLineFields(ContentObject, MagentoPaymentLine);

        // [Then] the designer example exposes exactly the keys the real content has
        ExampleObject := NPEmailPayByLinkDataProv.GenerateContentExample();
        foreach JsonKey in ContentObject.Keys() do
            Assert.IsTrue(ExampleObject.Contains(JsonKey), StrSubstNo('The content key %1 is missing from GenerateContentExample.', JsonKey));
        foreach JsonKey in ExampleObject.Keys() do
            Assert.IsTrue(ContentObject.Contains(JsonKey), StrSubstNo('The example key %1 is not produced by GetContent.', JsonKey));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetContentPostedDocuments()
    var
        Customer: Record Customer;
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [Given] a customer with an e-mail and language data
        LibrarySales.CreateCustomer(Customer);
        Customer."E-Mail" := 'posted-customer@example.com';
        Customer.Modify();
        EnsureLanguage('DAN', 1030);

        // [Given] a posted invoice
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := 'PBLTEST-INV';
        SalesInvoiceHeader."Bill-to Name" := 'Invoice Bill-to Name';
        SalesInvoiceHeader."Bill-to Customer No." := Customer."No.";
        SalesInvoiceHeader."Currency Code" := 'TSTCUR';
        SalesInvoiceHeader."Language Code" := 'DAN';
        SalesInvoiceHeader.Insert();

        // [Then] invoice content carries the bill-to values
        InitPaymentLine(MagentoPaymentLine, Database::"Sales Invoice Header", "Sales Document Type"::Invoice, SalesInvoiceHeader."No.");
        AssertDocumentFields(GetContent(MagentoPaymentLine), 'Invoice Bill-to Name', 'posted-customer@example.com');

        // [Given] a posted credit memo
        SalesCrMemoHeader.Init();
        SalesCrMemoHeader."No." := 'PBLTEST-CRM';
        SalesCrMemoHeader."Bill-to Name" := 'CrMemo Bill-to Name';
        SalesCrMemoHeader."Bill-to Customer No." := Customer."No.";
        SalesCrMemoHeader."Currency Code" := 'TSTCUR';
        SalesCrMemoHeader."Language Code" := 'DAN';
        SalesCrMemoHeader.Insert();

        // [Then] credit memo content carries the bill-to values
        InitPaymentLine(MagentoPaymentLine, Database::"Sales Cr.Memo Header", "Sales Document Type"::"Credit Memo", SalesCrMemoHeader."No.");
        AssertDocumentFields(GetContent(MagentoPaymentLine), 'CrMemo Bill-to Name', 'posted-customer@example.com');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetContentEcomSale()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        // [Given] an incoming ecommerce sales document
        EnsureLanguage('DAN', 1030);
        EcomSalesHeader.Init();
        EcomSalesHeader."Sell-to Name" := 'Ecom Sell-to Name';
        EcomSalesHeader."Sell-to Email" := 'ecom-customer@example.com';
        EcomSalesHeader."Currency Code" := 'TSTCUR';
        EcomSalesHeader."Language Code" := 'DAN';
        EcomSalesHeader.Insert();

        // [Given] a payment line pointing at the ecom document via its system id
        InitPaymentLine(MagentoPaymentLine, Database::"NPR Ecom Sales Header", "Sales Document Type"::Order, 'PBLTEST-ECOM');
        MagentoPaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;

        // [Then] the content carries the ecom sell-to values
        AssertDocumentFields(GetContent(MagentoPaymentLine), 'Ecom Sell-to Name', 'ecom-customer@example.com');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetContentFallbacksAndGuards()
    var
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NPEmailPayByLinkDataProv: Codeunit "NPR NPEmailPayByLinkDataProv";
        JObject: JsonObject;
        RecRef: RecordRef;
    begin
        // [Given] a posted invoice in local currency (blank currency code)
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := 'PBLTEST-LCY';
        SalesInvoiceHeader.Insert();
        InitPaymentLine(MagentoPaymentLine, Database::"Sales Invoice Header", "Sales Document Type"::Invoice, SalesInvoiceHeader."No.");

        // [Then] the currency code falls back to the LCY code
        GeneralLedgerSetup.Get();
        Assert.AreEqual(GeneralLedgerSetup."LCY Code", JText(GetContent(MagentoPaymentLine), 'currency_code'), 'A blank document currency should fall back to the LCY code.');

        // [Then] a payment line whose document no longer exists does not error; customer fields stay blank
        InitPaymentLine(MagentoPaymentLine, Database::"Sales Header", "Sales Document Type"::Order, 'PBLTEST-GONE');
        JObject := GetContent(MagentoPaymentLine);
        Assert.AreEqual('', JText(JObject, 'customer_name'), 'customer_name should be blank when the document is gone.');
        Assert.AreEqual('', JText(JObject, 'customer_email'), 'customer_email should be blank when the document is gone.');
        AssertPaymentLineFields(JObject, MagentoPaymentLine);

        // [Then] a record that is not a Magento Payment Line hits the programming-bug guard
        RecRef.GetTable(Customer);
        asserterror NPEmailPayByLinkDataProv.GetContent(RecRef);
        Assert.IsTrue(StrPos(GetLastErrorText(), 'programming bug') > 0, 'A wrong record type must hit the programming-bug guard.');
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure FeatureFlagEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
        PayByLinkNPEmailFeature: Codeunit "NPR PayByLinkNPEmailFeature";
    begin
        if not Feature.Get(PayByLinkNPEmailFeature.GetFeatureId()) then
            exit(false);
        exit(Feature.Enabled);
    end;

    local procedure EnsureAdyenSetup(EnablePayByLink: Boolean; LegacyTemplate: Code[20]; NPTemplate: Code[20])
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if not AdyenSetup.Get() then begin
            AdyenSetup.Init();
            AdyenSetup.Insert();
        end;
        AdyenSetup."Enable Pay by Link" := EnablePayByLink;
        AdyenSetup."Pay By Link E-Mail Template" := LegacyTemplate;
        AdyenSetup."Pay By Link NP Email Template" := NPTemplate;
        AdyenSetup.Modify();
    end;

    local procedure RemoveAdyenSetup()
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        AdyenSetup.DeleteAll();
    end;

    local procedure InitPaymentLine(var MagentoPaymentLine: Record "NPR Magento Payment Line"; DocumentTableNo: Integer; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20])
    begin
        MagentoPaymentLine.Init();
        MagentoPaymentLine."Document Table No." := DocumentTableNo;
        MagentoPaymentLine."Document Type" := DocumentType;
        MagentoPaymentLine."Document No." := DocumentNo;
        MagentoPaymentLine."Line No." := 10000;
        MagentoPaymentLine."Pay by Link URL" := 'https://pay.example.com/link/TEST123';
        MagentoPaymentLine."Requested Amount" := 123.45;
        MagentoPaymentLine.Description := 'Pay by Link test payment';
        MagentoPaymentLine."Transaction ID" := 'PBLTEST-TRANS-001';
        MagentoPaymentLine."Expires At" := CreateDateTime(20260101D, 120000T);
        MagentoPaymentLine."External Reference No." := 'PBLTEST-EXT-001';
    end;

    local procedure GetContent(var MagentoPaymentLine: Record "NPR Magento Payment Line"): JsonObject
    var
        NPEmailPayByLinkDataProv: Codeunit "NPR NPEmailPayByLinkDataProv";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(MagentoPaymentLine);
        exit(NPEmailPayByLinkDataProv.GetContent(RecRef));
    end;

    local procedure AssertDocumentFields(JObject: JsonObject; ExpectedName: Text; ExpectedEmail: Text)
    begin
        Assert.AreEqual(ExpectedName, JText(JObject, 'customer_name'), 'customer_name should come from the document.');
        Assert.AreEqual(ExpectedEmail, JText(JObject, 'customer_email'), 'customer_email should come from the document/customer.');
        Assert.AreEqual('TSTCUR', JText(JObject, 'currency_code'), 'currency_code should come from the document.');
        Assert.AreEqual('DAN', JText(JObject, 'language_code'), 'language_code should come from the document.');
    end;

    local procedure AssertPaymentLineFields(JObject: JsonObject; MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        JToken: JsonToken;
    begin
        Assert.AreEqual(MagentoPaymentLine."Pay by Link URL", JText(JObject, 'pay_by_link_url'), 'pay_by_link_url should come from the payment line.');
        Assert.AreEqual(Format(MagentoPaymentLine."Document No."), JText(JObject, 'document_no'), 'document_no should come from the payment line.');
        Assert.IsTrue(JObject.Get('requested_amount', JToken), 'The content is missing the requested_amount key.');
        Assert.AreEqual(MagentoPaymentLine."Requested Amount", JToken.AsValue().AsDecimal(), 'requested_amount should come from the payment line.');
        Assert.AreNotEqual('', JText(JObject, 'requested_amount_formatted'), 'requested_amount_formatted should not be blank.');
        Assert.AreEqual(MagentoPaymentLine.Description, JText(JObject, 'description'), 'description should come from the payment line.');
        Assert.AreEqual(MagentoPaymentLine."Transaction ID", JText(JObject, 'transaction_id'), 'transaction_id should come from the payment line.');
        Assert.AreNotEqual('', JText(JObject, 'expires_at_formatted'), 'expires_at_formatted should not be blank.');
        Assert.AreEqual(Format(MagentoPaymentLine."External Reference No."), JText(JObject, 'external_reference_no'), 'external_reference_no should come from the payment line.');
    end;

    local procedure JText(JObject: JsonObject; KeyName: Text): Text
    var
        JToken: JsonToken;
    begin
        Assert.IsTrue(JObject.Get(KeyName, JToken), StrSubstNo('The content is missing the %1 key.', KeyName));
        exit(JToken.AsValue().AsText());
    end;

    local procedure EnsureLanguage(LanguageCode: Code[10]; WindowsLanguageId: Integer)
    var
        Language: Record Language;
    begin
        if Language.Get(LanguageCode) then
            exit;
        Language.Init();
        Language.Code := LanguageCode;
        Language."Windows Language ID" := WindowsLanguageId;
        Language.Insert();
    end;
}
