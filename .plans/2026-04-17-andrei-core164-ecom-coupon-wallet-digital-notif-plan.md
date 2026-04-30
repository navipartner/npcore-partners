# CORE-164 follow-up: Ecom coupons & attraction wallets in digital notifications — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the existing CORE-164 Ecom digital-notification flow to cover standalone coupons and attraction-wallet bundles, add a new `Exclude Tickets From Manifest` setup flag, and harden the trigger against concurrent races — all Ecom-only (Magento/Shopify remain voucher+ticket only).

**Architecture:** Ecom-exclusive asset routing. `ProcessCouponAssets` and `ProcessWalletAssets` bodies are replaced with deterministic Ecom lookups (`Ecom Sales Coupon Link` + `WalletAssetHeaderReference` keyed by ecom line SystemId). Bundle-child filtering uses an in-memory `External Line ID → IsWallet` dictionary built in a single pre-pass. Notification insertion is serialized by an `UpdLock` on `NPR Ecom Sales Header` so concurrent last-one-done callers never duplicate-insert.

**Tech Stack:** Business Central AL (`#if not (BC17 or BC18 or BC19 or BC20 or BC21)` guard). Compile via `alc.exe` with CodeCop/AppSourceCop/UICop (see `.scripts/compile_with_analyzers.ps1`). Manual verification through the Postman sandbox requests embedded in the design spec (§"Test scenarios").

**Reference spec:** `.plans/2026-04-17-andrei-core164-ecom-coupon-wallet-digital-notif-design.md`

**Base branch:** `andrei/core-164-digital-notifications-from-ecom-sales-documents-for-virtual`

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `Application/src/Digital Notification/DigitalDocLineBuffer.Table.al` | Modify | +2 fields: `Source Line System Id` (Guid), `Is Wallet` (Boolean) |
| `Application/src/Digital Notification/DigitalNotificationSetup.Table.al` | Modify | +1 field: `Exclude Tickets From Manifest` (Boolean) |
| `Application/src/Digital Notification/DigitalNotificationSetup.Page.al` | Modify | Surface `Exclude Tickets From Manifest` |
| `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al` | Modify | Harden `TryCreateEcomDigitalNotification`; rewrite `PopulateBuffersFromEcomDoc` (two-pass + ancestor dictionary); extend `IdentifyAssetType`; widen `ProcessLineAssets` allowlist; replace `ProcessCouponAssets` & `ProcessWalletAssets` bodies; add ticket-exclusion guard; extend `ValidateDigitalNotifSetup` SetLoadFields |
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponProcess.Codeunit.al` | Modify | Call `TryCreateEcomDigitalNotification` on success |
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al` | Modify | Call `TryCreateEcomDigitalNotification` on success branch |
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipProcess.Codeunit.al` | Modify | Defensive `TryCreateEcomDigitalNotification` call on success (gate-unlatch only, no asset emission) |

No new files. All changes are additive or in-place replacements within existing units.

---

## Preflight

- [ ] **P1: Confirm worktree & branch**

Run:
```bash
cd /c/Projects/npcore && git status -sb && git log -1 --format="%h %s"
```
Expected: on `andrei/core-164-digital-notifications-from-ecom-sales-documents-for-virtual` (or a fresh worktree branched from it). If not, stop and ask the user before continuing.

- [ ] **P2: Ensure base CORE-164 files are present locally**

Run:
```bash
cd /c/Projects/npcore && ls "Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/EcomDigitalNotifJQ.Codeunit.al" && grep -c "TryCreateEcomDigitalNotification" "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al"
```
Expected: file exists and count ≥ 2. If absent, `git checkout origin/andrei/core-164-digital-notifications-from-ecom-sales-documents-for-virtual -- <paths>` or rebase/merge the CORE-164 branch onto the working branch first.

---

## Task 1: Add `Source Line System Id` + `Is Wallet` to line buffer

**Files:**
- Modify: `Application/src/Digital Notification/DigitalDocLineBuffer.Table.al`

The buffer is `TableType = Temporary`; field ids are not reserved by the AL ID Manager. Continue the existing 110/120 sequence with 130 and 140.

- [ ] **Step 1: Add the two fields after existing field 120**

In `DigitalDocLineBuffer.Table.al`, after the `"Ticket Reservation Line Id"` field block (currently field 120), insert:

```al
        field(130; "Source Line System Id"; Guid)
        {
            Caption = 'Source Line System Id';
            DataClassification = SystemMetadata;
        }
        field(140; "Is Wallet"; Boolean)
        {
            Caption = 'Is Wallet';
            DataClassification = SystemMetadata;
        }
