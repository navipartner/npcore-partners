codeunit 6184533 "NPR EFT NETSCloud Token"
{
    Access = Internal;

    SingleInstance = true;

    var
        Token: Text;
        Expires: DateTime;

    procedure SetToken(TokenIn: Text)
    begin
        Expires := GetTokenExpiration(TokenIn) - (1000 * 60 * 10); //10 min subtracted to not expire in middle of trx.
        Token := TokenIn;
    end;

    procedure TryGetToken(var TokenOut: Text): Boolean
    begin
        if (Token = '') or (Expires <= CurrentDateTime) then
            exit(false);

        TokenOut := Token;
        exit(true);
    end;

    local procedure GetTokenExpiration(TokenIn: Text): DateTime
    var
        Payload: Text;
        ExpirationUnixTime: BigInteger;
        FromDateTime: DateTime;
        JObject: JsonObject;
        JToken: JsonToken;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Payload := TokenIn.Split('.').Get(2).Replace('-', '+').Replace('_', '/');

        while (StrLen(Payload) mod 4) <> 0 do begin
            Payload += '=';
        end;

        Payload := Base64Convert.FromBase64(Payload, TextEncoding::UTF8);
        JObject.ReadFrom(Payload);
        JObject.Get('exp', JToken);
        Evaluate(ExpirationUnixTime, JToken.AsValue().AsText());
        Evaluate(FromDateTime, '1970-01-01T00:00:00Z', 9);
        exit(FromDateTime + (ExpirationUnixTime * 1000));
    end;
}