codeunit 85196 "NPR AT Cash Register Mgt Tests"
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
    procedure CreateCashRegister()
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ATCashRegisterNotCreatedErr: Label 'AT Cash Register is not created.', Locked = true;
    begin
        // [SCENARIO] Checks creation of Cash Register with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] AT Organization exists
        CreateATOrganization(ATOrganization);

        // [GIVEN] AT SCU exists and it is assigned to AT Organization
        CreateATSCU(ATSCU, ATOrganization.Code);

        // [GIVEN] AT Cash Register exists and AT SCU is assigned to it
        CreateATCashRegister(ATCashRegister, POSUnit."No.", ATSCU.Code);

        // [WHEN] Creating AT Cash Register at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.CreateCashRegister(ATCashRegister);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] AT Cash Register is created at Fiskaly
        Assert.IsTrue(ATCashRegister.Description <> '', ATCashRegisterNotCreatedErr);
        Assert.AreEqual(ATCashRegister.State, ATCashRegister.State::CREATED, ATCashRegisterNotCreatedErr);
        Assert.IsTrue(ATCashRegister."Serial Number" <> '', ATCashRegisterNotCreatedErr);
        Assert.IsTrue(ATCashRegister."Created At" <> 0DT, ATCashRegisterNotCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveCashRegister()
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ATCashRegisterNotRetrievedErr: Label 'AT Cash Register is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of Cash Register with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] AT Organization exists
        CreateATOrganization(ATOrganization);

        // [GIVEN] AT SCU exists and it is assigned to AT Organization
        CreateATSCU(ATSCU, ATOrganization.Code);

        // [GIVEN] AT Cash Register exists and AT SCU is assigned to it
        CreateATCashRegister(ATCashRegister, POSUnit."No.", ATSCU.Code);

        // [WHEN] Retrieving AT Cash Register at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.RetrieveCashRegister(ATCashRegister);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] AT Cash Register is retrieved from Fiskaly
        Assert.IsTrue(ATCashRegister.Description <> '', ATCashRegisterNotRetrievedErr);
        Assert.AreEqual(ATCashRegister.State, ATCashRegister.State::DECOMMISSIONED, ATCashRegisterNotRetrievedErr);
        Assert.IsTrue(ATCashRegister."Serial Number" <> '', ATCashRegisterNotRetrievedErr);
        Assert.IsTrue(ATCashRegister."Created At" <> 0DT, ATCashRegisterNotRetrievedErr);
        Assert.IsTrue(ATCashRegister."Registered At" <> 0DT, ATCashRegisterNotRetrievedErr);
        Assert.IsTrue(ATCashRegister."Initialized At" <> 0DT, ATCashRegisterNotRetrievedErr);
        Assert.IsFalse(IsNullGuid(ATCashRegister."Initialization Receipt Id"), ATCashRegisterNotRetrievedErr);
        Assert.IsTrue(ATCashRegister."Decommissioned At" <> 0DT, ATCashRegisterNotRetrievedErr);
        Assert.IsFalse(IsNullGuid(ATCashRegister."Decommission Receipt Id"), ATCashRegisterNotRetrievedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateCashRegister()
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ATSCUNotUpdatedErr: Label 'AT Cash Register is not updated.', Locked = true;
    begin
        // [SCENARIO] Checks updating of Cash Register with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] AT Organization exists
        CreateATOrganization(ATOrganization);

        // [GIVEN] AT SCU exists and it is assigned to AT Organization
        CreateATSCU(ATSCU, ATOrganization.Code);

        // [GIVEN] AT Cash Register exists and it is created at Fiskaly
        CreateATCashRegisterAtFiskaly(ATCashRegister, POSUnit."No.", ATSCU.Code);

        // [WHEN] Updating AT Cash Register at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.UpdateCashRegister(ATCashRegister, ATCashRegister.State::REGISTERED);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] AT Cash Register is updated from Fiskaly
        Assert.IsTrue(ATCashRegister.Description <> '', ATSCUNotUpdatedErr);
        Assert.AreEqual(ATCashRegister.State, ATCashRegister.State::REGISTERED, ATSCUNotUpdatedErr);
        Assert.IsTrue(ATCashRegister."Serial Number" <> '', ATSCUNotUpdatedErr);
        Assert.IsTrue(ATCashRegister."Created At" <> 0DT, ATSCUNotUpdatedErr);
        Assert.IsTrue(ATCashRegister."Registered At" <> 0DT, ATSCUNotUpdatedErr);
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
        ATFiscalLibrary.InitializeATSCU(ATSCU, ATOrganizationCode);
    end;

    local procedure CreateATCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; POSUnitNo: Code[10]; ATSCUCode: Code[20])
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        if ATCashRegister.Get(POSUnitNo) then
            ATCashRegister.Delete();

        ATFiscalLibrary.CreateATCashRegister(ATCashRegister, POSUnitNo);
        ATCashRegister.Validate("AT SCU Code", ATSCUCode);
        ATCashRegister.Modify(true);
    end;

    local procedure CreateATCashRegisterAtFiskaly(var ATCashRegister: Record "NPR AT Cash Register"; POSUnitNo: Code[10]; ATSCUCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        if ATCashRegister.Get(POSUnitNo) then
            ATCashRegister.Delete();

        ATFiscalLibrary.CreateATCashRegister(ATCashRegister, POSUnitNo);
        ATCashRegister.Validate("AT SCU Code", ATSCUCode);
        ATCashRegister.Validate(State, ATCashRegister.State::CREATED);
        ATCashRegister.Validate("Serial Number", LibraryUtility.GenerateRandomAlphabeticText(10, 1));
        ATCashRegister.Validate("Created At", CurrentDateTime());
        ATCashRegister.Modify(true);
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

            Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); // Clean between tests
        Commit();
    end;
}