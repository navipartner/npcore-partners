# API & Sentry JSON Optimization + Performance Improvements

Stacked on `mmv/sentry-early-transaction`.

## Problem

Our JSON helper codeunits (`NPR Json Builder`, `NPR JSON Parser`) add overhead on every method call due to:
- `InitcurrCodeunit()` fires an internal event with bind/unbind subscription (fluent interface pattern)
- `AddPropertyInternal` does Variant boxing + runtime type checking
- Token stack management for nesting

Native `JsonObject.Add('key', value)` skips all of this. Additionally, `SentryMetadata.WriteTagsForBackendEvent` does 5 DB reads per call and is invoked once per span — a 4-span request wastes 20 DB roundtrips on redundant reads.

## Scope

### 1. Replace JSON helpers with native JsonObject

**API Module — Request parsing** (`APIRequestProcessor.Codeunit.al:61-78`):
Replace `NPR JSON Parser` fluent chain with direct `JsonObject.Get()` calls for the 6 request fields.

**API Module — Response building** (`APIResponse.Codeunit.al`):
- `CreateErrorResponse`: Build error JsonObject with `.Add()`
- `CreateSimpleJsonResponse`: Same
- `GetProxyResponseMetadata`: Nested `.Add()` calls
- `GetSentryTagsJsonObject`: Iterate `_SentryTags` dict directly
- `GetSentrySpanAttributesJsonObject`: Iterate `_SentrySpanAttribs` dict directly
- `AddSentrySpanAttribute`: Native `JsonValue` instead of `JsonBuilder.CreateJsonValue()`

**API Module — Record serialization** (`APIRequest.Codeunit.al`):
- `GetRecord`: Build JsonObject directly
- `GetRecords`: Build native JsonArray directly
- `AddFieldToJson`: Signature changes to `var JsonObj: JsonObject`

**Sentry module** — all signatures change to native `JsonObject`:
- `SentrySpan.ToJson(traceId: Text): JsonObject`
- `SentryError.ToJson(): JsonObject`
- `SentryMetadata.WriteTagsForBackendEvent(): JsonObject`
- `SentryMetadata.WriteModulesJson(): JsonObject`
- `SentryTransaction.Log`: Builds with native JsonObject, calls `WriteTo()` at the end

### 2. Remove SQL roundtrip tracking headers

Remove from `APIResponse.AddMetadataHeaders`:
- `x-npr-sql-rows-read-total`
- `x-npr-sql-statements-executed-total`
- `x-npr-sql-rows-read-api`
- `x-npr-sql-statements-executed-api`

Remove from `APIRequestProcessor.httpmethod`: the `SetStartRowsRead` / `SetStartStatementsExecuted` calls.

Clean up `APISessionMetadata.Codeunit.al`: remove `_StartRowsRead`, `_StartStatementsExecuted` and their getters/setters.

### 3. Cache SentryMetadata DB reads

`WriteTagsForBackendEvent` does 5 DB reads per call:
1. `UserSetup.Get(UserId)`
2. `POSUnit.Get(...)`
3. `InstalledApp.Get('992c2309...')` (retail version)
4. `InstalledApp.Get('437dbf0e...')` (base app version)
5. `ActiveSession.Get(ServiceInstanceId(), SessionId())`

Since `SentryMetadata` is `SingleInstance = true`, cache the built tags JsonObject on first call with a `_tagsLoaded` flag. Return a clone on subsequent calls.

`WriteModulesJson` is already cached — just change return type.

### 4. RecordRef.SetAutoCalcFields for BC26+

Use preprocessor symbols to call `RecordRef.SetAutoCalcFields()` before `Find`/`FindSet` on BC26+, and skip per-row `CalcField()` in `AddFieldToJson`.

### 5. SQL roundtrip budget test

New test in `Test/src/Tests/API/` that calls helloworld API after `SelectLatestVersion()` (cache skip) and errors if SQL statements exceed 1 — showing the actual count. Purpose: catch future regressions where someone adds DB reads to the hot path.
