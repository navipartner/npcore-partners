#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248264 "NPR SendGrid Client"
{
    Access = Internal;

    internal procedure GetEnvironmentIdentifier(): Text
    var
        AzureAdTenant: Codeunit "Azure AD Tenant";
        EnvInfo: Codeunit "Environment Information";
    begin
        if (EnvInfo.IsSaaSInfrastructure()) then
            exit(AzureAdTenant.GetAadTenantId());
        if (GetUrl(ClientType::Web).Contains('dynamics-retail.net')) then
            exit(StrSubstNo('%1-test', UserId()));
        exit(TenantId());
    end;

    #region Central Database
    [NonDebuggable]
    internal procedure GetApiKeyFromD1Database(EnvironmentIdentifier: Text; var ApiKey: Text)
    var
        KeyVault: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        Url: Text;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        TempToken: JsonToken;
        JHelper: Codeunit "NPR Json Helper";
    begin
        Url := StrSubstNo('https://npemail-account-api.npretail.app/accountDetails/%1', EnvironmentIdentifier);

        Client.DefaultRequestHeaders().Add('Authorization', KeyVault.GetAzureKeyVaultSecret('NPEmailCloudflareToken'));

        Client.Get(Url, ResponseMsg);
        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error('Failed to query database.\Status code: %1\Body: %2', ResponseMsg.HttpStatusCode(), ResponseTxt);

        TempToken.ReadFrom(ResponseTxt);

        APIKey := JHelper.GetJText(TempToken, 'apikey', true);
    end;


    [TryFunction]
    [NonDebuggable]
    internal procedure TryGetAccountFromD1Database(EnvironmentIdentifier: Text; var NPEmailAccount: Record "NPR NP Email Account"; var AccountFound: Boolean)
    var
        KeyVault: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        Url: Text;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        TempToken: JsonToken;
        JHelper: Codeunit "NPR Json Helper";
        APIKey: Text;
        AccountName: Text;
    begin
        Url := StrSubstNo('https://npemail-account-api.npretail.app/accountDetails/%1', EnvironmentIdentifier);

        Client.DefaultRequestHeaders().Add('Authorization', KeyVault.GetAzureKeyVaultSecret('NPEmailCloudflareToken'));

        Client.Get(Url, ResponseMsg);
        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (ResponseMsg.HttpStatusCode() = 404) then begin
            AccountFound := false;
            exit;
        end;

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error('Failed to query database.\Status code: %1\Body: %2', ResponseMsg.HttpStatusCode(), ResponseTxt);

        TempToken.ReadFrom(ResponseTxt);

        AccountFound := true;

        AccountName := JHelper.GetJText(TempToken, 'subuser', true);
        APIKey := JHelper.GetJText(TempToken, 'apikey', true);

        NPEmailAccount.Init();
        NPEmailAccount.AccountId := JHelper.GetJBigInteger(TempToken, 'user_id', true);
#pragma warning disable AA0139
        NPEmailAccount.Username := AccountName;
#pragma warning restore AA0139
        NPEmailAccount.SetApiKey(APIKey);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure TryCreateAccount(EnvironmentIdentifier: Text; var NPEmailAccount: Record "NPR NP Email Account")
    var
        KeyVault: Codeunit "NPR Azure Key Vault Mgt.";
        Json: Codeunit "NPR Json Builder";
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        JToken: JsonToken;
        JHelper: Codeunit "NPR Json Helper";
        FailedToCreateAccountErr: Label 'Failed to create NP Email account.\Status code: %1\Body: %2', Comment = '%1 = http status code, %2 = response body';
    begin
        Json.StartObject()
                .AddProperty('entra_id', EnvironmentIdentifier)
                .AddProperty('email', NPEmailAccount.BillingEmail)
                .AddProperty('password', GenerateRandomPassword(24))
            .EndObject();

        Content.WriteFrom(Json.BuildAsText());
        Content.GetHeaders(ContentHeaders);

        SetHeader(ContentHeaders, 'Content-Type', 'application/json');
        Client.DefaultRequestHeaders().Add('Authorization', KeyVault.GetAzureKeyVaultSecret('NPEmailCloudflareToken'));

        Client.Post('https://npemail-account-api.npretail.app/accounts', Content, ResponseMsg);
        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(FailedToCreateAccountErr, ResponseMsg.HttpStatusCode(), ResponseTxt);

        JToken.ReadFrom(ResponseTxt);

#pragma warning disable AA0139
        NPEmailAccount.AccountId := JHelper.GetJInteger(JToken, 'user_id', true);
        NPEmailAccount.Username := JHelper.GetJText(JToken, 'username', true);
        NPEmailAccount.SetApiKey(JHelper.GetJText(JToken, 'apiKey', true));
#pragma warning restore AA0139
    end;
    #endregion

    #region Sender Identity
    internal procedure UpdateLocalSenderIdentities()
    var
        NPEmailAccount: Record "NPR NP Email Account";
        TempSenderIdentity: Record "NPR SendGrid Sender Identity" temporary;
        SenderIdentity: Record "NPR SendGrid Sender Identity";
        APIClient: Codeunit "NPR SendGrid API Client";
    begin
        if (NPEmailAccount.FindSet()) then
            repeat
                APIClient.GetSenderIdentities(NPEmailAccount.AccountId, TempSenderIdentity);
                SenderIdentity.UpdateFromIdentities(TempSenderIdentity);
            until NPEmailAccount.Next() = 0;
    end;

    internal procedure CreateSenderIdentity(AccountId: Integer; var Identity: Record "NPR SendGrid Sender Identity")
    var
        APIClient: Codeunit "NPR SendGrid API Client";
        JObject: JsonObject;
    begin
        JObject := APIClient.CreateSenderIdentity(AccountId, Identity.ToRequestJson());
        Identity.FromJson(AccountId, JObject);
        Identity.Insert();
    end;
    #endregion

    #region Subuser
    internal procedure CreateSubuser(EnvironmentIdentifier: Text; var NPEmailAccount: Record "NPR NP Email Account")
    var
        UpdateProfile: Codeunit "NPR Json Builder";
        APIClient: Codeunit "NPR SendGrid API Client";
        FailedToCreateAccountErr: Label 'Failed to create NP Email Account';
    begin
        if (not TryCreateAccount(EnvironmentIdentifier, NPEmailAccount)) then
            Error(FailedToCreateAccountErr);

        NPEmailAccount.Insert();
        Commit();

        UpdateProfile.StartObject().AddProperty('company', NPEmailAccount.CompanyName).EndObject();
        if (not APIClient.TryUpdateProfile(NPEmailAccount.AccountId, UpdateProfile.Build())) then;
    end;
    #endregion

    #region Domain
    internal procedure CreateDomain(NPEmailAccount: Record "NPR NP Email Account"; Domain: Text[300]; var NPEmailDomain: Record "NPR NP Email Domain"; var NPEmailDomainDNSRecord: Record "NPR NPEmailDomainDNSRecord")
    var
        Request: Codeunit "NPR Json Builder";
        APIClient: Codeunit "NPR SendGrid API Client";
        JObject: JsonObject;
        JToken: JsonToken;
        JHelper: Codeunit "NPR Json Helper";
    begin
        /*
         * We don't have to include the `username` in the request
         * since API scoped to a subuser (which we are using further down)
         * will scope the added domain to that user
         */
        Request.StartObject()
                    .AddProperty('domain', Domain)
                    .AddProperty('automatic_security', false)
                    .AddProperty('custom_spf', true)
                .EndObject();

        JObject := APIClient.CreateDomain(NPEmailAccount.AccountId, Request.Build());
        JToken := JObject.AsToken();

        NPEmailDomain.Init();
        NPEmailDomain.Id := JHelper.GetJInteger(JToken, 'id', true);
        NPEmailDomain.AccountId := JHelper.GetJInteger(JToken, 'user_id', true);
        NPEmailDomain.Domain := Domain;
        NPEmailDomain.Valid := JHelper.GetJBoolean(JToken, 'valid', true);
        NPEmailDomain.Insert();

        JToken.SelectToken('dns', JToken);

#pragma warning disable AA0139
        NPEmailDomainDNSRecord.AddRecord(
            JHelper.GetJText(JToken, 'mail_server.type', true),
            JHelper.GetJText(JToken, 'mail_server.host', true),
            JHelper.GetJText(JToken, 'mail_server.data', true)
        );

        NPEmailDomainDNSRecord.AddRecord(
            JHelper.GetJText(JToken, 'subdomain_spf.type', true),
            JHelper.GetJText(JToken, 'subdomain_spf.host', true),
            JHelper.GetJText(JToken, 'subdomain_spf.data', true)
        );

        NPEmailDomainDNSRecord.AddRecord(
            JHelper.GetJText(JToken, 'dkim.type', true),
            JHelper.GetJText(JToken, 'dkim.host', true),
            JHelper.GetJText(JToken, 'dkim.data', true)
        );
#pragma warning restore AA0139
    end;

    internal procedure VerifyDomain(var NPEmailAccountDomain: Record "NPR NP Email Domain")
    var
        APIClient: Codeunit "NPR SendGrid API Client";
        JObject: JsonObject;
        JHelper: Codeunit "NPR Json Helper";
    begin
        JObject := APIClient.ValidateDomain(NPEmailAccountDomain.AccountId, NPEmailAccountDomain.Id);
        NPEmailAccountDomain.Valid := JHelper.GetJBoolean(JObject.AsToken(), 'valid', true);
        NPEmailAccountDomain.Modify();
    end;
    #endregion

    #region Email
    internal procedure SendEmail(EmailMessage: Codeunit "Email Message"; Account: Record "NPR NPEmailWebSMTPEmailAccount")
    var
        APIClient: Codeunit "NPR SendGrid API Client";
        EmailObject: JsonObject;
    begin
        EmailObject := ConvertEmailMessageToJson(EmailMessage, Account);
        APIClient.SendEmail(Account.NPEmailAccountId, EmailObject);
    end;

    local procedure ConvertEmailMessageToJson(EmailMessage: Codeunit "Email Message"; Account: Record "NPR NPEmailWebSMTPEmailAccount"): JsonObject
    var
        RecipientList: List of [Text];
        ToEmail: Text;
        Json: Codeunit "NPR Json Builder";
    begin
        Json.StartObject().StartArray('personalizations').StartObject();

        EmailMessage.GetRecipients("Email Recipient Type"::"To", RecipientList);
        if (RecipientList.Count > 0) then begin
            Json.StartArray('to');
            foreach ToEmail in RecipientList do
                Json.StartObject().AddProperty('email', ToEmail).EndObject();
            Json.EndArray();
        end;

        EmailMessage.GetRecipients("Email Recipient Type"::"Cc", RecipientList);
        if (RecipientList.Count > 0) then begin
            Json.StartArray('cc');
            foreach ToEmail in RecipientList do
                Json.StartObject().AddProperty('email', ToEmail).EndObject();
            Json.EndArray();
        end;

        EmailMessage.GetRecipients("Email Recipient Type"::"Bcc", RecipientList);
        if (RecipientList.Count > 0) then begin
            Json.StartArray('bcc');
            foreach ToEmail in RecipientList do
                Json.StartObject().AddProperty('email', ToEmail).EndObject();
            Json.EndArray();
        end;

        Json.EndObject().EndArray(); // personalizations

        Json.StartObject('from')
                .AddProperty('email', Account.FromEmailAddress);
        if (Account.FromName <> '') then
            Json.AddProperty('name', Account.FromName);
        Json.EndObject(); // from

        if (Account.ReplyToEmailAddress <> '') then begin
            Json.StartObject('reply_to').AddProperty('email', Account.ReplyToEmailAddress);
            if (Account.ReplyToName <> '') then
                Json.AddProperty('name', Account.ReplyToName);
            Json.EndObject(); // reply_to
        end;

        Json.AddProperty('subject', EmailMessage.GetSubject());

        Json.StartArray('content')
            .StartObject();
        if (EmailMessage.IsBodyHTMLFormatted()) then
            Json.AddProperty('type', 'text/html')
        else
            Json.AddProperty('type', 'text/plain');
        Json.AddProperty('value', EmailMessage.GetBody())
            .EndObject()
            .EndArray(); // content

        if (EmailMessage.Attachments_First()) then begin
            Json.StartArray('attachments');
            repeat
                Json.StartObject()
                        .AddProperty('content', EmailMessage.Attachments_GetContentBase64())
                        .AddProperty('filename', EmailMessage.Attachments_GetName())
                        .AddProperty('type', EmailMessage.Attachments_GetContentType());
                if (EmailMessage.Attachments_IsInline()) then
                    Json.AddProperty('disposition', 'inline').AddProperty('content_id', EmailMessage.Attachments_GetContentId())
                else
                    Json.AddProperty('disposition', 'attachment');
            until EmailMessage.Attachments_Next() = 0;
            Json.EndArray(); // attachments
        end;

        Json.EndObject(); // the main object

        exit(Json.Build());
    end;
    #endregion

    #region Aux
    local procedure GenerateRandomPassword(Length: Integer) Password: Text
    var
        RandInt: Integer;
        i: Integer;
    begin
        for i := 1 to Length do begin
            RandInt := Random(122);
            while RandInt < 33 do
                RandInt := Random(122);
            Password[i] := RandInt;
        end;

        // We require both a letter and a number so to ensure that we have that, we add some here.
        Password[i + 1] := 'a';
        Password[i + 2] := '1';
    end;

    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if (Headers.Contains(HeaderName)) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;
    #endregion
}
#endif