#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6150988 "NPR Entria API Handler"
{
    Access = Internal;

    internal procedure SendEntriaRequest(EntriaStoreCode: Code[20]; APIEndpoint: Text; HttpMethod: Enum "Http Request Type"; var EntriaResponse: JsonToken): Boolean
    var
        EntriaStore: Record "NPR Entria Store";
        ResponseText: Text;
        Url: Text;
    begin
        EntriaStore.SetLoadFields("Entria Url", "Entria API Key Token");
        EntriaStore.Get(EntriaStoreCode);
        Url := GetEntriaUrl(EntriaStore) + APIEndpoint;
        exit(TrySendEntriaRequest(EntriaStore, HttpMethod, Url, ResponseText, EntriaResponse));
    end;

    internal procedure GetEntriaStoreList(EntriaStoreCode: Code[20]; var EntriaResponse: JsonToken): Boolean
    begin
        exit(SendEntriaRequest(EntriaStoreCode, 'admin/stores', Enum::"Http Request Type"::GET, EntriaResponse));
    end;


    [TryFunction]
    local procedure TrySendEntriaRequest(EntriaStore: Record "NPR Entria Store"; RestMethod: Enum "Http Request Type"; Url: Text; var ResponseText: Text; var EntriaResponse: JsonToken)
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        MaxRetries: Integer;
        RetryCounter: Integer;
        Retry: Boolean;
        Success: Boolean;
    begin
        CheckHttpClientRequestsAllowed();

        MaxRetries := 3;
        RetryCounter := 0;

        repeat
            RetryCounter += 1;
            Clear(Client);
            Clear(RequestMsg);
            Clear(ResponseMsg);

            CreateRequestMsg(EntriaStore, RestMethod, Url, RequestMsg);
            if not Client.Send(RequestMsg, ResponseMsg) then
                Error(GetLastErrorText());

            Success := ResponseMsg.IsSuccessStatusCode();
            if not Success then
                case true of
                    RetryCounter >= MaxRetries:
                        Retry := false;
                    else
                        Retry := ResponseAllowsRetries(ResponseMsg);
                end;
        until Success or not Retry;

        if not ResponseMsg.Content().ReadAs(ResponseText) then
            ResponseText := '';
        if ResponseText = '' then
            ResponseText := '{}';

        if not Success then
            Error(BuildErrorText(ResponseMsg, ResponseText));

        CheckResponseIsJson(ResponseText, Url);
        EntriaResponse.ReadFrom(ResponseText);
    end;

    local procedure CheckResponseIsJson(ResponseText: Text; Url: Text)
    var
        TrimmedResponse: Text;
        RoutingIssueErr: Label 'Entria API returned HTML/XML instead of JSON. This indicates a routing issue.\URL: %1\\Response preview: %2\\Please verify:\- Base URL is correct (without /admin or /app)\- API endpoint path is correct\- Entria server routing is properly configured';
    begin
        TrimmedResponse := ResponseText.TrimStart();
        if TrimmedResponse.StartsWith('<!DOCTYPE') or
           TrimmedResponse.StartsWith('<html') or
           TrimmedResponse.StartsWith('<?xml') or
           TrimmedResponse.StartsWith('<HTML') then
            Error(RoutingIssueErr, Url, CopyStr(TrimmedResponse, 1, 200));
    end;

    local procedure CreateRequestMsg(EntriaStore: Record "NPR Entria Store"; RestMethod: Enum "Http Request Type"; Url: Text; var RequestMsg: HttpRequestMessage)
    var
        Headers: HttpHeaders;
    begin
        RequestMsg.SetRequestUri(Url);
        RequestMsg.Method(Format(RestMethod));
        RequestMsg.GetHeaders(Headers);
        Headers.Add('Authorization', StrSubstNo('Basic %1', EntriaStore.GetAPIKey()));
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'NPRetail-BC');
    end;

    local procedure ResponseAllowsRetries(ResponseMsg: HttpResponseMessage): Boolean
    var
        Status: Integer;
        WaitTime: Integer;
    begin
        Status := ResponseMsg.HttpStatusCode();
        case Status of
            429:  //Too Many Requests
                WaitTime := 2000;
            500 .. 599:  //Internal errors
                WaitTime := 5000;
            else
                exit(false);
        end;

        if WaitTime > 0 then begin
            EmitThrottleWarning(Status, WaitTime);
            Sleep(WaitTime);
        end;
        exit(true);
    end;

    local procedure EmitThrottleWarning(StatusCode: Integer; WaitTimeMs: Integer)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
        InputMessage: Text;
        RateLimitMsg: Label 'Entria request rate limit exceeded. Waiting %1ms before retry.', Comment = '%1 = wait time in milliseconds';
        InternalErrorMsg: Label 'Entria API experiencing internal errors. Waiting %1ms before retry.', Comment = '%1 = wait time in milliseconds';
    begin
        if StatusCode = 429 then
            InputMessage := StrSubstNo(RateLimitMsg, WaitTimeMs)
        else
            InputMessage := StrSubstNo(InternalErrorMsg, WaitTimeMs);

        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            ActiveSession.Init();

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_StatusCode', Format(StatusCode));
        CustomDimensions.Add('NPR_WaitTimeMs', Format(WaitTimeMs));

        Session.LogMessage('Entria_API_Throttle', InputMessage, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    local procedure BuildErrorText(ResponseMsg: HttpResponseMessage; ResponseText: Text): Text
    begin
        Exit(StrSubstNo('%1: %2\%3', ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseText));
    end;

    local procedure CheckHttpClientRequestsAllowed()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        NAVAppSettings: Record "NAV App Setting";
        HttpRequestsAreNotAllowedErr: Label 'Http requests are blocked by default in sandbox environments. In order to proceed, you must allow HttpClient requests for NP Retail extension.';
    begin
        if EnvironmentInfo.IsSandbox() then
            if not (NAVAppSettings.Get('992c2309-cca4-43cb-9e41-911f482ec088') and NAVAppSettings."Allow HttpClient Requests") then
                Error(HttpRequestsAreNotAllowedErr);
    end;

    local procedure GetEntriaUrl(EntriaStore: Record "NPR Entria Store") EntriaUrl: Text
    begin
        EntriaStore.TestField("Entria Url");
        EntriaUrl := EntriaStore."Entria Url";
        if not EntriaUrl.EndsWith('/') then
            EntriaUrl := EntriaUrl + '/';
    end;

    internal procedure IsValidEntriaUrl(EntriaUrl: Text): Boolean
    var
        Regex: Codeunit Regex;
        PatternLbl: Label '^(https?)\:\/\/.+$', Locked = true;
    begin
        exit(Regex.IsMatch(EntriaUrl, PatternLbl))
    end;
}
#endif