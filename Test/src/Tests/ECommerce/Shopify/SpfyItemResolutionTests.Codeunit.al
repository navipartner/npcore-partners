#if not BC17
codeunit 85363 "NPR Spfy Item Resolution Tests"
{
    // [Feature] Shopify Item Resolution
    // Covers "NPR Spfy Item Mgt.".ParseItemForDocumentImport and its OnResolveUnknownItem extension point, as
    // reached from the legacy order import ("NPR Spfy Order Mgt.".UpsertSalesLine): the standard SKU lookup keeps
    // precedence, subscribers only get a say once it has failed, and a resolution pointing at a non-existing item
    // or variant is rejected as a subscriber bug rather than reported as an unknown SKU. Order line fixtures use
    // the legacy REST line item shape, because that is what the legacy order import feeds in.
    //
    // Only the legacy order import opts in for now. Two other callers stay on plain ParseItem, for different
    // reasons. Product synchronization ("NPR Spfy Send Items&Inventory") must never resolve through the fallback:
    // an unresolved Shopify variant is a normal outcome there, and a fallback item would be linked, assigned
    // Shopify IDs and have its data pushed. The ecommerce sales document import
    // ("NPR Spfy Ecom Sales Doc Import".AddNewSaleLine / ResolveItem) is a deliberate follow-up rather than an
    // exclusion - it raises the same unknown-SKU error and would benefit from the same extension point, but is
    // out of scope here because the stores driving this change run the legacy import. Wiring it up needs an
    // overload that also returns the Item record: ResolveItem classifies the line subtype from it, so a
    // subscriber resolution that left Item blank would silently import a ticket as an ordinary item line.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibraryInventory: Codeunit "NPR Library - Inventory";
        _StoreCodeLbl: Label 'SPFYTEST', Locked = true;
        _C2SSkuLbl: Label 'C2S-TENT-2000', Locked = true;
        _ProgrammingBugLbl: Label 'This is a programming bug.', Locked = true;

    [Test]
    procedure UnknownSku_WithoutSubscriber_IsNotResolved()
    var
        ItemVariant: Record "Item Variant";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderLine: JsonToken;
        Sku: Text;
    begin
        // [Scenario] Without a subscriber, an unresolvable SKU stays unresolved - the extension point changes nothing.

        // [Given] A Shopify store and an order line carrying a SKU that matches no item, item variant or item reference
        CreateShopifyStore();
        OrderLine := CreateOrderLine(5001, _C2SSkuLbl);

        // [When] The order line is resolved to a BC item
        // [Then] The lookup fails and no item is returned
        _Assert.IsFalse(
            SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, Sku),
            'An unresolvable SKU must not be resolved when nothing subscribes to OnResolveUnknownItem.');
        _Assert.AreEqual('', ItemVariant."Item No.", 'No item may be returned for an unresolvable SKU.');
    end;

    [Test]
    procedure KnownSku_SubscriberIsNotAsked()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OtherItemNo: Code[20];
        OrderLine: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        // [Scenario] The standard SKU lookup keeps precedence: a subscriber cannot redirect a SKU that BC can resolve.

        // [Given] An item whose number is used as the SKU on the order line, and a subscriber that would resolve to another item
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        OtherItemNo := _LibraryInventory.CreateItemNo();
        OrderLine := CreateOrderLine(5002, Item."No.");
        ResolutionMock.SetResolution(OtherItemNo, '');

        // [When] The order line is resolved to a BC item
        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] The item from the SKU is returned and the subscriber was never asked
        _Assert.IsTrue(Resolved, 'A SKU matching an item number must resolve.');
        _Assert.AreEqual(Item."No.", ItemVariant."Item No.", 'The item matching the SKU must be returned.');
        _Assert.AreEqual(0, ResolutionMock.CallCount(), 'OnResolveUnknownItem must not be raised for a SKU the standard lookup resolves.');
    end;

    [Test]
    procedure KnownSkuWithVariantSuffix_SubscriberIsNotAsked()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ResolvedItemVariant: Record "Item Variant";
        MSLibraryInventory: Codeunit "Library - Inventory";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OtherItemNo: Code[20];
        OrderLine: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        MSLibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        OtherItemNo := _LibraryInventory.CreateItemNo();
        OrderLine := CreateOrderLine(5009, StrSubstNo('%1_%2', Item."No.", ItemVariant.Code));
        ResolutionMock.SetResolution(OtherItemNo, '');

        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ResolvedItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        _Assert.IsTrue(Resolved, 'A SKU of the form <item no>_<variant code> must resolve through the standard lookup.');
        _Assert.AreEqual(Item."No.", ResolvedItemVariant."Item No.", 'The item named by the SKU must be returned, not the one the subscriber offers.');
        _Assert.AreEqual(ItemVariant.Code, ResolvedItemVariant.Code, 'The variant named by the SKU must be returned.');
        _Assert.AreEqual(0, ResolutionMock.CallCount(), 'OnResolveUnknownItem must not be raised for a SKU the variant-suffix lookup resolves.');
    end;

    [Test]
    procedure UnknownSku_SubscriberResolvesItem()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        LineID: BigInteger;
        OrderLine: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        // [Scenario] A subscriber resolves a SKU the standard lookup cannot, and is given the context to decide on.

        // [Given] An order line with an unresolvable SKU, and a subscriber that resolves it to an existing item
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        LineID := 5003;
        OrderLine := CreateOrderLine(LineID, _C2SSkuLbl);
        ResolutionMock.SetResolution(Item."No.", '');

        // [When] The order line is resolved to a BC item
        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] The item the subscriber picked is returned
        _Assert.IsTrue(Resolved, 'A SKU resolved by a subscriber must count as resolved.');
        _Assert.AreEqual(Item."No.", ItemVariant."Item No.", 'The item picked by the subscriber must be returned.');

        // [Then] The subscriber was given the store code and the SKU it was asked about
        _Assert.AreEqual(1, ResolutionMock.CallCount(), 'OnResolveUnknownItem must be raised once for an unresolvable SKU.');
        _Assert.AreEqual(_StoreCodeLbl, ResolutionMock.CapturedStoreCode(), 'The Shopify store code must be passed to subscribers.');
        _Assert.AreEqual(_C2SSkuLbl, ResolutionMock.CapturedSku(), 'The unresolved SKU must be passed to subscribers.');

        // [Then] The subscriber was given the Shopify order line itself, so it can read the original product data it maps away from
        _Assert.AreEqual(LineID, ResolutionMock.CapturedLineID(), 'The Shopify order line must be passed to subscribers.');
        _Assert.AreEqual(
            OrderLineTitle(LineID), ResolutionMock.CapturedTitle(),
            'Subscribers must be able to read the original Shopify product data from the order line they are asked about.');
    end;

    [Test]
    procedure UnknownSku_SubscriberResolvesItemVariant()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ResolvedItemVariant: Record "Item Variant";
        MSLibraryInventory: Codeunit "Library - Inventory";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderLine: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        // [Scenario] A subscriber can resolve a SKU to a specific item variant, not just to an item.

        // [Given] An item with a variant, and a subscriber that resolves an unresolvable SKU to that variant
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        MSLibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        OrderLine := CreateOrderLine(5004, _C2SSkuLbl);
        ResolutionMock.SetResolution(Item."No.", ItemVariant.Code);

        // [When] The order line is resolved to a BC item
        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ResolvedItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] Both the item and the variant the subscriber picked are returned
        _Assert.IsTrue(Resolved, 'A SKU resolved to an item variant by a subscriber must count as resolved.');
        _Assert.AreEqual(Item."No.", ResolvedItemVariant."Item No.", 'The item picked by the subscriber must be returned.');
        _Assert.AreEqual(ItemVariant.Code, ResolvedItemVariant.Code, 'The item variant picked by the subscriber must be returned.');
    end;

    [Test]
    procedure UnknownSku_SubscriberResolvesItem_ReturnsItemRecordForSubtype()
    var
        Item: Record Item;
        ResolvedItem: Record Item;
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        TicketTypeCode: Code[10];
        OrderLine: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        TicketTypeCode := 'SPFYTKT';
        Item."NPR Ticket Type" := TicketTypeCode;
        Item.Modify();
        OrderLine := CreateOrderLine(5010, _C2SSkuLbl);
        ResolutionMock.SetResolution(Item."No.", '');

        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, ResolvedItem, Sku);
        UnbindSubscription(ResolutionMock);

        _Assert.IsTrue(Resolved, 'The overload carrying the Item record must resolve a SKU through the subscriber fallback.');
        _Assert.AreEqual(Item."No.", ResolvedItem."No.", 'The Item record must be populated, because the ecommerce import classifies the line subtype from it.');
        _Assert.AreEqual(
            TicketTypeCode, ResolvedItem."NPR Ticket Type",
            'A subscriber-resolved ticket item must arrive with its ticket type, or the line imports as an ordinary item and no ticket reservation is created.');
        _Assert.AreEqual(Item."No.", ItemVariant."Item No.", 'The Item Variant record must name the same item as the Item record.');
    end;

    [Test]
    procedure UnknownSku_TwoSubscribers_ExactlyOneClaimsTheSku()
    var
        Item: Record Item;
        CompetingItem: Record Item;
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderLine: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        // [Scenario] Two extensions can be bound to OnResolveUnknownItem at once, and BC does not guarantee the
        // order it invokes them in. The event contract handles this by requiring a subscriber to abstain once the
        // SKU is claimed, so the outcome is one subscriber's item rather than whichever happened to run last.

        // [Given] An order line with an unresolvable SKU, and two subscribers that each resolve it to a different item
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        _LibraryInventory.CreateItem(CompetingItem);
        OrderLine := CreateOrderLine(5008, _C2SSkuLbl);
        ResolutionMock.SetResolution(Item."No.", '');
        ResolutionMock.SetCompetingResolution(CompetingItem."No.");

        // [When] The order line is resolved to a BC item
        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] Exactly one subscriber claimed the SKU - the other saw it taken and abstained
        _Assert.IsTrue(Resolved, 'A SKU claimed by one of the subscribers must count as resolved.');
        _Assert.AreEqual(1, ResolutionMock.ClaimCount(), 'Exactly one subscriber may claim a SKU. A second write would silently overwrite the first.');

        // [Then] The item returned is the one that claimed it, not a blend or a later overwrite
        _Assert.IsTrue(
            ItemVariant."Item No." in [Item."No.", CompetingItem."No."],
            'The returned item must be the one a subscriber claimed.');
    end;

    [Test]
    procedure UnknownSku_DecliningSubscriberWroteVariantCode_ReturnsBlankRecord()
    var
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderLine: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        // [Scenario] A subscriber may write to the record and then decline to claim the SKU - deriving a variant code
        // from the Shopify line before finding no item to hang it on, say. Declining is not a bug, but the leftovers
        // must not reach the caller: a blank item number with a variant code beside it is not a partial resolution.

        // [Given] An order line with an unresolvable SKU, and a subscriber that writes a variant code but resolves no item
        CreateShopifyStore();
        OrderLine := CreateOrderLine(5007, _C2SSkuLbl);
        ResolutionMock.SetResolution('', 'LEFTOVER');

        // [When] The order line is resolved to a BC item
        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] The lookup fails quietly - a declining subscriber is not a bug, so no error is raised
        _Assert.IsFalse(Resolved, 'A subscriber that resolves no item must not count as a resolution.');
        _Assert.AreEqual(1, ResolutionMock.CallCount(), 'OnResolveUnknownItem must be raised once for an unresolvable SKU.');

        // [Then] Nothing the subscriber wrote is left behind for the caller to act on
        _Assert.AreEqual('', ItemVariant."Item No.", 'A declined resolution must not leave an item number in the returned record.');
        _Assert.AreEqual('', ItemVariant.Code, 'A declined resolution must not leave a variant code in the returned record.');
    end;

    [Test]
    procedure UnknownSku_SubscriberResolvesNonExistingItem_RaisesProgrammingBugError()
    var
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderLine: JsonToken;
        Sku: Text;
    begin
        // [Scenario] A subscriber resolving to an item that does not exist is a bug in the subscriber, not an
        // unknown SKU. Falling through to the caller's unknown-SKU error would tell the partner the SKU was not
        // recognised when in fact their subscriber claimed it, which is not reconcilable from the outside.

        // [Given] An order line with an unresolvable SKU, and a subscriber that resolves it to a non-existing item
        CreateShopifyStore();
        OrderLine := CreateOrderLine(5005, _C2SSkuLbl);
        ResolutionMock.SetResolution('DOES NOT EXIST', '');

        // [When] The order line is resolved to a BC item
        BindSubscription(ResolutionMock);
        asserterror SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] The error names the item the subscriber picked, and is flagged for the developer rather than the partner
        _Assert.ExpectedError('DOES NOT EXIST');
        _Assert.ExpectedError(_ProgrammingBugLbl);
    end;

    [Test]
    procedure UnknownSku_SubscriberResolvesNonExistingVariant_RaisesProgrammingBugError()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderLine: JsonToken;
        Sku: Text;
    begin
        // [Scenario] A subscriber resolving to an existing item but a variant that does not exist is a bug too, and
        // the worse case to misreport: the item is fine and only the variant is wrong, so an unknown-SKU error would
        // send the partner looking at a SKU that was in fact claimed and an item that in fact exists.

        // [Given] An order line with an unresolvable SKU, and a subscriber that resolves it to an existing item with a non-existing variant
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        OrderLine := CreateOrderLine(5006, _C2SSkuLbl);
        ResolutionMock.SetResolution(Item."No.", 'NOVARIANT');

        // [When] The order line is resolved to a BC item
        BindSubscription(ResolutionMock);
        asserterror SpfyItemMgt.ParseItemForDocumentImport(_StoreCodeLbl, OrderLine, ItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] The error names the variant that does not exist, not the SKU, and is flagged for the developer
        _Assert.ExpectedError('NOVARIANT');
        _Assert.ExpectedError(_ProgrammingBugLbl);
    end;

    [Test]
    procedure PlainParseItem_DoesNotUseSubscriberFallback()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ResolutionMock: Codeunit "NPR Spfy Item Resolution Mock";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        ShopifyVariant: JsonToken;
        Sku: Text;
        Resolved: Boolean;
    begin
        // [Scenario] Plain ParseItem never raises OnResolveUnknownItem - the fallback is reached only through
        // ParseItemForDocumentImport. Callers for which an unresolved SKU is a normal outcome stay on ParseItem and
        // are unaffected by any subscriber.
        //
        // This pins the behaviour of ParseItem itself, not of any caller. Product synchronization is the caller that
        // most depends on it - a fallback item would be linked, assigned Shopify IDs and have its data pushed - but
        // it enters through "NPR Spfy Send Items&Inventory" and is not driven here, so this test would not catch
        // those call sites being moved onto ParseItemForDocumentImport.

        // [Given] A Shopify product variant whose SKU matches no item, and a subscriber that would resolve it
        CreateShopifyStore();
        _LibraryInventory.CreateItem(Item);
        ShopifyVariant := CreateProductVariant('gid://shopify/ProductVariant/6001', _C2SSkuLbl);
        ResolutionMock.SetResolution(Item."No.", '');

        // [When] The SKU is resolved through plain ParseItem
        BindSubscription(ResolutionMock);
        Resolved := SpfyItemMgt.ParseItem(_StoreCodeLbl, ShopifyVariant, ItemVariant, Sku);
        UnbindSubscription(ResolutionMock);

        // [Then] The SKU stays unresolved and the subscriber was never asked
        _Assert.IsFalse(Resolved, 'Plain ParseItem must not resolve a SKU through the subscriber fallback.');
        _Assert.AreEqual('', ItemVariant."Item No.", 'Plain ParseItem must return no item for an unresolvable SKU.');
        _Assert.AreEqual(0, ResolutionMock.CallCount(), 'OnResolveUnknownItem must not be raised by plain ParseItem.');

        // [Then] The SKU is still reported back, so the caller can log which Shopify record was skipped
        _Assert.AreEqual(_C2SSkuLbl, Sku, 'The SKU read from the Shopify JSON must be returned to the caller.');
    end;

    local procedure CreateShopifyStore()
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        if SpfyStore.Get(_StoreCodeLbl) then
            exit;
        SpfyStore.Init();
        SpfyStore.Code := _StoreCodeLbl;
        SpfyStore.Insert();
    end;

    /// <summary>Builds a Shopify order line the way the legacy REST order import receives it.</summary>
    local procedure CreateOrderLine(LineID: BigInteger; Sku: Text) OrderLine: JsonToken
    var
        OrderLineJson: JsonObject;
    begin
        OrderLineJson.Add('id', LineID);
        OrderLineJson.Add('sku', Sku);
        OrderLineJson.Add('title', OrderLineTitle(LineID));
        OrderLineJson.Add('variant_title', 'One Size');
        OrderLineJson.Add('name', StrSubstNo('%1 - One Size', OrderLineTitle(LineID)));
        OrderLine := OrderLineJson.AsToken();
    end;

    local procedure OrderLineTitle(LineID: BigInteger): Text
    begin
        exit(StrSubstNo('Shopify product %1', LineID));
    end;

    /// <summary>Builds a Shopify product variant node the way product synchronization receives it over GraphQL.</summary>
    local procedure CreateProductVariant(VariantGid: Text; Sku: Text) ShopifyVariant: JsonToken
    var
        ShopifyVariantJson: JsonObject;
    begin
        ShopifyVariantJson.Add('id', VariantGid);
        ShopifyVariantJson.Add('sku', Sku);
        ShopifyVariant := ShopifyVariantJson.AsToken();
    end;
}
#endif
