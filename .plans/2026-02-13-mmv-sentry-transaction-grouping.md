# Sentry Transaction Grouping, Span Start Time & Key Vault Span

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable Sentry transaction grouping by replacing customer-specific URL segments with `*`, add precise API processing span timing, and instrument Azure Key Vault calls.

**Architecture:** Modify `APIRequest.Match()` to record the matched route template. After handler dispatch, build a parameterized transaction name (`GET /*/*/*/ticket/*/card`) and update the transaction via new `SetTransactionName` plumbing through `Sentry → SentryScope → SentryTransaction`. Add `SetStartTime` on `SentrySpan` to precisely timestamp the API processing span. Wrap key vault secret retrieval in a Sentry span guarded by `HasActiveTransaction()`.

**Tech Stack:** AL (Business Central), Sentry telemetry, preprocessor guards for BC17-BC22

---

### Task 1: Record matched route template in APIRequest.Match()

**Files:**
- Modify: `Application/src/_API/_public/APIRequest.Codeunit.al`

**Step 1: Add the var and getter**

Add `_MatchedRouteTemplate: Text` to the var section (after line 11), and a getter after the existing `#region Getters` block.

```al
// In var section, add after _BodyJson:
_MatchedRouteTemplate: Text;
```

```al
// New getter, add after BodyJson() (after line 61):
procedure GetMatchedRouteTemplate(): Text
begin
    exit(_MatchedRouteTemplate);
end;
```

**Step 2: Store the template in Match() on success**

In `Match()`, before `exit(true)` at line 94, store the matched pattern:

```al
_MatchedRouteTemplate := _fullPath;
exit(true);
```

**Step 3: Commit**

```
feat: record matched route template in APIRequest.Match()
```

---

### Task 2: Add SetDescription, SetOperation, SetSource to SentryTransaction

**Files:**
- Modify: `Application/src/Sentry/SentryTransaction.Codeunit.al`

**Step 1: Add `_source` var and initialize it**

Add `_source: Text;` to the var section (after line 21). In both `Create()` overloads, initialize `_source := 'custom';` (add after line 39, inside the full Create).

**Step 2: Replace hardcoded `'custom'` in Log()**

At line 129, change:
```al
.AddProperty('source', 'custom')
```
to:
```al
.AddProperty('source', _source)
```

**Step 3: Add setter procedures**

Add after `AddData()` (after line 106):

```al
procedure SetDescription(Name: Text)
begin
    _description := Name;
end;

procedure SetOperation(Op: Text)
begin
    _operation := Op;
end;

procedure SetSource(Source: Text)
begin
    _source := Source;
end;
```

**Step 4: Commit**

```
feat: add SetDescription/SetOperation/SetSource to SentryTransaction
```

---

### Task 3: Add SetTransactionName to SentryScope and Sentry

**Files:**
- Modify: `Application/src/Sentry/SentryScope.Codeunit.al`
- Modify: `Application/src/Sentry/_public/Sentry.Codeunit.al`

**Step 1: Add to SentryScope**

Add after `AddTransactionData()` (after line 471 in SentryScope.Codeunit.al):

```al
internal procedure SetTransactionName(Name: Text; Operation: Text)
begin
    _transaction.SetDescription(Name);
    _transaction.SetOperation(Operation);
    _transaction.SetSource('route');
end;
```

**Step 2: Add to Sentry (public codeunit)**

Add after `AddTransactionData()` (after line 203 in Sentry.Codeunit.al):

```al
internal procedure SetTransactionName(Name: Text; Operation: Text)
begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    SentryScope.SetTransactionName(Name, Operation);
#endif
end;
```

**Step 3: Commit**

```
feat: add SetTransactionName to Sentry facade
```

---

### Task 4: Build parameterized transaction name in APIRequestProcessor

**Files:**
- Modify: `Application/src/_API/_public/APIRequestProcessor.Codeunit.al`

**Step 1: Add helper function**

Add a local procedure at the bottom of the codeunit (before the closing `}` at line 160):

```al
local procedure BuildParameterizedTransactionName(HttpMethod: Text; RouteTemplate: Text): Text
var
    Segments: List of [Text];
    Segment: Text;
    Result: Text;
begin
    // Prefix: tenant/environment/company are always the first 3 segments in the full path
    Result := '/*/*/*';

    Segments := RouteTemplate.Split('/');
    Segments.Remove('');
    foreach Segment in Segments do begin
        if Segment.StartsWith(':') then
            Result += '/*'
        else
            Result += StrSubstNo('/%1', Segment);
    end;

    exit(StrSubstNo('%1 %2', HttpMethod, Result));
end;
```

**Step 2: After handler dispatch, update transaction name**

After the handler returns successfully (after the `case` block ends at line 125 and before the `not responseCodeunit.IsInitialized()` check at line 127), insert the transaction name update. Add a new var `ParameterizedName: Text;` to the `ProcessRequest` var section.

Insert after line 125 (after `end;` of the case block):

