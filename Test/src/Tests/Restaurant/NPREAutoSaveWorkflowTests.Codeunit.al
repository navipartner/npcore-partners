codeunit 85386 "NPR NPRE AutoSave W/Flow Tests"
{
    // [FEATURE] Auto-save to waiter pad workflow injected at end of sale

    Subtype = Test;

    var
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit "Assert";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEnd_AutoSaveWithRoutedItemAndFullPayment_RequestsTheNextServing()
    var
        PreWorkflows: JsonObject;
    begin
        // [SCENARIO] A fast-food sale that is paid in full sends its kitchen-routed items to production without the operator asking

        // [GIVEN] Auto-save is on, the sale holds a kitchen-routed item and nothing is left to pay
        // [WHEN] The end-of-sale workflows are collected
        BuildEndOfSaleWorkflows(true, 1, true, "NPR NPRE Serv.Step Discovery"::"Item Routing Profiles", PreWorkflows);

        // [THEN] The waiter-pad action is queued to request the next serving silently
        AssertRequestNextServingWorkflow(PreWorkflows);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEnd_AutoSaveDisabled_QueuesNoWaiterPadAction()
    var
        PreWorkflows: JsonObject;
    begin
        // [SCENARIO] A restaurant that does not auto-save to the waiter pad never queues the action

        // [GIVEN] Auto-save is off, but the sale would otherwise qualify
        // [WHEN] The end-of-sale workflows are collected
        BuildEndOfSaleWorkflows(false, 1, true, "NPR NPRE Serv.Step Discovery"::"Item Routing Profiles", PreWorkflows);

        // [THEN] No waiter-pad action is queued
        AssertNoWaiterPadWorkflow(PreWorkflows, 'Auto-save must not add a waiter-pad workflow when disabled.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEnd_NothingToProduce_QueuesNoWaiterPadAction()
    var
        PreWorkflows: JsonObject;
    begin
        // [SCENARIO] A sale of items that no kitchen station produces has nothing to send, so no action is queued

        // [GIVEN] Auto-save is on and the sale is paid, but no item is routed to a kitchen
        // [WHEN] The end-of-sale workflows are collected
        BuildEndOfSaleWorkflows(true, 0, true, "NPR NPRE Serv.Step Discovery"::"Item Routing Profiles", PreWorkflows);

        // [THEN] No waiter-pad action is queued
        AssertNoWaiterPadWorkflow(PreWorkflows, 'Auto-save must not add a waiter-pad workflow without a routed item.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEnd_PaymentStillOutstanding_QueuesNoWaiterPadAction()
    var
        PreWorkflows: JsonObject;
    begin
        // [SCENARIO] Production is not requested while the guest still owes money on the sale

        // [GIVEN] Auto-save is on and a kitchen-routed item is on the sale, but the sale is not yet paid
        // [WHEN] The end-of-sale workflows are collected
        BuildEndOfSaleWorkflows(true, 1, false, "NPR NPRE Serv.Step Discovery"::"Item Routing Profiles", PreWorkflows);

        // [THEN] No waiter-pad action is queued
        AssertNoWaiterPadWorkflow(PreWorkflows, 'Auto-save must not add a waiter-pad workflow while payment remains.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEnd_RoutedItemReturned_QueuesNoWaiterPadAction()
    var
        PreWorkflows: JsonObject;
    begin
        // [SCENARIO] A returned kitchen-routed item is not something to produce, so no action is queued

        // [GIVEN] Auto-save is on and the sale's only kitchen-routed item has a negative quantity
        // [WHEN] The end-of-sale workflows are collected
        BuildEndOfSaleWorkflows(true, -1, true, "NPR NPRE Serv.Step Discovery"::"Item Routing Profiles", PreWorkflows);

        // [THEN] No waiter-pad action is queued
        AssertNoWaiterPadWorkflow(PreWorkflows, 'Auto-save must not add a waiter-pad workflow for a returned routed item.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEnd_LegacyServingStepDiscovery_RequestsTheNextServingRegardless()
    var
        PreWorkflows: JsonObject;
    begin
        // [SCENARIO] A restaurant that discovers serving steps from print tags queues the action without inspecting item routing or payment

        // [GIVEN] Serving steps are discovered the legacy way, and the sale has no routed item and is unpaid
        // [WHEN] The end-of-sale workflows are collected
        BuildEndOfSaleWorkflows(true, 0, false, "NPR NPRE Serv.Step Discovery"::"Legacy (using print tags)", PreWorkflows);

        // [THEN] The waiter-pad action is queued anyway
        AssertRequestNextServingWorkflow(PreWorkflows);
    end;

    local procedure BuildEndOfSaleWorkflows(AutoSave: Boolean; RoutedItemQuantity: Decimal; PaymentComplete: Boolean; ServingStepDiscovery: Enum "NPR NPRE Serv.Step Discovery"; var PreWorkflows: JsonObject)
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        Seating: Record "NPR NPRE Seating";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        Parameters: JsonObject;
        Root: JsonObject;
        Context: Codeunit "NPR POS JSON Helper";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        _LibraryRestaurant.SetupTableServiceRestaurant(_POSUnit, Seating, ServiceFlowProfile);
        _LibraryRestaurant.SetAutoSaveToWaiterPadOnSaleEnd(ServiceFlowProfile.Code, AutoSave);
        _LibraryRestaurant.SetServingStepDiscoveryMethod(ServingStepDiscovery);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
        if RoutedItemQuantity <> 0 then begin
            _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
            _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
            _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", RoutedItemQuantity);
        end else
            _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        if PaymentComplete then
            InsertFullPaymentLine();

        Parameters.Add('paymentNo', _POSPaymentMethod.Code);
        Root.Add('parameters', Parameters);
        Context.InitializeJObjectParser(Root);
        _POSSession.GetSale(POSSale);
        _POSSession.GetSetup(POSSetup);

        WaiterPadPOSMgt.AddSaveToWPadAndRequestNextServingWorkflow(POSSale, POSSetup, PreWorkflows, Context);
    end;

    local procedure InsertFullPaymentLine()
    var
        PaymentSaleLine: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SalesAmount: Decimal;
        SubTotal: Decimal;
    begin
        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        POSPaymentLine.GetPaymentLine(PaymentSaleLine);
        PaymentSaleLine."No." := _POSPaymentMethod.Code;
        PaymentSaleLine."Amount Including VAT" := SalesAmount;
        PaymentSaleLine.Amount := SalesAmount;
        POSPaymentLine.InsertPaymentLine(PaymentSaleLine, 0);
    end;

    local procedure AssertRequestNextServingWorkflow(PreWorkflows: JsonObject)
    var
        ActionParameters: JsonObject;
        MainParameters: JsonObject;
        JToken: JsonToken;
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Close w/out Saving";
        WPadLinesToSend: Option "New/Updated",All;
        WorkflowKeys: List of [Text];
    begin
        WorkflowKeys := PreWorkflows.Keys();
        _Assert.AreEqual(1, WorkflowKeys.Count(), 'Auto-save must add exactly one pre-workflow.');
        _Assert.IsTrue(PreWorkflows.Get('RUN_W/PAD_ACTION', JToken), 'Auto-save did not add the waiter-pad action.');
        ActionParameters := JToken.AsObject();
        _Assert.IsTrue(ActionParameters.Get('mainParameters', JToken), 'The waiter-pad action has no main parameters.');
        MainParameters := JToken.AsObject();
        AssertJsonInteger(MainParameters, 'LinesToSend', WPadLinesToSend::"New/Updated");
        AssertJsonInteger(MainParameters, 'WaiterPadAction', WPadAction::"Request Next Serving");
        AssertJsonBoolean(MainParameters, 'MoveSaleToWPadOnFinish', false);
        AssertJsonBoolean(MainParameters, 'ReturnToDefaultView', false);
        AssertJsonBoolean(MainParameters, 'Silent', true);
    end;

    local procedure AssertNoWaiterPadWorkflow(PreWorkflows: JsonObject; Message: Text)
    begin
        _Assert.IsFalse(PreWorkflows.Contains('RUN_W/PAD_ACTION'), Message);
    end;

    local procedure AssertJsonInteger(JObject: JsonObject; PropertyName: Text; ExpectedValue: Integer)
    var
        JToken: JsonToken;
    begin
        _Assert.IsTrue(JObject.Get(PropertyName, JToken), StrSubstNo('Workflow parameter %1 is missing.', PropertyName));
        _Assert.AreEqual(ExpectedValue, JToken.AsValue().AsInteger(), StrSubstNo('Workflow parameter %1 is incorrect.', PropertyName));
    end;

    local procedure AssertJsonBoolean(JObject: JsonObject; PropertyName: Text; ExpectedValue: Boolean)
    var
        JToken: JsonToken;
    begin
        _Assert.IsTrue(JObject.Get(PropertyName, JToken), StrSubstNo('Workflow parameter %1 is missing.', PropertyName));
        _Assert.AreEqual(ExpectedValue, JToken.AsValue().AsBoolean(), StrSubstNo('Workflow parameter %1 is incorrect.', PropertyName));
    end;
}
