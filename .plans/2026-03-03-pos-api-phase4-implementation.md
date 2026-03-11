# POS API Phase 4 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement 5 changes: remove unitPrice from PATCH sale line, add GET specific kitchen order endpoint, refactor print endpoints via IRetailPrintHandler interface, refactor TryFunction cleanup job, implement EFT API for Adyen Cloud.

**Architecture:** Uses NP Retail's custom REST API framework (not OData). All new API code gated behind `#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)`. Interface-based print dispatch via SingleInstance registry. EFT uses synchronous HTTP on web service session with consumer polling.

**Tech Stack:** AL (Business Central), Fern API documentation (YAML), BC test framework

**Design doc:** `.plans/2026-03-03-pos-api-phase4-design.md`

**Allocated Object IDs:**

| Object | ID | Name |
|--------|------|------|
| Codeunit | 6151081 | NPR Default Retail Print Handler |
| Codeunit | 6151082 | NPR Retail Print Handler Reg. |
| Codeunit | 6151083 | NPR API Retail Print Handler |
| Codeunit | 6151087 | NPR JQ Cleanup Delete Sale |
| Codeunit | 6151088 | NPR JQ Cleanup Park Sale |
| Codeunit | 6151089 | NPR API POS EFT Adyen Cloud |
| Enum | 6014609 | NPR Retail Print Handler Type |
| Table Field | 3 (on table 6150681) | Selfservice Card Payment Method |
| Codeunit (Test) | 85169 | EFT API Tests |

---

## Task 1: Remove unitPrice from PATCH POS Sale Line

**Files:**
- Modify: `Application/src/_API_SERVICES/POS/Sale/APIPOSSaleLine.Codeunit.al:354-382`
- Modify: `fern/apis/default/definition/pos/possale.yml:134-145`

**Step 1: Remove unitPrice from AL code**

In `APIPOSSaleLine.Codeunit.al`, modify `UpdateSaleLineFromJson`:
- Remove the `UnitPrice: Decimal;` variable declaration (line 357)
- Remove these two lines (367-368):
```al
    if GetJsonDecimal(Body, 'unitPrice', UnitPrice) then
        POSSaleLine.SetUnitPrice(UnitPrice);
```

The procedure should look like:
```al
local procedure UpdateSaleLineFromJson(Body: JsonToken; LinePosition: Text)
var
    Quantity: Decimal;
    DiscountAmount: Decimal;
    DescriptionText: Text;
    POSSession: Codeunit "NPR POS Session";
    POSSaleLine: Codeunit "NPR POS Sale Line";
    POSSaleLineRec: Record "NPR POS Sale Line";
begin
    POSSession.GetSaleLine(POSSaleLine);
    POSSaleLine.SetPosition(LinePosition);

    if GetJsonDecimal(Body, 'quantity', Quantity) then
        POSSaleLine.SetQuantity(Quantity);

    if GetJsonText(Body, 'description', DescriptionText) then
        POSSaleLine.SetDescription(CopyStr(DescriptionText, 1, 100));

    if GetJsonDecimal(Body, 'discountAmount', DiscountAmount) then begin
        POSSaleLine.GetCurrentSaleLine(POSSaleLineRec);
        POSSaleLineRec.Validate("Discount Amount", DiscountAmount);
        POSSaleLineRec.Modify(true);
        POSSaleLine.RefreshCurrent();
    end;
end;
```

**Step 2: Remove unitPrice from Fern spec**

In `fern/apis/default/definition/pos/possale.yml`, modify `UpdatePOSSaleLine` type:

Change from:
```yaml
  UpdatePOSSaleLine:
    docs: Request body for updating a sale line
    properties:
      quantity: optional<double>
      unitPrice: optional<double>
      discountAmount: optional<double>
      description: optional<string>
    examples:
      - name: ExampleUpdateLine
        value:
          quantity: 3
          unitPrice: 45.00
```

To:
```yaml
  UpdatePOSSaleLine:
    docs: Request body for updating a sale line
    properties:
      quantity: optional<double>
      discountAmount: optional<double>
      description: optional<string>
    examples:
      - name: ExampleUpdateLine
        value:
          quantity: 3
```

**Step 3: Run fern check**

```bash
cd fern && fern check
```
Expected: No errors related to possale.yml changes.

**Step 4: Commit**
```
feat: remove unitPrice from PATCH sale line API

The unitPrice parameter was ambiguous (could be with/without VAT).
Removed from both AL code and Fern API spec.
```

---

## Task 2: Fix Kitchen Order Status Enum in Fern + Add GET Specific Order

### Part A: Fix the KitchenOrderStatus enum in Fern

**Files:**
- Modify: `fern/apis/default/definition/restaurant/types-restaurant.yml:290-317`
- Modify: `fern/apis/default/definition/restaurant/orders.yml`

**Step 1: Add KitchenOrderStatus enum and fix KitchenOrder type**

In `types-restaurant.yml`, add the enum type BEFORE the `KitchenOrder` type:

```yaml
  KitchenOrderStatus:
    enum:
      - name: ReadyForServing
        value: "Ready for Serving"
      - name: InProduction
        value: "In-Production"
      - name: Released
        value: "Released"
      - name: Planned
        value: "Planned"
      - name: Finished
        value: "Finished"
      - name: Cancelled
        value: "Cancelled"
```

