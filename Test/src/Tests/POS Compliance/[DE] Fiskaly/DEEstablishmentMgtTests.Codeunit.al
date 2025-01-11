codeunit 85219 "NPR DE Establishment Mgt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpsertEstablishment()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        EstablishmentNotUpsertedErr: Label 'Establishment is not upserted.', Locked = true;
    begin
        // [SCENARIO] Checks creation/update of Establishment with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store, DE Connection Parameter Set is assigned to it and its data are entered
        CreateEstablishment(DEEstablishment, ConnectionParameterSet."Primary Key");

        // [WHEN] Creating Establishment at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.UpsertEstablishment(DEEstablishment, false);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Establishment is upserted at Fiskaly
        Assert.AreNotEqual(DEEstablishment.Street, '', EstablishmentNotUpsertedErr);
        Assert.AreNotEqual(DEEstablishment."House Number", '', EstablishmentNotUpsertedErr);
        Assert.AreNotEqual(DEEstablishment.Town, '', EstablishmentNotUpsertedErr);
        Assert.AreNotEqual(DEEstablishment."ZIP Code", '', EstablishmentNotUpsertedErr);
        Assert.IsTrue(DEEstablishment.Created, EstablishmentNotUpsertedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure DecommissionEstablishment()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        EstablishmentNotDecommissionedErr: Label 'Establishment is not decomissioned.', Locked = true;
    begin
        // [SCENARIO] Checks decomissioning of Establishment with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store, DE Connection Parameter Set is assigned to it, its data are entered and Decomissioning Date is assigned
        CreateEstablishment(DEEstablishment, ConnectionParameterSet."Primary Key", Today());

        // [WHEN] Decomissioning Establishment at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.DecommissionEstablishment(DEEstablishment);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Establishment is decomissioned at Fiskaly
        Assert.AreNotEqual(DEEstablishment."Decommissioning Date", 0D, EstablishmentNotDecommissionedErr);
        Assert.IsTrue(DEEstablishment.Decommissioned, EstablishmentNotDecommissionedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveEstablishment()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        POSStore: Record "NPR POS Store";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        EstablishmentIsNotRetrievedErr: Label 'Establishment is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Establishment with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and DE Connection Parameter Set is assigned to it
        POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
        DEFiscalLibrary.CreateEstablishment(DEEstablishment, POSStore.Code, ConnectionParameterSet."Primary Key");

        // [WHEN] Retrieving Establishment from Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.RetrieveEstablishment(DEEstablishment);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Establishment is retrieved from Fiskaly
        Assert.AreNotEqual(DEEstablishment.Street, '', EstablishmentIsNotRetrievedErr);
        Assert.AreNotEqual(DEEstablishment."House Number", '', EstablishmentIsNotRetrievedErr);
        Assert.AreNotEqual(DEEstablishment.Town, '', EstablishmentIsNotRetrievedErr);
        Assert.AreNotEqual(DEEstablishment."ZIP Code", '', EstablishmentIsNotRetrievedErr);
        Assert.IsTrue(DEEstablishment.Created, EstablishmentIsNotRetrievedErr);
    end;

    local procedure CreateTaxpayerAtFiskalyForConnectionParameterSet(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        DEFiscalLibrary.CreateTestConnectionParameterSet(ConnectionParameterSet);
        ConnectionParameterSet.Validate("Taxpayer Created", true);
        ConnectionParameterSet.Modify(true);
    end;

    local procedure CreateEstablishment(var DEEstablishment: Record "NPR DE Establishment"; ConnectionParameterSetCode: Code[10])
    var
        POSStore: Record "NPR POS Store";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
        DEFiscalLibrary.CreateEstablishment(DEEstablishment, POSStore.Code, ConnectionParameterSetCode);
        DEFiscalLibrary.SetAddressDataOnEstablishment(DEEstablishment);
    end;

    local procedure CreateEstablishment(var DEEstablishment: Record "NPR DE Establishment"; ConnectionParameterSetCode: Code[10]; DecomissionDate: Date)
    begin
        CreateEstablishment(DEEstablishment, ConnectionParameterSetCode);
        DEEstablishment.Validate("Decommissioning Date", DecomissionDate);
        DEEstablishment.Modify(true);
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure InitializeData()
    var
        POSSetup: Record "NPR POS Setup";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        if Initialized then
            exit;

        POSMasterDataLibrary.CreatePOSSetup(POSSetup);
        POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);

        DEFiscalLibrary.EnableFiscalization();

        Initialized := true;
        Commit();
    end;
}
