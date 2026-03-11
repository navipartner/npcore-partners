# POS API Test Coverage Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add 7 new tests and extend 1 existing test to cover VAT/pricing edge cases, addon insertion scenarios, restaurant menu endpoints, and kitchen order webhook verification.

**Architecture:** Extend existing `POSAPITests.Codeunit.al` with new test procedures. Extend `LibraryRestaurant.Codeunit.al` with helper procedures for menu, addon, and kitchen order lifecycle management. All tests use the shared initialization pattern with codeunit isolation.

**Tech Stack:** AL (Business Central), BC23+ APIs, Test codeunits with `[Test]` attribute, Manual event subscribers for webhook verification.

---

## Task 1: Extend LibraryRestaurant with Item Addon Helpers

**Files:**
- Modify: `Test/src/Libraries/LibraryRestaurant.Codeunit.al:94-112`

**Step 1: Add CreateItemAddon procedure**

Add after line 111 (before the closing `#endif`):

```al
    procedure CreateItemAddon(var ItemAddOn: Record "NPR NpIa Item AddOn")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ItemAddOn.Init();
        ItemAddOn."No." := CopyStr(
            LibraryUtility.GenerateRandomCode(ItemAddOn.FieldNo("No."), DATABASE::"NPR NpIa Item AddOn"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NpIa Item AddOn", ItemAddOn.FieldNo("No.")));
        ItemAddOn.Description := 'Test Item AddOn';
        ItemAddOn.Enabled := true;
        ItemAddOn.Insert(true);
    end;

    procedure CreateItemAddonLine(var ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; AddOnNo: Code[20]; ItemNo: Code[20]; UseUnitPrice: Option; UnitPrice: Decimal)
    var
        ItemAddOnLine2: Record "NPR NpIa Item AddOn Line";
    begin
        ItemAddOnLine2.SetRange("AddOn No.", AddOnNo);
        if ItemAddOnLine2.FindLast() then;

        ItemAddOnLine.Init();
        ItemAddOnLine."AddOn No." := AddOnNo;
        ItemAddOnLine."Line No." := ItemAddOnLine2."Line No." + 10;
        ItemAddOnLine.Type := ItemAddOnLine.Type::Quantity;
        ItemAddOnLine."Item No." := ItemNo;
        ItemAddOnLine.Description := 'Test Addon Line';
        ItemAddOnLine."Use Unit Price" := UseUnitPrice;
        ItemAddOnLine."Unit Price" := UnitPrice;
        ItemAddOnLine.Quantity := 1;
        ItemAddOnLine.Insert(true);
    end;

    procedure LinkItemToAddon(var Item: Record Item; AddonNo: Code[20])
    begin
        Item."NPR Item AddOn No." := AddonNo;
        Item.Modify();
    end;
```

**Step 2: Run compile to verify syntax**

Run: `/bcdev compile -suppressWarnings`

Expected: Compilation succeeds

**Step 3: Commit**

```bash
git add Test/src/Libraries/LibraryRestaurant.Codeunit.al
git commit -m "feat(test): add item addon helpers to LibraryRestaurant"
```

---

## Task 2: Extend LibraryRestaurant with Menu Helpers

**Files:**
- Modify: `Test/src/Libraries/LibraryRestaurant.Codeunit.al`

**Step 1: Add menu creation procedures**

Add after the addon helpers:

```al
    procedure CreateMenu(var Menu: Record "NPR NPRE Menu"; RestaurantCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Menu.Init();
        Menu."Restaurant Code" := RestaurantCode;
        Menu.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(Menu.FieldNo(Code), DATABASE::"NPR NPRE Menu"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Menu", Menu.FieldNo(Code)));
        Menu.Active := true;
        Menu.Insert(true);
    end;

    procedure CreateMenuCategory(var MenuCategory: Record "NPR NPRE Menu Category"; RestaurantCode: Code[20]; MenuCode: Code[20]; CategoryCode: Code[20])
    begin
        MenuCategory.Init();
        MenuCategory."Restaurant Code" := RestaurantCode;
        MenuCategory."Menu Code" := MenuCode;
        MenuCategory."Category Code" := CategoryCode;
        MenuCategory.Insert(true);
    end;

    procedure CreateMenuItem(var MenuItem: Record "NPR NPRE Menu Item"; RestaurantCode: Code[20]; MenuCode: Code[20]; CategoryCode: Code[20]; ItemNo: Code[20])
    var
        MenuItem2: Record "NPR NPRE Menu Item";
    begin
        MenuItem2.SetRange("Restaurant Code", RestaurantCode);
        MenuItem2.SetRange("Menu Code", MenuCode);
        MenuItem2.SetRange("Category Code", CategoryCode);
        if MenuItem2.FindLast() then;

        MenuItem.Init();
        MenuItem."Restaurant Code" := RestaurantCode;
        MenuItem."Menu Code" := MenuCode;
        MenuItem."Category Code" := CategoryCode;
        MenuItem."Line No." := MenuItem2."Line No." + 10000;
        MenuItem."Item No." := ItemNo;
        MenuItem.Insert(true);
    end;

    procedure SetupUserPOSUnit(POSUnitNo: Code[10])
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := POSUnitNo;
        UserSetup.Modify();
    end;
```

