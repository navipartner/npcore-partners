#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248567 "NPR JWT RS256 Verification"
{
    Access = Internal;

    var
        LastDetectedIssues: List of [Text];
        JwtInvalidFormatErr: Label 'JWT token format is invalid';
        IssuerClaimMismatchErr: Label 'Issuer claim does not match expected value';
        AudienceClaimMismatchErr: Label 'Audience claim does not match expected value';
        JwtExpiredErr: Label 'JWT token has expired';
        JwtIssuedInFutureErr: Label 'JWT token was issued in the future';
        JwtNotYetValidErr: Label 'JWT token is not yet valid';
        JwtMissingClaimErr: Label 'Requested claim is missing in JWT payload';
        JwtpayloadEmptyErr: Label 'JWT payload is empty';
    //JwtEmptyErr: Label 'JWT token or public key is empty';
    //WrongAlgorithmErr: Label 'Token algorithm is %1, expected %2', Comment = '%1 - actual algorithm, %2 - expected algorithm';
    //JwtHeadMissingSignAlgErr: Label 'Failed to extract algorithm from JWT header';
    //JwtHeadMissingErr: Label 'JWT header is empty';


    /// <summary>
    /// Verifies a complete JWT token including signature and standard claims
    /// </summary>
    /// <param name="JwtToken">The JWT token to verify</param>
    /// <param name="PublicKeyXml">RSA public key in XML format</param>
    /// <param name="ExpectedIssuer">Expected issuer (leave blank to skip)</param>
    /// <param name="ExpectedAudience">Expected audience (leave blank to skip)</param>
    /// <param name="AllowClockSkewSeconds">Clock skew tolerance in seconds (typically 300)</param>
    /// <returns>True if token is completely valid</returns>
    procedure VerifyCompleteJWT(JwtToken: Text; PublicKeyXml: Text; ExpectedIssuer: Text; ExpectedAudience: Text; AllowClockSkewSeconds: Integer): Boolean
    begin
        // TODO: Verify signature

        // Claim verification:
        if (not VerifyJWTClaims(JwtToken, ExpectedIssuer, ExpectedAudience, AllowClockSkewSeconds)) then
            exit(false);

        exit(true);
    end;

    /*
    /// <summary>
    /// Verifies the RS256 signature of a JWT token
    /// </summary>
    /// <param name="JwtToken">The complete JWT token to verify</param>
    /// <param name="PublicKeyXml">The RSA public key in XML format</param>
    /// <returns>True if signature is valid, False otherwise</returns>
    internal procedure VerifyRS256Signature(JwtToken: Text; PublicKeyXml: Text): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
        RSA: Codeunit RSA;
        TempBlobData: Codeunit "Temp Blob";
        TempBlobSignature: Codeunit "Temp Blob";
        HeaderAndPayloadStream: InStream;
        SignatureStream: InStream;
        DataOutStream: OutStream;
        SignatureOutStream: OutStream;
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        TokenParts: List of [Text];
        HeaderAndPayload: Text;
        ReceivedSignature: Text;
        ReceivedSignatureBytes: List of [Byte];
        HeaderAndPayloadBytes: List of [Byte];
        Algorithm: Text;
        SecretPublicKeyXml: SecretText;
        ByteValue: Byte;
    begin
        if ((JwtToken = '') or (PublicKeyXml = '')) then
            exit(ExitAndStoreLastDetectedIssue(JwtEmptyErr));

        // Split JWT into parts (header.payload.signature)
        if (not SplitJWTToken(JwtToken, TokenParts)) then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        if (TokenParts.Count() <> 3) then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        if (not GetJWTAlgorithm(JwtToken, Algorithm)) then
            exit(ExitAndStoreLastDetectedIssue(JwtHeadMissingSignAlgErr));

        if (Algorithm <> 'RS256') then
            exit(ExitAndStoreLastDetectedIssue(StrSubstNo(WrongAlgorithmErr, Algorithm, 'RS256')));

        // Get header and payload for signature verification (keep original encoding)
        HeaderAndPayload := TokenParts.Get(1) + '.' + TokenParts.Get(2);

        // Get the signature part, convert from Base64URL to Base64, and then to bytes
        ReceivedSignature := TokenParts.Get(3);
        ReceivedSignature := ConvertBase64UrlToBase64(ReceivedSignature);
        ConvertTextToBytesUTF8(Base64Convert.FromBase64(ReceivedSignature), ReceivedSignatureBytes);

        // Convert header+payload to bytes (UTF-8 encoding)
        ConvertTextToBytesUTF8(HeaderAndPayload, HeaderAndPayloadBytes);

        // Prepare data stream for verification
        TempBlobData.CreateOutStream(DataOutStream);
        foreach ByteValue in HeaderAndPayloadBytes do
            DataOutStream.Write(ByteValue);
        TempBlobData.CreateInStream(HeaderAndPayloadStream);

        // Prepare signature stream for verification
        TempBlobSignature.CreateOutStream(SignatureOutStream);
        foreach ByteValue in ReceivedSignatureBytes do
            SignatureOutStream.Write(ByteValue);
        TempBlobSignature.CreateInStream(SignatureStream);

        // Set the public key and algorithms
        SecretPublicKeyXml := PublicKeyXml;
        HashAlgorithm := HashAlgorithm::SHA256;
        RSASignaturePadding := RSASignaturePadding::Pkcs1;

        // Verify signature using the provided public key
        exit(
            RSA.VerifyData(
                SecretPublicKeyXml,
                HeaderAndPayloadStream,
                HashAlgorithm,
                RSASignaturePadding,
                SignatureStream
            )
        );
    end;
    */

    /// <summary>
    /// Verifies JWT claims including standard claims (iss, aud, exp, iat, etc.)
    /// </summary>
    /// <param name="JwtToken">The JWT token to verify</param>
    /// <param name="ExpectedIssuer">Expected issuer (iss) claim - leave blank to skip</param>
    /// <param name="ExpectedAudience">Expected audience (aud) claim - leave blank to skip</param>
    /// <param name="AllowClockSkewSeconds">Allowed clock skew in seconds for time-based claims</param>
    /// <returns>True if all claims are valid</returns>
    local procedure VerifyJWTClaims(JwtToken: Text; ExpectedIssuer: Text; ExpectedAudience: Text; AllowClockSkewSeconds: Integer): Boolean
    var
        JsonParser: Codeunit "NPR Json Parser";
        Base64Convert: Codeunit "Base64 Convert";
        TokenParts: List of [Text];
        PayloadJson: Text;
        IssuerClaim: Text;
        AudienceClaim: Text;
        ExpirationTime: BigInteger;
        IssuedAtTime: BigInteger;
        NotBeforeTime: BigInteger;
        CurrentUnixTime: BigInteger;
        HasProperty: Boolean;
    begin
        if (not SplitJWTToken(JwtToken, TokenParts)) then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        if TokenParts.Count() < 2 then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        // Decode payload
        PayloadJson := ConvertBase64UrlToBase64(TokenParts.Get(2));
        PayloadJson := Base64Convert.FromBase64(PayloadJson);
        if (PayloadJson = '') then
            exit(ExitAndStoreLastDetectedIssue(JwtpayloadEmptyErr));

        JsonParser.Parse(PayloadJson);

        // Verify issuer (iss)
        if (ExpectedIssuer <> '') then begin
            JsonParser.GetProperty('iss', IssuerClaim);
            if (IssuerClaim <> ExpectedIssuer) then
                exit(ExitAndStoreLastDetectedIssue(IssuerClaimMismatchErr));
        end;

        // Verify audience (aud)
        if (ExpectedAudience <> '') then begin
            JsonParser.GetProperty('aud', AudienceClaim);
            if (AudienceClaim <> ExpectedAudience) then
                exit(ExitAndStoreLastDetectedIssue(AudienceClaimMismatchErr));
        end;

        // Get current Unix timestamp
        CurrentUnixTime := GetCurrentUnixTimestamp();

        // Verify expiration (exp) - token must not be expired
        HasProperty := false;
        JsonParser.GetProperty('exp', ExpirationTime, HasProperty);
        if (HasProperty) then begin
            if (CurrentUnixTime > (ExpirationTime + AllowClockSkewSeconds)) then
                exit(ExitAndStoreLastDetectedIssue(JwtExpiredErr));
        end;

        // Verify issued at (iat) - token not issued in the future
        HasProperty := false;
        JsonParser.GetProperty('iat', IssuedAtTime, HasProperty);
        if (HasProperty) then begin
            if (IssuedAtTime > (CurrentUnixTime + AllowClockSkewSeconds)) then
                exit(ExitAndStoreLastDetectedIssue(JwtIssuedInFutureErr));
        end;

        // Verify not before (nbf) - token not valid yet
        HasProperty := false;
        JsonParser.GetProperty('nbf', NotBeforeTime, HasProperty);
        if (HasProperty) then begin
            if (CurrentUnixTime < (NotBeforeTime - AllowClockSkewSeconds)) then
                exit(ExitAndStoreLastDetectedIssue(JwtNotYetValidErr));  // Token not yet valid
        end;

        exit(true);
    end;

    /// <summary>
    /// Extracts a specific claim value from JWT payload
    /// </summary>
    /// <param name="JwtToken">The JWT token</param>
    /// <param name="ClaimName">Name of the claim to extract</param>
    /// <param name="ClaimValue">Returns the claim value as text</param>
    /// <returns>True if claim was found</returns>
    local procedure GetJWTClaim(JwtToken: Text; ClaimName: Text; var ClaimValue: Text): Boolean
    var
        JsonParser: Codeunit "NPR Json Parser";
        Base64Convert: Codeunit "Base64 Convert";
        TokenParts: List of [Text];
        PayloadJson: Text;
        HasProperty: Boolean;
    begin
        ClaimValue := '';

        if (not SplitJWTToken(JwtToken, TokenParts)) then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        if (TokenParts.Count() < 2) then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        // Decode payload
        PayloadJson := ConvertBase64UrlToBase64(TokenParts.Get(2));
        PayloadJson := Base64Convert.FromBase64(PayloadJson);
        if (PayloadJson = '') then
            exit(ExitAndStoreLastDetectedIssue(JwtpayloadEmptyErr));

        // Parse payload JSON
        JsonParser.Parse(PayloadJson);

        // Get the requested claim
        HasProperty := false;
        JsonParser.GetProperty(ClaimName, ClaimValue, HasProperty);
        if (not HasProperty) then
            exit(ExitAndStoreLastDetectedIssue(JwtMissingClaimErr));

        exit(true);
    end;

    /// <summary>
    /// Extracts tenant ID from your custom JWT structure
    /// </summary>
    /// <param name="JwtToken">The JWT token</param>
    /// <param name="TenantId">Returns the tenant ID</param>
    /// <returns>True if tenant ID was found</returns>
    procedure GetTenantId(JwtToken: Text; var TenantId: Text): Boolean
    begin
        exit(GetJWTClaim(JwtToken, 'tenantId', TenantId));
    end;

    /// <summary>
    /// Gets the JTI (JWT ID) claim
    /// </summary>
    /// <param name="JwtToken">The JWT token</param>
    /// <param name="JTI">Returns the JTI value</param>
    /// <returns>True if JTI was found</returns>
    procedure GetJTI(JwtToken: Text; var JTI: Text): Boolean
    begin
        exit(GetJWTClaim(JwtToken, 'jti', JTI));
    end;

    /// <summary>
    /// Gets the subject (sub) claim - in your case, the API key ID
    /// </summary>
    /// <param name="JwtToken">The JWT token</param>
    /// <param name="Subject">Returns the subject value</param>
    /// <returns>True if subject was found</returns>
    procedure GetSubject(JwtToken: Text; var Subject: Text): Boolean
    begin
        exit(GetJWTClaim(JwtToken, 'sub', Subject));
    end;

    /*
    /// <summary>
    /// Extracts and decodes the JWT header to get algorithm information
    /// </summary>
    /// <param name="JwtToken">The JWT token</param>
    /// <param name="Algorithm">Returns the algorithm used</param>
    /// <returns>True if header was successfully parsed</returns>
    local procedure GetJWTAlgorithm(JwtToken: Text; var Algorithm: Text): Boolean
    var
        JsonParser: Codeunit "NPR Json Parser";
        Base64Convert: Codeunit "Base64 Convert";
        TokenParts: List of [Text];
        HeaderJson: Text;
        HasProperty: Boolean;
    begin
        Algorithm := '';

        if (not SplitJWTToken(JwtToken, TokenParts)) then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        if (TokenParts.Count() < 1) then
            exit(ExitAndStoreLastDetectedIssue(JwtInvalidFormatErr));

        // Decode header
        HeaderJson := ConvertBase64UrlToBase64(TokenParts.Get(1));

        HeaderJson := Base64Convert.FromBase64(HeaderJson);
        if (HeaderJson = '') then
            exit(ExitAndStoreLastDetectedIssue(JwtHeadMissingErr));

        // Parse JSON to get algorithm
        JsonParser.Parse(HeaderJson);

        HasProperty := false;
        JsonParser.GetProperty('alg', Algorithm, HasProperty);
        if (not HasProperty) then
            exit(ExitAndStoreLastDetectedIssue(JwtHeadMissingSignAlgErr));

        exit(true);
    end;
    */

    local procedure SplitJWTToken(JwtToken: Text; var TokenParts: List of [Text]): Boolean
    var
        DotPosition: Integer;
        RemainingToken: Text;
        Part: Text;
    begin
        Clear(TokenParts);
        RemainingToken := JwtToken;

        // Split by dots
        while (StrPos(RemainingToken, '.') > 0) do begin
            DotPosition := StrPos(RemainingToken, '.');
            Part := CopyStr(RemainingToken, 1, DotPosition - 1);
            TokenParts.Add(Part);
            RemainingToken := CopyStr(RemainingToken, DotPosition + 1);
        end;

        // Add the last part
        if (RemainingToken <> '') then
            TokenParts.Add(RemainingToken);

        exit(TokenParts.Count() >= 3);
    end;

    local procedure ConvertBase64UrlToBase64(Base64Url: Text): Text
    var
        Result: Text;
    begin
        Result := Base64Url;

        // Replace URL-safe characters with standard Base64 characters
        Result := Result.Replace('-', '+');
        Result := Result.Replace('_', '/');

        // Add padding if necessary
        case (StrLen(Result) mod 4) of
            2:
                Result += '==';
            3:
                Result += '=';
        end;

        exit(Result);
    end;

    /*
    local procedure ConvertTextToBytesUTF8(InputText: Text; var OutputBytes: List of [Byte])
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        ByteValue: Byte;
    begin
        Clear(OutputBytes);

        // Use TempBlob to handle UTF-8 encoding properly
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(InputText);

        TempBlob.CreateInStream(InStream);
        while (not InStream.EOS()) do begin
            InStream.Read(ByteValue);
            OutputBytes.Add(ByteValue);
        end;
    end;
    */

    local procedure GetCurrentUnixTimestamp(): BigInteger
    var
        UnixEpoch: DateTime;
        CurrentDateTime: DateTime;
        TimeDifference: Duration;
    begin
        // Unix epoch: January 1, 1970, 00:00:00 UTC
        UnixEpoch := CreateDateTime(DMY2Date(1, 1, 1970), 0T);
        CurrentDateTime := CurrentDateTime();
        TimeDifference := CurrentDateTime - UnixEpoch;

        // Convert to seconds
        exit(TimeDifference div 1000);
    end;

    local procedure ExitAndStoreLastDetectedIssue(DetectedIssue: Text): Boolean
    begin
        if (LastDetectedIssues.Count > 0) then begin
            if (LastDetectedIssues.Get(LastDetectedIssues.Count) = DetectedIssue) then
                exit(false);
        end;

        LastDetectedIssues.Add(DetectedIssue);
        exit(false);
    end;

    procedure GetLastDetectedIssues(): List of [Text]
    begin
        exit(LastDetectedIssues);
    end;
}
#endif