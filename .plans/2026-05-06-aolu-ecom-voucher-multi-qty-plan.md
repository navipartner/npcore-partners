# Ecom Voucher Multi-Quantity + Subpage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow ecom voucher lines to be processed with `quantity > 1` (CORE-209), and add a "Vouchers" subpage to the Ecom Document page showing all issued vouchers active and archived (CORE-119, supersedes PR #9684).

**Architecture:** Introduces a new `NPR Ecom Sales Voucher Link` table that durably links ecom-line ↔ voucher with a `Voucher State` enum (Active/Archived) flipped via subscribers to existing `OnAfterArchiveVoucher` / `OnAfterUnArchiveVoucher` events. Downstream consumers (notification manifest, Show Related, BC sales-line bridge, voucher-entry posting) become fully link-first with legacy fallbacks for production ecom docs without link rows. Subpage on `EcomSalesDocument` page reads the same link table.

**Tech Stack:** Business Central AL (BC17+), npcore Application/Test apps, `bcdev` skill for compile/publish/test, `al-id-manager` skill for object/field IDs.

**Reference:** [Spec rev 8](2026-05-06-aolu-ecom-voucher-multi-qty-design.md) — read it. Each task below points at specific spec sections for code bodies. The plan does not duplicate code that's already in the spec.

**File structure (new objects + edits):**

| File | Status | Purpose |
|---|---|---|
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomSalesVoucherLink.Table.al` | **new** | Durable ecom-line ↔ voucher link |
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLinkState.Enum.al` | **new** | Active / Archived |
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherSub.Page.al` | **new** | ListPart on Ecom Document |
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLookup.Page.al` | **new** | List page for line-level AssistEdit when N>1 |
| `.../_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al` | edit | issuance loop, link writes, archive subscribers, Show-Related, voucher-entry posting patch, processing-time qty validation |
| `.../_fastLine/virtualItems/Voucher/EcomCreateVchrProcess.Codeunit.al` | edit | Sentry capture between Run and HandleResponse |
| `.../handlers/EcomSalesDocApiAgentV2.Codeunit.al` | edit | API payload validation |
| `.../EcomSalesDocImplV2.Codeunit.al` | edit | `InsertSalesLineVoucher` rewrite |
| `.../_public/EcomSalesDocument.Page.al` | edit | add subpage part, obsolete document-level "Retail Vouchers" action |
| `.../_public/EcomSalesLine.Table.al` | edit | `Quantity` `OnValidate` immutability guard |
| `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al` | edit | `ProcessVoucherAssets` ecom branch |
| `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al` | **new** | Tests #1-#22 from spec §7 |

---

## Task 1: Acquire AL IDs and bootstrap

**Files:**
- Reference only — no code changes yet

- [ ] **Step 1: Look up app.json ranges**

Read `Application/app.json` to confirm valid ID ranges. Per CLAUDE.md memory: `[6014400-6014699, 6059767-6060166, 6150613-6151612, 6184471-6185130, 6248181-6249170]`. New objects target the `_API_SERVICES/ecommerce/...` range (around 6248xxx).

- [ ] **Step 2: Use al-id-manager skill to fetch new object IDs**

Invoke `al-id-manager:get-next-id` for:
- 1× Table — `NPR Ecom Sales Voucher Link`
- 1× Enum — `NPR Ecom Voucher Link State`
- 1× ListPart Page — `NPR Ecom Voucher Sub`
- 1× List Page — `NPR Ecom Voucher Lookup`

Record the returned IDs in this plan inline as you go (replace `60xxxxx` placeholders below with actuals).

- [ ] **Step 3: Use al-id-manager for new field IDs on `NPR Ecom Sales Line`**

`Quantity` already exists; we're only adding an `OnValidate` trigger, no new field. **Skip if no new fields needed.** (Spec §4.2 "Quantity immutability guard" doesn't add a field; just a trigger.)

- [ ] **Step 4: Verify the test app structure**

Confirm `Test/src/Tests/ECommerce/FastLane/` exists and houses sibling test codeunits (`EcomCouponTests.Codeunit.al`, `EcomWalletTests.Codeunit.al`). The new voucher tests file will live alongside.

- [ ] **Step 5: Verify the `bcdev` skill is configured**

Try `bcdev compile -suppressWarnings` (per project rule) on the current branch as a baseline. Expected: success with no errors.

No commit yet.

---

## Task 2: Create the link state enum and link table

**Files:**
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLinkState.Enum.al`
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomSalesVoucherLink.Table.al`

- [ ] **Step 1: Write the enum**

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
enum 60xxxxx "NPR Ecom Voucher Link State"
{
    Access = Internal;
    Extensible = false;

    value(0; Active) { Caption = 'Active'; }
    value(1; Archived) { Caption = 'Archived'; }
}
#endif
```

- [ ] **Step 2: Write the link table**

Use the schema from spec §3.1 verbatim — 8 fields (Entry No., Source System Id, Source Line System Id, Voucher System Id, Voucher No., Reference No., Voucher State, Voucher Type) and 4 keys (PK, BySource, BySourceLine, BySystemId).

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 60xxxxx "NPR Ecom Sales Voucher Link"
{
    Access = Internal;
    Caption = 'Ecom Sales Voucher Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)               { AutoIncrement = true; Caption = 'Entry No.'; }
        field(2; "Source System Id"; Guid)           { Caption = 'Source System Id'; DataClassification = CustomerContent; }
        field(3; "Source Line System Id"; Guid)      { Caption = 'Source Line System Id'; DataClassification = CustomerContent; }
        field(4; "Voucher System Id"; Guid)          { Caption = 'Voucher System Id'; DataClassification = CustomerContent; }
        field(5; "Voucher No."; Code[20])            { Caption = 'Voucher No.'; DataClassification = CustomerContent; }
        field(6; "Reference No."; Text[50])          { Caption = 'Reference No.'; DataClassification = CustomerContent; }
        field(7; "Voucher State"; Enum "NPR Ecom Voucher Link State") { Caption = 'Voucher State'; DataClassification = CustomerContent; }
        field(8; "Voucher Type"; Code[20])           { Caption = 'Voucher Type'; DataClassification = CustomerContent; }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(BySource;     "Source System Id", "Source Line System Id") { }
        key(BySourceLine; "Source Line System Id") { }
        key(BySystemId;   "Voucher System Id", "Voucher State") { }
    }
}
#endif
```

- [ ] **Step 3: Compile**

Run: `bcdev compile -suppressWarnings`
Expected: success with no errors. New table and enum compile clean.

- [ ] **Step 4: Commit**

```bash
git add "Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLinkState.Enum.al" "Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomSalesVoucherLink.Table.al"
git commit -m "feat(ecom-voucher): add Ecom Sales Voucher Link table + state enum

Foundation for CORE-209 / CORE-119 multi-qty voucher support and the
Vouchers subpage on the Ecom Document page. See design doc:
.plans/2026-05-06-aolu-ecom-voucher-multi-qty-design.md §3.1."
```

---

## Task 3: Add `InsertVoucherLink` and `CountExistingLinks` helpers

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

- [ ] **Step 1: Add `InsertVoucherLink` private procedure to `EcomCreateVchrImpl`**

Code body from spec §4.2 "InsertVoucherLink":

```al
local procedure InsertVoucherLink(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; NpRvVoucher: Record "NPR NpRv Voucher")
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
begin
    EcomSalesVoucherLink.Init();
    EcomSalesVoucherLink."Source System Id" := EcomSalesHeader.SystemId;
    EcomSalesVoucherLink."Source Line System Id" := EcomSalesLine.SystemId;
    EcomSalesVoucherLink."Voucher System Id" := NpRvVoucher.SystemId;
    EcomSalesVoucherLink."Voucher No." := NpRvVoucher."No.";
    EcomSalesVoucherLink."Reference No." := NpRvVoucher."Reference No.";
    EcomSalesVoucherLink."Voucher Type" := NpRvVoucher."Voucher Type";
    EcomSalesVoucherLink."Voucher State" := EcomSalesVoucherLink."Voucher State"::Active;
    EcomSalesVoucherLink.Insert(true);
end;
```

- [ ] **Step 2: Add `CountExistingLinks` private procedure**

```al
local procedure CountExistingLinks(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"): Integer
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
begin
    EcomSalesVoucherLink.SetCurrentKey("Source System Id", "Source Line System Id");
    EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
    EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    exit(EcomSalesVoucherLink.Count());
end;
```

- [ ] **Step 3: Compile**

Run: `bcdev compile -suppressWarnings`
Expected: success.

- [ ] **Step 4: Commit**

