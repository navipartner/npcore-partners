codeunit 85495 "NPR Ecom Cust Template Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibraryUtility: Codeunit "Library - Utility";
        _LibrarySales: Codeunit "Library - Sales";
        _LibraryDimension: Codeunit "Library - Dimension";

    [Test]
    procedure GivenTemplateWithNoSeries_WhenNewCustomerIsCreated_ThenNumberComesFromTemplateSeries()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        StartNo: Code[20];
    begin
        // [GIVEN] a customer template with its own number series
        Initialize();
        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."No. Series" := CreateTemplateNoSeries(true, false, StartNo);
        CustomerTempl.Modify();

        // [WHEN] an order for an unknown e-mail names the template and is converted
        SubmitV2Document(CustomerTempl.Code, '', NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the new customer is numbered from the template series
        _Assert.AreEqual(StartNo, Customer."No.", 'The new customer must take the first number of the template series.');
        _Assert.AreEqual(CustomerTempl."No. Series", Customer."No. Series", 'The new customer must carry the template series.');
    end;

    [Test]
    procedure GivenTemplateWithoutNoSeries_WhenNewCustomerIsCreated_ThenCustomerNosIsUsed()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // [GIVEN] a customer template without a number series
        Initialize();
        SalesSetup.Get();
        _Assert.AreNotEqual('', SalesSetup."Customer Nos.", 'Precondition: Sales & Receivables Setup must have Customer Nos.');
        CreateWorkingTemplate(CustomerTempl);
        _Assert.AreEqual('', CustomerTempl."No. Series", 'Precondition: the template must have no number series.');

        // [WHEN] an order for an unknown e-mail names the template and is converted
        SubmitV2Document(CustomerTempl.Code, '', NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the new customer is numbered from Customer Nos.
        _Assert.AreEqual(SalesSetup."Customer Nos.", Customer."No. Series", 'Without a template series the new customer must use Customer Nos.');
    end;

    [Test]
    procedure GivenTemplateWithDocSendingProfileAndLanguage_WhenNewCustomerIsCreated_ThenBothAreCopiedAndOrderCountryWins()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LanguageCode: Code[10];
        OtherCountryCode: Code[10];
    begin
        // [GIVEN] a customer template with a document sending profile, a language and a country other than the order's
        Initialize();
        LanguageCode := GetLanguageCode();
        OtherCountryCode := GetCountryCodeOtherThan('DK');
        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."Document Sending Profile" := CreateDocumentSendingProfile();
        CustomerTempl."Language Code" := LanguageCode;
        CustomerTempl."Country/Region Code" := OtherCountryCode;
        CustomerTempl.Modify();

        // [WHEN] an order from DK for an unknown e-mail names the template and is converted
        SubmitV2Document(CustomerTempl.Code, '', NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the profile and the language come from the template, and the country comes from the order
        _Assert.AreEqual(CustomerTempl."Document Sending Profile", Customer."Document Sending Profile", 'The document sending profile must be copied from the template.');
        _Assert.AreEqual(LanguageCode, Customer."Language Code", 'The language code must be copied from the template.');
        _Assert.AreEqual('DK', Customer."Country/Region Code", 'The order country must win over the template country.');
    end;

    [Test]
    procedure GivenTemplateDefaultDimension_WhenNewCustomerIsCreated_ThenCustomerGetsDefaultDimension()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [GIVEN] a customer template with a default dimension
        Initialize();
        CreateWorkingTemplate(CustomerTempl);
        CreateTemplateDefaultDimension(CustomerTempl, DimensionValue);

        // [WHEN] an order for an unknown e-mail names the template and is converted
        SubmitV2Document(CustomerTempl.Code, '', NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the new customer has the same default dimension
        _Assert.IsTrue(DefaultDimension.Get(Database::Customer, Customer."No.", DimensionValue."Dimension Code"), 'The new customer must get the template default dimension.');
        _Assert.AreEqual(DimensionValue.Code, DefaultDimension."Dimension Value Code", 'The default dimension value must match the template.');
    end;

    [Test]
    procedure GivenPersonTemplate_WhenNewCustomerIsCreated_ThenCustomerAndContactArePerson()
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [GIVEN] contact sync is on, and a customer template with Contact Type Person
        Initialize();
        EnsureMarketingSetup();
        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."Contact Type" := CustomerTempl."Contact Type"::Person;
        CustomerTempl.Modify();

        // [WHEN] an order for an unknown e-mail names the template and is converted
        SubmitV2Document(CustomerTempl.Code, '', NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the customer and its contact are both of type Person
        _Assert.AreEqual(Customer."Contact Type"::Person, Customer."Contact Type", 'The new customer must take the template contact type.');
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("No.", Customer."No.");
        _Assert.IsTrue(ContactBusinessRelation.FindFirst(), 'Precondition: a contact must be linked to the new customer.');
        Contact.Get(ContactBusinessRelation."Contact No.");
        _Assert.AreEqual(Contact.Type::Person, Contact.Type, 'The contact created for the new customer must be a Person.');
    end;

    [Test]
    procedure GivenTemplateWithoutInvoiceDiscCode_WhenNewCustomerIsCreated_ThenInvoiceDiscCodeIsCustomerNo()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [GIVEN] a customer template without an invoice discount code
        Initialize();
        CreateWorkingTemplate(CustomerTempl);
        _Assert.AreEqual('', CustomerTempl."Invoice Disc. Code", 'Precondition: the template must have no invoice discount code.');

        // [WHEN] an order for an unknown e-mail names the template and is converted
        SubmitV2Document(CustomerTempl.Code, '', NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the invoice discount code keeps the customer number set on insert
        _Assert.AreEqual(Customer."No.", Customer."Invoice Disc. Code", 'A blank template invoice discount code must not blank the customer value.');
    end;

    [Test]
    procedure GivenCustomerNoMappingAndAutomaticTemplateSeries_WhenNewCustomerIsCreated_ThenOrderNumberIsKept()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrderCustomerNo: Code[20];
        StartNo: Code[20];
    begin
        // [GIVEN] mapping by customer no., and a template with an automatic series and a document sending profile
        Initialize();
        SetCustomerMapping(Enum::"NPR IncEcomDocCustomerMapping"::"Customer No.");
        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."No. Series" := CreateTemplateNoSeries(true, false, StartNo);
        CustomerTempl."Document Sending Profile" := CreateDocumentSendingProfile();
        CustomerTempl.Modify();
        OrderCustomerNo := NextUnusedCustomerNo();

        // [WHEN] an order carrying an unused customer no. names the template and is converted
        SubmitV2Document(CustomerTempl.Code, OrderCustomerNo, NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the order number is kept, no series is stamped, and the template is still applied
        _Assert.AreEqual(OrderCustomerNo, Customer."No.", 'The customer no. from the order must be kept.');
        _Assert.AreEqual('', Customer."No. Series", 'A customer numbered by the order must not carry the template series.');
        _Assert.AreEqual(CustomerTempl."Document Sending Profile", Customer."Document Sending Profile", 'The template must still be applied.');
    end;

    [Test]
    procedure GivenExistingCustomerAndCreateAndUpdateMode_WhenDocumentIsProcessed_ThenTemplateIsNotApplied()
    begin
        // [GIVEN] an existing customer, Customer Update Mode "Create and Update"
        // [WHEN] an order for that customer names a template
        // [THEN] the template is not applied
        Initialize();
        VerifyTemplateIsNotAppliedToExistingCustomer(Enum::"NPR IncEcomDocCustUpdateMode"::"Create and Update");
    end;

    [Test]
    procedure GivenExistingCustomerAndCreateMode_WhenDocumentIsProcessed_ThenTemplateIsNotApplied()
    begin
        // [GIVEN] an existing customer, Customer Update Mode Create
        // [WHEN] an order for that customer names a template
        // [THEN] the template is not applied
        Initialize();
        VerifyTemplateIsNotAppliedToExistingCustomer(Enum::"NPR IncEcomDocCustUpdateMode"::Create);
    end;

    [Test]
    procedure GivenTemplateSeriesWithoutDefaultNos_WhenNewCustomerIsCreated_ThenDocumentFailsWithoutCustomer()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Email: Text;
        StartNo: Code[20];
        UnexpectedErrorErr: Label 'The conversion must fail on the template series %1 without automatic numbers. Actual error: %2', Locked = true;
    begin
        // [GIVEN] mapping by e-mail, and a template series that does not allow automatic numbers
        Initialize();
        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."No. Series" := CreateTemplateNoSeries(false, true, StartNo);
        CustomerTempl.Modify();
        Email := NextEmail();

        // [WHEN] an order for an unknown e-mail names the template and the conversion runs
        SubmitV2Document(CustomerTempl.Code, '', Email, EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [THEN] the document fails on the template series, and neither a customer nor a sales document is left behind
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreNotEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The document must not be converted.');
        _Assert.IsTrue(StrPos(EcomSalesHeader."Last Error Message", CustomerTempl."No. Series") > 0, StrSubstNo(UnexpectedErrorErr, CustomerTempl."No. Series", EcomSalesHeader."Last Error Message"));
        Customer.SetRange("E-Mail", Email);
        _Assert.RecordIsEmpty(Customer);
        _Assert.AreEqual(0, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'No sales document may be created.');
    end;

    [Test]
    procedure GivenSetupDefaultTemplateAndNoTemplateInRequest_WhenNewCustomerIsCreated_ThenSetupTemplateIsApplied()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        StartNo: Code[20];
    begin
        // [GIVEN] the setup default customer template has an automatic series and a document sending profile
        Initialize();
        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."No. Series" := CreateTemplateNoSeries(true, false, StartNo);
        CustomerTempl."Document Sending Profile" := CreateDocumentSendingProfile();
        CustomerTempl.Modify();
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Def. Customer Template Code" := CustomerTempl.Code;
        IncEcomSalesDocSetup."Def Cust Config Template Code" := '';
        IncEcomSalesDocSetup.Modify();

        // [WHEN] an order for an unknown e-mail names no template and is converted
        SubmitV2Document('', '', NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        // [THEN] the new customer gets the number, series and profile of the setup template, and the document keeps no template
        _Assert.AreEqual(StartNo, Customer."No.", 'The new customer must take the first number of the setup template series.');
        _Assert.AreEqual(CustomerTempl."No. Series", Customer."No. Series", 'The new customer must carry the setup template series.');
        _Assert.AreEqual(CustomerTempl."Document Sending Profile", Customer."Document Sending Profile", 'The document sending profile must be copied from the setup template.');
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual('', EcomSalesHeader."Customer Template", 'The setup default template must not be stored on the document.');
    end;

    [Test]
    procedure GivenV1DocumentAndDefaultTemplate_WhenNewCustomerIsCreated_ThenSeriesDimensionAndDocSendingProfileComeFromTemplate()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        StartNo: Code[20];
    begin
        // [GIVEN] the setup default customer template has a series, a default dimension and a document sending profile
        Initialize();
        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."No. Series" := CreateTemplateNoSeries(true, false, StartNo);
        CustomerTempl."Document Sending Profile" := CreateDocumentSendingProfile();
        CustomerTempl.Modify();
        CreateTemplateDefaultDimension(CustomerTempl, DimensionValue);
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Def. Customer Template Code" := CustomerTempl.Code;
        IncEcomSalesDocSetup.Modify();

        // [WHEN] an order for an unknown e-mail is posted with x-api-version 2025-07-13, so the previous API version converts it during the request
        SubmitV1Document(NextEmail(), EcomSalesHeader);
        GetCreatedCustomer(EcomSalesHeader, Customer);

        // [THEN] the number, the default dimension and the document sending profile come from the template
        _Assert.AreEqual(StartNo, Customer."No.", 'The new customer must take the first number of the template series.');
        _Assert.AreEqual(CustomerTempl."No. Series", Customer."No. Series", 'The new customer must carry the template series.');
        _Assert.IsTrue(DefaultDimension.Get(Database::Customer, Customer."No.", DimensionValue."Dimension Code"), 'The new customer must get the template default dimension.');
        _Assert.AreEqual(DimensionValue.Code, DefaultDimension."Dimension Value Code", 'The default dimension value must match the template.');
        _Assert.AreEqual(CustomerTempl."Document Sending Profile", Customer."Document Sending Profile", 'The document sending profile must be copied from the template.');
    end;

    local procedure VerifyTemplateIsNotAppliedToExistingCustomer(CustomerUpdateMode: Enum "NPR IncEcomDocCustUpdateMode")
    var
        Customer: Record Customer;
        CustomerBefore: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        StartNo: Code[20];
    begin
        // CreateCustomer switches the mapping to Customer No., so the update mode is set after it.
        CustomerBefore.Get(_LibEcom.CreateCustomer());
        SetCustomerUpdateMode(CustomerUpdateMode);

        CreateWorkingTemplate(CustomerTempl);
        CustomerTempl."No. Series" := CreateTemplateNoSeries(true, false, StartNo);
        CustomerTempl."Document Sending Profile" := CreateDocumentSendingProfile();
        if CustomerBefore."Contact Type" = CustomerBefore."Contact Type"::Company then
            CustomerTempl."Contact Type" := CustomerTempl."Contact Type"::Person
        else
            CustomerTempl."Contact Type" := CustomerTempl."Contact Type"::Company;
        CustomerTempl.Modify();
        CreateTemplateDefaultDimension(CustomerTempl, DimensionValue);
        _Assert.AreNotEqual(CustomerTempl."Document Sending Profile", CustomerBefore."Document Sending Profile", 'Precondition: the template profile must differ from the customer profile.');
        _Assert.AreNotEqual(CustomerTempl."No. Series", CustomerBefore."No. Series", 'Precondition: the template series must differ from the customer series.');

        SubmitV2Document(CustomerTempl.Code, CustomerBefore."No.", NextEmail(), EcomSalesHeader);
        ConvertAndGetCustomer(EcomSalesHeader, Customer);

        _Assert.AreEqual(CustomerBefore."No.", Customer."No.", 'The existing customer must be reused.');
        _Assert.AreEqual(CustomerBefore."Document Sending Profile", Customer."Document Sending Profile", 'The template must not change the document sending profile of an existing customer.');
        _Assert.AreEqual(CustomerBefore."No. Series", Customer."No. Series", 'The template must not change the series of an existing customer.');
        _Assert.AreEqual(CustomerBefore."Contact Type", Customer."Contact Type", 'The template must not change the contact type of an existing customer.');
        _Assert.IsFalse(DefaultDimension.Get(Database::Customer, Customer."No.", DimensionValue."Dimension Code"), 'The template default dimension must not be added to an existing customer.');
    end;

    local procedure Initialize()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
    begin
        _LibEcom.ResetEcomSetupToDefaults();
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Customer Mapping" := IncEcomSalesDocSetup."Customer Mapping"::"E-mail";
        IncEcomSalesDocSetup."Customer Update Mode" := IncEcomSalesDocSetup."Customer Update Mode"::Create;
        IncEcomSalesDocSetup."Def. Customer Template Code" := '';
        IncEcomSalesDocSetup."Def Cust Config Template Code" := '';
        IncEcomSalesDocSetup.Modify();
        _LibEcom.SetMaxDocProcessRetryCount(1);
        // The watch is SingleInstance; a latch left by an earlier codeunit would make the job queue exit without processing.
        EcomAppSetWatch.ResetForTest();
    end;

    local procedure SetCustomerMapping(CustomerMapping: Enum "NPR IncEcomDocCustomerMapping")
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Customer Mapping" := CustomerMapping;
        IncEcomSalesDocSetup.Modify();
    end;

    local procedure SetCustomerUpdateMode(CustomerUpdateMode: Enum "NPR IncEcomDocCustUpdateMode")
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Customer Update Mode" := CustomerUpdateMode;
        IncEcomSalesDocSetup.Modify();
    end;

    // Posting groups come from a library customer, the same ones the ecom library customers and items convert with.
    local procedure CreateWorkingTemplate(var CustomerTempl: Record "Customer Templ.")
    var
        Donor: Record Customer;
    begin
        _LibrarySales.CreateCustomer(Donor);
        CustomerTempl.Init();
        CustomerTempl.Code := _LibraryUtility.GenerateRandomCode(CustomerTempl.FieldNo(Code), Database::"Customer Templ.");
        CustomerTempl."Gen. Bus. Posting Group" := Donor."Gen. Bus. Posting Group";
        CustomerTempl."VAT Bus. Posting Group" := Donor."VAT Bus. Posting Group";
        CustomerTempl."Customer Posting Group" := Donor."Customer Posting Group";
        CustomerTempl.Insert();
    end;

    local procedure CreateTemplateNoSeries(DefaultNos: Boolean; ManualNos: Boolean; var StartNo: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        SeriesPrefix: Text;
    begin
        SeriesPrefix := CopyStr('CT' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 14);
        StartNo := CopyStr(SeriesPrefix + '000001', 1, MaxStrLen(StartNo));
        _LibraryUtility.CreateNoSeries(NoSeries, DefaultNos, ManualNos, false);
        _LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, StartNo, CopyStr(SeriesPrefix + '999999', 1, 20));
        exit(NoSeries.Code);
    end;

    local procedure CreateTemplateDefaultDimension(CustomerTempl: Record "Customer Templ."; var DimensionValue: Record "Dimension Value")
    var
        DefaultDimension: Record "Default Dimension";
        Dimension: Record Dimension;
    begin
        _LibraryDimension.CreateDimension(Dimension);
        _LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        _LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Customer Templ.", CustomerTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure CreateDocumentSendingProfile(): Code[20]
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        DocumentSendingProfile.Init();
        DocumentSendingProfile.Code := _LibraryUtility.GenerateRandomCode(DocumentSendingProfile.FieldNo(Code), Database::"Document Sending Profile");
        DocumentSendingProfile.Insert();
        exit(DocumentSendingProfile.Code);
    end;

    local procedure GetLanguageCode(): Code[10]
    var
        Language: Record Language;
    begin
        if not Language.FindFirst() then begin
            Language.Init();
            Language.Code := _LibraryUtility.GenerateRandomCode(Language.FieldNo(Code), Database::Language);
            Language.Insert();
        end;
        _Assert.AreNotEqual('', Language.Code, 'Precondition: a language must exist.');
        exit(Language.Code);
    end;

    local procedure GetCountryCodeOtherThan(CountryCode: Code[10]): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SetFilter(Code, '<>%1&<>%2', CountryCode, '');
        if not CountryRegion.FindFirst() then begin
            CountryRegion.Init();
            CountryRegion.Code := _LibraryUtility.GenerateRandomCode(CountryRegion.FieldNo(Code), Database::"Country/Region");
            CountryRegion.Insert();
        end;
        _Assert.AreNotEqual(CountryCode, CountryRegion.Code, 'Precondition: the template country must differ from the order country.');
        exit(CountryRegion.Code);
    end;

    // Without a business relation code CustCont-Update creates no contact, so the contact type could not be checked.
    local procedure EnsureMarketingSetup()
    var
        BusinessRelation: Record "Business Relation";
        MarketingSetup: Record "Marketing Setup";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        SeriesPrefix: Text;
    begin
        if not MarketingSetup.Get() then begin
            MarketingSetup.Init();
            MarketingSetup.Insert();
        end;
        if MarketingSetup."Contact Nos." = '' then begin
            SeriesPrefix := CopyStr('CTC' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 14);
            _LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            _LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, CopyStr(SeriesPrefix + '000001', 1, 20), CopyStr(SeriesPrefix + '999999', 1, 20));
            MarketingSetup."Contact Nos." := NoSeries.Code;
        end;
        if MarketingSetup."Bus. Rel. Code for Customers" = '' then begin
            BusinessRelation.Init();
            BusinessRelation.Code := _LibraryUtility.GenerateRandomCode(BusinessRelation.FieldNo(Code), Database::"Business Relation");
            BusinessRelation.Insert();
            MarketingSetup."Bus. Rel. Code for Customers" := BusinessRelation.Code;
        end;
        MarketingSetup.Modify();
    end;

    local procedure NextUnusedCustomerNo() CustomerNo: Code[20]
    var
        Customer: Record Customer;
    begin
        CustomerNo := CopyStr('CTO' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(CustomerNo));
        _Assert.IsFalse(Customer.Get(CustomerNo), 'Precondition: the order customer no. must be unused.');
    end;

    local procedure NextEmail(): Text
    begin
        exit('cust.templ.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@ecom.test');
    end;

    local procedure SubmitV2Document(CustomerTemplateCode: Code[20]; SellToNo: Code[20]; Email: Text; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('CTPL');
        Body := BuildBody(ExternalNo, Email, SellToNo, CustomerTemplateCode);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
    end;

    local procedure BuildBody(ExternalNo: Code[20]; Email: Text; SellToNo: Code[20]; CustomerTemplateCode: Code[20]) Body: JsonObject
    var
        SellTo: JsonObject;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        if SellToNo <> '' then
            SellTo.Add('no', SellToNo);
        if CustomerTemplateCode <> '' then
            SellTo.Add('customerTemplate', CustomerTemplateCode);
        SellTo.Add('name', 'Template Customer');
        SellTo.Add('address', 'Template Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Template City');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', Email);
        Body.Add('sellToCustomer', SellTo);
        Body.Add('salesDocumentLines', ItemLines());
    end;

    local procedure SubmitV1Document(Email: Text; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgent";
        Request: Codeunit "NPR API Request";
        Body: JsonObject;
        Payments: JsonArray;
        SellTo: JsonObject;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('CTPLV1');
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        SellTo.Add('type', 'person');
        SellTo.Add('name', 'Template Customer');
        SellTo.Add('address', 'Template Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Template City');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', Email);
        Body.Add('sellToCustomer', SellTo);
        Body.Add('salesDocumentLines', ItemLines());
        Body.Add('payments', Payments);

        // x-api-version below 2025-10-19 routes the document to the previous API version.
        Headers.Add('x-api-version', '2025-07-13');
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        Request.Init("Http Method"::POST, '/ecommerce/documents', PathSegments, QueryParams, Headers, Body.AsToken());
        ApiAgent.CreateIncomingEcomDocument(Request);

        EcomSalesHeader.SetRange("External No.", ExternalNo);
        EcomSalesHeader.FindFirst();
    end;

    local procedure ItemLines() Lines: JsonArray
    var
        Line: JsonObject;
    begin
        Line.Add('type', 'item');
        Line.Add('no', _LibEcom.CreateItem());
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Lines.Add(Line);
    end;

    local procedure ConvertAndGetCustomer(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer)
    begin
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);
        GetCreatedCustomer(EcomSalesHeader, Customer);
    end;

    local procedure GetCreatedCustomer(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer)
    var
        SalesHeader: Record "Sales Header";
        NotConvertedErr: Label 'The document must be converted. Creation status: %1. Last error: %2', Locked = true;
    begin
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", StrSubstNo(NotConvertedErr, EcomSalesHeader."Creation Status", EcomSalesHeader."Last Error Message"));
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        SalesHeader.FindFirst();
        Customer.Get(SalesHeader."Sell-to Customer No.");
    end;
}