```

- [ ] **Step 2: Compile with analyzers**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: build succeeds with 0 errors, 0 warnings. If anything fails, fix before moving on.

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalDocLineBuffer.Table.al" && git commit -m "Add Source Line System Id + Is Wallet to digital notification line buffer"
```

---

## Task 2: Add `Exclude Tickets From Manifest` to setup table + page

**Files:**
- Modify: `Application/src/Digital Notification/DigitalNotificationSetup.Table.al`
- Modify: `Application/src/Digital Notification/DigitalNotificationSetup.Page.al`

- [ ] **Step 1: Add the field to the setup table**

Open `DigitalNotificationSetup.Table.al`. Immediately after field 15 `"Exclude Vouchers From Manifest"` insert:

```al
        field(17; "Exclude Tickets From Manifest"; Boolean)
        {
            Caption = 'Exclude Tickets From Manifest';
            DataClassification = CustomerContent;
        }
```

Field id 17 is deliberately chosen to group visually with the existing 15 (“Exclude Vouchers From Manifest”) — same family, before the `Enabled = 20` block. No table extension conflicts: table `"NPR Digital Notification Setup"` (6248183) is `Extensible = false`.

- [ ] **Step 2: Surface the field on the setup page**

Open `DigitalNotificationSetup.Page.al`. Find the existing field control for `"Exclude Vouchers From Manifest"`. Immediately after its closing `}`, add:

```al
                field("Exclude Tickets From Manifest"; Rec."Exclude Tickets From Manifest")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether ticket assets should be excluded from the digital notification manifest. Enable this when the legacy welcome-ticket email is active and you want to avoid duplicate ticket delivery. Tickets inside attraction wallets are not affected by this flag — they remain rendered inside the wallet asset.';
                }
```

- [ ] **Step 3: Compile with analyzers**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: build succeeds, 0 errors, 0 warnings.

- [ ] **Step 4: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalNotificationSetup.Table.al" "Application/src/Digital Notification/DigitalNotificationSetup.Page.al" && git commit -m "Add 'Exclude Tickets From Manifest' setup flag"
```

---

## Task 3: Harden `TryCreateEcomDigitalNotification` with UpdLock pattern

**Files:**
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

Current body (before change):
```al
    internal procedure TryCreateEcomDigitalNotification(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
    begin
        if EcomSalesHeader."Virtual Items Process Status" <> EcomSalesHeader."Virtual Items Process Status"::Processed then
            exit;

        if not ValidateDigitalNotifSetup() then
            exit;

        if not IsManifestFeatureEnabled() then
            exit;

        if EcomDigitalNotifEntryExists(EcomSalesHeader.SystemId) then
            exit;

        PopulateBuffersFromEcomDoc(EcomSalesHeader, TempHeaderBuffer, TempLineBuffer);

        ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer);
    end;
```

- [ ] **Step 1: Replace the body with the locked implementation**

Find `TryCreateEcomDigitalNotification` and replace its entire body with:

```al
    internal procedure TryCreateEcomDigitalNotification(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        LockedEcomSalesHeader: Record "NPR Ecom Sales Header";
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
    begin
        if EcomSalesHeader."Virtual Items Process Status" <> EcomSalesHeader."Virtual Items Process Status"::Processed then
            exit;

        if not ValidateDigitalNotifSetup() then
            exit;

        if not IsManifestFeatureEnabled() then
            exit;

        // Serialize concurrent last-one-done callers for the same doc.
        // Example race: coupon JQ and wallet JQ both finish their last line at the same instant — both read
        // "Virtual Items Process Status = Processed" and call this procedure concurrently. Without the lock, both
        // could pass EcomDigitalNotifEntryExists and insert duplicate entries.
        LockedEcomSalesHeader.ReadIsolation := IsolationLevel::UpdLock;
        if not LockedEcomSalesHeader.Get(EcomSalesHeader."Entry No.") then
            exit;

        if EcomDigitalNotifEntryExists(LockedEcomSalesHeader.SystemId) then
            exit;

        PopulateBuffersFromEcomDoc(LockedEcomSalesHeader, TempHeaderBuffer, TempLineBuffer);

        ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer);
    end;
