# POS API Phase 4 — CI Fixes + PR Review Remediation

**Branch:** `mmv/isv2-640-pos-api-design-6`
**PR:** #9276
**Date:** 2026-03-03

## CI Pipeline Errors (Blocking Merge)

Both Insider_CLOUD and vPrevious_CLOUD fail at `[App] Compile` with CodeCop analyzer errors:

### Fix 1: AA0228 — Unused local method `GetJsonText`
**File:** `Application/src/POS Payment/EFT/Integrations/Adyen/APICloud/APIPOSEFTAdyenCloud.Codeunit.al:363`
**Action:** Delete the `GetJsonText` local procedure (lines 363-373). It's declared but never called.

### Fix 2: AA0139 — Text overflow assigning `Text` to `Text[50]`
**File:** `Application/src/Restaurant/Menu/NPRERestaurantWebhooks.Codeunit.al:12`
**Issue:** Compiler flags `Format(SystemId, 0, 4).ToLower()` (returns `Text`) being passed to `kitchenOrderId: Text[50]` as a possible overflow.
**Action:** Keep the `Text[50]` parameter type (changing it would alter the ExternalBusinessEvent schema contract). Instead, use `CopyStr` at the call site:
```al
OnOrderReadyForServing(Format(KitchenOrder."Order ID"), CopyStr(Format(SystemId, 0, 4).ToLower(), 1, 50));
```
This satisfies the compiler while preserving the event's parameter contract.

---

## PR Review Fixes (from claude[bot] review comments)

### Fix 3: NPREMenuItem OnInsert sort key
**File:** `Application/src/Restaurant/Menu/NPREMenuItem.Table.al:113-115`
**Issue:** When no records exist, `FindLast()` returns false, `MenuItem."Sort Key"` defaults to 0, so result is `0 + 10000 = 10000`. This happens to work but is fragile and unclear.
**Action:** Change to explicit if/else:
```al
if MenuItem.FindLast() then
    Rec."Sort Key" := MenuItem."Sort Key" + 10000
else
    Rec."Sort Key" := 10000;
```

### Fix 4: CreateKitchenOrder Error() → RespondBadRequest
**File:** `Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al:345+`
**Issue:** `CreateKitchenOrder` uses `Error()` for missing JSON fields (seatingCode etc.), which causes 500 Internal Server Error from an API endpoint instead of 400.
**Action:** Wrap the kitchen order creation in a `[TryFunction]` helper so that `Error()` calls inside `CreateKitchenOrder` trigger a rollback (preserving data integrity) while the caller catches the failure and returns `RespondBadRequest(GetLastErrorText())`. This avoids partial commits that could happen with a Boolean-return pattern.
```al
[TryFunction]
local procedure TryCreateKitchenOrder(Request: JsonObject)
begin
    CreateKitchenOrder(Request);
end;
// In CompleteSale:
if not TryCreateKitchenOrder(KitchenOrder.AsObject()) then
    exit(Response.RespondBadRequest(GetLastErrorText()));
```

### Fix 5: InsertAddonLineFromApi Error() → RespondBadRequest
**File:** `Application/src/_API_SERVICES/POS/Sale/APIPOSSaleLine.Codeunit.al:432-518`
**Issue:** Multiple `Error()` calls for validation failures (`missing addon id`, `missing addon number`, `Invalid addon quantity`).
**Action:** Same TryFunction pattern as Fix 4 — wrap the addon insertion in a `[TryFunction]` so Error() triggers rollback, and the caller catches with `RespondBadRequest(GetLastErrorText())`. This preserves rollback semantics (critical since parent sale line is already inserted before addons).

### Fix 6: JQCleanupDeadPOSSales Error() stops entire job queue
**File:** `Application/src/_API_SERVICES/POS/Sale/JQCleanupDeadPOSSales.Codeunit.al:37+`
**Issue:** After `Codeunit.Run` fails and Sentry logs the error, calling `Error()` stops the entire job queue loop. Remaining POS units and sales are never processed.
**Action:** Remove the `Error()` calls after `Sentry.AddLastErrorIfProgrammingBug()`. Sentry already captured the error. Do NOT use `Message()` (not allowed in background sessions). Use `Session.LogMessage` for telemetry if desired, then `ClearLastError()` and continue the loop:
```al
if not Codeunit.Run(Codeunit::"NPR JQ Cleanup Park Sale", POSSale) then begin
    Sentry.AddLastErrorIfProgrammingBug();
    ClearLastError();
end;
// Continue processing remaining sales
```

### Fix 7: VerifyCleanupJobIsScheduled — remove "This is a programming bug"
**File:** `Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al:511-519`
**Issue:** Missing Job Queue entry is a setup/configuration issue, not a code bug. "This is a programming bug" will spam Sentry with setup issues.
**Action:** Remove "This is a programming bug" from the error message. This is a configuration error that should surface to the user, not to developers.

### Fix 8: CompleteSale typo
**File:** `Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al:231`
**Action:** Change `'Sale failed to completed.'` → `'Sale failed to complete.'`

### Fix 9: Fixed Quantity error message passes Boolean
**File:** `Application/src/_API_SERVICES/POS/Sale/APIPOSSaleLine.Codeunit.al:505`
**Issue:** `Error('...fixed to %1', TempItemAddOnLine."Fixed Quantity")` passes the Boolean field. User sees "fixed to Yes" instead of the actual quantity.
**Action:** Change to `TempItemAddOnLine.Quantity`.

