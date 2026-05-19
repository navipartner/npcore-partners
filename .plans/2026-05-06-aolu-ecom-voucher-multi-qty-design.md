# Allow ecom voucher lines with quantity > 1

**Linear issue:** [CORE-209](https://linear.app/navipartner/issue/CORE-209)
**Supersedes:** [CORE-119](https://linear.app/navipartner/issue/CORE-119) / [PR #9684](https://github.com/navipartner/npcore/pull/9684) — the Vouchers subpage requirement is absorbed into this PR (§4.8). PR #9684 to be closed when CORE-209 merges.
**Author:** Andrei Lungu (aolu@navipartner.com), with Claude
**Date:** 2026-05-06
**Status:** Design — under review (rev 8 — Quantity immutability guard, Sentry capture at process boundary, dedicated `BySourceLine` index per codex seventh review, active-only manifest filter, dropped redundant `Source` enum field per codex eighth review)

## 1. Problem

The ecommerce sales document API (`incomingEcommerceSalesDocuments`) treats every voucher line as exactly one voucher. The payload validator rejects `quantity != 1` outright (`EcomSalesDocApiAgentV2.al:340`), and the per-line voucher creator (`EcomCreateVchrImpl.CreateVoucher`) reserves and posts a single voucher, then writes that voucher's `"No."` and `"Voucher Type"` back onto the ecom sales line as the sole link to the issued voucher. Downstream consumers — `Digital Order Notif. Mgt.ProcessVoucherAssets`, the `Show Related Vouchers` page actions, and `EcomSalesDocImplV2.InsertSalesLineVoucher` (the BC `Sales Header` bridge) — all assume `EcomSalesLine."No." → NpRvVoucher.Get(...)` is a 1:1 relationship.

The sales-order ingest route (Shopify, POS, manual SO) already supports voucher lines with `Quantity > 1` by issuing N vouchers and tracking them via `NPR NpRv Sales Line` + `NPR NpRv Sales Line Ref.` (see `NpRvSalesDocMgt.al:455-484`). That capability was never extended to the ecom-doc fast-line route.

## 2. Goals & non-goals

**Goals**
- Accept `quantity >= 1` (positive integer) on ecom voucher lines via the API.
- Issue N vouchers per line.
- All issued vouchers (active and archived) are discoverable from the ecom document UI:
  - **Document-level**: a "Vouchers" subpage embedded on the Ecom Document page showing every voucher (active+archived) for the document at a glance — fulfills CORE-119 (§4.8).
  - **Line-level**: the existing "Show Related Vouchers" popup action on `EcomSalesLines` and `EcomSalesDocSub`, scoped to the selected line (§4.5).
- The digital order notification manifest emits all *active* vouchers issued on a line; archived vouchers are excluded (see §4.4).
- Backward compatible with existing production ecom docs (qty=1 today), including ecom docs whose voucher has since been archived (with archive renumbering).

**Non-goals**
- **Voucher-in-wallet-bundle support.** Vouchers are explicitly forbidden as attraction-wallet bundle components today by `EcomSalesDocUtils.EnsureNoUnsupportedAssetsInWalletComponentLines` (`:981-982, 997-998`). Codex review confirmed this validation runs at API ingest (`EcomSalesDocApiAgentV2.al:180`) and would reject any voucher inside a wallet payload before our new logic could see it. We deliberately leave that guard in place. The existing `EcomCreateWalletMgt.GetVoucherSystemIds` voucher branch (`:158-164`) and the pooled-voucher distributor (`:122-138`) are unreachable through the public API today and are not modified by this PR. If voucher-in-wallet support is added later, the link table introduced here is forward-compatible with that work.
- Changing how `NpRv Sales Line` / `NpRv Sales Line Ref.` work or are populated by the SO/POS flows.
- Top-up semantics: when `barcodeNo` is supplied, `quantity` must remain 1 — multi-quantity is only meaningful for new voucher issuance (top-up "5 times the same voucher" is meaningless; the API consumer would issue one top-up of 5×amount).
- Fern documentation update (separate PR in `navipartner/documentation`).

## 3. Architecture

### 3.1 New link table: `NPR Ecom Sales Voucher Link`

Mirror the layout of `NPR Ecom Sales Coupon Link` and add the fields needed for the voucher archival lifecycle. **One link row per issued voucher, regardless of `quantity`** — qty=1 also gets a link row.

```al
table 60xxxxx "NPR Ecom Sales Voucher Link"  // ID via /al-id-manager at implementation time
{
    Access = Internal;
    Caption = 'Ecom Sales Voucher Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)               { AutoIncrement = true; }
        field(2; "Source System Id"; Guid)           { /* Ecom Sales Header.SystemId */ }
        field(3; "Source Line System Id"; Guid)      { /* Ecom Sales Line.SystemId */ }
        field(4; "Voucher System Id"; Guid)          { /* preserved across archive/unarchive */ }
        field(5; "Voucher No."; Code[20])            { /* live-voucher No. — see note below */ }
        field(6; "Reference No."; Text[50])          { /* stable across archive — display only */ }
        field(7; "Voucher State"; Enum "NPR Ecom Voucher Link State") { /* Active | Archived */ }
        field(8; "Voucher Type"; Code[20])           { /* same for all rows of one ecom line — captured here so downstream consumers can be fully link-first */ }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(BySource;     "Source System Id", "Source Line System Id") { }
        key(BySourceLine; "Source Line System Id") { }                // line-scoped lookups (e.g. EcomSalesLine.Quantity OnValidate guard in §4.2)
        key(BySystemId;   "Voucher System Id", "Voucher State") { }   // archive-state subscriber
    }
}
```

**Note on `Voucher No.` not being a join key.** The archive flow can renumber the archived row when the voucher type's `Archive No. Series` is configured (`NpRvVoucherMgt.al:1063`); the original live No. is then stored in `Arch. No.` (`NpRvArchVoucher.Table.al:53-57`, indexed at `:406`). So `Voucher No.` on the link reflects the **live-voucher No.**, which is correct for active rows but is *not* a join key against `NpRv Arch. Voucher` after archival. We therefore do not declare a `ByVoucherNo` index. The reliable resolver is always `Voucher System Id` (preserved across archive and unarchive — see "How SystemId preservation actually works" below). `Voucher No.` and `Reference No.` are kept as stable display values for UI/manifest use without a database read.

**How SystemId preservation actually works.** BC's default `Record.Insert` auto-generates a fresh `SystemId` on every insert. The archive flow opts out of that default. The signature is `Insert([RunTrigger: Boolean] [, InsertWithSystemId: Boolean])`; when the second parameter is `true`, BC respects whatever `SystemId` was assigned to the record before the call.

Archive (`NpRvVoucherMgt.al:1115-1117`):
```al
ArchVoucher.SystemId := Voucher.SystemId;        // copy live voucher's SystemId
OnBeforeInsertArchivedVoucher(Voucher, ArchVoucher);
ArchVoucher.Insert(true, true);                   // ← second 'true' = InsertWithSystemId
// ... then Voucher.Delete() at :1050 removes the live row.
```

Unarchive (`:1194-1195`) does the symmetric assignment back to the live row. Net effect: the same Guid follows the voucher between live and archive tables.

**Codebase audit (rev 6):** verified that `NpRvVoucherMgt.al:1117` is the **only** insert into `NPR NpRv Arch. Voucher` across the entire `Application` codebase (grep of `*ArchVoucher*.Insert` patterns + manual review of all 16 files that reference the table type). Tests, upgrade codeunits, Shopify integration, POS code — none insert archive rows directly; they all go through the `NpRvVoucherMgt.ArchiveVouchers` / `ArchiveVoucher` entry points.

**Maintenance contract** — load-bearing for our link-table design:
1. **Any new code path that inserts into `NPR NpRv Arch. Voucher` MUST follow the pattern**: assign `ArchVoucher.SystemId := <source live voucher's SystemId>;` before calling `Insert(_, true)`. Adding a new archive path that uses default `Insert()` would silently break this PR's link-table semantics for the affected vouchers.
2. **`OnBeforeInsertArchivedVoucher`** is a public IntegrationEvent — external extensions could subscribe and mutate `ArchVoucher.SystemId` before insert. We can't prevent this in our app, but if we observe in practice that a partner extension does this, we'll need a fallback resolver (e.g., a parallel `Original SystemId` field on the archive table, or a `Voucher No. → SystemId` lookup table). Not solving for it preemptively — the contract is clear and the integration event is a reasonable place to extend, not to mutate identity.
3. The PR's tests (§7 #9, #10) exercise archive + unarchive end-to-end and assert that `Show Related Vouchers` resolves correctly through both. Any future regression in the SystemId-preservation pattern would fail those tests.

**Why a new table and not `NPR Ecom Sales Coupon Link`** — coupons and vouchers have different lifecycles (vouchers archive when fully redeemed; coupons don't). Reusing the coupon table would require widening it for a voucher-only state field, which is worse than two parallel tables.

**Why a new table and not `NpRv Sales Line` / `NpRv Sales Line Ref.`** — those tables are reservation/issuance staging in the SO/POS flows. They are deleted by `NpRvVoucherMgt.OnBeforeDeletePOSSaleLine` (`:25-38`), `OnBeforeDeleteNpRvSalesLine` (`:40-53`), `ResetInUseQty` (`:15-23`), and `NpRvSalesDocMgt.OnBeforeReleaseSalesDoc` (`:488-491`), and they hold no information once the voucher is archived. The ecom doc needs **its own** durable link.

**Why `Voucher State` flip-update vs delete-and-reinsert** — `OnAfterArchiveVoucher` preserves the SystemId across tables (`NpRvVoucherMgt.al:1115`: `ArchVoucher.SystemId := Voucher.SystemId;`), so a flip-state UPDATE is sufficient and keeps `Entry No.` stable. Unarchive (`:1194`, `OnAfterUnArchiveVoucher`) also preserves SystemId, so a stable row that simply flips state correctly tracks round-trips. Delete + reinsert would create a new `Entry No.` on every archive event, complicating any external consumer that joins on it.

### 3.2 Voucher archive lifecycle

Two new event subscribers, placed inside `EcomCreateVchrImpl` (the codeunit that owns ecom voucher creation, and which already hosts a `Sales-Post.OnAfterPostSalesLine` subscriber, so the precedent exists):

```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterArchiveVoucher, '', false, false)]
local procedure OnAfterArchiveVoucher_FlipLinkState(Voucher: Record "NPR NpRv Voucher"; ArchVoucher: Record "NPR NpRv Arch. Voucher")
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
begin
    EcomSalesVoucherLink.SetCurrentKey("Voucher System Id", "Voucher State");
    EcomSalesVoucherLink.SetRange("Voucher System Id", ArchVoucher.SystemId);
    EcomSalesVoucherLink.SetRange("Voucher State", "Voucher State"::Active);
    EcomSalesVoucherLink.ModifyAll("Voucher State", "Voucher State"::Archived);
end;

[EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterUnArchiveVoucher, '', false, false)]
local procedure OnAfterUnArchiveVoucher_FlipLinkState(...) // symmetric — flip back to Active
```

Both events are existing, public IntegrationEvents (`NpRvVoucherMgt.al:2393`, `:2398`).

### 3.3 Sales-order ingest path stays untouched

`NPR Ecom Sales Voucher Link` is **only** populated by the ecom-doc fast-line route (`EcomCreateVchrImpl`). The Shopify/Magento → SO → posting path does not pass through this codeunit, so it does not need to write to the link table. Ecom-doc traceability and SO-doc traceability remain two parallel mechanisms.

## 4. Detailed changes

### 4.1 API payload validation — `EcomSalesDocApiAgentV2`

`EcomSalesDocApiAgentV2.al:339-341`:

```al
EcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
if EcomSalesLine.Quantity <> 1 then                                            // remove
    Error(PropertyErrorText, ...);                                             // remove
```

becomes:

```al
EcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
if EcomSalesLine.Quantity <> Round(EcomSalesLine.Quantity, 1) then
    Error(FractionalQtyErr, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
if EcomSalesLine.Quantity < 1 then
    Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
if (EcomSalesLine."Barcode No." <> '') and (EcomSalesLine.Quantity <> 1) then
    Error(TopUpQtyMustBeOneErr, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
```

### 4.2 Voucher issuance — `EcomCreateVchrImpl.CreateVoucher`

Restructured around three explicit branches. Routing is **link-row-count-first** as a guard against the concurrent re-entry race window described in §6 (the gap between the inner `Codeunit.Run` commit and the outer `HandleResponse` status flip).

```al
local procedure CreateVoucher(var EcomSalesLine, EcomSalesHeader)
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    QtyToIssue, AlreadyLinked, i: Integer;
    IssuedVoucher: Record "NPR NpRv Voucher";
    FirstVoucherNoOfLine: Code[20];
    FirstVoucherTypeOfLine: Code[20];
    FirstReferenceNoOfLine: Text[50];
begin
    QtyToIssue := Round(EcomSalesLine.Quantity, 1, '>');
    AlreadyLinked := CountExistingLinks(EcomSalesHeader, EcomSalesLine);

    case true of
        AlreadyLinked = QtyToIssue:
            exit;  // race recovery — another session already issued these vouchers
        AlreadyLinked > QtyToIssue:
            Error(LinkCountExceedsQtyErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
        (AlreadyLinked > 0) and (AlreadyLinked < QtyToIssue):
            Error(PartialLinkStateErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
    end;

    if EcomSalesLine."Barcode No." <> '' then begin
        IssueOrTopUpSingleVoucher(EcomSalesLine, EcomSalesHeader, EcomSalesLine."Barcode No.", IssuedVoucher);
        InsertVoucherLink(EcomSalesHeader, EcomSalesLine, IssuedVoucher);
        EcomSalesLine."No." := IssuedVoucher."No.";
        EcomSalesLine."Voucher Type" := IssuedVoucher."Voucher Type";
        EcomSalesLine.Modify(true);
        exit;
    end;

    for i := 1 to QtyToIssue do begin
        IssueOrTopUpSingleVoucher(EcomSalesLine, EcomSalesHeader, '', IssuedVoucher);
        InsertVoucherLink(EcomSalesHeader, EcomSalesLine, IssuedVoucher);
        if i = 1 then begin
            FirstVoucherNoOfLine := IssuedVoucher."No.";
            FirstVoucherTypeOfLine := IssuedVoucher."Voucher Type";
            FirstReferenceNoOfLine := IssuedVoucher."Reference No.";
        end;
    end;

    if QtyToIssue = 1 then begin
        EcomSalesLine."Barcode No." := FirstReferenceNoOfLine;
        EcomSalesLine."No." := FirstVoucherNoOfLine;
        EcomSalesLine."Voucher Type" := FirstVoucherTypeOfLine;
        EcomSalesLine.Modify(true);
    end;
end;
```

`IssueOrTopUpSingleVoucher` is the existing single-voucher logic (`ReserveVoucher` + `InsertVoucher` + `PostIssueVoucherEntry` + Shopify ID assignment) extracted into a private helper.

`InsertVoucherLink`:

```al
local procedure InsertVoucherLink(EcomSalesHeader, EcomSalesLine, NpRvVoucher)
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

**Sequencing invariant** (referenced by §6): `InsertVoucherLink` MUST be the last DB operation in `IssueOrTopUpSingleVoucher`. The link row is the durable marker; a future commit between voucher issuance and link insert would break the count-based retry. Add a code comment in `IssueOrTopUpSingleVoucher` body referencing this invariant.

**`CheckIfLineCanBeProcessed`** (`EcomCreateVchrImpl.al:22-48`): keep all existing checks, plus mirror the API-side quantity guards here as defense in depth (per project CLAUDE.md: ingest is one boundary, processing is another):

```al
if EcomSalesLine.Quantity <> Round(EcomSalesLine.Quantity, 1) then
    EcomSalesLine.FieldError(Quantity);
if EcomSalesLine.Quantity < 1 then
    EcomSalesLine.FieldError(Quantity);
if (EcomSalesLine."Barcode No." <> '') and (EcomSalesLine.Quantity <> 1) then
    EcomSalesLine.FieldError(Quantity);
```

The existing `Quantity = 0` clause is replaced by the `< 1` clause above.

#### Quantity immutability guard — defense in depth

Once a voucher line has issued vouchers (link rows exist), `Quantity` becomes immutable. This prevents a user / API upsert / debug session / third-party extension from mutating `Quantity` after issuance and producing a partial-link or overcount state that would later trip the §4.2 hard-error branches.

The standard ecom pages are already largely read-only via page-level `Editable = false`, so this is a defense-in-depth measure for non-page mutation paths (direct `Validate` calls, API upsert, test code). New `OnValidate` on `EcomSalesLine."Quantity"`:

```al
field(...; Quantity; Decimal)
{
    ...
    trigger OnValidate()
    var
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        QtyImmutableErr: Label 'Quantity cannot be changed: %1 voucher(s) have already been issued for this line.', Comment = '%1 - issued voucher count';
    begin
        if Rec.Quantity = xRec.Quantity then exit;
        EcomSalesVoucherLink.SetCurrentKey("Source Line System Id");
        EcomSalesVoucherLink.SetRange("Source Line System Id", Rec.SystemId);
        if not EcomSalesVoucherLink.IsEmpty() then
            Error(QtyImmutableErr, EcomSalesVoucherLink.Count());
    end;
}
```

The new `BySourceLine` key on the link table (§3.1) covers this filter — no full-table scan. `IsEmpty` is sufficient for the gate; `Count` is included only in the error message for diagnostic clarity.

### 4.3 Wallet bundles — out of scope (not modified)

Vouchers are not currently allowed inside attraction-wallet bundles. `EcomSalesDocUtils.EnsureNoUnsupportedAssetsInWalletComponentLines` (`:981-982, 997-998`) errors with `VoucherNotSupportedAsWalletComponentErr` whenever a voucher subtype appears inside a wallet bundle, called from `EcomSalesDocApiAgentV2.al:180`. The existing `EcomCreateWalletMgt.GetVoucherSystemIds` voucher branch and the pooled-voucher distributor (`EcomCreateWalletMgt.al:122-138, :158-164`) are unreachable through the public API today.

This PR does **not** modify any of that wallet code. The link table introduced here is forward-compatible if voucher-in-wallet support is added later: that future work would relax the `EcomSalesDocUtils` guard and update `GetVoucherSystemIds` to read from the link table.

### 4.4 Digital order notification — `Digital Order Notif. Mgt.ProcessVoucherAssets`

`Digital Order Notif. Mgt.al:422-453` (the ecom-document branch) becomes a link-table loop with an `Active`-only filter and a legacy fallback that also only resolves live vouchers:

```al
if TempHeaderBuffer."Document Type" = ...::"Ecom Sales Document" then begin
    EcomSalesVoucherLink.SetCurrentKey("Source System Id", "Source Line System Id");
    EcomSalesVoucherLink.SetRange("Source System Id", TempHeaderBuffer."Source Document Id");
    EcomSalesVoucherLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
    EcomSalesVoucherLink.SetRange("Voucher State", "Voucher State"::Active);
    if EcomSalesVoucherLink.FindSet() then begin
        repeat
            AddActiveVoucherToManifest(EcomSalesVoucherLink, ManifestId, AssetsAdded);
        until EcomSalesVoucherLink.Next() = 0;
        exit;
    end;
    if NpRvVoucher.Get(TempLineBuffer."No.") then
        AddSingleActiveVoucherToManifest(NpRvVoucher, ManifestId, AssetsAdded);
    exit;
end;
// ... unchanged Magento/Shopify branch
```

**Active-only by design.** The notification manifest's purpose is to send the customer the PDFs of newly issued vouchers so they can use them. A voucher in `Archived` state has already been fully redeemed — emailing "here's your gift card" for a redeemed voucher is meaningless to the customer, and the PDF designer template is registered against `Database::"NPR NpRv Voucher"` (live table only) so the manifest engine wouldn't render archived rows correctly anyway. The Magento/Shopify branch (`:455-488`) already exhibits this behavior implicitly — it only handles live vouchers via `NpRvVoucher.Get(...)`. The new Ecom branch makes the active-only filter explicit on the link query.

This also simplifies the legacy-fallback chain: we only need to try the live table; an archived legacy voucher (no link rows + already redeemed) is correctly skipped from the manifest.

`AddActiveVoucherToManifest` resolves the link to the live voucher via `NpRvVoucher.GetBySystemId(link."Voucher System Id")`, then adds a manifest entry against `Database::"NPR NpRv Voucher"` using voucher-type's `PDFDesignerTemplateId`. `Reference No.` for the manifest comes from the link row directly — no extra DB read needed for the display value.

**Show Related vs Notification — different scopes.** The active-only filter applies to the manifest because of the PDF/email use case described above. `Show Related Vouchers` (§4.5) keeps showing both active and archived rows because the user's question there is "what was issued from this document?" — which legitimately includes redeemed/archived vouchers for visibility.

### 4.5 `Show Related Vouchers` — line-level AssistEdit; document-level subsumed by §4.8

The two existing entry points are different shapes:

- **Document-level button-action** at `EcomSalesDocument.Page.al:397-410` — a `action("Retail Vouchers")` that calls `EcomCreateVchrProcess.ShowRelatedVouchersAction(EcomSalesHeader)`. **Obsoleted** in favor of the always-visible Vouchers subpage in §4.8. Marked `ObsoleteState = Pending`, `Visible = false`, removal target two releases out so any external code that calls `ShowRelatedVouchersAction(EcomSalesHeader)` keeps working through the deprecation window.
- **Line-level AssistEdit** on the `Virtual Item Process Status` field of `EcomSalesLines.Page.al:114` and `EcomSalesDocSub.Page.al` (the field is configured `AssistEdit = true` with a `trigger OnAssistEdit()` containing a `case Rec.Subtype` block — for voucher subtype it calls `ShowRelatedVouchersAction(EcomSalesLine)`). **Stays** — clicking the AssistEdit "..." indicator on a Processed voucher line opens that line's vouchers. Rewritten internals to use the link table; behavior preserved for qty=1, extended for qty>1.

#### Shared data builder on `EcomCreateVchrImpl`

```al
internal procedure BuildVoucherTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
var
    EmptyGuid: Guid;
begin
    BuildVoucherTempBuffer(EcomSalesHeader, EmptyGuid, TempVoucher);
end;

internal procedure BuildVoucherTempBufferForLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
begin
    BuildVoucherTempBuffer(EcomSalesHeader, EcomSalesLine.SystemId, TempVoucher);
end;

local procedure BuildVoucherTempBuffer(EcomSalesHeader: Record "NPR Ecom Sales Header"; SourceLineSystemIdFilter: Guid; var TempVoucher: Record "NPR NpRv Voucher" temporary)
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    NpRvVoucher: Record "NPR NpRv Voucher";
    NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
begin
    EcomSalesVoucherLink.SetCurrentKey("Source System Id", "Source Line System Id");
    EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
    if not IsNullGuid(SourceLineSystemIdFilter) then
        EcomSalesVoucherLink.SetRange("Source Line System Id", SourceLineSystemIdFilter);

    if EcomSalesVoucherLink.FindSet() then begin
        repeat
            case EcomSalesVoucherLink."Voucher State" of
                "Voucher State"::Active:
                    if NpRvVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id") then begin
                        TempVoucher := NpRvVoucher;
                        if TempVoucher.Insert() then;
                    end;
                "Voucher State"::Archived:
                    if NpRvArchVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id") then
                        InsertArchivedAsTempVoucher(NpRvArchVoucher, TempVoucher);
            end;
        until EcomSalesVoucherLink.Next() = 0;
        exit;
    end;

    EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
    EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Voucher);
    EcomSalesLine.SetRange("Virtual Item Process Status", "Virtual Item Process Status"::Processed);
    if not IsNullGuid(SourceLineSystemIdFilter) then
        EcomSalesLine.SetRange(SystemId, SourceLineSystemIdFilter);
    if EcomSalesLine.FindSet() then
        repeat
            if NpRvVoucher.Get(EcomSalesLine."No.") then begin
                TempVoucher := NpRvVoucher;
                if TempVoucher.Insert() then;
            end else begin
                NpRvArchVoucher.SetCurrentKey("Arch. No.");
                NpRvArchVoucher.SetRange("Arch. No.", EcomSalesLine."No.");
                if NpRvArchVoucher.FindFirst() then
                    InsertArchivedAsTempVoucher(NpRvArchVoucher, TempVoucher);
            end;
        until EcomSalesLine.Next() = 0;
end;

internal procedure OpenVoucherCardForSystemId(SystemIdParam: Guid)
var
    NpRvVoucher: Record "NPR NpRv Voucher";
    NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
    NotAvailableMsg: Label 'This voucher is no longer available in the system.';
begin
    if NpRvVoucher.GetBySystemId(SystemIdParam) then begin
        NpRvVoucher.SetRecFilter();
        Page.Run(Page::"NPR NpRv Voucher Card", NpRvVoucher);
        exit;
    end;
    if NpRvArchVoucher.GetBySystemId(SystemIdParam) then begin
        NpRvArchVoucher.SetRecFilter();
        Page.Run(Page::"NPR NpRv Arch. Voucher Card", NpRvArchVoucher);
        exit;
    end;
    Message(NotAvailableMsg);
end;
```

`InsertArchivedAsTempVoucher` is the same helper from rev 4 (`TransferFields(NpRvArchVoucher)` + `[Archived]` description prefix + preserve SystemId).

#### Line-level AssistEdit handler rewrite

`EcomCreateVchrImpl.ShowRelatedVouchersAction(EcomSalesLine: Record "NPR Ecom Sales Line")` (`:345-357`):

```al
internal procedure ShowRelatedVouchersAction(EcomSalesLine: Record "NPR Ecom Sales Line")
var
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    TempVoucher: Record "NPR NpRv Voucher" temporary;
    NoVoucherFoundMsg: Label 'No retail vouchers are linked to this line in the system.';
begin
    if not EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then
        exit;
    BuildVoucherTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempVoucher);
    case TempVoucher.Count() of
        0:
            Message(NoVoucherFoundMsg);
        1:
            begin
                TempVoucher.FindFirst();
                OpenVoucherCardForSystemId(TempVoucher.SystemId);
            end;
        else
            Page.RunModal(Page::"NPR Ecom Voucher Lookup", TempVoucher);
    end;
end;
```

Behavior preserved for qty=1 (opens the right card directly; archived vouchers now resolve correctly via the link's SystemId, fixing today's silent failure on archived legacy data). Multi-qty lines open the dedicated archive-aware lookup page. The line-page wiring (`AssistEdit = true` + `trigger OnAssistEdit()` + `case Rec.Subtype` block) is unchanged — only this procedure's body changes.

#### Header-level overload — kept functional during deprecation

`ShowRelatedVouchersAction(EcomSalesHeader)` (`:323-343`) is marked obsolete (see §4.8) but its body is updated to the link-table shape during the deprecation window so any external caller in the meantime gets correct behavior:

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

#### `InsertArchivedAsTempVoucher` helper

Used by `BuildVoucherTempBuffer` to project an archived voucher row into the live-shape temp record:

```al
local procedure InsertArchivedAsTempVoucher(NpRvArchVoucher: Record "NPR NpRv Arch. Voucher"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
var
    OriginalNo: Code[20];
begin
    TempVoucher.Init();
    TempVoucher.TransferFields(NpRvArchVoucher);
    OriginalNo := NpRvArchVoucher."Arch. No.";
    if OriginalNo = '' then
        OriginalNo := NpRvArchVoucher."No.";
    TempVoucher."No." := OriginalNo;
    TempVoucher.Description := CopyStr(StrSubstNo('[Archived] %1', NpRvArchVoucher.Description),
                                       1, MaxStrLen(TempVoucher.Description));
    TempVoucher.SystemId := NpRvArchVoucher.SystemId;
    if TempVoucher.Insert() then;
end;
```

The SystemId assignment carries the original live-voucher SystemId through the temp projection (preserved across archive — see §3.1 "How SystemId preservation actually works"). `NpRvVoucher.TransferFields(NpRvArchVoucher)` is the same operation `NpRvVoucherMgt.UnArchiveVoucher` (`:1190`) uses internally, so field shape compatibility is established and travels with that contract.

#### New page `NPR Ecom Voucher Lookup` (used by line-level AssistEdit when N>1)

Small, archive-aware list page. Used as a popup from the line-level AssistEdit handler when there are 2+ vouchers attached to a line, and during the deprecation window from the obsolete document-level overload.

```al
page 60xxxxx "NPR Ecom Voucher Lookup"  // ID via /al-id-manager at implementation time
{
    Caption = LookupCaptionLbl;
    Access = Internal;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = NPRRetail; ToolTip = NoTooltipLbl; }
                field("Reference No."; Rec."Reference No.") { ApplicationArea = NPRRetail; ToolTip = ReferenceNoTooltipLbl; }
                field("Voucher Type"; Rec."Voucher Type") { ApplicationArea = NPRRetail; ToolTip = VoucherTypeTooltipLbl; }
                field(Description; Rec.Description) { ApplicationArea = NPRRetail; ToolTip = DescriptionTooltipLbl; }
                field("Starting Date"; Rec."Starting Date") { ApplicationArea = NPRRetail; ToolTip = StartingDateTooltipLbl; }
                field("Ending Date"; Rec."Ending Date") { ApplicationArea = NPRRetail; ToolTip = EndingDateTooltipLbl; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenVoucher)
            {
                Caption = OpenLbl;
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = OpenTooltipLbl;
                trigger OnAction()
                var
                    EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
                begin
                    EcomCreateVchrImpl.OpenVoucherCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    var
        LookupCaptionLbl: Label 'Vouchers';
        OpenLbl: Label 'Open';
        OpenTooltipLbl: Label 'Open the selected voucher (live or archived).';
        NoTooltipLbl: Label 'Specifies the voucher number.';
        ReferenceNoTooltipLbl: Label 'Specifies the voucher reference number presented to the customer.';
        VoucherTypeTooltipLbl: Label 'Specifies the voucher type.';
        DescriptionTooltipLbl: Label 'Specifies the voucher description. Archived vouchers are prefixed with [Archived].';
        StartingDateTooltipLbl: Label 'Specifies when the voucher became valid.';
        EndingDateTooltipLbl: Label 'Specifies when the voucher expires.';
}
```

Both the subpage (§4.8) and this lookup page route their `OpenVoucher` action through the same `EcomCreateVchrImpl.OpenVoucherCardForSystemId` resolver — single source of truth for "open the right card given a voucher SystemId."

### 4.6 Sales-line creation — `EcomSalesDocImplV2.InsertSalesLineVoucher`

`EcomSalesDocImplV2.al:643-693` is the bridge that converts an ecom voucher line into a `Sales Header` `Sales Line` (G/L Account type) and patches the corresponding `NpRvSalesLine` rows with the SalesHeader linkage. Two assumptions break for qty>1:

- **Line 656-657** — bails if `EcomSalesLine."No." = ''`. With the rev-2 writeback rule (qty>1 leaves `"No."` blank), this would silently skip multi-qty voucher lines.
- **Lines 663-666** — `FindFirst()` patches one of N `NpRvSalesLine` rows with `Document Type/No./Line No.`; the other N-1 rows stay orphaned, breaking downstream voucher-entry posting and credit-doc reversal flows.

Rewritten to drive off the link table (with legacy fallback) and to update **all** matching `NpRvSalesLine` rows:

```al
local procedure InsertSalesLineVoucher(EcomSalesHeader, SalesHeader, EcomSalesLine, var SalesLine)
var
    EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    NpRvSalesLine: Record "NPR NpRv Sales Line";
    NpRvVoucherType: Record "NPR NpRv Voucher Type";
    LinkExists: Boolean;
begin
    if EcomSalesLine.Type <> EcomSalesLine.Type::Voucher then exit;

    EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
    EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    LinkExists := not EcomSalesVoucherLink.IsEmpty();

    if (not LinkExists) and (EcomSalesLine."No." = '') then exit;

    if LinkExists then begin
        EcomSalesVoucherLink.FindFirst();
        NpRvVoucherType.Get(EcomSalesVoucherLink."Voucher Type");
    end else
        NpRvVoucherType.Get(EcomSalesLine."Voucher Type");

    SalesLine.Init();
    SalesLine."Document Type" := SalesHeader."Document Type";
    SalesLine."Document No." := SalesHeader."No.";
    SalesLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
    SalesLine.Insert(true);

    SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
    SalesLine.Validate("No.", NpRvVoucherType."Account No.");
    SalesLine.Description :=
        CopyStr(StrSubstNo('%1 %2', ResolveLineDescriptor(EcomSalesLine, EcomSalesVoucherLink), NpRvVoucherType.Description),
                1, MaxStrLen(SalesLine.Description));
    SalesLine.Validate(Quantity, EcomSalesLine.Quantity);
    SalesLine.Validate("VAT %", EcomSalesLine."VAT %");
    SalesLine.Validate("Unit Price", EcomSalesLine."Unit Price");
    if SalesLine."Unit Price" <> 0 then
        SalesLine.Validate("Line Amount", EcomSalesLine."Line Amount");
    SalesLine."NPR Inc Ecom Sales Line Id" := EcomSalesLine.SystemId;

    NpRvSalesLine.SetCurrentKey("Document No.", "NPR Inc Ecom Sales Line Id");
    NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
    NpRvSalesLine.SetRange("NPR Inc Ecom Sales Line Id", EcomSalesLine.SystemId);
    NpRvSalesLine.ModifyAll("Document Type", SalesLine."Document Type");
    NpRvSalesLine.ModifyAll("Document No.", SalesLine."Document No.");
    NpRvSalesLine.ModifyAll("Document Line No.", SalesLine."Line No.");

    EcomSalesDocImplEvents.OnInsertSalesLineVoucherBeforeFinalizeLine(EcomSalesHeader, SalesHeader, EcomSalesLine, SalesLine);
    SalesLine.Modify(true);
end;
```

`ResolveLineDescriptor` returns the descriptor used for the BC sales-line description format `'<descriptor> <voucherTypeDescription>'`:

- For qty=1 (single link row OR legacy `EcomSalesLine."Barcode No."` populated): the voucher's `Reference No.` — preserves today's behavior, e.g. `ABCD1234 Gift Voucher`.
- For qty>1: `'<firstReferenceNo> +<N-1>'` — e.g. `ABCD1234 +4 Gift Voucher`. Truthful, gives support a concrete handle, doesn't claim "this sales line is voucher X" alone.

### 4.7 Voucher-entry posting patch — `EcomCreateVchrImpl.UpdateVoucherEntryPostingInformationSalesInvoice`

`EcomCreateVchrImpl.al:292-321` (subscriber on `Sales-Post.OnAfterPostSalesLine`) updates one `NpRvVoucherEntry` per posted invoice line using `NpRvSalesLine.FindFirst()`. With qty>1 there are N `NpRvSalesLine` rows and N `NpRvVoucherEntry` rows for one invoice line. All of them need their `Document No.` / `Document Line No.` patched to the posted invoice line's identifiers.

Rewrite:

```al
NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
NpRvSalesLine.SetRange("NPR Inc Ecom Sales Line Id", SalesLine."NPR Inc Ecom Sales Line Id");
NpRvSalesLine.SetRange("External Document No.", SalesHeader."NPR External Order No.");
NpRvSalesLine.SetRange(Posted, true);
if not NpRvSalesLine.FindSet() then exit;
repeat
    NpRvVoucherEntry.SetCurrentKey("Entry No.", "Voucher No.", "Voucher Type", "External Document No.");
    NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2', "Issue Voucher", "Top-up");
    NpRvVoucherEntry.SetRange("Voucher No.", NpRvSalesLine."Voucher No.");   // per-row
    NpRvVoucherEntry.SetRange("Voucher Type", NpRvSalesLine."Voucher Type");
    NpRvVoucherEntry.SetRange("External Document No.", SalesHeader."NPR External Order No.");
    NpRvVoucherEntry.SetLoadFields("Document No.", "Document Line No.");
    if NpRvVoucherEntry.FindFirst() then begin
        NpRvVoucherEntry."Document No." := SalesInvLine."Document No.";
        NpRvVoucherEntry."Document Line No." := SalesInvLine."Line No.";
        NpRvVoucherEntry.Modify();
    end;
until NpRvSalesLine.Next() = 0;
```

This iterates all `NpRvSalesLine` rows for the ecom line and patches the one matching `NpRvVoucherEntry` per row — N voucher entries patched, each pointing back at the same posted SalesInvLine.

### 4.8 Vouchers subpage on Ecom Document — supersedes PR #9684 / CORE-119

CORE-119 asks for a "Vouchers" subpage on the Ecom Document page that shows every voucher (active and archived) created for that document, at a glance, with the ability to open the relevant card. PR #9684 implemented this with a buffer temp table (`EcomVoucherLookupBuffer`) and `NpRvVoucherEntry` walks filtered by External Document No. The reviewers (Andrei + codex) raised four blocking findings: no covering key on the entry filter (SQL scans), N+1 lookups inside the build loop, buffer rebuilt on every parent-record refresh (perf regression on list views), and two competing "Vouchers" entry points showing different datasets.

Once the link table introduced by §3.1 exists, the subpage's data layer collapses to a small `ListPart` reading `NPR Ecom Sales Voucher Link` directly, and all four blockers are addressed structurally instead of via spot fixes:

| #9684 finding | How rev 5 addresses it |
|---|---|
| No covering key on `("Entry Type", "External Document No.")` filter | Reads link table by the existing `BySource` key declared in §3.1; no `NpRvVoucherEntry` walks at all |
| N+1 (`Voucher.Get` per entry, `IsEmpty` per entry against keyless temp) | One `FindSet` over the link table + one `GetBySystemId` per row resolved against active or archived voucher |
| Buffer rebuilt on every `OnAfterGetRecord` of the parent | Rebuild stays driven by parent's `OnAfterGetCurrRecord` (the correct refresh signal — fires on record change AND on `RefreshOnActivate` so a JQ archiving a voucher in the background gets reflected when the user tabs back), but each rebuild is now cheap: 1 link-table `FindSet` + N `GetBySystemId`. PR #9684's perf finding was about *expensive* rebuilds firing often (entry walk + N+1 + 6 CalcFields per row); cheap rebuilds firing on the same trigger are not a problem. |
| Two competing Vouchers entry points (active-only action + active+archived subpage) | Document-level button-action obsoleted (§4.5); the subpage becomes the sole document-level entry point. Line-level status-field AssistEdit handler stays — different UX (inline AssistEdit "..." on the status indicator, not a separate button) and routes through the same link table (§4.5). |

Plus the style findings:

| #9684 finding | How rev 5 addresses it |
|---|---|
| Missing `Access = Internal;` on the part page | Declared on the new `NPR Ecom Voucher Sub` page |
| `#pragma warning disable AL0254` masking missing key | Not needed — sort by `"No."` is satisfied by the source temp's primary key, sort by `"Reference No."` is satisfied by the existing key on `NPR NpRv Voucher` |
| Hardcoded captions/tooltips | All user-visible strings declared as `Label`s |
| No tests | New tests #17, #18 in §7 |
| Caption typo on `"Arch. Initial Amount"` | Doesn't apply — we don't introduce a buffer table at all |

#### New page object

```al
page 60xxxxx "NPR Ecom Voucher Sub"  // ID via /al-id-manager at implementation time
{
    Caption = SubpageCaptionLbl;
    Access = Internal;
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR NpRv Voucher";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = NPRRetail; ToolTip = NoTooltipLbl; }
                field("Reference No."; Rec."Reference No.") { ApplicationArea = NPRRetail; ToolTip = ReferenceNoTooltipLbl; }
                field("Voucher Type"; Rec."Voucher Type") { ApplicationArea = NPRRetail; ToolTip = VoucherTypeTooltipLbl; }
                field(Description; Rec.Description) { ApplicationArea = NPRRetail; ToolTip = DescriptionTooltipLbl; }
                field("Starting Date"; Rec."Starting Date") { ApplicationArea = NPRRetail; ToolTip = StartingDateTooltipLbl; }
                field("Ending Date"; Rec."Ending Date") { ApplicationArea = NPRRetail; ToolTip = EndingDateTooltipLbl; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenVoucher)
            {
                Caption = OpenLbl;
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = OpenTooltipLbl;
                trigger OnAction()
                var
                    EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
                begin
                    EcomCreateVchrImpl.OpenVoucherCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    internal procedure RefreshContents(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        Rec.Reset();
        Rec.DeleteAll();
        EcomCreateVchrImpl.BuildVoucherTempBufferForDoc(EcomSalesHeader, Rec);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    var
        SubpageCaptionLbl: Label 'Vouchers';
        OpenLbl: Label 'Open';
        OpenTooltipLbl: Label 'Open the selected voucher (live or archived).';
        NoTooltipLbl: Label 'Specifies the voucher number.';
        ReferenceNoTooltipLbl: Label 'Specifies the voucher reference number presented to the customer.';
        VoucherTypeTooltipLbl: Label 'Specifies the voucher type.';
        DescriptionTooltipLbl: Label 'Specifies the voucher description. Archived vouchers are prefixed with [Archived].';
        StartingDateTooltipLbl: Label 'Specifies when the voucher became valid.';
        EndingDateTooltipLbl: Label 'Specifies when the voucher expires.';
}
```

**Why an explicit `OpenVoucher` action instead of `OnDrillDown` trigger** — BC's `OnDrillDown` is a page-field-level trigger and per Microsoft docs is not invoked for fields inside a `repeater`. An explicit row action is the BC-idiomatic way to expose "open the selected row" on a `ListPart`. Same pattern in the new `NPR Ecom Voucher Lookup` page (§4.5).

**Note on Amount fields.** Amount FlowFields on `NPR NpRv Voucher` read 0 for archived rows (the live record is gone). The archive snapshot lives on `NpRv Arch. Voucher`; the subpage accepts "amount shown for active vouchers only" — for redemption history the user opens the Archived Voucher Card via the `Open` action.

**Why no cache** — earlier rev introduced a `_LastShownEcomHeaderId` Guid on the page to skip rebuilds on no-op refreshes. Codex (rev 5 review) flagged it as too sticky: vouchers archived in the background while the page sits on the same parent record would not show their state change until the user navigated away. The cache was solving a problem we don't actually have — PR #9684's "rebuilt on every record load" finding was about *expensive* rebuilds (entry walks + N+1 + 6 CalcFields per row); rev 6's rebuild is 1 link-table `FindSet` + N `GetBySystemId`, which is fine to fire on every parent `OnAfterGetCurrRecord`. Trade-off: simpler code, fresher data, no global page state.

#### Embedding on the Ecom Document page

`EcomSalesDocument.Page.al` adds a `part(...)` declaration directly (no separate page extension — the page is in our own module):

```al
// In the layout, alongside other parts/factboxes:
part(VouchersSubPage; "NPR Ecom Voucher Sub")
{
    Caption = VouchersPartCaptionLbl;
    ApplicationArea = NPRRetail;
    UpdatePropagation = Both;
}

// Page-level trigger:
trigger OnAfterGetCurrRecord()
begin
    CurrPage.VouchersSubPage.Page.RefreshContents(Rec);
end;

// Add Label declaration alongside existing page Labels:
var
    VouchersPartCaptionLbl: Label 'Vouchers';
```

`OnAfterGetCurrRecord` fires on the parent in four concrete scenarios for `EcomSalesDocument` (a `Document` page with `RefreshOnActivate = true`):

1. **Page open** — first load of an ecom doc.
2. **Record navigation** — Next/Previous arrows, jumping to another ecom doc.
3. **Page reactivation** — user tabs back from another window/tab; `RefreshOnActivate = true` re-fires the trigger so any background changes (JQ archiving a voucher, etc.) become visible.
4. **Explicit `CurrPage.Update(false/true)`** — invoked from existing actions on the page (e.g. capture, manual reprocess).

For each, the rebuild cost is `1 link-table FindSet + N GetBySystemId` — typically 2-6 queries, worst case ~51 for a 50-voucher doc. Fine to fire on every parent refresh; the data is always fresh and there's no global page state to reason about.

#### Obsoleting the document-level popup action

`action("Retail Vouchers")` at `EcomSalesDocument.Page.al:397-410` is replaced by the subpage. Marked obsolete:

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
    Visible = false;  // hide from UI immediately so users have a single entry point

    trigger OnAction()
    var
        EcomCreateVchrProcess: Codeunit "NPR EcomCreateVchrProcess";
    begin
        EcomCreateVchrProcess.ShowRelatedVouchersAction(Rec);
    end;
}
```

The internal procedure `EcomCreateVchrImpl.ShowRelatedVouchersAction(EcomSalesHeader)` itself is also marked obsolete in the same window, but its body is updated to the link-table shape during deprecation (§4.5) so any external caller in the meantime gets correct active+archived behavior.

#### What is not changed

- The line-level `Virtual Item Process Status` field AssistEdit on `EcomSalesLines.Page.al:114` and `EcomSalesDocSub.Page.al` (configured `AssistEdit = true` + `trigger OnAssistEdit()` with a `case Rec.Subtype` block) **stays**. Different UX (inline AssistEdit "..." on the status indicator, not a separate button) answering a different question ("what came from THIS line"). Its body — `EcomCreateVchrImpl.ShowRelatedVouchersAction(EcomSalesLine)` — is rewritten in §4.5 to use the link table with N=0/1/N>1 branching.
- The shared data-builder procedures (`BuildVoucherTempBufferForDoc`, `BuildVoucherTempBufferForLine`, `OpenVoucherCardForSystemId`) live on `EcomCreateVchrImpl` — same codeunit that already owns voucher-related logic.

## 5. Data flow

```
ecom doc API → fastLine voucher line, qty=N
                 │
                 ▼
EcomCreateVchrImpl.CreateVoucher
   ├── Branch 1: link-count guard (race recovery — see §6)
   │     ├── = QtyToIssue → no-op exit (another session already finished this line)
   │     ├── > QtyToIssue → error (corruption)
   │     └── 0 < count < QtyToIssue → error (invariant break)
   ├── for i in 1..N (when AlreadyLinked = 0):
   │     ├── reserve + insert NpRvVoucher i
   │     ├── post NpRvVoucherEntry i
   │     └── insert NPR Ecom Sales Voucher Link row i (always — even qty=1)
   └── if qty=1: writeback (Barcode No., No., Voucher Type) — preserves API response shape.
       if qty>1: leave EcomSalesLine untouched. Link table is the source of truth.
                 │
                 ▼
   downstream (link-first, with legacy fallback chain to live → archived):
   ├── DigitalOrderNotifMgt.ProcessVoucherAssets    (manifest)
   ├── ShowRelatedVouchersAction                    (UI — unified active+archived)
   ├── EcomSalesDocImplV2.InsertSalesLineVoucher    (BC SalesLine + ALL NpRvSalesLine patches)
   └── EcomCreateVchrImpl.UpdateVoucherEntryPostingInformationSalesInvoice (per-row)
                 │
                 ▼
   [later] voucher fully redeemed → NpRvVoucherMgt.ArchiveVoucher
                 │
                 ▼
   OnAfterArchiveVoucher subscriber flips link.Voucher State → Archived
   (SystemId preserved; ShowRelated still resolves via NpRvArchVoucher.GetBySystemId)
```

## 6. Error handling, retries, idempotency

- **Why the link-count guard is necessary** (the actual rationale, identified in codex review #6 — earlier revs had this story partly wrong).

   `EcomCreateVchrProcess.OnRun` (`:10-22`) does:
   ```al
   Commit();
   _Success := EcomCreateVchrTryProcess.Run(Rec);    // ← per BC semantics, commits inner work on success
   HandleResponse(_Success, Rec, _UpdateRetryCount); // ← only here does the line flip to Processed
   Commit();                                          // ← outer commit of the Processed status
   ```

   Per Microsoft's [`Codeunit.Run` semantics](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/codeunit/codeunit-run-method), `Run` returns *after* it has committed any DB work performed inside the called codeunit. So between `_Success := ...Run(Rec)` returning and `HandleResponse` flipping the line to `Processed`, there is a small window where:

   - The voucher rows are committed.
   - The `NPR Ecom Sales Voucher Link` rows are committed.
   - The line's `"Virtual Item Process Status"` is still blank/initial.

   And other entry points specifically target blank-status lines:

   - The dispatcher (`EcomVirtualItemMgt.al:63-69`) — filters `"Virtual Item Process Status"::" "`.
   - The voucher JQ (`EcomCreateVoucherJQ.al:62-66`).
   - The API preprocess path (`EcomSalesDocApiAgentV2.al:946-948`).
   - The manual page action (`EcomSalesDocSub.Page.al:320-324`).

   If any of those fire on the same line during the window (parallel JQ, user clicking the manual retry button, another API call), they re-enter `CreateVoucher` on a line that already has full voucher + link rows. Without the link-count guard, this would issue duplicate vouchers. **`AlreadyLinked = QtyToIssue` → exit cleanly** is the load-bearing branch — it's race recovery, not retry resume. The winning session will mark the line `Processed` shortly; the losing session simply discovers the work is already done and exits.

- **What the count guard does NOT need to do.** Earlier rev reasoning argued for a "resume from partial state" path (`0 < AlreadyLinked < QtyToIssue` → issue the remainder). With the current code path that doesn't happen: failed inner runs roll back via `Codeunit.Run` semantics, so a retry sees `AlreadyLinked = 0`. Partial state is therefore an invariant break (corruption / manual edit / future inner-`Commit()` violating the sequencing invariant below) and the spec treats it as a hard error rather than masking it with a resume path. If a future change ever legitimately produces partial state, that change is also responsible for adjusting this branch.

- **Sequencing invariant.** Inside the per-voucher loop, `InsertVoucherLink` MUST be the last database operation after `IssueOrTopUpSingleVoucher`. The link row is the durable marker that "this voucher belongs to this ecom line." A future commit between voucher issuance and link insert would create a state where vouchers exist without their link, violating count-based race recovery. The current implementation has no inner commits, so the rollback semantics of the outer `Codeunit.Run` keep us safe; the invariant exists to preserve that property across future maintenance. Add a code comment in `IssueOrTopUpSingleVoucher` referencing this invariant.

- **`CheckIfLineCanBeProcessed` blocks reprocessing of `Processed` lines.** `EcomCreateVchrImpl.al:44-45` errors with `FieldError` if the line is already `Processed` when `Process` is entered. This handles the post-`HandleResponse` retry case — the count guard handles only the pre-`HandleResponse` race window described above.

- **No qty=1 writeback repair.** Earlier revs introduced `RepairQty1WritebackFromLink` to fix stale `EcomSalesLine` writeback fields after partial-commit retries. With the current design (no inner commits + race recovery via simple no-op exit), there's no scenario where the writeback gets skipped while the line continues processing. Removed in rev 7. The `EcomSalesLine` writeback fields are presentational only — downstream consumers (§4.4-4.7) read fully from the link table when link rows exist, so even if the writeback were somehow stale, downstream behavior would still be correct.
- **NoSeries gaps on rollback.** If a multi-qty run fails partway, `NoSeries.GetNextNo` calls executed before the failure may have consumed numbers from the configured Voucher No. series. BC's no-series-batch implementation typically commits its number-bookkeeping outside the surrounding transaction; gaps are an accepted operational reality (same behavior as today's qty=1 path). Not a correctness issue.
- **Concurrency.** Existing pattern: line is locked via `EcomSalesLine.ReadIsolation := UpdLock` at the top of `Process` (`EcomCreateVchrImpl.al:13`). Link-row inserts happen under the same lock. The archive-event subscribers run in the archiving session; the link rows they touch are not locked by the ecom flow at that point, so no contention.
- **Sentry / programming-bug errors.** The two link-count guard errors (`LinkCountExceedsQtyErr`, `PartialLinkStateErr`) genuinely indicate a programming bug or data tampering — exactly the case CLAUDE.md's "This is a programming bug" Sentry-targeted error convention is for. Their labels are non-translated English and end with the trigger phrase:
   ```al
   LinkCountExceedsQtyErr: Label
       'Internal data inconsistency on voucher line %1: %2 voucher(s) issued but quantity is %3. Contact support to investigate. This is a programming bug.',
       Locked = true;
   PartialLinkStateErr: Label
       'Internal data inconsistency on voucher line %1: %2 of %3 voucher(s) issued. Contact support to investigate. This is a programming bug.',
       Locked = true;
   ```
   Per the existing `SentryErrorHandling.Codeunit.al:46` detector, any error containing "This is a programming bug" gets logged to Sentry. **Sentry capture point** — `Sentry.AddLastErrorIfProgrammingBug()` operates on the *already-raised* last error, so it must be called at the process boundary AFTER `Run` returns false but BEFORE `HandleResponse` consumes the error text. Add this in `EcomCreateVchrProcess.OnRun` (`:10-22`):
   ```al
   _Success := EcomCreateVchrTryProcess.Run(Rec);
   if not _Success then
       Sentry.AddLastErrorIfProgrammingBug();   // capture before HandleResponse consumes the text
   HandleResponse(_Success, Rec, _UpdateRetryCount);
   ```
   All other user-visible errors in this PR are translatable `Label`s and do not trigger Sentry.

## 7. Testing strategy

Tests live in the separate `Test` app. New test codeunit covering:

1. **Happy path qty = 1** — single voucher line → 1 voucher issued, 1 link row, line carries voucher's reference. Regression check.
2. **Happy path qty = 5** — 5 vouchers issued, 5 link rows, line `Barcode No.` / `No.` / `Voucher Type` left blank.
3. **Top-up qty = 1** — existing voucher topped up, 1 link row pointing at the existing voucher.
4. **Top-up forbidden when qty > 1** — payload validation rejects.
5. **Quantity must be whole, positive number** — `0`, `-1`, `2.5` rejected at API ingest AND at `CheckIfLineCanBeProcessed`.
6. **`AlreadyLinked > QtyToIssue` raises error** — synthesize a corrupt state with extra link rows; processing fails with `LinkCountExceedsQtyErr`.
7. **Concurrent re-entry no-op (race recovery)** — pre-populate the link table with `QtyToIssue` rows for a still-blank-status line (simulating the post-inner-commit / pre-`HandleResponse` race window); call `Process` again; verify it exits cleanly without issuing duplicate vouchers. This is the load-bearing test for the link-count guard described in §6.
8. **Notification manifest — active vouchers** — line with qty = 3 (all active) produces 3 manifest entries.
8a. **Notification manifest — archived excluded** — line with qty = 3 where 1 voucher has been archived; manifest contains 2 entries (the 2 active vouchers). Verifies the active-only filter on the link query in §4.4.
9. **Archive lifecycle** — issue voucher, redeem fully, observe link state flips to `Archived`, `Show Related Vouchers` shows it with `[Archived]` prefix.
10. **Unarchive lifecycle** — admin-only; state flips back, prefix gone.
11. **Partial-link-state error** — synthesize a corrupt state with `0 < AlreadyLinked < QtyToIssue` (e.g., manually insert one link row for a `Quantity = 5` line); call `Process`; verify it errors with `PartialLinkStateErr` rather than silently issuing the remainder. This treats partial state as the invariant break it is.
12. **Legacy fallback live** — ecom doc with `EcomSalesLine."No."` populated and no link rows; `Show Related`, notification manifest, sales-doc bridge all resolve via live voucher.
13. **Legacy fallback archived (with renumbering)** — same as #12 but the voucher has been archived AND renumbered into the archive No. series; verify the legacy fallback chain resolves via `NpRvArchVoucher."Arch. No."`.
14. **Sales-doc bridge `InsertSalesLineVoucher`** — qty=5 ecom line produces one BC SalesLine quantity=5 and updates all 5 `NpRvSalesLine` rows with the SalesHeader linkage.
15. **Voucher-entry posting patch** — qty=5 ecom line, post the resulting invoice, verify all 5 `NpRvVoucherEntry` rows get `Document No.` / `Document Line No.` updated to the posted invoice line.
16. **Voucher-in-wallet still rejected** — payload with a voucher line as a wallet bundle component must still fail with `VoucherNotSupportedAsWalletComponentErr`. Guards against accidentally relaxing the existing validation while we change neighboring code.
17. **Vouchers subpage renders mixed active+archived** — ecom doc with 5 issued vouchers (e.g., 3 active + 2 archived after redemption); subpage shows all 5. Selecting an active row + clicking `Open` opens `NpRv Voucher Card`; selecting an archived row + clicking `Open` opens `NpRv Arch. Voucher Card`. Archived rows show the `[Archived]` description prefix.
18. **Subpage refreshes on parent record change** — open ecom doc A (5 vouchers), navigate Next to ecom doc B (3 vouchers), assert subpage now shows B's 3 vouchers (no stale A data). Replaces the rev-5 cache test, which was for a cache mechanism that's been removed.
19. **Line-level AssistEdit — N=0 (defensive corruption guard)** — *not a normal runtime state*; constructed test scenario where a voucher line is `Processed` but has no link rows and `EcomSalesLine."No." = ''` (would only occur via a future regression or manual data corruption). Clicking the status field's AssistEdit "..." shows the "No retail vouchers are linked to this line" message rather than crashing.
20. **Line-level AssistEdit — N=1** — voucher line with one issued voucher (active OR archived); clicking the AssistEdit "..." opens the right card directly (live → `NpRv Voucher Card`, archived → `NpRv Arch. Voucher Card`). For archived, this fixes today's silent failure on archived legacy data where `NpRvVoucher.Get(EcomSalesLine."No.")` returns false and the user sees the misleading "No vouchers" message.
21. **Line-level AssistEdit — N>1** — voucher line with 5 issued vouchers; clicking the AssistEdit "..." opens the new `NPR Ecom Voucher Lookup` page modally with all 5 rows. Selecting a row + `Open` resolves to the correct card.
22. **Quantity immutability after issuance** — voucher line with link rows exists; attempting to `Validate` a new `Quantity` value via direct AL code errors with `QtyImmutableErr`. Setting Quantity on a line with no link rows is allowed (covers initial API ingest path).

## 8. Backward compatibility — legacy ecom docs without link rows

Production already has ecom voucher lines without link rows (everything qty=1 today, traceability via `EcomSalesLine."No."`). Some of those vouchers will have been archived since — and archive can renumber the live No. into the archive No. series, with the original No. surviving as `NpRvArchVoucher."Arch. No."` (`NpRvArchVoucher.Table.al:53-57`, indexed at `:406`).

Three approaches considered:

- **No backfill, fallback chain at every read site.** Each consumer (Show Related, notification, sales-doc bridge) tries the link table first; if empty, falls back to a legacy chain: try `NpRvVoucher.Get(EcomSalesLine."No.")` (live), then `NpRvArchVoucher.SetRange("Arch. No.", EcomSalesLine."No.").FindFirst()` (archived, renumbering-aware). Chosen approach — see §§4.4-4.6.
- **Lazy backfill on first read.** Subtle race conditions and unclear ownership. Rejected.
- **Eager backfill via upgrade codeunit.** Cleanest end-state but requires a one-time scan of every processed ecom voucher line. Rejected for now as overkill — the fallback chain is roughly six lines per consumer; legacy docs roll off naturally.

If we later want a single source of truth, an upgrade codeunit can be added; the fallback paths can then be removed in a follow-up PR.

## 9. Out of scope

- **Voucher-in-wallet support.** See §2 / §4.3. Existing `EcomSalesDocUtils` guard preserved; existing `EcomCreateWalletMgt` voucher branch left as-is.
- **No upgrade codeunit / migration of historical link rows.** See §8.
- **Voucher type validation rules** — `Allow Top-up`, FCY restriction, return-order rejection, etc. unchanged.

## 10. Decisions made (rev 4)

1. **Show Related Vouchers UX** — single unified action; active and archived rendered together via `TempNpRvVoucher` populated from `NpRvVoucher` directly or via `TransferFields(NpRvArchVoucher)`. Archived rows prefixed `[Archived]`. (§4.5.)
2. **Archive subscriber location** — `EcomCreateVchrImpl`. (§3.2.)
3. **Top-up link-row insertion** — yes, the link table is populated for top-up too. The same voucher may then be linked from multiple ecom docs over its lifetime (original issuance + each top-up). (§4.2 Branch 2.)
4. **qty=1 vs qty>1 writeback to `EcomSalesLine`** — qty=1 keeps writeback (back-compat); qty>1 leaves blank (link table is sole source of truth). (§4.2 closing block.)
5. **Wallet voucher distribution** — out of scope. Not modified. (§4.3.)
6. **`Voucher No.` as join key** — no. SystemId is the only reliable cross-archive resolver. `Voucher No.` is display-only on the link. (§3.1.)
7. **Backward compatibility** — fallback chain at every read site, including archive renumbering via `Arch. No.` lookup. No upgrade codeunit. (§8.)
8. **Sequencing invariant** — `InsertVoucherLink` is the last DB op in `IssueOrTopUpSingleVoucher`. Documented as a code comment. (§6.)
9. **`AlreadyLinked` branching simplified (rev 7).** The link-count guard exists for one specific reason: race recovery against the window between the inner `Codeunit.Run` commit (which persists vouchers + link rows on success) and the outer `HandleResponse` flip to `Processed`. Three outcomes:
   - `= QtyToIssue` → no-op exit (race winner already did the work).
   - `> QtyToIssue` → error (data corruption).
   - `0 < AlreadyLinked < QtyToIssue` → error (partial state is an invariant break, not a resume scenario, given current code paths).
   The earlier "Branch 1b writeback repair" + "Branch 3 resume logic" mechanisms are removed because they protected against scenarios that don't occur with the current code path (failed inner runs roll back; processed lines are gated by `CheckIfLineCanBeProcessed`). (§§4.2, 6.)
9a. **Quantity immutability guard (rev 8).** New `OnValidate` on `EcomSalesLine."Quantity"` blocks mutations after link rows exist. Defense in depth — standard ecom pages are largely read-only already, so this protects non-page mutation paths (direct Validate calls, API upsert, test/debug code, third-party extensions). Closes the only realistic user-triggered path to the §4.2 hard-error branches. Filter uses the new `BySourceLine` index added to §3.1. (§4.2 "Quantity immutability guard".)
9b. **Sentry capture for the §4.2 guard errors (rev 8).** Both errors use "This is a programming bug" suffix per CLAUDE.md convention; `Sentry.AddLastErrorIfProgrammingBug()` is called at the process boundary in `EcomCreateVchrProcess.OnRun` after `Run` fails and before `HandleResponse` consumes the error. (§6 "Sentry / programming-bug errors".)
10. **Quantity validation** — at API ingest AND at `CheckIfLineCanBeProcessed`. Defense in depth. (§4.1, §4.2.)
11. **`ResolveLineDescriptor` format** — `'<firstReferenceNo> +<N-1>'` for qty>1. (§4.6.)
12. **Downstream consumers are fully link-first when `LinkExists`.** Voucher Type is added as field 8 on the link row so consumers (notably `InsertSalesLineVoucher`) never depend on `EcomSalesLine` fields when link rows exist. The `EcomSalesLine` writeback for qty=1 is purely a presentational concern (API GET response shape) and is not load-bearing for any downstream behavior. (§§3.1, 4.6.)
13. **Vouchers subpage absorbs CORE-119.** The "Vouchers" subpage from PR #9684 is implemented inside the CORE-209 PR using the new link table — eliminating the buffer table, entry walks, and the four blocking review findings on #9684 by construction. Document-level `Show Related Vouchers` button-action is obsoleted in favor of the subpage; line-level status-field AssistEdit handler stays (different UX — inline AssistEdit "..." on the Processed status indicator, not a separate button) and is rewritten to use the link table. PR #9684 to be closed when CORE-209 merges. (§§4.5, 4.8.)
14. **Subpage refresh model — no cache.** The subpage rebuilds on every parent `OnAfterGetCurrRecord`. Each rebuild is cheap (1 `FindSet` over the link table + N `GetBySystemId`), so the original PR #9684 perf concern (which was about expensive entry-walk rebuilds) doesn't apply. Trade-off: simpler code, no global page state, fresher data — vouchers archived/issued in the background while the user is on the page get reflected immediately when the parent's `RefreshOnActivate` fires. (§4.8.)
15. **Subpage row-open — explicit `OpenVoucher` action, not `OnDrillDown`.** BC's `OnDrillDown` trigger is page-field-only and does not fire on repeater rows (Microsoft docs). Same applies to the new `NPR Ecom Voucher Lookup` page. Both pages route their `OpenVoucher` action through `EcomCreateVchrImpl.OpenVoucherCardForSystemId(SystemId)` — single resolver, try-live-then-archive. (§§4.5, 4.8.)
16. **Line-level AssistEdit handler branches by voucher count.** N=0 → "No vouchers" message (defensive — not a normal state). N=1 → open the right card directly (preserves today's UX, fixes today's silent failure on archived legacy data). N>1 → open the new `NPR Ecom Voucher Lookup` page modally. The shared builder is split into `BuildVoucherTempBufferForDoc` (used by subpage) and `BuildVoucherTempBufferForLine` (used by line AssistEdit handler), both delegating to a private `BuildVoucherTempBuffer` with optional line filter. (§4.5.)
17. **Notification manifest excludes archived vouchers.** The link query in §4.4 filters `"Voucher State" = Active`. The manifest's purpose is "newly issued voucher → email PDF to customer"; an archived voucher has already been redeemed, so emailing the customer for it is meaningless. Mechanically, the PDF designer template is also registered against `Database::"NPR NpRv Voucher"` (live table only) — the existing Magento/Shopify branch already exhibits this behavior via `NpRvVoucher.Get(...)`. The Show Related Vouchers UI (§4.5) keeps showing both active and archived rows because its scope is "what was issued from this document?" — different question, different filter. (§4.4.)
18. **No `Source` enum field on the voucher link.** The shipped coupon link table carries a `Source` enum field that has only one practical value (`"Ecom Sales Document"`) — a YAGNI artifact. Codex eighth review confirmed there is no shared abstraction across the two link tables (coupon and voucher flows are handled by separate procedures throughout the codebase), so the "consistency for consistency's sake" argument is purely visual. Dropping the field for the new voucher link saves the row width, removes the redundant `SetRange("Source", ...)` filter from every read site, and avoids an awkward dependency on the coupon-named enum (`"NPR Ecom Sales Coupon Source"`) for a voucher-only table. The coupon link stays as-is — schema change there would be a breaking migration not in scope. (§3.1.)

## 11. Files touched (preview)

- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/handlers/EcomSalesDocApiAgentV2.Codeunit.al` — payload validation (§4.1)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrImpl.Codeunit.al` — issuance loop, link writes, archive subscribers, processing-time qty validation, Show-Related rewrite, voucher-entry posting patch (§§4.2, 3.2, 4.5, 4.7)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomCreateVchrProcess.Codeunit.al` — add `Sentry.AddLastErrorIfProgrammingBug()` between `Run` and `HandleResponse` for §4.2 guard errors (§6)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesLine.Table.al` — `Quantity` field gets `OnValidate` immutability guard (§4.2 "Quantity immutability guard")
- `src/Digital Notification/DigitalOrderNotifMgt.Codeunit.al` — `ProcessVoucherAssets` ecom branch with State-aware resolver and fallback chain (§4.4)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/EcomSalesDocImplV2.Codeunit.al` — `InsertSalesLineVoucher` rewrite (§4.6)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomSalesVoucherLink.Table.al` — **new** (§3.1)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLinkState.Enum.al` — **new** (Active, Archived)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherSub.Page.al` — **new** ListPart for the Vouchers subpage (§4.8). Placed alongside the implementation codeunits (not under `_public/`); declared `Access = Internal`.
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Voucher/EcomVoucherLookup.Page.al` — **new** archive-aware List page used by the line-level AssistEdit handler when N>1 (§4.5). Same `Access = Internal`.
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al` — add `part(VouchersSubPage; ...)` + `OnAfterGetCurrRecord` calling `RefreshContents`; obsolete document-level `Retail Vouchers` action (§§4.5, 4.8)
- (Test app) new tests covering items 1-22 in §7
- (External) `navipartner/documentation` Fern spec — `quantity` description for voucher lines (separate PR)
- (External) PR #9684 closed with a comment pointing at the merged CORE-209 PR (§4.8)

**Files explicitly NOT touched** (per scope narrowing):
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al`
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/EcomSalesDocUtils.Codeunit.al` (`EnsureNoUnsupportedAssetsInWalletComponentLines` stays)
