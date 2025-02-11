codeunit 85194 "NPR AT FON Management Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
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
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        if Initialized then
            exit;

        ATFiscalLibrary.EnableATFiscalization();
        Initialized := true;
    end;
}