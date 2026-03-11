# POS API Phase 4 Design

## Task 1: Remove unitPrice from PATCH POS Sale Line

Delete the `unitPrice` parameter from the PATCH sale line endpoint. It's ambiguous (could be with/without VAT) and not live yet.

**Changes:**
- `APIPOSSaleLine.Codeunit.al`: Remove `UnitPrice` variable declaration (line 357) and the `GetJsonDecimal(Body, 'unitPrice', UnitPrice)` + `POSSaleLine.SetUnitPrice(UnitPrice)` block (lines 367-368)
- `fern/apis/default/definition/pos/possale.yml`: Remove `unitPrice` from `UpdatePOSSaleLine` type (line 138) and from the example (line 145)

---

## Task 2: GET Specific Kitchen Order + Fix Fern Enum + Test

### API Endpoint
`GET /restaurant/:restaurantId/orders/:orderId`

Returns the same header fields as the list endpoint, for a single order looked up by its SystemId.

### Fern Changes
1. Add `getKitchenOrder` endpoint in `orders.yml`:
   - Path: `/{orderId}` (orderId is uuid)
   - Response: `KitchenOrder` type

2. Change `KitchenOrder.status` from `type: string` to a proper enum `KitchenOrderStatus`:
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
   Note: `ReadyForServing` and `InProduction` need explicit `name` properties because they contain spaces/hyphens.

3. Fix the example from `status: "Active"` to a valid value like `status: "Planned"`.

### AL Changes
- `APIRestKitchenOrders.Codeunit.al`: Add `GetKitchenOrder` procedure:
  - Validate restaurantId and orderId GUIDs
  - Get KitchenOrder by SystemId
  - Validate it belongs to the given restaurant
  - Return same JSON fields as list endpoint
- `APIRestaurantHandler.Codeunit.al`: Add route match for `GET /restaurant/:restaurantId/orders/:orderId`

### Test
New test in `KitchenOrderAPITests.Codeunit.al`:
1. Setup POS + restaurant + seating + kitchen-eligible item
2. Create POS sale via API, add sale line, complete with kitchenRequest
3. GET `/restaurant/:restaurantId/orders` to find the created order's orderNo
4. GET `/restaurant/:restaurantId/orders/:orderId` by the order's SystemId
5. Assert all header fields match (status = Planned, restaurantCode, priority, etc.)

---

## Task 3: Print Endpoint Refactoring

### Problem
`APIPOSEntry.PrintPosEntry` duplicates the `RetailReportSelectMgt` loop and the event subscriber `APIPOSEntryPrintMgt` intercepts at `OnBeforeSendLinePrint` before the `ObjectOutputSelection` is resolved, losing the output path and type info.

### Solution: IRetailPrintHandler interface + SingleInstance registry

#### New Interface: `NPR IRetail Print Handler`
Mirrors the retail print methods from `PrintMethodMgt.Codeunit.al`:
```al
interface "NPR IRetail Print Handler"
    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option; ObjectID: Integer)
    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
```

#### Default Implementation: `NPR Default Retail Print Handler`
Each method delegates directly to `PrintMethodMgt`:
```al
procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
begin
    _PrintMethodMgt.PrintBytesLocal(PrinterName, PrintJobBase64);
end;
// ... same for each method
```

#### API Implementation: `NPR API Retail Print Handler`
Captures print jobs into an in-memory JsonArray:
```al
procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
begin
    AddCapturedJob('raw', PrinterName, PrintJobBase64);
end;

procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
begin
    AddCapturedJob('raw', URL, PrintJobBase64);
end;

// Other methods: Error with 'Output type X not supported for API printing' (explicit rather than silent no-op)

local procedure AddCapturedJob(PrintJobFormat: Text; OutputPath: Text; PrintJobBase64: Text)
var Job: JsonObject;
begin
    Job.Add('printJobFormat', PrintJobFormat);
    Job.Add('outputPath', OutputPath);
    Job.Add('printJob', PrintJobBase64);
    _CapturedJobs.Add(Job);
end;

procedure GetCapturedJobs(): JsonArray
begin exit(_CapturedJobs); end;
```