Then update the `KitchenOrder` type's `status` field:

Change from:
```yaml
    status:
      type: string
      docs: Order status
```

To:
```yaml
    status:
      type: KitchenOrderStatus
      docs: Order status
```

**Step 2: Fix the example in orders.yml**

In `orders.yml`, change the example from `status: "Active"` to `status: "Planned"` (line ~50).

Also fix the `KitchenOrdersResponse` example if it contains `"Active"`.

**Step 3: Add GET specific order endpoint to orders.yml**

Add after the `getKitchenOrders` endpoint:

```yaml
    getKitchenOrder:
      display-name: Get Kitchen Order
      docs: Get a specific kitchen order by its ID
      method: GET
      path: "/{orderId}"
      path-parameters:
        orderId:
          docs: The kitchen order system ID
          type: uuid
      response: types.KitchenOrder
      examples:
        - name: ExampleGetKitchenOrder
          path-parameters:
            tenant: $globalApiTypes.tenant.Exampletenant
            environment: $globalApiTypes.environment.ExampleenvironmentProduction
            company: $globalApiTypes.Company.ExampleCompanyCronus
            restaurantId: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
            orderId: "b2c3d4e5-f6a7-8901-bcde-f12345678901"
          response:
            body:
              orderNo: 1001
              restaurantCode: "BISTRO01"
              status: "Planned"
              priority: 1
              createdDateTime: "2024-01-15T14:30:00Z"
              expectedDineDateTime: "2024-01-15T15:00:00Z"
              onHold: false
```

**Step 4: Run fern check**
```bash
cd fern && fern check
```

### Part B: Implement GET specific order in AL

**Files:**
- Modify: `Application/src/_API_SERVICES/restaurant/APIRestKitchenOrders.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/restaurant/APIRestaurantHandler.Codeunit.al`

**Step 5: Add route to APIRestaurantHandler**

In `APIRestaurantHandler.Codeunit.al`, add the new route BEFORE the existing list route (more specific routes must come first):

```al
            Request.Match('GET', '/restaurant/:restaurantId/orders/:orderId'):
                exit(APIKitchenOrders.GetKitchenOrder(Request));
            Request.Match('GET', '/restaurant/:restaurantId/orders'):
                exit(APIKitchenOrders.GetKitchenOrders(Request));
```

**Step 6: Add GetKitchenOrder procedure to APIRestKitchenOrders**

Add this procedure to `APIRestKitchenOrders.Codeunit.al`:

```al
    procedure GetKitchenOrder(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Restaurant: Record "NPR NPRE Restaurant";
        Json: Codeunit "NPR JSON Builder";
        RestaurantId: Guid;
        OrderId: Guid;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if not Evaluate(RestaurantId, Request.Paths().Get(2)) then
            exit(Response.RespondBadRequest('Invalid restaurantId format'));

        if not Evaluate(OrderId, Request.Paths().Get(4)) then
            exit(Response.RespondBadRequest('Invalid orderId format'));

        Restaurant.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Restaurant.GetBySystemId(RestaurantId) then
            exit(Response.RespondResourceNotFound());

        KitchenOrder.ReadIsolation := IsolationLevel::ReadCommitted;
        KitchenOrder.SetLoadFields(
            "Order ID",
            "Restaurant Code",
            "Order Status",
            Priority,
            "Created Date-Time",
            "Expected Dine Date-Time",
            "Finished Date-Time",
            "On Hold"
        );
        if not KitchenOrder.GetBySystemId(OrderId) then
            exit(Response.RespondResourceNotFound());

        if KitchenOrder."Restaurant Code" <> Restaurant.Code then
            exit(Response.RespondResourceNotFound());

        Json.StartObject('')
            .AddProperty('orderNo', KitchenOrder."Order ID")
            .AddProperty('restaurantCode', KitchenOrder."Restaurant Code")
            .AddProperty('status', Format(KitchenOrder."Order Status"))
            .AddProperty('priority', KitchenOrder.Priority)
            .AddProperty('createdDateTime', Format(KitchenOrder."Created Date-Time", 0, 9))
            .AddProperty('expectedDineDateTime', Format(KitchenOrder."Expected Dine Date-Time", 0, 9))
            .AddProperty('finishedDateTime', Format(KitchenOrder."Finished Date-Time", 0, 9))
            .AddProperty('onHold', KitchenOrder."On Hold")
        .EndObject();

        exit(Response.RespondOK(Json.BuildAsObject()));
    end;
```

### Part C: Add test for GET specific kitchen order

**Files:**
- Modify: `Test/src/Tests/API/KitchenOrderAPITests.Codeunit.al`

**Step 7: Add test procedure**

Add a new test to `KitchenOrderAPITests.Codeunit.al` that follows the existing test patterns. The test should:

1. Call `Initialize()` (existing setup procedure)
2. Create a POS sale via API (POST `/pos/sale/:saleId`)
3. Add a sale line with the kitchen-eligible item
4. Complete the sale with kitchenRequest body containing seating code and guests
5. GET `/restaurant/:restaurantId/orders` to find the created order
6. Extract the order's SystemId from the response
7. GET `/restaurant/:restaurantId/orders/:orderId` with that SystemId
8. Assert all header fields are present and valid (status = "Planned", restaurantCode matches, etc.)

