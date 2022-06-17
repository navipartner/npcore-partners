codeunit 6014560 "NPR FiskalyJWT"
{
    Access = Internal;
    SingleInstance = true;

    procedure SetJWT(ResponseJson: JsonToken; var AccessTokenOut: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
    begin
        ResponseJson.SelectToken('access_token', JToken);
        AccessToken := JToken.AsValue().AsText();
        ResponseJson.SelectToken('access_token_expires_at', JToken);
        AccessTokenExpires := TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger());
        ResponseJson.SelectToken('refresh_token', JToken);
        RefreshToken := JToken.AsValue().AsText();
        ResponseJson.SelectToken('refresh_token_expires_at', JToken);
        RefreshTokenExpires := TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger());
        AccessTokenOut := AccessToken;
    end;

    procedure GetToken(var AccessTokenOut: Text; var RefreshTokenOut: Text): Boolean
    var
        NPRJobQueueMgt: Codeunit "NPR Job Queue Management";
        ExpirationThresholdDateTime: DateTime;
    begin
        AccessTokenOut := '';
        RefreshTokenOut := '';
        if AccessToken = '' then
            exit(false);

        ExpirationThresholdDateTime := RoundDateTime(NPRJobQueueMgt.NowWithDelayInSeconds(-120), 1000);
        if (ExpirationThresholdDateTime < AccessTokenExpires) and (AccessTokenExpires <> 0DT) then begin
            AccessTokenOut := AccessToken;
            exit(true);
        end;

        if (ExpirationThresholdDateTime < RefreshTokenExpires) and (RefreshTokenExpires <> 0DT) then
            RefreshTokenOut := RefreshToken;
        exit(false);
    end;

    var
        AccessToken: Text;
        RefreshToken: Text;
        AccessTokenExpires: DateTime;
        RefreshTokenExpires: DateTime;
}