The API implementation supports building up multiple jobs across multiple calls from the RetailReportSelectMgt loop. Each invocation (including repeated invocations from the NoOfPrints loop inside ObjectOutputMgt) adds to the array.

#### SingleInstance Registry: `NPR Retail Print Handler Reg.`
```al
codeunit XXXXXX "NPR Retail Print Handler Reg."
{
    SingleInstance = true;
    Access = Internal;

    var
        _Handler: Interface "NPR IRetail Print Handler";
        _Active: Boolean;

    procedure SetHandler(Handler: Interface "NPR IRetail Print Handler")
    procedure GetHandler(var Handler: Interface "NPR IRetail Print Handler"): Boolean
    procedure ClearHandler()
}
```

#### ObjectOutputMgt Changes
In `PrintLineJob` and `PrintMatrixJob`, after resolving `ObjectOutputSelection` via `TryGetPrintOutput`, check the registry:

```al
// After TryGetPrintOutput resolves ObjectOutput:
RetailPrintHandlerReg: Codeunit "NPR Retail Print Handler Reg.";
Handler: Interface "NPR IRetail Print Handler";

if RetailPrintHandlerReg.GetHandler(Handler) then begin
    case ObjectOutput."Output Type" of
        "Printer Name":
            begin
                PrintJob := Printer.GetPrintBufferAsBase64();
                for i := 1 to NoOfPrints do
                    Handler.PrintBytesLocal(ObjectOutput."Output Path", PrintJob);
            end;
        HTTP:
            begin
                Printer.PrepareJobForHTTP(HTTPEndpoint);
                PrintJob := Printer.GetPrintBufferAsBase64();
                for i := 1 to NoOfPrints do
                    Handler.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintJob);
            end;
        // ... same cases as today, just using Handler instead of PrintMethodMgt
    end;
    exit;
end;

// Fall through to existing code (unchanged backward compat)
```

#### APIPOSEntry.PrintPosEntry Refactored
Unified flow for both Terminal Receipt and Sales Receipt:
```al
procedure PrintPosEntry(...)
var
    APIPrintHandler: Codeunit "NPR API Retail Print Handler";
    Registry: Codeunit "NPR Retail Print Handler Reg.";
    RetailReportSelectMgt: Codeunit "NPR Retail Report Select. Mgt.";
    RecRef: RecordRef;
begin
    // ... validate entryId, get POSEntry ...

    Registry.SetHandler(APIPrintHandler);

    RetailReportSelectMgt.SetRegisterNo(POSEntry."POS Unit No.");
    RecRef.GetTable(POSEntry);
    RecRef.SetRecFilter();

    // IMPORTANT: Guarded cleanup pattern to prevent SingleInstance leakage.
    // If RunObjects throws, ClearHandler must still execute to prevent the
    // handler from hijacking subsequent prints on the same session.
    if not TryRunReportSelection(RetailReportSelectMgt, RecRef, ReportSelectionType) then begin
        Registry.ClearHandler();
        Error(GetLastErrorText());
    end;
    Registry.ClearHandler();

    // Build response from APIPrintHandler.GetCapturedJobs()
    // Response only contains: printJobFormat, outputPath, printJob (base64)
end;

[TryFunction]
local procedure TryRunReportSelection(var RetailReportSelectMgt: Codeunit "NPR Retail Report Select. Mgt."; var RecRef: RecordRef; ReportSelectionType: Enum "NPR Report Selection Type")
begin
    RetailReportSelectMgt.RunObjects(RecRef, ReportSelectionType.AsInteger());
end;
```

No need to subscribe to `OnAfterRunReportSelectionRecord` - the response only needs the output type/destination/base64 data, not the object metadata.

**Note:** The TryFunction here does NOT do DB writes - it only calls RunObjects which internally commits. The TryFunction is purely for error handling to guarantee SingleInstance cleanup.

#### Fern Changes
Update `PrintJob` type in `posentry.yml`:
- Add `outputPath: optional<string>` field
- Can simplify or remove `objectType`/`objectId`/`objectName` if not needed, or keep them for backward compat

#### APIPOSEntryPrintMgt
Can be simplified significantly or removed, since the new handler replaces its event-subscriber role.

