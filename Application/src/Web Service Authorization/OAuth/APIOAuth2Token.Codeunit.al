codeunit 6184552 "NPR API OAuth2 Token"
{
    Access = Internal;
    SingleInstance = true;

    var
        Client: Dictionary of [Text, Text];
        AccessToken: Dictionary of [Text, DateTime];
        ClientToken: Dictionary of [Text, Text];

    [NonDebuggable]
    internal procedure CacheNewToken(JsonResponseTxt: Text; ClientId: Text)
    var
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        Token: Text;
        Lifetime: DateTime;
    begin
        JsonObj.ReadFrom(JsonResponseTxt);
        if JsonObj.SelectToken('access_token', JsonTok) then
            Token := JsonTok.AsValue().AsText();
        if JsonObj.SelectToken('expires_in', JsonTok) then
            Lifetime := CurrentDateTime + (JsonTok.AsValue().AsInteger() * 1000);

        if AccessToken.ContainsKey(Token) then
            AccessToken.Remove(Token);
        AccessToken.Add(Token, Lifetime);
        if ClientToken.ContainsKey(ClientId) then
            ClientToken.Remove(ClientId);
        ClientToken.Add(ClientId, Token);
    end;

    [NonDebuggable]
    internal procedure CheckExistingTokenIsValid(ClientId: Text; ClientSecret: Text): Boolean;
    begin
        If Client.Get(ClientId, ClientSecret) then
            exit(GetClientAccessToken(ClientId));
        Client.Add(ClientId, ClientSecret);
    end;

    [NonDebuggable]
    internal procedure GetClientAccessToken(ClientID: Text): Boolean
    var
        tokenExpiresAt: DateTime;
        Token: Text;
    begin
        if ClientToken.Get(ClientID, Token) then
            if AccessToken.Get(Token, tokenExpiresAt) then
                if CurrentDateTime() + 10000 < tokenExpiresAt then
                    exit(true)
                else
                    ClearAccessToken();
    end;

    internal procedure ClearAccessToken(): text
    begin
        Clear(AccessToken);
        Clear(ClientToken);
    end;


    [NonDebuggable]
    internal procedure GetOAuthToken(ClientId: Text) Token: Text
    begin
        if not ClientToken.Get(ClientId, Token) then
            exit;
    end;

}

