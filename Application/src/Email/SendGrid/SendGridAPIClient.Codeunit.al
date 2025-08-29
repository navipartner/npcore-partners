#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248263 "NPR SendGrid API Client"
{
    Access = Internal;

    #region Subuser Management
    /**
     * SendGrid documentation:
     * https://www.twilio.com/docs/sendgrid/api-reference/users-api/update-a-users-profile
     */
    [TryFunction]
    [NonDebuggable]
    internal procedure TryUpdateProfile(AccountId: Integer; ProfileUpdate: JsonObject)
    var
        Account: Record "NPR NP Email Account";
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestTxt: Text;
        RequestMsg: HttpRequestMessage;
        RequestHeaders: HttpHeaders;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        ResponseStream: InStream;
        TempBlob: Codeunit "Temp Blob";
        BufText: Text;
        FailedToUpdateProfileErr: Label 'Failed to update NP Email account profile.\Status code: %1\Body: %2', Comment = '%1 = http status code, %2 = response body';
    begin
        Account.Get(AccountId);

        ProfileUpdate.WriteTo(RequestTxt);
        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(ContentHeaders);

        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        RequestMsg.Content := Content;
        RequestMsg.SetRequestUri(GetBaseUrl(Account) + '/v3/user/profile');
        RequestMsg.GetHeaders(RequestHeaders);
        SetHeader(RequestHeaders, 'Authorization', StrSubstNo('Bearer %1', Account.GetApiKey()));
        RequestMsg.Method := 'PATCH';

        Client.Send(RequestMsg, ResponseMsg);

        if (not ResponseMsg.IsSuccessStatusCode()) then begin
            TempBlob.CreateInStream(ResponseStream, TextEncoding::UTF8);
            ResponseMsg.Content.ReadAs(ResponseStream);
            while (not ResponseStream.EOS()) do begin
                ResponseStream.ReadText(BufText);
                ResponseTxt += BufText;
            end;
            Error(FailedToUpdateProfileErr, ResponseMsg.HttpStatusCode(), ResponseTxt);
        end;
    end;
    #endregion

    #region Dynamic Templates
    [TryFunction]
    internal procedure TryGetDynamicTemplates(AccountId: Integer; var TempDynamicTemplate: Record "NPR SendGridDynamicTemplate" temporary)
    var
        Client: HttpClient;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        JToken: JsonToken;
        BufToken: JsonToken;
        FailedToFetchDynamicTemplatesErr: Label 'Failed to fetch dynamic templates from the API.\Status code: %1\Body: %2', Comment = '%1 = http status code, %2 = http body';
    begin
        Client := GenerateClient(AccountId);

        Client.Get('/v3/templates?generations=dynamic', ResponseMsg);
        if (not ResponseMsg.Content.ReadAs(ResponseTxt)) then;

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(FailedToFetchDynamicTemplatesErr, ResponseMsg.HttpStatusCode(), ResponseTxt);

        JToken.ReadFrom(ResponseTxt);
        JToken.SelectToken('templates', JToken);
        foreach BufToken in JToken.AsArray() do
            TempDynamicTemplate.AddFromJson(BufToken);
    end;
    #endregion

    #region Domain and DNS Management
    internal procedure GetSenderIdentities(AccountId: Integer; var TempSenderIdentities: Record "NPR SendGrid Sender Identity" temporary)
    var
        Client: HttpClient;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        JToken: JsonToken;
        BufToken: JsonToken;
        FailedToFetchDynamicTemplatesErr: Label 'Failed to fetch sender identities from the API.\Status code: %1\Body: %2', Comment = '%1 = http status code, %2 = http body';
    begin
        Client := GenerateClient(AccountId);
        Client.Get('/v3/senders', ResponseMsg);
        if (not ResponseMsg.Content.ReadAs(ResponseTxt)) then;

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(FailedToFetchDynamicTemplatesErr, ResponseMsg.HttpStatusCode(), ResponseTxt);

        JToken.ReadFrom(ResponseTxt);
        foreach BufToken in JToken.AsArray() do
            TempSenderIdentities.AddFromJson(AccountId, BufToken);
    end;

    /**
     * SendGrid documentation:
     * https://www.twilio.com/docs/sendgrid/api-reference/domain-authentication/authenticate-a-domain
     */
    internal procedure CreateDomain(AccountId: Integer; DomainRequest: JsonObject): JsonObject
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestTxt: Text;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        JObject: JsonObject;
        FailedToCreateDomainErr: Label 'Failed to create the domain for verification.\Status code: %1\Body: %2', Comment = '%1 = http status code, %2 = response body';
    begin
        Client := GenerateClient(AccountId);

        DomainRequest.WriteTo(RequestTxt);
        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(ContentHeaders);

        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        Client.Post('/v3/whitelabel/domains', Content, ResponseMsg);
        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(FailedToCreateDomainErr, ResponseMsg.HttpStatusCode(), ResponseTxt);

        JObject.ReadFrom(ResponseTxt);
        exit(JObject);
    end;

    /**
     * SendGrid documentation:
     * https://www.twilio.com/docs/sendgrid/api-reference/domain-authentication/list-all-authenticated-domains#operation-overview
     */
    internal procedure GetDomains(AccountId: Integer): JsonArray
    var
        Client: HttpClient;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        JArray: JsonArray;
        FailedToFetchDomainsErr: Label 'Failed to fetch domains.\Status code. %1\Body: %2', Comment = '%1 = http status code, %2 = response body';
    begin
        Client := GenerateClient(AccountId);

        Client.Get('/v3/whitelabel/domains', ResponseMsg);
        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(FailedToFetchDomainsErr, ResponseMsg.HttpStatusCode(), ResponseTxt);

        JArray.ReadFrom(ResponseTxt);
        exit(JArray);
    end;

    /**
     * SendGrid documentation:
     * https://www.twilio.com/docs/sendgrid/api-reference/domain-authentication/validate-a-domain-authentication
     */
    internal procedure ValidateDomain(AccountId: Integer; DomainId: Integer): JsonObject
    var
        Client: HttpClient;
        Content: HttpContent;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        JObject: JsonObject;
        FailedToGetInfoDomainErr: Label 'Failed to get information for the domain.\Status code: %1\Body: %2', Comment = '%1 = http status code, %2 = response body';
    begin
        Client := GenerateClient(AccountId);

        Client.Post(StrSubstNo('/v3/whitelabel/domains/%1/validate', DomainId), Content, ResponseMsg);
        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(FailedToGetInfoDomainErr, ResponseMsg.HttpStatusCode(), ResponseTxt);

        JObject.ReadFrom(ResponseTxt);
        exit(JObject);
    end;
    #endregion

    #region Email Sending
    /**
     * SendGrid documentation:
     * https://www.twilio.com/docs/sendgrid/api-reference/mail-send/mail-send#operation-overview
     */
    internal procedure SendEmail(AccountId: Integer; Email: JsonObject)
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestTxt: Text;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        FailedToSendMailErr: Label 'Failed to send e-mail.\Error code: %1\Content: %2', Comment = '%1 = response http status code, %2 = response content';
    begin
        Client := GenerateClient(AccountId);

        Email.WriteTo(RequestTxt);
        Content.WriteFrom(RequestTxt);

        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        Client.Post('/v3/mail/send', Content, ResponseMsg);

        if (ResponseMsg.IsSuccessStatusCode()) then
            exit;

        ResponseMsg.Content.ReadAs(ResponseTxt);
        Error(FailedToSendMailErr, ResponseMsg.HttpStatusCode(), ResponseTxt);
    end;
    #endregion

    #region Aux
    local procedure GenerateClient(AccountId: Integer): HttpClient
    var
        Client: HttpClient;
        Account: Record "NPR NP Email Account";
    begin
        Account.Get(AccountId);
        Client.SetBaseAddress(GetBaseUrl(Account));
        Client.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Bearer %1', Account.GetApiKey()));
        exit(Client);
    end;

    local procedure GetBaseUrl(Account: Record "NPR NP Email Account"): Text
    begin
        case Account.AccountRegion of
            "NPR SendGridAccountRegion"::GLOBAL:
                exit('https://api.sendgrid.com');
            "NPR SendGridAccountRegion"::EU:
                exit('https://api.eu.sendgrid.com');
        end;
    end;

    local procedure SetHeader(Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if (Headers.Contains(HeaderName)) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;
    #endregion
}
#endif