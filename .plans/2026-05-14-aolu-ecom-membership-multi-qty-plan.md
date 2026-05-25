# Ecom Membership Multi-Quantity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow ecom membership lines to be processed with `Quantity > 1` for the **Create Membership** operation only (CORE-208). Confirm / Renew / Extend / Upgrade keep `Quantity = 1`.

**Architecture:** Introduces a new `NPR Ecom Sales Membership Link` table that durably links ecom-line ↔ membership. The membership-issuance loop issues N memberships per line, inserts N link rows, and (only when `Quantity = 1`) writes the membership SystemId back onto `EcomSalesLine."Membership Id"` for back-compat. In-scope downstream consumers (`ShowRelatedMembershipsAction` line + document level, the Memberships subpage, `ConfirmAllMembershipsForLine`) read link rows first with legacy fallback to the writeback field. **Out of scope for this PR**: the GET response `createdMemberships` array (deferred to a follow-up PR per design §4.6 — voucher counterpart was disabled in PR 9975 pending API-team alignment) and the digital-notification manifest (memberships are not emitted via `ProcessMemberCardAssets` for ecom-doc sources — confirmed with Milena, design §4.8). No archive lifecycle subscriber — memberships don't archive across tables the way vouchers do.

A **Memberships subpage** is added to `EcomSalesDocument.Page.al`, hooking into the existing shared Page Background Task plumbing (`NPR Ecom Doc Subpages Task`) introduced for vouchers in commit `b9b8826ace`. Three discovery surfaces (subpage, document-level `action(Memberships)`, line-level `OnAssistEdit` on `Virtual Item Process Status`) all resolve through the same `BuildMembershipTempBufferFor{Doc,Line}` builder — single source of truth. Page-action and AssistEdit call sites stay byte-for-byte identical; only the underlying procedure body is rewritten.

**Tech Stack:** Business Central AL (BC17+ guarded via `#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22` — the Membership module already follows that gate, see `EcomCreateMMShipImpl.Codeunit.al:1`), npcore Application/Test apps, `bcdev` skill for compile/publish/test, `al-id-manager` skill for object/field IDs.

**Reference:** [Spec rev 1](2026-05-14-aolu-ecom-membership-multi-qty-design.md) — read it. Each task below points at specific spec sections for code bodies. The plan does not duplicate code that's already in the spec. Also reference the voucher design (`2026-05-06-aolu-ecom-voucher-multi-qty-design.md`) where the membership plan reuses identical patterns (race-recovery guard, Sentry capture, sequencing invariant).

**File structure (new objects + edits):**

| File | Status | Purpose |
|---|---|---|
| `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomSalesMembershipLink.Table.al` | **new** | Durable ecom-line ↔ membership link |
| `.../_fastLine/virtualItems/Membership/EcomMembershipSub.Page.al` | **new** | ListPart subpage on Ecom Document — PBT-fed |
| `.../_fastLine/virtualItems/Membership/EcomCreateMMShipImpl.Codeunit.al` | edit | issuance loop, link writes, quantity guards, ShowRelated rewrite, shared `BuildMembershipTempBufferFor{Doc,Line}` + `OpenMembershipCardForSystemId`, Confirm-all-after-Create |
| `.../_fastLine/virtualItems/Membership/EcomCreateMMShipProcess.Codeunit.al` | edit | Sentry capture between Run and HandleResponse |
| `.../_fastLine/virtualItems/EcomDocSubpagesTask.Codeunit.al` | edit | add `BuildMembershipsPayload` + `MembershipsResultKeyTok` |
| `.../_public/EcomSalesDocument.Page.al` | edit | add `part(MembershipsSubPage; ...)` + fill commented `PopulateMembershipsSubpage` + `ClearAllSubpages` hooks. **No** change to `action(Memberships)` body at `:477-490`. |
| `.../_public/EcomSalesDocSub.Page.al` | **no edit** | `Virtual Item Process Status` `OnAssistEdit` body at `:140-150` already calls `ShowRelatedMembershipsAction(Rec)` — entry point preserved. |
| `Test/src/Tests/ECommerce/FastLane/EcomMembershipMultiQtyTests.Codeunit.al` | **new** | 10 load-bearing tests from spec §7 (pruned from 23 candidates in earlier revs) |

---

## Task 1: Acquire AL IDs and verify prerequisites

**Files:**
- Reference only — no code changes yet

- [ ] **Step 1: Confirm CORE-209 (voucher multi-qty) is merged**

The membership work reuses one artifact from CORE-209: the Sentry-between-Run-and-HandleResponse pattern in `EcomCreateVchrProcess.OnRun`.

(Memberships do NOT use the digital-notification manifest path, so the `Source Line System Id` field on `NPR Digital Doc. Line Buffer` is not a dependency for this PR — confirmed with Milena 2026-05-15.)

Check `git log --oneline master | head -20` for CORE-209 / "voucher multi-qty" commits. If not merged yet:
- Either rebase this work on top, OR
- Re-implement the same pattern locally in `EcomCreateMMShipProcess.OnRun`.

Record the decision inline below this checkbox.

- [ ] **Step 2: Look up app.json ranges**

Per CLAUDE.md memory: `[6014400-6014699, 6059767-6060166, 6150613-6151612, 6184471-6185130, 6248181-6249170]`. New table targets the `_API_SERVICES/ecommerce/...` range (around 6248xxx, alongside `EcomSalesVoucherLink.Table.al:6248xxx`).

- [ ] **Step 3: Use al-id-manager skill to fetch new object IDs**

Invoke `al-id-manager:get-next-id` for:
- 1× Table — `NPR Ecom Sales Membership Link`
- 1× ListPart Page — `NPR Ecom Membership Sub`

Record the returned IDs in this plan inline as you go (replace `60xxxxx` placeholders below with the actual). No new enum is needed (no archive-state enum), no new lookup page (`ShowRelatedMembershipsAction` reuses `NPR MM Membership Card` for N=1 and the default `NPR MM Membership` list page for N>1).

- [ ] **Step 4: Verify the existing membership JQ exists**

