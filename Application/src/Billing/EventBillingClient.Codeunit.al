#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248217 "NPR Event Billing Client"
{
    Access = Internal;
    SingleInstance = true;
    Permissions =
        TableData "NPR Billing Queue Entry" = RIMd;

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
        CustDimErrorReasonCodeTok: Label 'ReasonCode', Locked = true;
        CustDimErrorReasonTextTok: Label 'ReasonText', Locked = true;
        CustDimensionOperationTok: Label 'Operation', Locked = true;
        NumberOfHoursToCheckInvalidErr: Label 'Number of hours without processing must be greater than 0.';

    #region === Register Event in BC Database (public) ===
    /// <summary>
    /// Registers an event with the specified identifier, type, and quantity.
    /// The EventId is used to ensure idempotency, meaning each EventId can only be registered once in the target database.
    /// </summary>
    /// <param name="EventId">The unique identifier of the event. Used to ensure idempotency.</param>
    /// <param name="EventType">The type of the event, defined by the NPR Billing Event Type enumeration.</param>
    /// <param name="Qty">The quantity associated with the event.</param>
    /// <returns>Returns Entry No. of the Billing Queue Entry that was created.</returns>
    procedure RegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal): BigInteger
    var
        EmptyMetadata: JsonObject;
    begin
        exit(RegisterEvent(EventId, EventType, Qty, EmptyMetadata.AsToken()));
    end;

    /// <summary>
    /// Registers an event with the specified identifier, type, quantity, and metadata, using the default processing mode (OfflineWithOnlineFallback).
    /// The EventId is used to ensure idempotency, meaning each EventId can only be registered once in the target database.
    /// </summary>
    /// <param name="EventId">The unique identifier of the event. Used to ensure idempotency.</param>
    /// <param name="EventType">The type of the event, defined by the NPR Billing Event Type enumeration.</param>
    /// <param name="Qty">The quantity associated with the event.</param>
    /// <param name="Metadata">Additional metadata related to the event, passed as a JSON token.</param>
    /// <returns>Returns Entry No. of the Billing Queue Entry that was created.</returns>
    procedure RegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal; Metadata: JsonToken): BigInteger
    begin
        exit(RegisterEventInternal(EventId, EventType, Qty, Metadata));
    end;
    #endregion

    #region === Register Event in BC Database (private) ===
    local procedure RegisterEventInternal(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal; Metadata: JsonToken): BigInteger
    var
        ExistingBillingQueueEntry: Record "NPR Billing Queue Entry";
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        BillingQueueEntryNo: BigInteger;
    begin
        InitSessionVars();

        // Idempotency Check (returning just true and nothing else but maybe we will want to change a subsequent logic somehow, e.g. for error situations):
        BillingQueueEntryNo := GetQueueEntryStatusForEvent(EventId, ExistingBillingQueueEntry);
        if (BillingQueueEntryNo <> 0) then
            exit(BillingQueueEntryNo);

        exit(CreateBillingQueueEntry(BillingQueueEntry, EventId, EventType, Qty, Metadata));
    end;

    local procedure CreateBillingQueueEntry(var BillingQueueEntry: Record "NPR Billing Queue Entry"; EventId: Guid; EventType: Enum "NPR Billing Event Type"; Qty: Decimal; Metadata: JsonToken): Integer
    var
        MetadataJsonString: Text;
    begin
#pragma warning disable AA0139
        Metadata.WriteTo(MetadataJsonString);
        BillingQueueEntry.Init();
        BillingQueueEntry."Event ID" := EventId;
        BillingQueueEntry."Event Timestamp" := ConvertDateTimeToPostgresDT(CurrentDateTime());
        BillingQueueEntry."Is SaaS" := IsSaaSValue;
        BillingQueueEntry."Tenant ID" := TenantId;
        BillingQueueEntry."Environment Type" := EnvironmentTypeValue;
        BillingQueueEntry."Environment Name" := EnvironmentName;
        BillingQueueEntry."Server Name" := SessionServerName;
        BillingQueueEntry."Company Name" := CompanyName;
        BillingQueueEntry."Feature ID" := EventType.AsInteger();
        BillingQueueEntry."Feature Name" := Format(EventType);
        BillingQueueEntry.Quantity := Qty;
        BillingQueueEntry."User Security ID" := UserSecurityId();
        BillingQueueEntry.SetMetadata(MetadataJsonString);
        BillingQueueEntry."Is Production Environment" := IsProductionEnvironment;
        BillingQueueEntry."Billing API URL" := BillingApiUrl;
        BillingQueueEntry.Validate(Status, BillingQueueEntry.Status::Pending);
        BillingQueueEntry.Insert(true);

        exit(BillingQueueEntry."Entry No.");