**Step 2: Run compile to verify syntax**

Run: `/bcdev compile -suppressWarnings`

Expected: Compilation succeeds

**Step 3: Commit**

```bash
git add Test/src/Libraries/LibraryRestaurant.Codeunit.al
git commit -m "feat(test): add menu creation helpers to LibraryRestaurant"
```

---

## Task 3: Add FinishKitchenOrder Helper

**Files:**
- Modify: `Test/src/Libraries/LibraryRestaurant.Codeunit.al`

**Step 1: Add FinishKitchenOrder procedure**

Add after menu helpers:

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

**Step 2: Run compile to verify syntax**

Run: `/bcdev compile -suppressWarnings`

Expected: Compilation succeeds

**Step 3: Commit**

```bash
git add Test/src/Libraries/LibraryRestaurant.Codeunit.al
git commit -m "feat(test): add FinishKitchenOrder helper to LibraryRestaurant"
```

---

## Task 4: Add VAT Edge Case Test

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Add test for empty VAT Bus. Posting Gr. (Price)**

Add after `SaleLineOperations_AddUpdateDelete_PricesCorrect` test (around line 420):

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_EmptyVATBusPostGrPrice_PricesInclVAT_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemWithEmptyVATBusPG: Record Item;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Item with empty "VAT Bus. Posting Gr. (Price)" and Prices Including VAT=true can be sold
        Initialize();

        // [GIVEN] An item with Prices Including VAT=true but empty VAT Bus. Posting Gr. (Price)
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ItemWithEmptyVATBusPG, _POSUnit, _POSStore);
        ItemWithEmptyVATBusPG."Unit Price" := 100;
        ItemWithEmptyVATBusPG."Price Includes VAT" := true;
        ItemWithEmptyVATBusPG."VAT Bus. Posting Gr. (Price)" := '';
        ItemWithEmptyVATBusPG.Modify();

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add a sale line with item that has empty VAT Bus. Posting Gr. (Price)
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', ItemWithEmptyVATBusPG."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Sale line should be created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed for item with empty VAT Bus. Posting Gr. (Price)');

        // [WHEN] Add payment and complete
        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', 100);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Sale should complete successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');
    end;
```

**Step 2: Run compile to verify syntax**

Run: `/bcdev compile -suppressWarnings`

Expected: Compilation succeeds

**Step 3: Run the test**

Run: `/bcdev test -codeunit 85240 -method SaleLine_EmptyVATBusPostGrPrice_PricesInclVAT_Success`

Expected: Test passes (or fails if the reported bug exists - that's OK, we're documenting expected behavior)

**Step 4: Commit**

```bash
git add Test/src/Tests/API/POSAPITests.Codeunit.al
git commit -m "test: add VAT edge case test for empty VAT Bus. Posting Gr. (Price)"
```

---

## Task 5: Add Single Addon Tests

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Add global variables for addon testing**

Add to the var section at the top of the codeunit (around line 8-18):

```al
        _ItemAddon: Record "NPR NpIa Item AddOn";
        _AddonItem: Record Item;
        _AddonInitialized: Boolean;
```

**Step 2: Add InitializeAddon procedure**

Add after `InitializeRestaurant` procedure:

```al
    local procedure InitializeAddon()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        Initialize();

        if _AddonInitialized then
            exit;

        // Create addon item
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_AddonItem, _POSUnit, _POSStore);
        _AddonItem."Unit Price" := 25;
        _AddonItem.Modify();

        // Create item addon and link to main item
        LibraryRestaurant.CreateItemAddon(_ItemAddon);
        LibraryRestaurant.LinkItemToAddon(_Item, _ItemAddon."No.");

        _AddonInitialized := true;
        Commit();
    end;
