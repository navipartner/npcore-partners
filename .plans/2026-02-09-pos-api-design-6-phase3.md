# POS API Design 6 - Phase 3 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add EFT BIN mapping test, enforce UNATTENDED-only POS units for the POS Sale API, and add menu item status enum + menu lastUpdated tracking with event subscribers.

**Architecture:** Three independent feature tracks: (1) EFT mapping test adds BIN setup helpers and validates the payment type remapping flow, (2) UNATTENDED enforcement adds a guard in CreateSale and fixes all existing tests, (3) Menu enhancements add a status enum on menu items, a lastUpdated DateTime on menu headers with subscriber-driven updates, and returns both in the API JSON. All changes stay behind the existing `#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)` preprocessor guard.

**Tech Stack:** AL (Business Central), Fern YAML (API docs), bcdev CLI (compile/publish/test)

---

## Task 1: Enforce UNATTENDED-only POS Units in POS Sale API

This must be done first because it changes Initialize() which all subsequent tests depend on.

**Files:**
- Modify: `Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al:490-505` (CreateSale procedure)
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al:1504-1541` (Initialize procedure)

**Step 1: Add UNATTENDED enforcement in CreateSale**

In `APIPOSSale.Codeunit.al`, change the `CreateSale` procedure. Currently the UNATTENDED check only validates the cleanup JQ. We need to enforce that the POS Unit type MUST be UNATTENDED:

```al
procedure CreateSale(SaleSystemId: Guid; POSUnitNo: Code[10])
var
    POSUnit: Record "NPR POS Unit";
    POSSession: Codeunit "NPR POS Session";
begin
    POSUnit.Get(POSUnitNo);
    POSUnit.TestField(Status, POSUnit.Status::OPEN);
    POSUnit.TestField("POS Type", POSUnit."POS Type"::UNATTENDED);

    VerifyCleanupJobIsScheduled();

    POSSession.ConstructFromWebserviceSession(false, POSUnit."No.", '');
    POSSession.StartTransaction(SaleSystemId);
end;
```

Key changes:
- Add `POSUnit.TestField("POS Type", POSUnit."POS Type"::UNATTENDED)` — enforces only UNATTENDED units
- Remove the `if POSUnit."POS Type" = UNATTENDED then` conditional — now always validates cleanup JQ since type is guaranteed UNATTENDED

**Step 2: Fix Initialize() in POSAPITests**

After creating the POS Unit, set its type to UNATTENDED and create the cleanup JQ entry:

```al
local procedure Initialize()
var
    NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    LibrarySales: Codeunit "Library - Sales";
    POSPostingProfile: Record "NPR POS Posting Profile";
    POSSetup: Record "NPR POS Setup";
begin
    if _Initialized then
        exit;

    LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');
    LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Restaurant');

    NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
    NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
    NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
    NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
    NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);

    _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
    _POSUnit.Modify();

    NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
    _Item."Unit Price" := 100;
    _Item.Modify();

    NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item2, _POSUnit, _POSStore);
    _Item2."Unit Price" := 50;
    _Item2.Modify();

    _CashPaymentMethod.SetRange("Processing Type", _CashPaymentMethod."Processing Type"::CASH);
    _CashPaymentMethod.FindFirst();

    NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_EFTPaymentMethod, _EFTPaymentMethod."Processing Type"::EFT, '', false);

    LibrarySales.CreateSalesperson(_Salesperson);

    CreateCleanupJobQueueEntry();

    _Initialized := true;
    Commit();
