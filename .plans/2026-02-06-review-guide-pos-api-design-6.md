# Review Guide: `mmv/isv2-640-pos-api-design-6`

**Branch:** `mmv/isv2-640-pos-api-design-6`
**Base:** `master` (merge base `4ae2197`)
**Scope:** 823 files changed, +18,366 / -1,778 lines
**PR:** #9276

This guide walks through all changes in a logical dependency order. Each section builds on the previous one, so by the end you'll have seen every file on the branch.

---

## Section 1: Restaurant Data Model (Tables & Pages)

**Why start here:** The restaurant menu data model is the foundation that both the BC UI and the REST API build on. Understanding these tables first makes the API layer trivial to follow.

### 1a. Restaurant Table Extensions

| File | What |
|------|------|
| `Application/src/Restaurant/NPRERestaurant.Table.al` | +21 lines: new fields on the Restaurant table (likely webhook/menu config) |
| `Application/src/Restaurant/NPRERestaurantCard.Page.al` | +48 lines: UI for the new restaurant fields |
| `Application/src/Restaurant/NPRERestaurantSetup.Page.al` | Small UI tweak |

**Review focus:** What new fields were added to the restaurant record and are they sensible.

### 1b. Menu Hierarchy (Menu -> Category -> MenuItem)

| File | What |
|------|------|
| `Application/src/Restaurant/Menu/NPREMenu.Table.al` | **New.** Menu header table: restaurant + menu code, time-based switching |
| `Application/src/Restaurant/Menu/NPREMenus.Page.al` | **New.** List page for menus |
| `Application/src/Restaurant/Menu/NPREMenuCategory.Table.al` | **New.** Categories within a menu, with sort key ordering |
| `Application/src/Restaurant/Menu/NPREMenuCategories.Page.al` | **New.** Category list page with move up/down actions |
| `Application/src/Restaurant/Menu/NPREMenuItem.Table.al` | **New.** Items within a category. Links to BC Item table. FlowFields for Has Addons, Has Picture, Has Upsells, Captions Filled |
| `Application/src/Restaurant/Menu/NPREMenuItems.Page.al` | **New.** Menu item list page |
| `Application/src/Restaurant/Menu/NPREMenuItemsPart.Page.al` | **New.** Subpage part for embedding in category view |

**Review focus:**
- Menu -> Category -> MenuItem is a 3-level hierarchy, all keyed by Restaurant Code + Menu Code (+ Category Code + Line No.)
- Sort Key pattern: auto-assigned on insert (+10000), swap-based MoveUp/MoveDown
- Unique key on (Restaurant, Menu, Category, Sort Key) - the `Unique = true` constraint matters for API ordering
- OnDelete cascades: Menu deletes categories, categories delete items, items delete upsells/translations

### 1c. Translations & Captions

| File | What |
|------|------|
| `Application/src/Restaurant/Menu/NPREMenuCatTranslation.Table.al` | **New.** Category translation table (language + caption) |
| `Application/src/Restaurant/Menu/NPREMenuCatCaptions.Page.al` | **New.** UI for category translations |
| `Application/src/Restaurant/Menu/NPREMenuItemTranslation.Table.al` | **New.** Menu item translation table, linked by SystemId |
| `Application/src/Restaurant/Menu/NPREMenuItemTranslat.Page.al` | **New.** Translation list page |
| `Application/src/Restaurant/Menu/NPREMenuItemTraDet.Page.al` | **New.** Translation detail page |

**Review focus:** Translations are linked via `External System Id` (GUID) rather than composite key. This is intentional for API-friendliness but worth noting as a pattern.

### 1d. Upsells

| File | What |
|------|------|
| `Application/src/Restaurant/Menu/NPREUpsell.Table.al` | **New.** Upsell suggestions linked to menu items via SystemId |
| `Application/src/Restaurant/Menu/NPREUpsellList.Page.al` | **New.** Upsell list UI |
| `Application/src/Restaurant/Menu/NPREUpsellTable.Enum.al` | **New.** Enum for which table the upsell belongs to |

### 1e. Media (Pictures & Logos)

