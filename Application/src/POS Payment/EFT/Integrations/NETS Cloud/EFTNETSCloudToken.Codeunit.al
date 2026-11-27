codeunit 6184533 "NPR EFT NETSCloud Token"
{
    Access = Internal;

    SingleInstance = true;

    var
        Token: Text;
        Expires: DateTime;
        _TokenKey: Text;
        _StorageKeyLbl: Label 'NPR_EFT_NETSCLOUD_TOKEN_%1_%2_%3', Locked = true;
        _RejectedResultKeyLbl: Label 'TokenRejected', Locked = true;

    procedure SetToken(TokenIn: Text)
    begin
        Expires := GetTokenExpiration(TokenIn) - (1000 * 60 * 10); //10 min subtracted to not expire in middle of trx.
        Token := TokenIn;
        Clear(_TokenKey);
    end;

    procedure TryGetToken(var TokenOut: Text): Boolean
    begin
        if (Token = '') or (Expires <= CurrentDateTime) then
            exit(false);

        TokenOut := Token;
        exit(true);
    end;

    procedure SetToken(EFTSetup: Record "NPR EFT Setup"; TokenIn: Text)
    begin
        SetSessionToken(EFTSetup, TokenIn);
        IsolatedStorage.Set(_TokenKey, TokenIn, DataScope::Company);
    end;

    procedure SetSessionToken(EFTSetup: Record "NPR EFT Setup"; TokenIn: Text)
    begin
        SetToken(TokenIn);
        _TokenKey := StorageKey(EFTSetup);
    end;

    procedure TryGetToken(EFTSetup: Record "NPR EFT Setup"; var TokenOut: Text): Boolean
    var
        TokenKey: Text;
        StoredToken: Text;
    begin
        TokenKey := StorageKey(EFTSetup);
        if not IsolatedStorage.Get(TokenKey, DataScope::Company, StoredToken) then begin
            ClearCachedToken();
            exit(false);
        end;
        if StoredToken = '' then begin
            ClearCachedToken();
            exit(false);
        end;

        if (_TokenKey = TokenKey) and (Token = StoredToken) and TryGetToken(TokenOut) then
            exit(true);

        if not TrySetToken(StoredToken) then
            exit(false);

        _TokenKey := TokenKey;
        exit(TryGetToken(TokenOut));
    end;

    procedure Invalidate(EFTSetup: Record "NPR EFT Setup")
    begin
        InvalidateKey(StorageKey(EFTSetup));
    end;

    procedure Invalidate(EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup")
    begin
        InvalidateKey(StorageKey(EFTNETSCloudPaymentSetup."Payment Type POS", EFTNETSCloudPaymentSetup.Environment, EFTNETSCloudPaymentSetup."API Username"));
    end;

    procedure InvalidateCurrent()
    begin
        InvalidateKey(_TokenKey);
    end;

    procedure AddTaskResult(var TaskResult: Dictionary of [Text, Text]; TokenRejected: Boolean)
    begin
        TaskResult.Add(_RejectedResultKeyLbl, Format(TokenRejected, 0, 9));
    end;

    procedure InvalidateIfRejectedByTask(EFTTransactionRequest: Record "NPR EFT Transaction Request"; TaskResults: Dictionary of [Text, Text])
    var
        EFTSetup: Record "NPR EFT Setup";
        RejectedText: Text;
        Rejected: Boolean;
    begin
        if not TaskResults.Get(_RejectedResultKeyLbl, RejectedText) then
            exit;
        if not Evaluate(Rejected, RejectedText, 9) then
            exit;
        if not Rejected then
            exit;
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        Invalidate(EFTSetup);
    end;

    local procedure StorageKey(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
    begin
        exit(StorageKey(EFTSetup."Payment Type POS", EFTNETSCloudIntegration.GetEnvironment(EFTSetup), EFTNETSCloudIntegration.GetAPIUsername(EFTSetup)));
    end;

    local procedure InvalidateKey(TokenKey: Text)
    begin
        if (TokenKey = '') or (TokenKey = _TokenKey) then
            ClearCachedToken();
        if TokenKey = '' then
            exit;
        if IsolatedStorage.Contains(TokenKey, DataScope::Company) then
            IsolatedStorage.Delete(TokenKey, DataScope::Company);
    end;

    local procedure ClearCachedToken()
    begin
        Clear(Token);
        Clear(Expires);
        Clear(_TokenKey);
    end;

    [TryFunction]
    local procedure TrySetToken(TokenIn: Text)
    begin
        SetToken(TokenIn);
    end;

    local procedure StorageKey(PaymentTypeCode: Code[10]; Environment: Integer; APIUsername: Text): Text
    begin
        exit(CopyStr(StrSubstNo(_StorageKeyLbl, PaymentTypeCode, Environment, APIUsername), 1, 200));
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
