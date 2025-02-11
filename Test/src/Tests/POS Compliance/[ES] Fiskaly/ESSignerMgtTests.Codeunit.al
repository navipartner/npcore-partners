codeunit 85210 "NPR ES Signer Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSigner()
    var
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESSignerNotCreatedErr: Label 'ES Signer is not created.', Locked = true;
    begin
        // [SCENARIO] Checks creation of Signer with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists
        ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);

        // [GIVEN] ES Signer exists and it is assigned to ES Organization
        CreateESSigner(ESSigner, ESOrganization.Code);

        // [WHEN] Creating ES Signer at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.CreateSigner(ESSigner);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES Signer is created at Fiskaly
        Assert.AreEqual(ESSigner.State, ESSigner.State::ENABLED, ESSignerNotCreatedErr);
        Assert.IsTrue(ESSigner."Certificate Serial Number" <> '', ESSignerNotCreatedErr);
        Assert.IsTrue(ESSigner."Certificate Expires At" <> 0DT, ESSignerNotCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure UpdateSigner()
    var
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESSignerNotUpdatedErr: Label 'ES Signer is not updated.', Locked = true;
    begin
        // [SCENARIO] Checks updating of Signer with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists
        ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);

        // [GIVEN] ES Signer exists and it is created at Fiskaly
        CreateESSignerAtFiskaly(ESSigner, ESOrganization.Code);

        // [WHEN] Updating ES Signer at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.UpdateSigner(ESSigner, ESSigner.State::DISABLED);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES Signer is updated at Fiskaly
        Assert.AreEqual(ESSigner.State, ESSigner.State::DISABLED, ESSignerNotUpdatedErr);
        Assert.IsTrue(ESSigner."Certificate Serial Number" <> '', ESSignerNotUpdatedErr);
        Assert.IsTrue(ESSigner."Certificate Expires At" <> 0DT, ESSignerNotUpdatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveSigner()
    var
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESSignerNotRetrievedErr: Label 'ES Signer is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Signer with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES Organization exists
        ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);

        // [GIVEN] ES Signer exists and it is assigned to ES Organization
        CreateESSigner(ESSigner, ESOrganization.Code);

        // [WHEN] Retrieving ES Signer from Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiskalyCommunication.RetrieveSigner(ESSigner);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES Signer is retrieved from Fiskaly
        Assert.AreEqual(ESSigner.State, ESSigner.State::DEFECTIVE, ESSignerNotRetrievedErr);
        Assert.IsTrue(ESSigner."Certificate Serial Number" <> '', ESSignerNotRetrievedErr);
        Assert.IsTrue(ESSigner."Certificate Expires At" <> 0DT, ESSignerNotRetrievedErr);
    end;

    local procedure CreateESSigner(var ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20])
    var
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        ESFiscalLibrary.CreateESSigner(ESSigner);
        ESSigner.Validate("ES Organization Code", ESOrganizationCode);
        ESSigner.Modify(true);
    end;

    local procedure CreateESSignerAtFiskaly(var ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20])
    var
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        ESFiscalLibrary.CreateESSigner(ESSigner);
        ESSigner.Validate("ES Organization Code", ESOrganizationCode);
        ESSigner.Validate(State, ESSigner.State::ENABLED);
        ESSigner.Validate("Certificate Serial Number", Format(CreateGuid(), 0, 4));
        ESSigner.Validate("Certificate Expires At", CurrentDateTime());
        ESSigner.Modify(true);
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
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if Initialized then
            exit;

        ESFiscalLibrary.EnableESFiscalization();

        Initialized := true;
        Commit();
    end;
}