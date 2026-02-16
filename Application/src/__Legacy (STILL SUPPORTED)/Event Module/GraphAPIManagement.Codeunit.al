codeunit 6014606 "NPR Graph API Management"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    var
        _GraphApiSetup: Record "NPR GraphApi Setup";

    internal procedure GetAccessToken(EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail")
    var
        Scopes: List of [Text];
#IF NOT BC17
        OAuth2: Codeunit OAuth2;
        RedirectURL: Text;
        NPROAuthControlAddIn: Page "NPR OAuth ControlAddIn";
        TypeHelper: Codeunit "Type Helper";
        URLText: Text;
        AuthCode: Text;
        Scope: Text;
        EncodedScope: Text;
        State: Integer;
        ExpiresIn: Integer;
#ENDIF
        AccessToken, RefreshToken, AuthCodeError : Text;
        AccesTokenMsg: Label 'Access token acquired.';
        FailErr: Label 'Acquire token failed. Error message: %1';
    begin
        EventExchIntEMail.TestField("Time Zone No.");
        AddScopes(Scopes);
        GetTestGraphAPISetup();
#IF NOT BC17
        OAuth2.GetDefaultRedirectURL(RedirectURL);
        State := Random(10000);
        Scope := 'User.Read Calendars.ReadWrite offline_access';
        EncodedScope := TypeHelper.UrlEncode(Scope);
        URLText := StrSubstNo('%1?client_id=%2&redirect_uri=%3&state=%4&response_type=code&scope=%5&prompt=login', _GraphApiSetup."OAuth Authority Url", _GraphApiSetup."Client Id", RedirectURL, State, EncodedScope);
        NPROAuthControlAddIn.SetRequestProps(URLText);
        NPROAuthControlAddIn.RunModal();
        AuthCode := NPROAuthControlAddIn.GetAuthCode();
        AuthCodeError := NPROAuthControlAddIn.GetAuthError();
        NPROAuthControlAddIn.SetTenant('common');
        NPROAuthControlAddIn.RequestToken(AuthCode, RedirectURL, _GraphApiSetup."Client Id", _GraphApiSetup."Client Secret", AccessToken, RefreshToken, ExpiresIn);
#ENDIF
        if (AccessToken = '') or (AuthCodeError <> '') then
            Error(FailErr, AuthCodeError);

        SetAccessToken(EventExchIntEMail, AccessToken, RefreshToken);

        Message(AccesTokenMsg);
    end;

    internal procedure DeleteEvent(JobNo: Code[20]; EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; CalendarItemID: Text): Boolean
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AccessToken, URL : Text;
        DeletedMsg: Label 'Event deleted';
    begin
        GetTestGraphAPISetup();
        URL := _GraphApiSetup."Graph Event Url" + CalendarItemID;
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'DELETE', URL);

        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() then begin
                Message(DeletedMsg);
                exit(true);
            end else begin
                LogResponse(JobNo, 'Delete Event', EventExchIntEMail."E-Mail", URL, '', ResponseMessage);
                exit(false);
            end;
    end;

    internal procedure CreateEventRequest(Subject: Text; StartingDateTime: DateTime; EndingDateTime: DateTime; TimeZoneId: Text; ShowAsBusy: Boolean; ReminderMinutesBeforeStart: Integer; JAAttendees: JsonArray; EventBodyText: Text; CalendarCategory: Text) RequestBody: Text
    var
        JRequestObject, JOStart, JOEnd, JOBody : JsonObject;
        JACategories: JsonArray;
    begin
        JRequestObject.Add('subject', Subject);
        JOStart.Add('dateTime', Format(StartingDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>'));
        JOStart.Add('timeZone', TimeZoneId);
        JRequestObject.Add('start', JOStart);
        JOEnd.Add('dateTime', Format(EndingDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>'));
        JOEnd.Add('timeZone', TimeZoneId);
        JRequestObject.Add('end', JOEnd);
        if ShowAsBusy then
            JRequestObject.Add('showAs', 'Busy')
        else
            JRequestObject.Add('showAs', 'Tentative');
        JRequestObject.Add('reminderMinutesBeforeStart', ReminderMinutesBeforeStart);
        JOBody.Add('contentType', 'html');
        JOBody.Add('content', EventBodyText);
        JRequestObject.Add('body', JOBody);

        JRequestObject.Add('attendees', JAAttendees);
        if CalendarCategory <> '' then begin
            JACategories.Add(CalendarCategory);
            JRequestObject.Add('categories', JACategories);
        end;
        JRequestObject.WriteTo(RequestBody);
    end;

    internal procedure GetEvent(EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; CalendarItemID: Text): Boolean
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AccessToken: Text;
    begin
        GetTestGraphAPISetup();
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'GET', _GraphApiSetup."Graph Event Url" + CalendarItemID);

        if Client.Send(RequestMessage, ResponseMessage) then
            exit(ResponseMessage.IsSuccessStatusCode())
        else
            exit(false);
    end;

    internal procedure GetEventContent(JobNo: Code[20]; EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; CalendarItemID: Text) ResponseContent: Text
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AccessToken, URL : Text;
        ErrorMsg: Label 'Error getting information for Event ID %1.';
    begin
        GetTestGraphAPISetup();
        URL := _GraphApiSetup."Graph Event Url" + CalendarItemID;
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'GET', URL);

        if Client.Send(RequestMessage, ResponseMessage) then
            ResponseMessage.Content.ReadAs(ResponseContent)
        else begin
            LogResponse(JobNo, 'Get Event Content', EventExchIntEMail."E-Mail", URL, '', ResponseMessage);
            Message(ErrorMsg, CalendarItemID);
        end;
    end;

    internal procedure SendEventRequest(JobNo: Code[20]; EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; Request: Text) CalendarItemID: Text
    var
        AccessToken: Text;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        GetTestGraphAPISetup();
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'POST', _GraphApiSetup."Graph Event Url");

        SetMessageContent(Request, Content, RequestMessage);
        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() then
                GetEventID(CalendarItemID, ResponseMessage)
            else
                LogResponse(JobNo, 'Event Create', EventExchIntEMail."E-Mail", _GraphApiSetup."Graph Event Url", Request, ResponseMessage);
    end;

    internal procedure SendEventRequestUpdate(JobNo: Code[20]; EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; Request: Text; CalendarItemID: Text; Silent: Boolean)
    var
        AccessToken, URL : Text;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        UpdatedMsg: Label 'Event updated.';
    begin
        GetTestGraphAPISetup();
        URL := _GraphApiSetup."Graph Event Url" + CalendarItemID;
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'PATCH', URL);

        SetMessageContent(Request, Content, RequestMessage);
        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() and (not Silent) then
                Message(UpdatedMsg)
            else
                LogResponse(JobNo, 'Event Update', EventExchIntEMail."E-Mail", URL, Request, ResponseMessage);
    end;

    internal procedure AddAttachment(JobNo: Code[20]; EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; Request: Text; CalendarItemID: Text)
    var
        AccessToken, URL : Text;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        GetTestGraphAPISetup();
        URL := _GraphApiSetup."Graph Event Url" + CalendarItemID + '/attachments';
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'POST', URL);
        SetMessageContent(Request, Content, RequestMessage);
        if Client.Send(RequestMessage, ResponseMessage) then
            if not ResponseMessage.IsSuccessStatusCode() then
                LogResponse(JobNo, 'Add Event Attachment', EventExchIntEMail."E-Mail", URL, Request, ResponseMessage);
    end;

    internal procedure DeleteAttachments(JobNo: Code[20]; EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; CalendarItemID: Text)
    var
        AccessToken, URL : Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        GetTestGraphAPISetup();
        URL := _GraphApiSetup."Graph Event Url" + CalendarItemID + '/attachments';
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'DELETE', URL);
        if Client.Send(RequestMessage, ResponseMessage) then
            if not ResponseMessage.IsSuccessStatusCode() then
                LogResponse(JobNo, 'Delete Event Attachments', EventExchIntEMail."E-Mail", URL, '', ResponseMessage);
    end;

    internal procedure CreateAttachmentRequest(AttachmentBase64: Text; AttachmentName: Text) Request: Text
    var
        JRequestObject: JsonObject;
    begin
        JRequestObject.Add('@odata.type', '#microsoft.graph.fileAttachment');
        JRequestObject.Add('name', AttachmentName);
        JRequestObject.Add('contentBytes', AttachmentBase64);
        JRequestObject.WriteTo(Request);
    end;

    local procedure GetAccessTokenFromRefreshToken(EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail") AccessToken: Text
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RefreshToken, NewRefreshToken, RefreshRequest : Text;
    begin
        GetTestGraphAPISetup();
        RefreshToken := EventExchIntEMail.GetRefreshToken();

        PrepareRefreshTokenRequest(RefreshToken, Client, RequestMessage, RefreshRequest);

        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() then
                GetTokensFromResponse(ResponseMessage, AccessToken, NewRefreshToken)
            else begin
                if SecretProblem(ResponseMessage) then begin
                    FetchNewSecret();

                    PrepareRefreshTokenRequest(RefreshToken, Client, RequestMessage, RefreshRequest);

                    if Client.Send(RequestMessage, ResponseMessage) then
                        if ResponseMessage.IsSuccessStatusCode() then
                            GetTokensFromResponse(ResponseMessage, AccessToken, NewRefreshToken)
                end;
            end;

        if AccessToken = '' then begin
            LogResponse('', 'Refresh Token', EventExchIntEMail."E-Mail", _GraphApiSetup."OAuth Token Url", RefreshRequest, ResponseMessage);
            Commit();
            exit;
        end;

        SetAccessToken(EventExchIntEMail, AccessToken, NewRefreshToken);
    end;

    internal procedure TestConnection(EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail")
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Response, AccessToken : Text;
        BadResponseErr: Label 'Bad response from the server. Contact your administrator.';
        OkLbl: Label 'Connection Sucessful. Loged in as %1';
    begin
        GetTestGraphAPISetup();
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'GET', _GraphApiSetup."Graph Me Url");

        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(Response);
            Message(OkLbl, GetEmail(Response));
        end else begin
            LogResponse('', 'Test Connection', EventExchIntEMail."E-Mail", _GraphApiSetup."Graph Me Url", '', ResponseMessage);
            Message(BadResponseErr);
        end;
    end;

    local procedure AddScopes(var Scopes: List of [Text])
    begin
        Scopes.Add('User.Read');
        Scopes.Add('Calendars.ReadWrite');
        Scopes.Add('offline_access');
    end;

    local procedure InitializeRequest(EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail"; var AccessToken: Text; var Client: HttpClient; var RequestMessage: HttpRequestMessage; Method: Text; URL: Text)
    var
        MessageHeaders: HttpHeaders;
        NoAccessTokenErr: Label 'There is not valid access token. Run Get Access Token action first.';
    begin
        EventExchIntEMail.Get(EventExchIntEMail."E-Mail");
        EventExchIntEMail.TestField("Time Zone No.");
        if not EventExchIntEMail."Access Token".HasValue() then
            Error(NoAccessTokenErr);

        if EventExchIntEMail."Acces Token Valid Until" < CurrentDateTime() then
            AccessToken := GetAccessTokenFromRefreshToken(EventExchIntEMail)
        else
            AccessToken := EventExchIntEMail.GetAccessToken();

        if AccessToken = '' then
            Error(NoAccessTokenErr);

        Client.Clear();

        Clear(RequestMessage);
        RequestMessage.Method(Method);
        RequestMessage.SetRequestUri(URL);
        RequestMessage.GetHeaders(MessageHeaders);
        MessageHeaders.Clear();
        MessageHeaders.Add('Authorization', 'Bearer ' + AccessToken);
        MessageHeaders.Add('Accept', '*/*');
    end;

    local procedure GetEventID(var CalendarItemID: Text; ResponseMessage: HttpResponseMessage)
    var
        ResponseContent: Text;
        JOResponse: JsonObject;
        JTId: JsonToken;
    begin
        ResponseMessage.Content().ReadAs(ResponseContent);
        JOResponse.ReadFrom(ResponseContent);
        JOResponse.SelectToken('id', JTId);
        CalendarItemID := JTId.AsValue().AsText();
    end;

    local procedure SetMessageContent(EventRequest: Text; Content: HttpContent; var RequestMessage: HttpRequestMessage)
    var
        ContentHeaders: HttpHeaders;
    begin
        Content.WriteFrom(EventRequest);
        ContentHeaders.Clear();
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Content := Content;
    end;

    local procedure LogResponse(JobNo: Code[20]; Description: Text; EMail: Text[50]; URL: Text; Request: Text; ResponseMessage: HttpResponseMessage)
    var
        GraphAPIWSLog: Record "NPR GraphAPI WS Log";
        Response: Text;
    begin
        ResponseMessage.Content.ReadAs(Response);
        GraphAPIWSLog.LogCall(JobNo, Description, Request, Response, URL, EMail);
    end;

    local procedure SetAccessToken(var EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail"; NewAccessToken: Text; NewRefreshToken: Text)
    var
        AccessOutstream: OutStream;
        RefreshOutstream: OutStream;
    begin
        EventExchIntEMail."Access Token".CreateOutStream(AccessOutstream, TextEncoding::UTF8);
        AccessOutstream.WriteText(NewAccessToken);
        EventExchIntEMail."Refresh Token".CreateOutStream(RefreshOutstream, TextEncoding::UTF8);
        RefreshOutstream.WriteText(NewRefreshToken);
        EventExchIntEMail."Acces Token Valid Until" := CurrentDateTime() + 1000 * 50 * 59; //token TTL is 59m59s
        EventExchIntEMail.Modify();
    end;

    local procedure GetEmail(Response: Text) Email: Text
    var
        JOResponse: JsonObject;
        JTEmail: JsonToken;
    begin
        JOResponse.ReadFrom(Response);
        JOResponse.SelectToken('userPrincipalName', JTEmail);
        Email := JTEmail.AsValue().AsText();
    end;

    local procedure GetTestGraphAPISetup()
    begin
        _GraphApiSetup.Get();
        _GraphApiSetup.TestField("Client Id");
        _GraphApiSetup.TestField("Client Secret");
        _GraphApiSetup.TestField("Graph Event Url");
        _GraphApiSetup.TestField("Graph Me Url");
        _GraphApiSetup.TestField("OAuth Authority Url");
        _GraphApiSetup.TestField("OAuth Token Url");
    end;

    local procedure PrepareRefreshTokenRequest(RefreshToken: Text; Client: HttpClient; RequestMessage: HttpRequestMessage; var RefreshRequest: Text)
    var
        Content: HttpContent;
        MessageHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
    begin
        RefreshRequest := GetRefreshTokenRequest(RefreshToken);

        Client.Clear();
        Clear(RequestMessage);
        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(_GraphApiSetup."OAuth Token Url");
        RequestMessage.GetHeaders(MessageHeaders);
        MessageHeaders.Clear();
        MessageHeaders.Add('Accept', '*/*');
        Content.WriteFrom(RefreshRequest);
        ContentHeaders.Clear();
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        RequestMessage.Content(Content);
    end;

    local procedure GetRefreshTokenRequest(RefreshToken: Text) Request: Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        Request := StrSubstNo('client_id=%1', _GraphApiSetup."Client Id");
        Request += '&grant_type=refresh_token';
        Request += StrSubstNo('&client_secret=%1', _GraphApiSetup."Client Secret");
        Request += StrSubstNo('&refresh_token=%1', TypeHelper.UrlEncode(RefreshToken));
    end;

    local procedure GetTokensFromResponse(ResponseMessage: HttpResponseMessage; var AccessToken: Text; var NewRefreshToken: Text)
    var
        Response: Text;
        JOResponse: JsonObject;
        JTAccessToken, JTRefreshToken : JsonToken;
    begin
        ResponseMessage.Content.ReadAs(Response);
        JOResponse.ReadFrom(Response);
        JOResponse.SelectToken('access_token', JTAccessToken);
        AccessToken := JTAccessToken.AsValue().AsText();
        JOResponse.SelectToken('refresh_token', JTRefreshToken);
        NewRefreshToken := JTRefreshToken.AsValue().AsText();
    end;

    local procedure SecretProblem(ResponseMessage: HttpResponseMessage): Boolean
    var
        Response: Text;
    begin
        ResponseMessage.Content.ReadAs(Response);
        exit((StrPos(Response, '7000222') > 0));
    end;

    local procedure FetchNewSecret()
    begin
        _GraphApiSetup."Client Secret" := GetKeyVaultValue('GraphAPISecret');
        _GraphApiSetup.Modify();
        Commit();
    end;


    procedure GetKeyVaultValue(KeyName: Text) Value: Text[50]
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        FetchedValue: Text;
        FetchedTooLongErr: Label 'Fetched value is too long. Please contact administrator.';
    begin
        FetchedValue := AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyName);
        if StrLen(FetchedValue) > 50 then
            Error(FetchedTooLongErr);
        Value := CopyStr(FetchedValue, 1, 50);
    end;


    procedure SetDefaultsValues(GraphApiSetup: Record "NPR GraphApi Setup")
    var
        GraphAPIManagement: Codeunit "NPR Graph API Management";
        OAuthAuthorityUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize', Locked = true;
        OAuthTokenUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2/v2.0/token', Locked = true;
        GraphEventUrl: Label 'https://graph.microsoft.com/v1.0/me/events/', Locked = true;
        GraphMeUrl: Label 'https://graph.microsoft.com/v1.0/me', Locked = true;
    begin
        GraphApiSetup."Client Id" := GraphAPIManagement.GetKeyVaultValue('GraphAPIClientId');
        GraphApiSetup."Client Secret" := GraphAPIManagement.GetKeyVaultValue('GraphAPISecret');
        GraphApiSetup."OAuth Authority Url" := OAuthAuthorityUrlTxt;
        GraphApiSetup."OAuth Token Url" := OAuthTokenUrlTxt;
        GraphApiSetup."Graph Event Url" := GraphEventUrl;
        GraphApiSetup."Graph Me Url" := GraphMeUrl;
        if not GraphApiSetup.Insert() then
            GraphApiSetup.Modify();
    end;
}
