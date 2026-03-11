# POS API Test Coverage Design

## Overview

Extend the POS API test suite to cover edge cases around VAT/pricing configurations, addon insertion, restaurant menu endpoints, and kitchen order webhook verification.

## Test File Structure

All tests will be added to the existing `POSAPITests.Codeunit.al` (codeunit 85240) to maintain consistency with the current test organization. The preprocessor directive `#if not BC17 and not BC18...BC22` will be preserved since these APIs only exist in BC23+.

## Library Extensions

`LibraryRestaurant.Codeunit.al` (codeunit 85242) will be extended with:

```al
// Menu creation
CreateMenu(var Menu; RestaurantCode)
CreateMenuCategory(var MenuCategory; RestaurantCode, MenuCode, CategoryCode)
CreateMenuItem(var MenuItem; RestaurantCode, MenuCode, CategoryCode, ItemNo)

// Item addon creation
CreateItemAddon(var ItemAddOn; ItemNo)
CreateItemAddonLine(var ItemAddOnLine; AddOnNo, ItemNo, UseUnitPrice, UnitPrice)
CreateItemAddonLineOption(var ItemAddOnLineOpt; AddOnNo, LineNo, ItemNo, UseUnitPrice, UnitPrice)

// Kitchen order lifecycle
FinishKitchenOrder(KitchenOrderNo) - marks all lines as served, triggers webhook

// User setup for menu endpoint
SetupUserPOSUnit(POSUnitNo)
```

## Test Data Strategy

Each test will use the shared `Initialize()` setup for POS infrastructure, then create test-specific item/addon configurations. This avoids test interdependence while reusing expensive POS setup via the `_Initialized` boolean pattern with codeunit isolation.

---

## Test Specifications

### 1. VAT/Pricing Edge Case Tests

#### Test: SaleLine_EmptyVATBusPostGrPrice_PricesInclVAT_Success

**Purpose:** Verify item with empty "VAT Bus. Posting Gr. (Price)" and Prices Including VAT=true can be sold.

**Setup:**
- Create item with `"Prices Including VAT" := true`
- Clear `"VAT Bus. Posting Gr. (Price)"` (leave empty)
- Standard VAT Posting Setup exists for the item's VAT groups

**Actions:**
1. Create sale via API
2. Add sale line with this item
3. Complete sale with payment

**Expected:** Sale completes successfully, prices calculate correctly based on item's VAT Prod. Posting Group.

**Note:** QA reported a potential bug here - test should expose it if present.

---

### 2. Addon Tests with Various VAT/Price Settings

#### Test: SaleLine_WithAddon_UseUnitPriceAlways_Success

**Setup:**
- Create item with addon line where `Use Unit Price` = Always, `Unit Price` = 15.00

**Actions:**
1. Create sale, add item line
2. Add addon via POST `/pos/sale/:saleId/saleline/:lineId/addon`
3. GET sale with `withLines=true`

