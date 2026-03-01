# Sentry Early Transaction & Observability Improvements

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Move Sentry transaction start to the earliest BC session trigger so we capture initialization overhead, mirror API response sentry tags/attributes into the AL-side transaction, and add cache-miss observability to SkipCacheIfNonStickyRequest.

**Architecture:** A new SingleInstance codeunit subscribes to OnCompanyOpenCompleted (the earliest non-obsolete platform trigger, fires before OnAfterLogin) and captures the session start timestamp for OData/API sessions. Since each web service request is its own BC session, the SingleInstance codeunit lives exactly for one request — no reuse concerns. The API module reads that timestamp to backdate its Sentry transaction, then starts a child span for actual API processing so the gap is visible. The SentryScope/SentryTransaction gain custom tag dictionaries that get merged into the transaction JSON. APIResponse pipes its sentry tags into the Sentry transaction in addition to the proxy metadata. SkipCacheIfNonStickyRequest adds sentry transaction tags for server IDs and cache misses.

**Tech Stack:** AL (Business Central), Sentry SDK (custom codeunits), compiler preprocessor directives (BC23+ for both API module and session init codeunit).

**Preprocessor context:** The API module uses `#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22`. The Sentry module uses `#if not (BC17 or BC18 or BC19 or BC20 or BC21)`. The new session init codeunit uses the same guard as the API module (`#if not BC17 and not BC18...not BC22`) since it only exists to serve the API module.

---

## Task 1: Create the SingleInstance session timestamp codeunit

**Purpose:** Capture `CurrentDateTime()` at the earliest platform trigger (`OnCompanyOpenCompleted`) for API/OData sessions. Each web service request is its own BC session, so the SingleInstance codeunit is fresh per request.

**Files:**
- Create: `Application/src/_API/APIWebServiceSessionInit.Codeunit.al`

**Step 1: Get the next available object ID**

Use the `/al-id-manager` skill to get a codeunit ID in the appropriate range.

**Step 2: Create the codeunit**

```al
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit {ID} "NPR API WS Session Init"
{
    Access = Internal;
    SingleInstance = true;

    var
        _SessionStartTime: DateTime;
        _Initialized: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpenCompleted', '', false, false)]
    local procedure OnCompanyOpenCompleted()
    begin
        if not (CurrentClientType() in [ClientType::Api, ClientType::OData, ClientType::ODataV4, ClientType::SOAP]) then
            exit;

        _SessionStartTime := CurrentDateTime();
        _Initialized := true;
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_Initialized);
    end;

    procedure GetSessionStartTime(): DateTime
    begin
        exit(_SessionStartTime);
    end;
}
#endif
```

**Key design notes:**
- `SingleInstance = true` so the timestamp persists from `OnCompanyOpenCompleted` until `httpmethod()` reads it later in the same session.
- Each web service request is its own BC session, so the SingleInstance is always fresh — no reuse concerns.
- `OnCompanyOpenCompleted` is an isolated event (BC20+), so failures don't block sign-in.
- We only capture for web service session types since interactive sessions have different Sentry flows.
- The `#if not BC17...BC22` guard matches the API module's guard. The session init codeunit exists solely to serve the API module, so there's no point compiling it for BC versions where the API module doesn't exist.

**Step 3: Commit**

```
feat: add web service session init timestamp capture
```

---

## Task 2: Add custom tags support to SentryTransaction

**Purpose:** The `SentryTransaction.Log()` currently only writes tags from `SentryMetadata.WriteTagsForBackendEvent()`. We need to support adding custom tags that can be set by the API module at response time.

**Files:**
- Modify: `Application/src/Sentry/SentryTransaction.Codeunit.al`
- Modify: `Application/src/Sentry/SentryScope.Codeunit.al`
- Modify: `Application/src/Sentry/_public/Sentry.Codeunit.al`

**Step 1: Add custom tag storage to SentryTransaction**

In `SentryTransaction.Codeunit.al`, add a new var:

```al
_customTags: Dictionary of [Text, Text];
```