end;
```

Key changes:
- Set `_POSUnit."POS Type" := UNATTENDED` + `Modify()` right after creating the unit
- Call `CreateCleanupJobQueueEntry()` in Initialize so every test has it
- This means the two cleanup tests no longer need to set POS Type or create JQ entry themselves — simplify them

**Step 3: Simplify cleanup tests**

In `CleanupJob_UnpaidSales_AreDeleted` and `CleanupJob_PaidEFTSales_AreParked`, remove the lines that set POS Type and create cleanup JQ entry since Initialize() now handles this:

Remove from both tests:
```al
// Remove these lines:
_POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
_POSUnit.Modify();
CreateCleanupJobQueueEntry();
Commit();
```

The `Commit()` before WorkDate manipulation is still needed after creating the sale.

**Step 4: Add negative test for non-UNATTENDED unit**

Add a new test `CreateSale_NonUnattendedUnit_ShouldFail`:

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure CreateSale_NonUnattendedUnit_ShouldFail()
var
    LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    Assert: Codeunit Assert;
    Response: JsonObject;
    Body: JsonObject;
    SaleId: Guid;
    QueryParams: Dictionary of [Text, Text];
    Headers: Dictionary of [Text, Text];
    NonUnattendedUnit: Record "NPR POS Unit";
    POSPostingProfile: Record "NPR POS Posting Profile";
begin
    // [SCENARIO] Creating a sale on a non-UNATTENDED POS unit should fail
    Initialize();

    // [GIVEN] A POS Unit with default type (not UNATTENDED)
    POSPostingProfile.FindFirst();
    NPRLibraryPOSMasterData.CreatePOSUnit(NonUnattendedUnit, _POSStore.Code, POSPostingProfile.Code);
    NonUnattendedUnit.Status := NonUnattendedUnit.Status::OPEN;
    NonUnattendedUnit.Modify();
    Commit();

    // [GIVEN] A new sale ID
    SaleId := CreateGuid();

    // [WHEN] Try to create a sale on non-UNATTENDED unit
    Body.Add('posUnit', NonUnattendedUnit."No.");

    // [THEN] Should fail because POS Unit type is not UNATTENDED
    asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
    Assert.ExpectedError('POS Type');
end;
```

**Step 5: Compile and verify**

Run: `bcdev symbols download && bcdev compile -suppressWarnings`

---

## Task 2: Add EFT BIN Mapping Test

**Files:**
- Modify: `Test/src/Libraries/LibraryEFT.Codeunit.al` (add BIN setup helpers)
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al` (add mapping test)

**Step 1: Add BIN range setup helpers to LibraryEFT**

Add three new procedures to `LibraryEFT.Codeunit.al`:

```al
procedure CreateBINGroup(var EFTBINGroup: Record "NPR EFT BIN Group"; GroupCode: Code[10]; Description: Text[100]; Priority: Integer)
begin
    EFTBINGroup.Init();
    EFTBINGroup.Code := GroupCode;
    EFTBINGroup.Description := Description;
    EFTBINGroup.Priority := Priority;
    EFTBINGroup.Insert(true);
end;

procedure CreateBINRange(GroupCode: Code[10]; BINFrom: BigInteger; BINTo: BigInteger)
var
    EFTBINRange: Record "NPR EFT BIN Range";
begin
    EFTBINRange.Init();
    EFTBINRange."BIN from" := BINFrom;
    EFTBINRange."BIN to" := BINTo;
    EFTBINRange.Validate("BIN Group Code", GroupCode);
    EFTBINRange.Insert(true);
end;

procedure CreateBINGroupPaymentLink(GroupCode: Code[10]; PaymentMethodCode: Code[10])
var
    EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
begin
    EFTBINGroupPaymentLink.Init();
    EFTBINGroupPaymentLink."Group Code" := GroupCode;
    EFTBINGroupPaymentLink."Location Code" := '';
    EFTBINGroupPaymentLink."From Payment Type POS" := '';
    EFTBINGroupPaymentLink."Payment Type POS" := PaymentMethodCode;
    EFTBINGroupPaymentLink.Insert(true);
end;
```

**Step 2: Add EFT BIN mapping test to POSAPITests**

Add new variables to the codeunit var section:
```al
_VisaPaymentMethod: Record "NPR POS Payment Method";
_MastercardPaymentMethod: Record "NPR POS Payment Method";
_EFTMappingInitialized: Boolean;
```

Add initialization:
```al
local procedure InitializeEFTMapping()
var
    NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    LibraryEFT: Codeunit "NPR Library - EFT";
    EFTBINGroup: Record "NPR EFT BIN Group";
begin
    Initialize();

    if _EFTMappingInitialized then
        exit;

    // Create VISA and Mastercard payment methods
    NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_VisaPaymentMethod, _VisaPaymentMethod."Processing Type"::EFT, '', false);
    NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_MastercardPaymentMethod, _MastercardPaymentMethod."Processing Type"::EFT, '', false);

    // Create VISA BIN Group with BIN range 400000-499999
    LibraryEFT.CreateBINGroup(EFTBINGroup, 'VISA', 'Visa', 1);
    LibraryEFT.CreateBINRange('VISA', 400000, 499999);
    LibraryEFT.CreateBINGroupPaymentLink('VISA', _VisaPaymentMethod.Code);

    // Create Mastercard BIN Group with BIN range 510000-559999
    LibraryEFT.CreateBINGroup(EFTBINGroup, 'MC', 'Mastercard', 2);
    LibraryEFT.CreateBINRange('MC', 510000, 559999);
    LibraryEFT.CreateBINGroupPaymentLink('MC', _MastercardPaymentMethod.Code);

    _EFTMappingInitialized := true;
    Commit();