```bash
git add Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "feat(ecom-voucher): add InsertVoucherLink + CountExistingLinks helpers

Helpers for the upcoming CreateVoucher restructure. Not yet wired in.
Spec §4.2."
```

---

## Task 4: Bootstrap test codeunit + Test #1 (qty=1 happy path) + wire `InsertVoucherLink` into existing flow

**Files:**
- Create: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

- [ ] **Step 1: Look up next test codeunit ID**

Use `al-id-manager:get-next-id` for one Codeunit in the Test app's range. Record the ID inline below.

- [ ] **Step 2: Write test codeunit skeleton with helpers + Test #1**

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 8524x "NPR Ecom Voucher Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_Qty1_HappyPath_OneLinkRow()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] qty=1 voucher line is processed → exactly 1 link row exists for the line.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 1, 100);

        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesVoucherLink.Count(), 'Expected exactly 1 link row for qty=1 voucher line.');
    end;

    local procedure CreateEcomVoucherType(var VoucherType: Record "NPR NpRv Voucher Type"): Code[20]
    begin
        // Existing helper pattern in NPR Library Ecommerce / NPR Library Coupon.
        // Use the smallest set of fields needed: code, partner code, GL account, reference-no pattern.
        VoucherType.Init();
        VoucherType.Code := CopyStr(CreateGuid(), 1, MaxStrLen(VoucherType.Code));
        // ... fill required fields from existing voucher-type test setup helpers if present;
        //     otherwise mirror NPR Library Coupon.CreateCouponType for the field shape.
        VoucherType.Insert(true);
        exit(VoucherType.Code);
    end;

    local procedure CreateCapturedVoucherLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherTypeCode: Code[20]; Qty: Integer; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Line No." := GetNextEcomLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Voucher;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Voucher;
        EcomSalesLine."Voucher Type" := VoucherTypeCode;
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure GetNextEcomLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if EcomSalesLine.FindLast() then
            exit(EcomSalesLine."Line No." + 10000);
        exit(10000);
    end;
}
#endif
```

Note: `CreateEcomVoucherType` is a placeholder — the implementer will need to mirror the existing voucher-type test setup pattern from a related test codeunit. If no existing pattern exists, use direct field-by-field setup. Fields required for `EcomCreateVchrImpl.Process` to succeed: `Code`, `Description`, an active `Allow Top-up` setting if testing top-up, a configured `Account No.`, and reference-no pattern.

- [ ] **Step 3: Run test to verify it fails**

Run: invoke `bcdev test` (or BC's test runner) on the new codeunit, filtering for `VoucherProcess_Qty1_HappyPath_OneLinkRow`.
Expected: FAIL — the existing `EcomCreateVchrImpl.Process` does NOT yet insert into the link table; assertion `Expected exactly 1 link row` fails with `0 <> 1`.

- [ ] **Step 4: Wire `InsertVoucherLink` into existing `CreateVoucher` flow**

In `EcomCreateVchrImpl.CreateVoucher` (currently at `:106-171`), find the success path right after `EcommSalesLine.Modify(true)` (the existing writeback at the end) and add ONE call:

```al
EcommSalesLine."No." := NpRvVoucher."No.";
EcommSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
EcommSalesLine.Modify(true);

InsertVoucherLink(EcomSalesHeader, EcommSalesLine, NpRvVoucher);  // <-- add this line

if NpRvSalesLine."Spfy Gift Card ID" <> '' then
    SpfyEcomSalesDocPrcssr.AssignShopifyIDToVoucher(NpRvVoucher, NpRvSalesLine);
```

This is the minimal change to make Test #1 pass without yet restructuring CreateVoucher. The link row gets inserted alongside the existing qty=1 path.

- [ ] **Step 5: Run test to verify it passes**

Run: same test command.
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "test(ecom-voucher): add Test #1 qty=1 link-row insertion

CreateVoucher now inserts one link row for qty=1 issuance. Spec §4.2,
test plan §7 #1."
```

---

## Task 5: Test #2 (qty=5 multi-issuance) + restructure `CreateVoucher`

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

- [ ] **Step 1: Add Test #2 to the test codeunit**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherProcess_Qty5_MultiIssue_FiveLinkRowsAndLineUntouched()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
begin
    // [Scenario] qty=5 → 5 vouchers issued, 5 link rows; line "No.", "Voucher Type", "Barcode No." all left blank.
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 5, 100);

    VchrImpl.Process(EcomSalesLine);
    EcomSalesLine.Get(EcomSalesLine."Document Entry No.", EcomSalesLine."Line No.");

    EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    _Assert.AreEqual(5, EcomSalesVoucherLink.Count(), 'Expected 5 link rows for qty=5 voucher line.');

    _Assert.AreEqual('', EcomSalesLine."No.", 'qty>1 line should not have "No." written back.');
    _Assert.AreEqual('', Format(EcomSalesLine."Voucher Type"), 'qty>1 line should not have "Voucher Type" written back beyond the user-supplied value.');
    _Assert.AreEqual('', EcomSalesLine."Barcode No.", 'qty>1 line should not have "Barcode No." written back.');