Add a setter procedure (use Set to handle duplicate keys safely, avoiding collision with metadata tags):

```al
procedure AddTag(TagKey: Text; TagValue: Text)
begin
    if _customTags.ContainsKey(TagKey) then
        _customTags.Set(TagKey, TagValue)
    else
        _customTags.Add(TagKey, TagValue);
end;
```

In the `Log()` procedure, after `SentryMetadata.WriteTagsForBackendEvent(Json);` (line 138), write the custom tags. Declare `TagKey: Text` as a local var:

```al
        SentryMetadata.WriteTagsForBackendEvent(Json);
        foreach TagKey in _customTags.Keys() do
            Json.AddProperty(TagKey, _customTags.Get(TagKey));
```

**Step 2: Expose AddTag through SentryScope**

In `SentryScope.Codeunit.al`, add after the `AddLastErrorInEnglish` procedure:

```al
internal procedure AddTransactionTag(TagKey: Text; TagValue: Text)
begin
    _transaction.AddTag(TagKey, TagValue);
end;
```

**Step 3: Expose AddTag through the public Sentry codeunit**

In `Sentry.Codeunit.al`, add after the `AddError` procedures:

```al
internal procedure AddTransactionTag(TagKey: Text; TagValue: Text)
begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    SentryScope.AddTransactionTag(TagKey, TagValue);
#endif
end;
```

**Step 4: Commit**

```
feat: add custom tag support to Sentry transactions
```

---

## Task 3: Backdate Sentry transaction and add API processing span in APIRequestProcessor

**Purpose:** Use the session start timestamp from Task 1 to backdate the Sentry transaction, then wrap the actual API processing in a child span so the gap between transaction start and span start reveals BC initialization overhead. Keep `_SessionMetadata` anchored to the actual request start time (preserving existing `x-npr-*` response header behavior).

**Files:**
- Modify: `Application/src/_API/_public/APIRequestProcessor.Codeunit.al`

**Step 1: Modify httpmethod() to use session start time for Sentry only**

The key changes:
1. Read the session start time from `WSSessionInit` for the Sentry transaction (falls back to `CurrentDateTime()` if not initialized, e.g. in dev environments without the event subscriber).
2. Keep `_SessionMetadata.SetStartTime(RequestStartTime)` anchored to actual request start — this preserves existing `x-npr-duration` and `x-npr-start-time` response header semantics for API consumers.
3. Pass `SentryStartTime` (which is earlier, captured at `OnCompanyOpenCompleted`) into `ProcessRequest` for the Sentry transaction.

Replace the current `httpmethod()` (lines 11-30):

```al
    [ServiceEnabled]
    procedure httpmethod(message: Text): Text
    var
        requestJson: JsonObject;
        responseJson: JsonObject;
        responseString: Text;
        RequestStartTime: DateTime;
        SentryStartTime: DateTime;
        Sentry: Codeunit "NPR Sentry";
        WSSessionInit: Codeunit "NPR API WS Session Init";
    begin
        RequestStartTime := CurrentDateTime();

        if WSSessionInit.IsInitialized() then
            SentryStartTime := WSSessionInit.GetSessionStartTime()
        else
            SentryStartTime := RequestStartTime;

        _SessionMetadata.SetStartTime(RequestStartTime);
        _SessionMetadata.SetStartRowsRead(SessionInformation.SqlRowsRead());
        _SessionMetadata.SetStartStatementsExecuted(SessionInformation.SqlStatementsExecuted());

        requestJson.ReadFrom(message);
        responseJson := ProcessRequest(requestJson, SentryStartTime);
        responseString := Format(responseJson);
        Sentry.FinalizeScope();
        exit(responseString);
    end;
```

**Step 2: Add a child span for API processing in ProcessRequest**

In `ProcessRequest()`, after the `Sentry.InitScopeAndTransaction(...)` block (line 82), start a child span. Add `ApiProcessingSpan: Codeunit "NPR Sentry Span";` to the var block.

