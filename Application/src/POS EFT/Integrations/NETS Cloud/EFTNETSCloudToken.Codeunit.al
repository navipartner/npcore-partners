codeunit 6184533 "NPR EFT NETSCloud Token"
{
    Access = Internal;
    // NPR5.54/MMV /20200129 CASE 364340 Created object
    // NPR5.55/MMV /20200420 CASE 386254 Added WF2 methods, unattended lookup skip & fixed sale completion check.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Token: Text;
        Expires: DateTime;

    procedure SetToken(TokenIn: Text)
    begin
        Expires := GetTokenExpiration(TokenIn) - (1000 * 60 * 10);
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
        Encoding: DotNet NPRNetEncoding;
        Convert: DotNet NPRNetConvert;
        String: DotNet NPRNetString;
        Payload: Text;
        JObject: DotNet NPRNetJObject;
        ExpirationUnixTime: BigInteger;
        FromDateTime: DateTime;
        StringArray: DotNet NPRNetArray;
        CharArray: DotNet NPRNetArray;
        Char: Char;
    begin
        Char := '.';
        CharArray := CharArray.CreateInstance(GetDotNetType(Char), 1);
        CharArray.SetValue(Char, 0);

        String := TokenIn;
        StringArray := String.Split(CharArray);
        //-NPR5.55 [386254]
        String := StringArray.GetValue(1);
        String := String.Replace('-', '+');
        String := String.Replace('_', '/');
        Payload := String;

        while (StrLen(Payload) mod 4) <> 0 do begin
            Payload += '=';
        end;
        //+NPR5.55 [386254]

        Payload := Encoding.UTF8.GetString(Convert.FromBase64String(Payload));
        JObject := JObject.Parse(Payload);
        Evaluate(ExpirationUnixTime, JObject.Item('exp').ToString());
        Evaluate(FromDateTime, '1970-01-01T00:00:00Z', 9);
        exit(FromDateTime + (ExpirationUnixTime * 1000));
    end;
}