```

- [ ] **Step 2: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al" && git commit -m "Serialize TryCreateEcomDigitalNotification with UpdLock to prevent duplicate inserts"
```

---

## Task 4: Trigger notification from coupon success path

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponProcess.Codeunit.al`

Target procedure: `SetSalesDocCouponStatusCreated`. Find the final `if Modi then EcomSalesHeader.Modify(true);` statement.

- [ ] **Step 1: Add the trigger call after the final Modify**

Inside `SetSalesDocCouponStatusCreated`, at the very end of the procedure (immediately after `if Modi then EcomSalesHeader.Modify(true);`), insert:

```al
        DigitalOrderNotifMgt.TryCreateEcomDigitalNotification(EcomSalesHeader);
```

Then add a local variable declaration in the `var` block of the procedure:

```al
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
```

The variable must appear **before** any existing codeunit variables alphabetically per AL style (AA0013 / CodeCop). Place it in correct alphabetic order among the `var` entries.

- [ ] **Step 2: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponProcess.Codeunit.al" && git commit -m "Trigger digital notification from Ecom coupon success path"
```

---

## Task 5: Trigger notification from wallet success path

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al`

Target procedure: `HandleResponse`. Only the `Success = true` branch should trigger. The current procedure ends with `EcomSalesHeader := EcomSalesHeader2;` after the status + header Modify.

- [ ] **Step 1: Add conditional trigger call after header Modify in HandleResponse**

At the very end of `HandleResponse`, after the line `EcomSalesHeader := EcomSalesHeader2;`, insert:

```al
        if Success then
            DigitalOrderNotifMgt.TryCreateEcomDigitalNotification(EcomSalesHeader2);
```

Then add the local variable declaration to the procedure's `var` block in correct alphabetical order:

```al
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
```

- [ ] **Step 2: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al" && git commit -m "Trigger digital notification from Ecom wallet success path"
```

---

## Task 6: Defensive trigger from membership success path

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipProcess.Codeunit.al`

Rationale: `CalculateVirtualItemsDocStatus` requires memberships processed for the `Virtual Items Process Status = Processed` gate. If memberships finish last, no path currently triggers the notification (this task does NOT add any membership asset — it only unlatches the gate).

- [ ] **Step 1: Locate the success path that sets line status Processed**

Open the file and find the procedure that sets `EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;` followed by the header Modify that brings `EcomSalesHeader."Membership Processing Status"` to `Processed` or `Partially Processed`. The equivalent of voucher’s `SetSalesDocVoucherStatusCreated`. Typically named `SetSalesDocMembershipStatusCreated` or inside `HandleResponse`.

- [ ] **Step 2: Add the trigger call after the final header Modify on the success path**

Immediately after the final `EcomSalesHeader.Modify(true);` on the success path, insert:

```al
        DigitalOrderNotifMgt.TryCreateEcomDigitalNotification(EcomSalesHeader);
```

Add the local variable declaration in correct alphabetical order:

```al
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
```

If the procedure uses a different local variable name for the header (e.g. `EcomSalesHeader2`), pass that one instead.

- [ ] **Step 3: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 4: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipProcess.Codeunit.al" && git commit -m "Defensive: trigger digital notification from membership success path to unlatch gate"
```

---

## Task 7: Rewrite `PopulateBuffersFromEcomDoc` — two-pass + ancestor dictionary

**Files:**
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

Replace the current body (which filters `SetFilter(Subtype, '%1|%2', Voucher, Ticket)`) with a two-pass implementation that emits one buffer row per wallet parent line + one per non-bundled voucher/ticket/coupon line.

- [ ] **Step 1: Replace the procedure body**

Find `internal procedure PopulateBuffersFromEcomDoc(` and replace its entire body with:

