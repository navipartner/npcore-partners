# API & Sentry JSON Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace JSON helper codeunits with native JsonObject in API module generic code and Sentry transaction code, cache SentryMetadata DB reads, remove SQL tracking headers, add BC26 SetAutoCalcFields, and add a SQL roundtrip budget test.

**Architecture:** Direct replacement of `NPR Json Builder` / `NPR JSON Parser` codeunit usage with native `JsonObject` / `JsonArray` / `JsonToken` types. SentryMetadata gets SingleInstance caching for DB-read tags. The `RespondOK(JsonBuilder)` / `RespondCreated(JsonBuilder)` overloads on APIResponse are kept because 22 handler callsites depend on them.

**Tech Stack:** AL (Business Central), compiler preprocessor symbols for BC version targeting.

---

### Task 1: SentryMetadata — cache tags, return native JsonObject

This task must be done first because SentrySpan, SentryError, and SentryTransaction all depend on these signatures.

**Files:**
- Modify: `Application/src/Sentry/SentryMetadata.Codeunit.al`

**Step 1: Change `WriteTagsForBackendEvent` to return cached `JsonObject`**

Replace lines 72-127 with:

```al
    internal procedure WriteTagsForBackendEvent(): JsonObject
    var
        Tags: JsonObject;
        TenantInformation: Codeunit "Tenant Information";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        ActiveSession: Record "Active Session";
        InstalledApp: Record "NAV App Installed App";
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        if _tagsLoaded then
            exit(_cachedTags.Clone().AsObject());

        if UserSetup.Get(UserId) then begin
            if POSUnit.Get(UserSetup."NPR POS Unit No.") then;
        end;

        if EnvironmentInformation.IsSaaSInfrastructure() then
            Tags.Add('aadTenantId', AzureADTenant.GetAadTenantId())
        else
            Tags.Add('aadTenantId', '_');

        Tags.Add('tenantId', TenantInformation.GetTenantId());
        if TenantInformation.GetTenantDisplayName() <> '' then
            Tags.Add('tenantDisplayName', TenantInformation.GetTenantDisplayName())
        else
            Tags.Add('tenantDisplayName', '_');

        if POSUnit."No." <> '' then
            Tags.Add('POSUnit', POSUnit."No.")
        else
            Tags.Add('POSUnit', '_');

        if POSUnit."POS Store Code" <> '' then
            Tags.Add('POSStore', POSUnit."POS Store Code")
        else
            Tags.Add('POSStore', '_');

        if InstalledApp.Get('992c2309-cca4-43cb-9e41-911f482ec088') then
            Tags.Add('retailAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));

        if InstalledApp.Get('437dbf0e-84ff-417a-965d-ed2bb9650972') then
            Tags.Add('baseAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));

        Tags.Add('company', CompanyName());
        Tags.Add('environment', GetEnvironment());
        Tags.Add('BCServiceInstanceId', ServiceInstanceId());
        Tags.Add('BCSessionId', SessionId());
        Tags.Add('BCClientType', Format(CurrentClientType()));
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then begin
            Tags.Add('BCSessionUniqueId', Format(ActiveSession."Session Unique ID", 0, 4).ToLower());
            if ActiveSession."Server Instance Name" <> '' then
                Tags.Add('BCServerInstanceName', ActiveSession."Server Instance Name")
            else
                Tags.Add('BCServerInstanceName', '_');
        end;
        Tags.Add('POSType', Format(POSUnit."POS Type", 0, 9));

        _cachedTags := Tags.Clone().AsObject();
        _tagsLoaded := true;
        exit(Tags);
    end;
```

**Step 2: Change `WriteModulesJson` to return `JsonObject`**

Replace lines 145-172 with:

```al
    internal procedure WriteModulesJson(): JsonObject
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        Modules: JsonObject;
        AppKey: Text;
        AppValue: Text;
        i: Integer;
    begin
        if _modulesJsonLoaded then
            exit(_cachedModulesJson.Clone().AsObject());

        i := 0;
        NAVAppInstalledApp.SetCurrentKey(Name);
        NAVAppInstalledApp.SetFilter(Publisher, '<>%1', 'Microsoft');
        if NAVAppInstalledApp.FindSet() then begin
            repeat
                i += 1;
                AppKey := StrSubstNo('%1 - %2', i, NAVAppInstalledApp.Name);
                AppValue := StrSubstNo('%1.%2.%3.%4', NAVAppInstalledApp."Version Major", NAVAppInstalledApp."Version Minor", NAVAppInstalledApp."Version Build", NAVAppInstalledApp."Version Revision");
                Modules.Add(AppKey, AppValue);
            until NAVAppInstalledApp.Next() = 0;
        end;

        _cachedModulesJson := Modules.Clone().AsObject();
        _modulesJsonLoaded := true;
        exit(Modules);
    end;
```