Follow the exact test patterns from existing tests in the file — use `LibraryNPRetailAPI.CallApi()` for API calls, `LibraryNPRetailAPI.IsSuccessStatusCode()` for assertions, and the same initialization and cleanup patterns.

**Step 8: Run fern check**
```bash
cd fern && fern check
```

**Step 9: Commit**
```
feat: add GET specific kitchen order endpoint and fix status enum

- Add GET /restaurant/:restaurantId/orders/:orderId endpoint
- Change KitchenOrder.status from string to KitchenOrderStatus enum in Fern
- Fix incorrect "Active" example value to "Planned"
- Add test that creates sale with kitchen request then GETs the order
```

---

## Task 3: Print Endpoint Refactoring via IRetailPrintHandler

### Part A: Create the interface and enum

**Files:**
- Create: `Application/src/Retail Print/IRetailPrintHandler.Interface.al`
- Create: `Application/src/Retail Print/RetailPrintHandlerType.Enum.al`

**Step 1: Create IRetailPrintHandler interface**

```al
interface "NPR IRetail Print Handler"
{
#if not BC17
    Access = Internal;
#endif

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
}
```

**Step 2: Create RetailPrintHandlerType enum**

```al
enum 6014609 "NPR Retail Print Handler Type" implements "NPR IRetail Print Handler"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Default")
    {
        Implementation = "NPR IRetail Print Handler" = "NPR Default Retail Print Handler";
    }
}
```

### Part B: Create default implementation

**Files:**
- Create: `Application/src/Retail Print/DefaultRetailPrintHandler.Codeunit.al`

**Step 3: Create DefaultRetailPrintHandler**

```al
codeunit 6151081 "NPR Default Retail Print Handler" implements "NPR IRetail Print Handler"
{
    Access = Internal;

    var
        _PrintMethodMgt: Codeunit "NPR Print Method Mgt.";

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    begin
        _PrintMethodMgt.PrintBytesLocal(PrinterName, PrintJobBase64);
    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    begin
        _PrintMethodMgt.PrintFileLocal(PrinterName, Stream, FileExtension);
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    begin
        _PrintMethodMgt.PrintBytesHTTP(URL, Endpoint, PrintJobBase64);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    begin
        _PrintMethodMgt.PrintBytesBluetooth(DeviceName, PrintJobBase64);
    end;

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    begin
        _PrintMethodMgt.PrintViaPrintNodeRaw(PrinterID, PrintJobBase64, ObjectType, ObjectID);
    end;
}
```

### Part C: Create SingleInstance registry

**Files:**
- Create: `Application/src/Retail Print/RetailPrintHandlerReg.Codeunit.al`

**Step 4: Create RetailPrintHandlerReg**

```al
codeunit 6151082 "NPR Retail Print Handler Reg."
{
    Access = Internal;
    SingleInstance = true;

    var
        _Handler: Interface "NPR IRetail Print Handler";
        _Active: Boolean;

    internal procedure SetHandler(Handler: Interface "NPR IRetail Print Handler")
    begin
        _Handler := Handler;
        _Active := true;
    end;

    internal procedure GetHandler(var Handler: Interface "NPR IRetail Print Handler"): Boolean
    begin
        if _Active then begin
            Handler := _Handler;
            exit(true);
        end;
        exit(false);
    end;

    internal procedure ClearHandler()
    begin
        Clear(_Handler);
        _Active := false;
    end;

    internal procedure IsActive(): Boolean
    begin
        exit(_Active);
    end;
}
```

### Part D: Create API print handler

**Files:**
- Create: `Application/src/_API_SERVICES/POS/Entry/APIRetailPrintHandler.Codeunit.al`

