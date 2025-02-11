codeunit 6184936 "NPR ES Fiskaly JWT"
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
        TypeHelper: Codeunit "Type Helper";
        ExpirationThresholdDateTime: DateTime;
        SelectedTokenExpiresAt: DateTime;
        SelectedAccessToken: Text;
        SelectedRefreshToken: Text;
    begin
        if not AccessTokens.Get(ConnectionID, SelectedAccessToken) or (SelectedAccessToken = '') then
            exit(false);

        ExpirationThresholdDateTime := RoundDateTime(JobQueueManagement.NowWithDelayInSeconds(-120), 1000);

        if AccessTokenExpiryTerm.Get(ConnectionID, SelectedTokenExpiresAt) then
            if TypeHelper.CompareDateTime(ExpirationThresholdDateTime, SelectedTokenExpiresAt) = -1 then begin
                AccessTokenOut := SelectedAccessToken;
                exit(true);
            end;

        if RefreshTokens.Get(ConnectionID, SelectedRefreshToken) and (SelectedRefreshToken <> '') then
            if RefreshTokenExpiryTerm.Get(ConnectionID, SelectedTokenExpiresAt) then
                if TypeHelper.CompareDateTime(ExpirationThresholdDateTime, SelectedTokenExpiresAt) = -1 then
                    RefreshTokenOut := SelectedRefreshToken;

        exit(false);
    end;

    internal procedure SetToken(ConnectionId: Guid; ResponseJson: JsonToken; var AccessTokenOut: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
    begin
        ResponseJson.SelectToken('$.content.access_token.bearer', JToken);
        if AccessTokens.ContainsKey(ConnectionId) then
            AccessTokens.Remove(ConnectionId);
        AccessTokens.Add(ConnectionId, JToken.AsValue().AsText());

        ResponseJson.SelectToken('$.content.access_token.expires_at', JToken);
        if AccessTokenExpiryTerm.ContainsKey(ConnectionId) then
            AccessTokenExpiryTerm.Remove(ConnectionId);
        AccessTokenExpiryTerm.Add(ConnectionId, TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger()));

        ResponseJson.SelectToken('$.content.refresh_token.bearer', JToken);
        if RefreshTokens.ContainsKey(ConnectionId) then
            RefreshTokens.Remove(ConnectionId);
        RefreshTokens.Add(ConnectionId, JToken.AsValue().AsText());

        ResponseJson.SelectToken('$.content.refresh_token.expires_at', JToken);
        if RefreshTokenExpiryTerm.ContainsKey(ConnectionId) then
            RefreshTokenExpiryTerm.Remove(ConnectionId);
        RefreshTokenExpiryTerm.Add(ConnectionId, TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger()));

        AccessTokens.Get(ConnectionId, AccessTokenOut);
    end;
}
