codeunit 85195 "NPR AT SCU Management Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSCU()
    var
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ATSCUNotCreatedErr: Label 'AT SCU is not created.', Locked = true;
    begin
        // [SCENARIO] Checks creation of Signature Creation Unit with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] AT Organization exists
        CreateATOrganization(ATOrganization);

        // [GIVEN] AT SCU exists and it is assigned to AT Organization
        CreateATSCU(ATSCU, ATOrganization.Code);

        // [WHEN] Creating AT SCU at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.CreateSCU(ATSCU);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] AT SCU is created at Fiskaly
        Assert.AreEqual(ATSCU.State, ATSCU.State::CREATED, ATSCUNotCreatedErr);
        Assert.IsTrue(ATSCU."Certificate Serial Number" <> '', ATSCUNotCreatedErr);
        Assert.IsTrue(ATSCU."Pending At" <> 0DT, ATSCUNotCreatedErr);
        Assert.IsTrue(ATSCU."Created At" <> 0DT, ATSCUNotCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveSCU()
    var
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ATSCUNotRetrievedErr: Label 'AT SCU is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Signature Creation Unit with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] AT Organization exists
        CreateATOrganization(ATOrganization);

        // [GIVEN] AT SCU exists and it is assigned to AT Organization
        CreateATSCU(ATSCU, ATOrganization.Code);

        // [WHEN] Retrieving AT SCU at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.RetrieveSCU(ATSCU);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] AT SCU is retrieved from Fiskaly
        Assert.AreEqual(ATSCU.State, ATSCU.State::DECOMMISSIONED, ATSCUNotRetrievedErr);
        Assert.IsTrue(ATSCU."Certificate Serial Number" <> '', ATSCUNotRetrievedErr);
        Assert.IsTrue(ATSCU."Pending At" <> 0DT, ATSCUNotRetrievedErr);
        Assert.IsTrue(ATSCU."Created At" <> 0DT, ATSCUNotRetrievedErr);
        Assert.IsTrue(ATSCU."Initialized At" <> 0DT, ATSCUNotRetrievedErr);
        Assert.IsTrue(ATSCU."Decommissioned At" <> 0DT, ATSCUNotRetrievedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateSCU()
    var
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ATSCUNotUpdatedErr: Label 'AT SCU is not updated.', Locked = true;
    begin
        // [SCENARIO] Checks updating of Signature Creation Unit with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] AT Organization exists
        CreateATOrganization(ATOrganization);

        // [GIVEN] AT SCU exists and it is created at Fiskaly
        CreateATSCUAtFiskaly(ATSCU, ATOrganization.Code);

        // [WHEN] Updating AT SCU at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.UpdateSCU(ATSCU, ATSCU.State::INITIALIZED);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] AT SCU is updated from Fiskaly
        Assert.AreEqual(ATSCU.State, ATSCU.State::INITIALIZED, ATSCUNotUpdatedErr);
        Assert.IsTrue(ATSCU."Certificate Serial Number" <> '', ATSCUNotUpdatedErr);
        Assert.IsTrue(ATSCU."Pending At" <> 0DT, ATSCUNotUpdatedErr);
        Assert.IsTrue(ATSCU."Created At" <> 0DT, ATSCUNotUpdatedErr);
        Assert.IsTrue(ATSCU."Initialized At" <> 0DT, ATSCUNotUpdatedErr);
    end;

    local procedure CreateATOrganization(var ATOrganization: Record "NPR AT Organization")
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATOrganization(ATOrganization);
        ATFiscalLibrary.AuthenticateATOrganizaiton(ATOrganization);
    end;

    local procedure CreateATSCU(var ATSCU: Record "NPR AT SCU"; ATOrganizationCode: Code[20])
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATSCU(ATSCU);
        ATSCU.Validate("AT Organization Code", ATOrganizationCode);
        ATSCU.Modify(true);
    end;

    local procedure CreateATSCUAtFiskaly(var ATSCU: Record "NPR AT SCU"; ATOrganizationCode: Code[20])
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATSCU(ATSCU);
        ATSCU.Validate("AT Organization Code", ATOrganizationCode);
        ATSCU.Validate(State, ATSCU.State::CREATED);
        ATSCU.Validate("Certificate Serial Number", Format(CreateGuid(), 0, 4));
        ATSCU.Validate("Pending At", CurrentDateTime());
        ATSCU.Validate("Created At", CurrentDateTime());
        ATSCU.Modify(true);
    end;

    local procedure InitializeData()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        if Initialized then begin
            // Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end else begin
            POSMasterDataLibrary.CreatePOSSetup(POSSetup);
            POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            ATFiscalLibrary.EnableATFiscalization();
            SetVATRegistrationNoOnCompanyInformation();

            Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); // Clean between tests
        Commit();
    end;

    local procedure SetVATRegistrationNoOnCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := 'ATU73948115'; // it has to be according to Austrian law
        CompanyInformation.Modify();
    end;
}