```al
    internal procedure PopulateBuffersFromEcomDoc(
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        IsWalletByExtLineId: Dictionary of [Text[100], Boolean];
        CurrencyCode: Code[10];
        TotalAmountExclVAT: Decimal;
        TotalAmountInclVAT: Decimal;
    begin
        CurrencyCode := EcomSalesHeader."Currency Code";
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.SetLoadFields("LCY Code");
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        TempHeaderBuffer.Init();
        TempHeaderBuffer."External Order No." := EcomSalesHeader."External No.";
        TempHeaderBuffer."Document Type" := TempHeaderBuffer."Document Type"::"Ecom Sales Document";
        TempHeaderBuffer."Recipient E-mail" := EcomSalesHeader."Sell-to Email";
        TempHeaderBuffer."Recipient Name" := CopyStr(EcomSalesHeader."Sell-to Name", 1, MaxStrLen(TempHeaderBuffer."Recipient Name"));
        TempHeaderBuffer."Document Date" := EcomSalesHeader."Received Date";
        TempHeaderBuffer."Currency Code" := CurrencyCode;
        TempHeaderBuffer."Ecom Sales Header Id" := EcomSalesHeader.SystemId;
        TempHeaderBuffer."Bucket Id" := EcomSalesHeader."Bucket Id";
        TempHeaderBuffer.Insert();

        // Pass 1: index by External Line ID to identify wallet parents.
        // Nested wallets are unsupported by the ecom pipeline, so a single lookup is sufficient to detect "child of wallet".
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter("External Line ID", '<>%1', '');
        if EcomSalesLine.FindSet() then
            repeat
                if not IsWalletByExtLineId.ContainsKey(EcomSalesLine."External Line ID") then
                    IsWalletByExtLineId.Add(EcomSalesLine."External Line ID", EcomSalesLine."Is Attraction Wallet");
            until EcomSalesLine.Next() = 0;

        // Pass 2: emit buffer rows for wallet parents + standalone voucher/ticket/coupon lines.
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if EcomSalesLine.FindSet() then
            repeat
                if ShouldEmitEcomAssetLine(EcomSalesLine, IsWalletByExtLineId) then begin
                    TempLineBuffer.Init();
                    TempLineBuffer."External Order No." := EcomSalesHeader."External No.";
                    TempLineBuffer."Line No." := EcomSalesLine."Line No.";
                    if EcomSalesLine.Subtype = EcomSalesLine.Subtype::Voucher then
                        TempLineBuffer.Type := TempLineBuffer.Type::" "
                    else
                        TempLineBuffer.Type := TempLineBuffer.Type::Item;
                    TempLineBuffer."Ecom Line Subtype" := EcomSalesLine.Subtype;
                    TempLineBuffer."Ticket Reservation Line Id" := EcomSalesLine."Ticket Reservation Line Id";
                    TempLineBuffer."No." := CopyStr(EcomSalesLine."No.", 1, MaxStrLen(TempLineBuffer."No."));
                    TempLineBuffer."Variant Code" := EcomSalesLine."Variant Code";
                    TempLineBuffer.Description := CopyStr(EcomSalesLine.Description, 1, 100);
                    TempLineBuffer.Quantity := EcomSalesLine.Quantity;
                    TempLineBuffer."Unit Price" := EcomSalesLine."Unit Price";
                    CalcEcomLineAmounts(EcomSalesLine."Line Amount", EcomSalesLine."VAT %", EcomSalesHeader."Price Excl. VAT", TempLineBuffer.Amount, TempLineBuffer."Amount Including VAT");
                    TempLineBuffer."VAT %" := EcomSalesLine."VAT %";
                    TempLineBuffer."Source Line System Id" := EcomSalesLine.SystemId;
                    TempLineBuffer."Is Wallet" := EcomSalesLine."Is Attraction Wallet";
                    TempLineBuffer.Insert();

                    TotalAmountExclVAT += TempLineBuffer.Amount;
                    TotalAmountInclVAT += TempLineBuffer."Amount Including VAT";
                end;
            until EcomSalesLine.Next() = 0;

        TempHeaderBuffer."Total Amount Excl. VAT" := TotalAmountExclVAT;
        TempHeaderBuffer."Total Amount Incl. VAT" := TotalAmountInclVAT;
        TempHeaderBuffer.Modify();
    end;

    local procedure ShouldEmitEcomAssetLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var IsWalletByExtLineId: Dictionary of [Text[100], Boolean]): Boolean
    var
        ParentIsWallet: Boolean;
    begin
        // Wallet parent always emits as the wallet asset.
        if EcomSalesLine."Is Attraction Wallet" then
            exit(true);

        // Non-wallet line is a candidate only for voucher/ticket/coupon subtypes.
        if not (EcomSalesLine.Subtype in [EcomSalesLine.Subtype::Voucher, EcomSalesLine.Subtype::Ticket, EcomSalesLine.Subtype::Coupon]) then
            exit(false);

        // Bundle-child skip: if the parent (by External Line ID) is a wallet, this line is rendered inside the wallet, not as a standalone asset.
        if EcomSalesLine."Parent Ext. Line ID" <> '' then
            if IsWalletByExtLineId.Get(EcomSalesLine."Parent Ext. Line ID", ParentIsWallet) then
                if ParentIsWallet then
                    exit(false);

        exit(true);
    end;
```