**Step 3: Add cache variables and remove old `_installedApp` dictionary**

In the var section (lines 7-10), replace with:

```al
    var
        _tagsLoaded: Boolean;
        _cachedTags: JsonObject;
        _modulesJsonLoaded: Boolean;
        _cachedModulesJson: JsonObject;
```

Remove the old `_installedAppsLoaded: Boolean` and `_installedApp: Dictionary of [Text, Text]` variables.

**Step 4: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 5: Commit**

```
feat(sentry): cache SentryMetadata tags and modules, return native JsonObject
```

---

### Task 2: SentrySpan — native JsonObject

**Files:**
- Modify: `Application/src/Sentry/_public/SentrySpan.Codeunit.al`

**Step 1: Change `ToJson` to return `JsonObject` using native types**

Replace lines 138-167 with:

```al
    internal procedure ToJson(traceId: Text): JsonObject
    var
        SentryMetadata: Codeunit "NPR Sentry Metadata";
        SpanJson: JsonObject;
        DataJson: JsonObject;
        metadataKey: Text;
    begin
        SpanJson.Add('span_id', _Id);
        SpanJson.Add('parent_span_id', _parentId);
        SpanJson.Add('description', _description);
        SpanJson.Add('op', _operation);
        SpanJson.Add('start_timestamp', _startedTimestampUtc);
        SpanJson.Add('timestamp', _finishedTimestampUtc);
        SpanJson.Add('trace_id', traceId);
        SpanJson.Add('status', Format(_status));

        if _metadata.Count > 0 then begin
            foreach metadataKey in _metadata.Keys() do
                DataJson.Add(metadataKey, _metadata.Get(metadataKey));
            SpanJson.Add('data', DataJson);
        end;

        SpanJson.Add('tags', SentryMetadata.WriteTagsForBackendEvent());
        exit(SpanJson);
    end;
```

**Step 2: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 3: Commit**

```
feat(sentry): rewrite SentrySpan.ToJson to native JsonObject
```

---

### Task 3: SentryError — native JsonObject

**Files:**
- Modify: `Application/src/Sentry/SentryError.Codeunit.al`

**Step 1: Change `ToJson` to return `JsonObject`**

Replace lines 26-96 with:

```al
    procedure ToJson(): JsonObject
    var
        SentryMetadata: Codeunit "NPR Sentry Metadata";
        SentryErrorHandling: Codeunit "NPR Sentry Error Handling";
        EventJson: JsonObject;
        UserJson: JsonObject;
        ExceptionJson: JsonObject;
        ValuesArray: JsonArray;
        ExceptionValue: JsonObject;
        MechanismJson: JsonObject;
        StacktraceJson: JsonObject;
        FramesArray: JsonArray;
        FrameJson: JsonObject;
        ContextsJson: JsonObject;
        TraceJson: JsonObject;
        ErrorCallStack: List of [Text];
        ErrorFrame: Text;
        HasFrames: Boolean;
    begin
        EventJson.Add('event_id', _id);
        EventJson.Add('timestamp', _timestampUtc);
        EventJson.Add('platform', 'other');
        EventJson.Add('release', _release);
        EventJson.Add('environment', SentryMetadata.GetEnvironment());
        EventJson.Add('level', 'error');

        UserJson.Add('id', Format(UserSecurityId(), 0, 4).ToLower());
        UserJson.Add('username', UserId);
        EventJson.Add('user', UserJson);

        MechanismJson.Add('type', 'generic');
        MechanismJson.Add('handled', false);

        SentryErrorHandling.SplitErrorStacktrace(_errorCallstack, ErrorCallStack);
        HasFrames := false;
        foreach ErrorFrame in ErrorCallStack do begin
            if ErrorFrame.Trim() <> '' then begin
                Clear(FrameJson);
                FrameJson.Add('function', ErrorFrame);
                FramesArray.Add(FrameJson);
                HasFrames := true;
            end;
        end;
        if not HasFrames then begin
            FrameJson.Add('function', '<unknown>');
            FramesArray.Add(FrameJson);
        end;

        StacktraceJson.Add('frames', FramesArray);

        ExceptionValue.Add('type', GetExceptionType());
        ExceptionValue.Add('value', _errorText);
        ExceptionValue.Add('mechanism', MechanismJson);
        ExceptionValue.Add('stacktrace', StacktraceJson);

        ValuesArray.Add(ExceptionValue);
        ExceptionJson.Add('values', ValuesArray);
        EventJson.Add('exception', ExceptionJson);

        EventJson.Add('modules', SentryMetadata.WriteModulesJson());

        EventJson.Add('tags', SentryMetadata.WriteTagsForBackendEvent());

        TraceJson.Add('trace_id', _traceId);
        TraceJson.Add('span_id', _parentSpanId);
        ContextsJson.Add('trace', TraceJson);
        EventJson.Add('contexts', ContextsJson);

        exit(EventJson);
    end;
```