#### Files
- NEW: `Application/src/Retail Print/IRetailPrintHandler.Interface.al`
- NEW: `Application/src/Retail Print/DefaultRetailPrintHandler.Codeunit.al`
- NEW: `Application/src/Retail Print/RetailPrintHandlerReg.Codeunit.al`
- NEW: `Application/src/_API_SERVICES/POS/Entry/APIRetailPrintHandler.Codeunit.al`
- MODIFIED: `Application/src/Retail Print/_public/ObjectOutputMgt.Codeunit.al`
- MODIFIED: `Application/src/_API_SERVICES/POS/Entry/APIPOSEntry.Codeunit.al`
- MODIFIED: `Application/src/_API_SERVICES/POS/Entry/APIPOSEntryPrintMgt.Codeunit.al` (simplify/remove)
- MODIFIED: `fern/apis/default/definition/pos/posentry.yml`

---

## Task 4: JQCleanupDeadPOSSales TryFunction Refactoring

Replace `[TryFunction]` with `if Codeunit.Run()` pattern. The issue is that some BC versions/configurations block DB writes (INSERT, MODIFY, DELETE) inside TryFunction calls. `Codeunit.Run()` provides the same error-catching capability without the TryFunction restriction — the inner codeunit gets its own implicit transaction scope.

### New Codeunits
**`NPR JQ Cleanup Delete Sale`** (TableNo = "NPR POS Sale"):
```al
trigger OnRun()
begin
    Rec.Delete(true);
end;
```

**`NPR JQ Cleanup Park Sale`** (TableNo = "NPR POS Sale"):
```al
trigger OnRun()
var
    POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
    SavePOSSaleBL: Codeunit "NPR POS Action: SavePOSSvSl B";
    POSCreateEntry: Codeunit "NPR POS Create Entry";
begin
    SavePOSSaleBL.CreateSavedSaleEntry(Rec, POSSavedSaleEntry);
    POSCreateEntry.InsertParkSaleEntry(Rec."Register No.", Rec."Salesperson Code");
    Rec.Delete(true);
end;
```

### Refactored JQCleanupDeadPOSSales
```al
// Replace TryDeleteSale:
if not Codeunit.Run(Codeunit::"NPR JQ Cleanup Delete Sale", POSSale) then begin
    Sentry.AddLastErrorIfProgrammingBug();
    Error('...');
end;

// Replace TryParkSale:
if not Codeunit.Run(Codeunit::"NPR JQ Cleanup Park Sale", POSSale) then begin
    Sentry.AddLastErrorIfProgrammingBug();
    Error('...');
end;
```

Remove the `[TryFunction]` local procedures `TryDeleteSale` and `TryParkSale`.

### Files
- NEW: `Application/src/_API_SERVICES/POS/Sale/JQCleanupDeleteSale.Codeunit.al`
- NEW: `Application/src/_API_SERVICES/POS/Sale/JQCleanupParkSale.Codeunit.al`
- MODIFIED: `Application/src/_API_SERVICES/POS/Sale/JQCleanupDeadPOSSales.Codeunit.al`

---

## Task 5: EFT API Implementation (Adyen Cloud only)

### New Folder
`Application/src/POS Payment/EFT/Integrations/Adyen/APICloud/`

### New Codeunit: `NPR API POS EFT Adyen Cloud`
Access = Internal. Handles 6 endpoints:

#### POST `/pos/sale/:saleId/eft/prepare`
- Request body: `{ "externalTransactionId": "consumer-unique-id", "amount": 100.00 (optional) }`
- Consumer provides their own unique transaction ID for idempotency/retry safety
- Validates:
  - POS Sale exists and is open
  - POS Unit from API user's User Setup has EFT Setup with Adyen Cloud integration type
  - Idempotency: LOCKTABLE on EFTTransactionRequest, then check if one with same externalTransactionId already exists — if so, return existing (prevents race conditions from concurrent retries)
- Uses `EFTTransactionMgt` helpers to create `EFTTransactionRequest`:
  - Integration Type = Adyen Cloud
  - Amount = provided amount, or remaining sale balance if not specified
  - "Reference Number Input" = consumer's externalTransactionId
  - Processing Type = PAYMENT
