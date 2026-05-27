# CORE-311 — Subpages for remaining digital assets on the Ecom Sales Document

**Issue**: [CORE-311] Create subpages for remaining digital assets on the ecom sales order page
**Author**: aolu (Andrei Lungu)
**Date**: 2026-05-22
**Status**: Design (pending implementation plan)

## Context

The parent page **6248188 `NPR Ecom Sales Document`** already hosts embedded subpages for **Vouchers** (page 6150924 `NPR Ecom Voucher Sub`) and **Memberships** (page 6248183 `NPR Ecom Membership Sub`). These subpages show all virtual items linked to the document and are populated asynchronously by a Page Background Task (orchestrator codeunit 6150899 `NPR Ecom Doc Subpages Task`).

CORE-311 extends this pattern to the remaining digital asset types: **Tickets**, **Coupons**, **Wallets**.

This task does NOT cover memberships (CORE-208 handled that, and is the predecessor branch this work stacks on).

## Goals

1. Add three new subpages: `NPR Ecom Ticket Sub`, `NPR Ecom Coupon Sub`, `NPR Ecom Wallet Sub`, mounted on page 6248188.
2. Populate them through the existing single-task Page Background Task — no additional background tasks.
3. Show the **same data** that the existing top-level actions ("Retail Tickets", "Retail Coupons", "Attraction Wallets") and the line-level `OnAssistEdit` triggers display today, by extracting the existing iterator logic into reusable `BuildXTempBufferForDoc` / `BuildXTempBufferForLine` procedures and reusing them in both the action and the orchestrator.
4. Add an Open action per subpage row that opens the asset's primary card page (mirroring the Voucher/Membership pattern).
5. Refactor line-level `ShowRelatedXAction(EcomSalesLine)` to use the 0/1/else count-switch pattern (Voucher/Membership precedent: `EcomCreateVchrImpl.Codeunit.al:426-446`, `EcomCreateMMShipImpl.Codeunit.al`).
6. Bring Wallet to the same typed-overload shape as the other assets (eliminate the asymmetric `ShowRelatedWallets(TableId, SystemId)`).

## Non-goals

- No new link tables for Ticket or Wallet. The link-table approach is reserved for assets where it already exists (Voucher, Membership, Coupon). Ticket and Wallet keep their existing iterator approaches (reservation token, attraction wallet reference table).
- No removal of the top-level actions ("Retail Vouchers", etc.) — they remain valid entry points (line-scoped use cases still rely on `OnAssistEdit`).
- No display of Wallet **balance / remaining value**. The `NPR AttractionWallet` table does not have a balance field — it would be computed from `WalletAssetLine`. Out of scope for this iteration; can be added later as a follow-up via a `Dictionary` sibling on the subpage (similar pattern to membership display name).
- No changes to background-task signature or orchestrator dispatch shape. Still one task, one `HeaderSystemId` parameter.

## Architecture

```
Parent page 6248188 (NPR Ecom Sales Document)
  ├── part(VouchersSubPage; NPR Ecom Voucher Sub)        [existing]
  ├── part(MembershipsSubPage; NPR Ecom Membership Sub)  [existing]
  ├── part(TicketsSubPage; NPR Ecom Ticket Sub)          [NEW]
  ├── part(CouponsSubPage; NPR Ecom Coupon Sub)          [NEW]
  └── part(WalletsSubPage; NPR Ecom Wallet Sub)          [NEW]

OnAfterGetCurrRecord → EnqueueSubpagesRefresh
  ↓ ClearContents on each subpage, enqueue codeunit 6150899 with HeaderSystemId
  ↓
EcomDocSubpagesTask.OnRun (read-only child session)
  ↓ BuildVouchersPayload   → Result['Vouchers']
  ↓ BuildMembershipsPayload → Result['Memberships']
  ↓ BuildTicketsPayload    → Result['Tickets']      [NEW]
  ↓ BuildCouponsPayload    → Result['Coupons']     [NEW]
  ↓ BuildWalletsPayload    → Result['Wallets']     [NEW]
  ↓
OnPageBackgroundTaskCompleted → dispatch by result key
  ↓ CurrPage.{X}SubPage.PAGE.PopulateFromJsonText(...)
```

