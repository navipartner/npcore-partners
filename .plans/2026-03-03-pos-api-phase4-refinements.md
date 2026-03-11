# POS API Phase 4 Refinements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Three refinements to the POS API: align EFT status response with standard delta format, nest selfservice fields in POS unit, and add kitchen order SystemId to webhook + complete response.

**Architecture:** Reuse existing `POSSaleAsJson` for EFT delta (no new table loops), nest POS Unit selfservice fields under a `selfserviceProfile` object, and thread kitchen order SystemId through webhook and complete response.

**Tech Stack:** AL (Business Central), Fern API definitions (YAML), BC test codeunits

---

### Task 1: EFT Status Response — Replace `paymentDelta` with standard delta fields

**Files:**
- Modify: `Application/src/_API_SERVICES/POS/Sale/APIPOSDeltaBuilder.Codeunit.al` — rewrite `BuildFullDataResponse`
- Modify: `Application/src/POS Payment/EFT/Integrations/Adyen/APICloud/APIPOSEFTAdyenCloud.Codeunit.al:178-222` — update `PollEFTStatus`
- Modify: `Test/src/Tests/API/EFTAPITests.Codeunit.al` — update `VerifyPaymentDeltaStructure` and failed payment test assertions
- Modify: `fern/apis/default/definition/pos/possale.yml` — update `EFTStatusResponse` type definition

**Step 1: Rewrite `BuildFullDataResponse` in APIPOSDeltaBuilder**

Replace the current implementation (lines 36-71) which uses `_RefreshPaymentLine.GetFullDataInCurrentSale()` (POS data source format) with a reuse of `APIPOSSale.POSSaleAsJson`:

```al
procedure BuildFullDataResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request") Json: JsonObject
var
    POSSaleLine: Record "NPR POS Sale Line";
    POSSaleRec: Record "NPR POS Sale";
    APIPOSSale: Codeunit "NPR API POS Sale";
    EFTPaymentLineIds: List of [Text];
    EmptySaleLineIds: List of [Text];
    FullResponse: JsonObject;
    Token: JsonToken;
begin
    // Find payment lines matching EFT transaction
    POSSaleLine.SetRange("Register No.", EFTTransactionRequest."Register No.");
    POSSaleLine.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
    POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"POS Payment");
    POSSaleLine.SetRange("No.", EFTTransactionRequest."Original POS Payment Type Code");
    if POSSaleLine.FindSet() then
        repeat
            EFTPaymentLineIds.Add(Format(POSSaleLine.SystemId, 0, 4).ToLower());
        until POSSaleLine.Next() = 0;

    // Get the current sale record
    POSSaleRec.SetRange("Register No.", EFTTransactionRequest."Register No.");
    POSSaleRec.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
    POSSaleRec.FindFirst();

    // Reuse POSSaleAsJson with delta mode — empty sale line IDs = no refreshed sale lines
    // EFT payment line IDs = only those payment lines in refreshedPaymentLines
    // Totals are calculated from ALL lines regardless of refresh filter
    FullResponse := APIPOSSale.POSSaleAsJson(POSSaleRec, true, true, EmptySaleLineIds, EFTPaymentLineIds).Build();

    // Extract only the 6 delta fields (skip sale metadata like saleId, receiptNo, etc.)
    if FullResponse.Get('refreshedSaleLines', Token) then
        Json.Add('refreshedSaleLines', Token);
    if FullResponse.Get('refreshedPaymentLines', Token) then
        Json.Add('refreshedPaymentLines', Token);
    if FullResponse.Get('deletedSaleLines', Token) then
        Json.Add('deletedSaleLines', Token);
    if FullResponse.Get('deletedPaymentLines', Token) then
        Json.Add('deletedPaymentLines', Token);
    if FullResponse.Get('totalSalesAmountInclVat', Token) then
        Json.Add('totalSalesAmountInclVat', Token);
    if FullResponse.Get('totalPaymentAmount', Token) then
        Json.Add('totalPaymentAmount', Token);
end;
```

