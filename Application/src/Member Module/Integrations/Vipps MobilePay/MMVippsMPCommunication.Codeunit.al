codeunit 6185092 "NPR MM VippsMP Communication"
{
    Access = Internal;

    trigger OnRun()
    var
        TaskParameters: Dictionary of [Text, Text];
        PhoneNo: Text[30];
        Scope: Text[70];
        Environment: Enum "NPR MM Add. Info. Req. Config.";
    begin
        TaskParameters := Page.GetBackgroundParameters();
        PhoneNo := CopyStr(TaskParameters.Get('RequestPhoneNo'), 1, MaxStrLen(PhoneNo));
        Scope := CopyStr(TaskParameters.Get('RequestScope'), 1, MaxStrLen(Scope));
        Evaluate(Environment, TaskParameters.Get('RequestEnvironment'));
        GetUserInformationVippsMP(PhoneNo, TaskParameters, Environment, Scope);
        Page.SetBackgroundTaskResult(TaskParameters);
    end;

    [NonDebuggable]
    internal procedure GetUserInformationVippsMP(PhoneNo: Text[30]; var ResponseDict: Dictionary of [Text, Text]; Environment: Enum "NPR MM Add. Info. Req. Config."; Scope: Text[70])
    var
        Configuration: Dictionary of [Text, Text];
        AuthRequestId: Text;
        AccessToken: Text;
        PollingInterval: Duration;
    begin
        FetchOpenIdConfig(Configuration, Environment);
        AuthRequestId := FetchAuthRequestId(Configuration.Get('backchannel_authentication_endpoint'),
                                            PhoneNo, Scope, PollingInterval);

        AccessToken := FetchAccessToken(Configuration.Get('token_endpoint'), AuthRequestId, PollingInterval);
        FetchUserInfo(Configuration.Get('userinfo_endpoint'), AccessToken, ResponseDict);
    end;

    local procedure FetchOpenIdConfig(var Configuration: Dictionary of [Text, Text]; Environment: Enum "NPR MM Add. Info. Req. Config.")
    var
        ResponseMessageText: Text;
    begin
        RequestOpenIdConfig(ResponseMessageText, Environment);
        ParseOpenIdConfig(ResponseMessageText, Configuration);
    end;

    local procedure RequestOpenIdConfig(var ResponseMessageText: Text; Environment: Enum "NPR MM Add. Info. Req. Config.")
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestResult: Boolean;
        OpenIDConfigEndpoint: Label 'https://api.vipps.no/access-management-1.0/access/.well-known/openid-configuration', Locked = true;
        OpenIDConfigTESTEndpoint: Label 'https://apitest.vipps.no/access-management-1.0/access/.well-known/openid-configuration', Locked = true; // Testing purposes
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Clear();
        HttpHeaders.Add('accept', 'application/json');

        if Environment = Environment::Production then
            RequestResult := HttpClient.Get(OpenIDConfigEndpoint, ResponseMessage)
        else
            RequestResult := HttpClient.Get(OpenIDConfigTESTEndpoint, ResponseMessage);

        if (not RequestResult) or (not ResponseMessage.IsSuccessStatusCode()) then
            HandleCommunicationError(RequestResult, ResponseMessage);

        ResponseMessage.Content().ReadAs(ResponseMessageText);
    end;

    local procedure ParseOpenIdConfig(ResponseMessageText: Text; var Configuration: Dictionary of [Text, Text])
    var
        JsonObject: JsonObject;
        JsonValueToken: JsonToken;
    begin
        JsonObject.ReadFrom(ResponseMessageText);
        JsonObject.Get('backchannel_authentication_endpoint', JsonValueToken);
        Configuration.Add('backchannel_authentication_endpoint', JsonValueToken.AsValue().AsText());
        Clear(JsonValueToken);

        JsonObject.Get('token_endpoint', JsonValueToken);
        Configuration.Add('token_endpoint', JsonValueToken.AsValue().AsText());
        Clear(JsonValueToken);

        JsonObject.Get('userinfo_endpoint', JsonValueToken);
        Configuration.Add('userinfo_endpoint', JsonValueToken.AsValue().AsText());
    end;

    [NonDebuggable]
    local procedure FetchAuthRequestId(BackchannelAuthEndpoint: Text; PhoneNo: Text[30]; Scope: Text[70]; var Interval: Duration): Text
    var
        ResponseMessageText: Text;
    begin
        RequestAuthRequestId(BackchannelAuthEndpoint, PhoneNo, Scope, ResponseMessageText);
        exit(ParseAuthRequestId(ResponseMessageText, Interval));
    end;

    [NonDebuggable]
    local procedure RequestAuthRequestId(BackchannelAuthEndpoint: Text; PhoneNo: Text[30]; Scope: Text[70]; var ResponseMessageText: Text)
    var
        AddInfoReqMgt: Codeunit "NPR MM Add. Info. Req. Mgt.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestResult: Boolean;
        LoginHintType: Text;
        BasicRequest: Label 'login_hint=%1%2&scope=%3', Comment = '%1 = login_hint Type, %2 = Phone No., %3 = Scope', Locked = true;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Clear();
        HttpHeaders.Add('accept', 'application/json');

        LoginHintType := 'urn:msisdn:';
        AddInfoReqMgt.UpperCaseUrlEncode(LoginHintType);

        HttpHeaders.Add('authorization', 'Basic ' + GenerateBasicAuth());
        HttpContent.WriteFrom(StrSubstNo(BasicRequest, LoginHintType, PhoneNo, Scope));

        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('content-type', 'application/x-www-form-urlencoded');

        RequestResult := HttpClient.Post(BackchannelAuthEndpoint, HttpContent, ResponseMessage);

        if (not RequestResult) or (not ResponseMessage.IsSuccessStatusCode()) then
            HandleCommunicationError(RequestResult, ResponseMessage);

        ResponseMessage.Content.ReadAs(ResponseMessageText);
    end;

    [NonDebuggable]
    local procedure ParseAuthRequestId(ResponseMessageText: Text; var Interval: Duration): Text
    var
        JsonObject: JsonObject;
        JsonValueToken: JsonToken;
    begin
        JsonObject.ReadFrom(ResponseMessageText);
        JsonObject.Get('interval', JsonValueToken);
        Interval := JsonValueToken.AsValue().AsDuration() * 1000;
        Clear(JsonValueToken);

        JsonObject.Get('auth_req_id', JsonValueToken);
        exit(JsonValueToken.AsValue().AsText());
    end;

    [NonDebuggable]
    local procedure FetchAccessToken(AccessTokenUrl: Text; AuthRequestId: Text; Interval: Duration): Text
    var
        ResponseMessageText: Text;
    begin
        RequestAccessToken(AccessTokenUrl, AuthRequestId, ResponseMessageText, Interval);
        exit(ParseAccessToken(ResponseMessageText));
    end;

    [NonDebuggable]
    local procedure RequestAccessToken(AccessTokenEndpoint: Text; AuthRequestId: Text; var ResponseMessageText: Text; Interval: Duration)
    var
        AddInfoReqMgt: Codeunit "NPR MM Add. Info. Req. Mgt.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        GrantType: Text;
        BasicRequest: Label 'grant_type=%1&auth_req_id=%2', Comment = '%1 = Url Encoded grant_type, %2 = Authentication Request Id', Locked = true;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Clear();
        HttpHeaders.Add('accept', 'application/json');

        GrantType := 'urn:openid:params:grant-type:ciba';
        AddInfoReqMgt.UpperCaseUrlEncode(GrantType);

        HttpHeaders.Add('authorization', 'Basic ' + GenerateBasicAuth());
        HttpContent.WriteFrom(StrSubstNo(BasicRequest, GrantType, AuthRequestId));

        PollRequest(AccessTokenEndpoint, HttpClient, HttpContent, Interval, ResponseMessage);

        ResponseMessage.Content.ReadAs(ResponseMessageText);
    end;

    [NonDebuggable]
    local procedure PollRequest(AccessTokenEndpoint: Text; HttpClient: HttpClient; HttpContent: HttpContent; Interval: Duration; var ResponseMessage: HttpResponseMessage)
    var
        DisposableHttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        OriginalContent: Text;
        ResponseMessageContent: Text;
        JsonObject: JsonObject;
        JsonValueToken: JsonToken;
        RequestResult: Boolean;
        Pending: Boolean;
    begin
        Pending := true;
        HttpContent.ReadAs(OriginalContent);
        repeat
            if not Pending then
                HandleCommunicationError(RequestResult, ResponseMessage);

            Pending := false;
            DisposableHttpContent.WriteFrom(OriginalContent); // Content gets disposed after the request - needs to be set again
            DisposableHttpContent.GetHeaders(ContentHeaders);
            ContentHeaders.Clear();
            ContentHeaders.Add('content-type', 'application/x-www-form-urlencoded');

            RequestResult := HttpClient.Post(AccessTokenEndpoint, DisposableHttpContent, ResponseMessage);

            if ResponseMessage.Content.ReadAs(ResponseMessageContent) then
                if JsonObject.ReadFrom(ResponseMessageContent) then
                    if JsonObject.Get('error', JsonValueToken) then
                        if JsonValueToken.AsValue().AsText() = 'authorization_pending' then
                            Pending := true;

            if Pending then
                Sleep(Interval);
        until (RequestResult and ResponseMessage.IsSuccessStatusCode());
    end;

    [NonDebuggable]
    local procedure ParseAccessToken(ResponseMessageText: Text): Text
    var
        JsonObject: JsonObject;
        JsonValueToken: JsonToken;
    begin
        JsonObject.ReadFrom(ResponseMessageText);
        JsonObject.Get('access_token', JsonValueToken);
        exit(JsonValueToken.AsValue().AsText());
    end;

    [NonDebuggable]
    local procedure FetchUserInfo(UserinfoEndpoint: Text; AccessToken: Text; var ResponseDict: Dictionary of [Text, Text])
    var
        ResponseMessageText: Text;
    begin
        RequestUserInfo(UserinfoEndpoint, AccessToken, ResponseMessageText);
        ParseUserInfo(ResponseMessageText, ResponseDict);
    end;

    [NonDebuggable]
    local procedure RequestUserInfo(UserinfoEndpoint: Text; AccessToken: Text; var ResponseMessageText: Text)
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestResult: Boolean;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Clear();
        HttpHeaders.Add('accept', 'application/json');
        HttpHeaders.Add('authorization', 'Bearer ' + AccessToken);

        RequestResult := HttpClient.Get(UserinfoEndpoint, ResponseMessage);

        if (not RequestResult) or (not ResponseMessage.IsSuccessStatusCode()) then
            HandleCommunicationError(RequestResult, ResponseMessage);

        ResponseMessage.Content.ReadAs(ResponseMessageText);
    end;

    local procedure ParseUserInfo(ResponseMessageText: Text; var ResponseDict: Dictionary of [Text, Text])
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        AddressToken: JsonToken;
        ConsentToken: JsonToken;
        ConsentsObject: JsonObject;
    begin
        JsonObject.ReadFrom(ResponseMessageText);

        if JsonObject.Get('name', JsonToken) then
            ResponseDict.Add('Name', JsonToken.AsValue().AsText());

        if JsonObject.Get('given_name', JsonToken) then
            ResponseDict.Add('FirstName', JsonToken.AsValue().AsText());

        if JsonObject.Get('family_name', JsonToken) then
            ResponseDict.Add('LastName', JsonToken.AsValue().AsText());

        if JsonObject.Get('email', JsonToken) then
            ResponseDict.Add('Email', JsonToken.AsValue().AsText());

        if JsonObject.Get('birthdate', JsonToken) then
            ResponseDict.Add('Birthdate', JsonToken.AsValue().AsText());

        if JsonObject.Get('address', JsonToken) then
            ParseAddress(JsonToken, ResponseDict);

        if JsonObject.Get('other_addresses', JsonToken) then
            foreach AddressToken in JsonToken.AsArray() do begin
                ParseAddress(AddressToken, ResponseDict);
            end;

        if JsonObject.Get('delegatedConsents', JsonToken) then begin
            ConsentsObject := JsonToken.AsObject();
            ConsentsObject.Get('timeOfConsent', JsonToken);
            ResponseDict.Add('ConsentTime', JsonToken.AsValue().AsText());

            if ConsentsObject.Get('consents', JsonToken) then
                foreach ConsentToken in JsonToken.AsArray() do begin
                    ParseConsent(ConsentToken, ResponseDict);
                end;
        end;
    end;

    local procedure ParseAddress(AddressToken: JsonToken; var ResponseDict: Dictionary of [Text, Text]);
    var
        AddressObject: JsonObject;
        JsonToken: JsonToken;
        AddressPrefix: Text[5];
        StreetAddress: List of [Text];
        LF: Text[1];
    begin
        LF[1] := 10;

        AddressObject := AddressToken.AsObject();
        AddressObject.Get('address_type', JsonToken);

        case JsonToken.AsValue().AsText() of
            'work':
                AddressPrefix := 'Work';
            'other':
                AddressPrefix := 'Alt';
            else // home
                AddressPrefix := '';
        end;

        AddressObject.Get('street_address', JsonToken);
        StreetAddress := JsonToken.AsValue().AsText().Split(LF);
        ResponseDict.Add(AddressPrefix + 'Address', StreetAddress.Get(1));
        ResponseDict.Add(AddressPrefix + 'Address2', StreetAddress.Get(2));

        if AddressObject.Get('region', JsonToken) then
            ResponseDict.Add(AddressPrefix + 'City', JsonToken.AsValue().AsText());

        if AddressObject.Get('postal_code', JsonToken) then
            ResponseDict.Add(AddressPrefix + 'PostCode', JsonToken.AsValue().AsText());

        if AddressObject.Get('country', JsonToken) then
            ResponseDict.Add(AddressPrefix + 'CountryCode', JsonToken.AsValue().AsText());
    end;

    local procedure ParseConsent(ConsentToken: JsonToken; var ResponseDict: Dictionary of [Text, Text]);
    var
        ConsentObject: JsonObject;
        JsonToken: JsonToken;
    begin
        ConsentObject := ConsentToken.AsObject();
        ConsentObject.Get('id', JsonToken);

        case JsonToken.AsValue().AsText() of
            'email':
                ResponseDict.Add('ConsentEmail', 'true');
            'sms':
                ResponseDict.Add('ConsentSMS', 'true');
            'digital':
                ResponseDict.Add('ConsentDigitalMarketing', 'true');
            'personal':
                ResponseDict.Add('ConsentCustomizedOffers', 'true');
        end;
    end;

    [NonDebuggable]
    local procedure GenerateBasicAuth(): Text
    var
        VippsMPUtil: Codeunit "NPR Vipps Mp Util";
        Base64Convert: Codeunit "Base64 Convert";
        PartnerClientId: Text;
        PartnerClientSecret: Text;
        UsernamePwd: Label '%1:%2', Locked = true;
    begin
        PartnerClientId := VippsMPUtil.VippsPartnerClientId();
        PartnerClientSecret := VippsMPUtil.VippsPartnerClientSecret();
        exit(Base64Convert.ToBase64(StrSubstNo(UsernamePwd, PartnerClientId, PartnerClientSecret)));
    end;

    local procedure HandleCommunicationError(RequestResult: Boolean; ResponseMessage: HttpResponseMessage)
    var
        ResponseMessageContent: Text;
        HttpRequestProcessingErr: Label 'Unable to process the HTTP request.\%1\%2', Comment = '%1 = Error Code, %2 = Error Text';
        HttpRequestResponseErr: Label 'The HTTP request returned a client error response status code.\%1\%2', Comment = '%1 = HttpStatusCode, %2 = ReasonPhrase';
        HttpRequestResponseDetailedErr: Label 'The HTTP request returned a client error response status code.\%1\%2\\%3',
                                        Comment = '%1 = HttpStatusCode, %2 = ReasonPhrase, %3 = Response Body';
    begin
        if not RequestResult then
            Error(HttpRequestProcessingErr, GetLastErrorCode(), GetLastErrorText());

        if ResponseMessage.Content.ReadAs(ResponseMessageContent) then
            Error(HttpRequestResponseDetailedErr, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, ResponseMessageContent);

        Error(HttpRequestResponseErr, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
    end;
}