The orchestrator runs entirely **read-only** in a child session. `BuildXPayload` methods MUST NOT call `ShowRelatedXAction` (which opens pages) or modify any real records. They call only the pure `BuildXTempBufferForDoc` extracted in this work.

## Per-asset implementation

### Ticket — `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Ticket/EcomCreateTicketImpl.Codeunit.al`

**New procedures:**
- `internal procedure BuildTicketTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempTicket: Record "NPR TM Ticket" temporary)` — extract body of `ShowRelatedTicketsAction(EcomSalesHeader)` (lines 314-325 + the join loop at 344-356). Filter `NPR TM Ticket Reservation Req.` by `"Session Token ID" = EcomSalesHeader."Ticket Reservation Token"`, iterate joined `NPR TM Ticket` by `"Ticket Reservation Entry No."`, copy into `TempTicket` with explicit SystemId preservation via `Insert(false, true)`. Skip (do not Error) any missing linked records.
- `internal procedure BuildTicketTempBufferForLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var TempTicket: Record "NPR TM Ticket" temporary)` — extract line-level iterator from `ShowRelatedTicketsAction(EcomSalesLine)` (lines 327-337). Use `GetBySystemId(EcomSalesLine."Ticket Reservation Line Id")` + `SetRecFilter`, same join + insert pattern.
- `internal procedure OpenTicketCardForSystemId(SystemIdParam: Guid)` — `NPR TM Ticket.GetBySystemId(SystemIdParam)`, `Page.Run(Page::"NPR TM Ticket Card", Ticket)`. If lookup fails, exit silently (no Error).

**Refactor:**
- `ShowRelatedTicketsAction(EcomSalesHeader)` body becomes: `BuildTicketTempBufferForDoc(...) → Page.RunModal(Page::"NPR TM Ticket List", TempTicket)`.
- `ShowRelatedTicketsAction(EcomSalesLine)` body becomes:
  ```al
  BuildTicketTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempTicket);
  case TempTicket.Count() of
      0:  Message(NoTicketFoundMsg);
      1:  begin TempTicket.FindFirst(); OpenTicketCardForSystemId(TempTicket.SystemId); end;
      else Page.RunModal(Page::"NPR TM Ticket List", TempTicket);
  end;
  ```

**Subpage fields** (`NPR Ecom Ticket Sub`):
- `"No."` (internal ticket number — support reference)
- `"External Ticket No."` (customer-facing)
- `"Ticket Type Code"`
- `"Item No."` (what was sold)
- `"Valid From Date"` + `"Valid From Time"`
- `"Valid To Date"` + `"Valid To Time"`

**JSON keys for `BuildTicketsPayload`**: `'No'`, `'Ext'`, `'Type'`, `'Item'`, `'VFromD'`, `'VFromT'`, `'VToD'`, `'VToT'`, `'Sid'` (SystemId, mandatory for Open action).

### Coupon — `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponImpl.Codeunit.al`

**New procedures:**
- `internal procedure BuildCouponTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempCoupon: Record "NPR NpDc Coupon" temporary)` — extract from `ShowRelatedCouponsAction(EcomSalesHeader)` (lines 87-94 + load loop at 108-117). Filter `NPR Ecom Sales Coupon Link` by `Source = "Ecom Sales Document"` + `"Source System Id" = EcomSalesHeader.SystemId`, load `NPR NpDc Coupon` via `"Coupon System Id"`.
- `internal procedure BuildCouponTempBufferForLine(EcomSalesHeader, EcomSalesLine; var TempCoupon)` — same pattern with `"Source Line System Id" = EcomSalesLine.SystemId`.
- `internal procedure OpenCouponCardForSystemId(SystemIdParam: Guid)` — opens `Page::"NPR NpDc Coupon Card"` (page 6151592).

**Refactor:**
- `ShowRelatedCouponsAction(EcomSalesHeader)` body: `BuildCouponTempBufferForDoc(...) → Page.RunModal(0, TempCoupon)` (default coupon list).
- `ShowRelatedCouponsAction(EcomSalesLine)`: count-switch as above.