- [ ] **Step 2: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings. (If a compile error complains about `Dictionary` element type casing, adjust `Dictionary of [Text[100], Boolean]` per the compiler’s requirement.)

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al" && git commit -m "Rewrite PopulateBuffersFromEcomDoc with two-pass ancestor dictionary"
```

---

## Task 8: Extend `IdentifyAssetType` ecom branch with Coupon + Wallet

**Files:**
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

Current ecom branch in `IdentifyAssetType`:
```al
        if TempHeaderBuffer."Document Type" = TempHeaderBuffer."Document Type"::"Ecom Sales Document" then begin
            if TempLineBuffer."Ecom Line Subtype" = TempLineBuffer."Ecom Line Subtype"::Voucher then
                exit(AssetType::Voucher);
            if TempLineBuffer."Ecom Line Subtype" = TempLineBuffer."Ecom Line Subtype"::Ticket then
                exit(AssetType::Ticket);
            exit(AssetType::None);
        end;
```

- [ ] **Step 1: Replace the ecom branch**

Replace the block above with:

```al
        if TempHeaderBuffer."Document Type" = TempHeaderBuffer."Document Type"::"Ecom Sales Document" then begin
            if TempLineBuffer."Is Wallet" then
                exit(AssetType::Wallet);
            case TempLineBuffer."Ecom Line Subtype" of
                TempLineBuffer."Ecom Line Subtype"::Voucher:
                    exit(AssetType::Voucher);
                TempLineBuffer."Ecom Line Subtype"::Ticket:
                    exit(AssetType::Ticket);
                TempLineBuffer."Ecom Line Subtype"::Coupon:
                    exit(AssetType::Coupon);
            end;
            exit(AssetType::None);
        end;
```

- [ ] **Step 2: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al" && git commit -m "IdentifyAssetType: map Ecom Coupon/Wallet lines to asset types"
```

---

## Task 9: Widen `ProcessLineAssets` allowlist

**Files:**
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

Current gate:
```al
        AssetType := IdentifyAssetType(TempHeaderBuffer, TempLineBuffer);

        if not (AssetType in [AssetType::Voucher, AssetType::Ticket]) then
            exit;
```

- [ ] **Step 1: Widen the allowlist to include Coupon and Wallet**

Replace the `if not (AssetType in [AssetType::Voucher, AssetType::Ticket]) then exit;` line with:

```al
        if not (AssetType in [AssetType::Voucher, AssetType::Ticket, AssetType::Coupon, AssetType::Wallet]) then
            exit;
```

Document-type scoping for Coupon and Wallet lives inside their processors (Tasks 10 and 11); the central gate is a pure type allowlist.

- [ ] **Step 2: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al" && git commit -m "ProcessLineAssets: allow Coupon and Wallet asset types"
```

---

## Task 10: Replace `ProcessCouponAssets` body with Ecom-only lookup

**Files:**
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

Current `ProcessCouponAssets` uses `NpDc Iss.OnSale Setup Line` + `NpDc Coupon Entry` lookup by posted document no. (Magento/CreditMemo). That whole body is removed; coupons are Ecom-exclusive.

- [ ] **Step 1: Replace the entire procedure body**

Find `local procedure ProcessCouponAssets(` and replace its entire body with:

```al
    local procedure ProcessCouponAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        // Coupon asset emission is Ecom-exclusive.
        // For Magento/Shopify, coupons are not part of the digital notification manifest by product decision.
        if IsNullGuid(TempHeaderBuffer."Ecom Sales Header Id") then
            exit;

        EcomSalesCouponLink.SetCurrentKey("Source", "Source System Id", "Source Line System Id");
        EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink."Source"::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", TempHeaderBuffer."Ecom Sales Header Id");
        EcomSalesCouponLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
        if not EcomSalesCouponLink.FindSet() then
            exit;

        repeat
            if Coupon.GetBySystemId(EcomSalesCouponLink."Coupon System Id") then begin
                CouponType.SetLoadFields(NPDesignerTemplateId);
                if CouponType.Get(Coupon."Coupon Type") and (CouponType.NPDesignerTemplateId <> '') then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        ManifestId,
                        Database::"NPR NpDc Coupon",
                        Coupon.SystemId,
                        Coupon."Reference No.",
                        CouponType.NPDesignerTemplateId);
                    AssetsAdded += 1;
                end;
            end;
        until EcomSalesCouponLink.Next() = 0;
    end;