end;
```

(Note: `Voucher Type` IS user-supplied at API ingest, so the assertion needs adjustment — assert that it equals what was supplied, not blank. Adjust accordingly when implementing.)

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL with `1 <> 5` because the current `CreateVoucher` only handles qty=1.

- [ ] **Step 3: Restructure `CreateVoucher`**

Replace `CreateVoucher` body (`EcomCreateVchrImpl.al:106-171`) with the full version from spec §4.2 — three branches (link-count guard, top-up, new-issuance loop), plus the `IssueOrTopUpSingleVoucher` private helper extracted from the existing single-voucher logic. Use the spec code verbatim.

The link-count guard from spec §4.2:
```al
case true of
    AlreadyLinked = QtyToIssue:
        exit;  // race recovery — another session already issued these vouchers
    AlreadyLinked > QtyToIssue:
        Error(LinkCountExceedsQtyErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
    (AlreadyLinked > 0) and (AlreadyLinked < QtyToIssue):
        Error(PartialLinkStateErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
end;
```

Add the error labels — both `Locked = true` with "This is a programming bug" suffix per spec §6:

```al
LinkCountExceedsQtyErr: Label
    'Internal data inconsistency on voucher line %1: %2 voucher(s) issued but quantity is %3. Contact support to investigate. This is a programming bug.',
    Locked = true;
PartialLinkStateErr: Label
    'Internal data inconsistency on voucher line %1: %2 of %3 voucher(s) issued. Contact support to investigate. This is a programming bug.',
    Locked = true;
```

The `IssueOrTopUpSingleVoucher` helper takes the existing `CreateVoucher` single-voucher body (the reserve + insert + post + Shopify ID logic) and parameterizes it on the optional barcode (top-up or new). See spec §4.2 for the full signature shape.

The `InsertVoucherLink` call is now invoked from inside the loop at every iteration; the standalone call added in Task 4 is removed (it's now inside the loop).

- [ ] **Step 4: Run both tests (#1 and #2)**

Expected: both PASS. Test #1 still works because the `for i := 1 to 1 do` loop case behaves identically to the prior single-voucher path, plus the writeback at the end runs only when `QtyToIssue = 1`.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "feat(ecom-voucher): support qty>1 on voucher lines

Restructure CreateVoucher into three branches: link-count guard,
top-up, and multi-qty new-issuance loop. qty=1 keeps API back-compat
writeback; qty>1 leaves EcomSalesLine fields untouched. Spec §4.2,
test plan §7 #1, #2."
```

---

## Task 6: Test #3-#5 (top-up qty=1, top-up qty>1 forbidden, qty validation) + API payload validation

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/handlers/EcomSalesDocApiAgentV2.Codeunit.al`

- [ ] **Step 1: Add Tests #3, #4, #5 to the test codeunit**

For each test:
- **#3 Top-up qty=1**: create existing voucher with `Allow Top-up = true`, supply its `Reference No.` as `Barcode No.` on the new ecom line with qty=1. Process, then assert exactly 1 link row exists pointing at the existing voucher (`"Voucher No." = pre-existing voucher's No.`).
- **#4 Top-up qty>1 forbidden**: payload has `barcodeNo` non-empty AND `quantity = 2`. Use a JSON-shaped helper (see `EcomSalesDocApiAgentV2.Codeunit.al:174` for the entry point) and assert that the API agent's processing errors out with the correct message.
- **#5 Quantity validation**: separate sub-tests for `quantity = 0`, `quantity = -1`, `quantity = 2.5` — each rejected at API ingest. Then a parallel sub-test that bypasses the API and writes the bad value directly to a line via `EcomSalesLine.Validate(Quantity, 2.5)`, then calls `Process` — assert that `CheckIfLineCanBeProcessed` rejects it.

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherProcess_TopUpQty1_LinksExistingVoucher()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    ExistingVoucher: Record "NPR NpRv Voucher";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
begin
    // [Scenario] Top-up of an existing voucher → 1 link row pointing at the existing voucher.
    CreateExistingActiveVoucher(ExistingVoucher, CreateEcomVoucherTypeAllowTopUp(VoucherType));
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, ExistingVoucher."Voucher Type", 1, 50);
    EcomSalesLine."Barcode No." := ExistingVoucher."Reference No.";
    EcomSalesLine.Modify();

    VchrImpl.Process(EcomSalesLine);

    EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    EcomSalesVoucherLink.FindFirst();
    _Assert.AreEqual(ExistingVoucher."No.", EcomSalesVoucherLink."Voucher No.", 'Top-up link should point at the existing voucher.');
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure ApiPayload_TopUpWithQty2_Rejected()
begin
    // [Scenario] API payload with barcodeNo non-empty AND quantity > 1 must be rejected.
    asserterror SimulateApiIngestVoucherLine('SOMEREFERENCE', 2);
    _Assert.ExpectedError('quantity'); // existing PropertyErrorText pattern includes 'quantity' in path
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure ApiPayload_FractionalQty_Rejected()
begin
    asserterror SimulateApiIngestVoucherLine('', 2.5);
    _Assert.ExpectedError('quantity');
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure ApiPayload_ZeroQty_Rejected()
begin
    asserterror SimulateApiIngestVoucherLine('', 0);
    _Assert.ExpectedError('quantity');
end;
```

`SimulateApiIngestVoucherLine` should construct a minimal JSON payload that exercises `EcomSalesDocApiAgentV2.InsertIncomingSalesLine`'s voucher branch. Look at how `EcomCouponTests` exercises the API agent for the same module — mirror that pattern.

- [ ] **Step 2: Run tests to verify they fail**

Expected: tests #3 PASSes already (top-up qty=1 was already supported and now also gets a link row from Task 5), but the API rejection tests #4, #5 FAIL with the wrong error or no error because the existing API code rejects ALL `quantity != 1`, not specifically the new-rules combinations.

- [ ] **Step 3: Update API payload validation per spec §4.1**

In `EcomSalesDocApiAgentV2.al:339-341`, replace:

```al
EcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
if EcomSalesLine.Quantity <> 1 then
    Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
```

with:

```al
EcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
if EcomSalesLine.Quantity <> Round(EcomSalesLine.Quantity, 1) then
    Error(FractionalQtyErr, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
if EcomSalesLine.Quantity < 1 then
    Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
if (EcomSalesLine."Barcode No." <> '') and (EcomSalesLine.Quantity <> 1) then
    Error(TopUpQtyMustBeOneErr, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
```

Add the two new Label declarations alongside `PropertyErrorText` near the top of the codeunit:

```al
FractionalQtyErr: Label '%1 must be a whole number; got %2.', Comment = '%1 = JSON path, %2 = the value';
TopUpQtyMustBeOneErr: Label '%1 must be 1 when barcodeNo is supplied (top-up requires quantity 1); got %2.', Comment = '%1 = JSON path, %2 = the value';
```

- [ ] **Step 4: Run tests to verify they pass**

Expected: all of #3, #4, #5 PASS.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/handlers/EcomSalesDocApiAgentV2.Codeunit.al
git commit -m "feat(ecom-voucher): relax API quantity validation; whole positive number

Voucher line quantity can now be any positive whole number. When
barcodeNo is supplied (top-up), quantity must remain 1. Spec §4.1,
test plan §7 #3-#5."
```

---

## Task 7: Test #6 + #11 (overcount + partial-state guard errors)

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`

- [ ] **Step 1: Add Tests #6 and #11**

Both tests synthesize a corrupt state by directly inserting link rows that don't match `Quantity`, then call `Process` and expect the appropriate `Locked = true` error.

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherProcess_AlreadyLinkedExceedsQty_Errors()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    i: Integer;
begin
    // [Scenario] More links than quantity → hard error with the diagnostic Sentry-targeted label.
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 2, 100);
    for i := 1 to 5 do  // insert 5 link rows for a qty=2 line — corruption simulated
        InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);

    asserterror VchrImpl.Process(EcomSalesLine);
    _Assert.ExpectedError('Internal data inconsistency');
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherProcess_PartialLinkState_Errors()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
begin
    // [Scenario] 0 < AlreadyLinked < QtyToIssue → hard error (not a resume scenario).
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 5, 100);
    InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);  // 1 of 5
    InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);  // 2 of 5

    asserterror VchrImpl.Process(EcomSalesLine);
    _Assert.ExpectedError('Internal data inconsistency');
end;

local procedure InsertCorruptLinkRow(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line")
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
begin
    EcomSalesVoucherLink.Init();
    EcomSalesVoucherLink."Source System Id" := EcomSalesHeader.SystemId;
    EcomSalesVoucherLink."Source Line System Id" := EcomSalesLine.SystemId;
    EcomSalesVoucherLink."Voucher System Id" := CreateGuid();   // dangling — no real voucher
    EcomSalesVoucherLink."Voucher No." := 'CORRUPT';
    EcomSalesVoucherLink."Voucher State" := EcomSalesVoucherLink."Voucher State"::Active;
    EcomSalesVoucherLink.Insert(true);
end;
```

- [ ] **Step 2: Run tests to verify they pass**

Expected: PASS — the guard branches added in Task 5 already implement these errors. This task is just regression coverage to guarantee the contract.

- [ ] **Step 3: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al
git commit -m "test(ecom-voucher): cover overcount and partial-link-state guard errors

Spec §4.2 Branches 1a (>QtyToIssue) and 1c (partial). Test plan §7 #6, #11."
```

---

## Task 8: Test #7 (concurrent re-entry race recovery)

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`

- [ ] **Step 1: Add Test #7**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherProcess_RaceRecovery_NoOpExit()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    i: Integer;
begin
    // [Scenario] Pre-populate AlreadyLinked = QtyToIssue (simulating the post-inner-commit /
    // pre-HandleResponse race window) → CreateVoucher exits cleanly without issuing duplicates.
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 3, 100);
    for i := 1 to 3 do
        InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);

    VchrImpl.Process(EcomSalesLine);   // should NOT error and NOT issue more vouchers

    EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    _Assert.AreEqual(3, EcomSalesVoucherLink.Count(), 'Race recovery: link count must remain at 3, no duplicates issued.');
end;
```

- [ ] **Step 2: Run test to verify it passes**

Expected: PASS — Branch 1a `AlreadyLinked = QtyToIssue` no-op exit (Task 5) handles this. Regression coverage.

- [ ] **Step 3: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al
git commit -m "test(ecom-voucher): cover race-recovery no-op exit

Spec §6 race-window rationale; test plan §7 #7."
```

---

## Task 9: Test #22 (Quantity immutability) + `OnValidate` guard

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesLine.Table.al`

- [ ] **Step 1: Add Test #22**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure EcomSalesLineQuantity_Immutable_AfterLinkRowsExist()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
begin
    // [Scenario] Once link rows exist for a voucher line, Quantity becomes immutable.
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 3, 100);

    VchrImpl.Process(EcomSalesLine);   // produces 3 link rows
    EcomSalesLine.Get(EcomSalesLine."Document Entry No.", EcomSalesLine."Line No.");

    asserterror EcomSalesLine.Validate(Quantity, 5);   // should fail with QtyImmutableErr
    _Assert.ExpectedError('Quantity cannot be changed');
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure EcomSalesLineQuantity_Mutable_BeforeIssuance()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
begin
    // [Scenario] Before any link rows exist, Quantity is freely mutable (regression: API ingest path).
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 1, 100);

    EcomSalesLine.Validate(Quantity, 3);  // must NOT error
    EcomSalesLine.Modify();
    _Assert.AreEqual(3, EcomSalesLine.Quantity, 'Quantity should be settable when no link rows exist.');
end;
```

- [ ] **Step 2: Run tests — first one fails, second passes**

Expected: `EcomSalesLineQuantity_Immutable_AfterLinkRowsExist` FAILS (no guard yet); `EcomSalesLineQuantity_Mutable_BeforeIssuance` PASSES.

- [ ] **Step 3: Add `OnValidate` to the `Quantity` field on `NPR Ecom Sales Line`**

Find `Quantity` field declaration in `EcomSalesLine.Table.al` (around `:66`, the Quantity field is a Decimal — find by `field(...; Quantity; Decimal)`). Add the trigger inside the field block:

```al
trigger OnValidate()
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    QtyImmutableErr: Label 'Quantity cannot be changed: %1 voucher(s) have already been issued for this line.', Comment = '%1 - issued voucher count';
begin
    if Rec.Quantity = xRec.Quantity then
        exit;
    EcomSalesVoucherLink.SetCurrentKey("Source Line System Id");
    EcomSalesVoucherLink.SetRange("Source Line System Id", Rec.SystemId);
    if not EcomSalesVoucherLink.IsEmpty() then
        Error(QtyImmutableErr, EcomSalesVoucherLink.Count());
end;
```

The new `BySourceLine` key on the link table covers this filter — no full-index scan.

- [ ] **Step 4: Run all tests**

Expected: all tests so far PASS, including both new ones.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesLine.Table.al
git commit -m "feat(ecom-voucher): make Quantity immutable on lines with issued vouchers

Defense-in-depth OnValidate guard. Closes the only realistic
user-triggered path to the §4.2 hard-error branches. Spec §4.2
'Quantity immutability guard'; test plan §7 #22."
```

---

## Task 10: Processing-time quantity validation in `CheckIfLineCanBeProcessed`

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

- [ ] **Step 1: Add tests for the processing-time guards (Test #5 second half)**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherProcess_FractionalQty_RejectedAtProcessing()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
begin
    // [Scenario] If a fractional Quantity bypasses API ingest, processing also rejects it.
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 1, 100);
    EcomSalesLine.Quantity := 2.5;  // direct set, bypassing OnValidate
    EcomSalesLine.Modify();

    asserterror VchrImpl.Process(EcomSalesLine);
    _Assert.ExpectedError('Quantity');
end;
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — current `CheckIfLineCanBeProcessed` only blocks `Quantity = 0`, not fractional.

- [ ] **Step 3: Update `CheckIfLineCanBeProcessed` per spec §4.2**

In `EcomCreateVchrImpl.al:22-48`, replace the existing `Quantity = 0` clause with the spec-required defensive checks:

```al
if EcomSalesLine.Quantity <> Round(EcomSalesLine.Quantity, 1) then
    EcomSalesLine.FieldError(Quantity);
if EcomSalesLine.Quantity < 1 then
    EcomSalesLine.FieldError(Quantity);
if (EcomSalesLine."Barcode No." <> '') and (EcomSalesLine.Quantity <> 1) then
    EcomSalesLine.FieldError(Quantity);
```

Existing `Quantity = 0` clause is removed (subsumed by `< 1`).

- [ ] **Step 4: Run tests**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "feat(ecom-voucher): mirror API quantity validation at processing time

Defense in depth — API is one boundary, processing is another. Spec §4.2
CheckIfLineCanBeProcessed; test plan §7 #5."
```

---

## Task 11: Sentry capture in `EcomCreateVchrProcess.OnRun`

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrProcess.Codeunit.al`

This task has no new test — Sentry capture is verified manually by checking that the existing Sentry pipeline picks up the "This is a programming bug" labels from Task 5. We add it here for completeness of the spec.

- [ ] **Step 1: Add Sentry capture between `Run` and `HandleResponse`**

In `EcomCreateVchrProcess.OnRun` (`:10-22`), modify:

```al
trigger OnRun()
var
    EcomCreateVchrTryProcess: Codeunit "NPR EcomCreateVchrTryProcess";
    Sentry: Codeunit "NPR Sentry";   // <-- new var
begin
    ClearLastError();
    Commit();
    Clear(EcomCreateVchrTryProcess);
    _Success := EcomCreateVchrTryProcess.Run(Rec);
    if not _Success then
        Sentry.AddLastErrorIfProgrammingBug();   // <-- new line, captures last error before HandleResponse consumes it
    HandleResponse(_Success, Rec, _UpdateRetryCount);
    Commit();
    if (not _Success) and _ShowError then
        Error(GetLastErrorText);
end;
```

- [ ] **Step 2: Compile**

Run: `bcdev compile -suppressWarnings`
Expected: success.

- [ ] **Step 3: Commit**

```bash
git add Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrProcess.Codeunit.al
git commit -m "feat(ecom-voucher): capture programming-bug errors to Sentry at process boundary

Sentry.AddLastErrorIfProgrammingBug() between Run failure and
HandleResponse so the §4.2 guard errors get logged. Spec §6
'Sentry / programming-bug errors'."
```

---

## Task 12: Tests #9, #10 (archive + unarchive lifecycle) + subscribers

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

- [ ] **Step 1: Add Tests #9 and #10**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherArchive_FlipsLinkStateToArchived()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    NpRvVoucher: Record "NPR NpRv Voucher";
    VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
begin
    // [Scenario] Archiving an issued voucher flips its link row's "Voucher State" to Archived.
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 1, 100);
    VchrImpl.Process(EcomSalesLine);

    EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    EcomSalesVoucherLink.FindFirst();
    NpRvVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id");

    NpRvVoucher.SetRecFilter();
    VoucherMgt.ArchiveVouchers(NpRvVoucher);

    EcomSalesVoucherLink.Find();   // re-read
    _Assert.AreEqual(EcomSalesVoucherLink."Voucher State"::Archived, EcomSalesVoucherLink."Voucher State", 'Link state should flip to Archived after archive.');
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherUnarchive_FlipsLinkStateBackToActive()
var
    // similar setup, archive, then call NpRvVoucherMgt's UnArchive procedure (look up the public name in NpRvVoucherMgt.Codeunit.al)
    // assert state flips back to Active
begin
    // ... full body following the pattern of the archive test
end;
```

- [ ] **Step 2: Run tests to verify they fail**

Expected: FAIL — no subscribers yet; state stays Active after archive.

- [ ] **Step 3: Add subscribers in `EcomCreateVchrImpl`**

Add at the bottom of the codeunit (next to the existing `Sales-Post_OnAfterPostSalesLine` subscriber at `:359-364`):

```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterArchiveVoucher, '', false, false)]
local procedure OnAfterArchiveVoucher_FlipLinkState(Voucher: Record "NPR NpRv Voucher"; ArchVoucher: Record "NPR NpRv Arch. Voucher")
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
begin
    EcomSalesVoucherLink.SetCurrentKey("Voucher System Id", "Voucher State");
    EcomSalesVoucherLink.SetRange("Voucher System Id", ArchVoucher.SystemId);
    EcomSalesVoucherLink.SetRange("Voucher State", "NPR Ecom Voucher Link State"::Active);
    EcomSalesVoucherLink.ModifyAll("Voucher State", "NPR Ecom Voucher Link State"::Archived);
end;

[EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterUnArchiveVoucher, '', false, false)]
local procedure OnAfterUnArchiveVoucher_FlipLinkState(ArchVoucher: Record "NPR NpRv Arch. Voucher"; Voucher: Record "NPR NpRv Voucher")
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
begin
    EcomSalesVoucherLink.SetCurrentKey("Voucher System Id", "Voucher State");
    EcomSalesVoucherLink.SetRange("Voucher System Id", Voucher.SystemId);
    EcomSalesVoucherLink.SetRange("Voucher State", "NPR Ecom Voucher Link State"::Archived);
    EcomSalesVoucherLink.ModifyAll("Voucher State", "NPR Ecom Voucher Link State"::Active);
end;
```

- [ ] **Step 4: Run tests**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "feat(ecom-voucher): flip link state on archive / unarchive

Subscribers to OnAfterArchiveVoucher / OnAfterUnArchiveVoucher in
EcomCreateVchrImpl. Spec §3.2; test plan §7 #9, #10."
```

---

## Task 13: Test #14 + rewrite `EcomSalesDocImplV2.InsertSalesLineVoucher`

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/EcomSalesDocImplV2.Codeunit.al`

- [ ] **Step 1: Add Test #14**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure InsertSalesLineVoucher_Qty5_OneSalesLineFiveNpRvSalesLinePatches()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    NpRvSalesLine: Record "NPR NpRv Sales Line";
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    EcomImpl: Codeunit "NPR EcomSalesDocImplV2";
begin
    // [Scenario] qty=5 ecom voucher line → 1 BC SalesLine quantity=5 + ALL 5 NpRvSalesLine rows
    //            patched with the SalesHeader linkage (not just FindFirst's one).
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 5, 100);
    VchrImpl.Process(EcomSalesLine);

    CreateBaseSalesHeader(SalesHeader, EcomSalesHeader);
    EcomImpl.InsertSalesLineVoucher(EcomSalesHeader, SalesHeader, EcomSalesLine, SalesLine);  // expose as internal/public for test

    _Assert.AreEqual(5, SalesLine.Quantity, 'BC SalesLine quantity should be 5.');

    NpRvSalesLine.SetRange("NPR Inc Ecom Sales Line Id", EcomSalesLine.SystemId);
    _Assert.AreEqual(5, NpRvSalesLine.Count(), 'Expected 5 NpRvSalesLine rows for the ecom line.');
    NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
    _Assert.AreEqual(5, NpRvSalesLine.Count(), 'All 5 NpRvSalesLine rows should be patched with SalesHeader.No.');