**Step 5: Create API implementation**

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151083 "NPR API Retail Print Handler" implements "NPR IRetail Print Handler"
{
    Access = Internal;

    var
        _CapturedJobs: JsonArray;
        _UnsupportedOutputLbl: Label 'Output type %1 is not supported for API printing. This is a programming bug.';

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    begin
        AddCapturedJob('raw', PrinterName, PrintJobBase64);
    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        Base64String: Text;
    begin
        Base64String := Base64Convert.ToBase64(Stream);
        AddCapturedJob(FileExtension, PrinterName, Base64String);
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    begin
        AddCapturedHTTPJob(URL, Endpoint, PrintJobBase64);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    begin
        Error(_UnsupportedOutputLbl, 'Bluetooth');
    end;

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    begin
        AddCapturedJob('raw', PrinterID, PrintJobBase64);
    end;

    local procedure AddCapturedJob(PrintJobFormat: Text; OutputPath: Text; PrintJobBase64: Text)
    var
        Job: JsonObject;
    begin
        Job.Add('printJobFormat', PrintJobFormat);
        Job.Add('outputPath', OutputPath);
        Job.Add('printJob', PrintJobBase64);
        _CapturedJobs.Add(Job);
    end;

    local procedure AddCapturedHTTPJob(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    var
        Job: JsonObject;
    begin
        Job.Add('printJobFormat', 'http');
        Job.Add('outputPath', URL);
        Job.Add('httpEndpoint', Endpoint);
        Job.Add('printJob', PrintJobBase64);
        _CapturedJobs.Add(Job);
    end;

    internal procedure GetCapturedJobs(): JsonArray
    begin
        exit(_CapturedJobs);
    end;

    internal procedure HasCapturedJobs(): Boolean
    begin
        exit(_CapturedJobs.Count() > 0);
    end;
}
#endif
```

### Part E: Refactor ObjectOutputMgt to use the registry

**Files:**
- Modify: `Application/src/Retail Print/_public/ObjectOutputMgt.Codeunit.al:154-205` (PrintLineJob)
- Modify: `Application/src/Retail Print/_public/ObjectOutputMgt.Codeunit.al:102-152` (PrintMatrixJob)

**Step 6: Refactor PrintLineJob**

The current `PrintLineJob` procedure (lines 154-205) routes to `PrintMethodMgt` directly. Refactor to check the registry first.

After the `OnBeforeSendLinePrint` event + Skip check and after `TryGetPrintOutput`, insert the registry check:

```al
    internal procedure PrintLineJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR ILine Printer"; NoOfPrints: Integer)
    var
        ObjectOutput: Record "NPR Object Output Selection";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        RetailPrintHandlerReg: Codeunit "NPR Retail Print Handler Reg.";
        Handler: Interface "NPR IRetail Print Handler";
        PrintJob: Text;
        HTTPEndpoint: Text;
        Skip: Boolean;
        i: Integer;
    begin
        if NoOfPrints < 1 then
            exit;
        OnBeforeSendLinePrint(TemplateCode, CodeunitId, ReportId, Printer, NoOfPrints, Skip);
        if Skip then
            exit;
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
            exit;

        if RetailPrintHandlerReg.GetHandler(Handler) then begin
            DispatchLineJobViaHandler(Handler, ObjectOutput, Printer, NoOfPrints);
            exit;
        end;

        case ObjectOutput."Output Type" of
            ObjectOutput."Output Type"::"Printer Name":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesLocal(ObjectOutput."Output Path", PrintJob);
                end;

            ObjectOutput."Output Type"::HTTP:
                begin
                    if not Printer.PrepareJobForHTTP(HTTPEndpoint) then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), TemplateCode);
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintJob);
                end;

            ObjectOutput."Output Type"::Bluetooth:
                begin
                    if not Printer.PrepareJobForBluetooth() then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), TemplateCode);
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesBluetooth(ObjectOutput."Output Path", PrintJob);
                end;

            ObjectOutput."Output Type"::"PrintNode Raw":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintViaPrintNodeRaw(ObjectOutput."Output Path", PrintJob, 1, CodeunitId);
                end;
        end;
    end;
```

Add the dispatch helper as a new local procedure:

```al
    local procedure DispatchLineJobViaHandler(var Handler: Interface "NPR IRetail Print Handler"; var ObjectOutput: Record "NPR Object Output Selection"; var Printer: Interface "NPR ILine Printer"; NoOfPrints: Integer)
    var
        PrintJob: Text;
        HTTPEndpoint: Text;
        i: Integer;
    begin
        case ObjectOutput."Output Type" of
            ObjectOutput."Output Type"::"Printer Name":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        Handler.PrintBytesLocal(ObjectOutput."Output Path", PrintJob);
                end;

            ObjectOutput."Output Type"::HTTP:
                begin
                    if not Printer.PrepareJobForHTTP(HTTPEndpoint) then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), '');
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        Handler.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintJob);
                end;

            ObjectOutput."Output Type"::Bluetooth:
                begin
                    if not Printer.PrepareJobForBluetooth() then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), '');
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        Handler.PrintBytesBluetooth(ObjectOutput."Output Path", PrintJob);
                end;

            ObjectOutput."Output Type"::"PrintNode Raw":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        Handler.PrintViaPrintNodeRaw(ObjectOutput."Output Path", PrintJob, 1, 0);
                end;
        end;
    end;
