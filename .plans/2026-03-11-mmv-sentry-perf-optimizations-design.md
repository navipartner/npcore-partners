# Sentry Performance Optimizations Design

## Context

Performance analysis of the Sentry telemetry integration identified several optimizations to reduce CPU overhead and payload size during span creation and serialization. Two changes were selected based on impact vs. complexity.

## Change 1: Minimize per-span tags

### Problem

`SentrySpan.ToJson()` calls `SentryMetadata.WriteTagsForBackendEvent()` for every span, cloning a cached JsonObject with ~15 tags. With N spans per transaction, this means N full clone operations and ~500+ chars of redundant tag data serialized per span.

### Solution

Replace the full tag set with a new `WriteSpanTags(): JsonObject` method on `SentryMetadata` that returns only the two tags needed for span-level alerting filtered by customer:
- `aadTenantId`
- `company`

The cached JsonObject still uses `.Clone().AsObject()` because Newtonsoft JToken detaches from its old parent when added to a new one — without clone, only the last span would retain its tags. But cloning a 2-field object is much cheaper than cloning a 15-field object.

### Files

- `SentryMetadata.Codeunit.al` — add `WriteSpanTags()` with `_spanTagsLoaded` / `_cachedSpanTags` cache
- `SentrySpan.Codeunit.al` — replace `WriteTagsForBackendEvent()` call with `WriteSpanTags()` in `ToJson()`

## Change 2: Span limit at 200

### Problem

No cap on span count. A loop with 200+ DB calls creates 200+ span objects with GUID generation, timestamp formatting, `RecRef.GetView(true)` calls, and a massive JSON payload that must be chunked across multiple BC telemetry dimensions.

### Solution

Add a `_tracingEnabled: Boolean` flag to `SentryScope` (SingleInstance). Set to `true` on `InitScopeAndTransaction`. When the 200th span is added, flip to `false` and tag the transaction with `span_limit_reached`.

The noop cascades through existing code paths:
- `SentrySpan.Create()` checks `_SentryScope.IsTracingEnabled()` — exits early, `_id` stays empty
- `SentrySpan.SetMetadata()` (both overloads) checks `_id = ''` — exits early, skipping `RecRef.GetView(true)`
- `SentrySpan.Finish()` already checks `_id = ''` — exits early
- `SentryScope.AddSpanToList()` checks `Span.GetId() = ''` — empty spans never enter the list

### Why not gate on sampling?

Errors override unsampled decisions (`FinalizeScope` sends even unsampled transactions when errors exist). Errors need the full span parent-child stack for correct attribution (`_activeSpanId` must track correctly). Therefore `_tracingEnabled` is independent of sampling — it only flips when the 200-span ceiling is hit.

### Files

- `SentryScope.Codeunit.al` — add `_tracingEnabled`, `AddSpanToList()` helper (replaces 15 `_spans.Add(Span)` calls), `IsTracingEnabled()` accessor
- `SentrySpan.Codeunit.al` — add early exit in `Create()` and both `SetMetadata()` overloads

## Explicitly not changing

- **Sampling noop (#4)** — errors need full span stack for attribution
- **SetActiveSpanStatus O(1) (#5)** — error-only path, capped at 200 iterations
- **JSON builder switch (#6)** — JsonObject is faster than TextBuilder in BC SaaS benchmarks
- **GlobalLanguage switching (#7)** — trivial overhead