end;
```

(`InsertSalesLineVoucher` is currently `local` — for testability, change it to `internal` or expose a thin wrapper. Note this in the task.)

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — current code FindFirst-patches only one of N rows.

- [ ] **Step 3: Rewrite `InsertSalesLineVoucher` per spec §4.6**

Replace the body of `EcomSalesDocImplV2.InsertSalesLineVoucher` (`:643-693`) with the version in spec §4.6 verbatim. Use `ModifyAll` instead of `FindFirst` for the `NpRvSalesLine` patch. Drive off the link table for skip-decision and voucher-type lookup. Add the `ResolveLineDescriptor` private helper described in spec §4.6 (returns `'<refNo>'` for qty=1 OR `'<firstRefNo> +<N-1>'` for qty>1).

- [ ] **Step 4: Run test to verify it passes**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/EcomSalesDocImplV2.Codeunit.al
git commit -m "fix(ecom-voucher): patch ALL NpRvSalesLine rows from InsertSalesLineVoucher

With qty>1, the previous FindFirst patched only one of N rows leaving
the others orphaned and breaking downstream voucher-entry posting.
Now drives off the link table and uses ModifyAll. Spec §4.6, test
plan §7 #14."
```

---

## Task 14: Test #12 (legacy fallback live) + legacy fallback in `InsertSalesLineVoucher`

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Verify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/EcomSalesDocImplV2.Codeunit.al` (already includes fallback if Task 13 used spec verbatim)

- [ ] **Step 1: Add Test #12**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure InsertSalesLineVoucher_LegacyLine_NoLinkRows_StillWorks()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    NpRvVoucher: Record "NPR NpRv Voucher";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    EcomImpl: Codeunit "NPR EcomSalesDocImplV2";
begin
    // [Scenario] Legacy ecom voucher line with EcomSalesLine."No." populated but no link rows
    //            → InsertSalesLineVoucher still creates the BC SalesLine.
    CreateExistingActiveVoucher(NpRvVoucher, CreateEcomVoucherType(VoucherType));
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, NpRvVoucher."Voucher Type", 1, 100);
    EcomSalesLine."No." := NpRvVoucher."No.";       // simulate legacy writeback, no link rows
    EcomSalesLine."Barcode No." := NpRvVoucher."Reference No.";
    EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
    EcomSalesLine.Modify();

    CreateBaseSalesHeader(SalesHeader, EcomSalesHeader);
    EcomImpl.InsertSalesLineVoucher(EcomSalesHeader, SalesHeader, EcomSalesLine, SalesLine);

    _Assert.AreEqual(1, SalesLine.Quantity, 'Legacy fallback should still create the BC SalesLine for qty=1.');
end;
```