```

**Step 7: Apply same pattern to PrintMatrixJob**

Same refactoring for `PrintMatrixJob` — check the registry after resolving output config, dispatch via handler if active. Create a corresponding `DispatchMatrixJobViaHandler` local procedure.

### Part F: Refactor APIPOSEntry to use RetailReportSelectMgt

**Files:**
- Modify: `Application/src/_API_SERVICES/POS/Entry/APIPOSEntry.Codeunit.al:118-239`

**Step 8: Refactor PrintPosEntry and remove PrintSalesReceipt**

Replace the current `PrintPosEntry` (lines 118-167) and `PrintSalesReceipt` (lines 169-226) with a unified flow using `RetailReportSelectMgt`:

```al
    internal procedure PrintPosEntry(var Request: Codeunit "NPR API Request"; ReportSelectionType: Enum "NPR Report Selection Type") Response: Codeunit "NPR API Response"
    var
        POSEntry: Record "NPR POS Entry";
        APIPrintHandler: Codeunit "NPR API Retail Print Handler";
        Registry: Codeunit "NPR Retail Print Handler Reg.";
        RetailReportSelectMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        entryId: Text;
        JsonResponse: JsonObject;
    begin
        entryId := Request.Paths().Get(3);
        if (entryId = '') then
            exit(Response.RespondBadRequest('Missing required path parameter: entryId'));

        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        POSEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        if (not POSEntry.GetBySystemId(entryId)) then
            exit(Response.RespondResourceNotFound());

        Registry.SetHandler(APIPrintHandler);

        RetailReportSelectMgt.SetRegisterNo(POSEntry."POS Unit No.");

        case ReportSelectionType of
            ReportSelectionType::"Terminal Receipt":
                begin
                    // Terminal receipts flow through EFT Receipt records
                    RunTerminalReceiptPrint(POSEntry);
                end;
            ReportSelectionType::"Sales Receipt (POS Entry)":
                begin
                    if POSEntry.Get(POSEntry."Entry No.") then begin
                        RecRef.GetTable(POSEntry);
                        RecRef.SetRecFilter();
                        if not TryRunReportSelection(RetailReportSelectMgt, RecRef, ReportSelectionType) then begin
                            Registry.ClearHandler();
                            Error(GetLastErrorText());
                        end;
                    end;
                end;
        end;

        Registry.ClearHandler();

        JsonResponse.Add('entryId', Format(POSEntry.SystemId, 0, 4).ToLower());
        JsonResponse.Add('prints', APIPrintHandler.GetCapturedJobs());

        exit(Response.RespondOK(JsonResponse));
    end;

    local procedure RunTerminalReceiptPrint(POSEntry: Record "NPR POS Entry")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        RetailReportSelectMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
    begin
        EFTTransactionRequest.SetRange("Sales Ticket No.", POSEntry."Document No.");
        EFTTransactionRequest.SetRange("Register No.", POSEntry."POS Unit No.");
        if EFTTransactionRequest.FindSet() then
            repeat
                EFTReceipt.SetRange("Transaction Request Entry No.", EFTTransactionRequest."Entry No.");
                if EFTReceipt.FindSet() then begin
                    RecRef.GetTable(EFTReceipt);
                    RetailReportSelectMgt.SetRegisterNo(POSEntry."POS Unit No.");
                    RetailReportSelectMgt.RunObjects(RecRef, Enum::"NPR Report Selection Type"::"Terminal Receipt".AsInteger());
                    RecRef.Close();
                end;
            until EFTTransactionRequest.Next() = 0;
    end;

    [TryFunction]
    local procedure TryRunReportSelection(var RetailReportSelectMgt: Codeunit "NPR Retail Report Select. Mgt."; var RecRef: RecordRef; ReportSelectionType: Enum "NPR Report Selection Type")
    begin
        RetailReportSelectMgt.RunObjects(RecRef, ReportSelectionType.AsInteger());
    end;
```

Remove the old `PrintSalesReceipt` local procedure and the old `BuildPrintObject` helper (they are replaced by the handler-based approach).

**Note:** The `BuildPrintObject` helper and old `APIPOSEntryPrintMgt` event subscriber approach are no longer needed. `APIPOSEntryPrintMgt.Codeunit.al` can be kept for now (it's harmless as an unbound subscriber) or deleted. Keeping it avoids changing any permission sets that reference it.

**Step 9: Update Fern print response type**

In `fern/apis/default/definition/pos/posentry.yml`, update the `PrintJob` type to add `outputPath` and adjust fields:

```yaml
  PrintJob:
    docs: A single print job
    properties:
      printJobFormat:
        type: string
        docs: "Output format: raw, http, or file extension"
      outputPath:
        type: optional<string>
        docs: The configured output destination (printer name, HTTP URL, etc.)
      httpEndpoint:
        type: optional<string>
        docs: HTTP endpoint path (only present when printJobFormat is 'http')
      printJob:
        type: string
        docs: Base64-encoded print job data
```

Update the examples to match the new structure (remove objectType/objectId/objectName, add outputPath).

**Step 10: Run fern check**
```bash
cd fern && fern check
```

**Step 11: Commit**
```
feat: refactor print endpoints via IRetailPrintHandler interface

