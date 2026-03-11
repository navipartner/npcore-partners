# POS API Phase 4 Re-Plan (User Feedback Applied)

Date: 2026-03-03
Branch context: uncommitted work only (no master diff review)

## Confirmed Decisions

1. Remove `qrCardPaymentMethod` from restaurant API responses because that data does not belong on restaurant.
2. Add `GET /pos/unit/:unitId` and `GET /pos/unit/me` endpoints.
3. For EFT endpoint identifier strategy: replace all token-based path usage with `EFTTransactionRequest.SystemId`.
4. For failed EFT outcomes in `/status`: return HTTP 200 with `successful = false` and error information.
5. No migration work is needed because changes are not live.

## Goals

- Realign payment-method ownership away from Restaurant and onto Self Service Profile.
- Finish EFT API design changes so lifecycle and identifiers are stable and indexed-friendly.
- Replace retail print handler registry approach with the simpler event-based default/override flow.
- Add missing test coverage for EFT end-to-end and print behavior.

## Work Plan

## 1) Move QR/Selfservice payment method ownership to Self Service Profile

### 1.1 Data model and pages
- Add fields to `table 6150658 "NPR SS Profile"`:
  - `QR Card Payment Method` (Code[10], relation to `NPR POS Payment Method`)
  - `Selfservice Card Payment Method` (Code[10], relation to `NPR POS Payment Method`)
- Expose both fields on `page 6150699 "NPR SS Profile Card"`.

### 1.2 Remove from Restaurant ownership
- Remove restaurant-level fields currently used for these concerns:
  - `QR Card Payment Method`
  - `Selfservice Card Payment Meth.`
- Remove page controls from `NPRERestaurantCard.Page.al`.

### 1.3 API exposure changes
- Remove `qrCardPaymentMethod` from restaurant payload in `APIRestaurant.Codeunit.al`.
- Remove `qrCardPaymentMethod` from Fern restaurant types.

## 2) POS Unit API additions (`/unit/:unitId` and `/unit/me`)

### 2.1 AL endpoint implementation
- Extend `APIPOSUnit.Codeunit.al` with:
  - `GetPOSUnit(Request)` for `GET /pos/unit/:unitId`
  - `GetCurrentPOSUnit(Request)` for `GET /pos/unit/me`
- Include the two profile-derived fields in response:
  - `qrCardPaymentMethod`
  - `selfserviceCardPaymentMethod`
- Resolution logic:
  - `/unit/:unitId`: lookup POS Unit by `SystemId`.
  - `/unit/me`: lookup `User Setup` by current `UserId()`, get `NPR POS Unit No.`, then load POS Unit.
  - For both: resolve `POS Self Service Profile` on POS Unit, then read fields from `NPR SS Profile`.

### 2.2 Route wiring
- Update `APIPOSHandler.Codeunit.al` with route order:
  - `GET /pos/unit/me`
  - `GET /pos/unit/:unitId`
  - existing `GET /pos/unit`

### 2.3 Fern updates
- Update `fern/apis/default/definition/pos/unit.yml`:
  - Extend `POSUnit` type with optional `qrCardPaymentMethod` and `selfserviceCardPaymentMethod`.
  - Add endpoint docs/examples for `getPOSUnit` and `getPOSUnitMe`.
- Update restaurant Fern types to remove `qrCardPaymentMethod`.

## 3) Print architecture simplification (replace registry with default+event override)

### 3.1 ObjectOutputMgt dispatch model
- Refactor `ObjectOutputMgt` so each print path:
  - Instantiates default implementation in an interface variable.
  - Calls new event publisher allowing manually bound subscriber to replace the interface implementation.
  - Dispatches through interface variable only.
- Remove `RetailPrintHandlerReg` dependency in `ObjectOutputMgt`.

### 3.2 API print capture flow
- Update API print flow to use manual subscription override pattern.
- Keep `APIRetailPrintHandler` as state holder for captured jobs.
- Remove/retire registry codeunit and enum scaffolding if no longer needed.

### 3.3 API response continuity
- Keep print response payload in current simplified structure (`printJobFormat`, `outputPath`, optional `httpEndpoint`, `printJob`).

## 4) EFT API redesign updates

### 4.1 Endpoint identifier replacement (replace all)
- Replace path parameter usage from `:transactionToken` to `:transactionId` across all EFT routes:
  - local build
  - local parse
  - cloud start
  - cloud status
  - cloud cancel
- Lookup EFT requests by `SystemId` everywhere (not by `Token`, not by `Reference Number Input`).

### 4.2 Prepare contract and lifecycle
- Update `/prepare` request to remove caller-provided external ID.
- `/prepare` response returns `transactionId` = `EFTTransactionRequest.SystemId`.
- After prepare helper creates record, explicitly clear:
  - `Started`
  - `Finished`