This removes the dependency on `_RefreshPaymentLine` global var and `POSSession.ConstructFromWebserviceSession` in this method. The `_RefreshPaymentLine`/`_RefreshSaleLine`/`_RefreshSale` global vars remain used by `StartDataCollection` and `BuildDeltaResponse`.

**Step 2: Update `PollEFTStatus` in APIPOSEFTAdyenCloud**

Replace line 218 (`JsonResponse.Add('paymentDelta', APIPOSDeltaBuilder.BuildFullDataResponse(EFTTransactionRequest))`) with merging the delta fields into the response:

```al
if EFTTransactionRequest.Successful then begin
    DeltaFields := APIPOSDeltaBuilder.BuildFullDataResponse(EFTTransactionRequest);
    foreach FieldName in DeltaFields.Keys() do
        if DeltaFields.Get(FieldName, DeltaToken) then
            JsonResponse.Add(FieldName, DeltaToken);
end;
```

Declare new vars: `DeltaFields: JsonObject; FieldName: Text; DeltaToken: JsonToken;`

**Step 3: Update `VerifyPaymentDeltaStructure` in EFTAPITests**

Replace current verification (which checks for `rows` and `totals` in POS data source format) with verification of the new standard delta fields. The procedure now takes the full `ResponseBody` JsonObject instead of a `PaymentDeltaToken`:

```al
local procedure VerifyEFTDeltaFields(ResponseBody: JsonObject; ExpectedAmount: Decimal)
var
    Assert: Codeunit Assert;
    JToken: JsonToken;
    PaymentLinesArray: JsonArray;
    PaymentLine: JsonObject;
begin
    // refreshedSaleLines should be empty (EFT only adds payment lines)
    Assert.IsTrue(ResponseBody.Get('refreshedSaleLines', JToken), 'Should contain refreshedSaleLines');
    Assert.AreEqual(0, JToken.AsArray().Count(), 'refreshedSaleLines should be empty for EFT');

    // refreshedPaymentLines should contain the EFT payment line
    Assert.IsTrue(ResponseBody.Get('refreshedPaymentLines', JToken), 'Should contain refreshedPaymentLines');
    PaymentLinesArray := JToken.AsArray();
    Assert.IsTrue(PaymentLinesArray.Count() > 0, 'refreshedPaymentLines should have at least one line');

    // Verify payment line has expected fields (id, sortKey, paymentMethodCode, description, amountInclVat)
    PaymentLinesArray.Get(0, JToken);
    PaymentLine := JToken.AsObject();
    Assert.IsTrue(PaymentLine.Contains('id'), 'Payment line should have id');
    Assert.IsTrue(PaymentLine.Contains('sortKey'), 'Payment line should have sortKey');
    Assert.IsTrue(PaymentLine.Contains('paymentMethodCode'), 'Payment line should have paymentMethodCode');
    Assert.IsTrue(PaymentLine.Contains('amountInclVat'), 'Payment line should have amountInclVat');

    // deletedSaleLines and deletedPaymentLines should be empty
    Assert.IsTrue(ResponseBody.Get('deletedSaleLines', JToken), 'Should contain deletedSaleLines');
    Assert.AreEqual(0, JToken.AsArray().Count(), 'deletedSaleLines should be empty');
    Assert.IsTrue(ResponseBody.Get('deletedPaymentLines', JToken), 'Should contain deletedPaymentLines');
    Assert.AreEqual(0, JToken.AsArray().Count(), 'deletedPaymentLines should be empty');

    // Totals
    Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Should contain totalSalesAmountInclVat');
    Assert.AreEqual(ExpectedAmount, JToken.AsValue().AsDecimal(), 'totalSalesAmountInclVat should equal item price');
    Assert.IsTrue(ResponseBody.Get('totalPaymentAmount', JToken), 'Should contain totalPaymentAmount');
    Assert.AreEqual(ExpectedAmount, JToken.AsValue().AsDecimal(), 'totalPaymentAmount should equal item price');
end;
```

Also update the happy path test call from `VerifyPaymentDeltaStructure(JToken, ...)` to `VerifyEFTDeltaFields(ResponseBody, ...)`.

Update the failed payment test: replace `Assert.IsFalse(ResponseBody.Get('paymentDelta', JToken), ...)` with assertions that delta fields are NOT present (since `Successful` is false).

