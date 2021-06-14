codeunit 6014560 "NPR FiskalyJWT"
{
    SingleInstance = true;

    procedure SetJWT(JsonString: JsonObject; var TokenPar: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        JsonTokenValue: JsonToken;
    begin
        JsonString.SelectToken('access_token', JsonTokenValue);
        AccessToken := JsonTokenValue.AsValue().AsText();
        JsonString.SelectToken('access_token_expires_at', JsonTokenValue);
        AccessTokenExpires := TypeHelper.EvaluateUnixTimestamp(JsonTokenValue.AsValue().AsBigInteger());
        JsonString.SelectToken('refresh_token', JsonTokenValue);
        RefreshToken := JsonTokenValue.AsValue().AsText();
        JsonString.SelectToken('refresh_token_expires_at', JsonTokenValue);
        RefreshTokenExpires := TypeHelper.EvaluateUnixTimestamp(JsonTokenValue.AsValue().AsBigInteger());
        TokenPar := AccessToken;
    end;

    procedure GetToken(var TokenPar: Text; var RefreshTokenPar: Text): Boolean
    begin
        if AccessToken = '' then
            exit(false);
        if CurrentDateTime < AccessTokenExpires then
            if CurrentDateTime < RefreshTokenExpires then
                exit(false)
            else begin
                RefreshTokenPar := RefreshToken;
                exit(false);
            end
        else begin
            TokenPar := AccessToken;
            exit(true);
        end;
    end;


    var
        AccessToken: Text;
        RefreshToken: Text;
        AccessTokenExpires: DateTime;
        RefreshTokenExpires: DateTime;
}