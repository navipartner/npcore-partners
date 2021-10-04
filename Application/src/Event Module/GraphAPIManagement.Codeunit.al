codeunit 6014606 "NPR Graph API Management"
{
    var
        GraphApiSetup: Record "NPR GraphApi Setup";

    internal procedure GetAccessToken(EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail")
    var
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        PromptInteraction: Enum "Prompt Interaction";
        AccessToken, TokenCache : Text;
        RedirectURL, AuthCodeError : Text;
        AccesTokenMsg: Label 'Access token acquired.';
    begin
        AddScopes(Scopes);
        GetTestGraphAPISetup();
        OAuth2.GetDefaultRedirectURL(RedirectURL);
        OAuth2.AcquireTokenAndTokenCacheByAuthorizationCode(GraphApiSetup."Client Id", GraphApiSetup."Client Secret", GraphApiSetup."OAuth Authority Url", RedirectURL, Scopes, PromptInteraction::Login, AccessToken, TokenCache, AuthCodeError);

        if (AccessToken = '') or (AuthCodeError <> '') then
            Error(AuthCodeError);

        SetAccessToken(EventExchIntEMail, AccessToken, GetRefreshTokenFromTokenCache(TokenCache));

        Message(AccesTokenMsg);
    end;

    internal procedure DeleteEvent(EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; CalendarItemID: Text): Boolean
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AccessToken, URL : Text;
        DeletedMsg: Label 'Event deleted';
    begin
        GetTestGraphAPISetup();
        URL := GraphApiSetup."Graph Event Url" + CalendarItemID;
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'DELETE', URL);

        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() then begin
                Message(DeletedMsg);
                exit(true);
            end else begin
                LogResponse('Delete Event', EventExchIntEMail."E-Mail", URL, '', ResponseMessage);
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
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'GET', GraphApiSetup."Graph Event Url" + CalendarItemID);

        if Client.Send(RequestMessage, ResponseMessage) then
            exit(ResponseMessage.IsSuccessStatusCode())
        else
            exit(false);
    end;

    internal procedure GetEventContent(EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; CalendarItemID: Text) ResponseContent: Text
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AccessToken, URL : Text;
        ErrorMsg: Label 'Error getting information for Event ID %1.';
    begin
        GetTestGraphAPISetup();
        URL := GraphApiSetup."Graph Event Url" + CalendarItemID;
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'GET', URL);

        if Client.Send(RequestMessage, ResponseMessage) then
            ResponseMessage.Content.ReadAs(ResponseContent)
        else begin
            LogResponse('Get Event Content', EventExchIntEMail."E-Mail", URL, '', ResponseMessage);
            Message(ErrorMsg, CalendarItemID);
        end;
    end;

    internal procedure SendEventRequest(EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; Request: Text) CalendarItemID: Text
    var
        AccessToken: Text;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        GetTestGraphAPISetup();
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'POST', GraphApiSetup."Graph Event Url");

        SetMessageContent(Request, Content, RequestMessage);
        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() then
                GetEventID(CalendarItemID, ResponseMessage)
            else
                LogResponse('Event Create', EventExchIntEMail."E-Mail", GraphApiSetup."Graph Event Url", Request, ResponseMessage);
    end;

    internal procedure SendEventRequestUpdate(EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; Request: Text; CalendarItemID: Text)
    var
        AccessToken, URL : Text;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        UpdatedMsg: Label 'Event updated.';
    begin
        GetTestGraphAPISetup();
        URL := GraphApiSetup."Graph Event Url" + CalendarItemID;
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'PATCH', URL);

        SetMessageContent(Request, Content, RequestMessage);
        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() then
                Message(UpdatedMsg)
            else
                LogResponse('Event Update', EventExchIntEMail."E-Mail", URL, Request, ResponseMessage);
    end;

    internal procedure AddAttachment(EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; Request: Text; CalendarItemID: Text)
    var
        AccessToken, URL : Text;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        GetTestGraphAPISetup();
        URL := GraphApiSetup."Graph Event Url" + CalendarItemID + '/attachments';
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'POST', URL);
        SetMessageContent(Request, Content, RequestMessage);
        if Client.Send(RequestMessage, ResponseMessage) then
            if not ResponseMessage.IsSuccessStatusCode() then
                LogResponse('Add Event Attachment', EventExchIntEMail."E-Mail", URL, Request, ResponseMessage);
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
        RefreshToken, NewRefreshToken : Text;
        Scopes: List of [Text];
    begin
        GetTestGraphAPISetup();
        AddScopes(Scopes);
        RefreshToken := EventExchIntEMail.GetRefreshToken();
        PrepareRefreshTokenRequest(RefreshToken, Client, RequestMessage);

        if Client.Send(RequestMessage, ResponseMessage) then begin
            GetTokensFromResponse(ResponseMessage, AccessToken, NewRefreshToken);
        end else begin
            LogResponse('Refresh Token', EventExchIntEMail."E-Mail", GraphApiSetup."OAuth Token Url", '', ResponseMessage);
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
        InitializeRequest(EventExchIntEMail, AccessToken, Client, RequestMessage, 'GET', GraphApiSetup."Graph Me Url");

        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(Response);
            Message(OkLbl, GetEmail(Response));
        end else begin
            LogResponse('Test Connection', EventExchIntEMail."E-Mail", GraphApiSetup."Graph Me Url", '', ResponseMessage);
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

    local procedure LogResponse(Description: Text; EMail: Text[50]; URL: Text; Request: Text; ResponseMessage: HttpResponseMessage)
    var
        GraphAPIWSLog: Record "NPR GraphAPI WS Log";
        Response: Text;
    begin
        ResponseMessage.Content.ReadAs(Response);
        GraphAPIWSLog.LogCall(Description, Request, Response, URL, EMail);
    end;

    local procedure SetAccessToken(var EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail"; NewAccessToken: Text; NewRefreshToken: Text)
    var
        Outstream: OutStream;
    begin
        EventExchIntEMail."Access Token".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewAccessToken);
        EventExchIntEMail."Refresh Token".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewRefreshToken);
        EventExchIntEMail."Acces Token Valid Until" := CurrentDateTime() + 1000 * 59 * 59; //token TTL is 59m59s
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

    local procedure GetRefreshTokenFromTokenCache(TokenCache: Text) RefreshToken: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        TokenCacheCoverted: Text;
        JOTokenCache: JsonObject;
        JTRefreshToken, JTSecret : JsonToken;
    begin
        if TokenCache = '' then
            exit('');
        TokenCacheCoverted := Base64Convert.FromBase64(TokenCache);
        JOTokenCache.ReadFrom(TokenCacheCoverted);
        JOTokenCache.SelectToken('RefreshToken', JTRefreshToken);
        JTRefreshToken.SelectToken('*.secret', JTSecret);
        RefreshToken := JTSecret.AsValue().AsText();
    end;

    local procedure GetTestGraphAPISetup()
    begin
        GraphApiSetup.Get();
        GraphApiSetup.TestField("Client Id");
        GraphApiSetup.TestField("Client Secret");
        GraphApiSetup.TestField("Graph Event Url");
        GraphApiSetup.TestField("Graph Me Url");
        GraphApiSetup.TestField("OAuth Authority Url");
        GraphApiSetup.TestField("OAuth Token Url");
    end;




    local procedure PrepareRefreshTokenRequest(RefreshToken: Text; Client: HttpClient; RequestMessage: HttpRequestMessage)
    var
        Content: HttpContent;
        MessageHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        RefreshRequest: Text;
    begin
        RefreshRequest := GetRefreshTokenRequest(RefreshToken);

        Client.Clear();
        Clear(RequestMessage);
        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(GraphApiSetup."OAuth Token Url");
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
        Request := StrSubstNo('client_id=%1', GraphApiSetup."Client Id");
        Request += '&scope=offline_access%20https%3A%2F%2Fgraph.microsoft.com%2FCalendars.ReadWrite';
        Request += '&redirect_uri=https%3A%2F%2Flocalhost';
        Request += '&grant_type=refresh_token';
        Request += StrSubstNo('&client_secret=%1', GraphApiSetup."Client Secret");
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

#IF BC17
    procedure RunGraphAPIWizard(GraphAPIWizard: Notification)
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.Run(Page::"NPR GraphApi Setup Wizard");
    end;
#ELSE
    procedure RunGraphAPIWizard(GraphAPIWizard: Notification)
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        GuidedExperience.Run(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR GraphApi Setup Wizard");
    end;
#ENDIF
}
