codeunit 6184862 "NPR AT Fiskaly JWT"
{
    Access = Internal;
    SingleInstance = true;

    var
        AccessTokenExpiryTerm: Dictionary of [Guid, DateTime];
        RefreshTokenExpiryTerm: Dictionary of [Guid, DateTime];
        AccessTokens: Dictionary of [Guid, Text];
        RefreshTokens: Dictionary of [Guid, Text];

    internal procedure GetToken(ConnectionID: Guid; var AccessTokenOut: Text; var RefreshTokenOut: Text): Boolean
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        ExpirationThresholdDateTime: DateTime;
        SelectedTokenExpiresAt: DateTime;
        SelectedAccessToken: Text;
        SelectedRefreshToken: Text;
    begin
        if not AccessTokens.Get(ConnectionID, SelectedAccessToken) or (SelectedAccessToken = '') then
            exit(false);

        ExpirationThresholdDateTime := RoundDateTime(JobQueueManagement.NowWithDelayInSeconds(-120), 1000);

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

    internal procedure SetToken(ConnectionId: Guid; ResponseJson: JsonToken; var AccessTokenOut: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
    begin
        ResponseJson.SelectToken('access_token', JToken);
        if AccessTokens.ContainsKey(ConnectionId) then
            AccessTokens.Remove(ConnectionId);
        AccessTokens.Add(ConnectionId, JToken.AsValue().AsText());

        ResponseJson.SelectToken('access_token_expires_at', JToken);
        if AccessTokenExpiryTerm.ContainsKey(ConnectionId) then
            AccessTokenExpiryTerm.Remove(ConnectionId);
        AccessTokenExpiryTerm.Add(ConnectionId, TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger()));

        ResponseJson.SelectToken('refresh_token', JToken);
        if RefreshTokens.ContainsKey(ConnectionId) then
            RefreshTokens.Remove(ConnectionId);
        RefreshTokens.Add(ConnectionId, JToken.AsValue().AsText());

        ResponseJson.SelectToken('refresh_token_expires_at', JToken);
        if RefreshTokenExpiryTerm.ContainsKey(ConnectionId) then
            RefreshTokenExpiryTerm.Remove(ConnectionId);
        RefreshTokenExpiryTerm.Add(ConnectionId, TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger()));

        AccessTokens.Get(ConnectionId, AccessTokenOut);
    end;
}