**Subpage fields** (`NPR Ecom Coupon Sub`):
- `"No."`
- `"Reference No."`
- `"Coupon Type"`
- `Description`
- `"Starting Date"`
- `"Ending Date"`

**JSON keys**: `'No'`, `'Ref'`, `'Type'`, `'Desc'`, `'Start'`, `'End'`, `'Sid'`.

### Wallet — `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al`

Today's `ShowRelatedWallets(TableId: Integer; SystemId: Guid)` is the only asymmetric API in the family — every other asset (`Voucher`, `Membership`, `Ticket`, `Coupon`) uses `ShowRelatedXAction(Rec)` typed overloads. Both the procedure and the enclosing codeunit are `Access = Internal`; all 3 callers are inside this app (`EcomSalesDocument.Page.al:478`, `EcomSalesDocSub.Page.al:180`, `EcomSalesLines.Page.al:168`). Renaming is safe (no breaking change) and brings Wallet to full parity.

**New procedures:**
- `internal procedure BuildWalletTempBufferFor(LinkToTableId: Integer; LinkToSystemIdParam: Guid; var TempWallet: Record "NPR AttractionWallet" temporary)` — pure iterator, extracted from current `ShowRelatedWallets(TableId, SystemId)` (lines 208-231: filter `NPR WalletAssetHeaderReference` by `LinkToTableId` + `LinkToSystemId`, walk `WalletAssetHeader → WalletAssetLine (Type::WALLET) → NPR AttractionWallet`, insert into `TempWallet` with `Insert(false, true)`). **No UI.** This is what the orchestrator calls.
- `internal procedure BuildWalletTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempWallet: Record "NPR AttractionWallet" temporary)` — thin wrapper: `BuildWalletTempBufferFor(Database::"NPR Ecom Sales Header", EcomSalesHeader.SystemId, TempWallet)`.
- `internal procedure BuildWalletTempBufferForLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var TempWallet: Record "NPR AttractionWallet" temporary)` — thin wrapper: `BuildWalletTempBufferFor(Database::"NPR Ecom Sales Line", EcomSalesLine.SystemId, TempWallet)`.
- `internal procedure OpenWalletCardForSystemId(SystemIdParam: Guid)` — opens `Page::"NPR AttractionWalletCard"` (page 6185090).
- `internal procedure ShowRelatedWalletsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")` — `BuildWalletTempBufferForDoc(...) → Page.RunModal(Page::"NPR AttractionWallets", TempWallet)`.
- `internal procedure ShowRelatedWalletsAction(EcomSalesLine: Record "NPR Ecom Sales Line")` — count-switch using `BuildWalletTempBufferForLine` (0 → Message, 1 → `OpenWalletCardForSystemId`, else → `Page.RunModal(Page::"NPR AttractionWallets", TempWallet)`).

**Remove:**
- `internal procedure ShowRelatedWallets(TableId: Integer; SystemId: Guid)` — replaced by the two `ShowRelatedWalletsAction` typed overloads.

**Call-site migrations:**
- `EcomSalesDocument.Page.al:478` → `EcomCreateWalletMgt.ShowRelatedWalletsAction(Rec)` (compiler picks header overload by `Rec` type).
- `EcomSalesDocSub.Page.al:180` → `EcomCreateWalletMgt.ShowRelatedWalletsAction(Rec)` (line overload).
- `EcomSalesLines.Page.al:168` → `EcomCreateWalletMgt.ShowRelatedWalletsAction(Rec)` (line overload). The page is unused but must compile after removing the untyped API.

**Subpage fields** (`NPR Ecom Wallet Sub`):
- `ReferenceNumber`
- `Description`
- `OriginatesFromItemNo`
- `ExpirationDate`

**JSON keys**: `'Ref'`, `'Desc'`, `'Item'`, `'Exp'`, `'Sid'`.

(Balance/value display deferred — see Non-goals.)

## Orchestrator changes — `EcomDocSubpagesTask.Codeunit.al`

