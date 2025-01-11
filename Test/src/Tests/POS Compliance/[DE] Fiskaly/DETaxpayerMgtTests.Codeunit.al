codeunit 85218 "NPR DE Taxpayer Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpsertTaxpayer()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        TaxpayerNotUpsertedErr: Label 'Taxpayer is not upserted.', Locked = true;
    begin
        // [SCENARIO] Checks creation/update of Taxpayer with successful response from Fiskaly
        // [GIVEN] DE audit setup is enabled
        InitializeData();

        // [GIVEN] Registration number is populated on company information
        DEFiscalLibrary.UpdateRegistrationNumberOnCompanyInformation();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer's data are entered
        CreateConnectionParameterSet(ConnectionParameterSet);

        // [WHEN] Creating Taxpayer at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.UpsertTaxpayer(ConnectionParameterSet);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Taxpayer is upserted at Fiskaly
        Assert.AreNotEqual(ConnectionParameterSet."Taxpayer Registration No.", '', TaxpayerNotUpsertedErr);
        Assert.AreNotEqual(ConnectionParameterSet."Taxpayer Person Type", ConnectionParameterSet."Taxpayer Person Type"::" ", TaxpayerNotUpsertedErr);
        Assert.AreNotEqual(ConnectionParameterSet."Taxpayer Legal Form", ConnectionParameterSet."Taxpayer Legal Form"::" ", TaxpayerNotUpsertedErr);
        Assert.IsTrue(ConnectionParameterSet."Taxpayer Created", TaxpayerNotUpsertedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveTaxpayer()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        TaxpayerIsNotRetrievedErr: Label 'Taxpayer is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Taxpayer with successful response from Fiskaly
        // [GIVEN] DE audit setup is enabled
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists
        DEFiscalLibrary.CreateConnectionParameterSet(ConnectionParameterSet);

        // [WHEN] Retrieving Taxpayer from Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.RetrieveTaxpayer(ConnectionParameterSet);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Taxpayer is retrieved from Fiskaly
        Assert.AreNotEqual(ConnectionParameterSet."Taxpayer Registration No.", '', TaxpayerIsNotRetrievedErr);
        Assert.AreNotEqual(ConnectionParameterSet."Taxpayer Person Type", ConnectionParameterSet."Taxpayer Person Type"::" ", TaxpayerIsNotRetrievedErr);
        Assert.AreNotEqual(ConnectionParameterSet."Taxpayer Legal Form", ConnectionParameterSet."Taxpayer Legal Form"::" ", TaxpayerIsNotRetrievedErr);
        Assert.IsTrue(ConnectionParameterSet."Taxpayer Created", TaxpayerIsNotRetrievedErr);
    end;

    local procedure CreateConnectionParameterSet(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        DEFiscalLibrary.CreateConnectionParameterSet(ConnectionParameterSet);
        DEFiscalLibrary.UpdateLegalTaxpayerDataOnConnectionParameterSet(ConnectionParameterSet);
    end;

    local procedure InitializeData()
    var
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        if Initialized then
            exit;

        DEFiscalLibrary.EnableFiscalization();

        Initialized := true;
        Commit();
    end;
}