| File | What |
|------|------|
| `Application/src/Restaurant/Menu/Media/NPREMenuItemPictureHandler.Codeunit.al` | **New.** Upload/delete menu item pictures via Cloudflare |
| `Application/src/Restaurant/Menu/Media/NPREMenuItemPictureCard.Page.al` | **New.** Picture preview card |
| `Application/src/Restaurant/Menu/Media/NPREMenuItemImageFactBox.Page.al` | **New.** FactBox for inline picture display |
| `Application/src/Restaurant/Menu/Media/NPRERestaurantLogoHandler.Codeunit.al` | **New.** Restaurant logo via Cloudflare, uses SystemId as public ID |
| `Application/src/Restaurant/Menu/Media/NPRERestaurantLogoFactBox.Page.al` | **New.** Logo factbox |
| `Application/src/CloudflareMedia/_public/CloudflareMediaSelector.Enum.al` | **New.** Enum values for MENU_ITEM_PICTURE and RESTAURANT_LOGO |

**Review focus:** Images are stored in Cloudflare, not in BC blob/media fields (per CLAUDE.md rules). The `CloudflareMediaLink` table references records by TableNumber + SystemId + MediaSelector.

### 1f. Webhooks

| File | What |
|------|------|
| `Application/src/Restaurant/Menu/NPRERestaurantWebhook.Enum.al` | **New.** Webhook event types enum |
| `Application/src/Restaurant/Menu/NPRERestaurantWebhooks.Codeunit.al` | **New.** Fires webhooks on menu changes (carries posEntryId) |

---

## Section 2: Item AddOn Enhancements

**Why here:** The POS Sale API references addons extensively. Understanding the addon data model changes helps when reviewing CreateSaleLineAddon.

| File | What |
|------|------|
| `Application/src/Item AddOn/NpIaItemAddOnCategory.Table.al` | **New.** AddOn Category table with Sort Key auto-assignment |
| `Application/src/Item AddOn/NpIaItemAddOnCategories.Page.al` | **New.** Category list page |
| `Application/src/Item AddOn/NpIaItemAddOnCatTrans.Table.al` | **New.** Category translation table |
| `Application/src/Item AddOn/NpIaAddOnCatTrans.Page.al` | **New.** Category translation UI |
| `Application/src/Item AddOn/ItemAddonTranslation.Table.al` | **New.** AddOn line translation table |
| `Application/src/Item AddOn/ItemAddonTranslation.Page.al` | **New.** AddOn line translation UI |
| `Application/src/Item AddOn/NpIaItemAddOnMgt.Codeunit.al` | +14 lines: management changes |
| `Application/src/Item AddOn/_public/NpIaItemAddOnLine.Table.al` | +12 lines: new fields (IncludeFromDate, IncludeUntilDate, AddToWallet, Serial/Lot No.) |
| `Application/src/Item AddOn/_public/NpIaItemAddOnLineOpt.Page.al` | +17 lines: UI for new fields |
| `Application/src/Item AddOn/_public/NpIaItemAddOnSubform.Page.al` | +20 lines: Category Code column added to subform |

**Review focus:**
- AddOn Categories add grouping to addon lines (e.g., "Toppings", "Sides")
- New fields on AddOnLine: date filtering, wallet integration, serial/lot tracking
- Translation tables follow same SystemId-linked pattern as restaurant translations

---

## Section 3: POS Core Changes

**Why here:** The API layer calls into POS Core. Understanding what changed in core sale/entry processing explains the API's behavior.

### 3a. POS Sale & Sale Line

| File | What |
|------|------|
| `Application/src/POS Core/_public/POSSale.Table.al` | -37+: field removals/changes on POS Sale table |
| `Application/src/POS Core/_public/POSSaleLine.Codeunit.al` | +23 lines: changes to sale line codeunit (likely addon insertion positioning) |
| `Application/src/POS Core/_public/POSPaymentLine.Codeunit.al` | +14 lines: `SetUseCustomSystemId` support for API-provided payment line IDs |

**Review focus:**
- `SetUseCustomSystemId` is critical: it allows the API to assign specific GUIDs to payment lines so the client can track them
- Sale line changes likely support the addon API's need to position lines correctly

