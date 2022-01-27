codeunit 6014520 "NPR MobilePayV10 Token"
{
    Access = Internal;
    SingleInstance = true;

    var
        _token: Text;
        _tokenExpiryTime: DateTime;


    procedure TryGetToken(var outToken: Text): Boolean
    begin
        if (_token = '') or (_tokenExpiryTime <= CurrentDateTime) then
            exit(false);

        outToken := _token;
        exit(true);
    end;

    procedure SetToken(json: JsonObject)
    var
        expiresIn: JsonToken;
        token: JsonToken;
    begin
        json.SelectToken('expires_in', expiresIn);
        _tokenExpiryTime := CurrentDateTime + (expiresIn.AsValue().AsInteger() * 1000) - (60 * 10 * 1000); //10 minute buffer so we don't expire in the middle of future transactions.        

        json.SelectToken('access_token', token);
        _token := token.AsValue().AsText();
    end;
}
