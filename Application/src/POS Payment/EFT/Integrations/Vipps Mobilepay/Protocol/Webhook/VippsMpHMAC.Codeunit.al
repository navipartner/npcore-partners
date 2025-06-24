codeunit 6184730 "NPR Vipps Mp HMAC"
{
    Access = Internal;

    [TryFunction]
    internal procedure VerifyHMAC(HttpRequestDetails: JsonObject; Secret: Text)
    begin
        VerifyContent(HttpRequestDetails);
        VerifySignature(HttpRequestDetails, Secret);
    end;

    [TryFunction]
    local procedure VerifyContent(HttpRequestDetails: JsonObject)
    var
        _Crypto: Codeunit "Cryptography Management";
        _HashAlgorithm: Option "MD5","SHA1","SHA256","SHA384","SHA512";
        JToken: JsonToken;
        Content: Text;
        ActualHashedBase64Txt: Text;
        ExpectedHashedBase64Txt: Text;
        ContentMismatchLbl: Label 'The hash content was expected to be %1 but had value %2';
    begin
        HttpRequestDetails.Get('Content', JToken);
        Content := JToken.AsValue().AsText();
        HttpRequestDetails.Get('HeadersDictionary', JToken);
        JToken.AsObject().Get('x-ms-content-sha256', JToken);
        JToken.AsArray().Get(0, JToken);
        ExpectedHashedBase64Txt := JToken.AsValue().AsText();
        ActualHashedBase64Txt := _Crypto.GenerateHashAsBase64String(Content, _HashAlgorithm::SHA256);
        if (ActualHashedBase64Txt <> ExpectedHashedBase64Txt) then
            Error(ContentMismatchLbl, ExpectedHashedBase64Txt, ActualHashedBase64Txt);
    end;

    [TryFunction]
    local procedure VerifySignature(HttpRequestDetails: JsonObject; Secret: Text)
    var
        _Crypto: Codeunit "Cryptography Management";
        _HashAlgorithm: Option "MD5","SHA1","SHA256","SHA384","SHA512";
        JToken: JsonToken;
        Headers: JsonObject;
        CRLF: Text[1];
        HttpMethod: Text;
        Path: Text;
        Query: Text;
        X_Ms_Date: Text;
        Host: Text;
        X_Ms_Content_Sha256: Text;
        ExpectedSignedString: Text;
        ExpectedSignature: Text;
        ExpectedAuthorization: Text;
        ActualAuthorization: Text;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        ParamSecretText: SecretText;
#ENDIF
        SignatureMismatchLbl: Label 'The hash signature was expected to be %1 but had value %2';
    begin
        //CRLF[1] := 13;
        CRLF[1] := 10;
        HttpRequestDetails.Get('HttpMethod', JToken);
        HttpMethod := JToken.AsValue().AsText();

        HttpRequestDetails.Get('Path', JToken);
        Path := JToken.AsValue().AsText();

        HttpRequestDetails.Get('Query', JToken);
        Query := JToken.AsValue().AsText();

        HttpRequestDetails.Get('HeadersDictionary', JToken);
        Headers := JToken.AsObject();

        Headers.Get('x-ms-date', JToken);
        JToken.AsArray().Get(0, JToken);
        X_Ms_Date := JToken.AsValue().AsText();

        Headers.Get('Host', JToken);
        JToken.AsArray().Get(0, JToken);
        Host := JToken.AsValue().AsText();

        Headers.Get('x-ms-content-sha256', JToken);
        JToken.AsArray().Get(0, JToken);
        X_Ms_Content_Sha256 := JToken.AsValue().AsText();

        ExpectedSignedString := StrSubstNo('%1%2%3%4%5%6;%7;%8', HttpMethod, CRLF, Path, Query, CRLF, X_Ms_Date, Host, X_Ms_Content_Sha256);
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        ParamSecretText := Secret;
        ExpectedSignature := _Crypto.GenerateHashAsBase64String(ExpectedSignedString, ParamSecretText, _HashAlgorithm::SHA256);
#ELSE
        ExpectedSignature := _Crypto.GenerateHashAsBase64String(ExpectedSignedString, Secret, _HashAlgorithm::SHA256);
#ENDIF
        ExpectedAuthorization := 'HMAC-SHA256 SignedHeaders=x-ms-date;host;x-ms-content-sha256&Signature=' + ExpectedSignature;
        Headers.Get('Authorization', JToken);
        JToken.AsArray().Get(0, JToken);
        ActualAuthorization := JToken.AsValue().AsText();

        if (ExpectedAuthorization <> ActualAuthorization) then
            Error(SignatureMismatchLbl, ExpectedAuthorization, ActualAuthorization);
    end;
}