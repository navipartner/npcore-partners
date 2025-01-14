codeunit 85220 "NPR DE Client Add D Mgt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpsertClientAdditionalData()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
        POSStore: Record "NPR POS Store";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        ClientAdditionalDataNotUpsertedErr: Label 'Client additional data is not upserted.', Locked = true;
    begin
        // [SCENARIO] Checks creation/update of Client additional data with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and it is created at Fiskaly
        CreateEstablishmentAtFiskaly(DEEstablishment, POSStore, ConnectionParameterSet."Primary Key");

        // [GIVEN] DE TSS exists and it is created at Fiskaly
        CreateTSSAtFiskaly(DETSS, ConnectionParameterSet."Primary Key");

        // [GIVEN] DE TSS Client exists for POS Unit, DE TSS is assigned to it and its data are entered
        CreateTSSClient(DETSSClient, POSStore.Code, DETSS.Code);

        // [WHEN] Creating Client additional data at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.UpsertClientAdditionalData(DETSSClient, false);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Client additional data is upserted at Fiskaly
        Assert.AreNotEqual(DETSSClient."Acquisition Date", 0D, ClientAdditionalDataNotUpsertedErr);
        Assert.AreNotEqual(DETSSClient."Commissioning Date", 0D, ClientAdditionalDataNotUpsertedErr);
        Assert.AreNotEqual(DETSSClient."Cash Register Brand", '', ClientAdditionalDataNotUpsertedErr);
        Assert.AreNotEqual(DETSSClient."Cash Register Model", '', ClientAdditionalDataNotUpsertedErr);
        Assert.AreNotEqual(DETSSClient.Software, '', ClientAdditionalDataNotUpsertedErr);
        Assert.AreNotEqual(DETSSClient."Client Type", DETSSClient."Client Type"::" ", ClientAdditionalDataNotUpsertedErr);
        Assert.IsTrue(DETSSClient."Additional Data Created", ClientAdditionalDataNotUpsertedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure DecommissionClientAdditionalData()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
        POSStore: Record "NPR POS Store";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        ClientAdditionalDataNotDecommissionedErr: Label 'Client additional data is not decomissioned.', Locked = true;
    begin
        // [SCENARIO] Checks decomissioning of client additional data with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and it is created at Fiskaly
        CreateEstablishmentAtFiskaly(DEEstablishment, POSStore, ConnectionParameterSet."Primary Key");

        // [GIVEN] DE TSS exists and it is created at Fiskaly
        CreateTSSAtFiskaly(DETSS, ConnectionParameterSet."Primary Key");

        // [GIVEN] DE TSS Client exists for POS Unit, DE TSS is assigned to it and its data are entered and Decomissioning Date is assigned
        CreateTSSClient(DETSSClient, POSStore.Code, DETSS.Code, Today());

        // [WHEN] Decomissioning Client additional data at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.DecommissionClientAdditionalData(DETSSClient);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Client additional data is decomissioned at Fiskaly
        Assert.AreNotEqual(DETSSClient."Decommissioning Date", 0D, ClientAdditionalDataNotDecommissionedErr);
        Assert.IsTrue(DETSSClient."Additional Data Decommissioned", ClientAdditionalDataNotDecommissionedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveClientAdditionalData()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        ClientAdditionalDataNotRetrievedErr: Label 'Client additional data is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Establishment with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and it is created at Fiskaly
        CreateEstablishmentAtFiskaly(DEEstablishment, POSStore, ConnectionParameterSet."Primary Key");

        // [GIVEN] DE TSS exists and it is created at Fiskaly
        CreateTSSAtFiskaly(DETSS, ConnectionParameterSet."Primary Key");

        // [GIVEN] DE TSS Client exists for POS Unit and DE TSS is assigned to it
        POSMasterDataLibrary.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
        DEFiscalLibrary.CreateTSSClient(DETSSClient, POSUnit."No.", DETSS.Code);

        // [WHEN] Retrieving client additional data from Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.RetrieveClientAdditionalData(DETSSClient);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Client additional data is retrieved from Fiskaly
        Assert.AreNotEqual(DETSSClient."Acquisition Date", 0D, ClientAdditionalDataNotRetrievedErr);
        Assert.AreNotEqual(DETSSClient."Commissioning Date", 0D, ClientAdditionalDataNotRetrievedErr);
        Assert.AreNotEqual(DETSSClient."Cash Register Brand", '', ClientAdditionalDataNotRetrievedErr);
        Assert.AreNotEqual(DETSSClient."Cash Register Model", '', ClientAdditionalDataNotRetrievedErr);
        Assert.AreNotEqual(DETSSClient.Software, '', ClientAdditionalDataNotRetrievedErr);
        Assert.AreNotEqual(DETSSClient."Client Type", DETSSClient."Client Type"::" ", ClientAdditionalDataNotRetrievedErr);
        Assert.IsTrue(DETSSClient."Additional Data Created", ClientAdditionalDataNotRetrievedErr);
    end;

    local procedure CreateTaxpayerAtFiskalyForConnectionParameterSet(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        DEFiscalLibrary.CreateTestConnectionParameterSet(ConnectionParameterSet);
        ConnectionParameterSet.Validate("Taxpayer Created", true);
        ConnectionParameterSet.Modify(true);
    end;

    local procedure CreateEstablishmentAtFiskaly(var DEEstablishment: Record "NPR DE Establishment"; var POSStore: Record "NPR POS Store"; ConnectionParameterSetCode: Code[10])
    var
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
        DEFiscalLibrary.CreateEstablishment(DEEstablishment, POSStore.Code, ConnectionParameterSetCode);
        DEEstablishment.Validate(Created, true);
        DEEstablishment.Modify(true);
    end;

    local procedure CreateTSSAtFiskaly(var DETSS: Record "NPR DE TSS"; ConnectionParameterSetCode: Code[10])
    var
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        DEFiscalLibrary.CreateTSS(DETSS, ConnectionParameterSetCode);
        DETSS.Validate("Fiskaly TSS Created at", CurrentDateTime());
        DETSS.Modify(true);
    end;

    local procedure CreateTSSClient(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; POSStoreCode: Code[10]; TSSCode: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        POSMasterDataLibrary.CreatePOSUnit(POSUnit, POSStoreCode, POSPostingProfile.Code);
        DEFiscalLibrary.CreateTSSClient(DETSSClient, POSUnit."No.", TSSCode);
        DEFiscalLibrary.UpdateAdditionalDataOnTSSClient(DETSSClient);
    end;

    local procedure CreateTSSClient(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; POSStoreCode: Code[10]; TSSCode: Code[10]; DecomissionDate: Date)
    begin
        CreateTSSClient(DETSSClient, POSStoreCode, TSSCode);
        DETSSClient.Validate("Decommissioning Date", DecomissionDate);
        DETSSClient.Modify(true);
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