**Step 4: Update fern `EFTStatusResponse` in possale.yml**

Replace `paymentDelta: optional<map<string, unknown>>` with the 6 standard fields:

```yaml
  EFTStatusResponse:
    docs: Response with the current status of an EFT transaction
    properties:
      transactionId: transactionId
      status: EFTTransactionStatus
      successful: boolean
      resultCode:
        type: optional<string>
        docs: Result code from the payment provider (present when result is known)
      cardNumber:
        type: optional<string>
        docs: Masked card number (present when result is known)
      cardName:
        type: optional<string>
        docs: Card brand name (present when result is known)
      authorizationNumber:
        type: optional<string>
        docs: Authorization number from the payment provider (present when result is known)
      resultMessage:
        type: optional<string>
        docs: Human-readable result message (present when result is known)
      refreshedSaleLines:
        type: optional<list<POSSaleLineResponse>>
        docs: Sale lines created or modified as a result of the EFT payment (typically empty since EFT only adds payment lines). Present only when successful.
      refreshedPaymentLines:
        type: optional<list<POSPaymentLineResponse>>
        docs: Payment lines created by the EFT payment. Present only when successful.
      deletedSaleLines:
        type: optional<list<string>>
        docs: SystemIds of sale lines deleted during the payment (typically empty). Present only when successful.
      deletedPaymentLines:
        type: optional<list<string>>
        docs: SystemIds of payment lines deleted during the payment (typically empty). Present only when successful.
      totalSalesAmountInclVat:
        type: optional<double>
        docs: Total of all sale lines including VAT. Present only when successful.
      totalPaymentAmount:
        type: optional<double>
        docs: Total of all payment lines. Present only when successful.
```

Update the examples to match.

**Step 5: Run `fern check`**

Run: `cd fern && fern check`
Expected: 0 errors

**Step 6: Commit**

```
git add Application/src/_API_SERVICES/POS/Sale/APIPOSDeltaBuilder.Codeunit.al \
  "Application/src/POS Payment/EFT/Integrations/Adyen/APICloud/APIPOSEFTAdyenCloud.Codeunit.al" \
  Test/src/Tests/API/EFTAPITests.Codeunit.al \
  fern/apis/default/definition/pos/possale.yml
git commit -m "refactor: align EFT status response with standard delta format (refreshedSaleLines etc.)"
```

---

### Task 2: POS Unit — Nest selfservice fields under `selfserviceProfile`