### Fix 10: ParseSaleLineFromJson — reject "POS Payment" line type
**File:** `Application/src/_API_SERVICES/POS/Sale/APIPOSSaleLine.Codeunit.al:332-336`
**Issue:** Clients can pass `type: "POS Payment"` to create payment lines through the sale line endpoint, bypassing the dedicated payment endpoint's validation.
**Action:** After resolving the enum, check:
```al
if POSSaleLine."Line Type" = POSSaleLine."Line Type"::"POS Payment" then
    exit(false);
```

### Fix 11: APIPOSEntry lastRowVersion — missing ContainsKey + Evaluate check
**File:** `Application/src/_API_SERVICES/POS/Entry/APIPOSEntry.Codeunit.al:44`
**Issue:** When `sync=true` but `lastRowVersion` is not provided, `Params.Get('lastRowVersion')` throws a runtime error. Also, if present but invalid, `Evaluate` will fail.
**Action:** Add both guards:
```al
if not Params.ContainsKey('lastRowVersion') then
    exit(Response.RespondBadRequest('Missing required parameter: lastRowVersion when sync=true'));
if not Evaluate(LastRowVersion, Params.Get('lastRowVersion')) then
    exit(Response.RespondBadRequest('Invalid lastRowVersion format'));
```

### Fix 12: APIPOSEntry pageKey Reset() clears filters
**File:** `Application/src/_API_SERVICES/POS/Entry/APIPOSEntry.Codeunit.al:58-64`
**Issue:** `POSEntry.Reset()` before `ApplyPageKey` clears all filters (posStore, posUnit, documentNo, entry type), so page 2+ returns unfiltered results.
**Action:** Remove the `Reset()` call. `ApplyPageKey` should work with existing filters.

### ~~Fix 13: CompleteSale — add CommitBehavior::Ignore~~ DROPPED
**File:** `Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al:199`
**Issue:** `CreateSale`, `UpdateSale`, `DeleteSale` all have `[CommitBehavior(CommitBehavior::Ignore)]` but `CompleteSale` doesn't.
**Reason for dropping:** Per codex review — `CompleteSale` calls `TryEndSale` → `EndSale` which has an explicit `Commit()` inside it (the sale is committed to a POS Entry). Adding `CommitBehavior::Ignore` would suppress that commit, potentially rolling back the completed sale if post-processing errors. The absence of this attribute is **intentional** for `CompleteSale`.

---

## Reviewed & Deferred (No Action Needed)

These PR comments were reviewed and are either already fixed, not applicable, or not worth the risk:

| Comment | Reason for deferring |
|---------|---------------------|
| NpIaItemAddOnCategory sort key bug | **Already fixed** in current code — uses `SetFilter('<>%1')` and if/else |
| NpIaItemAddOnLine DataClassification | **Already fixed** — both fields have `DataClassification = CustomerContent` |
| APIPOSSale/SaleLine/PaymentLine Evaluate | **Already fixed** — all use `if not Evaluate` with `RespondBadRequest` |
| MoveUp/MoveDown negative random sort key | Pre-existing BC pattern used elsewhere in codebase; changing it risks regressions for low-probability concurrency issue |
| EFTReceipt entry numbering race | Low risk: EFT receipts are created per-POS-unit per-sale; concurrent writes to same sale are not a real scenario |
| POSRefreshSaleLine GUID format | Standard BC pattern; all our GUID formatting is consistently lowercase |
| POSSaleLine code duplication | Pre-existing code we minimally modified; refactoring it is out of scope |
| SearchSale pagination/date filters | V1 design choice; endpoint filters by POS store/unit which limits result sets |
| GetItemPrice performance | Per vhn: menu is cached client-side and only re-retrieved when `lastUpdated` changes |
| BuildCategory redundant filters | Cosmetic only; `FindSet` rewind + same filters is a clarity choice |
| APIPOSEFTAdyenCloud Commit behavior | Complex existing EFT pattern with deliberate commit boundaries; changing risks breaking payment flows |
| PollEFTStatus payment line lookup | Needs deeper investigation of EFT Payment Mapping flow; defer to follow-up |
| POSSaleLine SystemId handling | Pre-existing code, minimal risk, out of scope |

---

## Implementation Order

1. **Fixes 1-2** (CI blockers) — unblock pipeline first
2. **Fixes 3, 7, 8, 9, 10** (simple one-line or few-line changes)
3. **Fix 11-12** (APIPOSEntry parameter validation and pagination fix)
4. **Fix 6** (JQCleanupDeadPOSSales loop continuation)
5. **Fixes 4-5** (TryFunction wrappers for Error() → RespondBadRequest — larger changes)
6. Compile, test, fern check, commit, push

## Codex Review Notes

Plan was reviewed by gpt-5.3-codex (codereviewer role). Key corrections incorporated:
- **Fix 2**: Keep `Text[50]` parameter, use `CopyStr` at call site instead (preserves ExternalBusinessEvent schema)
- **Fix 4/5**: Use `[TryFunction]` wrappers instead of Boolean return (preserves rollback semantics for partial DB changes)
- **Fix 6**: Don't use `Message()` in job queue (not allowed in background sessions); use `ClearLastError()` after Sentry logging
- **Fix 11**: Also handle invalid `lastRowVersion` format with `if not Evaluate`
- **Fix 13**: DROPPED — `CommitBehavior::Ignore` would suppress EndSale's required commit, changing end-sale semantics
