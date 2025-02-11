codeunit 85209 "NPR ES Taxpayer Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateTaxpayer()
    var
        ESOrganization: Record "NPR ES Organization";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        TaxpayerNotCreatedErr: Label 'Taxpayer is not created.', Locked = true;
    begin
        // [SCENARIO] Checks creation of Taxpayer with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists and Taxpayer's territory is assigned to it
        CreateESOrganization(ESOrganization);

        // [WHEN] Creating Taxpayer at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.CreateTaxpayer(ESOrganization);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] Taxpayer is created at Fiskaly
        Assert.AreEqual(ESOrganization."Taxpayer Territory", ESOrganization."Taxpayer Territory"::BIZKAIA, TaxpayerNotCreatedErr);
        Assert.AreEqual(ESOrganization."Taxpayer Type", ESOrganization."Taxpayer Type"::COMPANY, TaxpayerNotCreatedErr);
        Assert.IsTrue(ESOrganization."Taxpayer Created", TaxpayerNotCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveTaxpayer()
    var
        ESOrganization: Record "NPR ES Organization";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        TaxpayerNotCreatedErr: Label 'Taxpayer is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Taxpayer with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists and Taxpayer's territory is assigned to it
        CreateESOrganization(ESOrganization);

        // [WHEN] Retrieving Taxpayer from Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.RetrieveTaxpayer(ESOrganization);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] Taxpayer is retrieved from Fiskaly
        Assert.AreEqual(ESOrganization."Taxpayer Territory", ESOrganization."Taxpayer Territory"::BIZKAIA, TaxpayerNotCreatedErr);
        Assert.AreEqual(ESOrganization."Taxpayer Type", ESOrganization."Taxpayer Type"::COMPANY, TaxpayerNotCreatedErr);
        Assert.IsTrue(ESOrganization."Taxpayer Created", TaxpayerNotCreatedErr);
    end;

    local procedure CreateESOrganization(var ESOrganization: Record "NPR ES Organization")
    var
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        ESFiscalLibrary.CreateESOrganization(ESOrganization);
        ESOrganization."Taxpayer Territory" := ESOrganization."Taxpayer Territory"::BIZKAIA;
        ESOrganization.Modify(true);
    end;

    local procedure InitializeData()
    var
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if Initialized then
            exit;

        ESFiscalLibrary.EnableESFiscalization();
        SetVATRegistrationNoOnCompanyInformation();

        Initialized := true;
        Commit();
    end;

    local procedure SetVATRegistrationNoOnCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := 'B44752212'; // it has to be according to Spain law
        CompanyInformation.Modify();
    end;
}
