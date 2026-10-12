codeunit 85523 "NPR Item Before Image Tests"
{
    // [FEATURE] Item before-image: after-modify subscribers see the item row as it was on disk, and the readers that depend on it still detect code-driven changes
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";

    [Test]
    procedure CodeDrivenItemModifyHandsAfterSubscribersTheOnDiskUnitPrice()
    var
        Item: Record Item;
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] An after-modify subscriber asking the before-image helper during a code-driven price change gets the price that was on disk, not the one being written.
        // [GIVEN] An item with unit price 100
        _Lib.CreateItem(Item);
        Item."Unit Price" := 100;
        Item.Modify(false);

        // [GIVEN] A probe subscriber asking the helper during the modify
        BindSubscription(TestXRecProbe);

        // [WHEN] The unit price is changed to 200 from code
        Item."Unit Price" := 200;
        Item.Modify(true);

        // [THEN] The helper handed out the on-disk price
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::Item), 'The probe must observe the item modify');
        _Assert.AreEqual(100, TestXRecProbe.ItemBeforeImageUnitPrice(), 'The before-image must carry the price that was on disk');
    end;

    [Test]
    procedure FlaggingAnItemAsMagentoItemFromCodeLogsTheChange()
    var
        Item: Record Item;
        RecordChangeLog: Record "NPR M2 Record Change Log";
    begin
        // [SCENARIO] Setting the Magento item flag from code is logged as an enabled item, which needs the pre-change flag value.
        // [GIVEN] An item that is not a Magento item
        _Lib.CreateItem(Item);

        // [WHEN] The flag is set from code
        Item."NPR Magento Item" := true;
        Item.Modify(true);

        // [THEN] The change log holds the item as enabled
        RecordChangeLog.SetRange("Type of Change", RecordChangeLog."Type of Change"::ItemEnabled);
        RecordChangeLog.SetRange("Entity Identifier", Item."No.");
        _Assert.AreEqual(1, RecordChangeLog.Count(), 'The Magento change log must record the item as enabled');
    end;

    [Test]
    procedure CodeDrivenItemModifyLeavesXRecUntouchedForLaterSubscribers()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] A code-driven modify of a Shopify-linked item reaches later subscribers with the xRec the platform supplied, which carries the category being written rather than the category on disk.
        // [GIVEN] An item linked to a Shopify store
        _Lib.EnsureIntegrationEnabled();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, _Lib.CreateStore(true, false, false, false, false));

        // [GIVEN] A probe subscriber observing the modify event
        BindSubscription(TestXRecProbe);

        // [WHEN] The item's category is changed from code
        Item."Item Category Code" := _Lib.CreateItemCategory('xRec probe category');
        Item.Modify(true);

        // [THEN] The probe saw the modify with xRec still carrying the new category
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::Item), 'The probe must observe the item modify');
        _Assert.IsTrue(TestXRecProbe.XRecCarriesRecValue(Database::Item), 'A Shopify subscriber must not replace xRec on an item modify');
    end;

    [Test]
    procedure RemovingTheCategoryOfALinkedItemClearsItsCategoryMetafield()
    var
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        // [SCENARIO] Clearing the item category of an item linked to a store that maps categories to a metafield blanks the link's category metafield.
        // [GIVEN] A store that maps item categories to a product metafield
        _Lib.EnsureIntegrationEnabled();
        ShopifyStore.Get(_Lib.CreateStore(true, false, false, false, false));
        ShopifyStore."Item Category as Metafield" := true;
        ShopifyStore.Modify(false);

        // [GIVEN] A linked item with a category, and a category metafield on its link mapped for the store
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, ShopifyStore.Code);
        Item."Item Category Code" := _Lib.CreateItemCategory('Category to remove');
        Item.Modify(false);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), '["old category"]');
        SpfyMetafieldMgt.SaveMetafieldMapping(
            ShopifyStore.RecordId(), ShopifyStore.FieldNo("Item Category as Metafield"), ShopifyStore.Code,
            "NPR Spfy Metafield Owner Type"::PRODUCT, SpfyEntityMetafield."Metafield ID");

        // [WHEN] The category is removed from code
        Item."Item Category Code" := '';
        Item.Modify(true);

        // [THEN] The category metafield on the link is blank
        SpfyEntityMetafield.Get(SpfyEntityMetafield."Entry No.");
        _Assert.AreEqual('', SpfyEntityMetafield.GetMetafieldValue(true), 'The category metafield must be cleared');
    end;

    [Test]
    procedure PartialRecordModifyClearingTheCategoryStillClearsTheCategoryMetafield()
    var
        Item: Record Item;
        PartialItem: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        // [SCENARIO] Clearing the category through a record that loaded only the category still blanks the link's category metafield.
        // [GIVEN] A store that maps item categories to a product metafield
        _Lib.EnsureIntegrationEnabled();
        ShopifyStore.Get(_Lib.CreateStore(true, false, false, false, false));
        ShopifyStore."Item Category as Metafield" := true;
        ShopifyStore.Modify(false);

        // [GIVEN] A linked item with a category, and a category metafield on its link mapped for the store
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, ShopifyStore.Code);
        Item."Item Category Code" := _Lib.CreateItemCategory('Category to remove');
        Item.Modify(false);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), '["old category"]');
        SpfyMetafieldMgt.SaveMetafieldMapping(
            ShopifyStore.RecordId(), ShopifyStore.FieldNo("Item Category as Metafield"), ShopifyStore.Code,
            "NPR Spfy Metafield Owner Type"::PRODUCT, SpfyEntityMetafield."Metafield ID");

        // [WHEN] The category is cleared through a record that loaded only the category
        PartialItem.SetLoadFields("Item Category Code");
        PartialItem.Get(Item."No.");
        PartialItem."Item Category Code" := '';
        PartialItem.Modify(true);

        // [THEN] The category metafield on the link is blank
        SpfyEntityMetafield.Get(SpfyEntityMetafield."Entry No.");
        _Assert.AreEqual('', SpfyEntityMetafield.GetMetafieldValue(true), 'The category metafield must be cleared');
    end;

    [Test]
    procedure BeforeImageOfAnOuterModifySurvivesANestedModifyOfTheSameItem()
    var
        Item: Record Item;
        OuterImage: Record Item;
        OuterXRec: Record Item;
        NestedImage: Record Item;
        NestedXRec: Record Item;
        TakenImage: Record Item;
        ItemBeforeImage: Codeunit "NPR Item Before Image";
        OuterPrice: Decimal;
        NestedPrice: Decimal;
    begin
        // [SCENARIO] A reader of an outer modify still gets the outer modify's before-image after another modify of the same item has remembered its own.
        // [GIVEN] An outer modify of an item from unit price 10 to 12, and its before-image remembered
        _Lib.CreateItem(Item);
        OuterImage := Item;
        OuterImage."Unit Price" := 10;
        OuterXRec := Item;
        OuterXRec."Unit Price" := 12;
        ItemBeforeImage.Remember(OuterImage, OuterXRec);

        // [GIVEN] A nested modify of the same item, on disk at 12 by then, changing its description, and its before-image remembered
        NestedImage := OuterXRec;
        NestedXRec := OuterXRec;
        NestedXRec.Description := 'Changed by a nested modify';
        ItemBeforeImage.Remember(NestedImage, NestedXRec);

        // [WHEN] The readers of both modifies ask for their before-image
        ItemBeforeImage.GetBeforeImage(OuterXRec, OuterXRec, TakenImage);
        OuterPrice := TakenImage."Unit Price";
        ItemBeforeImage.GetBeforeImage(NestedXRec, NestedXRec, TakenImage);
        NestedPrice := TakenImage."Unit Price";

        // [THEN] Each gets the image of its own modify
        _Assert.AreEqual(10, OuterPrice, 'The outer modify must get the price that was on disk when it began');
        _Assert.AreEqual(12, NestedPrice, 'The nested modify must get the price that was on disk when it began');
    end;

    [Test]
    procedure CodeDrivenVendorItemNoChangeReplacesTheVendorItemReference()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        Vendor: Record Vendor;
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        // [SCENARIO] Changing an item's vendor item number from code replaces the item reference for the old number with one for the new number.
        // [GIVEN] An item with a vendor and vendor item number OLD-REF, and its vendor item reference
        LibraryPurchase.CreateVendor(Vendor);
        _Lib.CreateItem(Item);
        Item."Vendor No." := Vendor."No.";
        Item."Vendor Item No." := 'OLD-REF';
        Item.Modify(false);
        CreateVendorItemReference(Item);

        // [WHEN] The vendor item number is changed to NEW-REF from code
        Item."Vendor Item No." := 'NEW-REF';
        Item.Modify(true);

        // [THEN] The reference for OLD-REF is gone and one for NEW-REF exists
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", Vendor."No.");
        ItemReference.SetRange("Reference No.", 'OLD-REF');
        _Assert.RecordIsEmpty(ItemReference);
        ItemReference.SetRange("Reference No.", 'NEW-REF');
        _Assert.RecordIsNotEmpty(ItemReference);
    end;

    [Test]
    procedure CodeDrivenUnitPriceChangeReachesSalesPriceMaintenance()
    var
        Item: Record Item;
        TestItemReaderProbe: Codeunit "NPR Test Item Reader Probe";
    begin
        // [SCENARIO] Changing an item's unit price from code makes sales price maintenance update the staff prices.
        // [GIVEN] An item with unit price 100
        _Lib.CreateItem(Item);
        Item."Unit Price" := 100;
        Item.Modify(false);

        // [GIVEN] A probe on the sales price maintenance update
        BindSubscription(TestItemReaderProbe);

        // [WHEN] The unit price is changed to 200 from code
        Item."Unit Price" := 200;
        Item.Modify(true);

        // [THEN] Sales price maintenance was asked to update the staff prices
        _Assert.IsTrue(TestItemReaderProbe.SalesPriceUpdateRaised(), 'A code-driven price change must reach sales price maintenance');
    end;

    [Test]
    procedure PartialRecordUnitPriceChangeReachesSalesPriceMaintenance()
    var
        Item: Record Item;
        PartialItem: Record Item;
        TestItemReaderProbe: Codeunit "NPR Test Item Reader Probe";
    begin
        // [SCENARIO] A unit price changed on a partial record that loaded only the unit price still makes sales price maintenance update the staff prices.
        // [GIVEN] An item with unit price 100
        _Lib.CreateItem(Item);
        Item."Unit Price" := 100;
        Item.Modify(false);

        // [GIVEN] The item read as a partial record that loads only the unit price
        PartialItem.SetLoadFields("Unit Price");
        PartialItem.Get(Item."No.");

        // [GIVEN] A probe on the sales price maintenance update
        BindSubscription(TestItemReaderProbe);

        // [WHEN] The unit price is changed to 200 on the partial record
        PartialItem."Unit Price" := 200;
        PartialItem.Modify(true);

        // [THEN] Sales price maintenance was asked to update the staff prices
        _Assert.IsTrue(TestItemReaderProbe.SalesPriceUpdateRaised(), 'A price change on a partial record must reach sales price maintenance');
    end;

    [Test]
    procedure CodeDrivenVarietyChangeHandsTheVarietyCheckTheOldVariety()
    var
        Item: Record Item;
        TestItemReaderProbe: Codeunit "NPR Test Item Reader Probe";
    begin
        // [SCENARIO] Changing an item's variety from code hands the variety check the variety the item had before.
        // [GIVEN] An item with variety 1 set to OLDV
        _Lib.CreateItem(Item);
        Item."NPR Variety 1" := 'OLDV';
        Item.Modify(false);

        // [GIVEN] A probe on the variety check
        BindSubscription(TestItemReaderProbe);

        // [WHEN] Variety 1 is changed to NEWV from code
        Item."NPR Variety 1" := 'NEWV';
        Item.Modify(true);

        // [THEN] The variety check received the old variety
        _Assert.IsTrue(TestItemReaderProbe.VarietyChangeSeen(), 'The variety check must run on the modify');
        _Assert.AreEqual('OLDV', TestItemReaderProbe.VarietyBefore(), 'The variety check must get the variety the item had before');
    end;

    [Test]
    procedure CodeDrivenItemStatusChangeRaisesTheWorkflowEventWithTheOldStatus()
    var
        Item: Record Item;
        TestItemReaderProbe: Codeunit "NPR Test Item Reader Probe";
    begin
        // [SCENARIO] Changing an item's status from code raises the item status workflow event with the status the item had before.
        // [GIVEN] An item with status OLDST
        _Lib.CreateItem(Item);
        Item."NPR Item Status" := 'OLDST';
        Item.Modify(false);

        // [GIVEN] A probe on the workflow event
        BindSubscription(TestItemReaderProbe);

        // [WHEN] The status is changed to NEWST from code
        Item."NPR Item Status" := 'NEWST';
        Item.Modify(true);

        // [THEN] The item status workflow event was raised with the old status
        _Assert.IsTrue(TestItemReaderProbe.ItemStatusChangeSeen(), 'A code-driven status change must raise the item status workflow event');
        _Assert.AreEqual('OLDST', TestItemReaderProbe.ItemStatusBefore(), 'The workflow event must carry the status the item had before');
    end;

    [Test]
    procedure BeforeImagesBeyondTheRingOverwriteTheOldestOnly()
    var
        Images: array[21] of Record Item;
        XRecs: array[21] of Record Item;
        TakenImage: Record Item;
        ItemBeforeImage: Codeunit "NPR Item Before Image";
        i: Integer;
        OldestPrice: Decimal;
        SecondPrice: Decimal;
        NewestPrice: Decimal;
    begin
        // [SCENARIO] Remembering one image more than the helper keeps overwrites the oldest image and keeps the others.
        // [GIVEN] Twenty images remembered for twenty items, each image priced i and its modify writing price 1000 + i
        for i := 1 to ArrayLen(Images) do begin
            Images[i]."No." := _Lib.NextCode('IT', MaxStrLen(Images[i]."No."));
            Images[i]."Unit Price" := i;
            XRecs[i] := Images[i];
            XRecs[i]."Unit Price" := 1000 + i;
        end;
        for i := 1 to ArrayLen(Images) - 1 do
            ItemBeforeImage.Remember(Images[i], XRecs[i]);

        // [WHEN] One more image is remembered
        ItemBeforeImage.Remember(Images[ArrayLen(Images)], XRecs[ArrayLen(Images)]);

        // [THEN] The oldest image is gone, so its reader gets xRec, while the second oldest and the newest are still found
        ItemBeforeImage.GetBeforeImage(XRecs[1], XRecs[1], TakenImage);
        OldestPrice := TakenImage."Unit Price";
        ItemBeforeImage.GetBeforeImage(XRecs[2], XRecs[2], TakenImage);
        SecondPrice := TakenImage."Unit Price";
        ItemBeforeImage.GetBeforeImage(XRecs[ArrayLen(Images)], XRecs[ArrayLen(Images)], TakenImage);
        NewestPrice := TakenImage."Unit Price";
        _Assert.AreEqual(1001, OldestPrice, 'The oldest image must be overwritten, leaving xRec');
        _Assert.AreEqual(2, SecondPrice, 'The second oldest image must be kept');
        _Assert.AreEqual(ArrayLen(Images), NewestPrice, 'The newest image must be kept');
    end;

    [Test]
    procedure PartialRecordModifyOfAnotherFieldLeavesTheCategoryMetafieldAlone()
    var
        Item: Record Item;
        PartialItem: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        // [SCENARIO] Changing another field through a record that never loaded the category leaves the link's category metafield as it was.
        // [GIVEN] A store that maps item categories to a product metafield
        _Lib.EnsureIntegrationEnabled();
        ShopifyStore.Get(_Lib.CreateStore(true, false, false, false, false));
        ShopifyStore."Item Category as Metafield" := true;
        ShopifyStore.Modify(false);

        // [GIVEN] A linked item with a category, and a category metafield on its link mapped for the store
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, ShopifyStore.Code);
        Item."Item Category Code" := _Lib.CreateItemCategory('Category to keep');
        Item.Modify(false);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), '["old category"]');
        SpfyMetafieldMgt.SaveMetafieldMapping(
            ShopifyStore.RecordId(), ShopifyStore.FieldNo("Item Category as Metafield"), ShopifyStore.Code,
            "NPR Spfy Metafield Owner Type"::PRODUCT, SpfyEntityMetafield."Metafield ID");

        // [WHEN] The description is changed through a record that loaded only the description
        PartialItem.SetLoadFields(Description);
        PartialItem.Get(Item."No.");
        PartialItem.Description := 'Changed through a partial record';
        PartialItem.Modify(true);

        // [THEN] The category metafield on the link still holds the category
        SpfyEntityMetafield.Get(SpfyEntityMetafield."Entry No.");
        _Assert.AreEqual('["old category"]', SpfyEntityMetafield.GetMetafieldValue(true), 'A partial record that never loaded the category must not clear the category metafield');
    end;

    [Test]
    procedure ReaderAfterANestedModifyThroughAnotherRecordStillGetsTheOuterImage()
    var
        Item: Record Item;
        TestNestedItemModify: Codeunit "NPR Test Nested Item Modify";
    begin
        // [SCENARIO] An after-modify reader that runs after another subscriber modified the same item through its own record still gets the outer modify's before-image.
        // [GIVEN] An item with unit price 10
        _Lib.CreateItem(Item);
        Item."Unit Price" := 10;
        Item.Modify(false);

        // [GIVEN] An after-modify subscriber that modifies the item again through another record and then asks for the before-image
        TestNestedItemModify.SetThroughSameRecord(false);
        BindSubscription(TestNestedItemModify);

        // [WHEN] The unit price is changed to 12 from code
        Item."Unit Price" := 12;
        Item.Modify(true);

        // [THEN] After the nested modify the outer modify's before-image still carries unit price 10
        _Assert.IsTrue(TestNestedItemModify.NestedModifyDone(), 'The nested modify must have run');
        _Assert.AreEqual(10, TestNestedItemModify.OuterImageUnitPrice(), 'The outer modify must still get the price that was on disk when it began');
    end;

    [Test]
    procedure ReaderAfterANestedModifyThroughTheSameRecordStillGetsTheOuterImage()
    var
        Item: Record Item;
        TestNestedItemModify: Codeunit "NPR Test Nested Item Modify";
    begin
        // [SCENARIO] An after-modify reader that runs after another subscriber modified the same item through the record it was handed still gets the outer modify's before-image.
        // [GIVEN] An item with unit price 10
        _Lib.CreateItem(Item);
        Item."Unit Price" := 10;
        Item.Modify(false);

        // [GIVEN] An after-modify subscriber that modifies the item again through the record it was handed and then asks for the before-image
        TestNestedItemModify.SetThroughSameRecord(true);
        BindSubscription(TestNestedItemModify);

        // [WHEN] The unit price is changed to 12 from code
        Item."Unit Price" := 12;
        Item.Modify(true);

        // [THEN] After the nested modify the outer modify's before-image still carries unit price 10
        _Assert.IsTrue(TestNestedItemModify.NestedModifyDone(), 'The nested modify must have run');
        _Assert.AreEqual(10, TestNestedItemModify.OuterImageUnitPrice(), 'The outer modify must still get the price that was on disk when it began');
    end;

    local procedure CreateVendorItemReference(Item: Record Item)
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.Init();
        ItemReference."Item No." := Item."No.";
        ItemReference."Unit of Measure" := Item."Base Unit of Measure";
        ItemReference."Reference Type" := ItemReference."Reference Type"::Vendor;
        ItemReference."Reference Type No." := Item."Vendor No.";
        ItemReference."Reference No." := Item."Vendor Item No.";
        ItemReference.Insert(false);
    end;
}
