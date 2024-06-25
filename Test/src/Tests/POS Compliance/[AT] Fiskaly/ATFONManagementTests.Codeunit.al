codeunit 85194 "NPR AT FON Management Tests"
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
    procedure AuthenticateFON()
    var
        ATOrganization: Record "NPR AT Organization";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ATOrganizationNotAuthenticatedErr: Label 'AT Organization is not authenticated.', Locked = true;
    begin
        // [SCENARIO] Checks authenticate with FinanzOnline with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] FinanzOnline credentials are set on AT Fiscalization Setup
        SetFinanzOnlineCredentials();

        // [GIVEN] AT Organization exists
        ATFiscalLibrary.CreateATOrganization(ATOrganization);

        // [WHEN] Authenticating AT Organization with FinanzOnline
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.AuthenticateFON(ATOrganization);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] AT Organization is authenticated with FinanzOnline
        Assert.AreEqual(ATOrganization."FON Authentication Status", ATOrganization."FON Authentication Status"::AUTHENTICATED, ATOrganizationNotAuthenticatedErr);
        Assert.IsTrue(ATOrganization."FON Authenticated At" <> 0DT, ATOrganizationNotAuthenticatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveFONStatus()
    var
        ATOrganization: Record "NPR AT Organization";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        FinanzOnlineStatusOfATOrganizationNotRetrievedErr: Label 'FinanzOnline status of AT Organization is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieve FinanzOnline status with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] AT Organization exists
        ATFiscalLibrary.CreateATOrganization(ATOrganization);

        // [WHEN] Retrieving FinanzOnline status of AT Organization
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.RetrieveFONStatus(ATOrganization);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] FinanzOnline status of AT Organization is retrieved
        Assert.AreEqual(ATOrganization."FON Authentication Status", ATOrganization."FON Authentication Status"::AUTHENTICATED, FinanzOnlineStatusOfATOrganizationNotRetrievedErr);
        Assert.IsTrue(ATOrganization."FON Authenticated At" <> 0DT, FinanzOnlineStatusOfATOrganizationNotRetrievedErr);
    end;

    local procedure SetFinanzOnlineCredentials()
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATSecretMgt: Codeunit "NPR AT Secret Mgt.";
    begin
        ATFiscalizationSetup.Get();
        ATSecretMgt.SetSecretKey(ATFiscalizationSetup.GetFONParticipantId(), 'mockdata123');
        ATSecretMgt.SetSecretKey(ATFiscalizationSetup.GetFONUserId(), 'mock-data');
        ATSecretMgt.SetSecretKey(ATFiscalizationSetup.GetFONUserPIN(), 'mock-data2');
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