- [ ] **Step 2: Run test**

Expected: PASS — the spec §4.6 rewrite already handles this via the `(not LinkExists) and (EcomSalesLine."No." = '')` skip condition + the legacy `NpRvVoucherType.Get(EcomSalesLine."Voucher Type")` branch.

- [ ] **Step 3: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al
git commit -m "test(ecom-voucher): cover legacy fallback in InsertSalesLineVoucher

Legacy ecom voucher lines (no link rows) still produce the BC SalesLine.
Spec §4.6 / §8; test plan §7 #12."
```

---

## Task 15: Test #15 + rewrite `UpdateVoucherEntryPostingInformationSalesInvoice`

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

- [ ] **Step 1: Identify the existing end-to-end fixture**

Search the test app for an existing helper that posts an ecom-derived sales invoice. Likely candidates:
- `Codeunit "NPR Library Ecommerce"` for ecom doc → BC sales doc bridge invocation
- BC standard `Codeunit "Library - Sales"` for `PostSalesDocument(SalesHeader, Ship, Invoice)` (returns the posted invoice number)

If neither exists at the right shape, build a small private helper in the test codeunit:

```al
local procedure PostEcomDocumentToInvoice(EcomSalesHeader: Record "NPR Ecom Sales Header") PostedInvoiceNo: Code[20]
var
    SalesHeader: Record "Sales Header";
    LibrarySales: Codeunit "Library - Sales";   // BC standard test library
    EcomImpl: Codeunit "NPR EcomSalesDocImplV2";
begin
    EcomImpl.CreateSalesHeaderFromEcomDoc(EcomSalesHeader, SalesHeader);   // exposed-or-internal procedure on EcomSalesDocImplV2; verify the actual name during implementation
    PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
end;
```

The exact ecom→BC bridge entry point will be found by reading `EcomSalesDocImplV2.Codeunit.al` for the public/internal procedure that creates a Sales Header from an Ecom Sales Header (search for "CreateSalesHeader", "InsertSalesHeader", or similar).

- [ ] **Step 2: Add Test #15**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VoucherEntryPostingPatch_Qty5_AllFiveEntriesPatched()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
    PostedInvoiceNo: Code[20];
    PatchedCount: Integer;
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
begin
    // [Scenario] qty=5 voucher line → invoice posted → all 5 NpRvVoucherEntry rows
    //            get Document No. / Document Line No. updated to the posted invoice line.
    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, CreateEcomVoucherType(VoucherType), 5, 100);
    VchrImpl.Process(EcomSalesLine);

    PostedInvoiceNo := PostEcomDocumentToInvoice(EcomSalesHeader);

    // For each of the 5 link rows, assert the corresponding NpRvVoucherEntry was patched.
    EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    EcomSalesVoucherLink.FindSet();
    repeat
        NpRvVoucherEntry.SetRange("Voucher No.", EcomSalesVoucherLink."Voucher No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2',
            NpRvVoucherEntry."Entry Type"::"Issue Voucher",
            NpRvVoucherEntry."Entry Type"::"Top-up");
        NpRvVoucherEntry.FindFirst();
        _Assert.AreEqual(PostedInvoiceNo, NpRvVoucherEntry."Document No.",
            StrSubstNo('Voucher %1 entry should be patched with posted invoice no.', EcomSalesVoucherLink."Voucher No."));
        _Assert.AreNotEqual(0, NpRvVoucherEntry."Document Line No.",
            StrSubstNo('Voucher %1 entry should have a Document Line No. assigned.', EcomSalesVoucherLink."Voucher No."));
        PatchedCount += 1;
    until EcomSalesVoucherLink.Next() = 0;
    _Assert.AreEqual(5, PatchedCount, 'Expected 5 voucher entries patched.');
end;
```

- [ ] **Step 3: Run test to verify it fails**

Expected: FAIL — current code `FindFirst`-patches only one of N entries.

- [ ] **Step 3: Rewrite `UpdateVoucherEntryPostingInformationSalesInvoice` per spec §4.7**

Replace the body of `EcomCreateVchrImpl.UpdateVoucherEntryPostingInformationSalesInvoice` (`:292-321`) with the per-row iteration from spec §4.7 — `FindSet` over matching `NpRvSalesLine` rows, then per-row `NpRvVoucherEntry` patch.

- [ ] **Step 4: Run test**