Add three new payload builders, three new result-key tokens, and three new calls in `OnRun`. Each `BuildXPayload` follows the existing `BuildVouchersPayload` shape (lines 29-52):

1. Resolve `EcomSalesHeader` from `HeaderSystemId`.
2. Call `EcomCreateXImpl.BuildXTempBufferForDoc(EcomSalesHeader, TempX)`.
3. Iterate `TempX`, serialize each row to a `JsonObject` with the short keys listed above.
4. Add the resulting `JsonArray` to the `Result` dictionary under `XResultKeyTok()`.

**Important**: Even when the temp buffer is empty, the builder MUST still add an empty array under its result key, so the parent's `AllSubpagesLoaded` promotion logic processes all 5 keys consistently.

New token methods (each returns the string used as both the result-dict key and the JSON property name):
- `local procedure TicketsResultKeyTok(): Text begin exit('Tickets'); end;`
- `local procedure CouponsResultKeyTok(): Text begin exit('Coupons'); end;`
- `local procedure WalletsResultKeyTok(): Text begin exit('Wallets'); end;`

## Parent page wiring — `EcomSalesDocument.Page.al`

1. Three new `part(...)` declarations after the existing `MembershipsSubPage` (lines 310-315). Order on screen: Vouchers, Memberships, Tickets, Coupons, Wallets.
2. `OnPageBackgroundTaskCompleted` (lines 554-572): three new dispatch branches calling `PopulateTicketsSubpage(Results)`, `PopulateCouponsSubpage(Results)`, `PopulateWalletsSubpage(Results)`. Each helper extracts the JSON text under the result key and calls `CurrPage.{X}SubPage.PAGE.PopulateFromJsonText(...)`.
3. `EnqueueSubpagesRefresh` (lines 619-648): three new `CurrPage.{X}SubPage.PAGE.ClearContents()` calls before the enqueue.
4. `AllSubpagesLoaded` (existing): extend the predicate to require all 5 result keys present.

## Subpage page structure

Each new subpage uses the exact shape of `EcomVoucherSub.Page.al`:
- `PageType = ListPart`
- `SourceTable = "<Asset>"`
- `SourceTableTemporary = true`
- `Editable = false`, `InsertAllowed = false`, `DeleteAllowed = false`, `ModifyAllowed = false`
- `ApplicationArea = NPRRetail`
- Guarded with `#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)` (matching Voucher/Membership precedent)
- `area(Content) > repeater(Group)` with the field list above
- `area(Processing) > action(Open<X>)` calling `OpenXCardForSystemId(Rec.SystemId)`
- `internal procedure ClearContents()` — `Rec.Reset(); Rec.DeleteAll(); CurrPage.Update(false);`
- `internal procedure PopulateFromJsonText(JsonText: Text)` — clear, parse `JsonArray`, call `PopulateBufferFromJson`
- `local procedure PopulateBufferFromJson(<X>Json: JsonArray)` — iterate, `Rec.Init()`, set fields from JSON tokens with `CopyStr` to respect `MaxStrLen`, evaluate SystemId guid, `Rec.Insert(false, true)` to preserve SystemId.

## Card pages confirmed (Open action targets)

| Asset | Card page | ID |
|-------|-----------|----|
| Ticket | `NPR TM Ticket Card` | 6151294 |
| Coupon | `NPR NpDc Coupon Card` | 6151592 |
| Wallet | `NPR AttractionWalletCard` | 6185090 |

Each `OpenXCardForSystemId` calls `GetBySystemId` on the asset table and runs the card page. If `GetBySystemId` fails, the procedure exits silently (defensive).

## Refactoring impact summary

