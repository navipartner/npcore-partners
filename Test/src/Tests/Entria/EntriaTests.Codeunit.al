#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85260 "NPR Entria Tests"
{
    // [FEATURE] Entria webhook subscriber + API exposure of entriaProduct
    //
    // NOTE on testing strategy for the price-change webhook:
    //
    // The production publisher "NPR Entria Integr. Webhooks".OnItemUnitPriceChanged
    // is decorated with [ExternalBusinessEvent]. Per Microsoft AL docs, that
    // attribute is intentionally NOT among the subscribable in-process event types
    // (BusinessEvent / IntegrationEvent / InternalEvent / Global / Trigger). When
    // such a procedure is invoked from AL, it does not fan out to in-process AL
    // [EventSubscriber] handlers — the notification is delivered to external HTTP
    // subscribers (Power Automate / webhook subscriptions / Business Events API)
    // only AFTER the surrounding transaction commits. A BC unit test therefore
    // cannot observe the actual dispatch from inside the test process.
    //
    // Instead these tests verify that the production webhook subscriber
    // ("NPR Entria Webhook Subscr.") would REACH the publisher call line under
    // each scenario — i.e. that all of its guards evaluate as expected:
    //   1) Rec.IsTemporary()                  → false
    //   2) Rec."NPR Entria Product"           → true
    //   3) Rec.AreFieldsLoaded("Unit Price")  → true
    //   4) xRec.AreFieldsLoaded("Unit Price") → true
    //   5) Rec."Unit Price" <> xRec."Unit Price"
    //   6) EntriaIntegrationMgt.HasEnabledStore()
    //
    // The TestSub codeunit hooks Item OnBefore/OnAfter ModifyEvent and captures
    // the same Rec/xRec state the production subscriber sees, so we can assert
    // on guards 2–5 directly. Guard 6 is asserted by calling HasEnabledStore()
    // from the test. Verifying the external dispatch itself would require an
    // integration test against a real webhook endpoint.

    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibraryInventory: Codeunit "Library - Inventory";
        _Initialized: Boolean;
        _StoreCode: Code[20];
        _StoreCodeLbl: Label 'NPRENT-TEST', Locked = true;

    [Test]
    procedure WebhookGuards_PriceChangeOnEntriaItemWithEnabledStore_AllGuardsPass()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] Entria item, enabled store, Unit Price changes from 100 to 200.
        // [THEN] All production-subscriber guards evaluate to a state that would
        //        reach the publisher call line.
        Initialize();
        EnableEntriaStore();
        CreateItem(Item, 100, true);

        TestSub.Reset();
        BindSubscription(TestSub);

        Item.Get(Item."No.");
        Item.Validate("Unit Price", 200);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.AreEqual(1, TestSub.GetOnAfterCallCount(), 'OnAfterModifyEvent should fire exactly once');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Guard: Rec."NPR Entria Product" must be true');
        _Assert.IsTrue(TestSub.GetOnAfterXRecLoaded(), 'Guard: xRec."Unit Price" must be loaded');
        _Assert.AreEqual(200, TestSub.GetOnAfterRecPrice(), 'Guard: Rec."Unit Price" must reflect the new value');
        _Assert.AreEqual(100, TestSub.GetOnAfterXRecPrice(), 'Guard: xRec."Unit Price" must reflect the old value');
        _Assert.AreNotEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Guard: Rec."Unit Price" <> xRec."Unit Price" must hold');
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledStore(), 'Guard: HasEnabledStore must be true');
    end;

    [Test]
    procedure WebhookGuards_NonEntriaItemPriceChange_BlockedByEntriaProductFlag()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
    begin
        // [SCENARIO] Item with NPR Entria Product = false has Unit Price changed.
        // [THEN] Production subscriber would early-exit at guard 2 (the flag check).
        Initialize();
        EnableEntriaStore();
        CreateItem(Item, 100, false);

        TestSub.Reset();
        BindSubscription(TestSub);

        Item.Get(Item."No.");
        Item.Validate("Unit Price", 200);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.IsFalse(TestSub.GetOnAfterRecEntriaProduct(),
            'Flag guard: Rec."NPR Entria Product" must be false → production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_EntriaItemDescriptionChange_BlockedByPriceGuard()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
    begin
        // [SCENARIO] Entria item is modified but Unit Price stays the same (Description change).
        // [THEN] Production subscriber would early-exit at guard 5 (price equality).
        Initialize();
        EnableEntriaStore();
        CreateItem(Item, 100, true);

        TestSub.Reset();
        BindSubscription(TestSub);

        Item.Get(Item."No.");
        Item.Description := 'Description changed, price untouched';
        Item.Modify(true);

        UnbindSubscription(TestSub);

        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Entria flag stays true');
        _Assert.AreEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price guard: Rec."Unit Price" must equal xRec."Unit Price" → production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_EntriaItemPriceChangeAllStoresDisabled_BlockedByHasEnabledStore()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] Entria item price changes but no store is enabled.
        // [THEN] Earlier guards (flag, price diff) hold, but HasEnabledStore returns false,
        //        so production exits before publisher call.
        Initialize();
        DisableAllStores();
        CreateItem(Item, 100, true);

        TestSub.Reset();
        BindSubscription(TestSub);

        Item.Get(Item."No.");
        Item.Validate("Unit Price", 200);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Entria flag is true');
        _Assert.AreNotEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price actually changed');
        _Assert.IsFalse(EntriaIntegrationMgt.HasEnabledStore(),
            'Store guard: HasEnabledStore must be false → production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_FlagToggleFalseToTruePriceUnchanged_BlockedByPriceGuard()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
    begin
        // [SCENARIO] Item starts non-Entria with non-zero price; admin flips
        //            NPR Entria Product to true without changing Unit Price.
        // [THEN] Documents the "first-sync edge case": flag toggle alone does not
        //        trigger an initial price sync because guard 5 (price diff) blocks it.
        Initialize();
        EnableEntriaStore();
        CreateItem(Item, 100, false);

        TestSub.Reset();
        BindSubscription(TestSub);

        Item.Get(Item."No.");
        Item.Validate("NPR Entria Product", true);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Flag just got toggled to true');
        _Assert.AreEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price guard: untouched Unit Price means production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_DerivedPriceChangeViaUnitCostValidate_AllGuardsPass()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] Caller validates Unit Cost on an item set to derive Unit Price
        //            from cost. OnValidate side effect changes Unit Price.
        // [THEN] All production guards still pass for the derived new Unit Price,
        //        and OnAfterModifyEvent fires exactly once.
        Initialize();
        EnableEntriaStore();
        CreateItem(Item, 100, true);
        Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"Price=Cost+Profit");
        Item.Validate("Profit %", 0);
        Item.Modify(true);

        TestSub.Reset();
        BindSubscription(TestSub);

        Item.Get(Item."No.");
        Item.Validate("Unit Cost", 250);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.AreEqual(1, TestSub.GetOnAfterCallCount(), 'OnAfterModifyEvent should fire exactly once');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Entria flag is true');
        _Assert.AreNotEqual(100, TestSub.GetOnAfterRecPrice(),
            'Rec."Unit Price" must reflect the derived new value, not the original 100');
        _Assert.AreNotEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price guard: derived Unit Price differs from the pre-modify Unit Price');
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledStore(), 'Store guard: HasEnabledStore is true');
    end;

    local procedure Initialize()
    begin
        if _Initialized then
            exit;
        _Initialized := true;
        EnsureSetupExists();
        _StoreCode := _StoreCodeLbl;
    end;

    local procedure EnsureSetupExists()
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
    begin
        if not EntriaSetup.Get() then begin
            EntriaSetup.Init();
            EntriaSetup.Insert();
        end;
        EntriaSetup."Enable Integration" := true;
        EntriaSetup.Modify();
    end;

    local procedure EnableEntriaStore()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        EnsureSetupExists();
        if not EntriaStore.Get(_StoreCodeLbl) then begin
            EntriaStore.Init();
            EntriaStore.Code := _StoreCodeLbl;
            EntriaStore."Entria Url" := 'https://entria.test';
            EntriaStore.Insert();
        end;
        EntriaStore.Enabled := true;
        EntriaStore.Modify();
    end;

    local procedure DisableAllStores()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        if EntriaStore.FindSet() then
            repeat
                EntriaStore.Enabled := false;
                EntriaStore.Modify();
            until EntriaStore.Next() = 0;
    end;

    local procedure CreateItem(var Item: Record Item; UnitPrice: Decimal; EntriaProduct: Boolean)
    begin
        _LibraryInventory.CreateItem(Item);
        Item.Validate("Unit Price", UnitPrice);
        Item."NPR Entria Product" := EntriaProduct;
        Item.Modify(true);
    end;
}
#endif