#pragma warning restore
    end;

    local procedure GetQueueEntryStatusForEvent(EventIdParam: Guid; var BillingQueueEntry: Record "NPR Billing Queue Entry"): BigInteger
    begin
        BillingQueueEntry.ReadIsolation := BillingQueueEntry.ReadIsolation::ReadCommitted;

        BillingQueueEntry.Reset();
        BillingQueueEntry.SetLoadFields(Status, SystemId);
        BillingQueueEntry.SetCurrentKey("Event ID", "Is Production Environment");
        BillingQueueEntry.SetRange("Event ID", EventIdParam);
        BillingQueueEntry.SetRange("Is Production Environment", IsProductionEnvironment);
        if (BillingQueueEntry.FindFirst()) then
            exit(BillingQueueEntry."Entry No.");

        exit(0);
    end;
    #endregion

    #region === Prepare to send Data to Billing DB ===
    /// <summary>
    /// Prepares and sends data to the billing database.
    /// This function is called to process the billing queue entries and forward them to the billing database.
    /// It is supposed to be called via Job Queue.
    /// </summary>
    procedure ForwardDataToBillingDatabase()
    begin
        ForwardDataToBillingDatabaseInternal();
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure ForwardDataToBillingDatabaseInternal()
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        BillingQueueEntryMod: Record "NPR Billing Queue Entry";
        JsonBuilder: Codeunit "NPR Json Builder";
        RequestJsonToken: JsonToken;
        MaxEntryCount: BigInteger;
        EntryCounter: BigInteger;
        SyncDT: DateTime;
    begin
        InitSessionVars();

        // Let's find the entries to process:
        BillingQueueEntry.Reset();
        BillingQueueEntry.SetCurrentKey("Status", "Is Production Environment");
        BillingQueueEntry.SetRange(Status, BillingQueueEntry.Status::Pending);
        BillingQueueEntry.SetRange("Is Production Environment", IsProductionEnvironment);

        if (BillingQueueEntry.IsEmpty()) then
            exit;

        JsonBuilder.Initialize()
            .AddProperty('tableName', 'public.bceventstd')
            .StartArray('values');

        EntryCounter := 0;
        MaxEntryCount := GetMaxNumberOfEntriesToSend();
        SyncDT := CurrentDateTime();

        BillingQueueEntry.FindSet(true);
        repeat
            BillingQueueEntry.TestField("Billing API URL", BillingApiUrl);

            JsonBuilder.AddObject(GetBillingEntryJsonObjectToken(JsonBuilder, BillingQueueEntry));

            BillingQueueEntryMod := BillingQueueEntry;
            BillingQueueEntryMod.Validate(Status, BillingQueueEntryMod.Status::Done);
            BillingQueueEntryMod."Synced At (DateTime)" := SyncDT;
            BillingQueueEntryMod.Modify(true);

            EntryCounter += 1;
        until ((BillingQueueEntry.Next() = 0) or (EntryCounter >= MaxEntryCount));

        RequestJsonToken := JsonBuilder
            .EndArray()
            .BuildAsJsonToken();

        ProcessData(RequestJsonToken);
    end;

    /// <summary>
    /// Checks if there are any pending billing changes that need to be processed.
    /// </summary>
    /// <param name="OlderThanNumberOfHours">Number of hours that will be ignored. The search will happen the hours before it. 
    /// For value 0 the filter is ignored.</param>
    /// <returns>True if there are pending changes, otherwise false.</returns>
    procedure HasPendingChanges(OlderThanNumberOfHours: Integer): Boolean
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        DateTimeRangeToCheck: DateTime;
        HourDuration: Duration;
    begin
        if (OlderThanNumberOfHours < 1) then
            Error(NumberOfHoursToCheckInvalidErr);

        InitSessionVars();

        BillingQueueEntry.ReadIsolation := BillingQueueEntry.ReadIsolation::ReadCommitted;
        BillingQueueEntry.Reset();
        BillingQueueEntry.SetCurrentKey(Status, "Is Production Environment", SystemCreatedAt);
        BillingQueueEntry.SetRange(Status, BillingQueueEntry.Status::Pending);
        BillingQueueEntry.SetRange("Is Production Environment", IsProductionEnvironment);
        if (OlderThanNumberOfHours > 0) then begin
            HourDuration := OlderThanNumberOfHours * (1000 * 60 * 60);
            DateTimeRangeToCheck := CurrentDateTime() - HourDuration;
            BillingQueueEntry.SetFilter(SystemCreatedAt, '<%1', DateTimeRangeToCheck);
        end;

        exit(not BillingQueueEntry.IsEmpty());
    end;

    local procedure GetMaxNumberOfEntriesToSend(): BigInteger
    begin
        // 100 corresponds to max_batch_size of the Cloudflare Queue sendBatch() function.
        exit(100);
    end;
    #endregion

    #region === Sending to Billing DB via HTTP ===
    local procedure ProcessData(ReqJsonToken: JsonToken) RetVal: Boolean
    var
        Sentry: Codeunit "NPR Sentry";
        SentryRegisterBillingEventSpan: Codeunit "NPR Sentry Span";
        Response: Codeunit "Http Response Message";
        LogCustDims: Dictionary of [Text, Text];
        ReqTokenText: Text;
        HttpErrorMessage: Text;
        HttpErrorCode: Text;
        ErrorMessage: Text;
        ReqTokenTextErrorMaxLen: Integer;
    begin
        Sentry.StartSpan(SentryRegisterBillingEventSpan, 'bc.np-billing-register-event');

        LogCustDims := SessionVarsToCustDims();

        ReqTokenTextErrorMaxLen := 1024;
        RetVal := false;
        if SendData(ReqJsonToken, Response) then begin
            RetVal := Response.GetIsSuccessStatusCode();
            if (not RetVal) then begin
                HttpErrorMessage := Response.GetErrorMessage();
                HttpErrorCode := Format(Response.GetHttpStatusCode());
                ReqJsonToken.WriteTo(ReqTokenText);

                ErrorMessage := StrSubstNo('HTTP request failed with status %1. Details: %2', HttpErrorCode, HttpErrorMessage);

                LogCustDims.Set(CustDimensionOperationTok, 'SendDataHttpRequestFailed');
                LogCustDims.Set(CustDimErrorReasonCodeTok, HttpErrorCode);
                LogCustDims.Set(CustDimErrorReasonTextTok, ErrorMessage);

                LogCustDims.Set('Http.response.statusCode', HttpErrorCode);
                LogCustDims.Set('Http.response.errorMessage', HttpErrorMessage);
                if (StrLen(ReqTokenText) > ReqTokenTextErrorMaxLen) then
                    // Let's take only the first X chars of the request body for logging:
                    LogCustDims.Set('Http.request.body.summary', CopyStr(ReqTokenText, 1, ReqTokenTextErrorMaxLen) + ' ...')
                else
                    LogCustDims.Set('Http.request.body.summary', ReqTokenText);

                Session.LogMessage('NPR_API_NpBilling', StrSubstNo('HTTP Error %1 sending', HttpErrorCode), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, LogCustDims);

                ErrorMessage := StrSubstNo('Failed to send HTTP request to the billing API. Http error %1, details: %2', HttpErrorCode, HttpErrorMessage);
                Sentry.AddError(ErrorMessage, '');
            end;
        end else begin
            ErrorMessage := StrSubstNo('Failed to send HTTP request to the billing API. Error: %1', GetLastErrorText());

            LogCustDims.Set(CustDimensionOperationTok, 'SendDataGeneralFailure');
            LogCustDims.Set(CustDimErrorReasonCodeTok, 'SendDataTryFuncError');
            LogCustDims.Set(CustDimErrorReasonTextTok, ErrorMessage);

            Session.LogMessage('NPR_API_NpBilling', 'SendData TryFunction failed.', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, LogCustDims);
            Sentry.AddError(ErrorMessage, GetLastErrorCallStack());
        end;

        SentryRegisterBillingEventSpan.Finish();

        if (not RetVal) then
            Error(ErrorMessage);

        exit(RetVal);
    end;

    [TryFunction]
    local procedure SendData(ReqJsonToken: JsonToken; var Response: Codeunit "Http Response Message")
    var
        RestClient: Codeunit "Rest Client";
        Content: Codeunit "Http Content";
        AuthSecret: SecretText;
    begin
        Content := Content.Create(ReqJsonToken);
        AuthSecret := GetAuthSecret();

        RestClient.Initialize();
        RestClient.SetDefaultRequestHeader(BillingQueueSharedKeyHeaderNameTok, AuthSecret);
        // Setting 5 seconds timeout for the request:
        RestClient.SetTimeOut(5000);
        Response := RestClient.Post(StrSubstNo('%1/event', BillingApiUrl), Content);
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
    #endregion

    #region === Session Variables ===
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

    local procedure GetIsRealProductionEnvironment() RetVal: Boolean
    var
        ServerNameLocal: Text;
        IsCraneServerName: Boolean;
    begin
        if (EnvInfo.IsSaaSInfrastructure()) then begin
            RetVal := EnvInfo.IsProduction();
        end else begin
            // TODO: For non-SaaS this is far to be okay, it covers just Crane exception but nothing else!
            //       Also, once we change the lenhth of the crane container names, this will not work anymore.
            ServerNameLocal := SessionServerName;
            IsCraneServerName := GetIsCraneContainerHostName(ServerNameLocal, 6, 6);
            RetVal := (not IsCraneServerName);
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
        AADTenant: Codeunit "Azure AD Tenant";
    begin
        RetVal := AADTenant.GetAadTenantId();
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
    #endregion

    #region === Telemetry ===
    local procedure SessionVarsToCustDims() LogCustDims: Dictionary of [Text, Text];
    begin
        LogCustDims.Set('IsSaaSValue', Format(IsSaaSValue));
        LogCustDims.Set('TenantId', TenantId);
        LogCustDims.Set('SessionServerName', SessionServerName);
        LogCustDims.Set('IsProductionEnvironment', Format(IsProductionEnvironment));
        LogCustDims.Set('EnvironmentName', EnvironmentName);
        LogCustDims.Set('EnvironmentTypeValue', Format(EnvironmentTypeValue));
        LogCustDims.Set('BillingApiUrlGlobal', BillingApiUrl);
        LogCustDims.Set('SessionVarsInitialized', Format(SessionVarsInitialized));
        LogCustDims.Set('SessionVarsContext', 'FromGlobalVars');

        exit(LogCustDims);
    end;
    #endregion

    #region === Postgres Convertors ===
    local procedure ConvertDateTimeToPostgresDT(Value: DateTime): Text
    begin
        exit(Format(Value, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;
    #endregion

    #region === JSON Handlers ===
    local procedure GetBillingEntryJsonObjectToken(var JsonBuilder: Codeunit "NPR Json Builder"; var BillingQueueEntry: Record "NPR Billing Queue Entry"): Codeunit "NPR Json Builder"
    begin
        JsonBuilder.StartObject()
            .AddProperty('event_id', BillingQueueEntry."Event ID")
            .AddProperty('timestamp', BillingQueueEntry."Event Timestamp")
            .AddProperty('is_saas', BillingQueueEntry."Is SaaS")
            .AddProperty('tenant_id', BillingQueueEntry."Tenant ID")
            .AddProperty('environment_type', BillingQueueEntry."Environment Type")
            .AddProperty('environment_name', BillingQueueEntry."Environment Name")
            .AddProperty('server_name', BillingQueueEntry."Server Name")
            .AddProperty('company_name', BillingQueueEntry."Company Name")
            .AddProperty('feature_id', BillingQueueEntry."Feature ID")
            .AddProperty('feature_name', BillingQueueEntry."Feature Name")
            .AddProperty('quantity', BillingQueueEntry.Quantity)
            .AddProperty('user_id', BillingQueueEntry."User Security ID")
            .AddProperty('metadata', BillingQueueEntry.GetMetadata())
        .EndObject();

        exit(JsonBuilder);
    end;
    #endregion
}
#endif