- Create IRetailPrintHandler interface mirroring PrintMethodMgt methods
- Create DefaultRetailPrintHandler (delegates to PrintMethodMgt)
- Create APIRetailPrintHandler (captures print jobs in memory)
- Create SingleInstance RetailPrintHandlerReg for injection
- Refactor ObjectOutputMgt to dispatch via registry when active
- Refactor APIPOSEntry to use RetailReportSelectMgt (unified path)
- Add outputPath to Fern PrintJob response type
- Guarded cleanup pattern prevents SingleInstance leakage
```

---

## Task 4: JQCleanupDeadPOSSales TryFunction Refactoring

**Files:**
- Create: `Application/src/_API_SERVICES/POS/Sale/JQCleanupDeleteSale.Codeunit.al`
- Create: `Application/src/_API_SERVICES/POS/Sale/JQCleanupParkSale.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/POS/Sale/JQCleanupDeadPOSSales.Codeunit.al`

**Step 1: Create JQCleanupDeleteSale codeunit**

```al
codeunit 6151087 "NPR JQ Cleanup Delete Sale"
{
    Access = Internal;
    TableNo = "NPR POS Sale";

    trigger OnRun()
    begin
        Rec.Delete(true);
    end;
}
```

**Step 2: Create JQCleanupParkSale codeunit**

```al
codeunit 6151088 "NPR JQ Cleanup Park Sale"
{
    Access = Internal;
    TableNo = "NPR POS Sale";

    var
        _POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        _SavePOSSaleBL: Codeunit "NPR POS Action: SavePOSSvSl B";
        _POSCreateEntry: Codeunit "NPR POS Create Entry";

    trigger OnRun()
    begin
        _SavePOSSaleBL.CreateSavedSaleEntry(Rec, _POSSavedSaleEntry);
        _POSCreateEntry.InsertParkSaleEntry(Rec."Register No.", Rec."Salesperson Code");
        Rec.Delete(true);
    end;
}
```

**Step 3: Refactor JQCleanupDeadPOSSales**

In `JQCleanupDeadPOSSales.Codeunit.al`, replace the `TryDeleteSale` and `TryParkSale` procedures with `Codeunit.Run()`:

Replace the inner loop body (lines 33-44):
```al
                    repeat
                        if SaleHasEFTApprovedLines(POSSale) then begin
                            if not Codeunit.Run(Codeunit::"NPR JQ Cleanup Park Sale", POSSale) then begin
                                Sentry.AddLastErrorIfProgrammingBug();
                                Error('JQ Cleanup: Failed to park sale %1 on POS Unit %2: %3. This is a programming bug.', POSSale."Sales Ticket No.", POSSale."Register No.", GetLastErrorText());
                            end;
                        end else begin
                            if not Codeunit.Run(Codeunit::"NPR JQ Cleanup Delete Sale", POSSale) then begin
                                Sentry.AddLastErrorIfProgrammingBug();
                                Error('JQ Cleanup: Failed to delete sale %1 on POS Unit %2: %3. This is a programming bug.', POSSale."Sales Ticket No.", POSSale."Register No.", GetLastErrorText());
                            end;
                        end;
                    until POSSale.Next() = 0;
```

Remove the two `[TryFunction]` procedures (`TryDeleteSale` and `TryParkSale`) at lines 61-77.

**Step 4: Commit**
```
fix: replace TryFunction with Codeunit.Run in cleanup job