- Commit prepared record in that blank-timestamp state.

### 4.3 Start behavior
- In `/start`:
  - Validate sale + transaction relation.
  - Set `Started := CurrentDateTime`, commit, then send Adyen request.
  - Return minimal start response keyed by `transactionId` and completion flag.

### 4.4 Unattended enforcement
- In `/prepare`, enforce that resolved POS Unit has `POS Type = UNATTENDED`.

### 4.5 API key handling and debugging restrictions
- Replace direct field use `EFTAdyenPaymTypeSetup."API Key"` with `GetApiKey()`.
- Add `[NonDebuggable]` wrappers around procedures that read or process API key values.

### 4.6 Status response contract
- `/status` always returns HTTP 200.
- If in-progress/not finished: return state with `successful=false` and non-final status info.
- If finished and unsuccessful: return `successful=false` and error/result fields.
- If finished and successful: return payment delta payload matching `POST /pos/sale/:saleId/paymentline` style.

### 4.7 Delta builder reuse for status
- Add `BuildFullDataResponse()` to `APIPOSDeltaBuilder`.
- Internally use `POSRefreshPaymentLine.GetFullDataInCurrentSale()`.
- Filter resulting payment rows so only the EFT-created payment line remains in delta payload.

## 5) Fern changes for EFT

- Update `fern/apis/default/definition/pos/possale.yml`:
  - Rename all EFT path params from `transactionToken` to `transactionId`.
  - Update request/response types to new `/prepare` and `/status` contracts.
  - Remove `externalTransactionId` from prepare request/response.
  - Update examples accordingly.

## 6) Test coverage additions

### 6.1 EFT API tests
- Replace/expand `EFTAPITests.Codeunit.al` with full E2E happy path:
  - prepare -> start (with mocked Adyen call) -> poll status -> complete sale.
  - Assert sale is completed and moved to POS Entry.
  - Assert EFT transaction record is in finished state with valid links.
  - Assert `/status` returns delta showing only expected payment line and fully paid subtotal.

### 6.2 EFT logging test
- Add test for Adyen setup `Log Level = FULL`.
- Verify both request and response content are persisted in `NPR EFT Transaction Log` for the transaction.

### 6.3 POS unit endpoint tests
- Add API tests for:
  - `GET /pos/unit/:unitId`
  - `GET /pos/unit/me`
- Assert profile-derived `qrCardPaymentMethod` and `selfserviceCardPaymentMethod` fields.

### 6.4 Print tests
- Add API tests for print logic covering:
  - sales receipt path with static codeunit + object output selection mapping.
  - terminal receipt path with static EFT receipt setup.
  - multi-line report selection (3 active, 1 optional skipped) yielding exactly 3 print jobs.

## 7) Validation and final checks

- Run Fern validation (`fern check`) after schema edits.
- Run targeted AL test suite sections for:
  - API POS/EFT tests
  - print endpoint tests
  - kitchen/order and POS unit endpoint regressions
- Verify no stale references remain to removed restaurant QR/selfservice fields.

## Files Expected to Change

- `Application/src/Self Service/SSProfile.Table.al`
- `Application/src/Self Service/SSProfileCard.Page.al`
- `Application/src/Restaurant/NPRERestaurant.Table.al`
- `Application/src/Restaurant/NPRERestaurantCard.Page.al`
- `Application/src/_API_SERVICES/restaurant/APIRestaurant.Codeunit.al`
- `Application/src/_API_SERVICES/POS/Unit/APIPOSUnit.Codeunit.al`
- `Application/src/_API_SERVICES/POS/APIPOSHandler.Codeunit.al`
- `Application/src/Retail Print/_public/ObjectOutputMgt.Codeunit.al`
- `Application/src/_API_SERVICES/POS/Entry/APIPOSEntry.Codeunit.al`
- `Application/src/_API_SERVICES/POS/Entry/APIPOSEntryPrintMgt.Codeunit.al`
- `Application/src/POS Payment/EFT/Integrations/Adyen/APICloud/APIPOSEFTAdyenCloud.Codeunit.al`
- `Application/src/_API_SERVICES/POS/Sale/APIPOSDeltaBuilder.Codeunit.al`
- `Test/src/Tests/API/EFTAPITests.Codeunit.al`
- `Test/src/Tests/API/POSAPITests.Codeunit.al` (or dedicated POS unit/print API tests)
- `fern/apis/default/definition/restaurant/types-restaurant.yml`
- `fern/apis/default/definition/pos/unit.yml`
- `fern/apis/default/definition/pos/possale.yml`

## Out of Scope

- Data migration scripts/upgrades for moved payment method fields.
- Any master branch history cleanup.