```

**Step 3: Add test for addon with Use Unit Price = Always**

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceAlways_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Always uses addon's defined price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Always and Unit Price = 15
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 15);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon via separate endpoint
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should be created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        // [THEN] Verify addon has correct price (15, not 25 from item)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(15, AddonUnitPrice, 'Addon should use defined price (15), not item price (25)');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line in sale');
    end;
```

**Step 4: Run compile and test**

Run: `/bcdev compile -suppressWarnings`
Run: `/bcdev test -codeunit 85240 -method SaleLine_WithAddon_UseUnitPriceAlways_Success`

**Step 5: Commit**

```bash
git add Test/src/Tests/API/POSAPITests.Codeunit.al
git commit -m "test: add addon test with Use Unit Price = Always"
```

---

## Task 6: Add Addon Tests for Non-Zero Price Settings

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Add test for Use Unit Price = Non-Zero with price**

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceNonZero_WithPrice_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Non-Zero and non-zero price uses addon's price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Non-Zero and Unit Price = 10
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::"Non-Zero", 10);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should be created with price 10
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(10, AddonUnitPrice, 'Addon should use defined price (10)');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceNonZero_ZeroPrice_UsesItemPrice()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Non-Zero and zero price uses item's price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Non-Zero and Unit Price = 0
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::"Non-Zero", 0);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should use item price (25) since addon price is 0
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(25, AddonUnitPrice, 'Addon should use item price (25) when addon price is 0');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line');
    end;
```

**Step 2: Run compile and tests**

Run: `/bcdev compile -suppressWarnings`
Run: `/bcdev test -codeunit 85240 -method SaleLine_WithAddon_UseUnitPriceNonZero_WithPrice_Success`
Run: `/bcdev test -codeunit 85240 -method SaleLine_WithAddon_UseUnitPriceNonZero_ZeroPrice_UsesItemPrice`

**Step 3: Commit**

```bash
git add Test/src/Tests/API/POSAPITests.Codeunit.al
git commit -m "test: add addon tests for Non-Zero price settings"
```

---

## Task 7: Add Parent Item VAT Edge Case with Addon Test

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Add test for addon with parent having empty VAT Bus. Posting Gr. (Price)**

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_ParentEmptyVATBusPostGrPrice_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ParentItemWithEmptyVAT: Record Item;
        AddonForVATTest: Record Item;
        ItemAddonForVAT: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Addon can be inserted when parent item has empty VAT Bus. Posting Gr. (Price)
        Initialize();

        // [GIVEN] A parent item with empty VAT Bus. Posting Gr. (Price) and Prices Including VAT=true
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ParentItemWithEmptyVAT, _POSUnit, _POSStore);
        ParentItemWithEmptyVAT."Unit Price" := 100;
        ParentItemWithEmptyVAT."Price Includes VAT" := true;
        ParentItemWithEmptyVAT."VAT Bus. Posting Gr. (Price)" := '';
        ParentItemWithEmptyVAT.Modify();

        // [GIVEN] An addon item
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(AddonForVATTest, _POSUnit, _POSStore);
        AddonForVATTest."Unit Price" := 15;
        AddonForVATTest.Modify();

        // [GIVEN] Item addon linked to parent
        LibraryRestaurant.CreateItemAddon(ItemAddonForVAT);
        LibraryRestaurant.LinkItemToAddon(ParentItemWithEmptyVAT, ItemAddonForVAT."No.");
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, ItemAddonForVAT."No.", AddonForVATTest."No.",
            ItemAddOnLine."Use Unit Price"::Always, 15);

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent item with empty VAT Bus. Posting Gr. (Price)
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', ParentItemWithEmptyVAT."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon to this parent
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', ItemAddonForVAT."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should be created successfully despite parent's VAT configuration
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed even with parent having empty VAT Bus. Posting Gr. (Price)');
    end;
```

**Step 2: Run compile and test**

Run: `/bcdev compile -suppressWarnings`
Run: `/bcdev test -codeunit 85240 -method SaleLine_WithAddon_ParentEmptyVATBusPostGrPrice_Success`

**Step 3: Commit**

```bash
git add Test/src/Tests/API/POSAPITests.Codeunit.al
git commit -m "test: add addon test with parent having empty VAT Bus. Posting Gr. (Price)"
```

---

