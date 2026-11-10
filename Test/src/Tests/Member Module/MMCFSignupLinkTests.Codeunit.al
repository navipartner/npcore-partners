codeunit 85596 "NPR MM CF Signup Link Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _SetupCodeTok: Label 'CFLINKTEST', Locked = true;
        _WorkerBaseUrlTok: Label 'https://member-signup.npretail-prelive.app', Locked = true;
        _LegacyUrlTok: Label 'https://legacy-signup.example.com', Locked = true;
        _TermsUrlTok: Label 'https://example.com/terms', Locked = true;
        _QueueNameTok: Label 'test-slug', Locked = true;
        _DataSubjectIdTok: Label '59C202B21F6A41AFBEC569D7DBDC8A2E', Locked = true;
        _ShortCodeTok: Label 'AbCdEfGhIjKlMnOp', Locked = true;
        _ApiKeySecretNameTok: Label 'MM-CFSignUp-ApiKey', Locked = true;
        _ForeignUrlTok: Label 'https://attacker.example.com/s/AbCdEfGhIjKlMnOp', Locked = true;
        _WorkerErrorTok: Label 'Tenant or company does not match the instance', Locked = true;
        _CapturedPath: Text;
        _ResponseStatusCode: Integer;
        _ResponseBody: Text;

    [Test]
    procedure RegistrationBodyCarriesPrefill()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        CFMemberRegistration: Codeunit "NPR MM CFMemberRegistration";
        RequestJson: JsonObject;
    begin
        Initialize();
        AzureRegistrationSetup.Get(_SetupCodeTok);

        RequestJson := CFMemberRegistration.BuildSignupRequestBody(AzureRegistrationSetup, _DataSubjectIdTok, 'Anna', '+4512345678');

        _Assert.AreEqual(_QueueNameTok, GetText(RequestJson, 'queueName'), 'queueName must be the setup partition key.');
        _Assert.AreEqual(_DataSubjectIdTok, GetText(RequestJson, 'dataSubjectId'), 'dataSubjectId must be the entry data subject id.');
        _Assert.AreEqual(CompanyName(), GetText(RequestJson, 'companyName'), 'companyName must be the current company.');
        _Assert.AreEqual('Anna', GetText(RequestJson, 'prefill.firstName'), 'prefill.firstName must be the entry first name.');
        _Assert.AreEqual('+4512345678', GetText(RequestJson, 'prefill.phoneNumber'), 'prefill.phoneNumber must be the entry phone number.');
        _Assert.AreEqual(_TermsUrlTok, GetText(RequestJson, 'prefill.tos'), 'prefill.tos must be the setup terms of service url.');
    end;

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure RegistrationStoresShortLink()
    var
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        AzureMemberRegistration: Codeunit "NPR MM AzureMemberRegistration";
        ShortUrl: Text;
    begin
        Initialize();
        ShortUrl := _WorkerBaseUrlTok + '/s/' + _ShortCodeTok;
        PrepareResponse(201, StrSubstNo('{"url":"%1","code":"%2"}', ShortUrl, _ShortCodeTok));
        CreateNotificationEntry(MemberNotificationEntry);

        _Assert.IsTrue(AzureMemberRegistration.CreateMemberSignUpReference(MemberNotificationEntry), 'Registration must succeed when the Worker answers 201 with a short link.');

        _Assert.AreEqual(ShortUrl, MemberNotificationEntry.ClientSignUpUrl, 'The short link returned by the Worker must be stored on the notification entry.');
        _Assert.IsTrue(_CapturedPath.EndsWith('/internal/signup-requests'), 'The registration must be posted to the signup-requests route.');
    end;

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure RegistrationWithNullLinkFallsBackToLegacyLink()
    var
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        AzureMemberRegistration: Codeunit "NPR MM AzureMemberRegistration";
    begin
        Initialize();
        PrepareResponse(200, '{"url":null,"code":null}');
        CreateNotificationEntry(MemberNotificationEntry);

        _Assert.IsTrue(AzureMemberRegistration.CreateMemberSignUpReference(MemberNotificationEntry), 'A null url must not fail the registration.');

        _Assert.IsTrue(MemberNotificationEntry.ClientSignUpUrl.StartsWith(_LegacyUrlTok), StrSubstNo('A null url must fall back to the legacy link. Got %1', MemberNotificationEntry.ClientSignUpUrl));
    end;

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure RegistrationWithoutShortLinkFallsBackToLegacyLink()
    var
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        AzureMemberRegistration: Codeunit "NPR MM AzureMemberRegistration";
        ExpectedPrefix: Text;
    begin
        Initialize();
        PrepareResponse(200, '');
        CreateNotificationEntry(MemberNotificationEntry);

        _Assert.IsTrue(AzureMemberRegistration.CreateMemberSignUpReference(MemberNotificationEntry), 'Registration must succeed when an older Worker answers without a body.');

        ExpectedPrefix := StrSubstNo('%1?PartitionKey=%2&RowKey=%3&data=', _LegacyUrlTok, _QueueNameTok, _DataSubjectIdTok);
        _Assert.IsTrue(MemberNotificationEntry.ClientSignUpUrl.StartsWith(ExpectedPrefix), StrSubstNo('Without a short link the entry must fall back to the legacy link. Got %1', MemberNotificationEntry.ClientSignUpUrl));
        _Assert.IsTrue(StrLen(MemberNotificationEntry.ClientSignUpUrl) > StrLen(ExpectedPrefix), 'The legacy link must carry the base64 member data.');
    end;

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure RegistrationRejectsShortLinkOnForeignHost()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        CFMemberRegistration: Codeunit "NPR MM CFMemberRegistration";
        SignupUrl: Text;
    begin
        Initialize();
        PrepareResponse(201, StrSubstNo('{"url":"%1","code":"%2"}', _ForeignUrlTok, _ShortCodeTok));
        AzureRegistrationSetup.Get(_SetupCodeTok);

        ClearLastError();
        _Assert.IsFalse(CFMemberRegistration.CreateSignupReference(AzureRegistrationSetup, _DataSubjectIdTok, 'Anna', '+4512345678', SignupUrl), 'A short link outside the Worker host must be rejected.');

        _Assert.IsTrue(GetLastErrorText().Contains('attacker.example.com'), StrSubstNo('The error must name the rejected link. Got: %1', GetLastErrorText()));
        _Assert.AreEqual('', SignupUrl, 'A rejected link must not be returned.');
    end;

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure RegistrationFailureCarriesWorkerError()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        CFMemberRegistration: Codeunit "NPR MM CFMemberRegistration";
        SignupUrl: Text;
    begin
        Initialize();
        PrepareResponse(422, StrSubstNo('{"error":"%1"}', _WorkerErrorTok));
        AzureRegistrationSetup.Get(_SetupCodeTok);

        ClearLastError();
        _Assert.IsFalse(CFMemberRegistration.CreateSignupReference(AzureRegistrationSetup, _DataSubjectIdTok, 'Anna', '+4512345678', SignupUrl), 'A non-2xx answer must fail the registration.');

        _Assert.IsTrue(GetLastErrorText().Contains('422'), StrSubstNo('The error must carry the status code. Got: %1', GetLastErrorText()));
        _Assert.IsTrue(GetLastErrorText().Contains(_WorkerErrorTok), StrSubstNo('The error must carry the Worker error text. Got: %1', GetLastErrorText()));
    end;

    [HttpClientHandler]
    procedure AnswerSignupRequest(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        _CapturedPath := Request.Path();

        Response.HttpStatusCode := _ResponseStatusCode;
        Response.Content.WriteFrom(_ResponseBody);
        exit(false);
    end;

    local procedure Initialize()
    var
        SandboxSecretInjection: Codeunit "NPR Sandbox Secret Injection";
    begin
        _CapturedPath := '';
        SandboxSecretInjection.AddSecret(_ApiKeySecretNameTok, 'test-api-key');
        CreateCloudflareSetup();
    end;

    local procedure PrepareResponse(StatusCode: Integer; Body: Text)
    begin
        _ResponseStatusCode := StatusCode;
        _ResponseBody := Body;
    end;

    local procedure CreateCloudflareSetup()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
    begin
        if (AzureRegistrationSetup.Get(_SetupCodeTok)) then
            AzureRegistrationSetup.Delete();

        AzureRegistrationSetup.Init();
        AzureRegistrationSetup.AzureRegistrationSetupCode := _SetupCodeTok;
        AzureRegistrationSetup.Provider := AzureRegistrationSetup.Provider::Cloudflare;
        AzureRegistrationSetup.QueueName := _QueueNameTok;
        AzureRegistrationSetup.CFWorkerBaseUrl := _WorkerBaseUrlTok;
        AzureRegistrationSetup.MemberRegistrationUrl := _LegacyUrlTok;
        AzureRegistrationSetup.TermsOfServiceUrl := _TermsUrlTok;
        AzureRegistrationSetup.Enabled := true;
        AzureRegistrationSetup.Insert();
    end;

    local procedure CreateNotificationEntry(var MemberNotificationEntry: Record "NPR MM Member Notific. Entry")
    begin
        MemberNotificationEntry.Init();
        MemberNotificationEntry.AzureRegistrationSetupCode := _SetupCodeTok;
        MemberNotificationEntry.DataSubjectId := _DataSubjectIdTok;
        MemberNotificationEntry."First Name" := 'Anna';
        MemberNotificationEntry."Phone No." := '+4512345678';
    end;

    local procedure GetText(Json: JsonObject; Path: Text): Text
    var
        Token: JsonToken;
    begin
        if (not Json.SelectToken(Path, Token)) then
            exit('');
        exit(Token.AsValue().AsText());
    end;
}