### 3b. POS Entry Creation & Data Refresh

| File | What |
|------|------|
| `Application/src/POS Posting/_public/POSCreateEntry.Codeunit.al` | +44 lines: changes to how POS entries are created |
| `Application/src/POS Core/_public/MoveEntries.Codeunit.al` | **New.** +116 lines: entry movement/consolidation logic |
| `Application/src/POS Core/POS Data Refresh/POSRefreshSale.Codeunit.al` | +27 lines |
| `Application/src/POS Core/POS Data Refresh/POSRefreshSaleLine.Codeunit.al` | +27 lines |
| `Application/src/POS Core/POS Data Refresh/POSRefreshPaymentLine.Codeunit.al` | +27 lines |

**Review focus:** The Data Refresh codeunits likely support the delta response pattern - after a mutation, the API needs to report what changed. Check that the refresh logic correctly captures insertions/modifications.

### 3c. Restaurant Print System

| File | What |
|------|------|
| `Application/src/Restaurant/NPREPrintTemplate.Table.al` | **New.** +107 lines: configurable print templates |
| `Application/src/Restaurant/NPREPrintTemplSubpage.Page.al` | Modified print template subpage |
| `Application/src/Restaurant/NPREPrintTemplateSubP.Page.al` | **New.** Additional subpage |
| `Application/src/Restaurant/NPREWPadLineOutpBuffer.Table.al` | **New.** +63 lines: output buffer for line printing |
| `Application/src/Restaurant/Static Restaurant Print/NPREStaticKitchenPrint.Codeunit.al` | **New.** +93 lines: static (non-RDLC) kitchen order printing |
| `Application/src/Restaurant/Static Restaurant Print/NPREStaticPreReceipt.Codeunit.al` | **New.** +154 lines: static pre-receipt generation |
| `Application/src/Restaurant/_public/NPRERestaurantPrint.Codeunit.al` | +376 lines: major expansion of print capabilities |
| `Application/src/POS Core/NewRestaurantPrintExp.Codeunit.al` | **New.** +118 lines: bridge between POS and restaurant print |
| `Application/src/Restaurant/KDS/NPREKitchenOrderMgt.Codeunit.al` | +9 lines: kitchen order management tweaks |
| `Application/src/Restaurant/KDS/KDSWebService.PermissionSet.al` | +1 line: permission update |

**Review focus:**
- Static print = codeunit-based receipt generation (not RDLC reports), needed for API-driven receipt endpoints
- The print codeunits use event subscription binding for extensibility
- WPadLineOutpBuffer is the intermediate buffer between order data and printed output

### 3d. Period Discount & Pricing