## Task 8: Add Inline Addons Array Test

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Add test for addons in same request as parent line**

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddonsArray_MultipleAddons_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        AddonsArray: JsonArray;
        Addon1: JsonObject;
        Addon2: JsonObject;
        ItemAddOnLine1: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLine2: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId1: Guid;
        AddonLineId2: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        AddonCount: Integer;
    begin
        // [SCENARIO] Multiple addons can be inserted in same request as parent line
        InitializeAddon();

        // [GIVEN] Two addon lines with different prices
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine1, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine1."Use Unit Price"::Always, 15);
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine2, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine2."Use Unit Price"::Always, 10);

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId1 := CreateGuid();
        AddonLineId2 := CreateGuid();

        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent line with addons array
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);

        Addon1.Add('lineId', FormatGuid(AddonLineId1));
        Addon1.Add('addonNo', _ItemAddon."No.");
        Addon1.Add('addonLineNo', Format(ItemAddOnLine1."Line No."));
        Addon1.Add('quantity', 1);
        AddonsArray.Add(Addon1);

        Addon2.Add('lineId', FormatGuid(AddonLineId2));
        Addon2.Add('addonNo', _ItemAddon."No.");
        Addon2.Add('addonLineNo', Format(ItemAddOnLine2."Line No."));
        Addon2.Add('quantity', 2);
        AddonsArray.Add(Addon2);

        Body.Add('addons', AddonsArray);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Sale line with addons should be created
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line with addons array should succeed');

        // [THEN] Verify 3 lines total (1 parent + 2 addons)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        Assert.AreEqual(3, SaleLinesArray.Count(), 'Should have 3 sale lines (1 parent + 2 addons)');

        // Count addon lines
        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then
                AddonCount += 1;
        end;
        Assert.AreEqual(2, AddonCount, 'Should have 2 addon lines');
    end;
```

**Step 2: Run compile and test**

Run: `/bcdev compile -suppressWarnings`
Run: `/bcdev test -codeunit 85240 -method SaleLine_WithAddonsArray_MultipleAddons_Success`

**Step 3: Commit**

```bash
git add Test/src/Tests/API/POSAPITests.Codeunit.al
git commit -m "test: add inline addons array test"
```

---

## Task 9: Add Restaurant Menu Test

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Add global variables for menu testing**

Add to the var section:

```al
        _Menu: Record "NPR NPRE Menu";
        _MenuInitialized: Boolean;
```

**Step 2: Add InitializeMenu procedure**

```al
    local procedure InitializeMenu()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
    begin
        InitializeRestaurant();
        InitializeAddon();

        if _MenuInitialized then
            exit;

        // Get the restaurant from the POS unit's profile
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        // Create menu and category
        LibraryRestaurant.CreateMenu(_Menu, Restaurant.Code);

        // Setup user's POS unit for menu pricing
        LibraryRestaurant.SetupUserPOSUnit(_POSUnit."No.");

        _MenuInitialized := true;
        Commit();
    end;
```

**Step 3: Add restaurant menu test**

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantMenu_WithItemsAndAddons_ReturnsStructure()
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
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
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
        AddonItemsArray: JsonArray;
    begin
        // [SCENARIO] Menu endpoint returns items with their addons
        InitializeMenu();

        // [GIVEN] Menu has a category with an item that has addons
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'MAIN');
        LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'MAIN', _Item."No.");

        // Ensure addon line exists
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 20);

        // [WHEN] Get menu
        Response := LibraryNPRetailAPI.CallApi('GET',
            '/restaurant/' + Format(_Menu.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
            Body, QueryParams, Headers);

        // [THEN] Menu should be returned with structure
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        // [THEN] Should have menuContent with categories
        Assert.IsTrue(ResponseBody.Get('menuContent', JToken), 'Response should have menuContent');
        MenuContent := JToken.AsObject();

        Assert.IsTrue(MenuContent.Get('categories', JToken), 'menuContent should have categories');
        CategoriesArray := JToken.AsArray();
        Assert.IsTrue(CategoriesArray.Count() > 0, 'Should have at least one category');

        // [THEN] Category should have items
        CategoriesArray.Get(0, CategoryToken);
        CategoryObj := CategoryToken.AsObject();
        Assert.IsTrue(CategoryObj.Get('items', JToken), 'Category should have items');
        ItemsArray := JToken.AsArray();
        Assert.IsTrue(ItemsArray.Count() > 0, 'Should have at least one item');

        // [THEN] Item should have addonItems array
        ItemsArray.Get(0, ItemToken);
        ItemObj := ItemToken.AsObject();
        Assert.IsTrue(ItemObj.Get('addonItems', JToken), 'Item should have addonItems');
        AddonItemsArray := JToken.AsArray();
        Assert.IsTrue(AddonItemsArray.Count() > 0, 'Should have at least one addon');
    end;
```

