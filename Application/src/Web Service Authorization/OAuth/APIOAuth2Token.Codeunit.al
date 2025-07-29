codeunit 6184552 "NPR API OAuth2 Token"
{
    Access = Internal;
    SingleInstance = true;

    var
        AccessTokenLifeTime: Dictionary of [Text, DateTime];
        ClientToken: Dictionary of [Text, Text];

    [NonDebuggable]
    internal procedure CacheNewToken(JsonResponseTxt: Text; CacheKey: Text)
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

        if AccessTokenLifeTime.ContainsKey(Token) then
            AccessTokenLifeTime.Remove(Token);
        AccessTokenLifeTime.Add(Token, Lifetime);
        if ClientToken.ContainsKey(CacheKey) then
            ClientToken.Remove(CacheKey);
        ClientToken.Add(CacheKey, Token);
    end;

    [NonDebuggable]
    internal procedure CheckExistingTokenIsValid(CacheKey: Text; ClientSecret: Text): Boolean;
    begin
        exit(GetClientAccessToken(CacheKey));
    end;

    [NonDebuggable]
    internal procedure GetClientAccessToken(CacheKey: Text): Boolean
    var
        tokenExpiresAt: DateTime;
        Token: Text;
    begin
        if ClientToken.Get(CacheKey, Token) then
            if AccessTokenLifeTime.Get(Token, tokenExpiresAt) then
                if CurrentDateTime() + 10000 < tokenExpiresAt then
                    exit(true)
                else
                    ClearAccessToken(CacheKey, Token);
    end;

    local procedure ClearAccessToken(CacheKey: Text; Token: Text): text
    begin
        if AccessTokenLifeTime.Remove(Token) then;
        if ClientToken.Remove(CacheKey) then;
    end;


    [NonDebuggable]
    internal procedure GetOAuthToken(CacheKey: Text) Token: Text
    begin
        if not ClientToken.Get(CacheKey, Token) then
            exit;
    end;

}

