codeunit 6014560 "NPR FiskalyJWT"
{
    Access = Internal;
    SingleInstance = true;

    procedure SetJWT(ConnectionID: Guid; ResponseJson: JsonToken; var AccessTokenOut: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
    begin
        ResponseJson.SelectToken('access_token', JToken);
        if AccessTokens.ContainsKey(ConnectionID) then
            AccessTokens.Remove(ConnectionID);
        AccessTokens.Add(ConnectionID, JToken.AsValue().AsText());

        ResponseJson.SelectToken('access_token_expires_at', JToken);
        if AccessTokenExpiryTerm.ContainsKey(ConnectionID) then
            AccessTokenExpiryTerm.Remove(ConnectionID);
        AccessTokenExpiryTerm.Add(ConnectionID, TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger()));

        ResponseJson.SelectToken('refresh_token', JToken);
        if RefreshTokens.ContainsKey(ConnectionID) then
            RefreshTokens.Remove(ConnectionID);
        RefreshTokens.Add(ConnectionID, JToken.AsValue().AsText());

        ResponseJson.SelectToken('refresh_token_expires_at', JToken);
        if RefreshTokenExpiryTerm.ContainsKey(ConnectionID) then
            RefreshTokenExpiryTerm.Remove(ConnectionID);
        RefreshTokenExpiryTerm.Add(ConnectionID, TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger()));

        AccessTokens.Get(ConnectionID, AccessTokenOut);
    end;

    procedure GetToken(ConnectionID: Guid; var AccessTokenOut: Text; var RefreshTokenOut: Text): Boolean
    var
        NPRJobQueueMgt: Codeunit "NPR Job Queue Management";
        SelectedAccessToken: Text;
        SelectedRefreshToken: Text;
        ExpirationThresholdDateTime: DateTime;
        SelectedTokenExpiresAt: DateTime;
    begin
        AccessTokenOut := '';
        RefreshTokenOut := '';
        if not AccessTokens.Get(ConnectionID, SelectedAccessToken) or (SelectedAccessToken = '') then
            exit(false);

        ExpirationThresholdDateTime := RoundDateTime(NPRJobQueueMgt.NowWithDelayInSeconds(-120), 1000);

        if AccessTokenExpiryTerm.Get(ConnectionID, SelectedTokenExpiresAt) then
            if (ExpirationThresholdDateTime < SelectedTokenExpiresAt) and (SelectedTokenExpiresAt <> 0DT) then begin
                AccessTokenOut := SelectedAccessToken;
                exit(true);
            end;

        if RefreshTokens.Get(ConnectionID, SelectedRefreshToken) and (SelectedRefreshToken <> '') then
            if RefreshTokenExpiryTerm.Get(ConnectionID, SelectedTokenExpiresAt) then
                if (ExpirationThresholdDateTime < SelectedTokenExpiresAt) and (SelectedTokenExpiresAt <> 0DT) then
                    RefreshTokenOut := SelectedRefreshToken;

        exit(false);
    end;

    var
        AccessTokens: Dictionary of [Guid, Text];
        RefreshTokens: Dictionary of [Guid, Text];
        AccessTokenExpiryTerm: Dictionary of [Guid, DateTime];
        RefreshTokenExpiryTerm: Dictionary of [Guid, DateTime];
}
