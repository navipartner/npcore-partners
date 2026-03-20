# Sentry PR Feedback Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:executing-plans to implement this plan task-by-task.

**Goal:** Fix 3 issues from PR #9696 review: custom tag key collision (runtime error risk), missing FinalizeSpan serialization, and unnecessary Clone() allocations in WriteSpanTags.

**Architecture:** All changes are in the Sentry telemetry module. Two fixes in SentryTransaction.Codeunit.al (tag merge and span serialization), one in SentryMetadata.Codeunit.al (remove defensive clone). No new files, no public API changes.

**Tech Stack:** AL (Business Central), JsonObject native types

---

### Task 1: Fix custom tag key collision in SentryTransaction.Log

**Files:**
- Modify: `Application/src/Sentry/SentryTransaction.Codeunit.al:178-179`

**Context:** `SentryTransaction.Log()` builds `TagsJson` from `SentryMetadata.WriteTagsForBackendEvent()` which includes keys like `aadTenantId`, `company`, `tenantId`, etc. Then `_customTags` are merged in using `TagsJson.Add()`. In AL, `JsonObject.Add()` throws a runtime error if the key already exists. If any caller does `AddTag('company', 'X')`, this will crash at runtime.

Note: `AddTag()` (line 94-100) already handles duplicates safely in the Dictionary via `ContainsKey`/`Set`. The bug is only in the merge into JsonObject at serialization time.

**Step 1: Edit the tag merge loop**

At lines 178-179, replace:
```al
        foreach TagKey in _customTags.Keys() do
            TagsJson.Add(TagKey, _customTags.Get(TagKey));
```
With:
```al
        foreach TagKey in _customTags.Keys() do
            if TagsJson.Contains(TagKey) then
                TagsJson.Replace(TagKey, _customTags.Get(TagKey))
            else
                TagsJson.Add(TagKey, _customTags.Get(TagKey));
```

**Step 2: Verify no compile errors**

Run: `/bcdev compile` (with -suppressWarnings)
Expected: Compilation succeeds

---

### Task 2: Add FinalizeSpan to SpansArray in SentryTransaction.Log

**Files:**
- Modify: `Application/src/Sentry/SentryTransaction.Codeunit.al:191-193`

**Context:** `FinalizeSpan` measures JSON assembly time. It's created by `SentryScope.FinalizeScope()`, passed to `Transaction.Log()`, and `Finish()` is called at line 189. But it's never added to `SpansArray` — the foreach only iterates the `Spans` list which doesn't contain it. The span is silently lost.

**Step 1: Add FinalizeSpan to the array after the loop (with guard)**

`FinalizeSpan.Create()` checks `IsTracingEnabled()` and exits early if tracing is disabled (span cap reached), leaving `_id` empty. We must guard against serializing an empty span.

At lines 191-193, replace:
```al
        foreach Span in Spans do
            SpansArray.Add(Span.ToJson(_traceId));
        EventJson.Add('spans', SpansArray);
```
With:
```al
        foreach Span in Spans do
            SpansArray.Add(Span.ToJson(_traceId));
        if FinalizeSpan.GetId() <> '' then
            SpansArray.Add(FinalizeSpan.ToJson(_traceId));
        EventJson.Add('spans', SpansArray);
```

**Step 2: Verify no compile errors**

Run: `/bcdev compile` (with -suppressWarnings)
Expected: Compilation succeeds

---

### Task 3: Remove unnecessary Clone() in WriteSpanTags

**Files:**
- Modify: `Application/src/Sentry/SentryMetadata.Codeunit.al:144-145,154-155`

**Context:** `WriteSpanTags()` returns `_cachedSpanTags.Clone().AsObject()` each call, creating a deep copy up to 200 times per transaction. The sole caller is `SentrySpan.ToJson()` at line 169:
```al
SpanJson.Add('tags', SentryMetadata.WriteSpanTags());
```
`JsonObject.Add()` copies by value in AL when adding to a parent object, so the caller never holds a mutable reference to the cached object. The clone is unnecessary overhead.

**Step 1: Remove Clone() from cached path (line 144-145)**

Replace:
```al
        if _spanTagsLoaded then
            exit(_cachedSpanTags.Clone().AsObject());
```
With:
```al
        if _spanTagsLoaded then
            exit(_cachedSpanTags);
```

**Step 2: Remove Clone() from first-load path (line 154-155)**

Replace:
```al
        _spanTagsLoaded := true;
        exit(_cachedSpanTags.Clone().AsObject());
```
With:
```al
        _spanTagsLoaded := true;
        exit(_cachedSpanTags);
```

**Step 3: Verify no compile errors**

Run: `/bcdev compile` (with -suppressWarnings)
Expected: Compilation succeeds

---

### Task 4: Commit

```bash
git add Application/src/Sentry/SentryTransaction.Codeunit.al Application/src/Sentry/SentryMetadata.Codeunit.al
git commit -m "fix: address PR review - tag collision, FinalizeSpan serialization, remove Clone()"
```