**Step 2: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 3: Commit**

```
feat(sentry): rewrite SentryError.ToJson to native JsonObject
```

---

### Task 4: SentryTransaction — native JsonObject

**Files:**
- Modify: `Application/src/Sentry/SentryTransaction.Codeunit.al`

**Step 1: Rewrite `Log` procedure to use native JsonObject**

Replace lines 125-211 with:

```al
    procedure Log(var Spans: List of [Codeunit "NPR Sentry Span"]; var Errors: List of [Codeunit "NPR Sentry Error"])
    var
        Span: Codeunit "NPR Sentry Span";
        Error: Codeunit "NPR Sentry Error";
        SentryMetadata: Codeunit "NPR Sentry Metadata";
        EventJson: JsonObject;
        UserJson: JsonObject;
        TransactionInfoJson: JsonObject;
        ContextsJson: JsonObject;
        TraceJson: JsonObject;
        TagsJson: JsonObject;
        DataJson: JsonObject;
        SpansArray: JsonArray;
        ErrorJson: JsonObject;
        EventDimensions: Dictionary of [Text, Text];
        ExceptionDimensions: Dictionary of [Text, Text];
        TagKey: Text;
        DataKey: Text;
        JsonText: Text;
    begin
        if Errors.Count > 0 then
            _status := _status::InternalError;

        EventJson.Add('event_id', Format(CreateGuid(), 0, 3).ToLower());
        EventJson.Add('start_timestamp', _startedTimestampUtc);
        EventJson.Add('timestamp', _finishedTimestampUtc);
        EventJson.Add('transaction', _description);

        TransactionInfoJson.Add('source', _source);
        EventJson.Add('transaction_info', TransactionInfoJson);

        EventJson.Add('platform', 'other');
        EventJson.Add('release', _appRelease);
        EventJson.Add('type', 'transaction');
        EventJson.Add('environment', SentryMetadata.GetEnvironment());
        EventJson.Add('level', 'info');

        UserJson.Add('id', Format(UserSecurityId(), 0, 4).ToLower());
        UserJson.Add('username', UserId);
        EventJson.Add('user', UserJson);

        TraceJson.Add('trace_id', _traceId);
        TraceJson.Add('span_id', _rootSpanId);
        TraceJson.Add('op', _operation);
        TraceJson.Add('status', Format(_status));
        if _externalSpanId <> '' then
            TraceJson.Add('parent_span_id', _externalSpanId);
        ContextsJson.Add('trace', TraceJson);
        EventJson.Add('contexts', ContextsJson);

        EventJson.Add('modules', SentryMetadata.WriteModulesJson());

        TagsJson := SentryMetadata.WriteTagsForBackendEvent();
        foreach TagKey in _customTags.Keys() do
            TagsJson.Add(TagKey, _customTags.Get(TagKey));
        EventJson.Add('tags', TagsJson);

        if _customData.Count > 0 then begin
            foreach DataKey in _customData.Keys() do
                DataJson.Add(DataKey, _customData.Get(DataKey));
            EventJson.Add('data', DataJson);
        end;

        foreach Span in Spans do
            SpansArray.Add(Span.ToJson(_traceId));
        EventJson.Add('spans', SpansArray);

        EventJson.WriteTo(JsonText);

        EventDimensions.Add('NPRSentryDsn', _dsn);
        AddJsonChunks(EventDimensions, JsonText);
        Session.LogMessage('NPRSentryTransaction', 'sentryPayload', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, EventDimensions);

        foreach Error in Errors do begin
            ErrorJson := Error.ToJson();
            ErrorJson.WriteTo(JsonText);

            Clear(ExceptionDimensions);
            ExceptionDimensions.Add('NPRSentryDsn', _dsn);
            AddJsonChunks(ExceptionDimensions, JsonText);
            ExceptionDimensions.Add('NPRSentryTraceId', _traceId);
            ExceptionDimensions.Add('NPRSentrySpanId', Error.GetParentId());
            Session.LogMessage('NPRSentryException', 'sentryPayload', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, ExceptionDimensions);
        end;
    end;
```