**Files:**
- Modify: `Application/src/_API_SERVICES/POS/Unit/APIPOSUnit.Codeunit.al` — update `POSUnitToJson`
- Modify: `fern/apis/default/definition/pos/unit.yml` — restructure `POSUnit` type
- Modify: `Test/src/Tests/API/EFTAPITests.Codeunit.al` — no existing POS unit tests to change, but verify EFT tests still pass (they don't test unit response fields)

**Step 1: Update `POSUnitToJson` in APIPOSUnit**

Replace lines that add flat fields:
```al
// Current:
Json.Add('qrCardPaymentMethod', SSProfile."QR Card Payment Method");
Json.Add('selfserviceCardPaymentMethod', SSProfile."Selfservice Card Payment Meth.");

// New:
var
    SelfserviceProfileJson: JsonObject;
begin
    ...
    if (POSUnit."POS Self Service Profile" <> '') and SSProfile.Get(POSUnit."POS Self Service Profile") then begin
        SelfserviceProfileJson.Add('qrCardPaymentMethod', SSProfile."QR Card Payment Method");
        SelfserviceProfileJson.Add('selfserviceCardPaymentMethod', SSProfile."Selfservice Card Payment Meth.");
        Json.Add('selfserviceProfile', SelfserviceProfileJson);
    end;
```

**Step 2: Update fern unit.yml**

Replace flat fields with nested type:

```yaml
types:
  SelfserviceProfile:
    docs: Self-service configuration resolved from the unit's Self Service Profile
    properties:
      qrCardPaymentMethod:
        type: optional<string>
        docs: Default POS payment method code for QR code card payments
      selfserviceCardPaymentMethod:
        type: optional<string>
        docs: POS payment method code for selfservice EFT terminal payments

  POSUnit:
    properties:
      id: uuid
      code: string
      name: string
      posStoreCode:
        type: string
        docs: The code of the POS Store that the unit is associated with.
      selfserviceProfile:
        type: optional<SelfserviceProfile>
        docs: Self-service configuration from the unit's Self Service Profile. Only present when the unit has a profile assigned.
```

Update examples: `ExamplePOSUnitSelfService` gets nested `selfserviceProfile:` object.

**Step 3: Run `fern check`**

Run: `cd fern && fern check`
Expected: 0 errors

**Step 4: Commit**

```
git add Application/src/_API_SERVICES/POS/Unit/APIPOSUnit.Codeunit.al \
  fern/apis/default/definition/pos/unit.yml
git commit -m "refactor: nest POS Unit selfservice fields under selfserviceProfile object"
```

---

### Task 3: Kitchen Order — Add SystemId to webhook and complete response

**Files:**
- Modify: `Application/src/Restaurant/Menu/NPRERestaurantWebhooks.Codeunit.al` — add `kitchenOrderId` parameter
- Modify: `Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al:324-340,427-447` — update `POSEntryAsJson` and `GetKitchenOrderNoFromPOSEntry`
- Modify: `Application/src/_API_SERVICES/restaurant/APIRestKitchenOrders.Codeunit.al` — add `orderId` (SystemId) field to GET responses
- Modify: `Test/src/Tests/API/KitchenOrderAPITests.Codeunit.al` — add assertions for `kitchenOrderId`
- Modify: `fern/apis/default/definition/pos/possale.yml` — add `kitchenOrderId` to `POSEntryResponse`
- Modify: `fern/apis/default/definition/restaurant/webhooks.yml` — add `kitchenOrderId` to webhook payload
- Modify: `fern/apis/default/definition/restaurant/orders.yml` — add `orderId` to kitchen order response type

**Step 1: Add `kitchenOrderId` to webhook in NPRERestaurantWebhooks**

Add a second parameter to the ExternalBusinessEvent procedure:

```al
procedure InvokeOrderReadyForServingWebhook(SystemId: Guid)
var
    KitchenOrder: Record "NPR NPRE Kitchen Order";
begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
    KitchenOrder.GetBySystemId(SystemId);
    OnOrderReadyForServing(Format(KitchenOrder."Order ID"), Format(SystemId, 0, 4).ToLower());
    OnAfterOrderReadyForServingWebhook(KitchenOrder."Order ID");
#endif
end;

// Update signature:
[ExternalBusinessEvent('restaurant_order_ready_for_serving', ...)]
local procedure OnOrderReadyForServing(kitchenOrderNo: Text[250]; kitchenOrderId: Text[50])
begin
end;
```

**Step 2: Update `GetKitchenOrderNoFromPOSEntry` and `POSEntryAsJson` in APIPOSSale**

Change `GetKitchenOrderNoFromPOSEntry` to also return SystemId via var parameter:

```al
local procedure GetKitchenOrderNoFromPOSEntry(POSEntryNo: Integer; var KitchenOrderSystemId: Guid): BigInteger
var
    POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
    KitchenReqSrcLink: Record "NPR NPRE Kitchen Req.Src. Link";
    KitchenRequest: Record "NPR NPRE Kitchen Request";
    KitchenOrder: Record "NPR NPRE Kitchen Order";
begin
    POSEntryWaiterPadLink.SetRange("POS Entry No.", POSEntryNo);
    if not POSEntryWaiterPadLink.FindFirst() then
        exit(0);

    KitchenReqSrcLink.SetRange("Source Document Type", KitchenReqSrcLink."Source Document Type"::"Waiter Pad");
    KitchenReqSrcLink.SetRange("Source Document No.", POSEntryWaiterPadLink."Waiter Pad No.");
    if not KitchenReqSrcLink.FindFirst() then
        exit(0);

    if not KitchenRequest.Get(KitchenReqSrcLink."Request No.") then
        exit(0);

    KitchenOrder.SetRange("Order ID", KitchenRequest."Order ID");
    if KitchenOrder.FindFirst() then
        KitchenOrderSystemId := KitchenOrder.SystemId;

    exit(KitchenRequest."Order ID");
end;
```

Update `POSEntryAsJson`:
```al
local procedure POSEntryAsJson(POSEntry: Record "NPR POS Entry") Json: Codeunit "NPR Json Builder"
var
    KitchenOrderNo: BigInteger;
    KitchenOrderSystemId: Guid;
begin
    Json.StartObject('')
        .AddProperty('entryNo', POSEntry."Entry No.")
        .AddProperty('entryId', Format(POSEntry.SystemId, 0, 4).ToLower())
        .AddProperty('documentNo', POSEntry."Document No.")
        .AddProperty('totalAmountInclVat', POSEntry."Amount Incl. Tax");

    KitchenOrderNo := GetKitchenOrderNoFromPOSEntry(POSEntry."Entry No.", KitchenOrderSystemId);
    if KitchenOrderNo <> 0 then begin
        Json.AddProperty('kitchenOrderNo', Format(KitchenOrderNo));
        Json.AddProperty('kitchenOrderId', Format(KitchenOrderSystemId, 0, 4).ToLower());
    end;

    Json.EndObject();
end;
```

**Step 3: Add `orderId` to kitchen order GET responses**

In `APIRestKitchenOrders.Codeunit.al`, add `.AddProperty('orderId', Format(KitchenOrder.SystemId, 0, 4).ToLower())` as the first property in both the list loop (line 91) and single order response (line 157). Also add `SystemId` to `SetLoadFields` calls (lines 68-77 and 140-149).

**Step 4: Update kitchen order tests**

In `KitchenOrderAPITests.Codeunit.al`:
- In `CreateSaleWithKitchenOrder`: also extract and return `kitchenOrderId` from the complete response (change return type or add a var parameter)
- In `GetKitchenOrders_AfterCompleteSaleWithKitchenRequest_ReturnsOrders`: verify `kitchenOrderId` field exists in the complete response
- In `GetKitchenOrders_ReturnsExpectedFields`: add `Assert.IsTrue(OrderObj.Contains('orderId'), ...)`
- In `GetKitchenOrder_BySystemId_ReturnsOrder`: verify `orderId` matches the expected SystemId

**Step 5: Update fern definitions**

In `possale.yml` — add to `POSEntryResponse`:
```yaml
kitchenOrderId:
  type: optional<uuid>
  docs: SystemId of the kitchen order, for use with GET /restaurant/{restaurantId}/orders/{orderId}
```

In `webhooks.yml` — add to `OrderReadyForServingEventPayload`:
```yaml
kitchenOrderId:
  type: uuid
  docs: SystemId of the kitchen order, for use with GET /restaurant/{restaurantId}/orders/{orderId}
```

In `orders.yml` — add `orderId: uuid` to the kitchen order type and update examples.

**Step 6: Run `fern check`**

Run: `cd fern && fern check`
Expected: 0 errors

**Step 7: Commit**

```
git add Application/src/Restaurant/Menu/NPRERestaurantWebhooks.Codeunit.al \
  Application/src/_API_SERVICES/POS/Sale/APIPOSSale.Codeunit.al \
  Application/src/_API_SERVICES/restaurant/APIRestKitchenOrders.Codeunit.al \
  Test/src/Tests/API/KitchenOrderAPITests.Codeunit.al \
  fern/apis/default/definition/pos/possale.yml \
  fern/apis/default/definition/restaurant/webhooks.yml \
  fern/apis/default/definition/restaurant/orders.yml
git commit -m "feat: add kitchen order SystemId to webhook, complete response, and GET endpoints"
```

---

### Task 4: Compile, publish, and run all tests

**Step 1: Compile and publish**

Use `/bcdev` skill to compile Application and Test apps against dev server with suppressWarnings.

**Step 2: Run all tests**

- EFT API tests (85169): expect 14 passing
- POS API tests (85157): expect 27 passing
- Kitchen Order API tests (85159): expect 8 passing
- Total: 49 passing

**Step 3: Final `fern check`**

Run: `cd fern && fern check`
Expected: 0 errors

**Step 4: Commit all remaining changes and push**

```
git push
```