Grep: `Grep "EcomCreateMembership.*JQ|EcomCreateMMShip.*JQ" src/_API_SERVICES/ecommerce`. If a membership JQ exists, it is part of the race surface described in spec §6 / the voucher design §6. If it doesn't, the spec section about "dispatcher / JQ / manual / API preprocess all target blank-status lines" still applies through the other three paths. Either way, no new code in the JQ — it already calls `Process` and is correct.

- [ ] **Step 5: Verify the test app structure**

Confirm whether `Test/src/Tests/ECommerce/FastLane/` has an existing `EcomMembership*` test file. If so, plan to extend it (Task 11). If not, the new file lands alongside sibling test codeunits (`EcomVoucherTests.Codeunit.al`, `EcomCouponTests.Codeunit.al`, `EcomWalletTests.Codeunit.al`).

- [ ] **Step 6: Baseline compile**

`bcdev compile -suppressWarnings` on the current branch. Expected: success.

No commit yet.

---

## Task 2: Create the membership link table

**Files:**
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomSalesMembershipLink.Table.al`

- [ ] **Step 1: Write the table**

Use the schema from spec §3.1 verbatim — 4 fields (Entry No., Source System Id, Source Line System Id, Membership System Id) and 3 keys (PK, BySource, BySourceLine). All other Membership fields are resolved at read time via `Membership.GetBySystemId(...)` — no denormalization (rev 7, per Andrei's review against the voucher precedent).

```al
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6248182 "NPR Ecom Sales Membership Link"
{
    Access = Internal;
    Caption = 'Ecom Sales Membership Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)               { AutoIncrement = true; Caption = 'Entry No.'; }
        field(2; "Source System Id"; Guid)           { Caption = 'Source System Id'; DataClassification = CustomerContent; }
        field(3; "Source Line System Id"; Guid)      { Caption = 'Source Line System Id'; DataClassification = CustomerContent; }
        field(4; "Membership System Id"; Guid)       { Caption = 'Membership System Id'; DataClassification = CustomerContent; }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(BySource;     "Source System Id", "Source Line System Id") { }
        key(BySourceLine; "Source Line System Id", "Entry No.") { }   // Entry No. tiebreaker = deterministic FindSet order, load-bearing for §4.5.1
    }
}
#endif
```

- [ ] **Step 2: Compile**

`bcdev compile -suppressWarnings`. Expected: success.

- [ ] **Step 3: Commit**

```
feat(ecom-membership): add Ecom Sales Membership Link table

