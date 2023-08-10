codeunit 6151089 "NPR Sentry Cron"
{
    Access = Internal;

    internal procedure CreateCheckIn(OrganizationSlug: Text; MonitorSlug: Text; Status: Text; Schedule: Text; ScheduleType: Option Crontab,Interval; CheckinMarginInMinutes: Integer; MaxRuntimeInMinutes: Integer; Timezone: Text) CheckInId: Text
    var
        SentryHelper: Codeunit "NPR Sentry Helper";
        RequestContent: HttpContent;
        ResponseContent: HttpContent;
        ResponseJson: JsonObject;
        JToken: JsonToken;
        CreateCheckInLbl: Label 'organizations/%1/monitors/%2/checkins/', Locked = true, Comment = '%1 - Organization Slug, %2 - Monitor Slug';
        RestMethod: Option Get,Post,Delete,Patch,Put;
        Environment: Text;
        JsonText: Text;
        Url: Text[250];
    begin
        if not SentryHelper.ShouldUseSentryCron() then
            exit;

        Url := InitUrl(StrSubstNo(CreateCheckInLbl, OrganizationSlug, MonitorSlug));
        RestMethod := RestMethod::Post;
        Environment := GetEnvironment();
        RequestContent.WriteFrom(GetFormDataForCheckIn(Status, Environment, Schedule, ScheduleType, CheckinMarginInMinutes, MaxRuntimeInMinutes, Timezone));
        if not TryCallWebService(Url, RestMethod, RequestContent, ResponseContent) then
            exit;

        ResponseContent.ReadAs(JsonText);
        ResponseJson.ReadFrom(JsonText);
        ResponseJson.Get('id', JToken);
        CheckInId := JToken.AsValue().AsText();
    end;

    internal procedure UpdateCheckIn(OrganizationSlug: Text; MonitorSlug: Text; Status: Text; CheckInId: Text)
    var
        SentryHelper: Codeunit "NPR Sentry Helper";
        RequestContent: HttpContent;
        ResponseContent: HttpContent;
        UpdateCheckInLbl: Label 'organizations/%1/monitors/%2/checkins/%3/', Locked = true, Comment = '%1 - Organization Slug, %2 - Monitor Slug; %3 - Check-in Id';
        RestMethod: Option Get,Post,Delete,Patch,Put;
        Environment: Text;
        Url: Text[250];
    begin
        if not SentryHelper.ShouldUseSentryCron() then
            exit;

        Url := InitUrl(StrSubstNo(UpdateCheckInLbl, OrganizationSlug, MonitorSlug, CheckInId));
        RestMethod := RestMethod::Put;
        Environment := GetEnvironment();
        RequestContent.WriteFrom(GetFormDataForCheckIn(Status, Environment, '', 0, 0, 0, ''));
        if not TryCallWebService(Url, RestMethod, RequestContent, ResponseContent) then;
    end;

    local procedure GetFormDataForCheckIn(Status: Text; Environment: Text; Schedule: Text; ScheduleType: Option Crontab,Interval; CheckinMarginInMinutes: Integer; MaxRuntimeInMinutes: Integer; Timezone: Text) Data: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextReaderWriter.WriteStartObject('');
        if Schedule <> '' then begin
            JsonTextReaderWriter.WriteStartObject('monitor_config');
            JsonTextReaderWriter.WriteStringProperty('schedule', Schedule);
            JsonTextReaderWriter.WriteStringProperty('schedule_type', GetScheduleType(ScheduleType));
            if CheckinMarginInMinutes > 0 then
                JsonTextReaderWriter.WriteStringProperty('checkin_margin', CheckinMarginInMinutes);
            if MaxRuntimeInMinutes > 0 then
                JsonTextReaderWriter.WriteStringProperty('max_runtime', MaxRuntimeInMinutes);
            if Timezone <> '' then
                JsonTextReaderWriter.WriteStringProperty('timezone', Timezone);
            JsonTextReaderWriter.WriteEndObject();
        end;
        JsonTextReaderWriter.WriteStringProperty('status', Status);
        if Environment <> '' then
            JsonTextReaderWriter.WriteStringProperty('environment', Environment);
        JsonTextReaderWriter.WriteEndObject();
        Data := JsonTextReaderWriter.GetJSonAsText();
    end;

    [TryFunction]
    local procedure TryCallWebService(Url: Text[250]; RestMethod: Option get,post,delete,patch,put; var RequestContent: HttpContent; var ResponseContent: HttpContent)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        DSNAuthorizationLbl: Label 'DSN %1', Locked = true, Comment = '%1 = Username and password in base64 string';
        ErrorMesssagePlaceholderLbl: Label '%1 %2', Locked = true, Comment = '%1 - HTTP Status Code value, %2 - Reason Phrase value';
    begin
        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Method := GetRestMethod(RestMethod);
        RequestMessage.SetRequestUri(Url);

        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', StrSubstNo(DSNAuthorizationLbl, GetDSN()));
        Headers.Add('Host', GetHost());

        RequestMessage.Content := RequestContent;
        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode() then
            Error(ErrorMesssagePlaceholderLbl, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase());

        ResponseContent := ResponseMessage.Content;
    end;

    local procedure InitUrl(Method: Text) Url: Text[250]
    begin
        Url := GetBaseUrl() + Method;
    end;

    local procedure GetEnvironment(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        CharsToKeep: Text;
        NewCompanyName: Text;
    begin
        CharsToKeep := 'abcdefghijklmnopqrstuvwxyz0123456789-';
        NewCompanyName := LowerCase(CompanyName());
        NewCompanyName := DelChr(NewCompanyName, '=', DelChr(NewCompanyName, '=', CharsToKeep));

        if EnvironmentInformation.IsSaaS() then
            exit(GetSaaSEnvironment(NewCompanyName));

        if EnvironmentInformation.IsOnPrem() then
            exit(GetOnPremEnvironment(NewCompanyName));
    end;

    local procedure GetSaaSEnvironment(ThisCompanyName: Text): Text
    var
        AzureAdTenant: Codeunit "Azure AD Tenant";
        EnvironmentName: Text;
        EnvironmentTypeAndTenantId: Text;
    begin
        EnvironmentName := 'saas_' + ThisCompanyName + '_' + AzureAdTenant.GetAadTenantId();

        if StrLen(EnvironmentName) <= GetEnvironmentNameMaxLength() then
            exit(EnvironmentName);

        EnvironmentTypeAndTenantId := 'saas_' + '_' + AzureAdTenant.GetAadTenantId();
        EnvironmentName := 'saas_' + CopyStr(ThisCompanyName, 1, GetEnvironmentNameMaxLength() - StrLen(EnvironmentTypeAndTenantId)) + '_' + AzureAdTenant.GetAadTenantId();
        exit(EnvironmentName);
    end;

    local procedure GetOnPremEnvironment(ThisCompanyName: Text): Text
    var
        EnvironmentName: Text;
        EnvironmentTypeAndTenantId: Text;
    begin
        EnvironmentName := 'onprem_' + ThisCompanyName + '_' + TenantId();

        if StrLen(EnvironmentName) <= GetEnvironmentNameMaxLength() then
            exit(EnvironmentName);

        EnvironmentTypeAndTenantId := 'onprem_' + '_' + TenantId();
        EnvironmentName := 'onprem_' + CopyStr(ThisCompanyName, 1, GetEnvironmentNameMaxLength() - StrLen(EnvironmentTypeAndTenantId)) + '_' + TenantId();
        exit(EnvironmentName);
    end;

    local procedure GetEnvironmentNameMaxLength(): Integer
    begin
        exit(64);
    end;

    local procedure GetBaseUrl(): Text
    begin
        exit('https://sentry.io/api/0/');
    end;

    local procedure GetHost(): Text
    begin
        exit('sentry.io');
    end;

    local procedure GetRestMethod(RestMethod: Option Get,Post,Delete,Patch,Put): Text
    begin
        case RestMethod of
            RestMethod::Get:
                exit('get');
            RestMethod::Delete:
                exit('delete');
            RestMethod::Patch:
                exit('patch');
            RestMethod::Post:
                exit('post');
            RestMethod::Put:
                exit('put');
        end;
    end;

    local procedure GetScheduleType(ScheduleType: Option Crontab,Interval): Text
    begin
        case ScheduleType of
            ScheduleType::Crontab:
                exit('crontab');
            ScheduleType::Interval:
                exit('interval');
        end;
    end;

    [NonDebuggable]
    local procedure GetDSN(): Text
    begin
        exit(GetSecretKey());
    end;

    [NonDebuggable]
    local procedure GetSecretKey(): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('SentryIONpCorePointOfSale'));
    end;

    internal procedure GetOrganizationSlug(): Text
    begin
        exit('navipartner');
    end;
}