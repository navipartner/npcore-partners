codeunit 85470 "NPR Azure Key Vault Mgt. Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _WrongModuleErr: Label 'This procedure cannot be called from another application.', Locked = true;
        _AttackerUrlTok: Label 'https://attacker.example.com', Locked = true;
        _CityCodeTok: Label 'KVTEST', Locked = true;
        _LocationCodeTok: Label 'KVLOC', Locked = true;
        _NotificationCodeTok: Label 'KVT-WC', Locked = true;
        _ShopifyStoreCodeTok: Label 'KVSPFY', Locked = true;
        _GraphEMailTok: Label 'kvtest@example.com', Locked = true;
        _CapturedUrl: Text;
        _CapturedCode: Text;
        _InjectedSecretNames: List of [Text];

    [Test]
    procedure DirectGetterRejectsExternalCaller()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        ErrorText: Text;
    begin
        // The test app has internalsVisibleTo access, but is still a different module.
        ClearLastError();
        asserterror AzureKeyVaultMgt.GetAzureKeyVaultSecret('CallerValidationTest');
        ErrorText := GetLastErrorText();

        _Assert.AreEqual(_WrongModuleErr, ErrorText, 'The direct getter must reject the test app.');
    end;

    [Test]
    procedure TryGetterRejectsExternalCaller()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        SecretValue: Text;
        ErrorText: Text;
        Success: Boolean;
    begin
        SecretValue := 'unchanged';

        ClearLastError();
        Success := AzureKeyVaultMgt.TryGetAzureKeyVaultSecret('CallerValidationTest', SecretValue);
        ErrorText := GetLastErrorText();

        _Assert.IsFalse(Success, 'The try getter must reject the test app.');
        _Assert.AreEqual(_WrongModuleErr, ErrorText, 'Both entry points must reject the caller for the same reason.');
        _Assert.AreEqual('unchanged', SecretValue, 'A rejected call must not assign the secret to the output.');
    end;

    [Test]
    procedure TryGetterWithoutReturnValueRejectsExternalCaller()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        SecretValue: Text;
        ErrorText: Text;
    begin
        ClearLastError();
        asserterror AzureKeyVaultMgt.TryGetAzureKeyVaultSecret('CallerValidationTest', SecretValue);
        ErrorText := GetLastErrorText();

        _Assert.AreEqual(_WrongModuleErr, ErrorText, 'Ignoring the try return value must still reject the caller.');
        _Assert.AreEqual('', SecretValue, 'A rejected call must not return the secret.');
    end;

    [Test]
    [HandlerFunctions('CaptureRequestAndFail')]
    procedure FtpRequestIgnoresInjectedAddress()
    var
        AFFTPClient: Codeunit "NPR AF FTP Client";
    begin
        Initialize();
        InjectSecret('FtpAzureFunctionUrl', _AttackerUrlTok + '/api/');
        InjectSecret('FtpAzureFunction', 'test-code');

        AFFTPClient.Construct('ftp.example.com', 'user', 'password', 21, 1000, true, Enum::"NPR Nc FTP Encryption mode"::None, false);
        AFFTPClient.ListDirectory('/');
        RemoveInjectedSecrets();

        _Assert.IsTrue(_CapturedUrl.StartsWith('https://ftpaf.azurewebsites.net/api/ListDirectory'), StrSubstNo('The FTP request went to %1 instead of the fixed FTP address.', _CapturedUrl));
        _Assert.AreNotEqual('', _CapturedCode, 'The FTP function code from the Key Vault must be sent with the request.');
        _Assert.IsFalse(_CapturedCode.Contains('://'), 'The FTP code must be the function code, not an address from an old Key Vault entry.');
    end;

    [Test]
    [HandlerFunctions('CaptureRequestAndFail')]
    procedure DocLXValidationIgnoresInjectedAddress()
    var
        DocLXCityCard: Codeunit "NPR DocLXCityCard";
        EntryNo: Integer;
    begin
        Initialize();
        CreateDocLXSetup();
        InjectSecret('DocLXCityCardCopenhagenDemoHost', 'host.example.com');
        InjectSecret('DocLXCityCardCopenhagenDemoCipherKey', 'test-cipher-key');
        InjectSecret('DocLXCityCardProxyUrl', _AttackerUrlTok + '/api/cityCard?code=attacker');
        InjectSecret('DocLXCityCardProxyUrlCode', 'test-code');

        DocLXCityCard.ValidateCityCard('KV-CARD-1', _CityCodeTok, _LocationCodeTok, '', EntryNo);
        RemoveInjectedSecrets();

        _Assert.IsTrue(_CapturedUrl.StartsWith('https://npdoclxcitycardapi.azurewebsites.net/api/cityCard'), StrSubstNo('The DocLX validation request went to %1 instead of the fixed DocLX address.', _CapturedUrl));
        _Assert.AreNotEqual('', _CapturedCode, 'The DocLX function code from the Key Vault must be sent with the validation request.');
        _Assert.IsFalse(_CapturedCode.Contains('://'), 'The DocLX code must be the function code, not an address from the old DocLXCityCardProxyUrl entry.');
    end;

    [Test]
    [HandlerFunctions('CaptureRequestAndSucceed')]
    procedure DocLXHealthCheckIgnoresInjectedAddress()
    var
        DocLXCityCard: Codeunit "NPR DocLXCityCard";
        Result: JsonObject;
        HelloUrlToken: JsonToken;
    begin
        Initialize();
        CreateDocLXSetup();
        InjectSecret('DocLXCityCardCopenhagenDemoHost', 'host.example.com');
        InjectSecret('DocLXCityCardHelloUrl', _AttackerUrlTok + '/api/hello?code=attacker');
        InjectSecret('DocLXCityCardHelloUrlCode', 'test-code');

        Result := DocLXCityCard.CheckServiceHealth(_CityCodeTok);
        RemoveInjectedSecrets();

        _Assert.IsTrue(_CapturedUrl.StartsWith('https://npdoclxcitycardapi.azurewebsites.net/api/hello'), StrSubstNo('The DocLX health check went to %1 instead of the fixed DocLX address.', _CapturedUrl));
        _Assert.AreNotEqual('', _CapturedCode, 'The DocLX function code from the Key Vault must be sent with the health check.');
        _Assert.IsFalse(_CapturedCode.Contains('://'), 'The DocLX code must be the function code, not an address from the old DocLXCityCardHelloUrl entry.');
        _Assert.IsTrue(Result.SelectToken('request.helloUrl', HelloUrlToken), 'The health check result must include the hello address.');
        _Assert.AreEqual('https://npdoclxcitycardapi.azurewebsites.net/api/hello', HelloUrlToken.AsValue().AsText(), 'The health check result is shown to the user and must not include the function code.');
    end;

    [Test]
    [HandlerFunctions('CaptureRequestAndFail')]
    procedure ServiceLibraryIgnoresInjectedAddress()
    var
        NaviPartnerSendSMS: Codeunit "NPR NaviPartner Send SMS";
    begin
        Initialize();
        EnsureSMSSetup();
        InjectSecret('ApiHostUri', _AttackerUrlTok);
        InjectSecret('ServiceLibraryKey', 'test-key');
        Commit();

        asserterror NaviPartnerSendSMS.SendSMS('+4512345678', '12345678', 'Test message');
        RemoveInjectedSecrets();

        _Assert.IsTrue(_CapturedUrl.StartsWith('https://api.navipartner.dk/servicelibrary'), StrSubstNo('The service library request went to %1 instead of the fixed service library address.', _CapturedUrl));
    end;

    [Test]
    procedure NPPassDemoDataIgnoresInjectedAddress()
    var
        MemberNotificationSetup: Record "NPR MM Member Notific. Setup";
        MemberCreateDemoData: Codeunit "NPR MM Member Create Demo Data";
    begin
        Initialize();
        InjectSecret('PassesServerBaseUrl', _AttackerUrlTok + '/api/v1');
        InjectSecret('PassesToken', 'test-token');

        MemberCreateDemoData.SetupWalletNotification(_NotificationCodeTok, 'RIVERLAND', '', 0);
        RemoveInjectedSecrets();

        MemberNotificationSetup.Get(_NotificationCodeTok);
        _Assert.AreEqual('https://passes.npecommerce.dk/api/v1', MemberNotificationSetup."NP Pass Server Base URL", 'Create Demo Data must fill in the fixed NP Pass address.');
        MemberNotificationSetup.Delete();
    end;

    [Test]
    procedure ShopifyRequestRefusesAddressOutsideMyshopify()
    var
        ShopifyStore: Record "NPR Spfy Store";
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
    begin
        Initialize();
        CreateShopifyStore(_AttackerUrlTok);

        NcTask."Store Code" := _ShopifyStoreCodeTok;
        ClearLastError();
        _Assert.IsFalse(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse), 'A Shopify request to an address outside myshopify.com must fail.');
        ShopifyStore.Get(_ShopifyStoreCodeTok);
        ShopifyStore.Delete(false);

        _Assert.IsTrue(GetLastErrorText().Contains('myshopify.com'), StrSubstNo('The request must be refused before it is sent, with the address rule as the error. Got: %1', GetLastErrorText()));
    end;

    [Test]
    procedure GraphTokenRefreshRefusesAddressOutsideMicrosoft()
    var
        EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail";
        GraphAPIManagement: Codeunit "NPR Graph API Management";
    begin
        Initialize();
        CreateGraphApiSetup(_AttackerUrlTok + '/common/oauth2/v2.0/token');
        CreateExpiredExchangeEMail();

        EventExchIntEMail."E-Mail" := _GraphEMailTok;
        ClearLastError();
        asserterror GraphAPIManagement.TestConnection(EventExchIntEMail);

        _Assert.IsTrue(GetLastErrorText().Contains('login.microsoftonline.com'), StrSubstNo('The token refresh must be refused before it is sent, with the address rule as the error. Got: %1', GetLastErrorText()));
    end;

    [HttpClientHandler]
    procedure CaptureRequestAndFail(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        CaptureRequest(Request.Path(), Request.QueryParameters());
        Response.HttpStatusCode := 500;
        Response.ReasonPhrase := 'Blocked by test';
        exit(false);
    end;

    [HttpClientHandler]
    procedure CaptureRequestAndSucceed(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        CaptureRequest(Request.Path(), Request.QueryParameters());
        Response.Content.WriteFrom('{}');
        Response.HttpStatusCode := 200;
        Response.ReasonPhrase := 'OK';
        exit(false);
    end;

    local procedure CaptureRequest(Path: Text; QueryParameters: Dictionary of [Text, Text])
    begin
        if _CapturedUrl <> '' then
            exit;
        _CapturedUrl := Path;
        if QueryParameters.ContainsKey('code') then
            _CapturedCode := QueryParameters.Get('code');
    end;

    local procedure Initialize()
    begin
        _CapturedUrl := '';
        _CapturedCode := '';
        RemoveInjectedSecrets();
    end;

    local procedure CreateShopifyStore(ShopifyUrl: Text)
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if ShopifyStore.Get(_ShopifyStoreCodeTok) then
            ShopifyStore.Delete(false);
        ShopifyStore.Init();
        ShopifyStore.Code := _ShopifyStoreCodeTok;
        ShopifyStore."Shopify Url" := CopyStr(ShopifyUrl, 1, MaxStrLen(ShopifyStore."Shopify Url"));
        ShopifyStore."Shopify Access Token" := 'test-token';
        ShopifyStore.Insert();
    end;

    local procedure CreateGraphApiSetup(OAuthTokenUrl: Text)
    var
        GraphApiSetup: Record "NPR GraphApi Setup";
    begin
        if GraphApiSetup.Get() then
            GraphApiSetup.Delete();
        GraphApiSetup.Init();
        GraphApiSetup."Client Id" := 'test-client-id';
        GraphApiSetup."Client Secret" := 'test-client-secret';
        GraphApiSetup."OAuth Authority Url" := 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
        GraphApiSetup."OAuth Token Url" := CopyStr(OAuthTokenUrl, 1, MaxStrLen(GraphApiSetup."OAuth Token Url"));
        GraphApiSetup."Graph Event Url" := 'https://graph.microsoft.com/v1.0/me/events/';
        GraphApiSetup."Graph Me Url" := 'https://graph.microsoft.com/v1.0/me';
        GraphApiSetup.Insert();
    end;

    local procedure CreateExpiredExchangeEMail()
    var
        EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail";
        OutStr: OutStream;
    begin
        if EventExchIntEMail.Get(_GraphEMailTok) then
            EventExchIntEMail.Delete();
        EventExchIntEMail.Init();
        EventExchIntEMail."E-Mail" := _GraphEMailTok;
        EventExchIntEMail."Time Zone No." := 1;
        EventExchIntEMail."Access Token".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText('expired-access-token');
        EventExchIntEMail."Refresh Token".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText('test-refresh-token');
        EventExchIntEMail."Acces Token Valid Until" := CurrentDateTime() - 60000;
        EventExchIntEMail.Insert();
    end;

    local procedure InjectSecret(SecretName: Text; SecretValue: Text)
    var
        SandboxSecretInjection: Codeunit "NPR Sandbox Secret Injection";
    begin
        SandboxSecretInjection.AddSecret(SecretName, SecretValue);
        if not _InjectedSecretNames.Contains(SecretName) then
            _InjectedSecretNames.Add(SecretName);
    end;

    local procedure RemoveInjectedSecrets()
    var
        SandboxSecretInjection: Codeunit "NPR Sandbox Secret Injection";
        SecretName: Text;
        SecretValue: Text;
    begin
        foreach SecretName in _InjectedSecretNames do
            if SandboxSecretInjection.TryGetSecret(SecretName, SecretValue) then
                SandboxSecretInjection.RemoveSecret(SecretName);
        Clear(_InjectedSecretNames);
    end;

    local procedure CreateDocLXSetup()
    var
        CityCardSetup: Record "NPR DocLXCityCardSetup";
        CityCardLocation: Record "NPR DocLXCityCardLocation";
    begin
        if CityCardSetup.Get(_CityCodeTok) then
            CityCardSetup.Delete();
        CityCardSetup.Init();
        CityCardSetup.Code := _CityCodeTok;
        CityCardSetup.City := Enum::"NPR DocLXCities"::COPENHAGEN;
        CityCardSetup.Environment := CityCardSetup.Environment::DEMO;
        CityCardSetup.Insert();

        if CityCardLocation.Get(_CityCodeTok, _LocationCodeTok) then
            CityCardLocation.Delete();
        CityCardLocation.Init();
        CityCardLocation.CityCode := _CityCodeTok;
        CityCardLocation.Code := _LocationCodeTok;
        CityCardLocation.CityCardLocationId := 1;
        CityCardLocation.CouponSelection := CityCardLocation.CouponSelection::ITEM;
        CityCardLocation.Insert();
    end;

    local procedure EnsureSMSSetup()
    var
        SMSSetup: Record "NPR SMS Setup";
    begin
        if not SMSSetup.Get() then begin
            SMSSetup.Init();
            SMSSetup.Insert();
        end;
    end;
}