**Step 2: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 3: Commit**

```
feat(sentry): rewrite SentryTransaction.Log to native JsonObject
```

---

### Task 5: APIRequestProcessor — replace JSON Parser with native JsonObject

**Files:**
- Modify: `Application/src/_API/_public/APIRequestProcessor.Codeunit.al`

**Step 1: Replace JSON Parser usage in `ProcessRequest`**

Replace lines 61-78 with direct JsonObject.Get() calls. Remove the `jsonParser` variable declaration (line 61).

```al
        // Replace the jsonParser block (lines 61, 71-78) with:
        // Remove: jsonParser: Codeunit "NPR JSON Parser"; from var section
        // Add to var section: jToken: JsonToken;
        // Remove: requestBodyStr: Text; (no longer needed)

        // Lines 71-80 become:
        if requestJson.Get('httpMethod', jToken) then
            requestHttpMethodStr := jToken.AsValue().AsText();
        if requestJson.Get('path', jToken) then
            requestPath := jToken.AsValue().AsText();
        if requestJson.Get('body', jToken) then
            requestBodyJson := jToken;  // Direct token assignment — works for object, array, and primitive bodies
        ParseDictionaryFromJson(requestJson, 'queryParams', requestQueryParams);
        ParseDictionaryFromJson(requestJson, 'headers', requestHeaders);
        ParseListFromJson(requestJson, 'relativePathSegments', requestRelativePathSegments);

        // Also remove the old line 80: if (not requestBodyJson.ReadFrom(requestBodyStr)) then;
        // It is no longer needed since we get the body token directly.
```

**Step 2: Add local helper procedures**

Add after the `BuildParameterizedTransactionName` procedure:

```al
    local procedure ParseDictionaryFromJson(SourceJson: JsonObject; PropertyName: Text; var Dict: Dictionary of [Text, Text])
    var
        jToken: JsonToken;
        PropToken: JsonToken;
        ChildObj: JsonObject;
        PropName: Text;
    begin
        Clear(Dict);
        if not SourceJson.Get(PropertyName, jToken) then
            exit;
        if not jToken.IsObject() then
            exit;
        ChildObj := jToken.AsObject();
        foreach PropName in ChildObj.Keys() do
            if ChildObj.Get(PropName, PropToken) and PropToken.IsValue() then
                Dict.Add(PropName, PropToken.AsValue().AsText());
    end;

    local procedure ParseListFromJson(SourceJson: JsonObject; PropertyName: Text; var ListOut: List of [Text])
    var
        jToken: JsonToken;
        ArrayElement: JsonToken;
    begin
        Clear(ListOut);
        if not SourceJson.Get(PropertyName, jToken) then
            exit;
        if not jToken.IsArray() then
            exit;
        foreach ArrayElement in jToken.AsArray() do
            ListOut.Add(ArrayElement.AsValue().AsText());
    end;
```

**Step 3: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 4: Commit**

```
feat(api): replace JSON Parser with native JsonObject in request processing
```

---

### Task 6: APIResponse — replace JSON Builder in internal methods

**Files:**
- Modify: `Application/src/_API/_public/APIResponse.Codeunit.al`

**Step 1: Replace `CreateErrorResponse` (the 4-param overload, line 421)**

Replace lines 421-451 with:

```al
    procedure CreateErrorResponse(ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text; ErrorStatusCode: enum "NPR API HTTP Status Code"): Codeunit "NPR API Response"
    var
        ErrorJson: JsonObject;
        ErrorCodeName: Text;
    begin
        InitcurrCodeunit();
        if (ErrorMessage.Trim() = '') then begin
            ErrorMessage := Format(ErrorCode);
        end;

        if (ErrorStatusCode.AsInteger() = 0) then begin
            ErrorStatusCode := "NPR API HTTP Status Code"::"Bad Request";
        end else begin
            if (not (ErrorStatusCode.AsInteger() in [400 .. 499])) then begin
                Error(UnsupportedErrorStatusCodeErr, ErrorStatusCode.AsInteger());
            end;
        end;

        ErrorCodeName := ErrorCode.Names.Get(ErrorCode.Ordinals.IndexOf(ErrorCode.AsInteger()));

        ErrorJson.Add('code', ErrorCodeName);
        ErrorJson.Add('message', ErrorMessage);

        Init();
        SetStatusCode(ErrorStatusCode);
        SetJson(ErrorJson);
        exit(_CurrCodeunit);
    end;
```

**Step 2: Replace `CreateSimpleJsonResponse` (line 453)**

```al
    local procedure CreateSimpleJsonResponse(PropertyName: Text; PropertyValue: Text): JsonObject
    var
        SimpleJson: JsonObject;
    begin
        SimpleJson.Add(PropertyName, PropertyValue);
        exit(SimpleJson);
    end;
```

**Step 3: Replace `GetProxyResponseMetadata` (line 471)**

```al
    local procedure GetProxyResponseMetadata(): JsonObject
    var
        ProxyJson: JsonObject;
    begin
        ProxyJson.Add('sentryTags', GetSentryTagsJsonObject());
        ProxyJson.Add('sentrySpanAttributes', GetSentrySpanAttributesJsonObject());
        exit(ProxyJson);
    end;
```

**Step 4: Replace `GetSentryTagsJsonObject` (line 485)**

```al
    local procedure GetSentryTagsJsonObject(): JsonObject
    var
        TagsJson: JsonObject;
        TagKey: Text;
    begin
        foreach TagKey in _SentryTags.Keys() do
            TagsJson.Add(TagKey, _SentryTags.Get(TagKey));
        exit(TagsJson);
    end;
```

**Step 5: Replace `GetSentrySpanAttributesJsonObject` (line 508)**

```al
    local procedure GetSentrySpanAttributesJsonObject(): JsonObject
    var
        AttribsJson: JsonObject;
        AttrKey: Text;
    begin
        foreach AttrKey in _SentrySpanAttribs.Keys() do
            AttribsJson.Add(AttrKey, _SentrySpanAttribs.Get(AttrKey));
        exit(AttribsJson);
    end;
```

**Step 6: Replace `AddSentrySpanAttribute` (line 519)**

Replace the JsonBuilder usage with a local `CreateJsonValue` helper:

```al
    procedure AddSentrySpanAttribute(AttrKey: Text; AttrValue: Variant): Codeunit "NPR API Response"
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        InitcurrCodeunit();
        _SentrySpanAttribs.Add(AttrKey, VariantToJsonValue(AttrValue));
        Sentry.AddTransactionData(AttrKey, Format(AttrValue));
        exit(_CurrCodeunit);
    end;

    local procedure VariantToJsonValue(Value: Variant): JsonValue
    var
        JValue: JsonValue;
        BooleanValue: Boolean;
        IntegerValue: Integer;
        DecimalValue: Decimal;
        TextValue: Text;
        DateValue: Date;
        TimeValue: Time;
        DateTimeValue: DateTime;
    begin
        case true of
            Value.IsBoolean:
                begin
                    BooleanValue := Value;
                    JValue.SetValue(BooleanValue);
                end;
            Value.IsInteger:
                begin
                    IntegerValue := Value;
                    JValue.SetValue(IntegerValue);
                end;
            Value.IsDecimal:
                begin
                    DecimalValue := Value;
                    JValue.SetValue(DecimalValue);
                end;
            Value.IsDate:
                begin
                    DateValue := Value;
                    JValue.SetValue(Format(DateValue, 0, 9));
                end;
            Value.IsTime:
                begin
                    TimeValue := Value;
                    JValue.SetValue(Format(TimeValue, 0, 9));
                end;
            Value.IsDateTime:
                begin
                    DateTimeValue := Value;
                    JValue.SetValue(Format(DateTimeValue, 0, 9));
                end;
            Value.IsCode, Value.IsText:
                begin
                    TextValue := Value;
                    JValue.SetValue(TextValue);
                end;
            Value.IsJsonValue:
                begin
                    JValue := Value;
                end;
            else begin
                TextValue := Format(Value);
                JValue.SetValue(TextValue);
            end;
        end;
        exit(JValue);
    end;
```

