codeunit 85270 "NPR Period Disc. Line Filters"
{
    // [Feature] Periodic Discount - variant scoped flow fields
    Subtype = Test;
    Permissions = TableData "Item Ledger Entry" = rimd,
                  TableData "Purchase Line" = rimd;

    var
        _Assert: Codeunit Assert;
        _LibraryInventory: Codeunit "Library - Inventory";
        _LibraryUtility: Codeunit "Library - Utility";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InventoryIsVariantSpecificWhenVariantCodeSet()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        // [SCENARIO] When Variant Code is set on a period discount line, Inventory only includes item ledger entries of that variant

        // [GIVEN] Item with two variants and inventory: 2 on variant A, 3 on variant B, 4 without variant
        CreateItemWithTwoVariantsAndInventory(Item, VariantA, VariantB);

        // [GIVEN] Period discount line for variant A
        CreatePeriodDiscountLine(PeriodDiscountLine, CreatePeriodDiscount(), Item."No.", VariantA.Code);

        // [WHEN] Applying the variant filter and calculating Inventory
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields(Inventory);

        // [THEN] Only variant A inventory is included
        _Assert.AreEqual(2, PeriodDiscountLine.Inventory, 'Inventory must only include item ledger entries of the line''s variant');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InventoryIncludesAllVariantsWhenVariantCodeBlank()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        // [SCENARIO] When Variant Code is blank on a period discount line, Inventory keeps the total across all variants and non-variant entries

        // [GIVEN] Item with two variants and inventory: 2 on variant A, 3 on variant B, 4 without variant
        CreateItemWithTwoVariantsAndInventory(Item, VariantA, VariantB);

        // [GIVEN] Period discount line without variant code
        CreatePeriodDiscountLine(PeriodDiscountLine, CreatePeriodDiscount(), Item."No.", '');

        // [WHEN] Applying the variant filter and calculating Inventory
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields(Inventory);

        // [THEN] All item ledger entries are included
        _Assert.AreEqual(9, PeriodDiscountLine.Inventory, 'Inventory must include all item ledger entries when the line has no variant code');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QtyOnPurchOrderIsVariantSpecificWhenVariantCodeSet()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        // [SCENARIO] When Variant Code is set on a period discount line, Quantity On Purchase Order only includes purchase order lines of that variant

        // [GIVEN] Item with two variants
        _LibraryInventory.CreateItem(Item);
        _LibraryInventory.CreateItemVariant(VariantA, Item."No.");
        _LibraryInventory.CreateItemVariant(VariantB, Item."No.");

        // [GIVEN] Outstanding purchase order lines: 5 for variant A, 7 without variant
        MockPurchaseOrderLine(Item."No.", VariantA.Code, 5);
        MockPurchaseOrderLine(Item."No.", '', 7);

        // [GIVEN] Period discount line for variant A
        CreatePeriodDiscountLine(PeriodDiscountLine, CreatePeriodDiscount(), Item."No.", VariantA.Code);

        // [WHEN] Applying the variant filter and calculating Quantity On Purchase Order
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields("Quantity On Purchase Order");

        // [THEN] Only variant A purchase order lines are included
        _Assert.AreEqual(5, PeriodDiscountLine."Quantity On Purchase Order", 'Quantity On Purchase Order must only include purchase order lines of the line''s variant');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QtyOnPurchOrderIncludesAllVariantsWhenVariantCodeBlank()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        // [SCENARIO] When Variant Code is blank on a period discount line, Quantity On Purchase Order keeps the total across all variants

        // [GIVEN] Item with a variant and outstanding purchase order lines: 5 for the variant, 7 without variant
        _LibraryInventory.CreateItem(Item);
        _LibraryInventory.CreateItemVariant(VariantA, Item."No.");
        MockPurchaseOrderLine(Item."No.", VariantA.Code, 5);
        MockPurchaseOrderLine(Item."No.", '', 7);

        // [GIVEN] Period discount line without variant code
        CreatePeriodDiscountLine(PeriodDiscountLine, CreatePeriodDiscount(), Item."No.", '');

        // [WHEN] Applying the variant filter and calculating Quantity On Purchase Order
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields("Quantity On Purchase Order");

        // [THEN] All purchase order lines are included
        _Assert.AreEqual(12, PeriodDiscountLine."Quantity On Purchase Order", 'Quantity On Purchase Order must include all purchase order lines when the line has no variant code');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantitySoldIsVariantSpecificWhenVariantCodeSet()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        PeriodDiscountCode: Code[20];
    begin
        // [SCENARIO] When Variant Code is set on a period discount line, Quantity Sold only includes POS entry sales lines of that variant

        // [GIVEN] Item with two variants
        _LibraryInventory.CreateItem(Item);
        _LibraryInventory.CreateItemVariant(VariantA, Item."No.");
        _LibraryInventory.CreateItemVariant(VariantB, Item."No.");

        // [GIVEN] POS entry sales lines for the campaign: qty 1 on variant A, 2 on variant B, 3 without variant
        PeriodDiscountCode := CreatePeriodDiscount();
        MockPOSEntrySalesLine(PeriodDiscountCode, Item."No.", VariantA.Code, 1);
        MockPOSEntrySalesLine(PeriodDiscountCode, Item."No.", VariantB.Code, 2);
        MockPOSEntrySalesLine(PeriodDiscountCode, Item."No.", '', 3);

        // [GIVEN] Period discount line for variant A
        CreatePeriodDiscountLine(PeriodDiscountLine, PeriodDiscountCode, Item."No.", VariantA.Code);

        // [WHEN] Applying the variant filter and calculating Quantity Sold
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields("Quantity Sold");

        // [THEN] Only variant A sales are included (the flow field negates the summed quantity)
        _Assert.AreEqual(-1, PeriodDiscountLine."Quantity Sold", 'Quantity Sold must only include POS entry sales lines of the line''s variant');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantitySoldIncludesAllVariantsWhenVariantCodeBlank()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        PeriodDiscountCode: Code[20];
    begin
        // [SCENARIO] When Variant Code is blank on a period discount line, Quantity Sold keeps the total across all variants sold under the campaign

        // [GIVEN] Item with two variants
        _LibraryInventory.CreateItem(Item);
        _LibraryInventory.CreateItemVariant(VariantA, Item."No.");
        _LibraryInventory.CreateItemVariant(VariantB, Item."No.");

        // [GIVEN] POS entry sales lines for the campaign: qty 1 on variant A, 2 on variant B, 3 without variant
        PeriodDiscountCode := CreatePeriodDiscount();
        MockPOSEntrySalesLine(PeriodDiscountCode, Item."No.", VariantA.Code, 1);
        MockPOSEntrySalesLine(PeriodDiscountCode, Item."No.", VariantB.Code, 2);
        MockPOSEntrySalesLine(PeriodDiscountCode, Item."No.", '', 3);

        // [GIVEN] Period discount line without variant code
        CreatePeriodDiscountLine(PeriodDiscountLine, PeriodDiscountCode, Item."No.", '');

        // [WHEN] Applying the variant filter and calculating Quantity Sold
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields("Quantity Sold");

        // [THEN] Sales of all variants are included (the flow field negates the summed quantity)
        _Assert.AreEqual(-6, PeriodDiscountLine."Quantity Sold", 'Quantity Sold must include sales of all variants when the line has no variant code');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetVariantCodeFilterClearsFilterLeftFromPreviousLine()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        PeriodDiscountCode: Code[20];
    begin
        // [SCENARIO] When the same record instance moves from a variant line to a blank-variant line (as pages do), the variant filter from the previous line is cleared

        // [GIVEN] Item with two variants and inventory: 2 on variant A, 3 on variant B, 4 without variant
        CreateItemWithTwoVariantsAndInventory(Item, VariantA, VariantB);

        // [GIVEN] Period discount lines for variant A and without variant code
        PeriodDiscountCode := CreatePeriodDiscount();
        CreatePeriodDiscountLine(PeriodDiscountLine, PeriodDiscountCode, Item."No.", VariantA.Code);
        CreatePeriodDiscountLine(PeriodDiscountLine, PeriodDiscountCode, Item."No.", '');

        // [GIVEN] The variant line was calculated first on the same record instance
        PeriodDiscountLine.Get(PeriodDiscountCode, Item."No.", VariantA.Code);
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields(Inventory);
        _Assert.AreEqual(2, PeriodDiscountLine.Inventory, 'Inventory must only include item ledger entries of the line''s variant');

        // [WHEN] Moving to the blank-variant line and applying the variant filter again
        PeriodDiscountLine.Get(PeriodDiscountCode, Item."No.", '');
        PeriodDiscountLine.SetVariantCodeFilter();
        PeriodDiscountLine.CalcFields(Inventory);

        // [THEN] The filter from the variant line is cleared and the total is shown
        _Assert.AreEqual(9, PeriodDiscountLine.Inventory, 'Variant filter from the previous line must be cleared for a blank-variant line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CampaignDiscLineListShowsVariantSpecificInventory()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        CampaignDiscLineList: TestPage "NPR Campaign Disc. Line List";
        PeriodDiscountCode: Code[20];
    begin
        // [SCENARIO] The Campaign Disc. Line List page shows variant scoped inventory on variant lines and the total on blank-variant lines

        // [GIVEN] Item with two variants and inventory: 2 on variant A, 3 on variant B, 4 without variant
        CreateItemWithTwoVariantsAndInventory(Item, VariantA, VariantB);

        // [GIVEN] Period discount lines for variant A and without variant code
        PeriodDiscountCode := CreatePeriodDiscount();
        CreatePeriodDiscountLine(PeriodDiscountLine, PeriodDiscountCode, Item."No.", VariantA.Code);
        CreatePeriodDiscountLine(PeriodDiscountLine, PeriodDiscountCode, Item."No.", '');

        // [WHEN] Opening the page on the variant A line
        CampaignDiscLineList.OpenView();
        PeriodDiscountLine.Get(PeriodDiscountCode, Item."No.", VariantA.Code);
        CampaignDiscLineList.GoToRecord(PeriodDiscountLine);

        // [THEN] Inventory shows the variant A quantity
        _Assert.AreEqual(2, CampaignDiscLineList.Inventory.AsDecimal(), 'Page must show inventory of the line''s variant');

        // [WHEN] Moving to the blank-variant line
        PeriodDiscountLine.Get(PeriodDiscountCode, Item."No.", '');
        CampaignDiscLineList.GoToRecord(PeriodDiscountLine);

        // [THEN] Inventory shows the total quantity
        _Assert.AreEqual(9, CampaignDiscLineList.Inventory.AsDecimal(), 'Page must show total inventory for a blank-variant line');
    end;

    local procedure CreateItemWithTwoVariantsAndInventory(var Item: Record Item; var VariantA: Record "Item Variant"; var VariantB: Record "Item Variant")
    begin
        _LibraryInventory.CreateItem(Item);
        _LibraryInventory.CreateItemVariant(VariantA, Item."No.");
        _LibraryInventory.CreateItemVariant(VariantB, Item."No.");

        MockItemLedgerEntry(Item."No.", VariantA.Code, 2);
        MockItemLedgerEntry(Item."No.", VariantB.Code, 3);
        MockItemLedgerEntry(Item."No.", '', 4);
    end;

    local procedure CreatePeriodDiscount(): Code[20]
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        PeriodDiscount.Init();
        PeriodDiscount.Code := _LibraryUtility.GenerateRandomCode(PeriodDiscount.FieldNo(Code), Database::"NPR Period Discount");
        PeriodDiscount.Status := PeriodDiscount.Status::Active;
        PeriodDiscount.Insert();
        exit(PeriodDiscount.Code);
    end;

    local procedure CreatePeriodDiscountLine(var PeriodDiscountLine: Record "NPR Period Discount Line"; PeriodDiscountCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10])
    begin
        PeriodDiscountLine.Init();
        PeriodDiscountLine.Code := PeriodDiscountCode;
        PeriodDiscountLine."Item No." := ItemNo;
        PeriodDiscountLine."Variant Code" := VariantCode;
        PeriodDiscountLine.Insert();
    end;

    local procedure MockItemLedgerEntry(ItemNo: Code[20]; VariantCode: Code[10]; Qty: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        EntryNo: Integer;
    begin
        if ItemLedgerEntry.FindLast() then
            EntryNo := ItemLedgerEntry."Entry No.";

        ItemLedgerEntry.Init();
        ItemLedgerEntry."Entry No." := EntryNo + 1;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Variant Code" := VariantCode;
        ItemLedgerEntry.Quantity := Qty;
        ItemLedgerEntry.Insert();
    end;

    local procedure MockPurchaseOrderLine(ItemNo: Code[20]; VariantCode: Code[10]; OutstandingQtyBase: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
        PurchaseLine."Document No." := _LibraryUtility.GenerateGUID();
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := ItemNo;
        PurchaseLine."Variant Code" := VariantCode;
        PurchaseLine."Outstanding Qty. (Base)" := OutstandingQtyBase;
        PurchaseLine.Insert();
    end;

    local procedure MockPOSEntrySalesLine(DiscountCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; Qty: Decimal)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryNo: Integer;
    begin
        if POSEntrySalesLine.FindLast() then
            POSEntryNo := POSEntrySalesLine."POS Entry No.";

        POSEntrySalesLine.Init();
        POSEntrySalesLine."POS Entry No." := POSEntryNo + 1;
        POSEntrySalesLine."Line No." := 10000;
        POSEntrySalesLine.Type := POSEntrySalesLine.Type::Item;
        POSEntrySalesLine."No." := ItemNo;
        POSEntrySalesLine."Variant Code" := VariantCode;
        POSEntrySalesLine."Discount Type" := POSEntrySalesLine."Discount Type"::Campaign;
        POSEntrySalesLine."Discount Code" := DiscountCode;
        POSEntrySalesLine.Quantity := Qty;
        POSEntrySalesLine.Insert();
    end;
}