```

- [ ] **Step 2: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings. (CodeCop may flag the removed variables — make sure no stale `var` entries remain.)

- [ ] **Step 3: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al" && git commit -m "ProcessCouponAssets: replace body with Ecom-only Ecom Sales Coupon Link lookup"
```

---

## Task 11: Replace `ProcessWalletAssets` body with Ecom-only lookup; simplify `TryAddWalletAssetToManifest`

**Files:**
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

Current `ProcessWalletAssets` filters `WalletAssetHeaderReference` by `LinkToReference = External Order No.` and matches on `OriginatesFromItemNo = TempLineBuffer."No."`. That Magento-style body is removed; the new Ecom lookup keys directly off the parent line SystemId.

- [ ] **Step 1: Replace `ProcessWalletAssets` body**

Find `local procedure ProcessWalletAssets(` and replace its entire body with:

```al
    local procedure ProcessWalletAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletAssetHeader: Record "NPR WalletAssetHeader";
        WalletAssetLine: Record "NPR WalletAssetLine";
        Wallet: Record "NPR AttractionWallet";
    begin
        // Wallet asset emission is Ecom-exclusive.
        // For Magento/Shopify, wallets are not part of the digital notification manifest by product decision.
        if IsNullGuid(TempHeaderBuffer."Ecom Sales Header Id") then
            exit;

        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetRange(LinkToTableId, Database::"NPR Ecom Sales Line");
        WalletAssetHeaderRef.SetRange(LinkToSystemId, TempLineBuffer."Source Line System Id");
        if not WalletAssetHeaderRef.FindSet() then
            exit;

        repeat
            if WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo) then begin
                WalletAssetLine.SetCurrentKey(TransactionId);
                WalletAssetLine.SetRange(TransactionId, WalletAssetHeader.TransactionId);
                WalletAssetLine.SetRange(Type, WalletAssetLine.Type::WALLET);
                if WalletAssetLine.FindSet() then
                    repeat
                        if Wallet.GetBySystemId(WalletAssetLine.LineTypeSystemId) then
                            TryAddWalletAssetToManifest(Wallet, ManifestId, AssetsAdded);
                    until WalletAssetLine.Next() = 0;
            end;
        until WalletAssetHeaderRef.Next() = 0;
    end;
```

- [ ] **Step 2: Simplify `TryAddWalletAssetToManifest` signature + body**

Find `local procedure TryAddWalletAssetToManifest(` and replace its entire body with:

```al
    local procedure TryAddWalletAssetToManifest(
        Wallet: Record "NPR AttractionWallet";
        ManifestId: Guid;
        var AssetsAdded: Integer): Boolean
    var
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        Item.SetLoadFields("NPR Item AddOn No.");
        if not Item.Get(Wallet.OriginatesFromItemNo) then
            exit(false);

        ItemAddOn.SetLoadFields(NPDesignerTemplateId);
        if not ItemAddOn.Get(Item."NPR Item AddOn No.") then
            exit(false);

        if ItemAddOn.NPDesignerTemplateId = '' then
            exit(false);

        NPDesignerManifestFacade.AddAssetToManifest(
            ManifestId,
            Database::"NPR AttractionWallet",
            Wallet.SystemId,
            Wallet.ReferenceNumber,
            ItemAddOn.NPDesignerTemplateId);
        AssetsAdded += 1;
        exit(true);
    end;
```