**Expected:** Addon line created with `unitPrice` = 15.00 (addon's defined price)

---

#### Test: SaleLine_WithAddon_UseUnitPriceNonZero_WithPrice_Success

**Setup:**
- Create item with addon line where `Use Unit Price` = Non-Zero, `Unit Price` = 10.00

**Expected:** Addon line uses addon's price (10.00) since it's non-zero

---

#### Test: SaleLine_WithAddon_UseUnitPriceNonZero_ZeroPrice_UsesItemPrice

**Setup:**
- Create item with addon line where `Use Unit Price` = Non-Zero, `Unit Price` = 0
- Addon's underlying item has Unit Price = 25.00

**Expected:** Addon line uses item's price (25.00) since addon price is zero

---

#### Test: SaleLine_WithAddon_ParentEmptyVATBusPostGrPrice_Success

**Setup:**
- Parent item with empty "VAT Bus. Posting Gr. (Price)"
- Addon line with price defined

**Expected:** Addon can be inserted successfully despite parent's VAT configuration

**Note:** QA reported addon insertion may fail under certain VAT/pricing configurations - this test should expose it.

---

### 3. Inline Addons Array Test

#### Test: SaleLine_WithAddonsArray_MultipleAddons_Success

**Setup:**
- Create item with Item AddOn containing 2 addon lines:
  - Addon line 1 (Line No. 10): Type=Quantity, `Use Unit Price`=Always, `Unit Price`=15.00
  - Addon line 2 (Line No. 20): Type=Quantity, `Use Unit Price`=Non-Zero, `Unit Price`=10.00

**Actions:**
1. Create sale
2. POST sale line with `addons` array containing both addons:
```json
{
  "type": "Item",
  "code": "ITEM-001",
  "quantity": 1,
  "addons": [
    { "lineId": "guid-1", "addonNo": "ADDON-001", "addonLineNo": 10, "quantity": 1 },
    { "lineId": "guid-2", "addonNo": "ADDON-001", "addonLineNo": 20, "quantity": 2 }
  ]
}
```
3. GET sale with `withLines=true`

**Expected:**
- 3 sale lines total (1 parent + 2 addons)
- Addon lines have `isAddon=true` and `appliesToLine` pointing to parent SystemId
- Addon 1 price = 15.00, Addon 2 price = 10.00 (respecting their settings)

---

### 4. Restaurant Menu Endpoint Test

#### Test: RestaurantMenu_WithItemsAndAddons_ReturnsStructure

**Setup:**
- Create restaurant via `LibraryRestaurant`
- Create menu with `Active = true`
- Create menu category
- Create menu item linked to an Item record
- Create Item AddOn with:
  - Quantity-type line (direct item)
  - Select-type line with options
- Link addon to the menu item's underlying Item record (`Item."NPR Item AddOn No."`)
- Setup user's POS Unit via UserSetup

**Actions:**
- GET `/restaurant/:restaurantId/menu/:menuId`

**Expected:** Response contains:
```json
{
  "menuContent": {
    "categories": [{
      "items": [{
        "itemCode": "...",
        "addonItems": [
          {
            "addonNo": "ADDON-001",
            "addonLineNo": 10,
            "type": "Quantity",
            "unitPrice": 15.00,
            "description": {...}
          },
          {
            "addonNo": "ADDON-001",
            "addonLineNo": 20,
            "type": "Select",
            "selectOptions": [...]
          }
        ]
      }]
    }]
  }
}
```

---

### 5. Kitchen Order Webhook Verification

#### Modification: Extend CompleteSale_WithKitchenRequest_TransfersCustomerDetails

**Current test flow:**
1. Create sale with item
2. Add payment
3. Complete with kitchenRequest
4. Verify WaiterPad has customer details ✓

**Extended flow (additions in bold):**
1. Create sale with item
2. Add payment
3. Bind webhook subscriber
4. Complete with kitchenRequest
5. Verify WaiterPad has customer details
6. **Get kitchen order number from response (`kitchenOrderNo`)**
7. **Call `LibraryRestaurant.FinishKitchenOrder(KitchenOrderNo)`**
8. **Assert `RestaurantWebhookTestSub.WasWebhookInvoked() = true`**
9. **Assert `RestaurantWebhookTestSub.GetLastKitchenOrderId() = KitchenOrderNo`**

---

## Library Implementation Details

### FinishKitchenOrder

Uses existing order-level `SetRequestLinesAsServed` from `NPR NPRE Kitchen Order Mgt.`:

```al
procedure FinishKitchenOrder(KitchenOrderNo: BigInteger)
var
    KitchenRequest: Record "NPR NPRE Kitchen Request";
    KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
begin
    KitchenOrderMgt.SetHideValidationDialog(true);

    KitchenRequest.SetCurrentKey("Order ID");
    KitchenRequest.SetRange("Order ID", KitchenOrderNo);
    KitchenRequest.SetFilter("Line Status", '<>%1&<>%2',
        KitchenRequest."Line Status"::Served,
        KitchenRequest."Line Status"::Cancelled);

    KitchenOrderMgt.SetRequestLinesAsServed(KitchenRequest);
end;
```

This triggers the webhook via the existing flow:
- `SetRequestLinesAsServed` → `SetRequestLineAsServed` → `UpdateOrderStatus` → `InvokeOrderReadyForServingWebhook`

---

## Files to Modify

| File | Changes |
|------|---------|
| `Test/src/Tests/API/POSAPITests.Codeunit.al` | Add 7 new test procedures, extend 1 existing |
| `Test/src/Libraries/LibraryRestaurant.Codeunit.al` | Add ~10 helper procedures |

## New Test Procedures Summary

1. `SaleLine_EmptyVATBusPostGrPrice_PricesInclVAT_Success`
2. `SaleLine_WithAddon_UseUnitPriceAlways_Success`
3. `SaleLine_WithAddon_UseUnitPriceNonZero_WithPrice_Success`
4. `SaleLine_WithAddon_UseUnitPriceNonZero_ZeroPrice_UsesItemPrice`
5. `SaleLine_WithAddon_ParentEmptyVATBusPostGrPrice_Success`
6. `SaleLine_WithAddonsArray_MultipleAddons_Success`
7. `RestaurantMenu_WithItemsAndAddons_ReturnsStructure`

## Modified Test Procedure

8. `CompleteSale_WithKitchenRequest_TransfersCustomerDetails` - extended with webhook verification

## New Library Procedures

- `CreateMenu(var Menu; RestaurantCode)`
- `CreateMenuCategory(var MenuCategory; RestaurantCode, MenuCode, CategoryCode)`
- `CreateMenuItem(var MenuItem; RestaurantCode, MenuCode, CategoryCode, ItemNo)`
- `CreateItemAddon(var ItemAddOn; ItemNo)`
- `CreateItemAddonLine(var ItemAddOnLine; AddOnNo, ItemNo, UseUnitPrice, UnitPrice)`
- `CreateItemAddonLineOption(var ItemAddOnLineOpt; AddOnNo, LineNo, ItemNo, UseUnitPrice, UnitPrice)`
- `FinishKitchenOrder(KitchenOrderNo)`
- `SetupUserPOSUnit(POSUnitNo)`

## Execution Order

1. Extend `LibraryRestaurant` with all helpers first
2. Add VAT/pricing edge case tests
3. Add addon tests (single and array)
4. Add restaurant menu test
5. Extend kitchen order test with webhook verification
6. Run full test suite to verify
