codeunit 6248747 "NPR MM CFMemberRegistration"
{
    Access = Internal;

    var
        _ImageUrlTok: Label '%1/api/images/%2', Locked = true;
        _ImageTokenSecretNameTok: Label 'MM-CFSignUpImage-Token', Locked = true;
        _SignupRequestUrlTok: Label '%1/internal/signup-requests', Locked = true;
        _SignupApiKeySecretNameTok: Label 'MM-CFSignUp-ApiKey', Locked = true;
        _HttpsSchemeTok: Label 'https://', Locked = true;

    [TryFunction]
    internal procedure CreateSignupReference(RegistrationSetup: Record "NPR MM AzureMemberRegSetup"; DataSubjectId: Text[64])
    var
        EnvironmentInformation: Codeunit "Environment Information";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        RequestBody: JsonObject;
        PayloadText: Text;
        UnexpectedResponseCodeErr: Label '%1 [POST] URL:%2', Locked = true;
    begin
        RequestBody.Add('queueName', RegistrationSetup.QueueName);
        RequestBody.Add('dataSubjectId', DataSubjectId);
        RequestBody.Add('tenantId', TenantId());
        RequestBody.Add('companyName', CompanyName());
        RequestBody.Add('environmentName', EnvironmentInformation.GetEnvironmentName());
        RequestBody.Add('aadTenantId', GetAadTenantId());
        RequestBody.WriteTo(PayloadText);

        Content.WriteFrom(PayloadText);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json; charset=utf-8');

        Request.GetHeaders(Headers);
        Headers.Add('x-api-key', GetSignupApiKey());

        Request.Method('POST');
        Request.SetRequestUri(GetSignupRequestUrl(RegistrationSetup));
        Request.Content(Content);

        Client.Timeout(5000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not (Response.HttpStatusCode() in [200, 201])) then
            Error(UnexpectedResponseCodeErr, Response.HttpStatusCode(), GetSignupRequestUrl(RegistrationSetup));
    end;

    [TryFunction]
    internal procedure ValidateWorker(RegistrationSetup: Record "NPR MM AzureMemberRegSetup")
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        ProbeKey: Text[64];
        ImageTokenRejectedErr: Label 'The Worker rejected the image token (HTTP %1) at %2.', Comment = '%1 = HTTP status code, %2 = url';
        ApiKeyRejectedErr: Label 'The Worker rejected the signup API key (HTTP %1) at %2.', Comment = '%1 = HTTP status code, %2 = url';
        UnexpectedStatusErr: Label 'The Worker answered HTTP %1 at %2, expected %3. Check the Cloudflare Worker base URL.', Comment = '%1 = HTTP status code, %2 = url, %3 = expected status code';
    begin
        ProbeKey := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(ProbeKey));

        Request.GetHeaders(Headers);
        Headers.Add('Authorization', GetImageBearerToken());
        Request.Method('DELETE');
        Request.SetRequestUri(GetImageUrl(RegistrationSetup, ProbeKey));
        Client.Timeout(10000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());
        if (Response.HttpStatusCode() in [401, 403]) then
            Error(ImageTokenRejectedErr, Response.HttpStatusCode(), GetImageUrl(RegistrationSetup, ProbeKey));
        if (Response.HttpStatusCode() <> 204) then
            Error(UnexpectedStatusErr, Response.HttpStatusCode(), GetImageUrl(RegistrationSetup, ProbeKey), 204);

        Clear(Request);
        Clear(Response);
        Content.WriteFrom('{}');
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json; charset=utf-8');
        Request.GetHeaders(Headers);
        Headers.Add('x-api-key', GetSignupApiKey());
        Request.Method('POST');
        Request.SetRequestUri(GetSignupRequestUrl(RegistrationSetup));
        Request.Content(Content);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());
        if (Response.HttpStatusCode() in [401, 403]) then
            Error(ApiKeyRejectedErr, Response.HttpStatusCode(), GetSignupRequestUrl(RegistrationSetup));
        if (Response.HttpStatusCode() <> 400) then
            Error(UnexpectedStatusErr, Response.HttpStatusCode(), GetSignupRequestUrl(RegistrationSetup), 400);
    end;

    internal procedure ValidateWorkerBaseUrl(WorkerBaseUrl: Text)
    var
        Host: Text;
        AllowedHostSuffixes: List of [Text];
        HostSuffix: Text;
        HttpsRequiredErr: Label 'The Cloudflare Worker base URL must start with https://.';
        HostOnlyErr: Label 'The Cloudflare Worker base URL must contain only the scheme and the host name, for example https://member-signup.npretail.app.';
        HostNotAllowedErr: Label 'The host %1 is not a NaviPartner Worker host. Allowed hosts end with %2.', Comment = '%1 = host name, %2 = allowed host suffixes';
    begin
        Host := LowerCase(DelChr(WorkerBaseUrl, '<>', ' '));
        if (not Host.StartsWith(_HttpsSchemeTok)) then
            Error(HttpsRequiredErr);
        Host := Host.Substring(StrLen(_HttpsSchemeTok) + 1);
        Host := DelChr(Host, '>', '/');
        if ((Host = '') or Host.Contains('/') or Host.Contains('@') or Host.Contains('?') or Host.Contains('#') or Host.Contains(':')) then
            Error(HostOnlyErr);

        AllowedHostSuffixes.Add('.npretail.app');
        AllowedHostSuffixes.Add('.npretail.io');
        AllowedHostSuffixes.Add('.npretail-prelive.app');
        AllowedHostSuffixes.Add('.navipartner-prelive.workers.dev');
        foreach HostSuffix in AllowedHostSuffixes do
            if (Host.EndsWith(HostSuffix)) then
                exit;

        Error(HostNotAllowedErr, Host, '.npretail.app, .npretail.io, .npretail-prelive.app, .navipartner-prelive.workers.dev');
    end;

    local procedure GetWorkerBaseUrl(RegistrationSetup: Record "NPR MM AzureMemberRegSetup"): Text
    begin
        ValidateWorkerBaseUrl(RegistrationSetup.CFWorkerBaseUrl);
        exit(DelChr(RegistrationSetup.CFWorkerBaseUrl, '<>', ' /'));
    end;

    local procedure GetAadTenantId(): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if (not EnvironmentInformation.IsSaaS()) then
            exit('');
        exit(AzureADTenant.GetAadTenantId());
    end;

    local procedure GetSignupRequestUrl(RegistrationSetup: Record "NPR MM AzureMemberRegSetup"): Text
    begin
        exit(StrSubstNo(_SignupRequestUrlTok, GetWorkerBaseUrl(RegistrationSetup)));
    end;

    [NonDebuggable]
    local procedure GetSignupApiKey(): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret(_SignupApiKeySecretNameTok));
    end;

    internal procedure ProcessPushedSignup(DataSubjectId: Text[64]; SignupDataB64: Text; SignupId: Text[64]; var FailureReason: Text; var TransientFailure: Boolean): Boolean
    var
        RegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        AzureLog: Record "NPR MM AzureMemberUpdateLog";
        MembershipRole: Record "NPR MM Membership Role";
        AzureMemberRegistration: Codeunit "NPR MM AzureMemberRegistration";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberJson: JsonObject;
        ImageB64: Text;
        LogReason: Text;
        HaveImage: Boolean;
        BlankDataSubjectErr: Label 'The data subject id must not be blank.';
        TooLongDataSubjectErr: Label 'The data subject id %1 exceeds the maximum length of %2.', Comment = '%1 = data subject id, %2 = maximum allowed length';
        NoSetupErr: Label 'No enabled %1 with %2 = %3 was found for data subject %4.', Comment = '%1 = registration setup table caption, %2 = provider field caption, %3 = provider value, %4 = data subject id';
        LinkAlreadyUsedErr: Label 'The signup link for data subject %1 has already been used.', Comment = '%1 = data subject id';
        InvalidPayloadErr: Label 'The signup payload for data subject %1 could not be decoded.', Comment = '%1 = data subject id';
        ImageFetchFailedErr: Label 'The selfie for data subject %1 could not be fetched from the Worker: %2', Comment = '%1 = data subject id, %2 = error text';
        ImageDeleteFailedErr: Label 'The selfie for data subject %1 was applied but could not be deleted from the Worker: %2', Comment = '%1 = data subject id, %2 = error text';
        UpdateFailedErr: Label 'Member update failed for data subject %1.', Comment = '%1 = data subject id';
    begin
        FailureReason := '';
        TransientFailure := false;

        if (DataSubjectId = '') then begin
            FailureReason := BlankDataSubjectErr;
            exit(false);
        end;

        if (StrLen(DataSubjectId) > MaxStrLen(MembershipRole."GDPR Data Subject Id")) then begin
            FailureReason := StrSubstNo(TooLongDataSubjectErr, DataSubjectId, MaxStrLen(MembershipRole."GDPR Data Subject Id"));
            exit(false);
        end;

        if (not FindCloudflareSetup(DataSubjectId, AzureLog, RegistrationSetup)) then begin
            FailureReason := StrSubstNo(
                NoSetupErr,
                RegistrationSetup.TableCaption(),
                RegistrationSetup.FieldCaption(Provider),
                Format(RegistrationSetup.Provider::Cloudflare),
                DataSubjectId);
            exit(false);
        end;

        if (AzureLog.SignupCompleted) then begin
            if ((SignupId <> '') and (AzureLog.SignupId = SignupId)) then
                exit(true);
            FailureReason := StrSubstNo(LinkAlreadyUsedErr, DataSubjectId);
            exit(false);
        end;

        if (not DecodePayload(SignupDataB64, MemberJson)) then begin
            FailureReason := StrSubstNo(InvalidPayloadErr, DataSubjectId);
            exit(false);
        end;

        ClearLastError();
        if (not GetMemberImage(RegistrationSetup, DataSubjectId, ImageB64, HaveImage)) then begin
            FailureReason := StrSubstNo(ImageFetchFailedErr, DataSubjectId, GetLastErrorText());
            TransientFailure := true;
            exit(false);
        end;

        if (not MembershipManagement.UpdateMember(DataSubjectId, MemberJson, ImageB64)) then
            Error(UpdateFailedErr, DataSubjectId);

        if (HaveImage) then
            if (not DeleteMemberImage(RegistrationSetup, DataSubjectId)) then
                LogReason := StrSubstNo(ImageDeleteFailedErr, DataSubjectId, GetLastErrorText());

        AzureMemberRegistration.UpdateReceiveAzureLog(DataSubjectId, MemberJson, HaveImage, ImageB64, LogReason);
        MarkSignupCompleted(AzureLog, SignupId);
        exit(true);
    end;

    local procedure MarkSignupCompleted(var AzureLog: Record "NPR MM AzureMemberUpdateLog"; SignupId: Text[64])
    begin
        AzureLog.Get(AzureLog.EntryNo);
        AzureLog.SignupCompleted := true;
        AzureLog.SignupId := SignupId;
        AzureLog.Modify();
    end;

    local procedure FindCloudflareSetup(DataSubjectId: Text[64]; var AzureLog: Record "NPR MM AzureMemberUpdateLog"; var RegistrationSetup: Record "NPR MM AzureMemberRegSetup"): Boolean
    begin
        AzureLog.SetCurrentKey(DataSubjectId);
        AzureLog.SetFilter(DataSubjectId, '=%1', DataSubjectId);
        if (not AzureLog.FindLast()) then
            exit(false);

        if (not RegistrationSetup.Get(AzureLog.SetupCode)) then
            exit(false);

        exit(RegistrationSetup.Enabled and (RegistrationSetup.Provider = RegistrationSetup.Provider::Cloudflare));
    end;

    [TryFunction]
    local procedure DecodePayload(SignupDataB64: Text; var MemberJson: JsonObject)
    var
        Base64: Codeunit "Base64 Convert";
    begin
        MemberJson.ReadFrom(Base64.FromBase64(SignupDataB64));
    end;

    [TryFunction]
    local procedure GetMemberImage(RegistrationSetup: Record "NPR MM AzureMemberRegSetup"; DataSubjectId: Text[64]; var ImageB64: Text; var HaveImage: Boolean)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        UnexpectedResponseCodeErr: Label '%1 [GET] URL:%2', Locked = true;
    begin
        ImageB64 := '';
        HaveImage := false;

        Request.GetHeaders(Headers);
        Headers.Add('Authorization', GetImageBearerToken());

        Request.Method('GET');
        Request.SetRequestUri(GetImageUrl(RegistrationSetup, DataSubjectId));

        Client.Timeout(10000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (Response.HttpStatusCode() = 404) then
            exit;

        if (not Response.IsSuccessStatusCode()) then
            Error(UnexpectedResponseCodeErr, Response.HttpStatusCode(), GetImageUrl(RegistrationSetup, DataSubjectId));

        Response.Content().ReadAs(ImageB64);
        HaveImage := true;
    end;

    [TryFunction]
    local procedure DeleteMemberImage(RegistrationSetup: Record "NPR MM AzureMemberRegSetup"; DataSubjectId: Text[64])
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        UnexpectedResponseCodeErr: Label '%1 [DELETE] URL:%2', Locked = true;
    begin
        Request.GetHeaders(Headers);
        Headers.Add('Authorization', GetImageBearerToken());

        Request.Method('DELETE');
        Request.SetRequestUri(GetImageUrl(RegistrationSetup, DataSubjectId));

        Client.Timeout(10000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode()) then
            Error(UnexpectedResponseCodeErr, Response.HttpStatusCode(), GetImageUrl(RegistrationSetup, DataSubjectId));
    end;

    local procedure GetImageUrl(RegistrationSetup: Record "NPR MM AzureMemberRegSetup"; DataSubjectId: Text[64]): Text
    begin
        exit(StrSubstNo(_ImageUrlTok, GetWorkerBaseUrl(RegistrationSetup), DataSubjectId));
    end;

    [NonDebuggable]
    local procedure GetImageBearerToken(): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        exit('Bearer ' + AzureKeyVaultMgt.GetAzureKeyVaultSecret(_ImageTokenSecretNameTok));
    end;
}