Foundation for CORE-208 multi-qty membership support. Mirrors the
NPR Ecom Sales Voucher Link table introduced in CORE-209, simpler:
no archive-state field (memberships don't archive across tables) and
no voucher-type denormalization (no analog). See design doc:
.plans/2026-05-14-aolu-ecom-membership-multi-qty-design.md §3.1.
```

---

## Task 3: Add `InsertMembershipLink` and `CountExistingLinks` helpers

**Files:**
- Modify: `.../_fastLine/virtualItems/Membership/EcomCreateMMShipImpl.Codeunit.al`

- [ ] **Step 1: Add `InsertMembershipLink` private procedure**

Body from spec §4.4 "InsertMembershipLink".

- [ ] **Step 2: Add `CountExistingLinks` private procedure**

```al
local procedure CountExistingLinks(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"): Integer
var
    EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
begin
    EcomSalesMembershipLink.SetCurrentKey("Source System Id", "Source Line System Id");
    EcomSalesMembershipLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
    EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
    exit(EcomSalesMembershipLink.Count());
end;
```

- [ ] **Step 3: Compile and commit**

```
feat(ecom-membership): add link-row helpers for multi-qty issuance

Pure additions. Not wired into the issuance flow yet — that comes in
the next commit when CreateMembership is restructured around the
issuance loop. See design §4.4.
```

---

## Task 4: Extract `IssueSingleMembership` and rewrite `CreateMembership` as a loop

**Files:**
- Modify: `.../EcomCreateMMShipImpl.Codeunit.al`

- [ ] **Step 1: Extract `IssueSingleMembership`**

Move the body of today's `CreateMembership` (`:191-217`) into a new private `IssueSingleMembership` procedure as shown in spec §4.4. Make `InsertMembershipLink(...)` the last DB operation inside it.

Add a code comment right before the `InsertMembershipLink` call:
```al
// Sequencing invariant: InsertMembershipLink MUST stay the last DB op here. The link row is the
// durable race-recovery marker (see design §6 and CORE-209 design §6 for the rationale). A future
// commit between MembershipManagement.CreateMembershipAll and InsertMembershipLink would create a
// state where the membership exists without its link, breaking count-based race recovery.
```

- [ ] **Step 2: Replace the body of `CreateMembership` with the loop**

Body from spec §4.4. The `case true of` branching on `AlreadyLinked` mirrors the voucher design.

Define the two error labels:
```al
LinkCountExceedsQtyErr: Label
    'Internal data inconsistency on membership line %1: %2 membership(s) issued but quantity is %3. Contact support to investigate. This is a programming bug.',
    Locked = true;
PartialLinkStateErr: Label
    'Internal data inconsistency on membership line %1: %2 of %3 membership(s) issued. Contact support to investigate. This is a programming bug.',
    Locked = true;
```

Per CLAUDE.md, "This is a programming bug" triggers Sentry capture downstream (Task 5).

- [ ] **Step 3: Compile**

`bcdev compile -suppressWarnings`. Expected: success.

- [ ] **Step 4: Commit**

```
refactor(ecom-membership): make CreateMembership issue N memberships

Per CORE-208. Wraps the single-membership body in a loop driven by
EcomSalesLine.Quantity, inserts one link row per issued membership,
and applies the race-recovery count-first guard pattern from CORE-209
§4.2. Quantity = 1 still writes EcomSalesLine."Membership Id" for
back-compat; Quantity > 1 leaves it blank. See design §4.4.

Note: this commit does NOT yet relax the qty=1 validators or fix
ConfirmMembership for multi-qty — both happen in subsequent commits.
On its own this is a no-behavior-change refactor (qty>1 is still
rejected upstream).
```

---

## Task 5: Sentry capture in `EcomCreateMMShipProcess.OnRun`

**Files:**
- Modify: `.../_fastLine/virtualItems/Membership/EcomCreateMMShipProcess.Codeunit.al`

- [ ] **Step 1: Add the Sentry hook**

Read the file first to find the existing `OnRun` body. Add `Sentry.AddLastErrorIfProgrammingBug()` between the `Run` call and `HandleResponse` — same shape as the voucher counterpart (CORE-209 design §6 / `EcomCreateVchrProcess.OnRun`).

If `Sentry: Codeunit "NPR Sentry"` isn't already in scope, declare it as a local.

- [ ] **Step 2: Compile and commit**

```
feat(ecom-membership): capture programming-bug errors in Sentry

The link-count-guard errors in CreateMembership use the "This is a
programming bug" suffix per CLAUDE.md convention. Sentry's last-error
detector must be invoked at the process boundary BEFORE HandleResponse
consumes the error text. Same pattern as the voucher counterpart.
See design §6.
```

---

## Task 6: Confirm-all-after-Create with per-membership amount split

This task fixes a **financial-correctness** issue identified in codex review: today's `ConfirmMembership` writes the full `EcomSalesLine."Line Amount"` into the `MM Membership Entry`. Looping that body N times for a qty=N line would record `N * LineAmount` of revenue — incorrect. The amount must be split across N memberships with deterministic rounding (last absorbs the remainder).

**Files:**
- Modify: `.../EcomCreateMMShipImpl.Codeunit.al`

- [ ] **Step 1: Add `ComputeWholeLineAmounts` helper**

Body from spec §4.5.2. Takes `(EcomSalesLine, EcomSalesHeader, var WholeAmount, var WholeAmountInclVAT)` and writes both totals once, rounded to `0.01`. Authoritative side is whichever carries `Line Amount` (per `Price Excl. VAT`); secondary side is derived once at the whole-line level. This is the single source of truth for the rounding precision and VAT direction across both confirm paths (qty=1 standalone and qty>1 bulk).

- [ ] **Step 2: Add `ApplyAmountsToEntry` slim helper**

```al
local procedure ApplyAmountsToEntry(var MembershipEntry, AmountValue, AmountInclVATValue)
begin
    MembershipEntry.Amount := AmountValue;
    MembershipEntry."Amount Incl VAT" := AmountInclVATValue;
end;
```

Both amounts are pre-computed by the caller (`ConfirmAllMembershipsForLine` or the standalone-Confirm shell). No conditional, no rounding inside — that's how both columns sum to their whole-line totals exactly (§4.5.1 invariant).

- [ ] **Step 3: Extract `ConfirmMembershipById` from `ConfirmMembership` (+ link-row write with dedup)**

```al
local procedure ConfirmMembershipById(MembershipSystemId: Guid;
                                       AmountForEntry: Decimal;
                                       AmountInclVATForEntry: Decimal;
                                       EcomSalesLine: Record "NPR Ecom Sales Line";
                                       EcomSalesHeader: Record "NPR Ecom Sales Header") DidFlip: Boolean
```

**`EcomSalesLine` IS a parameter** (rev-5 decision #20 reverses rev-3's trim). It's needed for the `EnsureMembershipLinkExists(EcomSalesHeader, EcomSalesLine, Membership)` call at the end of the body — the link row's `Source Line System Id` comes from `EcomSalesLine.SystemId`.

`DidFlip` returns `true` when this call actually wrote `MembershipEntry."Document No."`; `false` when the idempotency-exit branch at the original `:174-178` short-circuits (`MembershipEntry."Document No." = EcomSalesHeader."External No."`). The boolean feeds the event gating in Step 6.

**Add `EnsureMembershipLinkExists` helper** per spec §4.5.2:
```al
local procedure EnsureMembershipLinkExists(EcomSalesHeader, EcomSalesLine, Membership)
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

The dedup is necessary because `ConfirmMembershipById` is called from both the Create-after-confirm path (where `IssueSingleMembership` already inserted a link row) and the standalone-Confirm path (where no prior link row exists). The Create path hits the IsEmpty-false branch and skips; the standalone path inserts. `BySourceLine` key covers the filter.

Place `EnsureMembershipLinkExists(EcomSalesHeader, EcomSalesLine, Membership)` as the **last DB op** in `ConfirmMembershipById`, immediately after `CreateMembershipPaymentMethods` and before `DidFlip := true`. Sequencing invariant: do not commit between `MembershipEntry.Modify()` and this call.

- [ ] **Step 4: Rewrite `ConfirmMembership(EcomSalesLine, EcomSalesHeader)` shell**

Body becomes:
```al
EcomSalesLine.TestField("Membership Id");
ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT);
if ConfirmMembershipById(EcomSalesLine."Membership Id", WholeAmount, WholeAmountInclVAT, EcomSalesHeader) then;
```

For qty=1 this is byte-identical to today's output (no split, secondary side rounds the same as before).

- [ ] **Step 5: Add `ConfirmAllMembershipsForLine` with deterministic split**

Body from spec §4.5.1 verbatim. Returns `DidConfirmAny: Boolean` (OR-reduction over `ConfirmMembershipById`'s `DidFlip`). Critical invariants:

- Calls `ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT)` at the boundary — does NOT inline the conditional.
- `PerMembershipAmount := Round(WholeAmount / QtyToConfirm, 0.01);` and `PerMembershipAmountInclVAT := Round(WholeAmountInclVAT / QtyToConfirm, 0.01);` — both columns split independently.
- For iterations 1..N-1: `ThisAmount := PerMembershipAmount; ThisAmountInclVAT := PerMembershipAmountInclVAT;`
- For iteration N (last): `ThisAmount := WholeAmount - ConsumedAmount; ThisAmountInclVAT := WholeAmountInclVAT - ConsumedAmountInclVAT;` — remainder lands on the last row.
- After the loop: `sum(ThisAmount) = WholeAmount` AND `sum(ThisAmountInclVAT) = WholeAmountInclVAT` — **both** invariants checked by Test #6 in the spec §7 (parameterized over both `Price Excl. VAT` modes).
- Iterates by `SetCurrentKey("Source Line System Id", "Entry No.")` so "last" = most-recently-inserted link row (deterministic per the key change in Task 2).

- [ ] **Step 6: Update `CreateMembership` return type and the `Process` branch**

Per spec §§4.4, 4.5.3. `CreateMembership` returns `IssuedAnyThisRound: Boolean` (false on race-recovery early-exit, true on the success path). Replace the `Process` branch wiring with the event-gated form:

```al
EcomMembershipOperation::CreateMembership:
    begin
        if CreateMembership(EcomSalesLine, EcomSalesHeader) then
            _EcomVirtualItemEvents.OnAfterMembershipCreatedBeforeCommit(EcomSalesLine);
        if ConfirmAllMembershipsForLine(EcomSalesLine, EcomSalesHeader) then
            _EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
    end;
```

The standalone `ConfirmMembership` branch at `:46-50` is also gated:
```al
EcomMembershipOperation::ConfirmMembership:
    begin
        ConfirmMembership(EcomSalesLine, EcomSalesHeader);   // shell, doesn't fire its own events
        // OR the inlined form per spec §4.5.3:
        // ComputeWholeLineAmounts(...); if ConfirmMembershipById(...) then OnAfter...;
    end;
```

Decide which form at implementation time; the inlined form makes event-gating visible at the dispatch site, the shell-call form is shorter. Either is acceptable.

- [ ] **Step 7: Compile and commit**

```
refactor(ecom-membership): confirm each of N memberships after create

CreateMembership and ConfirmAllMembershipsForLine now return booleans
("did we issue/confirm anything this round"); the Process branch
gates OnAfterMembershipCreatedBeforeCommit and
OnAfterMembershipConfirmedBeforeCommit on those returns. Race
recovery fires neither event.

Critical: BOTH MembershipEntry.Amount AND Amount Incl VAT are
split independently across N memberships from pre-computed
whole-line totals. Each column sums to its whole-line total exactly.
The shared ComputeWholeLineAmounts helper is the single source of
truth for the rounding-direction conditional; ConfirmMembershipById
takes pre-computed amounts and never derives the secondary side
itself. Three rounds of codex review identified and closed:
financial corruption (rev 1), derived-side drift (rev 2),
unused parameter + duplicated formula (rev 3).

See design §§4.4, 4.5.1, 4.5.2, 4.5.3.
```

---

## Task 7: Alteration path link-row + race-recovery (Renew / Extend / Upgrade)

This task closes the link-table coverage to all 5 membership operations per design §4.5.3. Without it, the subpage / `action(Memberships)` / line `OnAssistEdit` would silently miss alteration-operation memberships (the regression Andrei surfaced after discussing with Milena).

**Files:**
- Modify: `.../EcomCreateMMShipImpl.Codeunit.al`

- [ ] **Step 1: Wrap `ProcessMembershipAlteration` with the case-analysis race-recovery guard + link-write**

Today's body at `:219-222` is a thin one-liner delegating to `ReshapeMembershipDuration`. Replace with the case-shape from spec §4.5.3:

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
            ;
        1:
            begin
                EcomSalesMembershipLink.FindFirst();
                if EcomSalesMembershipLink."Membership System Id" <> EcomSalesLine."Membership Id" then
                    Error(AlterationMembershipMismatchErr, EcomSalesLine.RecordId());
                exit(false);
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

Notes:
- The case shape mirrors Create's count-guard pattern (§4.4) — every state is explicit; corruption fails loudly with Sentry capture.
- `Membership.GetBySystemId(EcomSalesLine."Membership Id")` is safe because `ValidateMembershipAlterationRequest` (called during API ingest) already verifies the membership exists.
- The two error labels use "This is a programming bug" suffix — the existing Sentry hook in `EcomCreateMMShipProcess.OnRun` (Task 5) captures them.

- [ ] **Step 2: Update the Process branch wiring for the four operations**

Per spec §4.5.4, replace the Process branches at `EcomCreateMMShipImpl.al:32-75`:

```al
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
```

Each event gates on the boolean return — race recovery fires neither operation nor event.

- [ ] **Step 3: Update `ConfirmMembership` shell signature to return a boolean**

`ConfirmMembership(EcomSalesLine, EcomSalesHeader)` (`:148-189`) now returns `DidConfirmAny: Boolean`. Body becomes the wrapper from Task 6 Step 4:

```al
internal procedure ConfirmMembership(EcomSalesLine, EcomSalesHeader) DidConfirmAny: Boolean
var
    WholeAmount, WholeAmountInclVAT: Decimal;
begin
    EcomSalesLine.TestField("Membership Id");
    ComputeWholeLineAmounts(EcomSalesLine, EcomSalesHeader, WholeAmount, WholeAmountInclVAT);
    DidConfirmAny := ConfirmMembershipById(EcomSalesLine."Membership Id", WholeAmount, WholeAmountInclVAT, EcomSalesLine, EcomSalesHeader);
end;
```

The `if ConfirmMembership(...) then` Process-branch wiring (Step 2 above) consumes the new return value.

- [ ] **Step 4: Compile and commit**

```
feat(ecom-membership): write link rows for Confirm/Renew/Extend/Upgrade

CORE-208 with the wider link-row scope (rev 5 decision #20). Mirrors
the voucher precedent: link row inserted for every processed membership
line regardless of operation, so the subpage / page action / line
AssistEdit all see the same set.

ProcessMembershipAlteration now has a race-recovery guard analogous
to CreateMembership's count-guard; ConfirmMembership (shell) returns
a boolean for event gating; events for all 4 non-Create operations
are gated on their respective work-this-round booleans.

See design §§4.5.3, 4.5.4, decision #20.
```

---

## Task 8: Relax qty=1 gates; harden qty=1 for other operations

**Files:**
- Modify: `.../EcomCreateMMShipImpl.Codeunit.al`

- [ ] **Step 1: Relax `ValidateMembershipRequestForDirectCreation`**

Per spec §4.2: change `if EcomSalesLine.Quantity <> 1 then Error(QuantityErr);` (`:267-268`) to:
```al
if EcomSalesLine.Quantity < 1 then
    Error(QuantityErr);
```
Update the `QuantityErr` label text to: `'Membership line quantity must be a positive whole number.'`

- [ ] **Step 2: Keep `ValidateMembershipForToken` (confirm) strict**

No change — `:426-427` already errors on `Quantity <> 1`, which is correct for the Confirm operation.

- [ ] **Step 3: Add a `Quantity <> 1` guard to `ValidateMembershipAlterationRequest`**

Top of the procedure (after `:467` `begin`):
```al
if EcomSalesLine.Quantity <> 1 then
    Error(QuantityErr);
```
Define `QuantityErr` as a local label: `'Membership alteration line quantity must be 1.'`

This guard does not exist today; qty>1 would silently process the alteration once against one membership (the one identified by `Membership Id`) while creating N copies of the BC sales line. Closing the hole defensively.

- [ ] **Step 4: Update `CheckIfLineCanBeProcessed`**

Per spec §4.3. Replace today's single `if EcomSalesLine.Quantity <> 1 then EcomSalesLine.FieldError(Quantity);` (`:137-138`) with the three operation-aware checks.

- [ ] **Step 5: Reorder `Process` body — lock first, re-resolve operation, then validate**

Per spec §4.3 "Process body ordering — corrected (rev 6)". Live code at `:15-31` validates BEFORE locking + re-resolving, which means the new operation-conditional quantity check from Step 4 would read a potentially stale `Membership Operation`. Fix:

```al
internal procedure Process(var EcomSalesLine: Record "NPR Ecom Sales Line") Success: Boolean
...
begin
    EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
    EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;   // ← moved up from :20
    EcomSalesLine.Get(EcomSalesLine.RecordId);

    EcomMembershipOperation := DetermineMembershipOperation(EcomSalesLine); // ← moved up from :23
    if (EcomSalesLine."Membership Operation" <> EcomMembershipOperation) then begin
        EcomSalesLine."Membership Operation" := EcomMembershipOperation;
        EcomSalesLine.Modify();
    end;

    CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);              // ← was at :18, moved down
    ...
end;
```

The original Process body's `CheckIfLineCanBeProcessed` call moves from line `:18` to after the operation re-resolve. Everything else (the Sentry span, the operation case dispatch) stays where it is.

- [ ] **Step 6: Compile**

`bcdev compile -suppressWarnings`. Expected: success.

- [ ] **Step 6: Commit**

```
feat(ecom-membership): allow Quantity > 1 only for CreateMembership

Per Milena's analysis on CORE-208: Confirm / Renew / Extend / Upgrade
all reference an existing Membership Id and must stay qty=1. Create is
the only operation where multi-qty makes sense (sell N memberships,
attach members later from POS / back-office).

Tightens Renew/Extend/Upgrade with an explicit qty=1 guard that didn't
exist before (was implicit via the global gate this commit removes).
See design §§4.2, 4.3.
```

---

## Task 9: Shared temp-buffer builder + `ShowRelatedMembershipsAction` rewrite

This task introduces the **single source of truth** that all three discovery surfaces (subpage in Task 10, document-level `action(Memberships)` at `EcomSalesDocument.Page.al:477`, line-level `OnAssistEdit` at `EcomSalesDocSub.Page.al:140-150`) read from.

*(Note: the GET response `createdMemberships` array is NOT part of this PR — voucher counterpart was disabled in PR 9975 pending API-team alignment; memberships follow that resolution in a follow-up PR. See design §4.6.)*

**Files:**
- Modify: `.../EcomCreateMMShipImpl.Codeunit.al`

- [ ] **Step 1: Add the shared builder + opener**

From spec §4.7: add three procedures —
- `BuildMembershipTempBufferForDoc(EcomSalesHeader, var TempMembership)` (internal)
- `BuildMembershipTempBufferForLine(EcomSalesHeader, EcomSalesLine, var TempMembership)` (internal)
- `BuildMembershipTempBuffer(EcomSalesHeader, SourceLineSystemIdFilter: Guid, var TempMembership)` (local)
- `OpenMembershipCardForSystemId(SystemIdParam: Guid)` (internal)

The private `BuildMembershipTempBuffer` walks the link table first by `Source System Id` (+ optional `Source Line System Id` if a line filter is supplied) and falls back to the legacy `EcomSalesLine."Membership Id"` walk when no link rows exist (pre-CORE-208 docs).

- [ ] **Step 2: Rewrite the line-level overload to delegate to the builder**

`:645-655` body becomes the N=0/1/N>1 dispatcher in spec §4.7. Calls `BuildMembershipTempBufferForLine` and routes to `OpenMembershipCardForSystemId` for N=1 / `Page.Run(0, TempMembership)` for N>1.

- [ ] **Step 3: Rewrite the document-level overload to delegate to the builder**

`:623-643` body collapses to: `BuildMembershipTempBufferForDoc(EcomSalesHeader, TempMembership); if not TempMembership.IsEmpty() then Page.Run(0, TempMembership);`

- [ ] **Step 4: Verify call sites unchanged**

Grep should show **no** edits required at:
- `EcomSalesDocument.Page.al:488` — page action body still calls `EcomCreateMMShipProcess.ShowRelatedMembershipsAction(Rec)`.
- `EcomSalesDocSub.Page.al:145` — AssistEdit case-block still calls `EcomCreateMMShipProcess.ShowRelatedMembershipsAction(Rec)`.

If you find yourself editing either file in this task, stop — the design is explicit that entry points stay byte-for-byte identical.

- [ ] **Step 5: Compile and commit**

```
refactor(ecom-membership): shared link-table builder for Show Related

Three surfaces (subpage, doc-level page action, line-level AssistEdit)
will read from the same BuildMembershipTempBufferForDoc/ForLine helper.
Page action body and AssistEdit body unchanged — only the called
procedure body is rewritten. Legacy fallback to EcomSalesLine."Membership
Id" keeps pre-CORE-208 docs working. See design §§4.7, 4.10.4.
```

---

## Task 10: Memberships subpage — new `NPR Ecom Membership Sub` ListPart

**Files:**
- Create: `.../_fastLine/virtualItems/Membership/EcomMembershipSub.Page.al`

- [ ] **Step 1: Write the ListPart page**

Use the schema from spec §4.10.1 verbatim. Page is `Access = Internal`, `SourceTable = "NPR MM Membership"`, `SourceTableTemporary = true`. Five fields (External Membership No., Membership Code, Community Code, Customer No., Blocked) and one `Open` action routing through `EcomCreateMMShipImpl.OpenMembershipCardForSystemId(Rec.SystemId)`.

Two internal procedures: `ClearContents()` and `PopulateFromJsonText(JsonText: Text)`. The JSON-to-temp-record projection inside `PopulateFromJsonText` uses `Insert(false, true)` to preserve `SystemId` (needed by the Open action) and to skip `OnInsert` (the corresponding live row already exists in the real table, so a regular `Insert(true)` would error). Same shape as `EcomVoucherSub.Page.al:108-155`.

- [ ] **Step 2: Verify the field shortlist exists on `NPR MM Membership`**

Confirm `External Membership No.`, `Membership Code`, `Community Code`, `Customer No.`, `Blocked` are real fields with sensible types/captions on the source table. If `Customer No.` doesn't exist (most uncertain entry per spec §4.10.1), drop it.

- [ ] **Step 3: Compile and commit**

```
feat(ecom-membership): add Memberships subpage ListPart

New EcomMembershipSub.Page.al — temporary-record list part driven
by the parent page's Page Background Task. Open action routes to
NPR MM Membership Card via OpenMembershipCardForSystemId. Mirrors
the voucher subpage's PopulateFromJsonText / ClearContents shape,
simpler: no archive row-style, single homogeneous list. Not wired
into the parent page yet — that happens in the next commit.
See design §4.10.1.
```

---

## Task 11: PBT wiring — `EcomDocSubpagesTask` + `EcomSalesDocument` page

**Files:**
- Modify: `.../_fastLine/virtualItems/EcomDocSubpagesTask.Codeunit.al`
- Modify: `.../_public/EcomSalesDocument.Page.al`

- [ ] **Step 1: Extend `EcomDocSubpagesTask` with the memberships payload builder**

Add `BuildMembershipsPayload(EcomSalesHeader, var Result)` and `MembershipsResultKeyTok()` per spec §4.10.2. Add the call from `OnRun()`:

```al
BuildVouchersPayload(EcomSalesHeader, Result);
BuildMembershipsPayload(EcomSalesHeader, Result);   // new
```

The child session now executes `BuildMembershipTempBufferForDoc` (from Task 9) once per refresh, serializes the result, and ships it back in the dictionary.

- [ ] **Step 2: Add the part declaration on `EcomSalesDocument.Page.al`**

Right after the existing `part(VouchersSubPage; "NPR Ecom Voucher Sub")` at `:289` (inside the `#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)` guard):

```al
part(MembershipsSubPage; "NPR Ecom Membership Sub")
{
    Caption = 'Memberships';
    ApplicationArea = NPRRetail;
    UpdatePropagation = Both;
}
```

- [ ] **Step 3: Fill in the commented placeholders**

The page anticipates this exact addition with three commented lines. **Verify line numbers at implementation time** — the page has evolved since rev 5 and the citations below may have drifted. Current shape (verified 2026-05-18):

- `:560` (was `:551`) — `AllSubpagesLoaded := PopulateMembershipsSubpage(Results) and AllSubpagesLoaded;`
- `:598` (was `:589`) — `CurrPage.MembershipsSubPage.Page.ClearContents();`
- Add `PopulateMembershipsSubpage` helper alongside `PopulateVouchersSubpage` at `:581` (was `:572`) — body from spec §4.10.3.

Grep for the exact placeholders `// AllSubpagesLoaded := PopulateMembershipsSubpage(Results) and AllSubpagesLoaded;` and `// CurrPage.MembershipsSubPage.Page.ClearContents();` rather than trusting these line numbers blindly.

- [ ] **Step 4: Verify no other page-level changes are required**

- `EnqueueSubpagesRefresh` body — **unchanged**. Do NOT touch. Post-rev-5 it added `Codeunit "NPR Ecom Subpages Sync".ConsumeDirty(...)` handling so subpage-action mutations on `EcomSalesDocSub` invalidate the parent's loaded cache and force a fresh PBT — the membership subpage benefits from this automatically without us doing anything.
- `_SubpagesBackgroundTaskId` / `_SubpagesPendingForSystemId` / `_SubpagesLoadedForSystemId` page-level vars — **unchanged**.
- `OnPageBackgroundTaskError` body — **unchanged**. Already routes to `ClearAllSubpages()`.
- `action(Memberships)` body at `:477-490` — **unchanged**. Entry point preserved.
- No `Sync.MarkDirty` call to add from the membership processing path. Vouchers don't add one either — `MarkDirty` is the subpage-action mutator's mechanism, not the API-ingest path's.

If you find yourself editing anything beyond the part declaration, the three placeholder lines, and the new `PopulateMembershipsSubpage` helper, stop and reconcile against the design.

- [ ] **Step 5: Compile and commit**

```
feat(ecom-membership): wire Memberships subpage into PBT plumbing

EcomDocSubpagesTask now builds vouchers + memberships in a single
child session. EcomSalesDocument.Page.al hosts the new
MembershipsSubPage part, and the OnPageBackgroundTaskCompleted /
ClearAllSubpages hooks (commented placeholders since CORE-209) are
filled in. action(Memberships) entry point unchanged. See design
§§4.10.2, 4.10.3.
```

---

## Task 12: Tests

**Files:**
- Create or extend: `Test/src/Tests/ECommerce/FastLane/EcomMembershipMultiQtyTests.Codeunit.al` (or extend an existing membership test file if Task 1 step 5 found one)

- [ ] **Step 1: Establish test fixture**

Sibling test codeunits (`EcomVoucherTests.Codeunit.al`, etc.) demonstrate the conventions used in `Test/src/Tests/ECommerce/FastLane/`. Reuse: same Setup/TearDown pattern, same `[Test]`/`[HandlerFunctions]` decorators, same membership-test library helpers if present (search `Test/src/Libraries/` for `LibraryMM*` / `MembershipTestLib*`).

- [ ] **Step 2: Write the 10 tests from spec §7**

Each numbered item in §7 maps to one `[Test]` procedure. Suggested names:

| Spec # | Procedure name | One-line purpose |
|---|---|---|
| 1 | `Test_CreateMembership_Qty1_BackCompat` | Regression — qty=1 today's behavior preserved |
| 2 | `Test_CreateMembership_Qty5_HappyPath` | Load-bearing — multi-qty issuance produces N memberships + N link rows |
| 3 | `Test_QuantityIngestValidation` | Parameterized: 0 / -1 / 2.5 rejected; qty>1 rejected for non-Create at processing-time gate |
| 4 | `Test_NonCreateOperations_Qty5_Rejected` | Parameterized over Confirm / Renew / Extend / Upgrade payloads |
| 5 | `Test_RaceRecovery_NoDuplicates_NoEvents` | Pre-populated link rows → Process exits with `false` returns and no events fire |
| 6 | `Test_AccountingCorrectness_BothColumnsSum_RemainderToLast` | LineAmount=10.01, VAT=25%, qty=3 → both columns sum exactly; replay is deterministic |
| 7 | `Test_ConfirmOperation_WritesLinkRow` | Wider-scope link-row test for non-Create operation |
| 8 | `Test_AlterationOperation_WritesLinkRow_AndRaceRecovery` | Renew test combining first-run success + race-recovery branch |
| 9 | `Test_ShowRelated_LineLevel_Qty5_OpensListPage` | qty=5 line → AssistEdit opens BC default `NPR MM Membership` list with 5 rows |
| 10 | `Test_ThreeSurfaces_Coherent_AllFiveOperations` | **Load-bearing integration test** — doc with 1 line per operation; subpage / page action / per-line AssistEdit all show the same 7-membership set |

- [ ] **Step 3: Run tests**

`bcdev test` (or the project's standard test invocation). All 10 must pass.

- [ ] **Step 4: Commit**

```
test(ecom-membership): multi-qty membership tests for CORE-208

10 load-bearing tests covering happy paths, operation-conditional
quantity validation, race recovery + event gating, accounting
correctness (both-columns split with deterministic remainder),
wider-scope link rows for Confirm and alteration operations,
ShowRelated UX dispatch, and three-surface coherence across all
5 operations. Earlier revs of this design had 23 candidate tests;
trimmed to 10 to focus on real regressions only — see spec §7 for
what was cut and why.
```

---

## Task 13: Compile-with-analyzers + LSP diagnostics + Codex review

**Files:**
- Reference only — no code changes

- [ ] **Step 1: Compile with analyzers**

Per memory `feedback_compile_analyzers.md`: `bcdev compile` skips CodeCop. Run the full compile-with-analyzers script:

```powershell
.\.scripts\compile_with_analyzers.ps1 -WorkspaceFolder .
```

Fix any new warnings or errors introduced by this branch. (AA0137 unused vars, AA0136 dead code, AA0073 Temp prefix mis-use, etc.)

- [ ] **Step 2: AL LSP diagnostics**

Run `mcp__serena__get_diagnostics_for_file` on each modified file. Resolve any new diagnostics.

- [ ] **Step 3: Codex review via PAL**

Invoke `mcp__pal__clink` with `codex` CLI and `gpt-5.5` model, extra-high reasoning, on the design + plan + diff combined. Address review comments (likely areas: race-recovery edge cases, the `MemberInfoCapture` lifecycle, whether confirm-each-membership genuinely produces N independent `MM Membership Entry` rows, whether `Page.Run(0, TempMembership)` actually resolves to the expected list page in production environments, the operation-conditional `Quantity` validation thoroughness).

- [ ] **Step 4: Self-review**

Walk through spec §10 "Decisions made" and confirm each lines up with the merged-in diff. If something diverges, either fix the code or document why in the design.

No commit at the end of this task unless the analyzer/LSP/codex pass produces fixes.

---

## Task 15: Community-policy compatibility — `AllowMergeOnConflict` opt-in + defensive validator

Implements design §4.12 (decisions #25 and #26). Surfaced during Milena's Job Queue test pass (2026-05-20): communities configured with `Create Member UI Violation = Merge` silently fail in non-UI context with `ALLOW_MEMBER_MERGE_NOT_SET` (-127008) when iteration 2+ of `CreateMembership` hits a unique-identity match. This task closes that gap and adds an upfront validator rejection for the `Error`-policy hard-fail case.

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipImpl.Codeunit.al`
- Modify: `Test/src/Tests/ECommerce/FastLane/EcomMembershipMultiQtyTests.Codeunit.al`

- [ ] **Step 1: Set `MemberInfoCapture.AllowMergeOnConflict := true` in `IssueSingleMembership`** (design §4.12.1)

  Between `SetNotificationMethod(MemberInfoCapture)` and `MemberInfoCapture.Modify()`, add:

  ```al
  MemberInfoCapture.AllowMergeOnConflict := true;
  ```

  In our codepath `MemberInfoCapture."Member Entry No"` is never set, so `Member.Get(0)` at `CheckMemberUniqueId:1551` returns false and `MergeMemberUniqueId` is never actually called — the flag only bypasses the `ALLOW_MEMBER_MERGE_NOT_SET` raise and lets conflict resolution fall through to the existing-member reuse.

- [ ] **Step 2: Add the defensive validator + `LineCouldTriggerUniquenessConflict` helper in `ValidateMembershipRequestForDirectCreation`** (design §4.12.2)

  Add the new error label:

  ```al
  QtyMultiNeedsPermissiveCommunityErr: Label
      'Multi-quantity membership lines with identity fields require community ''%1'' to be configured with %2 ≠ Error. Use Reuse, Merge, or Confirm.',
      Comment = '%1 = Community Code; %2 = field caption';
  ```

  Add the gate after the existing quantity / identity / GDPR checks:

  ```al
  if (EcomSalesLine.Quantity > 1) then begin
      Community.Get(MembershipSetup."Community Code");
      if LineCouldTriggerUniquenessConflict(EcomSalesLine, Community)
         and (Community."Create Member UI Violation" = Community."Create Member UI Violation"::Error)
      then
          Error(QtyMultiNeedsPermissiveCommunityErr, Community.Code, Community.FieldCaption("Create Member UI Violation"));
  end;
  ```

  Add the new private helper next to other validator helpers:

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

- [ ] **Step 3: Compile with analyzers** — `bcdev compile -suppressWarnings`. Expect 0 errors / 0 warnings on the touched file.

- [ ] **Step 4: Add tests T11 + T12 in `EcomMembershipMultiQtyTests.Codeunit.al`** (design §7 tests 11 and 12)

  **T11 — `Test_QtyMulti_ErrorPolicy_RejectedByValidator`** (design §4.12.2 / test 11). Override `Initialize`'s community to `Member Unique Identity = EMAIL`, `Create Member UI Violation = Error`. Build a qty=3 Create line with `Member Email` populated. `asserterror EcomCreateMMShipImpl.Process(...)`. Assert the captured error text matches the new `QtyMultiNeedsPermissiveCommunityErr` label.

  **T12 — `Test_QtyMulti_MergePolicy_AllLinkToOneMember`** (design §4.12.1 / test 12). Override community to `Member Unique Identity = EMAIL`, `Create Member UI Violation = Merge`, `Member Logon Credentials = NA`. Build a qty=5 Create line with `Member Email` populated. Process. Assert:
  - 5 link rows created.
  - For each link row, fetch the Membership, then iterate active non-anonymous `MembershipRole` rows; collect distinct `Member Entry No.` values.
  - Across all 5 memberships, exactly one distinct `Member Entry No.` appears.

  Both tests need to set the community policy fields BEFORE `Process` is called and restore them after (per the existing `Initialize` pattern with `_IsInitialized` — copy that shape, or use a per-test setup helper that takes the policy enum as a parameter).

- [ ] **Step 5: Compile Test app + run T11 / T12 only**

  Run only these two new tests (avoid the multi-hour full suite). Expect both green.

- [ ] **Step 6: Commit**

  ```bash
  git add Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Membership/EcomCreateMMShipImpl.Codeunit.al \
          Test/src/Tests/ECommerce/FastLane/EcomMembershipMultiQtyTests.Codeunit.al
  git commit -m "Honor community Merge policy + defensive Error-policy validator (CORE-208)"
  ```

  Single commit covering both changes A and B + tests T11/T12 — they're logically one feature ("multi-qty Create now respects community uniqueness-resolution policy").

---

## Task 14: Finishing

- [ ] **Step 1: Verify branch is clean and tests pass**

```bash
git status
git log --oneline master..HEAD
bcdev compile -suppressWarnings
bcdev test
```

- [ ] **Step 2: Use the `superpowers:finishing-a-development-branch` skill**

It will guide PR creation, push, and a final review pass. Per user memory ("Don't commit automatically", "Confirm before posting"), do NOT push or open a PR without explicit user confirmation.

When drafting the PR description and release notes, **explicitly call out the API-contract limitation** (per codex rev-8 review / design §11):

> **Known transitional limitation:** for qty>1 create-membership lines, the `membershipId` field in the GET response stays blank, and there is no response-only public API discovery path for the N issued memberships until the follow-up PR enables `AddCreatedMembershipsArray` (deferred together with the voucher `createdVouchers` array per PR 9975, pending API-team alignment on the response contract). External API callers handling multi-qty membership creation in this window can either (a) read the BC UI Memberships subpage on the Ecom Document, or (b) wait for the follow-up PR. This is still a strict capability improvement over the pre-CORE-208 behavior, which rejected qty>1 lines outright.

Put this verbatim (or close to it) in the PR description under a "Known limitations" heading and in the release notes for the version that ships this PR.

- [ ] **Step 3: Open the corresponding Fern PR in `navipartner/documentation`**

Spec §11 lists the three Fern changes needed:
- `quantity` semantics on membership lines: "≥ 1 when membership operation is *create*; must be 1 otherwise."
- Note on `membershipId` field for qty>1: "When `quantity > 1` on a create-membership line, this is empty; use the Memberships subpage on the Ecom Document to discover the N issued memberships."
- (The `createdMemberships` GET array Fern update is part of the deferred follow-up PR — see design §4.6.)

Save a follow-up memory linking the BC PR to the Fern PR if both are open at the same time. Per memory `project_core206_fern_docs_pending.md` precedent, mark the Fern work as pending if it goes out of session.

---

## Notes for the executing agent

- **Sequencing invariant** for `IssueSingleMembership`: `InsertMembershipLink` MUST stay the last DB op. Re-check after every edit to that procedure.
- **The `_EcomVirtualItemEvents` events** are line-scoped, not membership-scoped. Subscribers needing per-membership info read the link table. Don't multiply event firings inside the loop without an explicit reason.
- **`Page.Run(0, TempMembership)`** in the N>1 ShowRelated branch resolves to the registered list page for `NPR MM Membership`. Verify at runtime that it renders the temporary rows correctly. If BC's behavior for `Page.Run(0, ...)` with a temp record isn't what we expect, fall back to a dedicated lookup page (mirror the voucher `EcomVoucherLookup.Page.al`).
- **MemberInfoCapture lifecycle.** Each loop iteration inserts and deletes its own MemberInfoCapture row. If `CreateMembershipAll` throws, the surrounding `Codeunit.Run` rollback removes the row. Don't add `try-finally` style cleanup — let the rollback do its job.
- **Quantity field on EcomSalesLine.** No table-level `OnValidate` immutability guard in this PR — earlier revs had one, but PR 9975 reviewers asked to drop the voucher counterpart and the membership analog follows. See spec §4.11. Corruption states are still detected at processing time via the Sentry-captured hard errors in `CreateMembership` / `ProcessMembershipAlteration`; we just lose one layer of defense at mutation time.
- **Per-membership amount split is load-bearing.** Task 6 explicitly splits `Line Amount` across N memberships. If at any point during implementation you find yourself writing `MembershipEntry.Amount := EcomSalesLine."Line Amount";` inside the loop, stop — that's the bug codex caught. The whole-line amount only goes onto a single membership in the qty=1 standalone-Confirm path. See spec §4.5.1.
