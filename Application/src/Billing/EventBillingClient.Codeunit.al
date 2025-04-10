#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248217 "NPR Event Billing Client"
{
    Access = Internal;
    SingleInstance = true;

    var
        EnvInfo: Codeunit "Environment Information";
        BillingApiUrl: Text;
        TenantId: Text;
        SessionServerName: Text;
        EnvironmentName: Text;
        BillingApiToken: SecretText;
        EnvironmentTypeValue: Integer;
        IsSaaSValue: Integer;
        IsProductionEnvironment: Boolean;
        SessionVarsInitialized: Boolean;
        BillingQueueSharedKeyHeaderNameTok: Label 'X-BillingQueue-PSK', Locked = true;
        NpBillingApiUrlPreliveTok: Label 'https://bc-billing-proxy-api.npretail-prelive.app', Locked = true;
        NpBillingApiUrlProductionTok: Label 'https://bc-billing-proxy-api.npretail.app', Locked = true;
        AkvNpBillingApiSharedKeyTok: Label 'NpBillingApiSharedKey', Locked = true;

    /// <summary>
    /// Registers an event with the specified identifier, type, and quantity.
    /// This overload provides a simplified interface by passing an empty metadata object.
    /// The EventId is used to ensure idempotency, meaning each EventId can only be registered once in the target database.
    /// </summary>
    /// <param name="EventId">The unique identifier of the event. Used to ensure idempotency.</param>
    /// <param name="EventType">The type of the event, defined by the NPR Billing Event Type enumeration.</param>
    /// <param name="Qty">The quantity associated with the event.</param>
    /// <returns>Returns true if the event was successfully registered; otherwise, false.</returns>
    procedure RegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal): Boolean
    var
        EmptyMetadata: JsonObject;
    begin
        exit(RegisterEvent(EventId, EventType, Qty, EmptyMetadata.AsToken()));
    end;

    /// <summary>
    /// Registers an event with the specified identifier, type, quantity, and metadata.
    /// The EventId is used to ensure idempotency, meaning each EventId can only be registered once in the target database.
    /// </summary>
    /// <param name="EventId">The unique identifier of the event. Used to ensure idempotency.</param>
    /// <param name="EventType">The type of the event, defined by the NPR Billing Event Type enumeration.</param>
    /// <param name="Qty">The quantity associated with the event.</param>
    /// <param name="Metadata">Additional metadata related to the event, passed as a JSON token.</param>
    /// <returns>Returns true if the event was successfully registered; otherwise, false.</returns>
    procedure RegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal; Metadata: JsonToken): Boolean
    begin
        exit(RegisterEventInternal(EventId, EventType, Qty, Metadata));
    end;

    local procedure RegisterEventInternal(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal; Metadata: JsonToken): Boolean
    var
        LogCustDims: Dictionary of [Text, Text];
        TryMethodSuccessful: Boolean;
        HttpMethodSucessful: Boolean;
    begin
        TryMethodSuccessful := TryRegisterEvent(EventId, EventType, Qty, Metadata, HttpMethodSucessful);

        if (not TryMethodSuccessful) then begin
            LogCustDims.Add('operation', 'TryRegisterEvent');
            Session.LogMessage('NPR_API_NpBilling', GetLastErrorText(), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, LogCustDims);
        end;

        exit(TryMethodSuccessful and HttpMethodSucessful);
    end;

    [TryFunction]
    local procedure TryRegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal; Metadata: JsonToken; var HttpMethodSucessful: Boolean)
    var
        RequestJToken: JsonToken;
    begin
        InitSessionVars();

        if (not SendToBillingDB()) then
            exit;

        RequestJToken := GetEventJson(EventId, EventType, Qty, Metadata);
        HttpMethodSucessful := ProcessData(RequestJToken);
    end;

    local procedure InitSessionVars()
    begin
        if (SessionVarsInitialized) then
            exit;

        IsSaaSValue := GetIsSaaS();
        TenantId := GetTenantId();
        SessionServerName := GetServerNameIfNeeded();
        IsProductionEnvironment := GetIsRealProductionEnvironment();
        EnvironmentName := GetEnvironmentName();
        EnvironmentTypeValue := GetEnvironmentType();
        BillingApiUrl := GetBillingSystemUrl();
        SessionVarsInitialized := true;
    end;

    local procedure GetEventJson(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal; Metadata: JsonToken): JsonToken
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        MetadataJsonString: Text;
    begin
        Metadata.WriteTo(MetadataJsonString);

        exit(JsonBuilder
            .Initialize()
            .AddProperty('tableName', 'public.bceventstd')
            .StartObject('values')
                .AddProperty('event_id', EventId)
                .AddProperty('timestamp', ConvertDateTimeToPostgresDT(CurrentDateTime()))
                .AddProperty('is_saas', IsSaaSValue)
                .AddProperty('tenant_id', CopyStr(TenantId, 1, 50))
                .AddProperty('environment_type', EnvironmentTypeValue)
                .AddProperty('environment_name', CopyStr(EnvironmentName, 1, 100))
                .AddProperty('server_name', CopyStr(SessionServerName, 1, 100))
                .AddProperty('company_name', CopyStr(CompanyName, 1, 100))
                .AddProperty('feature_id', EventType.AsInteger())
                .AddProperty('feature_name', CopyStr(Format(EventType), 1, 100))
                .AddProperty('quantity', Qty)
                .AddProperty('user_id', UserSecurityId())
                .AddProperty('metadata', MetadataJsonString)
            .EndObject()
            .BuildAsJsonToken());
    end;

    local procedure ProcessData(ReqJsonToken: JsonToken) RetVal: Boolean
    var
        SentryScope: Codeunit "NPR Sentry Scope";
        SentryActiveSpan: Codeunit "NPR Sentry Span";
        SentryRegisterBillingEventSpan: Codeunit "NPR Sentry Span";
        Response: Codeunit "Http Response Message";
        LogCustDims: Dictionary of [Text, Text];
        ReqTokenText: Text;
    begin
        if (not SendToBillingDB()) then
            exit;
        if SentryScope.TryGetActiveSpan(SentryActiveSpan) then
            SentryActiveSpan.StartChildSpan('bc.np-billing-register-event', 'bc.np-billing-register-event', SentryRegisterBillingEventSpan);

        Response := SendData(ReqJsonToken);

        RetVal := Response.GetIsSuccessStatusCode();
        if (not RetVal) then begin
            ReqJsonToken.WriteTo(ReqTokenText);
            LogCustDims.Add('operation', 'HttpRequest');
            LogCustDims.Add('http.request.body', ReqTokenText);
            LogCustDims.Add('http.response.statusCode', Format(Response.GetHttpStatusCode()));
            Session.LogMessage('NPR_API_NpBilling', Response.GetErrorMessage(), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, LogCustDims);
        end;

        SentryRegisterBillingEventSpan.Finish();

        exit(RetVal);
    end;

    local procedure SendData(ReqJsonToken: JsonToken) Response: Codeunit "Http Response Message"
    var
        RestClient: Codeunit "Rest Client";
        Content: Codeunit "Http Content";
    begin
        Content := Content.Create(ReqJsonToken);

        RestClient.Initialize();
        RestClient.SetDefaultRequestHeader(BillingQueueSharedKeyHeaderNameTok, GetAuthSecret());
        // Setting 5 seconds but maybe we will need to set different values e.g. for WS calls.
        // We still expect the API should be always pretty fast.
        RestClient.SetTimeOut(5000);
        Response := RestClient.Post(StrSubstNo('%1/event', BillingApiUrl), Content);

        exit(Response);
    end;

    local procedure SendToBillingDB(): Boolean
    begin
        //if (IsProductionEnvironment) then
        //    exit(true);

        // TODO: ??? Do we want to implement additional logic when sending/not-sending the data to the billing db!!!
        // For now let's send all, but to different tables using different routes (production/prelive).
        exit(true);
    end;

    local procedure GetIsRealProductionEnvironment() RetVal: Boolean
    var
        ServerName: Text;
        IsCraneServerName: Boolean;
    begin
        if (EnvInfo.IsSaaSInfrastructure()) then begin
            // TODO: CDX environments ???
            RetVal := EnvInfo.IsProduction();
        end else begin
            // TODO: For non-SaaS this is far to be okay, it covers just Crane exception but nothing else!
            ServerName := SessionServerName;
            IsCraneServerName := GetIsCraneContainerHostName(ServerName, 6, 6);
            RetVal := (not IsCraneServerName)
        end;

        exit(RetVal);
    end;

    local procedure GetIsCraneContainerHostName(TextToValidate: Text; MinDigits: Integer; MaxDigits: Integer): Boolean
    var
        Regex: Codeunit Regex;
        RegexPattern: Text;
    begin
        // Create pattern: ^[A-Z]{2}\d{min,max}$
        RegexPattern := StrSubstNo('^[A-Z]{2}\d{%1,%2}$', MinDigits, MaxDigits);
        Regex.Regex(RegexPattern);
        exit(Regex.IsMatch(TextToValidate));
    end;

    local procedure GetBillingSystemUrl() RetVal: Text
    begin
        if (IsProductionEnvironment) then
            RetVal := NpBillingApiUrlProductionTok
        else
            RetVal := NpBillingApiUrlPreliveTok;

        RetVal := StrSubstNo('%1/api', RetVal.TrimEnd('/'));
    end;

    local procedure GetTenantId() RetVal: Text
    var
        TenantInfo: Codeunit "Tenant Information";
    begin
        RetVal := TenantInfo.GetTenantId();
        exit(RetVal);
    end;

    local procedure GetEnvironmentName(): Text
    begin
        exit(EnvInfo.GetEnvironmentName());
    end;

    local procedure GetEnvironmentType(): Integer
    begin
        if (not EnvInfo.IsSaaSInfrastructure()) then begin
            // For non-SaaS environments let's try to identify known non-production environments first (e.g. Crane):
            if (not GetIsRealProductionEnvironment()) then
                exit(-1);
        end;

        case true of
            EnvInfo.IsProduction():
                exit(Enum::"Environment Type"::Production.AsInteger());
            EnvInfo.IsSandbox():
                exit(Enum::"Environment Type"::Sandbox.AsInteger());
            else
                exit(-1)
        end;
    end;

    local procedure GetIsSaaS(): Integer
    begin
        if EnvInfo.IsSaaSInfrastructure() then
            exit(1)
        else
            exit(0);
    end;

    local procedure GetServerNameIfNeeded(): Text
    var
        ActiveSession: Record "Active Session";
    begin
        if IsSaaSValue = 1 then
            exit('');

        if not ActiveSession.Get(ServiceInstanceId(), SessionId()) then
            exit('');

        exit(ActiveSession."Server Computer Name");
    end;

    [NonDebuggable]
    local procedure GetAuthSecret(): SecretText
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if (BillingApiToken.IsEmpty()) then begin
            BillingApiToken := AzureKeyVaultMgt.GetAzureKeyVaultSecret(AkvNpBillingApiSharedKeyTok);
        end;

        exit(BillingApiToken);
    end;

    local procedure ConvertDateTimeToPostgresDT(Value: DateTime): Text
    begin
        exit(Format(Value, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;

}
#endif