Some BC versions/configurations block DB writes inside TryFunction.
Codeunit.Run provides the same error-catching without this restriction.
```

---

## Task 5: EFT API Implementation (Adyen Cloud)

### Part A0: Add Selfservice Card Payment Method field to NPRERestaurant

**Files:**
- Modify: `Application/src/Restaurant/NPRERestaurant.Table.al`
- Modify: `Application/src/Restaurant/NPRERestaurantCard.Page.al`

**Step 0a: Add field to table**

Add after field 230 ("QR Card Payment Method") in `NPRERestaurant.Table.al`:

```al
        field(3; "Selfservice Card Payment Method"; Code[10])
        {
            Caption = 'Selfservice Card Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
```

**Step 0b: Add field to page**

In `NPRERestaurantCard.Page.al`, add after the "QR Card Payment Method" field (after line ~113):

```al
                field("Selfservice Card Payment Method"; Rec."Selfservice Card Payment Method")
                {
                    ToolTip = 'Specifies the POS payment method used for selfservice EFT terminal payments. This payment method is used to find the EFT Setup when preparing API-driven card transactions.';
                    ApplicationArea = NPRRetail;
                }
```

### Part A: Create the API codeunit

**Files:**
- Create: `Application/src/POS Payment/EFT/Integrations/Adyen/APICloud/APIPOSEFTAdyenCloud.Codeunit.al`

**Step 1: Create the API EFT codeunit**

This is the largest new file. Create `APIPOSEFTAdyenCloud.Codeunit.al` with:

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151089 "NPR API POS EFT Adyen Cloud"
{
    Access = Internal;
    // ... implementation below
}
#endif
```

**Procedures to implement:**

1. **PrepareEFTPayment(Request) Response** — POST `/pos/sale/:saleId/eft/prepare`
   - Extract saleId from path, parse body for `externalTransactionId` (required) and `amount` (optional)
   - Get POS Unit from user setup (`"NPR POS Unit No."` on User Setup table)
   - Get Restaurant from the sale, look up `"Selfservice Card Payment Method"` field on `NPRERestaurant`
   - Look up `EFTSetup` for that POS Unit + Payment Method, validate integration type is Adyen Cloud via `EFTAdyenIntegration.CloudIntegrationType()`
   - LOCKTABLE on EFTTransactionRequest, check for existing record with same `"Reference Number Input"` = externalTransactionId — if found, return it (idempotent)
   - Use `EFTTransactionMgt.PreparePayment()` to create the EFTTransactionRequest record
   - Set `"Reference Number Input"` to the consumer's externalTransactionId on the created record
   - If optional amount was provided, update the Amount Input field
   - Commit
   - Return: `{ transactionToken, externalTransactionId, status: "Prepared" }`

2. **BuildEFTRequest(Request) Response** — GET local/buildRequest
   - Return 501 Not Implemented

3. **ParseEFTResponse(Request) Response** — POST local/parseResponse
   - Return 501 Not Implemented

4. **StartEFTPayment(Request) Response** — POST cloud/start
   - Extract transactionToken from path
   - Find EFTTransactionRequest by Token field
   - Validate not already completed (check `Successful` and `"Result Code"`)
   - Get EFTSetup for the POS Unit
   - Use `EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup)` to build JSON
   - Get API key from `EFTAdyenIntegration.GetPaymentTypeParameters()`
   - Get URL from `EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest)`
   - Call `EFTAdyenCloudProtocol.InvokeAPI(RequestJson, APIKey, URL, 300000, Response, StatusCode)`
   - Call `EFTAdyenResponseHandler.ProcessResponse(EntryNo, Response, StatusCode in [0, 200], true, ErrorText)`
   - Commit
   - Return minimal: `{ transactionToken, processed: true }` (nudge toward /status)
   - **Note:** `ProcessResponse()` already calls `HandleProtocolResponse()` → `HandleTrxResponse()` which calls `EFTPaymentMapping.FindPaymentType()` internally. No separate payment mapping call needed in this codeunit.

5. **PollEFTStatus(Request) Response** — GET cloud/status
   - Find EFTTransactionRequest by Token (ReadCommitted)
   - Return current state: transactionToken, externalTransactionId, status (derived from Successful + Result Code + whether External Result Known), successful, resultCode, cardNumber (masked from "Card Number" field), cardName, authorizationNumber, resultMessage via `EFTAdyenResponseHandler.GetResultMessage()`

6. **CancelEFTTransaction(Request) Response** — POST cloud/cancel
   - Find EFTTransactionRequest by Token
   - Use `EFTAdyenAbortMgmt.CreateAbortTransactionRequest()` to create abort record
   - Build abort JSON via `EFTAdyenAbortTrxReq.GetRequestJson()`
   - Get API key + URL
   - Call `EFTAdyenCloudProtocol.InvokeAPI()` with 30000ms timeout (abort is quick)
   - Process abort response
   - Return: `{ transactionToken, cancelRequested: true }`

**Key implementation details:**
- All procedures should validate the saleId path parameter matches the EFTTransactionRequest's sale
- Use `EFTAdyenIntegration` for all setup lookups
- Reuse common request builders - do NOT duplicate JSON building
- Set HttpClient timeout to 300000ms (5 min max on BC SaaS) for /start, 30000ms for /cancel
- The EFTTransactionRequest.Token field (Guid) is the transactionToken in the API

### Part B: Wire routes in APIPOSHandler

**Files:**
- Modify: `Application/src/_API_SERVICES/POS/APIPOSHandler.Codeunit.al`

**Step 2: Uncomment and wire EFT routes**

Replace the commented EFT section (lines 50-78) with:

```al
            Request.Match('POST', '/pos/sale/:saleId/eft/prepare'):
                exit(APIPOSEFTAdyen.PrepareEFTPayment(Request));

            Request.Match('GET', '/pos/sale/:saleId/eft/:transactionToken/local/buildRequest'):
                exit(APIPOSEFTAdyen.BuildEFTRequest(Request));
            Request.Match('POST', '/pos/sale/:saleId/eft/:transactionToken/local/parseResponse'):
                exit(APIPOSEFTAdyen.ParseEFTResponse(Request));

            Request.Match('POST', '/pos/sale/:saleId/eft/:transactionToken/cloud/start'):
                exit(APIPOSEFTAdyen.StartEFTPayment(Request));
            Request.Match('GET', '/pos/sale/:saleId/eft/:transactionToken/cloud/status'):
                exit(APIPOSEFTAdyen.PollEFTStatus(Request));
            Request.Match('POST', '/pos/sale/:saleId/eft/:transactionToken/cloud/cancel'):
                exit(APIPOSEFTAdyen.CancelEFTTransaction(Request));
```

Add the variable declaration in the `Handle` procedure:
```al
        APIPOSEFTAdyen: Codeunit "NPR API POS EFT Adyen Cloud";
```

### Part C: Fern API documentation for EFT

**Files:**
- Modify: `fern/apis/default/definition/pos/possale.yml`

**Step 3: Add EFT types and endpoints to Fern**

Add types:
```yaml
  PrepareEFTRequest:
    docs: Request to prepare an EFT payment transaction
    properties:
      externalTransactionId:
        type: string
        docs: Consumer-provided unique transaction ID for idempotency and retry safety
      amount:
        type: optional<double>
        docs: Payment amount. If not provided, defaults to the remaining balance on the sale.

  EFTPrepareResponse:
    docs: Response after preparing an EFT transaction
    properties:
      transactionToken:
        type: uuid
        docs: Token to use for subsequent EFT operations (start, status, cancel)
      externalTransactionId:
        type: string
        docs: The consumer-provided transaction ID echoed back
      status:
        type: string
        docs: Current status of the EFT transaction

  EFTStartResponse:
    docs: Response after starting an EFT cloud transaction. Check /status for detailed result.
    properties:
      transactionToken: uuid
      processed: boolean

  EFTStatusResponse:
    docs: Current status of an EFT transaction
    properties:
      transactionToken: uuid
      externalTransactionId: string
      status:
        type: string
        docs: "Transaction status: Prepared, Initiated, Completed, Failed"
      successful: boolean
      resultCode: optional<string>
      cardNumber: optional<string>
      cardName: optional<string>
      authorizationNumber: optional<string>
      resultMessage: optional<string>

  EFTCancelResponse:
    docs: Response after requesting EFT transaction cancellation
    properties:
      transactionToken: uuid
      cancelRequested: boolean
```

Add 6 endpoints matching the routes. The two local endpoints should have docs noting they return 501.

**Step 4: Run fern check**
```bash
cd fern && fern check
```

### Part D: EFT API Test Codeunit

**Files:**
- Create: `Test/src/Tests/API/EFTAPITests.Codeunit.al`

**Step 5: Create EFT API test codeunit**

This test uses the `HttpClientHandler` attribute (BC24+) to intercept outbound HTTP calls to Adyen and return a hardcoded successful payment response.

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
codeunit 85169 "NPR EFT API Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Initialized: Boolean;
        _LibraryNPRetailAPI: Codeunit "NPR Library - NP Retail API";
        _LibraryEFT: Codeunit "NPR Library - EFT";
        _Assert: Codeunit Assert;

    [Test]
    [HttpClientHandler('AdyenCloudMockHandler')]
    procedure TestEFTPrepareAndStart()
    var
        Response: Codeunit "NPR API Response";
        JObject: JsonObject;
        JToken: JsonToken;
        TransactionToken: Text;
        StatusCode: Integer;
    begin
        // [SCENARIO] API consumer prepares an EFT transaction, starts it, and polls status
        Initialize();

        // [GIVEN] A POS sale exists with items
        // ... (sale creation via API, same as POSAPITests pattern)

        // [WHEN] POST /pos/sale/:saleId/eft/prepare
        // [THEN] Response contains transactionToken and status "Prepared"

        // [WHEN] POST /pos/sale/:saleId/eft/:token/cloud/start
        // [THEN] Response contains processed: true

        // [WHEN] GET /pos/sale/:saleId/eft/:token/cloud/status
        // [THEN] Response shows successful: true with card details from mock
    end;

    [HttpClientHandlerFunction('AdyenCloudMockHandler')]
    procedure AdyenCloudMockHandler(var Request: HttpRequestMessage; var Response: HttpResponseMessage; var IsHandled: Boolean)
    var
        ResponseBody: Text;
    begin
        ResponseBody := GetMockAdyenPaymentResponse();
        Response.Content.WriteFrom(ResponseBody);
        Response.Headers.Add('Content-Type', 'application/json');
        IsHandled := true;
    end;

    local procedure GetMockAdyenPaymentResponse(): Text
    begin
        exit(
            '{"SaleToPOIResponse":{"MessageHeader":{"POIID":"TESTTERM-001","ServiceID":"12345","MessageCategory":"Payment","MessageType":"Response","MessageClass":"Service"},' +
            '"PaymentResponse":{"Response":{"Result":"Success","AdditionalResponse":"aid=A0000000031010&applicationpreferredname=Visa%20Credit&cardtype=visa"},' +
            '"PaymentResult":{"PaymentInstrumentData":{"PaymentInstrumentType":"Card","CardData":{"MaskedPan":"411111****1111"}},' +
            '"PaymentAcquirerData":{"AcquirerID":"TestAcquirer","ApprovalCode":"123456"},' +
            '"AmountsResp":{"AuthorizedAmount":100.00,"Currency":"USD"}},' +
            '"POIData":{"POITransactionID":{"TransactionID":"TXN-TEST-001","TimeStamp":"2024-01-15T14:32:00Z"},"POIReconciliationID":"RECON-12345"}}}}'
        );
    end;

    local procedure Initialize()
    begin
        if _Initialized then
            exit;
        // Setup POS, restaurant, EFT Setup with Adyen Cloud, payment methods, etc.
        _Initialized := true;
    end;
}
#endif
```

**Note:** The `HttpClientHandler` / `HttpClientHandlerFunction` attributes are BC24+ features. The test is gated behind `#if not (BC17..BC23)`. The mock response JSON contains all fields that `EFTAdyenResponseParser` needs: Result, MaskedPan, ApprovalCode, AuthorizedAmount, POITransactionID, and AdditionalResponse with card type info.

**Step 6: Commit**
```
feat: implement EFT API for Adyen Cloud payments

- Add Selfservice Card Payment Method field to Restaurant table
- POST /prepare: create EFT transaction with consumer's unique ID
- POST /cloud/start: execute Adyen payment synchronously (consumer polls /status)
- GET /cloud/status: poll transaction status and result
- POST /cloud/cancel: request transaction cancellation
- GET /local/buildRequest and POST /local/parseResponse: 501 Not Implemented
- Reuses common Adyen request builders, protocol, and response handler
- EFTPaymentMapping handled internally via ProcessResponse
- 5-minute HttpClient timeout for cloud start, 30s for cancel
- LOCKTABLE + idempotent prepare for retry safety
- Add EFT API test with HttpClientHandler mock for Adyen responses
```

---

## Final Steps

**Step 1: Run full fern check**
```bash
cd fern && fern check
```

**Step 2: Verify compilation** (if dev environment available)
Use `/bcdev` skill to compile and verify no errors.

**Step 3: Final review commit**
Review all changes, ensure no TODOs or incomplete implementations remain.
