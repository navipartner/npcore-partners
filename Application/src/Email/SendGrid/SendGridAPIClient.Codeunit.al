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
    internal procedure TryUpdateProfile(AccountId: Integer; ProfileUpdate: JsonObject)
    var
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
        ProfileUpdate.WriteTo(RequestTxt);
        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(ContentHeaders);

        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        RequestMsg.Content := Content;
        RequestMsg.SetRequestUri(GetBaseUrl() + '/v3/user/profile');
        RequestMsg.GetHeaders(RequestHeaders);
        SetHeader(RequestHeaders, 'Authorization', StrSubstNo('Bearer %1', GetAuthorizationValue(AccountId)));
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

    #region Domain and DNS Management
    internal procedure GetSenderIdentities(AccountId: Integer; var TempSenderIdentities: Record "NPR SendGrid Sender Identity" temporary)
    var
        Client: HttpClient;
        ResponseMsg: HttpResponseMessage;
        InStr: InStream;
        JToken: JsonToken;
        BufToken: JsonToken;
    begin
        Client := GenerateClient(AccountId);
        Client.Get('/v3/senders', ResponseMsg);
        ResponseMsg.Content.ReadAs(InStr);
        JToken.ReadFrom(InStr);
        foreach BufToken in JToken.AsArray() do
            TempSenderIdentities.AddFromJson(AccountId, BufToken.AsObject());
    end;

    /**
     * SendGrid documentation:
     * https://www.twilio.com/docs/sendgrid/api-reference/sender-identities-api/get-all-sender-identities#operation-overview
     */
    internal procedure CreateSenderIdentity(AccountId: Integer; Identity: JsonObject): JsonObject
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestTxt: Text;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        JObject: JsonObject;
        FailedToCreateSenderErr: Label 'Failed to create sender identity.\Status code: %1\Body: %2', Comment = '%1 = http status code, %2 = response body';
    begin
        Client := GenerateClient(AccountId);

        Identity.WriteTo(RequestTxt);
        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(ContentHeaders);

        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        Client.Post('/v3/senders', Content, ResponseMsg);
        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(FailedToCreateSenderErr, ResponseMsg.HttpStatusCode(), ResponseTxt);

        JObject.ReadFrom(ResponseTxt);
        exit(JObject);
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
    begin
        Client.SetBaseAddress(GetBaseUrl());
        Client.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Bearer %1', GetAuthorizationValue(AccountId)));
        exit(Client);
    end;

    local procedure GetBaseUrl(): Text
    begin
        exit('https://api.sendgrid.com');
    end;

    [NonDebuggable]
    local procedure GetAuthorizationValue(AccountId: Integer): Text
    var
        NPEmailAccount: Record "NPR NP Email Account";
    begin
        NPEmailAccount.Get(AccountId);
        exit(NPEmailAccount.GetApiKey());
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