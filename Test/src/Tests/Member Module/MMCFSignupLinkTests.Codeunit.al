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
        _WelcomeSetupCodeTok: Label 'CFWELCOME', Locked = true;
        _SetupTemplateTok: Label 'WELCOME-FROM-SETUP', Locked = true;
        _LegacyEmailTemplateTok: Label 'LEGACYWLC', Locked = true;
        _NPEmailTemplateTok: Label 'NPEMAIL-WELCOME-0001', Locked = true;
        _UpgSignupTok: Label 'UPGSIGNUP', Locked = true;
        _UpgOtherTok: Label 'UPGOTHER', Locked = true;
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

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure WelcomeEntryKeepsSetupTemplateWithoutNPEmailTemplate()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberNotification: Codeunit "NPR MM Member Notification";
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        MemberEntryNo: Integer;
    begin
        // [SCENARIO] With the new e-mail experience on and no NP e-mail template on the registration setup, the signup entry keeps the welcome notification's template
        // [GIVEN] The new e-mail experience is on and the registration setup has only an old e-mail template
        Initialize();
        PrepareResponse(201, StrSubstNo('{"url":"%1","code":"%2"}', _WorkerBaseUrlTok + '/s/' + _ShortCodeTok, _ShortCodeTok));
        NewEmailExperienceFeature.SetFeatureEnabled(true);
        AzureRegistrationSetup.Get(_SetupCodeTok);
        AzureRegistrationSetup.EmailTemplate := _LegacyEmailTemplateTok;
        AzureRegistrationSetup.Modify();
        // [GIVEN] A member signed up on a membership item that uses the registration setup
        CreateSignupWelcomeNotification(MembershipNotification, MemberEntryNo);

        // [WHEN] The welcome notification is handled
        MemberNotification.HandleMembershipNotification(MembershipNotification);

        // [THEN] The member's notification entry carries the welcome notification's template
        MemberNotificationEntry.Get(MembershipNotification."Entry No.", MemberEntryNo);
        _Assert.AreEqual(_SetupTemplateTok, MemberNotificationEntry."Template Filter Value", 'A blank NP E-mail Template must not replace the template of the welcome notification.');
    end;

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure WelcomeEntryUsesNPEmailTemplate()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberNotification: Codeunit "NPR MM Member Notification";
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        MemberEntryNo: Integer;
    begin
        // [SCENARIO] With the new e-mail experience on, the signup entry carries the NP e-mail template of the registration setup
        // [GIVEN] The new e-mail experience is on and the registration setup has an old e-mail template and a 20-character NP e-mail template
        Initialize();
        PrepareResponse(201, StrSubstNo('{"url":"%1","code":"%2"}', _WorkerBaseUrlTok + '/s/' + _ShortCodeTok, _ShortCodeTok));
        NewEmailExperienceFeature.SetFeatureEnabled(true);
        AzureRegistrationSetup.Get(_SetupCodeTok);
        AzureRegistrationSetup.EmailTemplate := _LegacyEmailTemplateTok;
        AzureRegistrationSetup.NPEmailTemplate := _NPEmailTemplateTok;
        AzureRegistrationSetup.Modify();
        // [GIVEN] A member signed up on a membership item that uses the registration setup
        CreateSignupWelcomeNotification(MembershipNotification, MemberEntryNo);

        // [WHEN] The welcome notification is handled
        MemberNotification.HandleMembershipNotification(MembershipNotification);

        // [THEN] The member's notification entry carries the NP e-mail template
        MemberNotificationEntry.Get(MembershipNotification."Entry No.", MemberEntryNo);
        _Assert.AreEqual(_NPEmailTemplateTok, MemberNotificationEntry."Template Filter Value", 'With the new e-mail experience on, the signup entry must carry the NP E-mail Template of the registration setup.');
    end;

    [Test]
    [HandlerFunctions('AnswerSignupRequest')]
    procedure WelcomeEntryKeepsOldTemplateWhenWalletIsSentSeparately()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberNotification: Codeunit "NPR MM Member Notification";
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        MemberEntryNo: Integer;
    begin
        // [SCENARIO] When the wallet goes out in its own welcome e-mail and no NP e-mail template is set, the signup entry keeps the old template instead of repeating the welcome template
        // [GIVEN] The new e-mail experience is on and the registration setup allows an anonymous wallet and has only an old e-mail template
        Initialize();
        PrepareResponse(201, StrSubstNo('{"url":"%1","code":"%2"}', _WorkerBaseUrlTok + '/s/' + _ShortCodeTok, _ShortCodeTok));
        NewEmailExperienceFeature.SetFeatureEnabled(true);
        AzureRegistrationSetup.Get(_SetupCodeTok);
        AzureRegistrationSetup.EmailTemplate := _LegacyEmailTemplateTok;
        AzureRegistrationSetup.AllowAnonymousWallet := true;
        AzureRegistrationSetup.Modify();
        // [GIVEN] A member signed up on a membership item that uses the registration setup, so the welcome notification is split into a signup and a wallet notification
        CreateSignupWelcomeNotification(MembershipNotification, MemberEntryNo);

        // [WHEN] The signup welcome notification is handled
        MemberNotification.HandleMembershipNotification(MembershipNotification);

        // [THEN] The signup entry carries the old e-mail template, as before this change
        MemberNotificationEntry.Get(MembershipNotification."Entry No.", MemberEntryNo);
        _Assert.AreEqual(_LegacyEmailTemplateTok, MemberNotificationEntry."Template Filter Value", 'With the wallet in its own e-mail, a blank NP E-mail Template must not make the signup e-mail repeat the welcome template.');
    end;

    [Test]
    procedure UpgradeCopiesOnlyMemberNotificationNPEmailTemplates()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        UPGMMSignupNPEmail: Codeunit "NPR UPG MM Signup NP Email";
    begin
        // [SCENARIO] The upgrade copies the old e-mail template into the NP e-mail template only when it names an NP member notification template
        // [GIVEN] One setup whose old template code is an NP member notification template, and one whose code is an NP template of another data provider
        CreateNPEmailTemplate(_UpgSignupTok, "NPR DynTemplateDataProvider"::MEMBER_NOTIFICATION);
        CreateNPEmailTemplate(_UpgOtherTok, "NPR DynTemplateDataProvider"::TICKET_NOTIFICATION);
        CreateSetupWithOldEmailTemplate(_UpgSignupTok);
        CreateSetupWithOldEmailTemplate(_UpgOtherTok);

        // [WHEN] The upgrade step runs
        UPGMMSignupNPEmail.CopySignupNPEmailTemplates();

        // [THEN] Only the setup that points at a member notification template gets it as NP e-mail template
        AzureRegistrationSetup.Get(_UpgSignupTok);
        _Assert.AreEqual(_UpgSignupTok, AzureRegistrationSetup.NPEmailTemplate, 'An old template code that is also an NP member notification template must be copied.');
        AzureRegistrationSetup.Get(_UpgOtherTok);
        _Assert.AreEqual('', AzureRegistrationSetup.NPEmailTemplate, 'An old template code whose NP template has another data provider must not be copied.');
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

    local procedure CreateSignupWelcomeNotification(var MembershipNotification: Record "NPR MM Membership Notific."; var MemberEntryNo: Integer)
    var
        MemberItem: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        Membership: Record "NPR MM Membership";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        MembershipCode: Code[20];
        LoyaltyProgramCode: Code[20];
        MembershipEntryNo: Integer;
        ApiStatus: Boolean;
        ResponseMessage: Text;
    begin
        MemberLibrary.Initialize();
        LibraryInventory.CreateItem(MemberItem);
        MembershipCode := MemberLibrary.GenerateCode20();
        MemberCommunity.Get(MemberLibrary.SetupCommunity_Simple());
        MemberLibrary.SetupMembership_Simple(MemberCommunity.Code, MembershipCode, LoyaltyProgramCode, 'Signup welcome');
        MemberLibrary.SetupSimpleMembershipSalesItem(MemberItem."No.", MembershipCode);
        MemberLibrary.SetupWelcomeNotification(_WelcomeSetupCodeTok, MemberCommunity.Code, MembershipCode);

        NotificationSetup.Get(_WelcomeSetupCodeTok);
        NotificationSetup."Template Filter Value" := _SetupTemplateTok;
        NotificationSetup.Modify();

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberItem."No.");
        MembershipSalesSetup.AzureMemberRegSetupCode := _SetupCodeTok;
        MembershipSalesSetup.Modify();

        ApiStatus := MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);
        _Assert.IsTrue(ApiStatus, ResponseMessage);
        Membership.Get(MembershipEntryNo);
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        ApiStatus := MemberApiLibrary.AddMembershipMember(Membership, MemberInfoCapture, MemberEntryNo, ResponseMessage);
        _Assert.IsTrue(ApiStatus, ResponseMessage);

        MembershipNotification.SetRange("Membership Entry No.", MembershipEntryNo);
        MembershipNotification.SetRange("Member Entry No.", MemberEntryNo);
        MembershipNotification.SetRange("Notification Trigger", MembershipNotification."Notification Trigger"::WELCOME);
        MembershipNotification.SetRange(AzureRegistrationSetupCode, _SetupCodeTok);
        MembershipNotification.FindFirst();
    end;

    local procedure CreateNPEmailTemplate(TemplateId: Code[20]; DataProvider: Enum "NPR DynTemplateDataProvider")
    var
        NPEmailTemplate: Record "NPR NPEmailTemplate";
    begin
        if (NPEmailTemplate.Get(TemplateId)) then
            NPEmailTemplate.Delete();

        NPEmailTemplate.Init();
        NPEmailTemplate.TemplateId := TemplateId;
        NPEmailTemplate.DataProvider := DataProvider;
        NPEmailTemplate.Insert();
    end;

    local procedure CreateSetupWithOldEmailTemplate(SetupCode: Code[10])
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
    begin
        if (AzureRegistrationSetup.Get(SetupCode)) then
            AzureRegistrationSetup.Delete();

        AzureRegistrationSetup.Init();
        AzureRegistrationSetup.AzureRegistrationSetupCode := SetupCode;
        AzureRegistrationSetup.EmailTemplate := SetupCode;
        AzureRegistrationSetup.Insert();
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