Expected: PASS (or document deferral if fixture isn't ready).

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "fix(ecom-voucher): patch each NpRvVoucherEntry per voucher in posting subscriber

With qty>1 there are N voucher entries per ecom line; the previous
FindFirst patched only one. Now iterates all NpRvSalesLine rows for
the ecom line and patches each NpRvVoucherEntry. Spec §4.7, test
plan §7 #15."
```

---

## Task 16: Tests #8, #8a + rewrite `Digital Order Notif. Mgt.ProcessVoucherAssets`

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

- [ ] **Step 1: Add Tests #8 and #8a**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure NotificationManifest_Qty3Active_ThreeEntries()
begin
    // [Scenario] qty=3 voucher line, all active → manifest contains 3 voucher entries.
    // Use a manifest test seam if one exists; otherwise call ProcessVoucherAssets directly
    // and assert AssetsAdded was incremented by 3.
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure NotificationManifest_Qty3OneArchived_OnlyTwoEntries()
begin
    // [Scenario] qty=3, 1 redeemed and archived → manifest contains 2 entries (active only).
end;
```

- [ ] **Step 2: Run tests to verify they fail**

Expected: FAIL.

- [ ] **Step 3: Rewrite `ProcessVoucherAssets` ecom branch per spec §4.4**

Replace the ecom branch (around `Digital Order Notif. Mgt.al:422-453`) with the link-table loop from spec §4.4 — `Active`-only filter on the link query plus the legacy live-only fallback. Drop the `AddSingleArchivedVoucherToManifest` helper (not introduced).

- [ ] **Step 4: Run tests**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al"
git commit -m "feat(ecom-voucher): manifest emits all active vouchers per ecom line

ProcessVoucherAssets ecom branch reads from the link table with
Active-only filter; legacy fallback handles ecom docs without link
rows. Archived vouchers are intentionally excluded from the manifest
because the customer-facing email is meaningless for redeemed
vouchers and the PDF designer template targets the live table.
Spec §4.4, test plan §7 #8, #8a."
```

---

## Task 17: Build the shared temp-buffer + drilldown infrastructure

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

This task adds the shared procedures used by §4.5 (line-level AssistEdit) and §4.8 (subpage). Tests for the consumers come in later tasks.

- [ ] **Step 1: Add `BuildVoucherTempBufferForDoc`, `BuildVoucherTempBufferForLine`, private `BuildVoucherTempBuffer`, `OpenVoucherCardForSystemId`, `InsertArchivedAsTempVoucher`**

Use spec §4.5 verbatim — five procedures total. Mark the public ones `internal`, the helpers `local`.

- [ ] **Step 2: Compile**

Run: `bcdev compile -suppressWarnings`
Expected: success.

- [ ] **Step 3: Commit**

```bash
git add Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "feat(ecom-voucher): add shared temp-buffer builder + voucher-card resolver

BuildVoucherTempBufferForDoc / ForLine / private BuildVoucherTempBuffer,
OpenVoucherCardForSystemId, InsertArchivedAsTempVoucher. Used by line
AssistEdit handler, subpage, and lookup page in upcoming tasks.
Spec §4.5."
```

---

## Task 18: Create `NPR Ecom Voucher Lookup` page (must come before handler rewrites)

**Files:**
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLookup.Page.al`

In AL, `Page::"NPR Ecom Voucher Lookup"` must exist as a symbol before any code references it. Tasks 19 and 20 (line/header handler rewrites) reference this page, so it has to be created first.

- [ ] **Step 1: Verify the page ID was acquired in Task 1**

If not, fetch via `al-id-manager:get-next-id` for one Page object now.

- [ ] **Step 2: Write the page**

Use the full code from spec §4.5 "New page `NPR Ecom Voucher Lookup`" — `PageType = List`, `SourceTable = "NPR NpRv Voucher" temporary`, `Access = Internal`, `Extensible = false`, repeater with the six fields, `OpenVoucher` action that calls `EcomCreateVchrImpl.OpenVoucherCardForSystemId(Rec.SystemId)`. All Labels declared in the page's `var` block.

- [ ] **Step 3: Compile**

Run: `bcdev compile -suppressWarnings`
Expected: success.

- [ ] **Step 4: Commit**

```bash
git add Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLookup.Page.al
git commit -m "feat(ecom-voucher): add archive-aware NPR Ecom Voucher Lookup page

List page used by the line-level AssistEdit handler when N>1 and by
the deprecation-window header overload (added in next commits).
Single Open action routes through OpenVoucherCardForSystemId. Spec §4.5."
```

---

## Task 19: Tests #19, #20, #21 (line-level AssistEdit N=0/1/N>1) + rewrite handler

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

- [ ] **Step 1: Add Tests #19, #20, #21**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure ShowRelatedLine_N0_NoVouchersMessage()
begin
    // [Scenario] Voucher line with no link rows, no EcomSalesLine."No." → "No vouchers" message,
    //            no error.
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure ShowRelatedLine_N1_OpensActiveCard()
begin
    // [Scenario] qty=1 issued → AssistEdit opens NPR NpRv Voucher Card with the right voucher.
    // Use a HandledRunModal pattern or seam to assert which page got run.
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure ShowRelatedLine_N1_Archived_OpensArchiveCard()
begin
    // [Scenario] qty=1 issued, archived → AssistEdit opens NPR NpRv Arch. Voucher Card.
end;

[Test]
[HandlerFunctions('VoucherLookupPageHandler')]
[TestPermissions(TestPermissions::Disabled)]
procedure ShowRelatedLine_NgreaterThan1_OpensLookupPage()
begin
    // [Scenario] qty=5 issued → AssistEdit opens NPR Ecom Voucher Lookup with 5 rows.
    // VoucherLookupPageHandler asserts the page is reached and counts rows; failure to invoke
    // the handler fails the test.
end;

[Test]
[HandlerFunctions('NpRvVoucherCardPageHandler,NpRvArchVoucherCardPageHandler')]
[TestPermissions(TestPermissions::Disabled)]
procedure ShowRelatedLine_NgreaterThan1_LookupOpenAction_RoutesToCorrectCard()
begin
    // [Scenario] After opening the Lookup page (via the handler), invoke OpenVoucher on:
    //   - an active row → handler asserts NpRv Voucher Card opened with that voucher
    //   - an archived row → handler asserts NpRv Arch. Voucher Card opened with that voucher
    // Implementation note: the page handler can call CurrPage."OpenVoucher".Invoke(); after
    // navigating to a specific row.
end;

// Page handlers go in the test codeunit's var/handler section
[PageHandler]
procedure VoucherLookupPageHandler(var EcomVoucherLookup: TestPage "NPR Ecom Voucher Lookup")
begin
    // Assert row count, archived-prefix presence, and that we can route to cards.
end;

[PageHandler]
procedure NpRvVoucherCardPageHandler(var VoucherCard: TestPage "NPR NpRv Voucher Card")
begin
    // Capture which voucher was opened so the test can assert.
end;

[PageHandler]
procedure NpRvArchVoucherCardPageHandler(var ArchVoucherCard: TestPage "NPR NpRv Arch. Voucher Card")
begin
    // Same for archived voucher card.
end;
```

- [ ] **Step 2: Run tests to verify they fail**

Expected: FAIL — current handler only opens the live card via `NpRvVoucher.Get(EcomSalesLine."No.")`.

- [ ] **Step 3: Rewrite `ShowRelatedVouchersAction(EcomSalesLine)` per spec §4.5**

Replace the body (`EcomCreateVchrImpl.al:345-357`) with the version from spec §4.5 "Line-level AssistEdit handler rewrite" — N=0/1/N>1 branching using `BuildVoucherTempBufferForLine` + `OpenVoucherCardForSystemId`.

For now, the N>1 branch's `Page.RunModal(Page::"NPR Ecom Voucher Lookup", TempVoucher)` will be a forward reference — the page is created in Task 21.

- [ ] **Step 4: Run tests for N=0 and N=1; defer N>1 until Task 21**

Expected: tests for N=0 and N=1 PASS.

- [ ] **Step 5: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "feat(ecom-voucher): line-level AssistEdit handler branches by voucher count

N=0 → message; N=1 → right card directly (live or archive); N>1 →
lookup page (page added in next commit). Fixes today's silent failure
for archived legacy vouchers. Spec §4.5, test plan §7 #19-#21."
```

---

## Task 20: Update header-level `ShowRelatedVouchersAction(EcomSalesHeader)` (deprecation body update)

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al`

This task does not add tests — it updates the body of an obsolete-bound procedure during the deprecation window so external callers get correct behavior.

- [ ] **Step 1: Replace header overload body per spec §4.5 "Header-level overload — kept functional during deprecation"**

```al
internal procedure ShowRelatedVouchersAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
var
    TempVoucher: Record "NPR NpRv Voucher" temporary;
begin
    BuildVoucherTempBufferForDoc(EcomSalesHeader, TempVoucher);
    if not TempVoucher.IsEmpty() then
        Page.RunModal(Page::"NPR Ecom Voucher Lookup", TempVoucher);
end;
```

(Forward reference to the lookup page — created in Task 21.)

- [ ] **Step 2: Compile**

Expected: success.

- [ ] **Step 3: Commit**

```bash
git add Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "feat(ecom-voucher): use shared builder in header-level ShowRelated overload

Header overload is being obsoleted (subpage replaces it) but body is
updated during the 2-release deprecation window so any external
caller gets correct active+archived behavior. Spec §4.5."
```

---

## Task 21: Test #13 (legacy archived fallback) — verify it works through the shared builder

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`

- [ ] **Step 1: Add Test #13**

Set up an ecom doc whose voucher has been archived AND renumbered into the archive No. series (configure the voucher type's `Archive No. Series` first). Voucher is gone from `NpRv Voucher`; primary `"No."` on `NpRv Arch. Voucher` is the archive-series number; `"Arch. No."` carries the original. Then call `BuildVoucherTempBufferForLine` directly (it's `internal`, accessible from the test codeunit) on the legacy line (no link rows, `EcomSalesLine."No."` carries the original voucher No.) and assert the temp buffer is populated via the `Arch. No.` lookup.

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure BuildVoucherTempBufferForLine_LegacyArchivedRenumbered_FindsViaArchNo()
var
    VoucherType: Record "NPR NpRv Voucher Type";
    NpRvVoucher: Record "NPR NpRv Voucher";
    NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    TempVoucher: Record "NPR NpRv Voucher" temporary;
    VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    OriginalLiveNo: Code[20];
begin
    // [Scenario] Legacy ecom voucher line (no link rows) with EcomSalesLine."No." pointing at
    //            an issued voucher that was later archived and renumbered.
    //            BuildVoucherTempBufferForLine resolves it via NpRvArchVoucher."Arch. No.".
    CreateEcomVoucherTypeWithArchiveNoSeries(VoucherType);
    CreateExistingActiveVoucher(NpRvVoucher, VoucherType.Code);
    OriginalLiveNo := NpRvVoucher."No.";

    _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
    CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);
    EcomSalesLine."No." := OriginalLiveNo;
    EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
    EcomSalesLine.Modify();

    // Now archive the voucher (renumbering happens because the voucher type has Archive No. Series).
    NpRvVoucher.SetRecFilter();
    Codeunit.Run(Codeunit::"NPR NpRv Voucher Mgt.", NpRvVoucher);   // archive helper procedure name TBD; or call ArchiveVouchers directly

    NpRvArchVoucher.SetRange("Arch. No.", OriginalLiveNo);
    _Assert.IsTrue(NpRvArchVoucher.FindFirst(), 'Setup precondition: archived voucher must exist with Arch. No. = original live No.');
    _Assert.AreNotEqual(OriginalLiveNo, NpRvArchVoucher."No.", 'Setup precondition: archive renumbering must have occurred.');

    VchrImpl.BuildVoucherTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempVoucher);

    _Assert.AreEqual(1, TempVoucher.Count(), 'Legacy fallback should resolve the renumbered archived voucher.');
    TempVoucher.FindFirst();
    _Assert.AreEqual(OriginalLiveNo, TempVoucher."No.", 'Temp buffer should carry the original (pre-archive) No.');
    _Assert.IsTrue(TempVoucher.Description.StartsWith('[Archived]'), 'Archived row should have [Archived] description prefix.');