**Step 4: Run compile and test**

Run: `/bcdev compile -suppressWarnings`
Run: `/bcdev test -codeunit 85240 -method RestaurantMenu_WithItemsAndAddons_ReturnsStructure`

**Step 5: Commit**

```bash
git add Test/src/Tests/API/POSAPITests.Codeunit.al
git commit -m "test: add restaurant menu endpoint test with addons"
```

---

## Task 10: Extend Kitchen Order Test with Webhook Verification

**Files:**
- Modify: `Test/src/Tests/API/POSAPITests.Codeunit.al`

**Step 1: Update CompleteSale_WithKitchenRequest_TransfersCustomerDetails test**

Find the existing test (around line 424) and extend it:

```al
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_WithKitchenRequest_TransfersCustomerDetails()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        RestaurantWebhookTestSub: Codeunit "NPR Restaurant Webhook TestSub";
        Response: JsonObject;
        Body: JsonObject;
        KitchenRequest: JsonObject;
        CustomerDetails: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        KitchenOrderNoText: Text;
        KitchenOrderNo: BigInteger;
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Complete sale with kitchenRequest transfers customer details to kitchen order and triggers webhook
        InitializeRestaurant();

        // [GIVEN] A new sale with item
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

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [GIVEN] Webhook subscriber is bound
        RestaurantWebhookTestSub.Reset();
        BindSubscription(RestaurantWebhookTestSub);

        // [WHEN] Complete with kitchenRequest containing customer details
        Clear(Body);
        CustomerDetails.Add('name', 'John Doe');
        CustomerDetails.Add('phoneNo', '+1234567890');
        CustomerDetails.Add('email', 'john@example.com');
        KitchenRequest.Add('seatingCode', _Seating.Code);
        KitchenRequest.Add('noOfGuests', 2);
        KitchenRequest.Add('customerDetails', CustomerDetails);
        Body.Add('kitchenRequest', KitchenRequest);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale with kitchen request should succeed');

        // [THEN] Response contains kitchenOrderNo
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('kitchenOrderNo', JToken), 'Response should contain kitchenOrderNo');
        KitchenOrderNoText := JToken.AsValue().AsText();
        Evaluate(KitchenOrderNo, KitchenOrderNoText);
        Assert.AreNotEqual(0, KitchenOrderNo, 'Kitchen order number should not be 0');

        // [THEN] Waiter pad has customer details
        WaiterPad.SetRange("Seating Code", _Seating.Code);
        Assert.IsTrue(WaiterPad.FindLast(), 'Waiter pad should be created');
        Assert.AreEqual('John Doe', WaiterPad.Description, 'Waiter pad description should have customer name');
        Assert.AreEqual('+1234567890', WaiterPad."Customer Phone No.", 'Waiter pad should have phone number');
        Assert.AreEqual('john@example.com', WaiterPad."Customer E-Mail", 'Waiter pad should have email');
        Assert.AreEqual(2, WaiterPad."No. of Guests", 'Waiter pad should have correct number of guests');

        // [WHEN] Kitchen order is finished (marked as served)
        LibraryRestaurant.FinishKitchenOrder(KitchenOrderNo);

        // [THEN] Webhook should have been invoked
        Assert.IsTrue(RestaurantWebhookTestSub.WasWebhookInvoked(), 'Webhook should be invoked when kitchen order is ready for serving');
        Assert.AreEqual(KitchenOrderNo, RestaurantWebhookTestSub.GetLastKitchenOrderId(), 'Webhook should receive correct kitchen order ID');

        UnbindSubscription(RestaurantWebhookTestSub);
    end;
```

**Step 2: Run compile and test**

Run: `/bcdev compile -suppressWarnings`
Run: `/bcdev test -codeunit 85240 -method CompleteSale_WithKitchenRequest_TransfersCustomerDetails`

**Step 3: Commit**

```bash
git add Test/src/Tests/API/POSAPITests.Codeunit.al
git commit -m "test: extend kitchen order test with webhook verification"
```

---

## Task 11: Run Full Test Suite

**Step 1: Compile everything**

Run: `/bcdev compile -suppressWarnings`

Expected: Compilation succeeds

**Step 2: Publish to BC**

Run: `/bcdev publish`

Expected: Publish succeeds

**Step 3: Run all POS API tests**

Run: `/bcdev test -codeunit 85240`

Expected: All tests pass (note: some may fail if they expose actual bugs - document which ones)

**Step 4: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: address test issues found during full suite run"
```