After the Sentry init block:

```al
        Sentry.StartSpan(ApiProcessingSpan, StrSubstNo('%1 %2', requestHttpMethodStr, requestPath));
```

Before each `exit` in ProcessRequest, finish the span. There are 5 exit points. Add `ApiProcessingSpan.Finish();` before each:

```al
        // module not found exit (~line 89):
        if (not Evaluate(apiModule, apiModuleName)) then begin
            foreach requestPathSegment in requestRelativePathSegments do begin
                requestPathSegmentsStr += StrSubstNo('/%1', requestPathSegment)
            end;
            ApiProcessingSpan.Finish();
            exit(responseCodeunit.RespondResourceNotFound(requestPathSegmentsStr).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        // ... (permission check)

        // forbidden exit (~line 99):
        if not HasUserPermissionSetAssigned(...) then begin
            ApiProcessingSpan.Finish();
            exit(responseCodeunit.RespondForbidden(...).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        // ... (resolve + handle)

        // unsupported method exit (~line 110):
            else begin
                ApiProcessingSpan.Finish();
                exit(responseCodeunit.RespondBadRequestUnsupportedHttpMethod(requestHttpMethod).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
            end;

        // not initialized exit (~line 115):
        if (not responseCodeunit.IsInitialized()) then begin
            ApiProcessingSpan.Finish();
            exit(responseCodeunit.RespondResourceNotFound().AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        // success exit (~line 118):
        ApiProcessingSpan.Finish();
        exit(responseCodeunit.AddMetadataHeaders(_SessionMetadata).GetResponseJson());
```

**Step 3: Commit**

```
feat: backdate sentry transaction to session start, add API processing span
```

---

## Task 4: Mirror APIResponse sentry tags into the AL Sentry transaction

**Purpose:** Currently `APIResponse._SentryTags` and `._SentrySpanAttribs` are only sent to the cloudflare proxy via `GetProxyResponseMetadata()`. The tags should also be written to the AL-side Sentry transaction so they appear in Sentry.io traces.

**Files:**
- Modify: `Application/src/_API/_public/APIResponse.Codeunit.al`
- Modify: `Application/src/_API/_public/APIRequestProcessor.Codeunit.al`

**Step 1: Add a procedure to APIResponse that writes tags to Sentry transaction**

In `APIResponse.Codeunit.al`, add inside the `#region Sentry Tags` section, after `AddSentryTag`:

```al
    internal procedure WriteSentryTagsToTransaction(): Codeunit "NPR API Response"
    var
        Sentry: Codeunit "NPR Sentry";
        TagKey: Text;
    begin
        InitcurrCodeunit();
        foreach TagKey in _SentryTags.Keys() do
            Sentry.AddTransactionTag(TagKey, _SentryTags.Get(TagKey));
        exit(_CurrCodeunit);
    end;
```

**Step 2: Chain WriteSentryTagsToTransaction at each exit point in APIRequestProcessor.ProcessRequest**

At each exit point in ProcessRequest, change the pattern from:
```al
exit(responseCodeunit...AddMetadataHeaders(_SessionMetadata).GetResponseJson());
```
to:
```al
exit(responseCodeunit...AddMetadataHeaders(_SessionMetadata).WriteSentryTagsToTransaction().GetResponseJson());
```

Do this for all 5 exit points. This ensures that any tags added by request handlers (like `bc.ticket_api.function_name`) get written to the AL Sentry transaction.

**Step 3: Add http.status_code as a standard transaction tag**

In the `AddMetadataHeaders` procedure of `APIResponse.Codeunit.al`, add after the existing header additions:

```al
        Sentry.AddTransactionTag('http.status_code', Format(_StatusCode));
```

This requires declaring `Sentry: Codeunit "NPR Sentry";` as a local var. The `http.status_code` tag is the most universally useful for filtering API transactions in Sentry.

**Step 4: Commit**

```
feat: mirror API response sentry tags into AL sentry transaction
```

---