Note: the Ecom lookup is deterministic via parent line SystemId → the item-no match that previously guarded this helper is no longer needed, and the `WalletAssetLine` / `TempLineBuffer` arguments are removed.

- [ ] **Step 3: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 4: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al" && git commit -m "ProcessWalletAssets: replace body with Ecom-only WalletAssetHeaderReference lookup; simplify helper"
```

---

## Task 12: Enforce `Exclude Tickets From Manifest` + extend SetLoadFields

**Files:**
- Modify: `Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al`

- [ ] **Step 1: Add early exit at the top of `ProcessTicketAssets`**

Find `local procedure ProcessTicketAssets(` and insert this guard as the first statement of the procedure body (before the existing `// 1. Ecom direct link:` block):

```al
        if DigitalNotifSetup."Exclude Tickets From Manifest" then
            exit;
```

- [ ] **Step 2: Extend SetLoadFields in `ValidateDigitalNotifSetup`**

Find `ValidateDigitalNotifSetup` procedure. Locate the line:

```al
        DigitalNotifSetup.SetLoadFields(Enabled, "Email Template Id Order", "Exclude Vouchers From Manifest");
```

Replace it with:

```al
        DigitalNotifSetup.SetLoadFields(Enabled, "Email Template Id Order", "Exclude Vouchers From Manifest", "Exclude Tickets From Manifest");
```

- [ ] **Step 3: Compile**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 4: Commit**

```bash
cd /c/Projects/npcore && git add "Application/src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al" && git commit -m "ProcessTicketAssets: respect 'Exclude Tickets From Manifest' setup flag"
```

---

## Task 13: Full-app compile with analyzers (regression check)

**Files:** — (verification only)

- [ ] **Step 1: Clean build of the Application app**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"
```
Expected: 0 errors, 0 warnings. Confirms no unused `var` entries left behind from replaced bodies, no CodeCop violations, no UICop issues on the setup page addition.

- [ ] **Step 2: Clean build of the Test app**

Run:
```bash
ALC="$LOCALAPPDATA/bcdev/cache/27.0/alc.exe" && \
ANALYZER="$USERPROFILE/.vscode/extensions/ms-dynamics-smb.al-16.3.2065053/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll" && \
"$ALC" "/project:C:/Projects/npcore/Application" "/packagecachepath:C:/Projects/npcore/Application/.alpackages" "/out:C:/Projects/npcore/Application/output.app" "/analyzer:$ANALYZER" "/ruleset:C:/Projects/npcore/Application/main.ruleset.json" 2>&1 | grep -E "error |warning " | grep -iE "<paths of files you touched>"/Test
```
Expected: 0 errors, 0 warnings. (Confirms Test app still compiles; no API we changed is consumed by existing tests in a breaking way.)

- [ ] **Step 3: If any warnings/errors surface, fix in place**

Common issues to expect and how to resolve them:
- AA0137 “unused variable” — remove stale vars from the replaced `ProcessCouponAssets` / `ProcessWalletAssets` bodies.
- AA0001 / AA0013 spacing — reformat per CodeCop messages.
- Missing load field warning — extend the relevant `SetLoadFields` call.

After fixes, re-run Steps 1 and 2 until both pass cleanly, then:

```bash
cd /c/Projects/npcore && git add -A && git commit -m "Fix analyzer findings after coupon/wallet implementation"
```
(Only run if there were actual fixes — skip the commit if the two clean builds passed first-try.)

---

## Task 14: Manual sandbox verification (Postman)

**Files:** — (manual verification only)

Use the sandbox API requests embedded in the design spec under §“Test scenarios (sandbox API requests)”. The design spec path: `.plans/2026-04-17-andrei-core164-ecom-coupon-wallet-digital-notif-design.md`.

Setup prerequisites (one-time, per the design spec):
- Coupon Type `TEST_COUPON` with `NPDesignerTemplateId` set, `Trigger on Item = true`; `NpDc Iss.OnSale Setup Line` (Type=Item, No.=`60001`, Coupon Type=`TEST_COUPON`). Item `60001` is a plain Item.
- `NPR NpIa Item AddOn` = `WALLET_PKG` with `NPDesignerTemplateId` set; wallet template contains a ticket admission + a coupon. Coupon Type `TEST_WALLET_COUPON` with `Trigger on Attraction Wallet = true` + `Trigger on Item = true`. Item `70001` has `Create Attraction Wallet = true` + `Item Add-on No. = WALLET_PKG`. Attraction Wallet Setup enabled.
- Digital Notification Setup: `Enabled = true`, Email Template configured, manifest feature enabled in `NPR NPDesignerSetup`.
- Adyen payment-method mapping for `adyen_cc`.

- [ ] **Step 1: Publish to sandbox**

Use the `bcdev` skill: download symbols, compile, publish the Application + Test apps to the target sandbox.

- [ ] **Step 2: Scenario A — standalone coupon only**

Send the `A) Standalone coupon only` body from the design spec. Expected: 1 `NPR Digital Notification Entry` created with `Document Type = "Ecom Sales Document"`, `Ecom Sales Header Id` set, manifest contains exactly 1 coupon asset, email dispatched.

- [ ] **Step 3: Scenario B — wallet with ticket + coupon children**

Send the `B) Attraction wallet only` body (use the pre-request script to populate `TicketReservationToken` + `TicketReservationLineId`). Expected: manifest contains exactly 1 wallet asset. No separate ticket or coupon assets.

- [ ] **Step 4: Scenario C — wallet quantity 2**

Modify B to `quantity: 2` on the wallet parent (adjust children quantities to split round-robin). Expected: 2 wallet assets in the manifest.

- [ ] **Step 5: Scenario D — mixed (voucher + standalone ticket + standalone coupon + wallet with children)**

Send the `D) Mixed` body. Expected manifest: voucher + standalone ticket + standalone coupon + wallet (4 assets). Bundle children NOT separate.

- [ ] **Step 6: Scenario E — plain item regression**

Send `TEST-DIGI-NODIG-006`. Expected: no `NPR Digital Notification Entry` created.

- [ ] **Step 7: Scenario F — `Exclude Tickets From Manifest` toggle**

Enable `Exclude Tickets From Manifest` on the setup page. Re-run scenario D. Expected manifest: voucher + standalone coupon + wallet (3 assets). The standalone ticket is omitted. The wallet asset still contains its internal ticket. Disable the flag again.

- [ ] **Step 8: Scenario G — coupon quantity > 1**

Modify A to `quantity: 3`. Expected: 3 rows in `NPR Ecom Sales Coupon Link` for the line, and 3 coupon assets in the manifest.

- [ ] **Step 9: Concurrency check (best-effort)**

Send scenario D twice in quick succession from two Postman runners (different `externalNo`, same customer, same config) to exercise the job queues under load. Inspect `NPR Digital Notification Entry` — each Ecom doc produces exactly one notification entry. No duplicate-insert errors in the Sentry stream.

- [ ] **Step 10: Record results**

Add a short comment to the Linear ticket noting which scenarios passed and a screenshot of `NPR Digital Notif. Entries` for scenario D.

---

## Self-review against spec

Spec §1 (Trigger points) — Tasks 4, 5, 6 cover coupon/wallet/membership paths. Voucher + ticket already triggered on CORE-164 branch. ✓
Spec §2 (Idempotency) — Task 3 implements UpdLock + re-check. ✓
Spec §3 (Line filtering) — Task 7 implements the two-pass + ancestor dictionary. ✓
Spec §4 (ProcessCouponAssets replacement) — Task 10. ✓
Spec §5 (ProcessWalletAssets replacement + helper simplification) — Task 11. ✓
Spec §6 (Exclude Tickets setup flag) — Tasks 2 (schema/page) + 12 (enforcement). ✓
Spec §7 (IdentifyAssetType + ProcessLineAssets allowlist) — Tasks 8 and 9. ✓
Spec §“Files touched” — all seven files appear as targets across Tasks 1–12. ✓
Manual verification scenarios A–G + regression + concurrency — Task 14 Steps 2–9. ✓

No placeholders. All code blocks are complete AL source. Every task ends with a compile step and a commit.

---

## Execution Handoff

Plan complete and saved to `.plans/2026-04-17-andrei-core164-ecom-coupon-wallet-digital-notif-plan.md`. Two execution options:

1. **Subagent-Driven (recommended)** — A fresh subagent is dispatched per task, with review between tasks. Fast iteration, clean context per task.

2. **Inline Execution** — Tasks are executed in this session using the executing-plans skill. Batch execution with review checkpoints.

**Which approach?**