**Step 7: Remove the `Codeunit "NPR JSON Builder"` and `Codeunit "NPR Json Builder"` variable declarations** from every procedure that no longer uses them. Ensure `RespondOK(JsonBuilder)` and `RespondCreated(JsonBuilder)` overloads are untouched.

**Step 8: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 9: Commit**

```
feat(api): replace JSON Builder with native JsonObject in APIResponse
```

---

### Task 7: APIRequest record serialization — native JsonObject + BC26 SetAutoCalcFields

**Files:**
- Modify: `Application/src/_API/_public/APIRequest.Codeunit.al`

**Step 1: Rewrite `AddFieldToJson` to use native `JsonObject`**

Replace lines 335-399 with:

```al
    local procedure AddFieldToJson(var FieldRef: FieldRef; var JsonObj: JsonObject; FieldName: Text)
    var
        StringValue: Text;
        BooleanValue: Boolean;
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BigIntegerValue: BigInteger;
        PrevLanguage: Integer;
    begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
        if FieldRef.Class = FieldCLass::FlowField then
            FieldRef.CalcField();
#endif

        if FieldRef.Number = 0 then begin
            JsonObj.Add(FieldName, Format(FieldRef.Value(), 0, 9));
            exit;
        end;

        case FieldRef.Type() of
            FieldRef.Type::Integer:
                begin
                    IntegerValue := FieldRef.Value();
                    JsonObj.Add(FieldName, IntegerValue);
                end;
            FieldRef.Type::Decimal:
                begin
                    DecimalValue := FieldRef.Value();
                    JsonObj.Add(FieldName, DecimalValue);
                end;
            FieldRef.Type::Boolean:
                begin
                    BooleanValue := FieldRef.Value();
                    JsonObj.Add(FieldName, BooleanValue);
                end;
            FieldRef.Type::Text,
            FieldRef.Type::Code:
                begin
                    StringValue := FieldRef.Value();
                    JsonObj.Add(FieldName, StringValue);
                end;
            FieldRef.Type::BigInteger:
                begin
                    BigIntegerValue := FieldRef.Value();
                    JsonObj.Add(FieldName, BigIntegerValue);
                end;
            FieldRef.Type::Guid:
                JsonObj.Add(FieldName, Format(FieldRef.Value(), 0, 4).ToLower());
            FieldRef.Type::Option:
                begin
                    PrevLanguage := GlobalLanguage();
                    JsonObj.Add(FieldName, Format(FieldRef.Value));
                    GlobalLanguage(PrevLanguage);
                end;
            else begin
                if FieldRef.IsEnum() then
                    JsonObj.Add(FieldName, FieldRef.GetEnumValueName(FieldRef.Value))
                else
                    JsonObj.Add(FieldName, Format(FieldRef.Value(), 0, 9));
            end;
        end;
    end;
```

**Step 2: Rewrite `GetRecord` to use native JsonObject**

Replace lines 137-170 with:

```al
    local procedure GetRecord(var RecRef: RecordRef; Fields: Dictionary of [Integer, Text]; id: Text): JsonObject
    var
        RecordJson: JsonObject;
        FieldNo: Integer;
        FieldRef: FieldRef;
        Field: Record Field;
    begin
        if not Fields.ContainsKey(RecRef.SystemIdNo()) then
            Fields.Add(RecRef.SystemIdNo(), 'id');

        foreach FieldNo in Fields.Keys() do begin
            Field.Get(RecRef.Number(), FieldNo);
            if Field.Class = Field.Class::Normal then
                RecRef.AddLoadFields(FieldNo);
        end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        SetAutoCalcFieldsFromFields(RecRef, Fields);
#endif

        if not Fields.ContainsKey(0) then
            Fields.Add(0, 'rowVersion');

        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;
        RecRef.GetBySystemId(id);

        foreach FieldNo in Fields.Keys() do begin
            FieldRef := RecRef.Field(FieldNo);
            AddFieldToJson(FieldRef, RecordJson, Fields.Get(FieldNo));
        end;

        exit(RecordJson);
    end;
```