end;
```

Add test:
```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure EFTPayment_BINMapping_MapsToCorrectPaymentMethod()
var
    LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    Assert: Codeunit Assert;
    Response: JsonObject;
    Body: JsonObject;
    SaleId: Guid;
    SaleLineId: Guid;
    PaymentLineId: Guid;
    QueryParams: Dictionary of [Text, Text];
    Headers: Dictionary of [Text, Text];
    EFTTransactionRequest: Record "NPR EFT Transaction Request";
begin
    // [SCENARIO] EFT payment with a VISA BIN maps to the VISA payment method
    InitializeEFTMapping();

    // [GIVEN] A sale with an item
    SaleId := CreateGuid();
    SaleLineId := CreateGuid();
    PaymentLineId := CreateGuid();

    Body.Add('posUnit', _POSUnit."No.");
    Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
    Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

    Clear(Body);
    Body.Add('type', 'Item');
    Body.Add('code', _Item."No.");
    Body.Add('quantity', 1);
    Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
    Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

    // [WHEN] Add EFT payment with a masked VISA card number (BIN 411111)
    Clear(Body);
    Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
    Body.Add('paymentType', 'EFT');
    Body.Add('amount', _Item."Unit Price");
    Body.Add('maskedCardNo', '411111******1234');
    Body.Add('pspReference', 'PSP-BIN-TEST');
    Body.Add('success', true);
    Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
    Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment should succeed');

    // [THEN] EFT Transaction Request should be remapped to VISA payment method
    EFTTransactionRequest.SetRange("Register No.", _POSUnit."No.");
    EFTTransactionRequest.SetRange("Card Number", '411111******1234');
    Assert.IsTrue(EFTTransactionRequest.FindFirst(), 'EFT Transaction Request should exist');
    Assert.AreEqual(_EFTPaymentMethod.Code, EFTTransactionRequest."Original POS Payment Type Code",
        'Original payment type should be the generic EFT method');
    Assert.AreEqual(_VisaPaymentMethod.Code, EFTTransactionRequest."POS Payment Type Code",
        'Payment type should be remapped to VISA');
end;
```

**Step 3: Compile and verify**

Run: `bcdev compile -suppressWarnings`

---

## Task 3: Add Menu Item Status Enum

**Files:**
- Create: `Application/src/Restaurant/Menu/_public/NPREMenuItemStatus.Enum.al` (enum 6014578)
- Modify: `Application/src/Restaurant/Menu/NPREMenuItem.Table.al` (add Status field 60)
- Modify: `Application/src/_API_SERVICES/restaurant/APIRestaurantMenu.Codeunit.al` (return status in JSON)
- Modify: `fern/apis/default/definition/restaurant/types-restaurant.yml` (add status to MenuItem type)

**Step 1: Create the enum**

Create file `Application/src/Restaurant/Menu/_public/NPREMenuItemStatus.Enum.al`:

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
enum 6014578 "NPR NPRE Menu Item Status"
{
    Access = Public;
    Extensible = false;
    Caption = 'Menu Item Status';

    value(0; Active)
    {
        Caption = 'Active';
    }
    value(1; "Inactive Visible")
    {
        Caption = 'Inactive (visible)';
    }
    value(2; "Inactive Hidden")
    {
        Caption = 'Inactive (hidden)';
    }
}
#endif
```

**Step 2: Add Status field to Menu Item table**

In `NPREMenuItem.Table.al`, add after field 50 (Sort Key):

```al
field(60; Status; Enum "NPR NPRE Menu Item Status")
{
    Caption = 'Status';
    DataClassification = CustomerContent;
    InitValue = Active;
}
```

**Step 3: Return status in menu item JSON**

In `APIRestaurantMenu.Codeunit.al`, in the `BuildMenuItem` procedure, add after `.AddProperty('sortKey', MenuItem."Sort Key")`:

```al
.AddProperty('status', Format(MenuItem.Status))
```

**Step 4: Update Fern types**

In `types-restaurant.yml`, add to MenuItem properties after `sortKey`:

```yaml
      status:
        type: optional<MenuItemStatus>
        docs: Item status (Active, Inactive Visible, Inactive Hidden). Inactive Visible items are shown but cannot be ordered. Inactive Hidden items are not shown.
```

And add the enum type:

```yaml
  MenuItemStatus:
    docs: Menu item availability status
    enum:
      - Active
      - Inactive Visible
      - Inactive Hidden
```

**Step 5: Compile and verify**

Run: `bcdev compile -suppressWarnings`

---

## Task 4: Add Menu Last Updated DateTime + Event Subscribers

**Files:**
- Modify: `Application/src/Restaurant/Menu/NPREMenu.Table.al` (add "Last Updated" field 110)
- Create: `Application/src/Restaurant/Menu/NPREMenuLastUpdatedSub.Codeunit.al` (codeunit 6151026)
- Modify: `Application/src/_API_SERVICES/restaurant/APIRestaurantMenu.Codeunit.al` (return lastUpdated in GetMenus and GetMenu)
- Modify: `fern/apis/default/definition/restaurant/types-restaurant.yml` (add lastUpdated to MenuSummary and Menu)
- Modify: `fern/apis/default/definition/restaurant/menu.yml` (add lastUpdated to examples)

**Step 1: Add "Last Updated" field to Menu table**

In `NPREMenu.Table.al`, add after field 100 (Active):

```al
field(110; "Last Updated"; DateTime)
{
    Caption = 'Last Updated';
    DataClassification = CustomerContent;
}
```

**Step 2: Create subscriber codeunit**

Create `Application/src/Restaurant/Menu/NPREMenuLastUpdatedSub.Codeunit.al`:

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151026 "NPR NPRE Menu Last Updated Sub"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterInsertEvent, '', false, false)]
    local procedure MenuCategoryOnAfterInsert(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterModifyEvent, '', false, false)]
    local procedure MenuCategoryOnAfterModify(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuCategoryOnAfterDelete(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterInsertEvent, '', false, false)]
    local procedure MenuItemOnAfterInsert(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterModifyEvent, '', false, false)]
    local procedure MenuItemOnAfterModify(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuItemOnAfterDelete(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterInsertEvent, '', false, false)]
    local procedure MenuCatTransOnAfterInsert(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterModifyEvent, '', false, false)]
    local procedure MenuCatTransOnAfterModify(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuCatTransOnAfterDelete(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    local procedure UpdateMenuLastUpdated(RestaurantCode: Code[20]; MenuCode: Code[20])
    var
        Menu: Record "NPR NPRE Menu";
    begin
        if (RestaurantCode = '') or (MenuCode = '') then
            exit;
        if not Menu.Get(RestaurantCode, MenuCode) then
            exit;
        Menu."Last Updated" := CurrentDateTime;
        Menu.Modify();
    end;
}
#endif
```

Note: Menu Item Translation uses "External System Id" (links to MenuItem.SystemId) not restaurant/menu code directly. We need to look up the parent MenuItem to find the restaurant/menu code. Let me handle that differently.

Actually looking at the Menu Item Translation table - it links via "External System Id" to MenuItem.SystemId. We need to resolve the parent menu item first.

Update the Menu Item Translation subscribers:

```al
[EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterInsertEvent, '', false, false)]
local procedure MenuItemTransOnAfterInsert(var Rec: Record "NPR NPRE Menu Item Translation")
begin
    UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterModifyEvent, '', false, false)]
local procedure MenuItemTransOnAfterModify(var Rec: Record "NPR NPRE Menu Item Translation")
begin
    UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
end;

[EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterDeleteEvent, '', false, false)]
local procedure MenuItemTransOnAfterDelete(var Rec: Record "NPR NPRE Menu Item Translation")
begin
    UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
end;

local procedure UpdateMenuLastUpdatedFromMenuItemTranslation(MenuItemTranslation: Record "NPR NPRE Menu Item Translation")
var
    MenuItem: Record "NPR NPRE Menu Item";
begin
    MenuItem.SetRange(SystemId, MenuItemTranslation."External System Id");
    if MenuItem.FindFirst() then
        UpdateMenuLastUpdated(MenuItem."Restaurant Code", MenuItem."Menu Code");
