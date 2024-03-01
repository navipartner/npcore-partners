codeunit 6184709 "NPR Vipps Mp AccessToken API"
{
    Access = Internal;
    SingleInstance = true;

    var
        _AccessTokens: Dictionary of [Text, Text];
        _AccessTokensExpiresAt: Dictionary of [Text, DateTime];

    internal procedure SetCachedAccessToken(client_id: Text; token: Text; expiresAt: DateTime)
    begin
        _AccessTokens.Set(client_id, token);
        _AccessTokensExpiresAt.Set(client_id, expiresAt);
    end;

    [TryFunction]
    internal procedure GetAccessToken(VippsMpStore: Record "NPR Vipps Mp Store"; var AccessToken: Text)
    var
        ExpiresAt: DateTime;
    begin
        GetAccessToken(VippsMpStore, AccessToken, ExpiresAt);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure GetAccessToken(VippsMpStore: Record "NPR Vipps Mp Store"; var AccessToken: Text; var ExpiresAt: DateTime)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Partner_client_id: Text;
        Partner_client_secret: Text;
        Partner_client_sub: Text;
    begin
        if (VippsMpStore."Partner API Enabled") then begin
            if (VippsMpStore.Sandbox) then Error('Can''t use Partner keys in Sandbox mode.');
            Partner_client_id := AzureKeyVaultMgt.GetAzureKeyVaultSecret('VippsMp_PartnerClientId');
            Partner_client_secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('VippsMp_PartnerClientSecret');
            Partner_client_sub := AzureKeyVaultMgt.GetAzureKeyVaultSecret('VippsMp_PartnerClientSubscribtionKey');
            GetAccessToken(VippsMpStore."Merchant Serial Number", Partner_client_id, Partner_client_secret, Partner_client_sub, False, AccessToken, ExpiresAt);
        end else begin
            GetAccessToken(VippsMpStore."Merchant Serial Number", VippsMpStore."Client Id", VippsMpStore."Client Secret", VippsMpStore."Client Sub. Key", VippsMpStore.Sandbox, AccessToken, ExpiresAt);
        end;
    end;

    [TryFunction]
    internal procedure GetAccessToken(Msn: Text; ClientId: Text; ClientSecret: Text; SubscriptionKey: Text; Sandbox: Boolean; var AccessToken: Text)
    var
        ExpiresAt: DateTime;
    begin
        GetAccessToken(Msn, ClientId, ClientSecret, SubscriptionKey, Sandbox, AccessToken, ExpiresAt);
    end;

    [TryFunction]
    internal procedure GetAccessToken(Msn: Text; ClientId: Text; ClientSecret: Text; SubscriptionKey: Text; Sandbox: Boolean; var AccessToken: Text; var ExpiresAt: DateTime)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
        Response: JsonObject;
        Token1: JsonToken;
        Token2: JsonToken;
    begin
        if (ValidateAccessToken(ClientId)) then begin
            AccessToken := _AccessTokens.Get(ClientId);
            ExpiresAt := _AccessTokensExpiresAt.Get(ClientId);
            exit;
        end;
        VippsMpUtil.InitHttpClient(Http, Sandbox);
        Http.DefaultRequestHeaders().Add('client_id', ClientId);
        Http.DefaultRequestHeaders().Add('client_secret', ClientSecret);
        Http.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', SubscriptionKey);
        Http.DefaultRequestHeaders().Add('Merchant-Serial-Number', Msn);
        Http.Post('/accesstoken/get', HttpContent, HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            Response.ReadFrom(HttpResponseTxt);
            Response.Get('access_token', Token1);
            Response.Get('expires_in', Token2);
            AccessToken := Token1.AsValue().AsText();
            //Now + (Expires in Seconds) - (10 minute buffer)
            ExpiresAt := CurrentDateTime + (Token2.AsValue().AsInteger() * 1000) - (10 * 60 * 1000);
            SetCachedAccessToken(ClientId, AccessToken, ExpiresAt);
        end else begin
            VippsMpResponseHandler.HttpErrorResponseMessage(Response, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    local procedure ValidateAccessToken(client_id: Text): Boolean
    begin
        if (not _AccessTokens.ContainsKey(client_id)) then
            exit(false);
        if (_AccessTokensExpiresAt.Get(client_id) < CurrentDateTime) then begin
            _AccessTokens.Remove(client_id);
            _AccessTokensExpiresAt.Remove(client_id);
            exit(false);
        end;
        exit(true);
    end;
}