**Step 3: Rewrite `GetRecords` to use native JsonArray**

Replace lines 172-262 with:

```al
    local procedure GetRecords(var RecRef: RecordRef; Fields: Dictionary of [Integer, Text]): JsonObject
    var
        DataArray: JsonArray;
        RecordJson: JsonObject;
        ResultJson: JsonObject;
        Limit: Integer;
        FieldNo: Integer;
        i: Integer;
        FieldRef: FieldRef;
        MoreRecords: Boolean;
        PageKey: Text;
        Field: Record Field;
        Sync: Boolean;
        PageContinuation: Boolean;
        DataFound: Boolean;
    begin
        if _QueryParams.ContainsKey('pageSize') then
            Evaluate(Limit, _QueryParams.Get('pageSize'));

        if (limit < 1) or (limit > 20000) then
            limit := 20000;

        if _QueryParams.ContainsKey('pageKey') then begin
            ApplyPageKey(_QueryParams.Get('pageKey'), RecRef);
            PageContinuation := true;
        end;

        if _QueryParams.ContainsKey('sync') then begin
            Evaluate(Sync, _QueryParams.Get('sync'));
            if Sync then
                SetKeyToRowVersion(RecRef);

            if _QueryParams.ContainsKey('lastRowVersion') then
                RecRef.Field(0).SetFilter('>%1', _QueryParams.Get('lastRowVersion'));
        end;

        if not Fields.ContainsKey(RecRef.SystemIdNo()) then
            Fields.Add(RecRef.SystemIdNo(), 'id');

        foreach FieldNo in Fields.Keys() do begin
            Field.Get(RecRef.Number(), FieldNo);
            if Field.Class = Field.Class::Normal then
                RecRef.AddLoadFields(FieldNo);
        end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        SetAutoCalcFieldsFromFields(RecRef, Fields);
#endif

        if Sync and (not Fields.ContainsKey(0)) then
            Fields.Add(0, 'rowVersion');

        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;

        if PageContinuation then
            DataFound := RecRef.Find('>')
        else
            DataFound := RecRef.Find('-');

        if DataFound then begin
            repeat
                Clear(RecordJson);
                foreach FieldNo in Fields.Keys() do begin
                    FieldRef := RecRef.Field(FieldNo);
                    AddFieldToJson(FieldRef, RecordJson, Fields.Get(FieldNo));
                end;
                DataArray.Add(RecordJson);

                i += 1;
                if (i = Limit) then
                    PageKey := GetPageKey(RecRef);
                MoreRecords := RecRef.Next() <> 0;
            until (not MoreRecords) or (i = Limit);
        end;

        if not MoreRecords then
            PageKey := '';

        ResultJson.Add('morePages', MoreRecords);
        ResultJson.Add('nextPageKey', PageKey);
        ResultJson.Add('nextPageURL', GetNextPageUrl(PageKey));
        ResultJson.Add('data', DataArray);

        exit(ResultJson);
    end;
```

**Step 4: Add the BC26+ `SetAutoCalcFieldsFromFields` helper**

Add after `AddFieldToJson`:

The BC26 signature is `RecordRef.SetAutoCalcFields([Fields: Integer, ...])` — it takes field numbers as variadic Integer parameters. Since AL variadic params require literal arguments (you cannot pass a list), we must collect the FlowField numbers and call `SetAutoCalcFields` with up to a reasonable fixed number of parameters. Use a helper that collects FlowField numbers into a list and dispatches to the appropriate overload.

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
    local procedure SetAutoCalcFieldsFromFields(var RecRef: RecordRef; Fields: Dictionary of [Integer, Text])
    var
        FieldNo: Integer;
        Field: Record Field;
    begin
        // SetAutoCalcFields is additive — each call adds to the set of auto-calculated fields.
        foreach FieldNo in Fields.Keys() do begin
            if FieldNo <> 0 then begin
                Field.Get(RecRef.Number(), FieldNo);
                if Field.Class = Field.Class::FlowField then
                    RecRef.SetAutoCalcFields(FieldNo);
            end;
        end;
    end;
#endif
```

Update `AddFieldToJson` so it only calls `CalcField` on pre-BC26 versions:

```al
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
        if FieldRef.Class = FieldCLass::FlowField then
            FieldRef.CalcField();