end;
```

**Step 3: Return lastUpdated in GetMenus JSON**

In `APIRestaurantMenu.Codeunit.al`, in the `GetMenus` procedure, add `.AddProperty('lastUpdated', Menu."Last Updated")` after `.AddProperty('active', Menu.Active)`:

```al
JsonArray.StartObject('')
    .AddProperty('id', Format(Menu.SystemId, 0, 4).ToLower())
    .AddProperty('code', Menu.Code)
    .AddProperty('startTime', Menu."Start Time")
    .AddProperty('endTime', Menu."End Time")
    .AddProperty('timezone', Menu.Timezone)
    .AddProperty('active', Menu.Active)
    .AddProperty('lastUpdated', Menu."Last Updated")
    .EndObject();
```

Also add it in the `GetMenu` procedure:

```al
Json.StartObject('')
    .AddProperty('id', Format(Menu.SystemId, 0, 4).ToLower())
    .AddProperty('code', Menu.Code)
    .AddProperty('startTime', Menu."Start Time")
    .AddProperty('endTime', Menu."End Time")
    .AddProperty('timezone', Menu.Timezone)
    .AddProperty('active', Menu.Active)
    .AddProperty('lastUpdated', Menu."Last Updated");
```

**Step 4: Update Fern types**

In `types-restaurant.yml`, add to both `MenuSummary` and `Menu` properties:

```yaml
      lastUpdated:
        type: optional<datetime>
        docs: When the menu or any of its child content was last modified (UTC)
```

In `menu.yml`, add to the example responses:

For listMenus example, add: `lastUpdated: "2026-01-15T14:30:00Z"`
For getMenu example, add: `lastUpdated: "2026-01-15T14:30:00Z"`

**Step 5: Compile and verify**

Run: `bcdev compile -suppressWarnings`

---

## Task 5: Add Tests for Menu Features

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Add test for menu item status in JSON**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure RestaurantMenu_MenuItemStatus_ReturnsInJSON()
var
    LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    Assert: Codeunit Assert;
    Response: JsonObject;
    Body: JsonObject;
    MenuCategory: Record "NPR NPRE Menu Category";
    MenuItem: Record "NPR NPRE Menu Item";
    MenuItemInactive: Record "NPR NPRE Menu Item";
    Restaurant: Record "NPR NPRE Restaurant";
    POSRestProfile: Record "NPR POS NPRE Rest. Profile";
    QueryParams: Dictionary of [Text, Text];
    Headers: Dictionary of [Text, Text];
    ResponseBody: JsonObject;
    JToken: JsonToken;
    MenuContent: JsonObject;
    CategoriesArray: JsonArray;
    CategoryToken: JsonToken;
    CategoryObj: JsonObject;
    ItemsArray: JsonArray;
    ItemToken: JsonToken;
    ItemObj: JsonObject;
    i: Integer;
    FoundInactiveVisible: Boolean;
begin
    // [SCENARIO] Menu items return their status in the JSON response
    InitializeMenu();

    POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
    Restaurant.Get(POSRestProfile."Restaurant Code");
    LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'STATUS');

    // [GIVEN] An active menu item and an inactive (visible) menu item
    LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'STATUS', _Item."No.");

    LibraryRestaurant.CreateMenuItem(MenuItemInactive, Restaurant.Code, _Menu.Code, 'STATUS', _Item2."No.");
    MenuItemInactive.Status := MenuItemInactive.Status::"Inactive Visible";
    MenuItemInactive.Modify();

    // [WHEN] Get the menu
    Response := LibraryNPRetailAPI.CallApi('GET',
        '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
        Body, QueryParams, Headers);

    // [THEN] Menu should contain status fields
    Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
    ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
    ResponseBody.Get('menuContent', JToken);
    MenuContent := JToken.AsObject();
    MenuContent.Get('categories', JToken);
    CategoriesArray := JToken.AsArray();

    // Find the STATUS category
    for i := 0 to CategoriesArray.Count() - 1 do begin
        CategoriesArray.Get(i, CategoryToken);
        CategoryObj := CategoryToken.AsObject();
        CategoryObj.Get('code', JToken);
        if JToken.AsValue().AsText() = 'STATUS' then begin
            CategoryObj.Get('items', JToken);
            ItemsArray := JToken.AsArray();
            Assert.AreEqual(2, ItemsArray.Count(), 'Should have 2 items in STATUS category');

            // Check that inactive visible item has correct status
            ItemsArray.Get(1, ItemToken);
            ItemObj := ItemToken.AsObject();
            ItemObj.Get('status', JToken);
            if JToken.AsValue().AsText() = 'Inactive Visible' then
                FoundInactiveVisible := true;
        end;
    end;
    Assert.IsTrue(FoundInactiveVisible, 'Should find item with Inactive Visible status');
end;
```