| File | What |
|------|------|
| `Application/src/Period Discount/PeriodDiscountManagement.Codeunit.al` | +70 lines: VAT calculation fix (#9520) |

**Review focus:** This is a merged master fix for period discount VAT calculation. Important pricing correctness change.

---

## Section 4: POS Sale API (The Main Feature)

**This is the heart of the branch.** The POS Sale API allows external applications to create and manage POS sales via REST.

### 4a. Route Handler

| File | What |
|------|------|
| `Application/src/_API_SERVICES/POS/APIPOSHandler.Codeunit.al` | +93 lines: all POS routes (sale CRUD, sale lines, payment lines, EFT, entry, salesperson, store, unit) |

**Review focus:** The route table. Every endpoint on the POS API is registered here. Note the commented-out EFT endpoints (future work). The pattern is `Request.Match(METHOD, '/pos/...')` dispatching to handler codeunits.

### 4b. Sale Management

| File | What |
|------|------|
| `Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al` | +503 lines: CreateSale, UpdateSale, DeleteSale, CompleteSale, GetSale, SearchSale, CreateKitchenOrder |
| `Application/src/_API_SERVICES/POS/Sale/APIPOSDeltaBuilder.Codeunit.al` | **New.** +36 lines: captures mutations via event subscriptions for delta responses |

**Review focus:**
- `ReconstructSession` is the key pattern: creates an in-memory POS session from a persisted sale record, runs the mutation, then returns the delta
- `CommitBehavior::Ignore` at the procedure level prevents auto-commits inside the API handler
- `CompleteSale` triggers the full POS posting flow (creates POS Entry)
- `CreateKitchenOrder` creates a kitchen order from the active sale
- Delta builder subscribes to POS data refresh events to capture what changed
- `SearchSale` uses `SetLoadFields` for performance (the SetLoadFields fix from this review session lives here)

### 4c. Sale Lines

| File | What |
|------|------|
| `Application/src/_API_SERVICES/POS/Sale/APIPOSSaleLine.Codeunit.al` | **New.** +536 lines: CreateSaleLine, CreateSaleLineAddon, UpdateSaleLine, DeleteSaleLine, GetSaleLine, ListSaleLines |

**Review focus:**
- `CreateSaleLine` reconstructs the POS session, inserts via `POSSaleLine.InsertLine`
- `CreateSaleLineAddon` validates parent line exists AND belongs to the same sale (the ownership check from this review session)
- Addons use `NpIaItemAddOnMgt` for insertion, inheriting all BC addon business logic
- `UpdateSaleLine` supports patching quantity and description
- Sort key assignment and Evaluate guard for saleLineId (fixed during this review)

### 4d. Payment Lines

| File | What |
|------|------|
| `Application/src/_API_SERVICES/POS/Sale/APIPOSPaymentLine.Codeunit.al` | **New.** +365 lines: CreatePaymentLine (Cash + EFT), DeletePaymentLine, GetPaymentLine, ListPaymentLines |

**Review focus:**
- Two payment types: `Cash` (simple insert) and `EFT` (creates EFTTransactionRequest, handles card mapping, stores EFT receipts)
- `SetUseCustomSystemId(true)` allows the API caller to specify the payment line GUID upfront
- EFT flow: creates the request, attempts payment method mapping via BIN/issuer, inserts the payment line with `EFT Approved` flag
- EFT receipt lines stored from a JSON array in the request body

### 4e. Background Cleanup

| File | What |
|------|------|
| `Application/src/_API_SERVICES/POS/Sale/JQCleanupDeadPOSSales.Codeunit.al` | **New.** +44 lines: Job Queue task that cleans up abandoned API-created sales |

**Review focus:**
- Runs as a Job Queue entry (background session)
- Deletes sales on unattended POS units older than 4 hours
- Wrapped in Sentry transaction + Session.LogMessage (fixed during this review - was using Message() which crashes in background)

### 4f. Example HTTP file

| File | What |
|------|------|
| `Application/src/_API_SERVICES/POS/Sale/example.http` | **New.** +85 lines: example HTTP requests for testing the API manually |

---

## Section 5: POS Entry API

**Builds on:** POS Core (entries created by CompleteSale) and the print system.

| File | What |
|------|------|
| `Application/src/_API_SERVICES/POS/Entry/APIPOSEntry.Codeunit.al` | **New.** +452 lines: ListEntries (paginated), GetEntry, PrintPosEntry |
| `Application/src/_API_SERVICES/POS/Entry/APIPOSEntryPrintMgt.Codeunit.al` | **New.** +35 lines: print management for generating receipt content |

**Review focus:**
- `ListEntries` uses a PageKey-based cursor pagination pattern with `lastRowVersion` and `sync=true/false` for incremental sync
- Pagination bounds: default pageSize=50, max=100 (added during this review)
- `PrintPosEntry` renders receipts as HTML using the static print codeunits from Section 3c
- `ReadIsolation::ReadCommitted` throughout for performance

---

## Section 6: Restaurant API

**Builds on:** Restaurant data model (Section 1) and POS Core kitchen order management.

### 6a. Infrastructure

| File | What |
|------|------|
| `Application/src/_API_SERVICES/restaurant/APIRestaurantHandler.Codeunit.al` | **New.** Route handler: GET /restaurant, GET /restaurant/:restaurantId/menu, GET /restaurant/:restaurantId/menu/:menuId, GET /restaurant/:restaurantId/orders |
| `Application/src/_API_SERVICES/restaurant/APIRestaurant.Codeunit.al` | **New.** +45 lines: lists restaurants with SystemId as `id` |
| `Application/src/_API_SERVICES/restaurant/APIRestaurantResolver.Codeunit.al` | **New.** +19 lines: resolves restaurant GUID to record |
| `Application/src/_API_SERVICES/restaurant/APIRestaurant.PermissionSet.al` | **New.** Permission set for restaurant API objects |

### 6b. Menu Endpoints

| File | What |
|------|------|
| `Application/src/_API_SERVICES/restaurant/APIRestaurantMenu.Codeunit.al` | **New.** +522 lines: GetMenus and GetMenu with full nested JSON (categories -> items -> addons -> options, translations, upsells, pictures) |

**Review focus:**
- `GetMenu` builds a deeply nested JSON response: menu -> categories[] -> items[] -> addons[] -> options[]
- Each level includes translations array
- Addon data is pulled from the Item AddOn tables (not restaurant-specific)
- Pictures come from CloudflareMediaLink
- Time-based menu switching: menus have from/to times, `GetMenus` shows the one active "now"

### 6c. Kitchen Orders

| File | What |
|------|------|
| `Application/src/_API_SERVICES/restaurant/APIRestKitchenOrders.Codeunit.al` | **New.** +125 lines: paginated kitchen order listing by restaurant |

**Review focus:**
- Uses GUID-based restaurant resolution (fixed during this review - was using Code)
- PageKey pagination pattern matching POS Entry
- Returns kitchen orders with nested line items

---

## Section 7: Membership & Ticketing API Updates

These are incremental additions to existing API modules, merged from other work.

### 7a. Memberships

| File | What |
|------|------|
| `Application/src/_API_SERVICES/memberships/MembershipApiTranslation.Codeunit.al` | **New.** Translation support |
| `Application/src/_API_SERVICES/memberships/MembershipsAPI.Codeunit.al` | +7 lines |
| `Application/src/_API_SERVICES/memberships/handlers/MemberApiAgent.Codeunit.al` | +53 lines: expanded member endpoints |
| `Application/src/_API_SERVICES/memberships/handlers/MemberCardApiAgent.Codeunit.al` | +9 lines |
| `Application/src/_API_SERVICES/memberships/handlers/MembershipApiAgent.Codeunit.al` | +9 lines |
| `Application/src/_API_SERVICES/memberships/handlers/MembershipPhasesApiAgent.Codeunit.al` | +69 lines: phase management |

### 7b. Ticketing

| File | What |
|------|------|
| `Application/src/_API_SERVICES/ticketing/TicketingAPI.Codeunit.al` | +7 lines |
| `Application/src/_API_SERVICES/ticketing/TicketingApiFunctions.Enum.al` | +4 enum values |
| `Application/src/_API_SERVICES/ticketing/TicketingApiHandler.Codeunit.al` | +3 lines: new routes |
| `Application/src/_API_SERVICES/ticketing/TicketingApiTranslations.Codeunit.al` | +13 lines |
| `Application/src/_API_SERVICES/ticketing/handlers/TicketingCatalogAgent.Codeunit.al` | +51 lines |
| `Application/src/_API_SERVICES/ticketing/handlers/TicketingReportAgent.Codeunit.al` | +193 lines: reporting endpoints |
| `Application/src/_API_SERVICES/ticketing/handlers/TicketingReservationAgent.Codeunit.al` | +19 lines |
| `Application/src/_API_SERVICES/ticketing/handlers/TicketingTicketAgent.Codeunit.al` | +56 lines |

---

## Section 8: Fern API Documentation

**Builds on:** All the API codeunits above. The Fern YAML is the external contract.

| File | What |
|------|------|
| `fern/apis/default/definition/pos/possale.yml` | +763 lines: full POS Sale API spec (sale, sale lines, payment lines, complete) |
| `fern/apis/default/definition/pos/posentry.yml` | **New.** +381 lines: POS Entry API spec (list, get, print) |
| `fern/apis/default/definition/restaurant/restaurant.yml` | **New.** +32 lines: list restaurants |
| `fern/apis/default/definition/restaurant/menu.yml` | **New.** +175 lines: menu endpoints |
| `fern/apis/default/definition/restaurant/orders.yml` | **New.** +55 lines: kitchen orders (uses restaurantId UUID) |
| `fern/apis/default/definition/restaurant/types-restaurant.yml` | **New.** +298 lines: all restaurant type definitions |
| `fern/apis/default/definition/restaurant/webhooks.yml` | **New.** +54 lines: webhook event documentation |
| `fern/apis/default/definition/memberships/types/types-composite.yml` | +81 lines |
| `fern/apis/default/definition/memberships/types/types-simple.yml` | +79 lines |
| `fern/apis/default/definition/ticketing/service-catalog.yml` | +15 lines |
| `fern/apis/default/definition/ticketing/service-reports.yml` | **New.** +253 lines |
| `fern/apis/default/definition/ticketing/service-reservations.yml` | +58 lines |
| `fern/apis/default/definition/ticketing/types-composite.yml` | +17 lines |
| `fern/apis/default/definition/ticketing/types-simple.yml` | +32 lines |
| `fern/docs.yml` | +29 lines: navigation entries for new sections |
| `fern/docs/pages/pos/posentry.mdx` | **New.** Entry docs page |
| `fern/docs/pages/restaurant/overview.mdx` | **New.** Restaurant docs overview |

**Review focus:**
- Cross-reference YAML types with actual AL response JSON builders
- Check that all required/optional fields match the codeunit implementations
- Verify examples are realistic (GUIDs, amounts, payment types)

---

## Section 9: Tests

| File | What |
|------|------|
| `Test/src/Tests/API/POSAPITests.Codeunit.al` | **New.** +1,499 lines: comprehensive POS Sale API tests |
| `Test/src/Tests/API/KitchenOrderAPITests.Codeunit.al` | **New.** +450 lines: kitchen order API tests (uses GUID, fixed during review) |
| `Test/src/Tests/API/RestaurantWebhookTestSub.Codeunit.al` | **New.** +33 lines: webhook event subscriber for test verification |
| `Test/src/Libraries/LibraryRestaurant.Codeunit.al` | **New.** +416 lines: test library with helpers for restaurant, menu, kitchen order, and addon setup |
| `Test/src/Tests/NationalIdentifiers/NationalIdentifierTests.Codeunit.al` | **New.** +191 lines: tests for DK/SE national identifier validation |

**Review focus:**
- POS API tests cover: create sale, add lines, add addons (with various pricing scenarios), add payments (Cash + EFT), complete sale, search, delta responses
- Kitchen order tests: list orders, get order, pagination, webhook firing, no-orders returns 404
- Library helpers create full test data chains: POS Store -> POS Unit -> Restaurant -> Menu -> Category -> Item -> AddOn
- Tests use `ReadIsolation::ReadUncommitted` to read uncommitted data within test transactions

---

## Section 10: Merged Master Changes

These are changes from other PRs that were merged into master and then into this branch. They're not part of the POS API feature but are included in the diff.

### 10a. National Identifiers (#9576)

| Files | What |
|-------|------|
| `Application/src/National Identifiers/` (12 files) | **New module.** Interface-based national ID validation for DK (CPR, CVR, VAT) and SE (PNR, ONR, CNR, VAT) |
| `Application/src/Member Module/` (several files) | Member module integration with national identifiers |

**Review focus:** Clean interface pattern (`NationalIdentifierIface`), country-specific implementations, Luhn/modulus validation algorithms.

### 10b. RS Fiscal & Retail Localization (#9006)

| Files | What |
|-------|------|
| `Application/src/Localizations/[RS] Retail Localization/` (5 files) | Zero-amount line handling, 100% discount fix, GL addition refactoring |
| `Application/src/Localizations/[RS] Fiskalizacija/` (2 files) | Fiscal certificate and communication changes |

### 10c. Coupon Archive Facade (#9573)

| Files | What |
|-------|------|
| `Application/src/Coupon/_public/NpDcArchCouponEntry.Codeunit.al` | **New.** Facade for archived coupon entries |
| `Application/src/Coupon/_public/NpDcArchCouponEntryBuff.Table.al` | **New.** Buffer table for archived coupons |

### 10d. Other Merged PRs

| PR | Files | Summary |
|----|-------|---------|
| #9459 | `Application/src/POS Payment/EFT/Adyen/` (4 files) | Adyen abort acquisition task optimization |
| #9492 | `Application/src/Magento 2/` | Shopify GraphQL migration for close-order |
| #9520 | `Application/src/Period Discount/` | Period discount VAT calculation fix |
| #9521 | `Application/src/Restaurant/` (print files) | New kitchen/restaurant print experience |
| #9576 | National identifiers (see 10a) | |
| #9577 | `IntegrationTest/` (3 files) | Editable button test improvements |
| #9582 | Various | Mark legacy modules as obsolete |
| #9584 | Member Module | Cancellation fields |
| #9585 | Various | Remove code obsoleted by Microsoft |
| #9587 | `CLAUDE.md` | Root CLAUDE.md |
| #9588 | Ticketing | Dynamic price profile endpoint |
| #9589 | Member Module | BlockedAt on API |
| #9591 | Member Module | Current period field |
| #9594 | AppSource | API fixes |
| #9596 | Power BI | New fields |
| #9600 | Ticketing | Navigation on cancelled tickets |
| #9601 | Ticketing | Time-travel filter fix |
| #9605 | Ticketing | Group ticket kind |
| #9608 | Feature Management | Remove `basicUsernameAsText` flag |
| #9609 | Feature Management | Remove `blocksalespersononposviabutton` flag |

---

## Section 11: Infrastructure & Config

| File | What |
|------|------|
| `CLAUDE.md` | **New.** Repository-level AI assistant instructions |
| `CODEOWNERS` | +164 lines: ownership rules for new modules |
| `.github/Workflows.config.json` | +6 lines: CI config updates |
| `.gitignore` | +5 lines |
| `.plans/2026-02-02-pos-api-test-coverage-design.md` | Test plan design doc |
| `.plans/2026-02-02-pos-api-test-implementation.md` | Test implementation plan |
| `Application/src/Feature Management/Feature.Enum.al` | +5 lines: new feature flags |
| `Application/src/Application Area/EnableApplicationAreas.Codeunit.al` | +12 lines |
| `Application/src/Json/_public/JsonBuilder.Codeunit.al` | Moved (0 line diff) |
| `Application/src/Json/_public/JsonHelper.Codeunit.al` | Moved (0 line diff) |
| `Application/src/Json/_public/JsonParser.Codeunit.al` | Moved (0 line diff) |

---

## Review Checklist

After going through all sections, verify:

- [ ] **Section 1-2:** Data model makes sense (restaurant menu hierarchy + addon categories)
- [ ] **Section 3:** POS Core changes support the API correctly (session reconstruction, delta capture, custom SystemId)
- [ ] **Section 4:** POS Sale API: all CRUD operations, CommitBehavior, error handling, Sentry telemetry
- [ ] **Section 5:** POS Entry API: pagination bounds, print rendering, sync pattern
- [ ] **Section 6:** Restaurant API: GUID resolution, nested JSON, menu time switching
- [ ] **Section 7:** Membership/Ticketing: incremental, nothing breaking
- [ ] **Section 8:** Fern YAML matches AL implementations
- [ ] **Section 9:** Tests cover happy paths + edge cases (addon pricing, VAT, EFT)
- [ ] **Section 10:** Merged master changes are clean merges, no conflicts
- [ ] **Section 11:** No sensitive data in configs, CODEOWNERS correct

### Key Patterns to Watch For Across All Sections

1. **Preprocessor guards:** All new API code uses `#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)` - verify nothing leaks outside
2. **Access = Internal:** New objects should be Internal unless in `_public/` folders
3. **ReadIsolation::ReadCommitted:** Used consistently in read endpoints for performance
4. **SystemId as public ID:** All entities exposed via API use SystemId (GUID), never integer PKs
5. **Evaluate guards:** All GUID path parameters have `if not Evaluate(...) then exit(RespondBadRequest(...))`
6. **SetLoadFields:** Used in list/search endpoints for performance - verify no field is read but not loaded
