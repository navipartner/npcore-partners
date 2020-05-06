codeunit 6184533 "EFT NETSCloud Token"
{
    // NPR5.54/MMV /20200129 CASE 364340 Created object

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Token: Text;
        Expires: DateTime;

    procedure SetToken(TokenIn: Text)
    begin
        Expires :=  GetTokenExpiration(TokenIn) - (1000 * 60 * 10);
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
        Encoding: DotNet npNetEncoding;
        Convert: DotNet npNetConvert;
        String: DotNet npNetString;
        Payload: Text;
        JObject: DotNet npNetJObject;
        ExpirationUnixTime: BigInteger;
        FromDateTime: DateTime;
        StringArray: DotNet npNetArray;
        CharArray: DotNet npNetArray;
        Char: Char;
    begin
        Char := '.';
        CharArray := CharArray.CreateInstance(GetDotNetType(Char), 1);
        CharArray.SetValue(Char, 0);

        String := TokenIn;
        StringArray := String.Split(CharArray);
        Payload := StringArray.GetValue(1);

        Payload := Encoding.UTF8.GetString(Convert.FromBase64String(Payload));
        JObject := JObject.Parse(Payload);
        Evaluate(ExpirationUnixTime, JObject.Item('exp').ToString());
        Evaluate(FromDateTime, '1970-01-01T00:00:00Z', 9);
        exit(FromDateTime + (ExpirationUnixTime * 1000));
    end;
}