## Task 5: Add cache-miss observability to SkipCacheIfNonStickyRequest

**Purpose:** When the server-cache-id header doesn't match `ServiceInstanceId()`, log both IDs and a `cacheMiss` tag so we can filter for these in Sentry.

**Files:**
- Modify: `Application/src/_API/_public/APIRequest.Codeunit.al`

**Step 1: Modify SkipCacheIfNonStickyRequest**

Replace the current procedure (lines 469-489) with:

```al
    procedure SkipCacheIfNonStickyRequest(TableIds: List of [Integer])
    var
        RequestServerId: Integer;
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
        TableId: Integer;
#endif
    begin
        if (_Headers.ContainsKey('x-server-cache-id')) then begin
            Evaluate(RequestServerId, _Headers.Get('x-server-cache-id'));
            if (RequestServerId = ServiceInstanceId()) then
                exit;
        end;

        Sentry.StartSpan(Span, 'SkipCacheIfNonStickyRequest');
        Sentry.AddTransactionTag('bc.cache.headerServerId', Format(RequestServerId));
        Sentry.AddTransactionTag('bc.cache.actualServerId', Format(ServiceInstanceId()));
        Sentry.AddTransactionTag('bc.cache.miss', 'true');

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
        foreach TableId in TableIds do begin
            SelectLatestVersion(TableId);
        end;
#else
        SelectLatestVersion();
#endif
        Span.Finish();
    end;
```

**Key design notes:**
- `RequestServerId` will be `0` if the header was missing entirely, vs a mismatched integer if the caller hit a different server. Both cases trigger `SelectLatestVersion` and both are logged.
- We use `AddTransactionTag` (from Task 2) to put `bc.cache.headerServerId`, `bc.cache.actualServerId`, and `bc.cache.miss` directly on the transaction for easy Sentry filtering.
- We wrap the `SelectLatestVersion` calls in a span to see how long the cache skip takes.

**Step 2: Commit**

```
feat: add cache-miss sentry observability to SkipCacheIfNonStickyRequest
```

---

## Task 6: Verify compilation

**Step 1:** Use `/bcdev` to download symbols and compile the Application app with `-suppressWarnings`.

**Step 2:** Fix any compilation errors.

**Step 3:** Final commit if any fixes were needed.

---

## Summary of all modified/created files

| File | Action | Task |
|------|--------|------|
| `Application/src/_API/APIWebServiceSessionInit.Codeunit.al` | Create | 1 |
| `Application/src/Sentry/SentryTransaction.Codeunit.al` | Modify | 2 |
| `Application/src/Sentry/SentryScope.Codeunit.al` | Modify | 2 |
| `Application/src/Sentry/_public/Sentry.Codeunit.al` | Modify | 2 |
| `Application/src/_API/_public/APIRequestProcessor.Codeunit.al` | Modify | 3, 4 |
| `Application/src/_API/_public/APIResponse.Codeunit.al` | Modify | 4 |
| `Application/src/_API/_public/APIRequest.Codeunit.al` | Modify | 5 |

## Review feedback addressed

This plan incorporates feedback from a codex code review:

1. **Session reuse inflation** — Not applicable. Each BC web service request is its own session; the SingleInstance codeunit is always fresh.
2. **Client-visible timing headers changed** — Fixed by keeping `_SessionMetadata.SetStartTime()` anchored to `RequestStartTime` (actual request start), not the session start. Only the Sentry transaction uses the earlier timestamp.
3. **Guard mismatch** — Fixed by aligning the new codeunit's guard to `#if not BC17...BC22` (same as API module) instead of `#if not (BC17..BC21)` (Sentry module guard).
4. **Span attributes not mirrored** — The `_SentrySpanAttribs` on APIResponse are proxy-specific metadata (they get sent as span attributes on the cloudflare-side span, not the AL-side span). The AL transaction uses tags for filterability. The existing `AddSentryTag` calls in handlers are the ones that matter for Sentry.io and those are now mirrored via `WriteSentryTagsToTransaction()`.
