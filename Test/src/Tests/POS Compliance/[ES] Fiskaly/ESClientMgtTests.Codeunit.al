codeunit 85211 "NPR ES Client Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateClient()
    var
        ESClient: Record "NPR ES Client";
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESClientNotCreatedErr: Label 'ES Client is not created.', Locked = true;
    begin
        // [SCENARIO] Checks creation of Client with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists
        ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);

        // [GIVEN] ES Signer exists and it is assigned to ES Organization
        ESFiscalLibrary.CreateESSigner(ESSigner, ESOrganization.Code);

        // [GIVEN] ES Client exists and ES Signer is assigned to it
        CreateESClient(ESClient, ESSigner, POSUnit."No.", ESOrganization.Code);

        // [WHEN] Creating ES Client at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.CreateClient(ESClient);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES Client is created at Fiskaly
        Assert.IsTrue(ESClient.Description <> '', ESClientNotCreatedErr);
        Assert.AreEqual(ESClient.State, ESClient.State::ENABLED, ESClientNotCreatedErr);
        Assert.IsTrue(ESClient."ES Signer Code" <> '', ESClientNotCreatedErr);
        Assert.IsFalse(IsNullGuid(ESClient."ES Signer Id"), ESClientNotCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure UpdateClient()
    var
        ESClient: Record "NPR ES Client";
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESSignerNotUpdatedErr: Label 'ES Client is not updated.', Locked = true;
    begin
        // [SCENARIO] Checks updating of Client with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists
        ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);

        // [GIVEN] ES Signer exists and it is assigned to ES Organization
        ESFiscalLibrary.CreateESSigner(ESSigner, ESOrganization.Code);

        // [GIVEN] ES Client exists and it is created at Fiskaly
        CreateESClientAtFiskaly(ESClient, ESSigner, POSUnit."No.", ESOrganization.Code);

        // [WHEN] Updating ES Client at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.UpdateClient(ESClient, ESClient.State::DISABLED);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES Client is updated at Fiskaly
        Assert.IsTrue(ESClient.Description <> '', ESSignerNotUpdatedErr);
        Assert.AreEqual(ESClient.State, ESClient.State::DISABLED, ESSignerNotUpdatedErr);
        Assert.IsTrue(ESClient."ES Signer Code" <> '', ESSignerNotUpdatedErr);
        Assert.IsFalse(IsNullGuid(ESClient."ES Signer Id"), ESSignerNotUpdatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveClient()
    var
        ESClient: Record "NPR ES Client";
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESClientNotRetrievedErr: Label 'ES Client is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Client with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists
        ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);

        // [GIVEN] ES Signer exists and it is assigned to ES Organization
        ESFiscalLibrary.CreateESSigner(ESSigner, ESOrganization.Code);

        // [GIVEN] ES Client exists and ES Signer is assigned to it
        CreateESClient(ESClient, ESSigner, POSUnit."No.", ESOrganization.Code);

        // [WHEN] Retrieving ES Client at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.RetrieveClient(ESClient);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES Client is retrieved from Fiskaly
        Assert.IsTrue(ESClient.Description <> '', ESClientNotRetrievedErr);
        Assert.AreEqual(ESClient.State, ESClient.State::DISABLED, ESClientNotRetrievedErr);
        Assert.IsTrue(ESClient."ES Signer Code" <> '', ESClientNotRetrievedErr);
        Assert.IsFalse(IsNullGuid(ESClient."ES Signer Id"), ESClientNotRetrievedErr);
    end;

    local procedure CreateESClient(var ESClient: Record "NPR ES Client"; ESSigner: Record "NPR ES Signer"; POSUnitNo: Code[10]; ESOrganizationCode: Code[20])
    var
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if ESClient.Get(POSUnitNo) then
            ESClient.Delete();

        ESFiscalLibrary.CreateESClient(ESClient, POSUnitNo);
        ESClient.Validate("ES Organization Code", ESOrganizationCode);
        ESClient.Validate("ES Signer Code", ESSigner.Code);
        ESClient.Validate("ES Signer Id", ESSigner.SystemId);
        ESClient.Modify(true);
    end;

    local procedure CreateESClientAtFiskaly(var ESClient: Record "NPR ES Client"; ESSigner: Record "NPR ES Signer"; POSUnitNo: Code[10]; ESOrganizationCode: Code[20])
    var
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if ESClient.Get(POSUnitNo) then
            ESClient.Delete();

        ESFiscalLibrary.CreateESClient(ESClient, POSUnitNo);
        ESFiscalLibrary.EnableESClient(ESClient, ESSigner, ESOrganizationCode);
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        UpdateStateToDisabledQst: Label 'Are you sure that you want to set the State to Disabled since this it is irreversible?', Locked = true;
        QuestionNotExpectedErr: Label 'Question "%1" is not expected.', Locked = true;
    begin
        case true of
            Question = UpdateStateToDisabledQst:
                Reply := true;
            else
                Error(QuestionNotExpectedErr, Question);
        end;
    end;

    local procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if Initialized then
            exit;

        POSMasterDataLibrary.CreatePOSSetup(POSSetup);
        POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);
        POSPostingProfile."POS Period Register No. Series" := '';
        POSPostingProfile.Modify();
        POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
        POSMasterDataLibrary.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);

        ESFiscalLibrary.EnableESFiscalization();

        Initialized := true;
    end;
}