```al
if requestCodeunit.GetMatchedRouteTemplate() <> '' then begin
    ParameterizedName := BuildParameterizedTransactionName(requestHttpMethodStr, requestCodeunit.GetMatchedRouteTemplate());
    Sentry.SetTransactionName(ParameterizedName, StrSubstNo('http.server.bc:%1_%2', requestHttpMethodStr, requestCodeunit.GetMatchedRouteTemplate()));
end;
```

**Step 3: Commit**

```
feat: parameterize API transaction names for Sentry grouping
```

---

### Task 5: Add SetStartTime to SentrySpan

**Files:**
- Modify: `Application/src/Sentry/_public/SentrySpan.Codeunit.al`

**Step 1: Add the procedure**

Add after the existing `Finish(Status)` overload (after line 32):

```al
procedure SetStartTime(StartTime: DateTime)
begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    _startedTimestampUtc := Format(StartTime, 0, 9);
#endif
end;
```

**Step 2: Commit**

```
feat: add SetStartTime to SentrySpan
```

---

### Task 6: Set precise start time on ApiProcessingSpan

**Files:**
- Modify: `Application/src/_API/_public/APIRequestProcessor.Codeunit.al`

**Step 1: Pass RequestStartTime to the span**

In `ProcessRequest`, the `RequestStartTime` is not available (it's in `httpmethod()`). We need to thread it through. Change `ProcessRequest` signature to accept it:

Change line 39 from:
```al
local procedure ProcessRequest(requestJson: JsonObject; StartTime: DateTime): JsonObject
```
to:
```al
local procedure ProcessRequest(requestJson: JsonObject; StartTime: DateTime; RequestStartTime: DateTime): JsonObject
```

Update the call site at line 33:
```al
responseJson := ProcessRequest(requestJson, SentryStartTime, RequestStartTime);
```

After line 92 (`Sentry.StartSpan(ApiProcessingSpan, ...)`), add:
```al
ApiProcessingSpan.SetStartTime(RequestStartTime);
```

**Step 2: Commit**

```
feat: set precise start time on API processing span
```

---

### Task 7: Add Sentry span to Azure Key Vault secret retrieval

**Files:**
- Modify: `Application/src/Key Vault/AzureKeyVaultMgt.Codeunit.al`

**Step 1: Wrap GetAzureKeyVaultSecret with a span**

This codeunit is not guarded by preprocessor directives (it works on all BC versions), but the Sentry codeunit handles that internally with its own guards. Add span instrumentation inside `GetAzureKeyVaultSecret`, guarded by `HasActiveTransaction()` to avoid orphaned spans during Sentry init (which itself calls this codeunit to get the DSN).

Replace the body of `GetAzureKeyVaultSecret` (lines 14-36):

```al
begin
    if not NavApp.GetCallerModuleInfo(CallerModuleInfo) then
        exit;
    if not NavApp.GetCurrentModuleInfo(CurrentModuleInfo) then
        exit;
    if CurrentModuleInfo.Id <> CallerModuleInfo.Id then
        Error(WrongModuleErr);

    if not InMemorySecretProvider.GetSecret(Name, KeyValue) then begin
        if Sentry.HasActiveTransaction() then
            Sentry.StartSpan(Span, StrSubstNo('keyvault: %1', Name));

        if SandboxSecretInjection.TryGetSecret(Name, KeyValue) then begin
            Span.Finish();
            exit;
        end;

        if not AppKeyVaultSecretProviderInitialised then
            AppKeyVaultSecretProviderInitialised := AppKeyVaultSecretProvider.TryInitializeFromCurrentApp();

        if not AppKeyVaultSecretProviderInitialised then begin
            Span.Finish();
            Error(GetLastErrorText());
        end;

        if AppKeyVaultSecretProvider.GetSecret(Name, KeyValue) then begin
            InMemorySecretProvider.AddSecret(Name, KeyValue);
            Span.Finish();
        end else begin
            Span.Finish();
            Error(GetSecretFailedErr, Name);
        end;
    end;
end;
```

Add two vars to the procedure:
```al
Sentry: Codeunit "NPR Sentry";
Span: Codeunit "NPR Sentry Span";
```

**Step 2: Commit**

```
feat: add Sentry span to Azure Key Vault secret retrieval
```

---

### Task 8: Compile and verify

**Step 1: Set app.json to BC27 and compile**

Use the bcdev skill to set Application/app.json platform/application to 27.0.0.0, runtime to 16.0, target to Cloud, add preprocessor symbols BC17-BC27. Download symbols. Compile with -suppressWarnings. Verify zero errors in our files.

**Step 2: Revert app.json**

```bash
git checkout Application/app.json
```

**Step 3: Commit any final adjustments**

---

### Task 9: Code review and push

**Step 1: Get codex review via /pal:clink**

Use gpt5.1-max with highest reasoning as a code review of all changes on this branch vs master.

**Step 2: Address any feedback, amend commit, and push**

```bash
git push --force-with-lease origin mmv/sentry-early-transaction
```