#endif
```

**Step 5: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 6: Commit**

```
feat(api): native JsonObject for record serialization, BC26+ SetAutoCalcFields
```

---

### Task 8: Remove SQL tracking headers + clean up session metadata

**Files:**
- Modify: `Application/src/_API/_public/APIResponse.Codeunit.al`
- Modify: `Application/src/_API/_public/APIRequestProcessor.Codeunit.al`
- Modify: `Application/src/_API/APISessionMetadata.Codeunit.al`

**Step 1: Simplify `AddMetadataHeaders` in APIResponse (line 130)**

Replace lines 130-143 with:

```al
    internal procedure AddMetadataHeaders(SessionMetadata: Codeunit "NPR API Session Metadata"): Codeunit "NPR API Response";
    begin
        AddHeader('x-npr-start-time', Format(SessionMetadata.GetStartTime(), 0, 9));
        AddHeader('x-npr-end-time', Format(CurrentDateTime(), 0, 9));
        AddHeader('x-npr-duration', Format(CurrentDateTime() - SessionMetadata.GetStartTime()));

        AddSentryTag('http.status_code', Format(_StatusCode));

        exit(_CurrCodeunit);
    end;
```

**Step 2: Remove SQL tracking from `httpmethod` in APIRequestProcessor (lines 31-32)**

Remove these two lines:
```al
        _SessionMetadata.SetStartRowsRead(SessionInformation.SqlRowsRead());
        _SessionMetadata.SetStartStatementsExecuted(SessionInformation.SqlStatementsExecuted());
```

**Step 3: Clean up `APISessionMetadata.Codeunit.al`**

Replace the entire file with:

```al
codeunit 6150730 "NPR API Session Metadata"
{
    Access = Internal;

    var
        _StartTime: DateTime;

    procedure SetStartTime(StartTime: DateTime)
    begin
        _StartTime := StartTime;
    end;

    procedure GetStartTime(): DateTime
    begin
        exit(_StartTime);
    end;
}
```

**Step 4: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings`

**Step 5: Commit**

```
perf(api): remove SQL roundtrip tracking headers from API responses
```

---

### Task 9: SQL roundtrip budget test

**Files:**
- Modify: `Test/src/Tests/API/APIModuleTests.Codeunit.al`

**Step 1: Add the roundtrip budget test**

Add before the existing `local procedure InitializeData()` (line 164):

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HelloWorldSqlRoundtripBudget()
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SqlBefore: BigInteger;
        SqlAfter: BigInteger;
        SqlRoundtrips: BigInteger;
        MaxAllowedRoundtrips: BigInteger;
    begin
        // [SCENARIO] The helloworld API endpoint should use minimal SQL roundtrips
        // to catch regressions where someone adds DB reads to the generic hot path.

        // [GIVEN] API permissions are set up and cache is skipped
        LibraryAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API HelloWorld');
        SelectLatestVersion();

        // [WHEN] We call the helloworld API and measure SQL roundtrips
        SqlBefore := SessionInformation.SqlStatementsExecuted();
        Response := LibraryAPI.CallApi('GET', '/helloworld', Response, QueryParams, Headers);
        SqlAfter := SessionInformation.SqlStatementsExecuted();
        SqlRoundtrips := SqlAfter - SqlBefore;

        // [THEN] The response is successful
        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), 'HelloWorld API should return success');

        // [THEN] SQL roundtrips stay within budget
        MaxAllowedRoundtrips := 1;
        Assert.IsTrue(SqlRoundtrips <= MaxAllowedRoundtrips,
            StrSubstNo('HelloWorld API used %1 SQL roundtrips (max allowed: %2). If you intentionally added DB reads to the generic API path, increase this budget and document why.', SqlRoundtrips, MaxAllowedRoundtrips));
    end;
```

**Step 2: Compile and verify no errors**

Run: `/bcdev compile -suppressWarnings` (for the Test app)

**Step 3: Commit**

```
test(api): add SQL roundtrip budget test for helloworld endpoint
```

---

### Post-implementation

After all tasks are complete:

1. Run existing API pagination tests to verify no regressions
2. Run the new roundtrip budget test — if it fails, the error message shows the actual count; adjust `MaxAllowedRoundtrips` to match observed baseline + margin and document why
3. Verify the Sentry transaction JSON output is structurally identical (same keys, same nesting) by comparing a sample before/after
