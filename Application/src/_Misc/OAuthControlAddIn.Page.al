page 6059982 "NPR OAuth ControlAddIn"
{
    Extensible = false;
    Caption = 'Waiting for a response - do not close this page';
    PageType = NavigatePage;
    Editable = false;
    LinksAllowed = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            usercontrol(OAuthIntegration; OAuthControlAddIn)
            {
                ApplicationArea = NPRRetail;

                trigger AuthorizationCodeRetrieved(AuthCode: Text)
                begin
                    HandleAuthCodeResponse(AuthCode);
                    CurrPage.Close();
                end;

                trigger AuthorizationErrorOccurred(AuthError: Text; AuthErrorDescription: Text)
                begin
                    _AuthError := StrSubstNo(_AuthErrorLbl, AuthError, AuthErrorDescription);
                    CurrPage.Close();
                end;

                trigger ControlAddInReady()
                begin
                    CurrPage.OAuthIntegration.StartAuthorization(_OAuthRequestUrl);
                end;
            }
        }
    }
    var
        _OAuthRequestUrl: Text;
        _AuthCode: Text;
        _ReturnedState: Integer;
        _AuthError: Text;
        _AuthErrorLbl: Label 'Error: %1, description: %2', Comment = '%1 = error code, %2 = error description';
        _TenantId: Text;

    local procedure HandleAuthCodeResponse(Response: Text)
    var
        Params: List of [Text];
        ParamPair: Text;
        ParamKV: List of [Text];
        ParamKey: Text;
        ParamValue: Text;
    begin
        Params := Response.Split('&');
        foreach ParamPair in Params do begin
            ParamKV := ParamPair.Split('=');
            ParamKey := ParamKV.Get(1);
            ParamValue := ParamKV.Get(2);

            case ParamKey.ToLower() of
                'code':
                    _AuthCode := ParamValue;
                'state':
                    Evaluate(_ReturnedState, ParamValue);
            end;
        end;
    end;

    internal procedure SetRequestProps(RequestUrl: Text)
    begin
        _OAuthRequestUrl := RequestUrl;
    end;

    internal procedure GetAuthCode(): Text
    begin
        exit(_AuthCode);
    end;

    internal procedure GetAuthError(): Text
    begin
        exit(_AuthError);
    end;

    internal procedure GetReturnedState(): Integer
    begin
        exit(_ReturnedState);
    end;

    internal procedure SetTenant(TenantId: Text)
    begin
        _TenantId := TenantId;
    end;

    internal procedure RequestToken(AuthCode: Text; RedirectUrl: Text; ClientId: Text; ClientSecret: Text; var AccessToken: Text)
    var
        RefreshToken: Text;
    begin
        RequestToken(AuthCode, RedirectUrl, ClientId, ClientSecret, AccessToken, RefreshToken);
    end;

    internal procedure RequestToken(AuthCode: Text; RedirectUrl: Text; ClientId: Text; ClientSecret: Text; var AccessToken: Text; var RefreshToken: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestText: Text;
        ResponseMsg: HttpResponseMessage;
        ResponseJson: JsonToken;
        TempToken: JsonToken;
    begin
        RequestText := StrSubstNo(
            'code=%1&redirect_uri=%2&client_id=%3&client_secret=%4&grant_type=authorization_code',
            AuthCode,
            TypeHelper.UrlEncode(RedirectUrl),
            ClientId,
            ClientSecret
        );

        Content.WriteFrom(RequestText);
        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/x-www-form-urlencoded');

        if _TenantId = '' then
            _TenantId := 'common';
        Client.Post(StrSubstNo('https://login.microsoftonline.com/%1/oauth2/v2.0/token', _TenantId), Content, ResponseMsg);

        ResponseJson := ParseResponseAsJson(ResponseMsg);
        if ResponseJson.SelectToken('access_token', TempToken) then
            AccessToken := TempToken.AsValue().AsText();
        if ResponseJson.SelectToken('refresh_token', TempToken) then
            RefreshToken := TempToken.AsValue().AsText();
    end;

    local procedure SetHeader(var Headers: HttpHeaders; Name: Text; Value: Text)
    begin
        if (Headers.Contains(Name)) then
            Headers.Remove(Name);
        Headers.Add(Name, Value);
    end;

    local procedure ParseResponseAsJson(Response: HttpResponseMessage) ResponseJson: JsonToken
    var
        ResponseText: Text;
    begin
        Response.Content().ReadAs(ResponseText);
        ResponseJson.ReadFrom(ResponseText)
    end;
}