**Step 2: Add test for menu lastUpdated tracking**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure RestaurantMenu_LastUpdated_UpdatesOnMenuItemChange()
var
    LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    Assert: Codeunit Assert;
    Response: JsonObject;
    Body: JsonObject;
    MenuCategory: Record "NPR NPRE Menu Category";
    MenuItem: Record "NPR NPRE Menu Item";
    Restaurant: Record "NPR NPRE Restaurant";
    POSRestProfile: Record "NPR POS NPRE Rest. Profile";
    QueryParams: Dictionary of [Text, Text];
    Headers: Dictionary of [Text, Text];
    ResponseBody: JsonObject;
    JToken: JsonToken;
    MenuArr: JsonArray;
    MenuObj: JsonObject;
    Menu: Record "NPR NPRE Menu";
    LastUpdatedBefore: DateTime;
begin
    // [SCENARIO] Menu lastUpdated field updates when a menu item is inserted
    InitializeMenu();

    POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
    Restaurant.Get(POSRestProfile."Restaurant Code");

    // [GIVEN] Record the lastUpdated before any changes
    Menu.Get(Restaurant.Code, _Menu.Code);
    LastUpdatedBefore := Menu."Last Updated";

    // Allow time to pass so CurrentDateTime is different
    Sleep(100);

    // [WHEN] Insert a new category and item under the menu
    LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'UPDATED');
    LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'UPDATED', _Item."No.");

    // [THEN] Menu Last Updated should be updated
    Menu.Get(Restaurant.Code, _Menu.Code);
    Assert.IsTrue(Menu."Last Updated" > LastUpdatedBefore, 'Menu Last Updated should increase after inserting a category/item');

    // [THEN] API returns lastUpdated
    Response := LibraryNPRetailAPI.CallApi('GET',
        '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu',
        Body, QueryParams, Headers);
    Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'List menus should succeed');
end;
```

**Step 3: Compile and verify**

Run: `bcdev compile -suppressWarnings`

---

## Task 6: Compile, Publish, and Run Tests

**Step 1: Download symbols and compile both apps**

```bash
bcdev symbols download
bcdev compile -suppressWarnings
```

If there are compilation errors in our changed files, fix them.

**Step 2: Publish both apps**

```bash
bcdev publish
```

**Step 3: Run POS API tests**

```bash
bcdev test -codeunit 85157
```

**Step 4: Run restaurant API tests (if separate codeunit exists)**

Check if there's a separate restaurant test codeunit and run it too.

**Step 5: Fix any test failures and re-run**

If tests fail, fix the issues and re-run until all pass.

---

## Summary of New Objects

| Type | ID | Name | Location |
|------|-----|------|----------|
| Enum | 6014578 | NPR NPRE Menu Item Status | Application/src/Restaurant/Menu/_public/ |
| Codeunit | 6151026 | NPR NPRE Menu Last Updated Sub | Application/src/Restaurant/Menu/ |
| Table Field | 60 on 6151269 | Status | NPR NPRE Menu Item |
| Table Field | 110 on 6151265 | Last Updated | NPR NPRE Menu |

## Files Modified

| File | Change |
|------|--------|
| APIPOSSale.Codeunit.al | Enforce UNATTENDED-only, remove conditional |
| POSAPITests.Codeunit.al | Fix Initialize(), add 4 new tests, simplify cleanup tests |
| LibraryEFT.Codeunit.al | Add BIN setup helpers |
| NPREMenuItem.Table.al | Add Status field |
| NPREMenu.Table.al | Add Last Updated field |
| APIRestaurantMenu.Codeunit.al | Return status + lastUpdated in JSON |
| types-restaurant.yml | Add MenuItemStatus enum, lastUpdated, status |
| menu.yml | Update examples |
| NPREMenuItemStatus.Enum.al | New enum file |
| NPREMenuLastUpdatedSub.Codeunit.al | New subscriber codeunit |
