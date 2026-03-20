# Sentry Performance Optimizations Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:executing-plans to implement this plan task-by-task.

**Goal:** Reduce Sentry telemetry CPU overhead and payload size by minimizing per-span tags and capping span count at 200.

**Architecture:** Two independent changes: (1) replace full 15-field tag clone per span with a 2-field cached reference, (2) add a `_tracingEnabled` flag that flips to false at 200 spans, causing `Span.Create` and `Span.SetMetadata` to noop via empty `_id` checks.

**Tech Stack:** AL (Business Central), Sentry telemetry protocol

**Branch:** `mmv/sentry-json-optimizations` (existing, has FinalizeSpan changes already committed)

**Design doc:** `.plans/2026-03-11-mmv-sentry-perf-optimizations-design.md`

---

### Task 1: Add WriteSpanTags to SentryMetadata

**Files:**
- Modify: `Application/src/Sentry/SentryMetadata.Codeunit.al`

**Step 1: Add cached span tags variables**

Add two new vars after `_cachedModulesJson`:

```al
    var
        _tagsLoaded: Boolean;
        _cachedTags: JsonObject;
        _modulesJsonLoaded: Boolean;
        _cachedModulesJson: JsonObject;
        _spanTagsLoaded: Boolean;
        _cachedSpanTags: JsonObject;
```

**Step 2: Add WriteSpanTags procedure**

Add before `GetEnvironment()` (around line 137):

```al
    internal procedure WriteSpanTags(): JsonObject
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        if _spanTagsLoaded then
            exit(_cachedSpanTags.Clone().AsObject());

        if EnvironmentInformation.IsSaaSInfrastructure() then
            _cachedSpanTags.Add('aadTenantId', AzureADTenant.GetAadTenantId())
        else
            _cachedSpanTags.Add('aadTenantId', '_');

        _cachedSpanTags.Add('company', CompanyName());

        _spanTagsLoaded := true;
        exit(_cachedSpanTags.Clone().AsObject());
    end;
```

Key differences from `WriteTagsForBackendEvent()`:
- Only 2 fields: `aadTenantId` and `company` (vs ~15 fields)
- Still uses `.Clone().AsObject()` — required because Newtonsoft JToken detaches from its old parent when added to a new one, so without clone only the last span would keep its tags. But cloning 2 fields is much cheaper than cloning 15.

**Step 3: Compile and verify**

Run: `/bcdev compile -suppressWarnings`
Expected: No errors

**Step 4: Commit**

```
git add Application/src/Sentry/SentryMetadata.Codeunit.al
git commit -m "Add WriteSpanTags to SentryMetadata with minimal cached tags"
```

---

### Task 2: Replace full tags with span tags in SentrySpan.ToJson

**Files:**
- Modify: `Application/src/Sentry/_public/SentrySpan.Codeunit.al`

**Step 1: Replace WriteTagsForBackendEvent with WriteSpanTags**

In `ToJson()` (line 168), change:

```al
        SpanJson.Add('tags', SentryMetadata.WriteTagsForBackendEvent());
```

to:

```al
        SpanJson.Add('tags', SentryMetadata.WriteSpanTags());
```

No other changes needed — the `SentryMetadata` var declaration on line 149 stays as-is.

**Step 2: Compile and verify**

Run: `/bcdev compile -suppressWarnings`
Expected: No errors

**Step 3: Commit**

```
git add "Application/src/Sentry/_public/SentrySpan.Codeunit.al"
git commit -m "Use minimal span tags instead of full tag set per span"
```

---

### Task 3: Add _tracingEnabled flag and AddSpanToList helper to SentryScope

**Files:**
- Modify: `Application/src/Sentry/SentryScope.Codeunit.al`

**Step 1: Add _tracingEnabled variable**

Add to the var section (after `_activeSpanId`):

```al
    var
        _spans: List of [Codeunit "NPR Sentry Span"];
        _errors: List of [Codeunit "NPR Sentry Error"];
        _transaction: Codeunit "NPR Sentry Transaction";
        _activeSpanId: Text;
        _tracingEnabled: Boolean;
```

**Step 2: Set _tracingEnabled in InitScopeAndTransaction**

