# Allow ecom membership lines with quantity > 1

**Linear issue:** [CORE-208](https://linear.app/navipartner/issue/CORE-208)
**Related precedent:** [CORE-209](https://linear.app/navipartner/issue/CORE-209) — same pattern applied to vouchers; this doc reuses the link-table approach and refers back to that design where the rationale is identical.
**Author:** Andrei Lungu (aolu@navipartner.com), with Claude
**Date:** 2026-05-14
**Status:** Design — initial

## 1. Problem

The ecommerce sales document API (`incomingEcommerceSalesDocuments`) treats every membership line as exactly one membership. The processing-time guard rejects `Quantity <> 1` outright (`EcomCreateMMShipImpl.CheckIfLineCanBeProcessed`, `:137`), and the operation-specific validators repeat the same gate (`ValidateMembershipRequestForDirectCreation`, `:267`; `ValidateMembershipForToken`, `:426`). The per-line creator `EcomCreateMMShipImpl.CreateMembership` (`:191-217`) creates a single membership, writes that membership's `SystemId` back onto `EcomSalesLine."Membership Id"`, then `ConfirmMembership` (`:148-189`) reads that single SystemId back to flip the corresponding `MM Membership Entry` to confirmed.

Downstream consumers also assume 1:1 between the ecom line and a membership:

- `EcomSalesDocApiAgentV2.AddProperty('membershipId', ...)` (`:826`) — single Guid in the GET response.
- `EcomCreateMMShipImpl.ShowRelatedMembershipsAction(EcomSalesLine)` (`:645-655`) — opens one Membership Card from `EcomSalesLine."Membership Id"`.

(`DigitalOrderNotifMgt.ProcessMemberCardAssets` was originally listed here too, but is out of scope for CORE-208 — memberships are not emitted through the digital-notification manifest for ecom-doc sources. See §4.8 and decision #21.)

There are legitimate webshop scenarios — per Milena's comment on the issue — where the seller exposes a "buy N memberships" SKU without collecting member info up-front, then later attaches members from the POS or back-office. Today the API rejects `quantity = 10` and forces the caller to submit ten identical lines.

This change allows `Quantity >= 1` for the **Create Membership** operation only. The other four membership operations (`Confirm`, `Renew`, `Extend`, `Upgrade`) all reference an existing `Membership Id` on the line and therefore must remain `Quantity = 1` — that constraint comes from the operation's identity, not from a server-side restriction we can relax. The operation discriminator (`EcomSalesLine."Membership Operation"`) is set at API ingest (`EcomSalesDocApiAgentV2.al:303` calls `EcomCreateMMShipImpl.DetermineMembershipOperation`).

## 2. Goals & non-goals

**Goals**
- Accept `Quantity >= 1` (positive whole number) on `Subtype = Membership` lines **only when `Membership Operation = CreateMembership`**. Other operations stay strict `Quantity = 1`.
- Issue N memberships per such line.
- All memberships **touched by the ecom doc** (created, confirmed, renewed, extended, or upgraded) are discoverable via:
  - **Document-level UI**: a "Memberships" subpage embedded on `EcomSalesDocument.Page.al`, fed by the existing shared Page Background Task codeunit `NPR Ecom Doc Subpages Task`. Mirrors the Vouchers subpage built in CORE-209 (commit `b9b8826ace`). The page already has `OnPageBackgroundTaskCompleted` routing with commented-out hooks anticipating exactly this addition — see `EcomSalesDocument.Page.al:551, :589`. **Shows memberships from all 5 operations**, matching today's `action(Memberships)` semantics — no labeling ambiguity.
  - **Line-level UI**: existing `ShowRelatedMembershipsAction(EcomSalesLine)` continues to work — opens the single membership card for N=1 (back-compat), opens a list page for N>1, "No memberships" message for N=0.
  - **GET response**: out of scope for this PR (see §4.6). A `createdMemberships` array — analog of voucher's `createdVouchers` — is the right shape long-term, but the voucher counterpart was disabled in PR 9975 pending API-team alignment on the public response contract. Memberships will follow whatever resolution lands there, in a separate PR.

- **Link table populated for every membership-type processed line, regardless of operation.** Mirrors the voucher precedent (`EcomCreateVchrImpl.IssueOrTopUpSingleVoucher` at `:174` unconditionally calls `InsertVoucherLink` whether the voucher is brand-new or a top-up of an existing one). For memberships the same applies: Create issues N memberships and inserts N link rows; Confirm/Renew/Extend/Upgrade target a single existing membership and insert one link row each. The link table is the single source of truth for "what memberships did this ecom doc touch."

- **`EcomSalesLine."Membership Id"` field policy** (decided with Milena):
  - Populated for Create qty=1 (post-process writeback — back-compat with existing API consumers).
  - Populated for Confirm/Renew/Extend/Upgrade (ingest input, always qty=1 by §4.2).
  - Empty only for Create qty>1.
  - Accepted as duplicate of the link row for qty=1 cases; the field doubles as the legacy-fallback resolver for pre-CORE-208 docs.
- Backward compatible with all existing production ecom membership lines (qty=1 today; traceability via `EcomSalesLine."Membership Id"` writeback).

**Non-goals**
- No change to **Confirm / Renew / Extend / Upgrade** semantics. Those keep `Quantity = 1` because each references a specific existing `Membership Id` on the line.
- No change to the membership-creation logic itself (`MembershipMgtInternal.CreateMembershipAll`) — we call it N times in a loop, same as today.
- No member-info-capture changes. Member fields (`Member First Name`, `Member Last Name`, etc.) on the ecom line apply uniformly to all N memberships in a multi-qty create. Per Milena: webshops doing multi-qty memberships typically send empty member info; the POS / back-office attaches member details later. That workflow already exists and is out of scope here.
- No archive lifecycle subscriber. Memberships do not get archived the way vouchers do — `MM Membership` and `MM Membership Entry` are mutated in place (Blocked, expired, etc.) rather than moved across tables. So no `Voucher State` analog is needed.
- Fern documentation update (separate PR in `navipartner/documentation`).
- POS / back-office attach-member-to-membership UI. Already exists and is independent of how the membership was created.

## 3. Architecture

### 3.1 New link table: `NPR Ecom Sales Membership Link`

Mirror the layout of `NPR Ecom Sales Voucher Link` (CORE-209 §3.1), with two simplifications:

- **No `Voucher State` analog** — memberships don't archive across tables, so the link row's target Membership SystemId stays resolvable via `Membership.GetBySystemId(...)` indefinitely. A blocked or expired membership is still the same Membership row.
- **No "Voucher Type" denormalization** field — memberships have nothing analogous to `Voucher Type` that downstream consumers need without an extra read.

```al
table 6248182 "NPR Ecom Sales Membership Link"
{
    Access = Internal;
    Caption = 'Ecom Sales Membership Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)              { AutoIncrement = true; }
        field(2; "Source System Id"; Guid)          { /* Ecom Sales Header.SystemId */ }
        field(3; "Source Line System Id"; Guid)     { /* Ecom Sales Line.SystemId */ }
        field(4; "Membership System Id"; Guid)      { /* NPR MM Membership.SystemId — single join key,
                                                         all other Membership fields resolved at read time */ }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(BySource;     "Source System Id", "Source Line System Id") { }
        key(BySourceLine; "Source Line System Id", "Entry No.") { }
    }
}
```

**Why `Entry No.` is included in the `BySourceLine` key.** The link rows are iterated for the per-membership amount split in §4.5.1, where the "last row absorbs the rounding remainder" rule is load-bearing for accounting correctness. AL's `FindSet()` does not contractually return rows in insertion order when the key columns tie — without `Entry No.` as a tiebreaker the rounding remainder lands on a non-deterministic membership (codex review rev 2). Including `Entry No.` makes the iteration order match insertion order, which makes the "last absorbs remainder" rule resolve to "the most-recently-inserted link row" — deterministic and replayable for tests.

**Why a new table and not `NPR Ecom Sales Voucher Link` / `NPR Ecom Sales Coupon Link`** — coupons, vouchers, and memberships have different target tables and different lifecycle concerns. Combining them would require either widening one table with a discriminator column (and target-table-specific columns becoming nullable) or polymorphic joins. Two parallel tables already exist; a third in the same shape is the consistent choice.

**Why `Membership System Id` is the join key.** `MM Membership.SystemId` is stable for the lifetime of the row. Memberships do not migrate across tables (unlike vouchers, which can move to `NpRv Arch. Voucher` with their SystemId preserved). A simple `Membership.GetBySystemId(link."Membership System Id")` resolves cleanly forever.

**Single-field design — no denormalization (revised after Andrei's review).** Earlier drafts copied the voucher precedent and denormalized `Membership Entry No.` (the Membership PK) and `External Membership No.` onto the link row to let downstream JSON emitters avoid an extra `Membership.Get` per row.

That denormalization isn't earning its keep for memberships:
- **The voucher denorm rationale doesn't apply.** Vouchers archive AND renumber — the link row's `Voucher No.` captures the live-at-issuance value that would otherwise be ambiguous after archival. Memberships have no archive lifecycle and `External Membership No.` is immutable on `MM Membership`.
- **The subpage path doesn't benefit anyway.** `BuildMembershipTempBuffer` already calls `Membership.GetBySystemId` per row to populate the full temp record — the denorm fields are never read on that path.
- **No risk of orphaned link rows mis-rendering data.** With denorm, an admin-deleted membership leaves stale data on the link row. Without denorm, `GetBySystemId` returns false and the consumer silently skips the row — matching today's resolver patterns.

So the link table is just `(Entry No., Source System Id, Source Line System Id, Membership System Id)`. Single source of truth = `MM Membership`. `Membership System Id` is the only join key the link table needs.

**On `MM Membership Entry` row precision.** Memberships are not part of the digital-notification manifest (confirmed with Milena, 2026-05-15). The link row's consumers — subpage, ShowRelated, GET response, line AssistEdit — only need to identify the **membership** itself, not the specific ledger entry that the operation created or touched. `Membership System Id` is sufficient. If a future feature needs to render data from the specific ledger entry, a follow-up PR can either add a `Membership Ledger Entry No.` field or resolve the entry at read time via `(Membership PK + most-recent-or-Document-No.)`.

### 3.2 No archive subscriber

`MM Membership` rows aren't moved or renumbered the way `NpRv Voucher` rows are. There is no archive event to subscribe to. The link table's `Membership System Id` stays valid for the row's lifetime; if the membership ever gets deleted (admin action) the link row becomes orphaned and downstream resolvers (`Membership.GetBySystemId`) return false — same observable behavior as a missing voucher today.

### 3.3 SO/POS membership paths stay untouched

`NPR Ecom Sales Membership Link` is **only** populated by the ecom-doc fast-line membership processing path (`EcomCreateMMShipImpl.Process` and its operation branches — Create, Confirm, Renew, Extend, Upgrade — per decision #20). Shopify-via-SalesOrder, POS, and direct Membership API paths do not pass through this codeunit and do not need to write to the link table. Ecom-doc traceability remains parallel to those other mechanisms.

## 4. Detailed changes

### 4.1 API payload validation — `EcomSalesDocApiAgentV2`

`EcomSalesDocApiAgentV2.al:300-308` (the `Subtype::Membership` ingest branch) already calls `ValidateMembershipOperation`, which dispatches to one of:

- `ValidateMembershipRequestForDirectCreation` (Create)
- `ValidateMembershipForToken` (Confirm)
- `ValidateMembershipAlterationRequest` (Renew / Extend / Upgrade)

The fractional-quantity check at `:312-314` already applies to memberships. **Keep it.** All membership operations require a whole-number quantity. The per-operation `Quantity = 1` checks live inside the validators themselves (next section).

No additional API-ingest validation needed. The operation-specific validators are the right place because the rule is operation-conditional.

### 4.2 Operation-conditional quantity validation

Three validators in `EcomCreateMMShipImpl`:

- **`ValidateMembershipRequestForDirectCreation`** (`:259-281`) — Create-Membership path. **Relax** from `Quantity <> 1` to `Quantity < 1`:

  ```al
  if EcomSalesLine.Quantity < 1 then
      Error(QuantityErr);
  // (fractional already rejected at API ingest, but re-checked in CheckIfLineCanBeProcessed)
  ```

- **`ValidateMembershipForToken`** (`:418-444`) — Confirm path. **Keep** `Quantity <> 1` — the line references an existing `Membership Id` so qty>1 is meaningless.

- **`ValidateMembershipAlterationRequest`** (`:446-518`) — Renew / Extend / Upgrade. **Add** a `Quantity <> 1` guard at the top (today there is no quantity check there, but qty>1 would silently misbehave because the entire procedure operates on a single membership identified by `EcomSalesLine."Membership Id"`):

  ```al
  if EcomSalesLine.Quantity <> 1 then
      Error(QuantityErr);
  ```

### 4.3 Processing-time guard — `CheckIfLineCanBeProcessed` + handler-layer backstops

`EcomCreateMMShipImpl.CheckIfLineCanBeProcessed` (`:126-146`) currently has a hard `Quantity <> 1` check at `:137`. Replace with the **operation-agnostic** checks below — keep the upfront gate scoped to invariants that don't depend on which operation we're about to run:

```al
if EcomSalesLine.Quantity <> Round(EcomSalesLine.Quantity, 1) then
    EcomSalesLine.FieldError(Quantity);
if EcomSalesLine.Quantity < 1 then
    EcomSalesLine.FieldError(Quantity);
```

Operation-specific quantity rules (Confirm/Renew/Extend/Upgrade require `Quantity = 1`) are enforced inside the per-operation handlers — see §4.5.3 and §4.5.4.

**Process body ordering — original order preserved (rev 12 — Milena's review pass, 2026-05-21).** Earlier rev 6 reordered `Process` to call `DetermineMembershipOperation` (with writeback) BEFORE `CheckIfLineCanBeProcessed`, to enable an operation-conditional quantity gate at the upfront layer. Reviewer pushback: don't design around stale `Membership Operation` values; avoid the unnecessary `MembershipAlterationSetup.GetBySystemId` lookup on validation-failing alteration lines. Walked back the reorder. The Process body keeps the original layering:

```al
internal procedure Process(var EcomSalesLine: Record "NPR Ecom Sales Line") Success: Boolean
var
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    EcomMembershipOperation: Enum "NPR Ecom Membership Operation";
    ...
begin
    EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
    CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);

    EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
    EcomSalesLine.Get(EcomSalesLine.RecordId);

    EcomMembershipOperation := DetermineMembershipOperation(EcomSalesLine);
    if (EcomSalesLine."Membership Operation" <> EcomMembershipOperation) then begin
        EcomSalesLine."Membership Operation" := EcomMembershipOperation;
        EcomSalesLine.Modify();
    end;
    ...
end;
```

To preserve the operation-conditional `Quantity = 1` invariant for non-Create operations at runtime (the qty=1 assertions in `ValidateMembershipForToken` / `ValidateMembershipAlterationRequest` only run at ingest, not during `Process`), defensive guards live inside the per-operation handlers:

- `ConfirmMembership` (§4.5.1) — first statement: `if EcomSalesLine.Quantity <> 1 then Error(QuantityErr);`
- `ProcessMembershipAlteration` (§4.5.3) — first statement: `if EcomSalesLine.Quantity <> 1 then Error(QuantityErr);`

Net effect: the silent-corruption vector (stale stored Op = Create + actual Op = Confirm + qty=5 → one membership entry receiving the full line amount) is closed by the handler-layer backstop, regardless of upstream gate state or operation-resolution timing.

### 4.4 Membership creation — `EcomCreateMMShipImpl.CreateMembership`

Today (`:191-217`), verbatim:

```al
internal procedure CreateMembership(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
var
    MemberInfoCapture: Record "NPR MM Member Info Capture";
    MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    Membership: Record "NPR MM Membership";
    MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
begin
    MemberInfoCapture.Init();
    MemberInfoCapture."Entry No." := 0;
    MemberInfoCapture."Item No." := GetItemNoAsCode20(EcomSalesLine);
    MemberInfoCapture."Import Entry Document ID" :=
        CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(MemberInfoCapture."Import Entry Document ID"));
    MemberInfoCapture.Insert();

    UpdateMemberInfoCaptureFromLine(MemberInfoCapture, EcomSalesLine);
    SetNotificationMethod(MemberInfoCapture);
    MemberInfoCapture.Modify();

    GetMembershipSaleSetup(MembershipSalesSetup, GetItemNoAsCode20(EcomSalesLine));
    MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);

    Membership.Get(MemberInfoCapture."Membership Entry No.");
    EcomSalesLine."Membership Id" := Membership.SystemId;   // ← writeback (moves to caller in the refactor)
    EcomSalesLine.Modify();                                  // ← writeback
    MemberInfoCapture.Delete();
end;
```

Rewritten around a loop with link-row-count race recovery (same pattern as CORE-209 §4.2 — see that design for the full rationale on the count-first guard and the `Codeunit.Run` race window):

```al
internal procedure CreateMembership(var EcomSalesLine: Record "NPR Ecom Sales Line";
                                     EcomSalesHeader: Record "NPR Ecom Sales Header") IssuedAnyThisRound: Boolean
var
    EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
    QtyToIssue, AlreadyLinked, i: Integer;
    FirstMembership: Record "NPR MM Membership";
begin
    QtyToIssue := Round(EcomSalesLine.Quantity, 1, '>');
    AlreadyLinked := CountExistingLinks(EcomSalesHeader, EcomSalesLine);

    case true of
        AlreadyLinked = QtyToIssue:
            exit(false);  // race recovery — another session already issued these; events stay quiet
        AlreadyLinked > QtyToIssue:
            Error(LinkCountExceedsQtyErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
        (AlreadyLinked > 0) and (AlreadyLinked < QtyToIssue):
            Error(PartialLinkStateErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
    end;

    for i := 1 to QtyToIssue do begin
        IssueSingleMembership(EcomSalesLine, EcomSalesHeader, FirstMembership, i = 1);
        // FirstMembership is captured only on i=1 for the qty=1 writeback below
    end;

    if QtyToIssue = 1 then begin
        EcomSalesLine."Membership Id" := FirstMembership.SystemId;
        EcomSalesLine.Modify();
    end;

    IssuedAnyThisRound := true;
end;
```

`IssuedAnyThisRound` is consumed by `Process` (§4.5.3) to gate `OnAfterMembershipCreatedBeforeCommit`. Race-recovery exits cleanly with `false`; the success path returns `true`. The two error branches don't reach `exit` — `Error` aborts the call and the surrounding `Codeunit.Run` rolls back.

`IssueSingleMembership` is today's `CreateMembership` body **with three small diffs** — nothing added beyond:
1. The `EcomSalesLine."Membership Id" := ...; EcomSalesLine.Modify();` writeback pair is **removed** (caller-managed now, qty=1 only).
2. `InsertMembershipLink(EcomSalesHeader, EcomSalesLine, Membership)` is **added as the last DB op** (sequencing invariant — same load-bearing reason as voucher design §4.2: link row is the durable race-recovery marker; a future commit between membership creation and link insert would break the count-first guard).
3. New `var IssuedMembership` return-by-ref + `CaptureForWriteback: Boolean` parameter — used by the caller to capture `FirstMembership` once for the qty=1 writeback after the loop.

The other 11 lines of body (MemberInfoCapture init/fill/insert, `UpdateMemberInfoCaptureFromLine`, `SetNotificationMethod`, `GetMembershipSaleSetup`, `CreateMembershipAll`, `Membership.Get`, `MemberInfoCapture.Delete`) are **inherited verbatim** from today's procedure shown above.

```al
local procedure IssueSingleMembership(var EcomSalesLine, EcomSalesHeader,
                                       var IssuedMembership: Record "NPR MM Membership";
                                       CaptureForWriteback: Boolean)
var
    MemberInfoCapture: Record "NPR MM Member Info Capture";
    MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    Membership: Record "NPR MM Membership";
    MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
begin
    MemberInfoCapture.Init();
    MemberInfoCapture."Entry No." := 0;
    MemberInfoCapture."Item No." := GetItemNoAsCode20(EcomSalesLine);
    MemberInfoCapture."Import Entry Document ID" :=
        CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(MemberInfoCapture."Import Entry Document ID"));
    MemberInfoCapture.Insert();

    UpdateMemberInfoCaptureFromLine(MemberInfoCapture, EcomSalesLine);
    SetNotificationMethod(MemberInfoCapture);
    MemberInfoCapture.Modify();

    GetMembershipSaleSetup(MembershipSalesSetup, GetItemNoAsCode20(EcomSalesLine));
    MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);

    Membership.Get(MemberInfoCapture."Membership Entry No.");
    MemberInfoCapture.Delete();

    InsertMembershipLink(EcomSalesHeader, EcomSalesLine, Membership);  // ← last DB op

    if CaptureForWriteback then
        IssuedMembership := Membership;
end;

local procedure InsertMembershipLink(EcomSalesHeader, EcomSalesLine, Membership)
var
    EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
begin
    EcomSalesMembershipLink.Init();
    EcomSalesMembershipLink."Source System Id" := EcomSalesHeader.SystemId;
    EcomSalesMembershipLink."Source Line System Id" := EcomSalesLine.SystemId;
    EcomSalesMembershipLink."Membership System Id" := Membership.SystemId;
    EcomSalesMembershipLink.Insert(true);
end;
```

**Writeback rule.** For `Quantity = 1` we still write `EcomSalesLine."Membership Id"` so the existing GET response (`AddProperty('membershipId', ...)` at `EcomSalesDocApiAgentV2.al:826`) keeps its current value — backward compatibility for any consumer already reading it. For `Quantity > 1` we leave `Membership Id` blank; API callers that need to discover the N issued memberships use the document-level subpage / `action(Memberships)` until a follow-up PR ships the public `createdMemberships` GET array (see §4.6). Same trade-off shape as vouchers (§4.2 of CORE-209 design).

The legacy TODO at `EcomCreateMMShipImpl.al:211-213` (`// Wrong cardinality. Multiple sales interact with the membership over time. Field will be removed`) is not addressed by this PR — we keep the field for the qty=1 back-compat write and let it stay blank for qty>1. Future deprecation of the field is out of scope.

### 4.5 Confirm-after-Create chain — Process

`EcomCreateMMShipImpl.Process` (`:39-45`) chains:

```al
EcomMembershipOperation::CreateMembership:
    begin
        CreateMembership(EcomSalesLine, EcomSalesHeader);
        _EcomVirtualItemEvents.OnAfterMembershipCreatedBeforeCommit(EcomSalesLine);
        ConfirmMembership(EcomSalesLine, EcomSalesHeader);
        _EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
    end;
```

`ConfirmMembership` (`:148-189`) reads `EcomSalesLine."Membership Id"` to identify which membership to confirm. With qty>1 that field is blank — we need to confirm each of the N memberships individually. Two problems to solve at once: identity (find each membership), and money (split the line amount fairly across N).

#### 4.5.1 Per-membership amount allocation — load-bearing for accounting correctness

Today `ConfirmMembership` writes `MembershipEntry.Amount` / `"Amount Incl VAT"` from the line's **total** `Line Amount` / `VAT %` via `UpdateMembershipEntryAmounts` (`:714-722`). For qty=1 that is correct; the line total = the membership's price.

For qty>1, two failure modes:
1. **Whole-line clobber** (codex review rev 1) — naively looping with the same `Line Amount` would write the full line total into each of N entries. A qty=5 sale at `Line Amount = 50` records `5 × 50 = 250` of revenue.
2. **Derived-side drift** (codex review rev 2) — even with a correct equal split, computing the secondary column independently for each membership rounds independently. Example: `Price Excl. VAT = true`, `Line Amount = 10.01`, `VAT = 25%`, qty=3. Per-membership `Amount = 3.34 / 3.34 / 3.33`; per-membership `Amount Incl VAT` derived as `Round(share × 1.25, 0.01) = 4.18 / 4.18 / 4.16 = 12.52`. Whole-line `Amount Incl VAT = Round(10.01 × 1.25, 0.01) = 12.51`. The summed-entry total doesn't reconcile to the source line.

The fix splits **both columns independently** at the whole-line level, then distributes each split with last-row remainder absorption. Both `Amount` and `Amount Incl VAT` end up summing to exactly their respective whole-line totals — no drift on either side.

```al
local procedure ConfirmAllMembershipsForLine(EcomSalesLine: Record "NPR Ecom Sales Line";
                                              EcomSalesHeader: Record "NPR Ecom Sales Header") DidConfirmAny: Boolean
var
    EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
    WholeAmount, WholeAmountInclVAT: Decimal;
    PerMembershipAmount, PerMembershipAmountInclVAT: Decimal;
    ConsumedAmount, ConsumedAmountInclVAT: Decimal;
    ThisAmount, ThisAmountInclVAT: Decimal;
    QtyToConfirm, i: Integer;
begin
    QtyToConfirm := Round(EcomSalesLine.Quantity, 1, '>');
    if QtyToConfirm <= 0 then exit;

    // Compute both whole-line totals once via the shared helper (§4.5.2 ComputeWholeLineAmounts).
    // Whichever side carries Line Amount is authoritative; the other side is derived once and
    // split independently. This is the only way to get both columns to sum to their whole-line
    // totals without per-membership rounding drift.
    ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT);

    PerMembershipAmount := Round(WholeAmount / QtyToConfirm, 0.01);
    PerMembershipAmountInclVAT := Round(WholeAmountInclVAT / QtyToConfirm, 0.01);
    ConsumedAmount := 0;
    ConsumedAmountInclVAT := 0;
    i := 0;

    EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");   // deterministic iteration
    EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    if EcomSalesMembershipLink.FindSet() then
        repeat
            i += 1;
            if i = QtyToConfirm then begin
                ThisAmount := WholeAmount - ConsumedAmount;                       // last absorbs remainder
                ThisAmountInclVAT := WholeAmountInclVAT - ConsumedAmountInclVAT;
            end else begin
                ThisAmount := PerMembershipAmount;
                ThisAmountInclVAT := PerMembershipAmountInclVAT;
            end;
            ConsumedAmount += ThisAmount;
            ConsumedAmountInclVAT += ThisAmountInclVAT;
            if ConfirmMembershipById(EcomSalesMembershipLink."Membership System Id",
                                     ThisAmount, ThisAmountInclVAT,
                                     EcomSalesLine, EcomSalesHeader)
            then
                DidConfirmAny := true;
        until EcomSalesMembershipLink.Next() = 0;
end;
```

**Two invariants, both load-bearing:**
1. `sum(ThisAmount across N memberships) = WholeAmount` exactly.
2. `sum(ThisAmountInclVAT across N memberships) = WholeAmountInclVAT` exactly.

Test #6 (§7) verifies both — parameterized over `Price Excl. VAT = true` (codex's `10.01, 25%, qty=3` case) AND `Price Excl. VAT = false` (the symmetric `12.51, 25%, qty=3` case). Each column reconciles to its respective whole-line total cent-perfect under both pricing modes.

**Determinism.** The link table's `BySourceLine` key is `("Source Line System Id", "Entry No.")` (§3.1) so `FindSet()` returns rows in insertion order. The "last" row that absorbs the remainder is therefore the most-recently inserted link row for the line — deterministic and replayable.

**Currency rounding precision.** The standard `0.01` is the safe default for the major currencies the system already supports. If the ecom doc later carries a finer-grained `Currency."Amount Rounding Precision"`, swap `0.01` for that value. For v1, hardcoded `0.01` matches `UpdateMembershipEntryAmounts`'s existing rounding precision at `:718, :721`.

**Why split on `Line Amount` and not on `Unit Price × 1`.** `Line Amount` is the post-discount, post-line-discount value. Splitting `Line Amount` means each membership carries its proportional share of any line-level discount, which is the right accounting behavior (the customer bought N memberships under a single "5 for €40" promo; each one's recorded price should reflect that). The current `UpdateMembershipEntryAmounts` already reads `Line Amount` directly — we're preserving that contract, just dividing.

**Why `lineAmount` is not rounded at API ingest.** Codex review rev 2 raised it — `lineAmount` accepting arbitrary decimal precision could leave us splitting a value the system can't represent at 2dp. We deliberately do NOT round at ingest because: (a) it would silently corrupt callers that send 4dp prices for non-currency-rounded scenarios; (b) the both-columns-split fix above handles the drift problem already (drift only ever appeared because the secondary column was derived, not because the input was non-2dp); (c) the API contract for `lineAmount` precision is a broader decision that doesn't belong in this PR.

#### 4.5.2 Refactor — `ConfirmMembershipById` + shared `ComputeWholeLineAmounts`

The whole-line totals computation is now load-bearing for accounting correctness (§4.5.1, decision #16). To prevent the formula from drifting between call sites — `ConfirmAllMembershipsForLine` (qty>1 bulk path) and the standalone-`ConfirmMembership` shell (qty=1 path) — extract a single `ComputeWholeLineAmounts` helper that's the only place either column is computed from `Line Amount + VAT % + Price Excl. VAT`:

```al
local procedure ComputeWholeLineAmounts(EcomSalesLine: Record "NPR Ecom Sales Line";
                                         EcomSalesHeader: Record "NPR Ecom Sales Header";
                                         var WholeAmount: Decimal;
                                         var WholeAmountInclVAT: Decimal)
begin
    if EcomSalesHeader."Price Excl. VAT" then begin
        WholeAmount := EcomSalesLine."Line Amount";
        WholeAmountInclVAT := Round(EcomSalesLine."Line Amount" * (1 + EcomSalesLine."VAT %" / 100), 0.01);
    end else begin
        WholeAmountInclVAT := EcomSalesLine."Line Amount";
        WholeAmount := Round(EcomSalesLine."Line Amount" / (1 + EcomSalesLine."VAT %" / 100), 0.01);
    end;
end;
```

Both callers — the qty>1 bulk path in §4.5.1 and the qty=1 shell below — start by calling `ComputeWholeLineAmounts`. The qty=1 shell then trivially calls `ConfirmMembershipById` with `(WholeAmount, WholeAmountInclVAT)`; the qty>1 path splits each whole-line total before calling.

Extract `ConfirmMembership`'s body into:

```al
local procedure ConfirmMembershipById(MembershipSystemId: Guid;
                                       AmountForEntry: Decimal;
                                       AmountInclVATForEntry: Decimal;
                                       EcomSalesLine: Record "NPR Ecom Sales Line";
                                       EcomSalesHeader: Record "NPR Ecom Sales Header") DidFlip: Boolean
```

`EcomSalesLine` is needed for `InsertMembershipLink` (the link row's `Source Line System Id`). The body uses the line **only** for that link-insert call site — all other state comes from the membership lookup (`MembershipSystemId`), pre-computed amounts (`AmountForEntry`, `AmountInclVATForEntry`), and the header (for `External No.`, `Sell-to Email`). This reverses the rev-3 trim (decision #19) — necessitated by the wider link-row scope in decision #20.

Inside the body, the old `UpdateMembershipEntryAmounts(...)` call is replaced with the slim `ApplyAmountsToEntry` helper:

```al
local procedure ApplyAmountsToEntry(var MembershipEntry: Record "NPR MM Membership Entry";
                                    AmountValue: Decimal;
                                    AmountInclVATValue: Decimal)
begin
    MembershipEntry.Amount := AmountValue;
    MembershipEntry."Amount Incl VAT" := AmountInclVATValue;
end;
```

`ConfirmMembershipById` returns `DidFlip` — `true` when this call actually wrote `MembershipEntry."Document No."` (not just took the idempotency-exit branch at `:174-178`). This boolean is what `ConfirmAllMembershipsForLine`'s `DidConfirmAny` and the event-gating in §4.5.3 are built on.

```al
local procedure ConfirmMembershipById(...; EcomSalesLine: Record "NPR Ecom Sales Line") DidFlip: Boolean
var
    MembershipEntry: ...
    Membership: ...
begin
    DidFlip := false;
    // ... existing membership-lookup + blocked check + entry-lookup unchanged ...

    if MembershipEntry."Document No." <> '' then begin
        if MembershipEntry."Document No." = EcomSalesHeader."External No." then
            exit;                        // idempotent re-confirm — DidFlip stays false, no link insert
        Error(AlreadyConfirmedErr, Membership."Entry No.");
    end;

    MembershipEntry."Source Type" := MembershipEntry."Source Type"::SALESHEADER;
    MembershipEntry."Document Type" := SalesHeader."Document Type"::Order;
    MembershipEntry."Document No." := EcomSalesHeader."External No.";
    ApplyAmountsToEntry(MembershipEntry, AmountForEntry, AmountInclVATForEntry);
    MembershipEntry.Modify();

    SponsorshipTicketMgmt.OnMembershipPayment(MembershipEntry);
    CreateMembershipPaymentMethods(EcomSalesHeader, Membership);

    // Last DB op — sequencing invariant analogous to §4.4. Insert the link row IF it doesn't already
    // exist for this (line, membership) pair. The dedup check is necessary because the Create flow
    // already inserts link rows in IssueSingleMembership before ConfirmAllMembershipsForLine fans
    // out to ConfirmMembershipById; without the check we'd duplicate. For the standalone-Confirm
    // operation no prior link row exists, so the check succeeds and the insert runs.
    EnsureMembershipLinkExists(EcomSalesHeader, EcomSalesLine, Membership);

    DidFlip := true;
end;

local procedure EnsureMembershipLinkExists(EcomSalesHeader: Record "NPR Ecom Sales Header";
                                            EcomSalesLine: Record "NPR Ecom Sales Line";
                                            Membership: Record "NPR MM Membership")
var
    EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
begin
    EcomSalesMembershipLink.SetCurrentKey("Source Line System Id");
    EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    EcomSalesMembershipLink.SetRange("Membership System Id", Membership.SystemId);
    if not EcomSalesMembershipLink.IsEmpty() then exit;
    InsertMembershipLink(EcomSalesHeader, EcomSalesLine, Membership);
end;
```

**Why a dedup helper, not unconditional insert.** The `(Source Line System Id, Membership System Id)` pair is unique by construction across the link table (Create's loop inserts N rows with N distinct Membership System Ids for one line; the four non-Create operations each insert one row for the targeted membership). But the call sites differ:
- **Create path**: `IssueSingleMembership` already inserts the link row; `ConfirmAllMembershipsForLine` then calls `ConfirmMembershipById` on the same row's membership → dedup short-circuits.
- **Standalone Confirm / Renew / Extend / Upgrade**: no prior link row → dedup check passes, insert runs.

The `BySourceLine` key covers the filter — IsEmpty against the index is cheap, no scan.

**Note: `EcomSalesLine` is back as a parameter.** Codex's rev-3 cleanup removed it because the rev-3 body didn't use the line. With the link-write added here (and `InsertMembershipLink` / `EnsureMembershipLinkExists` needing `EcomSalesLine.SystemId` as the link row's `Source Line System Id`), the parameter is genuinely used again. Decision #19's "trim unused parameter" rationale was correct at the time but is reversed by the wider link-row scope decided in decision #20.

**Existing `ConfirmMembership` shell (qty=1 standalone path).** Calls the shared `ComputeWholeLineAmounts` then delegates — no duplicated formula:

```al
internal procedure ConfirmMembership(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
var
    WholeAmount, WholeAmountInclVAT: Decimal;
begin
    EcomSalesLine.TestField("Membership Id");
    ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT);
    if ConfirmMembershipById(EcomSalesLine."Membership Id", WholeAmount, WholeAmountInclVAT, EcomSalesLine, EcomSalesHeader) then;
end;
```

This matches today's `UpdateMembershipEntryAmounts` output exactly for qty=1 (whichever side carries `Line Amount` is preserved verbatim; the derived side rounds identically because there's only one membership to round to).

`ConfirmAllMembershipsForLine` (§4.5.1) is updated symmetrically to delegate to `ComputeWholeLineAmounts` at its boundary instead of inlining the conditional:

```al
ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT);
PerMembershipAmount := Round(WholeAmount / QtyToConfirm, 0.01);
PerMembershipAmountInclVAT := Round(WholeAmountInclVAT / QtyToConfirm, 0.01);
// ... rest of the per-membership loop unchanged
```

Single point of truth for the rounding-precision and VAT-direction policy. If the policy ever changes (e.g., to honor `Currency."Amount Rounding Precision"`), one place updates both flows.

The existing `UpdateMembershipEntryAmounts` (`:714-722`) stays in place for the alteration paths (`ReshapeMembershipDuration` at `:725-789` writes amounts to `MemberInfoCapture`, not directly to `MembershipEntry`, so it goes through a different code path that's qty=1-gated and unaffected by this refactor).

#### 4.5.3 Alteration path (Renew / Extend / Upgrade) — link row + race-recovery guard

`ProcessMembershipAlteration` (`:219-222`) is the entry point for the three alteration operations. Today it just calls `ReshapeMembershipDuration`. Wrap it with a count-guard race-recovery branch (same shape as `CreateMembership` §4.4 but for qty=1) and insert the link row after the alteration succeeds:

```al
internal procedure ProcessMembershipAlteration(EcomSalesLine: Record "NPR Ecom Sales Line";
                                                 EcomSalesHeader: Record "NPR Ecom Sales Header") DidAlterThisRound: Boolean
var
    EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
    Membership: Record "NPR MM Membership";
    ExistingLinkCount: Integer;
    AlterationCorruptionErr: Label 'Internal data inconsistency on membership alteration line %1: %2 link row(s) exist for membership %3 but exactly 0 or 1 was expected. Contact support to investigate. This is a programming bug.', Locked = true;
    AlterationMembershipMismatchErr: Label 'Internal data inconsistency on membership alteration line %1: existing link row points at a different membership than the line''s targeted Membership Id. Contact support to investigate. This is a programming bug.', Locked = true;
begin
    EcomSalesMembershipLink.SetCurrentKey("Source Line System Id", "Entry No.");
    EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    ExistingLinkCount := EcomSalesMembershipLink.Count();

    case ExistingLinkCount of
        0:
            ;   // proceed — first run of this alteration
        1:
            begin
                EcomSalesMembershipLink.FindFirst();
                if EcomSalesMembershipLink."Membership System Id" <> EcomSalesLine."Membership Id" then
                    Error(AlterationMembershipMismatchErr, EcomSalesLine.RecordId());
                exit(false);   // race recovery — alteration already completed for the same membership in a prior session
            end;
        else
            Error(AlterationCorruptionErr, EcomSalesLine.RecordId(), ExistingLinkCount, EcomSalesLine."Membership Id");
    end;

    ReshapeMembershipDuration(EcomSalesLine, EcomSalesHeader);

    Membership.GetBySystemId(EcomSalesLine."Membership Id");
    InsertMembershipLink(EcomSalesHeader, EcomSalesLine, Membership);
    DidAlterThisRound := true;
end;
```

**Why the case-analysis shape, not a bare `> 0` short-circuit (codex rev-6).**
- `0` → no link row → proceed with the alteration.
- `1 + same membership` → race recovery: the alteration was completed for THIS targeted membership in a prior session. Silent no-op.
- `1 + different membership` → corruption: the link row points at a different membership than `EcomSalesLine."Membership Id"` expected. Hard error (programming-bug suffix → Sentry).
- `>1` → corruption: alteration is always qty=1 by §4.2, so there should never be more than one link row. Hard error.

This mirrors Create's count-guard shape (§4.4) — every state is explicit, none of the failure modes is silently swallowed.

**No dedup helper here.** The race-recovery branch already exits before any link insert, so `InsertMembershipLink` is unconditional. (Unlike `ConfirmMembershipById` which is called from both Create-after-confirm and standalone-Confirm contexts; this procedure is called only from the alteration `Process` branches, so the count-guard above guarantees no prior link row exists when we reach the insert.)

**Sentry capture.** Both error labels use "This is a programming bug" suffix; the existing Sentry hook in `EcomCreateMMShipProcess.OnRun` (Task 5) captures them between `Run` and `HandleResponse`.

#### 4.5.4 Process branch — wiring with event gating

`CreateMembership`, `ConfirmAllMembershipsForLine`, `ConfirmMembership` (the standalone-Confirm shell), and `ProcessMembershipAlteration` all return booleans indicating "did this call actually do work this round." The `Process` branch gates the corresponding events on those returns so race-recovery (or any future no-op replay) doesn't fire events for work that wasn't actually performed in this session:

```al
case EcomSalesLine."Membership Operation" of
    EcomMembershipOperation::CreateMembership:
        begin
            if CreateMembership(EcomSalesLine, EcomSalesHeader) then
                _EcomVirtualItemEvents.OnAfterMembershipCreatedBeforeCommit(EcomSalesLine);
            if ConfirmAllMembershipsForLine(EcomSalesLine, EcomSalesHeader) then
                _EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
        end;
    EcomMembershipOperation::ConfirmMembership:
        if ConfirmMembership(EcomSalesLine, EcomSalesHeader) then
            _EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
    EcomMembershipOperation::RenewMembership:
        if ProcessMembershipAlteration(EcomSalesLine, EcomSalesHeader) then
            _EcomVirtualItemEvents.OnAfterMembershipRenewedBeforeCommit(EcomSalesLine);
    EcomMembershipOperation::ExtendMembership:
        if ProcessMembershipAlteration(EcomSalesLine, EcomSalesHeader) then
            _EcomVirtualItemEvents.OnAfterMembershipExtendedBeforeCommit(EcomSalesLine);
    EcomMembershipOperation::UpgradeMembership:
        if ProcessMembershipAlteration(EcomSalesLine, EcomSalesHeader) then
            _EcomVirtualItemEvents.OnAfterMembershipUpgradedBeforeCommit(EcomSalesLine);
end;
```

The standalone `ConfirmMembership(EcomSalesLine, EcomSalesHeader)` shell (§4.5.2) returns a boolean too — its body simply delegates to `ConfirmMembershipById` and returns `DidFlip`. Renamed return parameter for clarity:

```al
internal procedure ConfirmMembership(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header") DidConfirmAny: Boolean
var
    WholeAmount, WholeAmountInclVAT: Decimal;
begin
    EcomSalesLine.TestField("Membership Id");
    ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT);
    DidConfirmAny := ConfirmMembershipById(EcomSalesLine."Membership Id", WholeAmount, WholeAmountInclVAT, EcomSalesLine, EcomSalesHeader);
end;
```

`CreateMembership` returns `IssuedAnyThisRound`:
- `true` when the issuance loop ran at least once (i.e., `AlreadyLinked = 0` branch was taken and we created N memberships).
- `false` when the count-guard race-recovery branch (`AlreadyLinked = QtyToIssue`) exits immediately without creating anything.

`ConfirmAllMembershipsForLine` returns `DidConfirmAny` (the OR-reduction over each `ConfirmMembershipById` return value):
- `true` when at least one membership actually flipped from unconfirmed to confirmed in this call.
- `false` when every membership was already confirmed on this document (idempotent re-entry).

The legacy `ConfirmMembership(EcomSalesLine, EcomSalesHeader)` shell is still needed for the standalone `ConfirmMembership` branch of `Process` (`:46-50`) — qty=1, caller supplies an existing `Membership Id`. Its body becomes:

```al
EcomMembershipOperation::ConfirmMembership:
    begin
        ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT);
        if ConfirmMembershipById(EcomSalesLine."Membership Id", WholeAmount, WholeAmountInclVAT, EcomSalesLine, EcomSalesHeader) then
            _EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
    end;
```

(The legacy `ConfirmMembership(EcomSalesLine, EcomSalesHeader)` shell at `:148-189` still exists and is equivalent to the snippet above; the inlined version makes the event gating visible at the dispatch site.)

**Event firing — semantics.** `OnAfterMembershipCreatedBeforeCommit` and `OnAfterMembershipConfirmedBeforeCommit` fire **once per line** when work is actually performed in this session, with `EcomSalesLine` as argument. Subscribers today receive the line, not the individual memberships — and for qty>1 the line is the only natural granularity. Subscribers that want to walk the N memberships can read the link table. The event contract stays as-is; only the gating is tightened.

**Race-recovery + event firing — resolved across all 5 operations.** Codex review (rev 1 + rev 2) flagged that an unguarded event-on-race-recovery path leaks duplicate firings to out-of-tree subscribers. The boolean-return-guards above close that for every operation:

- **Create**: race recovery returns `IssuedAnyThisRound = false` (§4.4); also `DidConfirmAny = false` because every membership short-circuits via the idempotency check in `ConfirmMembershipById`. Neither `OnAfter...Created` nor `OnAfter...Confirmed` fires.
- **Confirm (standalone)**: race recovery short-circuits via `MembershipEntry."Document No." = External No.` in `ConfirmMembershipById` → `DidFlip = false` → `DidConfirmAny = false`. `OnAfter...Confirmed` does not fire.
- **Renew / Extend / Upgrade**: `ProcessMembershipAlteration` checks the link-count at the top → returns `false` if a link row exists from a prior session. None of `OnAfter...Renewed` / `Extended` / `Upgraded` fire.

All five operations have a deterministic "no work this round = no events fired" property, validated by test #5 in §7 (race recovery for Create — no duplicates, no events) and test #8 (alteration race recovery — no second alteration, no event).

### 4.6 GET response — out of scope for this PR

**No change to `EcomSalesDocApiAgentV2`** for the memberships response shape in this PR. Rationale: the voucher analog (`AddCreatedVouchersArray`) was implemented in CORE-209 and then **disabled by commenting out the call site and procedure body** during PR 9975 review pending API-team alignment on the public response contract (`EcomSalesDocApiAgentV2.Codeunit.al:849-892`, "FUTURE" preamble). Memberships will follow the same resolution in a separate follow-up PR aligned with whatever the API team decides for vouchers.

What this means for CORE-208:
- **`AddCreatedMembershipsArray` is NOT shipped** — not even as commented-out code. The procedure does not appear in this PR at all.
- **No edits to `EcomSalesDocApiAgentV2.Codeunit.al`** are part of this PR.
- The existing `AddProperty('membershipId', ...)` at `:826` keeps its current behavior: populated for qty=1 (via the writeback rule from §4.4), blank for qty>1.
- API callers that need to discover the N memberships issued by a qty>1 line read the document-level Memberships subpage / `action(Memberships)` until the public array is shipped in the follow-up PR.

What the follow-up PR will need:
- `AddCreatedMembershipsArray(EcomSalesLine, SalesLineDetailsJsonObject)` — walks `NPR Ecom Sales Membership Link` by `Source Line System Id`, resolves each via `Membership.GetBySystemId`, emits `{id, entryNo, externalMembershipNo}` per row.
- One call site in `AddSalesLineDetailsJsonObject` next to the (re-enabled) `AddCreatedVouchersArray` call.
- Fern spec update — `quantity` semantics on membership lines + `createdMemberships` shape + `membershipId` deprecation note (or whatever the API team decides).
- Two new tests for the array (qty=5 response shape + non-membership-line array omission) — covered in the follow-up PR's test suite, NOT in this PR's §7.

### 4.7 `ShowRelatedMembershipsAction` and the shared temp-buffer builder

The same data-shape — "give me a temp-record set of memberships linked to a given header (and optionally a given line)" — is needed three places: the line-level Show Related dispatch, the document-level Show Related dispatch, and the new subpage payload builder (§4.10). Extract a shared builder on `EcomCreateMMShipImpl`, mirroring the voucher precedent (`BuildVoucherTempBufferForDoc` / `BuildVoucherTempBufferForLine` / private `BuildVoucherTempBuffer`):

```al
internal procedure BuildMembershipTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header";
                                                   var TempMembership: Record "NPR MM Membership" temporary)
var
    EmptyGuid: Guid;
begin
    BuildMembershipTempBuffer(EcomSalesHeader, EmptyGuid, TempMembership);
end;

internal procedure BuildMembershipTempBufferForLine(EcomSalesHeader: Record "NPR Ecom Sales Header";
                                                    EcomSalesLine: Record "NPR Ecom Sales Line";
                                                    var TempMembership: Record "NPR MM Membership" temporary)
begin
    BuildMembershipTempBuffer(EcomSalesHeader, EcomSalesLine.SystemId, TempMembership);
end;

local procedure BuildMembershipTempBuffer(EcomSalesHeader: Record "NPR Ecom Sales Header";
                                          SourceLineSystemIdFilter: Guid;
                                          var TempMembership: Record "NPR MM Membership" temporary)
var
    EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
    EcomSalesLine: Record "NPR Ecom Sales Line";
    Membership: Record "NPR MM Membership";
    EmptyGuid: Guid;
begin
    EcomSalesMembershipLink.SetCurrentKey("Source System Id", "Source Line System Id");
    EcomSalesMembershipLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
    if not IsNullGuid(SourceLineSystemIdFilter) then
        EcomSalesMembershipLink.SetRange("Source Line System Id", SourceLineSystemIdFilter);

    if EcomSalesMembershipLink.FindSet() then begin
        repeat
            if Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id") then begin
                TempMembership := Membership;
                if TempMembership.Insert() then;
            end;
        until EcomSalesMembershipLink.Next() = 0;
        exit;
    end;

    // Legacy fallback: pre-CORE-208 docs have no link rows; trust the line's Membership Id.
    EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
    EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Membership);
    EcomSalesLine.SetFilter("Membership Id", '<>%1', EmptyGuid);
    if not IsNullGuid(SourceLineSystemIdFilter) then
        EcomSalesLine.SetRange(SystemId, SourceLineSystemIdFilter);
    if EcomSalesLine.FindSet() then
        repeat
            if Membership.GetBySystemId(EcomSalesLine."Membership Id") then begin
                TempMembership := Membership;
                if TempMembership.Insert() then;
            end;
        until EcomSalesLine.Next() = 0;
end;

internal procedure OpenMembershipCardForSystemId(SystemIdParam: Guid)
var
    Membership: Record "NPR MM Membership";
    NotAvailableMsg: Label 'This membership is no longer available in the system.';
begin
    if not Membership.GetBySystemId(SystemIdParam) then begin
        Message(NotAvailableMsg);
        exit;
    end;
    Membership.SetRecFilter();
    Page.Run(Page::"NPR MM Membership Card", Membership);
end;
```

Two existing `ShowRelatedMembershipsAction` overloads then collapse to thin dispatchers over the builder:

```al
internal procedure ShowRelatedMembershipsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
var
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    TempMembership: Record "NPR MM Membership" temporary;
    NoMembershipFoundMsg: Label 'No memberships are linked to this line.';
begin
    if not EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then exit;
    BuildMembershipTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempMembership);
    case TempMembership.Count() of
        0:
            Message(NoMembershipFoundMsg);
        1:
            begin
                TempMembership.FindFirst();
                OpenMembershipCardForSystemId(TempMembership.SystemId);
            end;
        else
            Page.Run(0, TempMembership);   // BC opens the registered list page for NPR MM Membership
    end;
end;

internal procedure ShowRelatedMembershipsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
var
    TempMembership: Record "NPR MM Membership" temporary;
begin
    BuildMembershipTempBufferForDoc(EcomSalesHeader, TempMembership);
    if not TempMembership.IsEmpty() then
        Page.Run(0, TempMembership);
end;
```

For qty=1 (single link row OR legacy `Membership Id`) the line-level overload lands the user on the Membership Card directly — preserves today's UX. For qty>1 the user gets the BC default list page for `NPR MM Membership` (`Page.Run(0, ...)`). No new dedicated lookup page object is needed — `NPR MM Membership List` is already registered and renders the temp rows correctly. (If runtime testing shows `Page.Run(0, TempMembership)` doesn't behave as expected with a temporary record, fall back to a dedicated lookup page mirroring `EcomVoucherLookup.Page.al`.)

### 4.8 Notification manifest — not affected

**Confirmed with Milena (2026-05-15): memberships are not part of the digital-notification manifest sent via Notification Entry.** `DigitalOrderNotifMgt.ProcessMemberCardAssets` exists for member-card asset emission, but that path is not invoked for ecom-doc-sourced memberships under CORE-208 — there's no design change needed there. The link table introduced in §3.1 is read by the discovery surfaces (subpage, ShowRelated; the GET-response array `createdMemberships` is a deferred follow-up per §4.6) but not by the manifest builder.

This is the reason the link table stores **only `Membership System Id`** as its join key (the rev-7 simplification, per decision #24) rather than including a `Membership Ledger Entry No.` for the specific `MM Membership Entry` row — discovery only needs membership identity via `Membership.GetBySystemId(...)`, not ledger-entry precision. If a future feature does emit member-card assets through the manifest for ecom-doc sources, a follow-up PR can add the ledger-entry PK field then.

### 4.9 Sales-line bridge — verification only

`EcomSalesDocImplV2` has no special membership branch (grep for `Membership` in that file returns no matches). Memberships flow through the default Item sales-line path: one ecom membership line → one BC `Sales Line` with `Quantity = N` and Type=Item. The BC line then posts as an Item sale into the membership-revenue G/L via the standard Item posting setup.

**To verify at implementation time:** issue a qty=5 membership line, post the SO, confirm there is one `Sales Invoice Line` quantity=5 and amounts are correctly aggregated. No code change expected.

### 4.10 Memberships subpage on `EcomSalesDocument` page — PBT integration

`EcomSalesDocument.Page.al` already runs all virtual-item subpages off a single shared Page Background Task (`NPR Ecom Doc Subpages Task`, codeunit 6150899). The page-level plumbing (`EnqueueSubpagesRefresh`, `OnPageBackgroundTaskCompleted`, `OnPageBackgroundTaskError`, `ClearAllSubpages`, the `_SubpagesPendingForSystemId` / `_SubpagesLoadedForSystemId` state) was introduced in CORE-209 commit `b9b8826ace` and is designed to host additional subpages with one helper + one line each. The current code even carries commented placeholders anticipating exactly this addition:

```al
// EcomSalesDocument.Page.al:550-551
// AllSubpagesLoaded := PopulateTicketsSubpage(Results) and AllSubpagesLoaded;
// AllSubpagesLoaded := PopulateMembershipsSubpage(Results) and AllSubpagesLoaded;

// EcomSalesDocument.Page.al:588-589
// CurrPage.TicketsSubPage.Page.ClearContents();
// CurrPage.MembershipsSubPage.Page.ClearContents();
```

We honor those hooks by adding three artifacts. None require a redesign of the existing PBT plumbing.

#### 4.10.1 New page `NPR Ecom Membership Sub` (ListPart)

Mirror of `EcomVoucherSub.Page.al` (6150924) at the same structural level: temporary `SourceTable`, `ClearContents` / `PopulateFromJsonText` internal procedures, single `Open` action routing through `EcomCreateMMShipImpl.OpenMembershipCardForSystemId`.

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6248183 "NPR Ecom Membership Sub"
{
    Caption = 'Memberships';
    Access = Internal;
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR MM Membership";
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
                field("External Membership No."; Rec."External Membership No.") { ApplicationArea = NPRRetail; ToolTip = 'Specifies the external membership number presented to the customer.'; }
                field("Membership Code"; Rec."Membership Code")                  { ApplicationArea = NPRRetail; ToolTip = 'Specifies the membership product code.'; }
                field("Community Code"; Rec."Community Code")                    { ApplicationArea = NPRRetail; ToolTip = 'Specifies the membership community.'; }
                field("Customer No."; Rec."Customer No.")                        { ApplicationArea = NPRRetail; ToolTip = 'Specifies the customer linked to the membership, if any.'; }
                field(Blocked; Rec.Blocked)                                       { ApplicationArea = NPRRetail; ToolTip = 'Specifies whether the membership is blocked.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenMembership)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected membership to see full details, ledger entries and member info.';
                trigger OnAction()
                var
                    EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
                begin
                    EcomCreateMMShipImpl.OpenMembershipCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    /// <summary>Clears the temp buffer. Called by the parent page before enqueueing a background task or on task error.</summary>
    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    /// <summary>Populates the temp buffer from the JSON array produced by the parent's background task.</summary>
    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        MembershipsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and MembershipsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(MembershipsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(MembershipsJson: JsonArray)
    var
        MembershipToken: JsonToken;
        MembershipObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
    begin
        foreach MembershipToken in MembershipsJson do begin
            MembershipObj := MembershipToken.AsObject();
            Rec.Init();
            if MembershipObj.Get('Ext', FieldToken) then
                Rec."External Membership No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."External Membership No."));
            if MembershipObj.Get('Code', FieldToken) then
                Rec."Membership Code" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Membership Code"));
            if MembershipObj.Get('Comm', FieldToken) then
                Rec."Community Code" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Community Code"));
            if MembershipObj.Get('Cust', FieldToken) then
                Rec."Customer No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Customer No."));
            if MembershipObj.Get('Blk', FieldToken) then
                Rec.Blocked := FieldToken.AsValue().AsBoolean();
            if MembershipObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);  // preserve SystemId for Open action; skip OnInsert (live row already exists)
        end;
    end;
}
#endif
```

The field set is small on purpose. The user can click `Open` for the full Membership Card; the subpage is meant for at-a-glance "what memberships did this doc produce." If a future ask wants amounts/dates/status here, add fields then — keeping it tight today avoids more PBT payload bandwidth.

Field shortlist verification at implementation time: confirm `External Membership No.`, `Membership Code`, `Community Code`, `Customer No.`, `Blocked` exist on `NPR MM Membership` with the captions/types shown. (If `Customer No.` doesn't exist, drop it — it's the most uncertain entry on the list.)

#### 4.10.2 `EcomDocSubpagesTask.Codeunit.al` — add `BuildMembershipsPayload`

Append a sibling builder + a result-key tok, calling the shared temp-buffer builder from §4.7:

```al
trigger OnRun()
...
begin
    ...
    BuildVouchersPayload(EcomSalesHeader, Result);
    BuildMembershipsPayload(EcomSalesHeader, Result);   // ← new line
    Page.SetBackgroundTaskResult(Result);
end;

local procedure BuildMembershipsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
var
    TempMembership: Record "NPR MM Membership" temporary;
    MMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    MembershipsJson: JsonArray;
    MembershipJson: JsonObject;
    MembershipsJsonText: Text;
begin
    MMShipImpl.BuildMembershipTempBufferForDoc(EcomSalesHeader, TempMembership);
    if TempMembership.FindSet() then
        repeat
            Clear(MembershipJson);
            MembershipJson.Add('Ext', TempMembership."External Membership No.");
            MembershipJson.Add('Code', TempMembership."Membership Code");
            MembershipJson.Add('Comm', TempMembership."Community Code");
            MembershipJson.Add('Cust', TempMembership."Customer No.");
            MembershipJson.Add('Blk', TempMembership.Blocked);
            MembershipJson.Add('Sid', Format(TempMembership.SystemId, 0, 4));
            MembershipsJson.Add(MembershipJson);
        until TempMembership.Next() = 0;
    MembershipsJson.WriteTo(MembershipsJsonText);
    Result.Add(MembershipsResultKeyTok(), MembershipsJsonText);
end;

internal procedure MembershipsResultKeyTok(): Text
var
    ResultKeyTok: Label 'Memberships', Locked = true;
begin
    exit(ResultKeyTok);
end;
```

Side effect: the single child session that already loads vouchers now also loads memberships. The cost is one extra link-table `FindSet` + N `GetBySystemId` against `NPR MM Membership` (typically 0-5 memberships per doc). Worst-case impact on existing voucher-only doc opens is negligible — the early-exit pattern `if TempMembership.FindSet() then ...` produces no JSON entries and adds a few microseconds of payload bookkeeping.

#### 4.10.3 `EcomSalesDocument.Page.al` — wire the part and the routing

Verify line numbers at implementation time — the page has continued evolving since rev 5 of this design and the citations below may have drifted. The current shape (verified 2026-05-18):

```al
// In the layout, immediately after VouchersSubPage at :289:
part(MembershipsSubPage; "NPR Ecom Membership Sub")
{
    Caption = 'Memberships';
    ApplicationArea = NPRRetail;
    UpdatePropagation = Both;
}

// OnPageBackgroundTaskCompleted at :558 — replace the commented placeholder with the real call.
// Verify the line position; current shape is the AND-chain that requires all subpages loaded:
AllSubpagesLoaded := PopulateVouchersSubpage(Results);
AllSubpagesLoaded := PopulateMembershipsSubpage(Results) and AllSubpagesLoaded;

// ClearAllSubpages at :596 — replace the commented placeholder with the real call:
CurrPage.VouchersSubPage.Page.ClearContents();
CurrPage.MembershipsSubPage.Page.ClearContents();

// New helper alongside PopulateVouchersSubpage at :581 — exact mirror, different keys/page:
local procedure PopulateMembershipsSubpage(Results: Dictionary of [Text, Text]) PayloadPresent: Boolean
var
    EcomDocSubpagesTask: Codeunit "NPR Ecom Doc Subpages Task";
    PayloadText: Text;
begin
    PayloadPresent := Results.Get(EcomDocSubpagesTask.MembershipsResultKeyTok(), PayloadText);
    if PayloadPresent then
        CurrPage.MembershipsSubPage.Page.PopulateFromJsonText(PayloadText)
    else
        CurrPage.MembershipsSubPage.Page.ClearContents();
end;
```

**Do not touch `EnqueueSubpagesRefresh` or `OnPageBackgroundTaskError`.** They evolved post-rev-5: `EnqueueSubpagesRefresh` now uses `Codeunit "NPR Ecom Subpages Sync".ConsumeDirty(...)` (added in commit after rev 5) so subpage-action mutations (e.g. "Process Virtual Item" on `EcomSalesDocSub`) can invalidate the parent's `_SubpagesLoadedForSystemId` cache and force a fresh PBT — including cancelling an in-flight PBT that has pre-mutation data. The membership subpage benefits from this mechanism automatically: when the user reprocesses a membership line via the line-subpage action, `Sync.MarkDirty(EcomSalesHeader.SystemId)` is already called there, the parent's `EnqueueSubpagesRefresh` consumes the flag, and our new `PopulateMembershipsSubpage` helper gets called as part of the fresh PBT.

**Page-level vars unchanged.** `_SubpagesBackgroundTaskId` / `_SubpagesPendingForSystemId` / `_SubpagesLoadedForSystemId` stay as they are. The "all subpages loaded before promoting Pending → Loaded" semantics in `OnPageBackgroundTaskCompleted` now correctly require both vouchers and memberships present — exactly what the `AllSubpagesLoaded := ... and AllSubpagesLoaded` chain is built to enforce.

**No `Sync.MarkDirty` call needed from the membership processing path.** Vouchers don't add one either — `Sync.MarkDirty` is called only from the subpage-action mutator (`EcomSalesDocSub.Page.al "Process Virtual Item"` trigger) where there's no other way to signal the parent. Membership processing reaches the page through standard `OnAfterGetCurrRecord` triggers (record navigation, page reopen, `RefreshOnActivate`), all of which the existing `EnqueueSubpagesRefresh` body handles correctly without a dirty-flag hint.

#### 4.10.4 Three surfaces, one data source — entry points unchanged

The three discovery surfaces all share a single data source. Their **entry points do not change in this PR**; only the procedure bodies they already call are rewritten in §4.7 to walk `NPR Ecom Sales Membership Link` first (with legacy fallback to `EcomSalesLine."Membership Id"`):

| Surface | Entry point (unchanged) | Resolves through |
|---|---|---|
| Subpage on Ecom Document | `part(MembershipsSubPage; ...)` + PBT (§§4.10.1–4.10.3) | `BuildMembershipTempBufferForDoc` |
| Document-level page action `action(Memberships)` | `EcomSalesDocument.Page.al:477-490` calls `EcomCreateMMShipProcess.ShowRelatedMembershipsAction(Rec)` (Header overload) | `BuildMembershipTempBufferForDoc` (via the rewritten body in §4.7) |
| Line-level `OnAssistEdit` on `Virtual Item Process Status` | `EcomSalesDocSub.Page.al:140-150` case-block calls `EcomCreateMMShipProcess.ShowRelatedMembershipsAction(Rec)` (Line overload) | `BuildMembershipTempBufferForLine` (via the rewritten body in §4.7) |

Single source of truth: all three are driven by the link-table walk in `BuildMembershipTempBuffer` (private, with the optional line filter). Because memberships don't archive across tables, the builder produces a homogeneous result set — no `[Archived]` prefixing, no row-style discrimination, no archive-aware lookup needed. That is the simplification over vouchers: one query path, one render path, end-to-end.

`EcomCreateMMShipProcess.ShowRelatedMembershipsAction(...)` is the existing thin public wrapper that already delegates to `EcomCreateMMShipImpl.ShowRelatedMembershipsAction(...)`. No new public surface, no new objects on the page side beyond the subpage.

### 4.11 Quantity immutability guard — dropped

Earlier revs (rev 2 onward, originally codex's rev-1 finding #3) proposed extending the voucher PR's `OnValidate` on `EcomSalesLine."Quantity"` to also check membership link rows — defense in depth against direct-AL mutation paths manufacturing the §4.4 hard-error states.

**Removed per PR 9975 reviewer feedback (2026-05-XX).** Reviewers of the voucher PR asked to drop the table-level immutability guard for vouchers; the membership counterpart follows the same direction by symmetry. Rationale (paraphrased from the voucher review):
- The standard ecom pages are largely read-only at the page level (`Editable = false`); the realistic mutation surface is much smaller than the guard implied.
- Adding a table-level `OnValidate` puts a cost on every `Quantity` write, including internal/test code paths that aren't the actual threat.
- The hard-error branches in `CreateMembership` / `ProcessMembershipAlteration` already catch the corruption states the guard was protecting against — at a point where Sentry capture and proper diagnostics are wired up.

No edits to `EcomSalesLine.Table.al` in this PR. The corruption states are still detected — just at processing time instead of mutation time — and the loss is one layer of defense against a low-probability surface, not actual correctness.

### 4.12 Community policy compatibility for qty>1 + identity-bearing lines

**The problem (surfaced during Milena's Job Queue test pass, 2026-05-20).** Multi-qty Create depends on the community's `NPR MM Member Community."Create Member UI Violation"` field (OptionMembers: `Error / Confirm / Reuse / Merge`) to absorb the unique-identity match that arises on iterations 2..N when the line carries shared identity fields (e.g. Tivoli's "Aktivares" pattern — one shared email across all N memberships).

Trace through `MMMembershipMgtInternal.CheckMemberUniqueId` (`:1496-1567`) on iteration 2 when iteration 1 just inserted a Member with the same identity:

| Policy | UI session (`GuiAllowed() = true`) | Non-UI (Job Queue / direct API) (`GuiAllowed() = false`) |
|---|---|---|
| `Error` | RaiseError immediately ("Already in use") | RaiseError immediately |
| `Confirm` | UI prompt; if accept → silent reuse | Silent reuse (sets `AcceptDuplicate := true`, exits 0) |
| `Reuse` | Silent reuse | Silent reuse |
| `Merge` | Skips merge logic (UI handles separately); falls through to existing-member return | Requires `MemberInfoCapture.AllowMergeOnConflict = true`; raises `ALLOW_MEMBER_MERGE_NOT_SET` (-127008) otherwise |

So `Merge` is the silently-inconsistent case: works when an operator clicks "Process Virtual Item" on the BC client; fails when processing runs through the Job Queue or direct API endpoint.

#### 4.12.1 Change A — set `AllowMergeOnConflict` in `IssueSingleMembership`

After `UpdateMemberInfoCaptureFromLine` / `SetNotificationMethod` in `EcomCreateMMShipImpl.IssueSingleMembership`, before `MemberInfoCapture.Modify()`, add:

```al
MemberInfoCapture.AllowMergeOnConflict := true;
```

In this codepath `MemberInfoCapture."Member Entry No"` is never set (not by `Init()`, not by `UpdateMemberInfoCaptureFromLine`, not by `SetNotificationMethod`). So `Member.Get(MemberInfoCapture."Member Entry No")` at `MMMembershipMgtInternal.Codeunit.al:1551` returns false → `MergeMemberUniqueId` is never called → conflict resolution falls through to `exit(Member."Entry No.")` (returns the existing Member's Entry No., new Membership links to it).

**Side-effect to flag (per codex rev-11 review).** After CheckMemberUniqueId returns a non-zero Entry No., `AddNamedMember` calls `SetMemberFields` and `Member.Modify()` on the reused Member (`MMMembershipMgtInternal.al:371, :5402`). So iteration N's payload **overwrites** the existing Member's fields (name/email/phone/etc). This matches today's UI behavior under `Create Member UI Violation = Merge` — clicking Process Virtual Item against a Merge community produces the same writeback. We are unifying UI and non-UI behavior, not introducing a new write.

#### 4.12.2 Change B — defensive validator in `ValidateMembershipRequestForDirectCreation`

With Change A live, only `Error` policy still hard-fails — but it fails cryptically mid-loop on iteration 2. Catch that case upfront in the validator with a clear message, gated on whether the line's identity fields would actually trigger a uniqueness lookup under the community's current mode:

```al
QtyMultiNeedsPermissiveCommunityErr: Label
    'Multi-quantity membership lines with identity fields require community ''%1'' to be configured with %2 ≠ Error. Use Reuse, Merge, or Confirm.',
    Comment = '%1 = Community Code; %2 = field caption';
...
if (EcomSalesLine.Quantity > 1) then begin
    Community.Get(MembershipSetup."Community Code");
    if LineCouldTriggerUniquenessConflict(EcomSalesLine, Community)
       and (Community."Create Member UI Violation" = Community."Create Member UI Violation"::Error)
    then
        Error(QtyMultiNeedsPermissiveCommunityErr,
              Community.Code,
              Community.FieldCaption("Create Member UI Violation"));
end;
```

The helper reads the community's actual `Member Unique Identity` mode and only signals a real risk when the line provides the fields that mode would require:

```al
local procedure LineCouldTriggerUniquenessConflict(EcomSalesLine: Record "NPR Ecom Sales Line"; Community: Record "NPR MM Member Community"): Boolean
begin
    case Community."Member Unique Identity" of
        Community."Member Unique Identity"::NONE:
            exit(false);
        Community."Member Unique Identity"::EMAIL:
            exit(EcomSalesLine."Member Email" <> '');
        Community."Member Unique Identity"::PHONENO:
            exit(EcomSalesLine."Member Phone No." <> '');
        Community."Member Unique Identity"::SSN:
            exit(false);   // not exposed via ecom payload
        Community."Member Unique Identity"::EMAIL_AND_PHONE:
            exit((EcomSalesLine."Member Email" <> '') and (EcomSalesLine."Member Phone No." <> ''));
        Community."Member Unique Identity"::EMAIL_OR_PHONE:
            exit((EcomSalesLine."Member Email" <> '') or (EcomSalesLine."Member Phone No." <> ''));
        Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME:
            exit((EcomSalesLine."Member Email" <> '') and (EcomSalesLine."Member First Name" <> ''));
    end;
end;
```

Avoids false positives like `EMAIL_AND_PHONE` community + only Email populated, where the line would already error in production with the truthful `RequireFieldAndField` message ("Both X and Y are required") from iteration 1 — not "Already in use". In that case the validator gate skips and the line falls through to that more accurate error.

#### 4.12.3 What this does not fix (acknowledged limits)

- **Spec's pure info-less qty>1 scenario** (no member info at all) only works on communities configured with `Member Unique Identity = NONE`. For any other mode, `SetMemberUniqueIdFilter` errors at iteration 1 with `RequireField` because the required identity column is empty. That constraint comes from `MMMembershipMgtInternal`, not from this PR. The Fern follow-up (§9) is the right place to call out the community-config requirement for the API consumer.
- **`Member Logon Credentials ≠ NA` interaction with `LogonIdExists`** (codex rev-11 finding). When Logon Credentials is enabled and the community-policy fallthrough silently reuses an existing Member, subsequent `CreateMemberRole` invocations can still fail downstream in `LogonIdExists` (`MMMembershipMgtInternal:5617, 6127`). Tivoli's communities have Logon Credentials = NA, so the issue isn't on the live path today. Not addressed in this PR — left to surface naturally if a customer ever hits it.

## 5. Data flow

```
ecom doc API → fastLine membership line, qty=N, Membership Operation = CreateMembership
                 │
                 ▼
EcomCreateMMShipImpl.CreateMembership
   ├── Branch 1: link-count guard (race recovery — same pattern as CORE-209 §6)
   │     ├── = QtyToIssue → no-op exit
   │     ├── > QtyToIssue → error (corruption)
   │     └── 0 < count < QtyToIssue → error (invariant break)
   ├── for i in 1..N:
   │     ├── init MemberInfoCapture from line
   │     ├── MembershipManagement.CreateMembershipAll → MM Membership i
   │     ├── insert NPR Ecom Sales Membership Link row i (last DB op)
   │     └── delete MemberInfoCapture
   └── if qty=1: writeback (EcomSalesLine."Membership Id" := Membership.SystemId).
       if qty>1: leave EcomSalesLine."Membership Id" blank. Link table is the source of truth.
                 │
                 ▼
ConfirmAllMembershipsForLine
   └── walk link table, ConfirmMembershipById for each (sets MembershipEntry.Document No. etc.)
                 │
                 ▼
   downstream (link-first, with legacy fallback to EcomSalesLine."Membership Id"):
   ├── ShowRelatedMembershipsAction (line & document level)    (UI)
   └── EcomDocSubpagesTask.BuildMembershipsPayload             (Memberships subpage — PBT child session)
   (GET response createdMemberships array — deferred to follow-up PR per §4.6)
```

## 6. Error handling, retries, idempotency

Reuse the design from CORE-209 §6 with two simplifications:

- **No archive race.** Memberships don't archive across tables, so no `OnAfterArchiveVoucher`-equivalent subscriber and no SystemId-preservation contract to maintain.
- **No top-up case.** Memberships have no analog of voucher top-up; all multi-qty membership lines are pure issuance.

The relevant pieces from §6 of the voucher design that apply here unchanged:

- **Why the link-count guard is necessary.** Same `Codeunit.Run` semantics — `EcomCreateMMShipProcess.OnRun` commits the inner run before the outer `HandleResponse` flips the line to `Processed`. Other entry points (`EcomVirtualItemMgt` dispatcher, the membership JQ if one exists, manual page actions, API preprocess) target blank-status lines. Without the count-first guard, a concurrent re-entry during that window would issue duplicate memberships. Verify the analog membership JQ exists in the codebase at implementation time (`grep -r "EcomCreateMembership.*JQ\|EcomCreateMMShip.*JQ"`); if it does, it is part of the same race surface.
- **Sequencing invariant.** `InsertMembershipLink` is the last DB op inside `IssueSingleMembership`. Add a code comment referencing this invariant.
- **`CheckIfLineCanBeProcessed` blocks re-processing.** Existing `:143-144` errors when the line is already `Processed`. Handles the post-`HandleResponse` retry case.
- **Sentry capture.** Both link-count guard errors (`LinkCountExceedsQtyErr`, `PartialLinkStateErr`) use "This is a programming bug" suffix and trigger `Sentry.AddLastErrorIfProgrammingBug()` called in `EcomCreateMMShipProcess.OnRun` between `Run` and `HandleResponse` — same shape as voucher design §6.

User-visible errors (operation/quantity validators) stay as translated `Label`s.

- **`MM Member Info Capture` cleanup on rollback.** Each `IssueSingleMembership` inserts a `MemberInfoCapture` row and deletes it at the end. If `CreateMembershipAll` errors out mid-call, the `MemberInfoCapture` insert rolls back along with the inner `Codeunit.Run` transaction — same behavior as today. No leakage.

## 7. Testing strategy

Tests live in the separate `Test` app, alongside existing `EcomMembershipTests` (or whatever the current sibling file is — verify at implementation time and pick the conventional filename).

Reduced from 23 candidate tests in earlier revs to 10 load-bearing tests (rev 10 — pruned per Andrei's review). Cut: redundant rejection tests for sibling alteration operations, synthesized-corruption error-branch tests, event-gating tests covered by the broader race-recovery test, legacy-fallback / defensive UX tests, and the immutability-guard test (the guard itself was dropped — §4.11).

1. **Happy path qty = 1, CreateMembership** — single membership line → 1 Membership created, 1 link row, line carries `Membership Id`. Regression check for today's behavior on the existing qty=1 path.

2. **Happy path qty = 5, CreateMembership** — load-bearing test for the new multi-qty capability. 5 Memberships created, 5 link rows, line `Membership Id` blank.

3. **Quantity ingest validation** — parameterized:
   - `0`, `-1`, `2.5` rejected at API ingest.
   - `Quantity <> 1` rejected at `CheckIfLineCanBeProcessed` for non-Create operations.
   - `Quantity >= 1` (whole) accepted for Create.

4. **Non-Create operations reject qty > 1** — parameterized over Confirm / Renew / Extend / Upgrade payloads with qty=5. Each errors at its respective validator (`ValidateMembershipForToken` / `ValidateMembershipAlterationRequest`). One test procedure with four sub-cases.

5. **Race recovery for Create — no duplicate memberships, no events fired** — pre-populate the link table with `QtyToIssue` rows for a still-blank-status line; subscribe to `OnAfterMembershipCreatedBeforeCommit` and `OnAfterMembershipConfirmedBeforeCommit`; call `Process` again. Assert: exits cleanly with `IssuedAnyThisRound = false` and `DidConfirmAny = false`; no duplicate memberships issued; neither event fired. Combines what earlier revs called #10, #11e, #11f — the race-recovery happy path AND the event-gating correctness in one test.

6. **Accounting correctness — both columns sum to whole-line with rounding remainder absorbed by last** — parameterized over `Price Excl. VAT = true` AND `Price Excl. VAT = false`. The `ComputeWholeLineAmounts` helper (§4.5.2) has a distinct arithmetic branch for each pricing mode; both must be locked in.
   - **Sub-case A: `Price Excl. VAT = true`** — codex's case: `Line Amount = 10.01`, `VAT % = 25`, qty=3. Whole-line `Amount = 10.01` (authoritative), `Amount Incl VAT = Round(10.01 * 1.25, 0.01) = 12.51` (derived).
   - **Sub-case B: `Price Excl. VAT = false`** — symmetric case: `Line Amount = 12.51`, `VAT % = 25`, qty=3. Whole-line `Amount Incl VAT = 12.51` (authoritative), `Amount = Round(12.51 / 1.25, 0.01) = 10.01` (derived).
   - For each sub-case, assert all of:
     - Per-membership `Amount` values sum to whole-line `Amount` exactly.
     - Per-membership `Amount Incl VAT` values sum to whole-line `Amount Incl VAT` exactly.
     - The last membership (most-recently-inserted link row by `BySourceLine` order) carries the rounding remainder on both columns.
     - Replay the scenario from scratch; the same membership receives the remainder both times (deterministic ordering).
   Single comprehensive test that locks in the both-columns invariant, the explicit remainder rule, the deterministic ordering, and both pricing-mode branches in `ComputeWholeLineAmounts`. **Most important accounting-correctness test** (per codex rev-10 review).

7. **Confirm operation writes link row** — line with `Membership Operation = ConfirmMembership` + supplied `Membership Id` processed end-to-end. Assert: one `NPR Ecom Sales Membership Link` row pointing at the confirmed membership; `EcomSalesLine."Membership Id"` stays populated (ingest input); `OnAfterMembershipConfirmedBeforeCommit` fires once. Validates the wider-scope link-row decision (#20) for non-Create operations.

8. **Alteration operation writes link row + race recovery** — single Renew test (representative of the three alteration operations, which share `ProcessMembershipAlteration`):
   - First run: link row written, membership dates updated, `OnAfterMembershipRenewedBeforeCommit` fires.
   - Pre-populate a link row simulating the race window; second run: `ProcessMembershipAlteration` returns `false`, membership dates unchanged from first run, no event fires, no second link row inserted.

9. **`ShowRelatedMembershipsAction(EcomSalesLine)` — N>1 opens list** — qty=5 line; clicking the line-level AssistEdit opens the BC default list page for `NPR MM Membership` rendering the 5 rows.

10. **Three-surface coherence + subpage covers all 5 operations** — load-bearing integration test. One ecom doc with five lines covering all five operations (one CreateMembership qty=3, one ConfirmMembership, one RenewMembership, one ExtendMembership, one UpgradeMembership). After processing all lines:
    - **Subpage** (`BuildMembershipTempBufferForDoc` payload): shows 3 + 1 + 1 + 1 + 1 = 7 memberships.
    - **Document-level `action(Memberships)`** (`ShowRelatedMembershipsAction(EcomSalesHeader)`): same 7-row set.
    - **Per-line `OnAssistEdit`** (`BuildMembershipTempBufferForLine` per line): sum across the 5 lines = 7 disjoint rows.
    Asserts the three discovery surfaces stay coherent across all operation types — the user-experience promise that motivated the wider link-row scope (decision #20). Single test, multiple assertions.

11. **Defensive validator rejects qty>1 + identity-bearing line + Error policy** (§4.12.2) — community configured `Member Unique Identity = EMAIL`, `Create Member UI Violation = Error`; line carries `Member Email`. Submit qty=3 with `Membership Operation = CreateMembership`. Assert: `ValidateMembershipRequestForDirectCreation` errors with `QtyMultiNeedsPermissiveCommunityErr` referencing the community code and field caption. Locks in Change B (validator + mode-aware precise gate).

12. **qty>1 + Merge policy + identity-bearing line — all link to one Member** (§4.12.1) — community configured `Member Unique Identity = EMAIL`, `Create Member UI Violation = Merge`, `Member Logon Credentials = NA`. Submit qty=5 with `Member Email` set. Assert: 5 Memberships created, 5 link rows; walking each Membership's active non-anonymous `MembershipRole` rows yields **exactly one** distinct `Member Entry No.` shared across all 5 memberships. Exercises Change A (`AllowMergeOnConflict := true`) end-to-end in non-UI flow — the Job Queue regression Milena surfaced.

## 8. Backward compatibility — legacy ecom docs without link rows

Existing production ecom membership lines are all qty=1 and trace via `EcomSalesLine."Membership Id"` directly. Three approaches considered:

- **No backfill, fallback chain at every read site.** Each consumer (Show Related, subpage, GET response) tries the link table first; if empty, falls back to the `Membership Id` write-back. Chosen approach — same as the voucher design §8.
- **Lazy backfill on first read.** Race conditions. Rejected.
- **Eager backfill via upgrade codeunit.** Cleanest end-state but overkill for a field that already works as a fallback.

For this PR, the GET response shape doesn't change at all — `AddCreatedMembershipsArray` is deferred (§4.6) and the existing `membershipId` property keeps its current behavior. So there's no GET-response back-compat surface to reason about. If/when the follow-up PR ships `createdMemberships`, that PR will inherit the same legacy-qty=1 asymmetry the voucher counterpart has and document the consumer contract then.

## 9. Out of scope

- Membership-archive lifecycle subscriber (no archive table exists for `MM Membership`).
- POS / back-office workflow for attaching members to memberships created without member info. Already exists, independent of this change.
- Digital-notification manifest changes. Memberships are not emitted as manifest assets through `ProcessMemberCardAssets` for ecom-doc sources — confirmed with Milena 2026-05-15. If a future feature adds membership/member-card emission to the ecom-doc notification manifest, a follow-up PR can either add a `Membership Ledger Entry No.` to the link table or resolve the specific ledger entry at read time.
- Deprecation of `EcomSalesLine."Membership Id"` field (per the legacy TODO at `EcomCreateMMShipImpl.al:211-213`). Field stays as the qty=1 writeback target and as the legacy-fallback resolver.
- Fern documentation update — separate PR in `navipartner/documentation`. Spec needs:
  - `quantity` description on membership lines: "≥ 1 when membership operation is *create*; must be 1 otherwise."
  - Note on `membershipId` field: "When quantity > 1 on a create-membership line, this is empty; use the Memberships subpage on the Ecom Document to discover the N issued memberships."
  - The `createdMemberships` array is **not** part of this PR's Fern update — it ships when `AddCreatedMembershipsArray` is enabled in a follow-up PR (see §4.6).
- **PR description / release notes must explicitly call out the API-contract limitation:** for qty>1 create-membership lines, `membershipId` in the GET response stays blank and there is **no response-only public API discovery path** for the N issued memberships until the follow-up PR enables `AddCreatedMembershipsArray`. External API callers handling multi-qty membership creation in this window need either (a) to read the BC UI Memberships subpage, or (b) to wait for the follow-up PR. (Per codex rev-8 review — strict capability improvement vs. today's outright rejection, but worth signposting so consumers don't assume self-describing responses.)

## 10. Decisions made

1. **Multi-qty only for `CreateMembership`.** Per Milena's comment on CORE-208. Confirm / Renew / Extend / Upgrade keep `Quantity = 1` because each references an existing `Membership Id`. (§§1, 2, 4.2.)
2. **New link table — single-field design.** Earlier drafts copied the voucher link's denorm pattern (`Membership Entry No.` + `External Membership No.`); revised after Andrei's review to keep only `Membership System Id` because (a) memberships don't archive/renumber, so the voucher denorm rationale doesn't carry over; (b) the subpage path already does `Membership.GetBySystemId` per row, so the denorm fields were never read there; (c) the only path that benefits is `AddCreatedMembershipsArray` and the cost is N sub-millisecond PK-equivalent lookups (typical N=1-5). The link table is now `(Entry No., Source System Id, Source Line System Id, Membership System Id)` — four fields, single source of truth on `MM Membership`. (§3.1.)
3. **No archive state enum.** Memberships don't archive across tables, so there's no SystemId-preservation contract to maintain. (§3.2.)
4. **Member-info-capture data applies uniformly across all N memberships** in a multi-qty create. The same email / phone / name / birthday is written into each. Per Milena, webshops doing multi-qty memberships typically send empty member info, and the POS/back-office attaches members later — but if they DO send info, we don't deduplicate or reject. (§2 non-goals, test #19.)
5. **qty=1 vs qty>1 writeback to `EcomSalesLine."Membership Id"`** — qty=1 keeps writeback (back-compat for existing `membershipId` GET property); qty>1 leaves blank. (§4.4.)
6. **GET response shape unchanged in this PR.** Existing `membershipId` property keeps its current behavior (populated for qty=1, blank for qty>1). The new `createdMemberships` array (designed earlier in rev 1-5) is **not** shipped in CORE-208 — voucher counterpart was disabled in PR 9975 pending API-team alignment, and memberships will follow that resolution in a separate follow-up PR. No edits to `EcomSalesDocApiAgentV2.Codeunit.al` in this PR. (§4.6.)
7. **`ShowRelatedMembershipsAction` line-level UX.** N=0 → "No memberships" message; N=1 → Membership Card directly; N>1 → BC default `NPR MM Membership` list page via `Page.Run(0, ...)`. No new lookup page object needed (memberships have a usable list page already). (§4.7.)
8. **Memberships subpage on `EcomSalesDocument` page** — added, hooking into the existing PBT plumbing introduced for vouchers in CORE-209. The page already carries commented placeholders for this addition (`PopulateMembershipsSubpage`, `MembershipsSubPage.Page.ClearContents()`); we fill them in. Three surfaces (subpage, document-level `action(Memberships)`, line-level `OnAssistEdit` on `Virtual Item Process Status`) all resolve through the shared `BuildMembershipTempBufferFor{Doc,Line}` builder — single source of truth. Because memberships don't archive, no row-style / `[Archived]` complication is needed; the rendering is one homogeneous list. The page action body and the AssistEdit case-block body do not change byte-for-byte — they already call `EcomCreateMMShipProcess.ShowRelatedMembershipsAction(...)`, and we only rewrite the internal procedure body. (§§4.7, 4.10.)
9. ~~Notification manifest uses link table for ecom branch only.~~ **Superseded by decision #21 (rev 6)** — notification manifest is out of scope entirely; memberships are not emitted through it for ecom-doc sources. See §§4.8, 9.
10. **Race-recovery guard and sequencing invariant** identical in shape to voucher design (CORE-209 §§4.2, 6). Both errors use "This is a programming bug" suffix and trigger Sentry capture in `EcomCreateMMShipProcess.OnRun`. (§§4.4, 6.)
11. **Member-Info-Capture lifecycle unchanged.** Each iteration of the issuance loop inserts and then deletes its own MemberInfoCapture row. Rollback semantics are unchanged. (§§4.4, 6.)
12. **Event firing granularity.** `OnAfterMembershipCreatedBeforeCommit` / `OnAfterMembershipConfirmedBeforeCommit` fire once per line (today's behavior), not once per membership. Subscribers needing per-membership granularity walk the link table. (§4.5.)
13. **Per-membership amount allocation (rev 2 — codex review pass 1, finding #1).** `ConfirmMembership`'s body writes `MembershipEntry.Amount` / `"Amount Incl VAT"` from `EcomSalesLine."Line Amount"`. For qty=1 the line total *is* the membership's price; for qty>1, naively looping that body would write the full line total into each of the N entries (codex finding: financial corruption — qty=5 at €50 would record €250 of revenue). Initial fix: pre-compute `PerMembershipShare = Round(LineAmount / Quantity, 0.01)`, pass per-share into the new `ConfirmMembershipById`, last membership absorbs the rounding remainder so `sum = LineAmount` exactly. (§4.5.1.)
14. ~~Notification helper takes `MM Membership Entry`, not `MM Membership` (rev 2 — codex review pass 1, finding #2).~~ **Superseded by decision #21 (rev 6)** — notification manifest work removed from PR scope. The rev-2 finding was correct at the time but moot now: there's no `ProcessMemberCardAssets` refactor in this PR. See §4.8.
15. ~~Quantity immutability guard extended (rev 2 — codex review pass 1, finding #3).~~ **Superseded (rev 8+ — PR 9975 reviewer feedback)** — voucher PR reviewers asked to drop the table-level `Quantity` `OnValidate` guard; the membership analog follows the same direction. No edits to `EcomSalesLine.Table.al` in this PR. Corruption states are still detected at processing time (Sentry-captured hard errors in CreateMembership / ProcessMembershipAlteration). See §4.11.
16. **Both-columns-split for the per-membership amount (rev 3 — codex review pass 2, finding #1).** The rev-2 algorithm split only `LineAmount` and derived the secondary column (`Amount Incl VAT` when `Price Excl. VAT = true`, or `Amount` when false) per-membership via `Round(share × (1 + VAT/100), 0.01)`. With `LineAmount = 10.01`, `VAT = 25%`, qty=3, each membership's derived Incl. VAT was `4.18 / 4.18 / 4.16 = 12.52`, but the whole-line `Round(10.01 × 1.25, 0.01) = 12.51` — one-cent drift on the derived side. Fix: compute **both** whole-line totals once, split **both** columns independently with last-row remainder absorption. The new `ConfirmMembershipById` and `ApplyAmountsToEntry` signatures accept both pre-computed amounts; the secondary column is no longer derived per-membership. (§§4.5.1, 4.5.2.)
17. **Deterministic iteration order for "last absorbs remainder" (rev 3 — codex review pass 2, finding #2).** The rev-2 link table's `BySourceLine` key was `("Source Line System Id")` alone — AL's `FindSet()` does not guarantee insertion-order traversal when key columns tie. "Last absorbs remainder" was therefore picking a non-deterministic membership. Fix: add `"Entry No."` to the key — `BySourceLine; "Source Line System Id", "Entry No."`. FindSet now returns rows in insertion order; the "last" row is reliably the most-recently-inserted link row. (§3.1.)
18. **Event firing gated on actual work this round (rev 3 — codex review pass 2, finding #3).** `CreateMembership` and `ConfirmAllMembershipsForLine` now return booleans indicating whether they actually issued / confirmed anything this session. `OnAfterMembershipCreatedBeforeCommit` and `OnAfterMembershipConfirmedBeforeCommit` are gated on those returns in the `Process` branch, so race-recovery (where both calls no-op) doesn't fire events for work that wasn't performed. Closes the leak-to-external-subscribers concern without restructuring the event contract. (§§4.4, 4.5.3.)
19. **Shared `ComputeWholeLineAmounts` helper + trimmed `ConfirmMembershipById` signature (rev 4 — codex review pass 3, low-severity cleanup).** The whole-line totals computation lived in two places (the qty>1 bulk path and the qty=1 standalone shell) — duplicated load-bearing accounting math. Extracted into a single private helper used at both boundaries. Also removed `EcomSalesLine` from `ConfirmMembershipById`'s parameter list — the refactored body uses only the membership id, pre-computed amounts, and the header. Trimming the unused parameter narrows the helper's dependency contract to what it actually needs. (§4.5.2.) **Partially reversed in rev 5 (decision #20)** — `EcomSalesLine` is needed again for the link-write call site.
20. **Link rows written for all 5 operations, not just Create (rev 5 — Andrei + Milena decision).** Following the voucher precedent (`EcomCreateVchrImpl.IssueOrTopUpSingleVoucher:174` unconditionally inserts a voucher link row for both new issuance and top-up of existing vouchers), the membership link table is populated for every processed membership line — Create, Confirm, Renew, Extend, and Upgrade. Single source of truth for "what memberships did this ecom doc touch"; subpage / `action(Memberships)` / line `OnAssistEdit` all read the same set. `EcomSalesLine."Membership Id"` stays populated for qty=1 cases (back-compat + legacy fallback resolver for pre-CORE-208 docs) but is no longer the source of truth — the link table is. No upgrade codeunit (matches voucher precedent §8); legacy fallback chain at consumer sites handles pre-CORE-208 data, rolls off naturally. (§§4.5.2 link-insert dedup, 4.5.3 alteration path link-write + race-recovery, 4.5.4 event gating across all 5 operations, §7 tests #7, #8, #10.)
21. **Notification manifest is out of scope (rev 6 — Andrei + Milena clarification).** Codex review of the rev-5 wider-scope design flagged that storing the Membership PK on the link row was ambiguous when one doc touches the same membership across multiple lines — `ProcessMemberCardAssets`'s `FindLast` resolver can't tell which `MM Membership Entry` belongs to which line. **The clarification: memberships are not emitted through the digital-notification manifest at all for ecom-doc sources.** §4.8 stripped down to a "not affected" note; no `DigitalOrderNotifMgt` or `DigitalDocLineBuffer` edits in this PR. (Decision #24 later simplified the schema further — the link row now stores only `Membership System Id` as the join key.) If a future feature needs ledger-entry precision, a `Membership Ledger Entry No.` field can be added then. (§§3.1 rationale, 4.8.)
22. **Process body ordering — original order preserved + handler-layer backstops (rev 12 — Milena's review pass, 2026-05-21).** Earlier rev 6 reordered `Process` (resolve operation → write back → validate) to support an operation-conditional quantity gate inside `CheckIfLineCanBeProcessed`. Reviewer pushback: don't design around stale `Membership Operation`; avoid the `MembershipAlterationSetup.GetBySystemId` lookup on validation-failing alteration lines. Walked back. Original order kept (validate → lock → resolve operation). Removed the operation-conditional gate from `CheckIfLineCanBeProcessed`. Added `if Quantity <> 1 then Error(QuantityErr);` as the first statement of `ConfirmMembership` and `ProcessMembershipAlteration` — these runtime handlers previously had no qty=1 check (the existing assertions in `ValidateMembershipForToken` / `ValidateMembershipAlterationRequest` only run at API ingest). Net: the silent-corruption vector (stale stored Op = Create + actual Op = Confirm + qty=5 → one membership entry receiving the full line amount, no error raised) is closed at the handler layer regardless of upstream gate state. (§4.3.)
23. **Alteration race-recovery uses case-analysis, not bare `> 0` (rev 6 — codex review).** `ProcessMembershipAlteration` had `if CountExistingLinks > 0 then exit(false)` which silently treated all pre-existing link states as success — masking corruption (link row for a different membership, or count >1). Replaced with Create's case-analysis shape: 0 → proceed, 1+matching-membership → race recovery, 1+different-membership → error, >1 → error. Both error labels use "This is a programming bug" suffix → Sentry capture. (§4.5.3.)
24. **Link table simplified to single join key (rev 7 — Andrei's review).** Dropped fields 5 (`Membership Entry No.`) and 6 (`External Membership No.`) from §3.1. The voucher denorm pattern was copied initially but doesn't apply: vouchers archive/renumber so the denorm captures live-at-issuance values; memberships have no archive lifecycle. The only consumer that benefits from denorm is `AddCreatedMembershipsArray`, which now does `Membership.GetBySystemId` per row — N sub-millisecond PK-equivalent lookups for typical N=1-5. The subpage builder already does `GetBySystemId` anyway. Net: simpler schema, single source of truth on `MM Membership`, no risk of stale denormed data on link rows whose membership was deleted. (§3.1.)

25. **`AllowMergeOnConflict := true` in `IssueSingleMembership` for Merge-policy community support (rev 11 — Milena's Job Queue test pass, 2026-05-20).** The qty>1 spec scenario silently broke in production for communities configured with `Create Member UI Violation = Merge`: `MMMembershipMgtInternal.CheckMemberUniqueId` (`:1545-1553`) requires the caller to opt in via `MemberInfoCapture.AllowMergeOnConflict = true` in non-UI context (`GuiAllowed = false`). When clicking "Process Virtual Item" manually in BC the gate is bypassed (UI branch); processing via Job Queue or direct API raises `ALLOW_MEMBER_MERGE_NOT_SET` (-127008). We set the flag unconditionally. In our codepath `MemberInfoCapture."Member Entry No"` is never set, so `Member.Get(0)` at `CheckMemberUniqueId:1551` returns false and `MergeMemberUniqueId` is never actually called — the flag's only effect is bypassing the `ALLOW_MEMBER_MERGE_NOT_SET` raise and letting conflict resolution fall through to `exit(Member."Entry No.")`. The reused-member writeback via `SetMemberFields` matches the existing UI path — we are unifying UI and non-UI behavior, not introducing a new write. (§4.12.1.)

26. **Defensive validator in `ValidateMembershipRequestForDirectCreation` — qty>1 + identity-bearing line + `Error` policy → reject upfront, mode-aware (rev 11 — codex rev-11 + Andrei's precise-gate refinement, 2026-05-20).** Catches the only remaining hard-fail case (`Create Member UI Violation = Error`) at the validator boundary with an actionable message instead of the cryptic "Already in use" raised mid-loop on iteration 2. The validator is community-mode-aware via the new `LineCouldTriggerUniquenessConflict` helper — only fires when the line provides enough identity to actually trigger a uniqueness lookup under the community's current `Member Unique Identity` mode. Avoids false positives like `EMAIL_AND_PHONE` community + only Email populated (where the line would error anyway with `RequireFieldAndField` from iteration 1, not "Already in use"). (§4.12.2.)

## 11. Files touched (preview)

- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipImpl.Codeunit.al` — issuance loop, link writes, quantity guards, ShowRelated rewrite, shared `BuildMembershipTempBufferFor{Doc,Line}` + `OpenMembershipCardForSystemId`, Confirm-all-after-Create with per-membership amount split + new `ConfirmMembershipById` / `ApplyAmountsToEntry` (§§4.2-4.5, 4.7)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipProcess.Codeunit.al` — add `Sentry.AddLastErrorIfProgrammingBug()` between `Run` and `HandleResponse` (§6)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomSalesMembershipLink.Table.al` — **new** (§3.1)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomMembershipSub.Page.al` — **new** (§4.10.1)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/EcomDocSubpagesTask.Codeunit.al` — add `BuildMembershipsPayload` and `MembershipsResultKeyTok` (§4.10.2)
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al` — add `part(MembershipsSubPage; ...)`, fill in the commented `PopulateMembershipsSubpage` + `ClearContents` hooks (§4.10.3). **No change** to `action(Memberships)` body at `:477-490` — entry point preserved.
- `src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocSub.Page.al` — **no change** to `Virtual Item Process Status` `OnAssistEdit` body at `:140-150`. Entry point preserved.
- (Test app) new tests covering items 1-19 in §7 + subpage / three-surface coherence tests added in plan Task 12
- (External) `navipartner/documentation` Fern spec — `quantity` semantics on membership lines + `membershipId` deprecation note for qty>1 (separate PR). `createdMemberships` array Fern updates are part of the deferred follow-up PR per §4.6, NOT this one.

**Files explicitly NOT touched:**
- Anything under `_API_SERVICES/.../Voucher/` — separate concern.
- `EcomSalesDocImplV2.Codeunit.al` — memberships have no special SalesLine branch today; the default Item path already supports `Quantity = N` correctly.
- `MM Membership Mgt. Internal` and `CreateMembershipAll` — called N times in the loop, unchanged internally.
- `EcomSalesLine."Membership Id"` field — kept for qty=1 writeback and legacy fallback; deprecating it is a separate future change.
