# CORE-164 follow-up: Digital notifications for Ecom coupons & attraction wallets — Design

Date: 2026-04-17
Owner: Andrei Lungu (aolu@navipartner.com)
Branch base: `andrei/core-164-digital-notifications-from-ecom-sales-documents-for-virtual`
Related commit (upstream, already merged): `09f66438` — Ecom docs: coupon and bundle (attraction wallet) processing (#9753)

## Problem

CORE-164 added Ecom-sourced digital-order notifications covering vouchers and tickets only. PR #9753 subsequently added coupon and attraction-wallet (bundle) processing to the incoming Ecom Sales Document pipeline. We need to extend the digital-notification flow to cover these two new virtual-item types so customers receive their coupons and wallets in the same notification email they already receive for vouchers/tickets.

## Goals

1. Ecom order with standalone coupon(s) → manifest contains coupon assets, email sent.
2. Ecom order with an attraction wallet (wallet parent + ticket/coupon children) → manifest contains the wallet asset(s) only; child lines are not emitted as separate assets (the wallet is the envelope; its contents render inside it).
3. Mixed orders (voucher + ticket + standalone coupon + wallet-with-children) → manifest contains voucher + standalone ticket + standalone coupon + wallet; bundled children are NOT separate.
4. New setup flag `Exclude Tickets From Manifest` lets customers with legacy welcome-ticket emails opt tickets out of the manifest (standalone tickets only; tickets inside a wallet still render inside the wallet asset).
5. Magento/Shopify paths untouched — they continue to emit only voucher + ticket assets. Coupon and Wallet asset emission is enabled **only** for `Document Type = "Ecom Sales Document"`.
6. Memberships: explicit skip (no trigger, no asset) — they have a separate notification flow.

## Non-goals

- Changing the API payload shape. The existing `externalLineId`/`parentExternalLineId` + item-level setup are all the data we need. No Fern updates.
- Magento/Shopify notification behavior.
- Membership asset rendering (follow-up ticket).

## Key domain facts (verified in code)

- `NPR Ecom Sales Line`
  - `Subtype` enum includes `Voucher`, `Ticket`, `Membership`, `Coupon`, `Item`, ` `.
  - `Is Attraction Wallet` (boolean) — true only on the wallet parent line (item with `Create Attraction Wallet = true` + `NPR Item AddOn No.`).
  - `External Line ID` / `Parent Ext. Line ID` — bundle parent/child relationship; non-nested (wallets cannot contain wallets).
  - `IsVirtualItem()` = true for Voucher/Ticket/Membership/Coupon.
- `NPR Ecom Sales Header`
  - `Coupons Exist` / `Attraction Wallets Exist` boolean flags.
  - `Coupon Processing Status` / `Attr. Wallet Processing Status` enums (Pending / Partially Processed / Processed / Error).
  - `Virtual Items Process Status` — set to `Processed` only when ALL virtual-item groups (voucher/ticket/membership/coupon/wallet) are Processed. Already updated by `EcomVirtualItemMgt.CalculateVirtualItemsDocStatus` to consider coupons + wallets.
- Coupon issuance
  - `EcomCreateCouponImpl.IssueCoupons` loops `for i := 1 to QtyTotalInt` × coupon types configured → one `NPR Ecom Sales Coupon Link` row per issued coupon with `(Source="Ecom Sales Document", Source System Id = EcomSalesHeader.SystemId, Source Line System Id = EcomSalesLine.SystemId, Coupon System Id = Coupon.SystemId)`.
  - `EcomCreateCouponProcess.SetSalesDocCouponStatusCreated` sets the line’s `Virtual Item Process Status = Processed`, updates header status, and currently does NOT invoke the digital-notification trigger.
- Wallet issuance
  - `EcomCreateWalletMgt.CreateWalletsForBundle` creates `Round(Quantity, 1, '>')` wallets per parent line, assigning each wallet a reference via `AttractionWalletFacade.SetWalletReferenceNumber(WalletEntryNo, Database::"NPR Ecom Sales Line", ParentLine.SystemId, …)` — deterministic link from ecom line SystemId to wallet(s).
  - `EcomCreateWalletMgt.HandleResponse` (success branch) sets parent-line status Processed, updates header status. Currently does NOT invoke the digital-notification trigger.
- Nested wallets are unsupported (`ComponentLine.SetRange("Is Attraction Wallet", false)` in both traversal helpers). Every non-wallet bundle parent today is a wallet, but we will not assume this — the ancestor check stays explicit.

## Design

### 1. Trigger points

Add `DigitalOrderNotifMgt.TryCreateEcomDigitalNotification(EcomSalesHeader)` calls on the success paths of:

- `EcomCreateCouponProcess.SetSalesDocCouponStatusCreated` — after `EcomSalesHeader.Modify(true)`.
- `EcomCreateWalletMgt.HandleResponse` (Success = true branch) — after `EcomSalesHeader2.Modify(true)`.
- `EcomCreateMMShipProcess` success path — defensive one-liner. We do NOT render any membership asset, but the gate (`Virtual Items Process Status = Processed`) already waits for memberships. Without this call, a doc containing membership + any other subtype could never fire a notification if memberships finish last. The call adds no membership asset; it only guarantees the gate unlatches on the last subtype.

Voucher and Ticket success paths already call it — unchanged.

The existing guard inside `TryCreateEcomDigitalNotification` (only proceed when `Virtual Items Process Status = Processed`) makes the call correct from every path: all but the last-one-done exit early.

### 2. Idempotency under concurrency

Two workers can both pass the current check-then-insert of `EcomDigitalNotifEntryExists`. We must prevent duplicate entries **without** raising errors (because `TryCreateEcomDigitalNotification` runs inline inside the virtual-item success paths, and an error there would poison the caller — e.g. propagate back into `SetSalesDocVoucherStatusCreated`, flipping a successful voucher/ticket/coupon/wallet commit into a failure).

Chosen approach: **UpdLock pattern on the EcomSalesHeader**. Inside `TryCreateEcomDigitalNotification`:

1. `EcomSalesHeader.ReadIsolation := UpdLock; EcomSalesHeader.Get(EcomSalesHeader."Entry No.");` — serializes concurrent last-one-done callers for the same doc.
2. Re-check `EcomDigitalNotifEntryExists(EcomSalesHeader.SystemId)` — under the lock.
3. If absent, populate buffers + insert entry.

No schema change. No thrown errors. Losers of the race simply see the entry already exists and exit cleanly.

Rationale for rejecting a Unique key: an insert failure would surface an error into the caller’s transaction and turn a benign race into a real failure.

### 3. Line filtering in `PopulateBuffersFromEcomDoc`

Replace the existing `SetFilter(Subtype, '%1|%2', Voucher, Ticket)` with a two-pass scan:

**Pass 1 — index by External Line ID (in-memory):**
- Iterate all lines of the document once.
- Build a dictionary `Dictionary of [Text[100], Boolean]` → `ExternalLineId → IsAttractionWallet`.

**Pass 2 — emit buffer rows:**
- For each line:
  - Skip unless line is an asset candidate: `Is Attraction Wallet = true` OR `Subtype in [Voucher, Ticket, Coupon]`.
  - Bundle-child skip: if `Parent Ext. Line ID <> ''` and the parent (looked up in the dictionary) has `IsAttractionWallet = true` → skip. This correctly keeps non-wallet bundles (should they ever exist) unaffected, and handles the current single-level wallet-bundle shape cheaply.
  - If `Is Attraction Wallet = true`: insert line buffer row with `Is Wallet = true` (new buffer field) — becomes a Wallet asset.
  - Else: insert line buffer row mirroring `Ecom Line Subtype` (existing behavior extended for Coupon) — becomes Voucher/Ticket/Coupon asset.
- Carry `EcomSalesLine.SystemId` in the buffer (new field `Source Line System Id` on `NPR Digital Doc. Line Buffer`). Used for coupon + wallet deterministic lookups.

Memberships: skipped at this filter (no asset emission).

No dependency on `EcomCreateWalletMgt` — Digital Notification remains self-contained.

### 4. Asset resolution — coupons (`ProcessCouponAssets` — Ecom only)

Coupon emission is Ecom-exclusive. The existing Magento-style body (`NpDc Iss.OnSale Setup Line` + `NpDc Coupon Entry` lookup by posted document no.) is fully replaced with the Ecom lookup using `NPR Ecom Sales Coupon Link`. No Magento branch retained.

```
local procedure ProcessCouponAssets(...)
var
    EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
    Coupon: Record "NPR NpDc Coupon";
    CouponType: Record "NPR NpDc Coupon Type";
    NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
begin
    if IsNullGuid(TempHeaderBuffer."Ecom Sales Header Id") then
        exit;

    EcomSalesCouponLink.SetRange(Source, EcomSalesCouponLink.Source::"Ecom Sales Document");
    EcomSalesCouponLink.SetRange("Source System Id", TempHeaderBuffer."Ecom Sales Header Id");
    EcomSalesCouponLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
    if not EcomSalesCouponLink.FindSet() then
        exit;

    repeat
        if Coupon.GetBySystemId(EcomSalesCouponLink."Coupon System Id") then
            if CouponType.Get(Coupon."Coupon Type") and (CouponType.NPDesignerTemplateId <> '') then begin
                NPDesignerManifestFacade.AddAssetToManifest(
                    ManifestId,
                    Database::"NPR NpDc Coupon",
                    Coupon.SystemId,
                    Coupon."Reference No.",
                    CouponType.NPDesignerTemplateId);
                AssetsAdded += 1;
            end;
    until EcomSalesCouponLink.Next() = 0;
end;
```

Because `EcomCreateCouponImpl.IssueCoupons` issues `Quantity` × `#CouponTypes` coupons per line, we emit one manifest asset per `Ecom Sales Coupon Link` row. The link table is the authoritative source of truth. Wallet-bundled coupons are filtered out upstream in buffer population, so this processor only sees standalone coupons.

### 5. Asset resolution — wallets (`ProcessWalletAssets` — Ecom only)

Wallet emission is Ecom-exclusive. The existing Magento-style body (lookup via `LinkToReference = External Order No.`, item-no match on last wallet) is fully replaced with the deterministic Ecom lookup keyed off the parent line SystemId. No Magento branch retained.

```
local procedure ProcessWalletAssets(...)
var
    WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    WalletAssetHeader: Record "NPR WalletAssetHeader";
    WalletAssetLine: Record "NPR WalletAssetLine";
    Wallet: Record "NPR AttractionWallet";
begin
    if IsNullGuid(TempHeaderBuffer."Ecom Sales Header Id") then
        exit;

    WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
    WalletAssetHeaderRef.SetRange(LinkToTableId, Database::"NPR Ecom Sales Line");
    WalletAssetHeaderRef.SetRange(LinkToSystemId, TempLineBuffer."Source Line System Id");
    if not WalletAssetHeaderRef.FindSet() then
        exit;

    repeat
        if WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo) then begin
            WalletAssetLine.SetCurrentKey(TransactionId);
            WalletAssetLine.SetRange(TransactionId, WalletAssetHeader.TransactionId);
            WalletAssetLine.SetRange(Type, WalletAssetLine.Type::WALLET);
            if WalletAssetLine.FindSet() then
                repeat
                    if Wallet.GetBySystemId(WalletAssetLine.LineTypeSystemId) then
                        TryAddWalletAssetToManifest(Wallet, ManifestId, AssetsAdded);
                until WalletAssetLine.Next() = 0;
        end;
    until WalletAssetHeaderRef.Next() = 0;
end;
```

`TryAddWalletAssetToManifest` is simplified to take the resolved `Wallet` record directly (no more item-no match on `TempLineBuffer."No."` — the Ecom lookup is deterministic). Template resolution: `Item.Get(Wallet.OriginatesFromItemNo)` → `NpIa Item AddOn.Get(Item."NPR Item AddOn No.")` → `ItemAddOn.NPDesignerTemplateId`.

One manifest asset per wallet. A parent line with `Quantity = 2` produces 2 wallets → 2 manifest assets.

### 6. Setup: `Exclude Tickets From Manifest`

- Add field `"Exclude Tickets From Manifest"` (Boolean, DataClassification `CustomerContent`) to `NPR Digital Notification Setup`. Next field id via AL ID Manager.
- Setup page: show below the existing `"Exclude Vouchers From Manifest"` with tooltip explaining the legacy welcome-ticket email use case.
- Enforcement at process-time inside `ProcessTicketAssets`: `if DigitalNotifSetup."Exclude Tickets From Manifest" then exit;` — mirrors the existing voucher pattern.
- Does NOT affect wallet asset rendering — wallet manifests show their internal tickets/coupons regardless.

No new setup gate for coupons or wallets (Malthe: always include).

### 7. `IdentifyAssetType` updates (ecom branch)

Within the `Document Type = "Ecom Sales Document"` branch already present:

```
if TempLineBuffer."Is Wallet" then exit(AssetType::Wallet);
case TempLineBuffer."Ecom Line Subtype" of
    TempLineBuffer."Ecom Line Subtype"::Voucher: exit(AssetType::Voucher);
    TempLineBuffer."Ecom Line Subtype"::Ticket: exit(AssetType::Ticket);
    TempLineBuffer."Ecom Line Subtype"::Coupon: exit(AssetType::Coupon);
end;
exit(AssetType::None);
```

Update the caller `ProcessLineAssets` allowlist:

```
if not (AssetType in [AssetType::Voucher, AssetType::Ticket, AssetType::Coupon, AssetType::Wallet]) then
    exit;
```

Member Card remains blocked by omission (unchanged behavior).

Document-type scoping for Coupon and Wallet lives **inside** their processors rather than in the central gate. Each processor early-exits if the document is not an Ecom Sales Document, identified by `IsNullGuid(TempHeaderBuffer."Ecom Sales Header Id")`:

- `ProcessCouponAssets`: `if IsNullGuid(TempHeaderBuffer."Ecom Sales Header Id") then exit;` as the first statement.
- `ProcessWalletAssets`: same guard as the first statement.

This keeps the central gate as a simple type allowlist and matches how voucher/ticket processors already branch on document type internally.

The existing Magento-style bodies of `ProcessCouponAssets` and `ProcessWalletAssets` are **replaced** with the new Ecom-only implementations shown in §4 and §5 — coupons and wallets are not intended for Magento/Shopify, so no Magento branch is retained.

### 8. New / changed schema

| Object | Change | Notes |
|---|---|---|
| `NPR Digital Notification Setup` | +field `"Exclude Tickets From Manifest"` Boolean | AL ID Manager for field id |
| `NPR Digital Doc. Line Buffer` (temp) | +field `"Source Line System Id"` Guid | Carries `EcomSalesLine.SystemId` |
| `NPR Digital Doc. Line Buffer` (temp) | +field `"Is Wallet"` Boolean | Distinguishes wallet parent lines from plain coupons/tickets |
| `NPR Digital Notification Entry` | (no schema change) | UpdLock on EcomSalesHeader handles concurrency |

### 9. Files touched

- `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`
  - `PopulateBuffersFromEcomDoc` — new two-pass filter + wallet-ancestor detection.
  - `IdentifyAssetType` ecom branch — add Coupon + Wallet.
  - `ProcessLineAssets` — accept Coupon and Wallet asset types.
  - `ProcessCouponAssets` — ecom branch.
  - `ProcessWalletAssets` — ecom branch.
  - `ProcessTicketAssets` — add `Exclude Tickets From Manifest` early exit.
  - `TryCreateEcomDigitalNotification` — add UpdLock + re-check pattern.
  - `ValidateDigitalNotifSetup` load fields extended with `Exclude Tickets From Manifest`.
- `Application/src/Digital Notification/DigitalDocLineBuffer.Table.al` — add two fields.
- `Application/src/Digital Notification/DigitalNotificationSetup.Table.al` — add field + (optional) page update.
- `Application/src/Digital Notification/DigitalNotificationSetup.Page.al` — surface new field.
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponProcess.Codeunit.al` — call `TryCreateEcomDigitalNotification` on success.
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al` — call `TryCreateEcomDigitalNotification` on success branch.
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipProcess.Codeunit.al` — defensive `TryCreateEcomDigitalNotification` call on success path (no asset rendered — gate-unlatch only).

## Test scenarios (sandbox API requests)

Setup prerequisites to create manually in sandbox:
- **Coupon path**: Coupon Type `TEST_COUPON` with `NPDesignerTemplateId` set, `Trigger on Item = true`; `NpDc Iss.OnSale Setup Line` (Type=Item, No.=`60001`, Coupon Type=`TEST_COUPON`). Item `60001` is a plain Item.
- **Wallet path**: `NPR NpIa Item AddOn` = `WALLET_PKG`, with `NPDesignerTemplateId` set, wallet template contains a ticket admission + a coupon. Coupon Type `TEST_WALLET_COUPON` with `Trigger on Attraction Wallet = true` + `Trigger on Item = true`, Item No matching the wallet’s child coupon item. Item `70001` has `Create Attraction Wallet = true` + `Item Add-on No. = WALLET_PKG`. Attraction Wallet Setup enabled.
- Common: Adyen payment-method mapping `adyen_cc`, Digital Notification Setup enabled, Email Template configured, manifest feature enabled.

### A) Standalone coupon only

```json
{
  "externalNo": "TEST-DIGI-COUP-001",
  "documentType": "order",
  "sellToCustomer": {
    "name": "Andrei Lungu",
    "address": "123 Test Street",
    "postCode": "1000",
    "city": "Copenhagen",
    "countryCode": "DK",
    "email": "aolu@navipartner.com"
  },
  "payments": [
    {
      "paymentMethodType": "paymentGateway",
      "externalPaymentMethodCode": "adyen_cc",
      "paymentReference": "TEST-PAY-COUP-001",
      "paymentAmount": 100.00
    }
  ],
  "salesDocumentLines": [
    {
      "type": "item",
      "no": "60001",
      "description": "Gift Coupon 100",
      "unitPrice": 100.00,
      "quantity": 1,
      "vatPercent": 25,
      "lineAmount": 100.00
    }
  ]
}
```

Expected: 1 coupon asset in manifest, email sent.

### B) Attraction wallet only (wallet + ticket child + coupon child)

Pre-request script must set `TicketReservationToken` + `TicketReservationLineId` like the existing ticket script. Note: vouchers are blocked as wallet components.

```json
{
  "externalNo": "{{ExternalNo}}",
  "documentType": "order",
  "ticketReservationToken": "{{TicketReservationToken}}",
  "ticketHolder": "Andrei Lungu",
  "ticketHolderLanguage": "ENU",
  "sellToCustomer": {
    "name": "Andrei Lungu",
    "address": "123 Test Street",
    "postCode": "1000",
    "city": "Copenhagen",
    "countryCode": "DK",
    "email": "aolu@navipartner.com"
  },
  "payments": [
    {
      "paymentMethodType": "paymentGateway",
      "externalPaymentMethodCode": "adyen_cc",
      "paymentReference": "TEST-PAY-WAL-001",
      "paymentAmount": 500.00
    }
  ],
  "salesDocumentLines": [
    {
      "type": "item",
      "no": "70001",
      "description": "Family Package Wallet",
      "unitPrice": 500.00,
      "quantity": 1,
      "vatPercent": 25,
      "lineAmount": 500.00,
      "externalLineId": "BUNDLE-1"
    },
    {
      "type": "item",
      "no": "31001",
      "description": "Concert Ticket (wallet)",
      "unitPrice": 0,
      "quantity": 1,
      "vatPercent": 25,
      "lineAmount": 0,
      "ticketReservationLineId": "{{TicketReservationLineId}}",
      "externalLineId": "BUNDLE-1-TICKET",
      "parentExternalLineId": "BUNDLE-1"
    },
    {
      "type": "item",
      "no": "60001",
      "description": "Gift Coupon (wallet)",
      "unitPrice": 0,
      "quantity": 1,
      "vatPercent": 25,
      "lineAmount": 0,
      "externalLineId": "BUNDLE-1-COUPON",
      "parentExternalLineId": "BUNDLE-1"
    }
  ]
}
```

Expected: 1 wallet asset in manifest; ticket + coupon children NOT emitted as separate assets.

### C) Wallet quantity 2 (round-robin distribution → 2 wallets → 2 assets)

Same payload as B but change the wallet parent line to `"quantity": 2` and adjust children quantities to match the intended split. Expected: 2 wallet assets.

### D) Mixed — voucher + standalone ticket + standalone coupon + wallet-with-children

```json
{
  "externalNo": "{{ExternalNo}}",
  "documentType": "order",
  "ticketReservationToken": "{{TicketReservationToken}}",
  "ticketHolder": "Andrei Lungu",
  "ticketHolderLanguage": "ENU",
  "sellToCustomer": {
    "name": "Andrei Lungu",
    "address": "123 Test Street",
    "postCode": "1000",
    "city": "Copenhagen",
    "countryCode": "DK",
    "email": "aolu@navipartner.com"
  },
  "payments": [
    {
      "paymentMethodType": "paymentGateway",
      "externalPaymentMethodCode": "adyen_cc",
      "paymentReference": "TEST-PAY-MIX-001",
      "paymentAmount": 1400.00
    }
  ],
  "salesDocumentLines": [
    { "type": "voucher", "voucherType": "EXTERNAL", "description": "Gift Voucher 500", "unitPrice": 500, "quantity": 1, "vatPercent": 25, "lineAmount": 500 },
    { "type": "item", "no": "31001", "description": "Standalone Ticket", "unitPrice": 200, "quantity": 1, "vatPercent": 25, "lineAmount": 200, "ticketReservationLineId": "{{TicketReservationLineId}}" },
    { "type": "item", "no": "60001", "description": "Standalone Coupon", "unitPrice": 100, "quantity": 1, "vatPercent": 25, "lineAmount": 100 },
    { "type": "item", "no": "70001", "description": "Wallet Package", "unitPrice": 600, "quantity": 1, "vatPercent": 25, "lineAmount": 600, "externalLineId": "W1" },
    { "type": "item", "no": "31001", "description": "Ticket in wallet", "unitPrice": 0, "quantity": 1, "vatPercent": 25, "lineAmount": 0, "ticketReservationLineId": "{{TicketReservationLineId2}}", "externalLineId": "W1-T", "parentExternalLineId": "W1" },
    { "type": "item", "no": "60001", "description": "Coupon in wallet", "unitPrice": 0, "quantity": 1, "vatPercent": 25, "lineAmount": 0, "externalLineId": "W1-C", "parentExternalLineId": "W1" }
  ]
}
```

Expected manifest: voucher (1) + standalone ticket (1) + standalone coupon (1) + wallet (1). Bundle children NOT separate assets.

### E) Regression — plain item only (no digital notification)

Existing `TEST-DIGI-NODIG-006` body. No notification entry created.

### F) Exclude Tickets From Manifest = true

Repeat scenario D after enabling the new setup flag. Expected: voucher + standalone coupon + wallet assets; standalone ticket omitted. Wallet still renders its internal ticket inside the manifest asset (no change — the flag affects only standalone ticket processing).

### G) Coupon quantity > 1

Modify A to `"quantity": 3`. Expected: 3 coupon assets in manifest (3 rows in `NPR Ecom Sales Coupon Link`).

## Risks & mitigations

- **Concurrency double-insert** — mitigated by UpdLock pattern on `EcomSalesHeader` in `TryCreateEcomDigitalNotification`.
- **Trigger forgotten for new subtype** — future virtual-item subtypes added to `CalculateVirtualItemsDocStatus` without a matching `TryCreate` call would permanently block notification firing. Mitigated within this PR by adding calls from every existing subtype success path (voucher, ticket, coupon, wallet, membership). Convention for future subtypes: add the one-line trigger call when adding the status to `CalculateVirtualItemsDocStatus`.
- **Template missing** — silent skip (consistent with existing voucher/ticket/coupon Magento handling).
- **Performance of two-pass buffer population** — O(N) dictionary build + O(N) scan with O(1) parent lookup; well under any wall-clock threshold.

## Acceptance

1. A: coupon asset in manifest.
2. B: wallet asset only (children not separately emitted).
3. C: 2 wallet assets for quantity 2.
4. D: voucher + ticket + coupon + wallet (4 assets); wallet children skipped.
5. E: no notification for plain item.
6. F: `Exclude Tickets From Manifest` omits standalone ticket only.
7. G: 3 coupon assets for quantity 3.
8. Concurrency: issuing two concurrent JQ workers that each finish last on the same doc produces exactly ONE notification entry, no errors.

## Open questions (resolved)

1. Idempotency approach — **UpdLock** (reject Unique key to avoid error propagation into virtual-item success paths).
2. Bundle-ancestor check — in-memory dictionary in Digital Notification; no dependency on `EcomCreateWalletMgt`. Check is: `Parent Ext. Line ID <> ''` AND parent has `Is Attraction Wallet = true`.
3. Coupon multiplicity — iterate `EcomSalesCouponLink`, one manifest asset per row.
4. Wallet multiplicity — iterate wallets created from the line, one manifest asset per wallet.
5. Memberships — explicit skip; no trigger, no asset.
6. Fern docs — no change; API payload unchanged.