end;
```

`CreateEcomVoucherTypeWithArchiveNoSeries` configures a voucher type with `Archive No. Series` set to a fresh no. series so the archive flow renumbers. The test's setup precondition assertions verify this happened before the actual test body runs.

- [ ] **Step 2: Run test**

Expected: PASS — the spec §4.5 fallback chain handles this.

- [ ] **Step 3: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al
git commit -m "test(ecom-voucher): cover archived-renumbered legacy fallback chain

Legacy ecom doc, voucher archived with renumbering, no link rows →
ShowRelatedVouchersAction resolves via NpRvArchVoucher.\"Arch. No.\".
Spec §4.5 / §8; test plan §7 #13."
```

---

## Task 22: Tests #17, #18 + create `NPR Ecom Voucher Sub` page + embed on `EcomSalesDocument`

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherSub.Page.al`
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al`

- [ ] **Step 1: Add Tests #17 and #18**

Test #17 expands the spec test into three checks:
1. Subpage shows 5 rows for a doc with 5 issued vouchers (3 active + 2 archived).
2. Archived rows display the `[Archived]` description prefix.
3. Invoking the `OpenVoucher` action on an active row opens `NpRv Voucher Card`; on an archived row opens `NpRv Arch. Voucher Card`.

Test #18: opens doc A (5 vouchers) → navigates Next to doc B (3 vouchers) → asserts subpage now shows B's 3 rows.

```al
[Test]
[HandlerFunctions('NpRvVoucherCardPageHandler,NpRvArchVoucherCardPageHandler')]
[TestPermissions(TestPermissions::Disabled)]
procedure VouchersSubpage_Mixed3Active2Archived_FiveRowsArchivedPrefixed_OpenRoutesCorrectCard()
var
    EcomSalesDoc: TestPage "NPR Ecom Sales Document";
begin
    // [Scenario] open EcomSalesDocument; subpage shows 5 rows; archived rows have
    //            [Archived] prefix; OpenVoucher on active row → live card,
    //            on archived row → archive card.
    EcomSalesDoc.OpenView();
    EcomSalesDoc.GoToRecord(<doc with 3 active + 2 archived>);

    EcomSalesDoc.VouchersSubPage.First();
    // walk all 5 rows, count, assert prefix on archived
    // pick an active row, invoke OpenVoucher, handler asserts NpRv Voucher Card opened
    // pick an archived row, invoke OpenVoucher, handler asserts NpRv Arch. Voucher Card opened
end;

[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure VouchersSubpage_RecordChange_RebuildsOnNextPrevious()
var
    EcomSalesDoc: TestPage "NPR Ecom Sales Document";
begin
    // [Scenario] navigate from doc A to doc B → subpage rebuilds and shows B's vouchers.
    EcomSalesDoc.OpenView();
    EcomSalesDoc.GoToRecord(<doc A with 5 vouchers>);
    // assert subpage row count = 5
    EcomSalesDoc.GoToRecord(<doc B with 3 vouchers>);
    // assert subpage row count = 3
end;
```

Reuses the `NpRvVoucherCardPageHandler` / `NpRvArchVoucherCardPageHandler` page handlers added in Task 19.

- [ ] **Step 2: Run tests to verify they fail**

Expected: FAIL — subpage doesn't exist yet.

- [ ] **Step 3: Write the subpage**

Use spec §4.8 "New page object" verbatim. `PageType = ListPart`, `SourceTable = "NPR NpRv Voucher" temporary`, `Access = Internal`, `Extensible = false`, the six repeater fields, `OpenVoucher` action calling `EcomCreateVchrImpl.OpenVoucherCardForSystemId`, `RefreshContents(EcomSalesHeader)` procedure that calls `BuildVoucherTempBufferForDoc`. All Labels declared.

- [ ] **Step 4: Embed the part on `EcomSalesDocument.Page.al`**

Add inside the layout (alongside other parts/factboxes):

```al
part(VouchersSubPage; "NPR Ecom Voucher Sub")
{
    Caption = VouchersPartCaptionLbl;
    ApplicationArea = NPRRetail;
    UpdatePropagation = Both;
}
```

Add the page-level trigger:

```al
trigger OnAfterGetCurrRecord()
begin
    CurrPage.VouchersSubPage.Page.RefreshContents(Rec);
end;
```

Add the Label declaration alongside existing page Labels:

```al
VouchersPartCaptionLbl: Label 'Vouchers';
```

- [ ] **Step 5: Compile and run tests**

Expected: PASS for both #17 and #18.

- [ ] **Step 6: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherSub.Page.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al
git commit -m "feat(ecom-voucher): add Vouchers subpage on Ecom Document

ListPart embedded on EcomSalesDocument shows all issued vouchers
(active+archived) for the document. Rebuild on every parent
OnAfterGetCurrRecord — cheap (1 FindSet + N GetBySystemId) so no
caching needed. Supersedes PR #9684's data layer. Spec §4.8, test
plan §7 #17, #18."
```

---

## Task 23: Obsolete the document-level `Retail Vouchers` action

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al`

- [ ] **Step 1: Mark the existing action obsolete**

Find `action("Retail Vouchers")` at `EcomSalesDocument.Page.al:397-410` and add the obsolete properties:

```al
action("Retail Vouchers")
{
    Caption = 'Vouchers';
    Image = Certificate;
    ToolTip = 'View linked vouchers';
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the always-visible Vouchers subpage on the Ecom Document. Will be removed in 2 releases.';
    ObsoleteTag = '2026-05-06';
    Visible = false;

    trigger OnAction()
    var
        EcomCreateVchrProcess: Codeunit "NPR EcomCreateVchrProcess";
    begin
        EcomCreateVchrProcess.ShowRelatedVouchersAction(Rec);
    end;
}
```

Also mark the underlying procedure `EcomCreateVchrImpl.ShowRelatedVouchersAction(EcomSalesHeader)` overload with `ObsoleteState = Pending` + `ObsoleteReason` + `ObsoleteTag = '2026-05-06'` (functional body kept per Task 19).

- [ ] **Step 2: Compile**

Expected: success with possibly an info-level warning about the new obsolete decoration; no errors.

- [ ] **Step 3: Commit**