| File | Change |
|------|--------|
| `Ticket/EcomCreateTicketImpl.Codeunit.al` | Add 3 procedures (`BuildTicketTempBufferForDoc`, `BuildTicketTempBufferForLine`, `OpenTicketCardForSystemId`); refactor `ShowRelatedTicketsAction(EcomSalesHeader)` and `(EcomSalesLine)` to call the new Build helpers; line-level adopts count-switch |
| `Coupon/EcomCreateCouponImpl.Codeunit.al` | Add 3 procedures (`BuildCouponTempBufferForDoc`, `BuildCouponTempBufferForLine`, `OpenCouponCardForSystemId`); refactor `ShowRelatedCouponsAction(EcomSalesHeader)` and `(EcomSalesLine)`; line-level adopts count-switch |
| `Wallet/EcomCreateWalletMgt.Codeunit.al` | Add 6 procedures (`BuildWalletTempBufferFor`, `BuildWalletTempBufferForDoc`, `BuildWalletTempBufferForLine`, `OpenWalletCardForSystemId`, `ShowRelatedWalletsAction(EcomSalesHeader)`, `ShowRelatedWalletsAction(EcomSalesLine)`); remove `ShowRelatedWallets(TableId, SystemId)` — safe rename since both procedure and codeunit are `internal` and all 3 callers live inside this app |
| `EcomDocSubpagesTask.Codeunit.al` | Add 3 `BuildXPayload` + 3 tokens + 3 calls in `OnRun`; ensure empty-array safety under each result key |
| `EcomSalesDocument.Page.al` | Add 3 `part(...)`, 3 routing branches in `OnPageBackgroundTaskCompleted`, 3 `ClearContents` calls in `EnqueueSubpagesRefresh`; extend `AllSubpagesLoaded` predicate to require all 5 result keys; migrate wallet call at line 478 to `ShowRelatedWalletsAction(Rec)` |
| `EcomSalesDocSub.Page.al` | Migrate wallet call at line 180 to `ShowRelatedWalletsAction(Rec)`. Ticket/Coupon `OnAssistEdit` calls (lines 143, 147) are unchanged — they automatically pick up the count-switch via the refactored impl bodies |
| `EcomSalesLines.Page.al` | Migrate wallet call at line 168 to `ShowRelatedWalletsAction(Rec)`. Page is unused but must compile after removing the untyped API |
| `Ticket/EcomTicketSub.Page.al` | New |
| `Coupon/EcomCouponSub.Page.al` | New |
| `Wallet/EcomWalletSub.Page.al` | New |

## Constraints

- All new pages guarded by `#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)` directive, matching existing V/M subpage pattern.
- New page IDs allocated via AL ID Manager (`https://al-id-manager.npretail.io`) at implementation time, using the App ID `992c2309-cca4-43cb-9e41-911f482ec088` and the page ID ranges declared in `Application/app.json`.
- AL coding standards per `Application/CLAUDE.md`:
  - Globals prefixed with `_`, locals not
  - User-facing errors via `Label` declarations with dynamic captions (`TableCaption`, `FieldCaption`)
  - All API-style identifiers `camelCase` (not applicable here — these are internal pages)
  - All new objects `Access = Internal` where possible; only the page object public for the part to host it.
- Background task purity:
  - `BuildXPayload` procedures must run in a read-only child session.
  - No `Page.Run` / `Message` / record modification from inside the orchestrator.
  - Defensive `Get` calls: skip records that don't resolve, never `Error`.

## Testing strategy

Manual:
1. Open an ecom sales document with mixed virtual items (vouchers + memberships + tickets + coupons + wallets).
2. Confirm all 5 subpages clear and reload as the user navigates between documents.
3. Click Open on a row in each new subpage — verify the correct card opens.
4. Verify the line-level OnAssistEdit count-switch behavior:
   - Line with 0 matching items → message.
   - Line with 1 matching item → card opens directly.
   - Line with 2+ matching items → list opens.
5. Stress-test a high-volume ticket order (e.g., 50+ tickets in one document) — confirm the background task completes in reasonable time and the subpage renders without truncation.

Automated (if test code is added):
- Pattern lives in `Test/src/Tests/ECommerce/FastLane/EcomMembershipMultiQtyTests.Codeunit.al` — follow it if test scope is requested.

## Migration / upgrade

No data migration. No upgrade codeunits. No schema changes. The subpages are pure read-side projections.

## Open questions

None at this time. Card pages confirmed, field selection approved, refactoring scope approved, codex review completed (verdict: proceed-with-changes; all flagged items addressed in this spec).