- COMMIT for traceability
- Response: `{ "transactionToken": "<guid>", "externalTransactionId": "...", "status": "Prepared" }`

#### GET `/pos/sale/:saleId/eft/:transactionToken/local/buildRequest`
- Returns 501 Not Implemented (local not supported yet)

#### POST `/pos/sale/:saleId/eft/:transactionToken/local/parseResponse`
- Returns 501 Not Implemented (local not supported yet)

#### POST `/pos/sale/:saleId/eft/:transactionToken/cloud/start`
- Finds EFTTransactionRequest by Token, validates not already completed
- Reads EFTSetup for the POS Unit
- Uses `EFTAdyenTrxRequest.GetRequestJson()` to build the Adyen payment JSON
- Uses `EFTAdyenCloudProtocol.InvokeAPI()` synchronously on the WS session
  - **Timeout: 300000ms (5 minutes)** - BC SaaS max HttpClient timeout
  - **Risk note:** BC SaaS service-tier may have its own request timeout that could terminate the session before Adyen responds. The /status endpoint acts as recovery — if /start is terminated mid-flight, the consumer polls /status which reads the DB state. If the transaction was left in "Initiated" state (Adyen responded but BC didn't persist), the existing lookup pattern from `EFTAdyenLookupTask` can be reused to reconcile.
- Uses `EFTAdyenResponseHandler.ProcessResponse()` to parse and update EFTTransactionRequest
- COMMIT
- **Returns minimal response only**: `{ "transactionToken": "<guid>", "started": true }` — no detailed result, to nudge consumers toward polling /status

#### GET `/pos/sale/:saleId/eft/:transactionToken/cloud/status`
- Reads EFTTransactionRequest by Token (ReadCommitted isolation)
- Returns current state:
  ```json
  {
    "transactionToken": "<guid>",
    "externalTransactionId": "...",
    "status": "Initiated|Completed|Failed",
    "successful": true/false,
    "resultCode": "...",
    "cardNumber": "****1234",
    "cardName": "VISA",
    "authorizationNumber": "...",
    "resultMessage": "..."
  }
  ```

#### POST `/pos/sale/:saleId/eft/:transactionToken/cloud/cancel`
- Uses `EFTAdyenAbortMgmt.CreateAbortTransactionRequest()` to create abort request record
- Uses `EFTAdyenAbortTrxReq.GetRequestJson()` to build abort JSON
- Uses `EFTAdyenCloudProtocol.InvokeAPI()` synchronously (shorter timeout ~30s)
- Note: Adyen's response just confirms receipt of cancellation. The actual transaction result will come back on the /start WS session.
- Returns: `{ "transactionToken": "<guid>", "cancelRequested": true }`

### Handler Routing
Uncomment the EFT routes in `APIPOSHandler.Codeunit.al` and wire to the new codeunit.

### Key Reuse from Existing Code
- `EFTTransactionMgt` — creating EFTTransactionRequest records
- `EFTAdyenIntegration` — setup lookup, parameters, payment type config
- `EFTAdyenTrxRequest` / `EFTAdyenVoidReq` — request JSON building
- `EFTAdyenCloudProtocol` — HTTP invocation (InvokeAPI)
- `EFTAdyenResponseHandler` — response parsing
- `EFTAdyenAbortMgmt` — abort request creation
- `EFTAdyenAbortTrxReq` — abort JSON building

### Fern Changes
Add EFT endpoints and types to `possale.yml`:
- `PrepareEFTRequest` type with `externalTransactionId: string` and `amount: optional<double>`
- `EFTPrepareResponse`, `EFTStartResponse`, `EFTStatusResponse`, `EFTCancelResponse` types
- 6 endpoint definitions matching the routes

### Files
- NEW: `Application/src/POS Payment/EFT/Integrations/Adyen/APICloud/APIPOSEFTAdyenCloud.Codeunit.al`
- MODIFIED: `Application/src/_API_SERVICES/POS/APIPOSHandler.Codeunit.al` (uncomment + wire routes)
- MODIFIED: `fern/apis/default/definition/pos/possale.yml`