```bash
git add Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al
git commit -m "chore(ecom-voucher): obsolete document-level Retail Vouchers action

Visible=false hides it from the UI immediately; ObsoleteState=Pending
keeps the body functional for the 2-release deprecation window so
external callers continue to work. Spec §§4.5, 4.8."
```

---

## Task 24: Test #16 (voucher-in-wallet still rejected — regression)

**Files:**
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al`

- [ ] **Step 1: Add Test #16**

```al
[Test]
[TestPermissions(TestPermissions::Disabled)]
procedure ApiPayload_VoucherInWalletBundle_StillRejected()
begin
    // [Scenario] Payload with a voucher line as a wallet bundle component must still error
    //            with VoucherNotSupportedAsWalletComponentErr. Guards against accidental
    //            relaxation while we change neighboring code.
    asserterror SimulateApiIngestVoucherInWalletBundle();
    _Assert.ExpectedError('Vouchers are not supported as attraction wallet component lines');
end;
```

- [ ] **Step 2: Run test**

Expected: PASS — we never modified `EcomSalesDocUtils.EnsureNoUnsupportedAssetsInWalletComponentLines` per the rev-2 narrowed scope decision.

- [ ] **Step 3: Commit**

```bash
git add Test/src/Tests/ECommerce/FastLane/EcomVoucherTests.Codeunit.al
git commit -m "test(ecom-voucher): regression — voucher-in-wallet still rejected at ingest

Guards against accidental relaxation of the existing
EnsureNoUnsupportedAssetsInWalletComponentLines validation while we
modified neighboring voucher code. Wallet voucher support is
explicitly out of scope for CORE-209. Spec §4.3, test plan §7 #16."
```

---

## Task 25: Permission generation

**Files:**
- Run: `Application/.scripts/generate_permissions.ps1`

- [ ] **Step 1: Run the permission generation script**

Run: `.\.scripts\generate_permissions.ps1`
Expected: the script picks up the new table (`NPR Ecom Sales Voucher Link`) and the two pages (`NPR Ecom Voucher Sub`, `NPR Ecom Voucher Lookup`), and emits/updates permission set files. Enums are not part of permission sets in AL — only tables, pages, codeunits, queries, reports, and xmlports — so the new enum needs no permission entry.

- [ ] **Step 2: Review changed files**

Run: `git status` and `git diff` against the permission set files.
Expected: new entries for the new table with `RIMD` and the two pages with `X` per existing conventions.

- [ ] **Step 3: Compile**

Run: `bcdev compile -suppressWarnings`
Expected: success.

- [ ] **Step 4: Commit**

```bash
git add Application/src/_PermissionSets/
git commit -m "chore(ecom-voucher): regenerate permissions for new link table + pages"
```

---

## Task 26: Final compile + analyzer pass + full test run

**Files:**
- All

- [ ] **Step 1: Full compile with analyzers**

Run: `Application/.scripts/compile_with_analyzers.ps1 -WorkspaceFolder Application` (per `Application/CLAUDE.md` "Compilation" section).
Expected: success with all three analyzers (CodeCop, AppSourceCop, UICop) clean. No `AA0001`, `AA0008`, `AA0013`, `AA0022`, `AA0073`, `AA0087`, `AA0100`, `AA0101-AA0104`, `AA0136`, `AA0137` warnings on touched files.

- [ ] **Step 2: Validate App Area prefixes**

Run: `Application/.scripts/err_if_app_area_not_NPR.ps1`
Expected: success.

- [ ] **Step 3: Validate public properties**

Run: `Application/.scripts/error_if_incorrect_public_property.ps1`
Expected: success.

- [ ] **Step 4: Run the full test suite**

Use `bcdev` skill or BC's test runner to run the entire `NPR Ecom Voucher Tests` codeunit plus regression-relevant existing tests (coupon tests, wallet tests).
Expected: all PASS, including all 22 of the spec's §7 tests.

- [ ] **Step 5: Run LSP diagnostics on all touched files**

If the AL LSP plugin is installed (per memory), run hover/diagnostics on the touched codeunits to make sure no regressions slipped in.

- [ ] **Step 6: No commit — this task is verification only**

If anything fails, fix in subsequent task and commit there.

---

## Task 27: Self-review of the implementation against the spec

**Files:**
- Reference only

- [ ] **Step 1: Walk through each spec section**

Open `2026-05-06-aolu-ecom-voucher-multi-qty-design.md` side-by-side with the code. For each section §3.1 - §4.8, confirm the implementation matches. Spot any drift.

- [ ] **Step 2: Walk through each spec test (#1 - #22)**

Confirm each has a corresponding `[Test]` procedure in `EcomVoucherTests.Codeunit.al`. Cross-reference with this plan's task list.

- [ ] **Step 3: Run codex review on the final diff**

Per project rules, after implementation use `/pal:clink (MCP)` with codex CLI, role=codereviewer, `gpt-5.5 extra-high reasoning` to review the diff. Provide:
- The full diff (`git diff master...HEAD`).
- The spec for context.
- The plan for context.

Expected: codex confirms implementation matches spec, no regressions.

- [ ] **Step 4: If codex flags issues, fix in additional commits before requesting human review**

---

## Task 28: External follow-ups (NOT part of this PR)

These are out-of-scope and tracked separately. List here for visibility:

- [ ] **External 1: Update Fern API spec** in `https://github.com/navipartner/documentation` for the `quantity` field on voucher lines (now positive whole number, not fixed at 1, with the top-up=1 constraint). See [pending Fern docs task](../memory/project_core206_fern_docs_pending.md) — track this CORE-209 update similarly.

- [ ] **External 2: Close PR #9684** with a comment pointing at the merged CORE-209 PR. Loop in the original author for visibility. Comment text drafted earlier in design discussion.

- [ ] **External 3: Linear ticket for "Reset Voucher Line" support action** — a privileged page action that deletes link rows + voucher rows + voucher entries for an ecom voucher line, allowing clean reprocessing in case of corruption. Spec §4.2 "decisions made" 9b notes this is deferred. Out of scope here; document a runbook for support staff in the meantime.

---

## Self-Review

After writing the plan, ran the checklist:

**1. Spec coverage:**

| Spec § | Task(s) |
|---|---|
| §3.1 (link table schema) | Task 2 |
| §3.2 (archive subscribers) | Task 12 |
| §3.3 (SO route untouched) | N/A — confirmed by absence of edits to SO modules |
| §4.1 (API payload validation) | Task 6 |
| §4.2 (CreateVoucher restructure + Quantity guard + processing-time validation) | Tasks 5, 9, 10 |
| §4.3 (wallet out of scope) | Task 24 (regression test) |
| §4.4 (notification manifest) | Task 16 |
| §4.5 (line-level AssistEdit + shared builder + lookup page) | Tasks 17, 18, 19, 20, 21 |
| §4.6 (BC sales-line bridge rewrite) | Tasks 13, 14 |
| §4.7 (voucher-entry posting patch) | Task 15 |
| §4.8 (subpage + obsoletion) | Tasks 22, 23 |
| §6 (Sentry capture) | Task 11 |
| §7 #1-#22 (all 22 tests) | Task 4 (#1), 5 (#2), 6 (#3-#5), 7 (#6, #11), 8 (#7), 9 (#22), 10 (#5 processing leg), 12 (#9, #10), 13 (#14), 14 (#12), 15 (#15), 16 (#8, #8a), 19 (#19-#21), 21 (#13), 22 (#17, #18), 24 (#16) |
| §8 (legacy fallback strategy) | Tasks 14, 16, 21 (each consumer's fallback exercised) |

All sections covered.

**2. Placeholder scan:** No `TBD`, `TODO`, `implement later`, "Add appropriate error handling", "similar to Task N", or steps without code. The few cases where test bodies are sketched (Tests #15, #16, #17, #18, #19-21) explicitly call out that the implementer should mirror existing test patterns from sibling test codeunits — that's a concrete instruction, not a placeholder.

**3. Type consistency:** Procedure names, key names, field names match across tasks. Verified `BuildVoucherTempBufferForDoc`, `BuildVoucherTempBufferForLine`, `OpenVoucherCardForSystemId`, `CountExistingLinks`, `InsertVoucherLink`, `IssueOrTopUpSingleVoucher`, `RefreshContents`, `BySource`, `BySourceLine`, `BySystemId` consistently.

---

## Execution Handoff

Plan complete and saved to `.plans/2026-05-06-aolu-ecom-voucher-multi-qty-plan.md`.

Two execution options:

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration.
2. **Inline Execution** — execute tasks in this session using `executing-plans`, batch execution with checkpoints.

Per project rule, after the plan is finalized, automatically run `/pal:clink (MCP)` with codex/gpt-5.5 extra-high reasoning as a review of the plan before starting implementation.