In the `InitScopeAndTransaction` overload with `SamplingRate` parameter (the one that calls `_transaction.Create`), add after `_activeSpanId` assignment:

```al
        _transaction.Create(Name, Operation, Dsn, AppRelease, ExternalTraceId, ExternalSpanId, sample, StartTime);
        _activeSpanId := _transaction.GetRootSpanId();
        _tracingEnabled := true;
```

Note: set to `true` unconditionally — `_tracingEnabled` is about span cap, not sampling. Sampling is handled separately by the existing `FinalizeScope` check.

**Step 3: Add AddSpanToList and IsTracingEnabled procedures**

Add after `SetActiveSpanStatus` (around line 463):

```al
    local procedure AddSpanToList(var Span: Codeunit "NPR Sentry Span")
    begin
        if Span.GetId() = '' then
            exit;

        _spans.Add(Span);

        if _spans.Count >= 200 then begin
            _tracingEnabled := false;
            _transaction.AddTag('span_limit_reached', 'true');
        end;
    end;

    internal procedure IsTracingEnabled(): Boolean
    begin
        exit(_tracingEnabled);
    end;
```

**Step 4: Replace all _spans.Add(Span) with AddSpanToList(Span)**

Replace all 15 occurrences of `_spans.Add(Span)` with `AddSpanToList(Span)` in:
- `StartSpan` (line 97)
- `HttpInvoke` (line 110)
- `ReportRun` x2 (lines 139, 153)
- `PageRunModal` x2 (lines 178, 206)
- `RecordFindSet` (line 234)
- `RecordFind` (line 263)
- `RecordDelete` (line 292)
- `RecordIsEmpty` (line 320)
- `RecordNext` (line 343)
- `DeleteAll` (line 365)
- `CodeunitRun` (line 387)
- `Confirm` (line 407)
- `StrMenu` (line 427)

Use replace-all for `_spans.Add(Span);` → `AddSpanToList(Span);`

**Step 5: Compile and verify**

Run: `/bcdev compile -suppressWarnings`
Expected: No errors

**Step 6: Commit**

```
git add Application/src/Sentry/SentryScope.Codeunit.al
git commit -m "Add span limit of 200 with _tracingEnabled flag and AddSpanToList helper"
```

---

### Task 4: Gate Span.Create and SetMetadata on tracing state

**Files:**
- Modify: `Application/src/Sentry/_public/SentrySpan.Codeunit.al`

**Step 1: Add early exit to Span.Create**

Add at the start of `Create()` body (before GUID generation):

```al
    internal procedure Create(parentId: Text; description: Text; operation: Text)
    var
        Guid: Text;
    begin
        if not _SentryScope.IsTracingEnabled() then
            exit;

        Guid := Format(CreateGuid(), 0, 3).ToLower();
```

When this exits early, `_id` stays empty. This causes:
- `AddSpanToList` to exit (empty ID check)
- `SetMetadata` to exit (empty ID checks added below)
- `Finish()` to exit (existing empty ID check)
- `_activeSpanId` unchanged (no `SetActiveSpanId` call)

**Step 2: Add early exit to SetMetadata (HTTP overload)**

Add at the start of `SetMetadata(HttpClient, ...)`:

```al
    internal procedure SetMetadata(var Client: HttpClient; var Request: HttpRequestMessage; var Response: HttpResponseMessage; Success: Boolean)
    begin
        if _id = '' then
            exit;

        _metadata.Add('method', Request.Method);
```

**Step 3: Add early exit to SetMetadata (DB overload)**

Add at the start of `SetMetadata(Operation, RecRef, ...)`. This is the critical one — it skips the expensive `RecRef.GetView(true)`:

```al
    internal procedure SetMetadata(Operation: Text; var RecRef: RecordRef; RowsRead: BigInteger; Result: Boolean)
    var
        PrevLanguage: Integer;
    begin
        if _id = '' then
            exit;

        PrevLanguage := GlobalLanguage();
```

**Step 4: Compile and verify**

Run: `/bcdev compile -suppressWarnings`
Expected: No errors

**Step 5: Commit**

```
git add "Application/src/Sentry/_public/SentrySpan.Codeunit.al"
git commit -m "Gate Span.Create and SetMetadata on tracing state for span limit noop"
```
