# Span Naming Cleanup & Post-Processing Span Instrumentation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix underscore characters in Sentry span descriptions (Sentry strips them in the UI) and add nested spans inside `bc.pos.line.insert.post-processing` to identify what causes production spikes.

**Architecture:** Pure string renaming for Task 1; adding `Codeunit "NPR Sentry Span"` local variables and `Sentry.StartSpan`/`Span.Finish()` pairs for Task 2. The preprocessor guards (`#if not (BC17 or BC18 or BC19 or BC20 or BC21)`) live inside the Sentry/SentrySpan codeunits themselves — callers do not need guards.

**Tech Stack:** AL (Business Central), Sentry span instrumentation via `NPR Sentry` / `NPR Sentry Span` codeunits.

---

## Task 1: Replace underscores in span descriptions

Replace `_` with `.` (for namespace separators) or `-` (for compound words) depending on what reads best. The convention already established in the codebase uses dots for hierarchy (`bc.pos.discount.find.active`) and hyphens for compound words (`insert-request`).

### Static span descriptions (literal strings)

Each step below is one file edit. Commit after all are done.

| # | File | Line | Old | New | Rationale |
|---|------|------|-----|-----|-----------|
| 1 | `Application/src/Sales Price/POSSalesPriceCalcMgt.Codeunit.al` | 60 | `bc.pos.calc_line_price` | `bc.pos.calc-line-price` | compound word |
| 2 | `Application/src/POS Tax Free/TaxFreeHandlerMgt.Codeunit.al` | 609 | `bc.pos.endsale.taxfree_voucher` | `bc.pos.endsale.taxfree-voucher` | compound word |
| 3 | `Application/src/POS Payment/EFT/Integrations/Adyen/Cloud/Tasks/EFTAdyenTrxTask.Codeunit.al` | 66 | `bc.pos.adyen.cloud.http_request` | `bc.pos.adyen.cloud.http-request` | compound word |
| 4 | `Application/src/POS Payment/EFT/Integrations/Adyen/Cloud/POSActionEFTAdyenCloud.Codeunit.al` | 64 | `bc.pos.adyen.cloud.process_result` | `bc.pos.adyen.cloud.process-result` | compound word |
| 5 | `Application/src/POS Payment/EFT/Integrations/Adyen/Cloud/POSActionEFTAdyenCloud.Codeunit.al` | 96 | `bc.pos.adyen.cloud.start_transaction` | `bc.pos.adyen.cloud.start-transaction` | compound word |
| 6 | `Application/src/SpeedGate/SGSpeedGate.Codeunit.al` | 750 | `bc.speedgate.wallet_validation` | `bc.speedgate.wallet-validation` | compound word |
| 7 | `Application/src/SpeedGate/SGSpeedGate.Codeunit.al` | 890 | `bc.speedgate.ticket_request-validation` | `bc.speedgate.ticket-request-validation` | mixed separator → consistent hyphen |
| 8 | `Application/src/POS Discount/_public/POSSalesDiscCalcMgt.Codeunit.al` | 342 | `bc.pos.discount.find_active` | `bc.pos.discount.find-active` | compound word |
| 9 | `Application/src/POS Discount/MixedDiscountManagement.Codeunit.al` | 1997 | `bc.pos.discount.mix.find_active` | `bc.pos.discount.mix.find-active` | compound word |
| 10 | `Application/src/POS Core/_public/POSSaleLine.Codeunit.al` | 167 | `bc.insert_sale_line` | `bc.pos.insert-sale-line` | compound word + add `pos.` prefix for consistency |
| 11 | `Application/src/POS Core/_public/POSSaleLine.Codeunit.al` | 573 | `bc.item_variant_lookup` | `bc.pos.item-variant-lookup` | compound word + add `pos.` prefix |
| 12 | `Application/src/POS Core/_public/POSSaleLine.Codeunit.al` | 594 | `ui.bc.item_variant_lookup` | `ui.bc.pos.item-variant-lookup` | compound word + add `pos.` prefix |
| 13 | `Application/src/POS Core/_public/POSSaleLine.Codeunit.al` | 711 | `bc.pos.line.insert.post_processing` | `bc.pos.line.insert.post-processing` | compound word |
| 14 | `Application/src/POS Core/_public/POSSale.Codeunit.al` | 464 | `bc.end_sale.pre_processing` | `bc.pos.endsale.pre-processing` | use `endsale` to match existing `bc.pos.endsale.*` namespace |
| 15 | `Application/src/POS Core/_public/POSSale.Codeunit.al` | 476 | `bc.end_sale.pos_entry_write` | `bc.pos.endsale.pos-entry-write` | same namespace |
| 16 | `Application/src/POS Core/_public/POSSale.Codeunit.al` | 486 | `bc.end_sale.post_processing` | `bc.pos.endsale.post-processing` | same namespace |
| 17 | `Application/src/POS Core/POSSalesPrintMgt.Codeunit.al` | 58 | `bc.pos.endsale.receipt_print` | `bc.pos.endsale.receipt-print` | compound word |
| 18 | `Application/src/POS Posting/_public/POSEntryManagement.Codeunit.al` | 282 | `bc.print_pos_entry` | `bc.print-pos-entry` | compound word |
| 19 | `Application/src/POS Action (with Misc actions)/Item/POSActionInsertItemB.Codeunit.al` | 26 | `bc.pos.item_insert.get_item` | `bc.pos.item-insert.get-item` | compound word |
| 20 | `Application/src/POS Core/POSDragonglass.Page.al` | 55 | `bc.pos.framework_ready` | `bc.pos.framework-ready` | compound word |
| 21 | `Application/src/POS Core/POSDragonglass.Page.al` | 152 | `bc.pos.process_background_tasks` | `bc.pos.process-background-tasks` | compound word |
| 22 | `Application/src/Member Module/MMMemberLimMgr.Codeunit.al` | 181 | `bc.membership.arrival.check_limitations` | `bc.membership.arrival.check-limitations` | compound word |
| 23 | `Application/src/Retail Print/_public/RPTemplateMgt.Codeunit.al` | 46 | `bc.print_template` | `bc.print-template` | compound word |
| 24 | `Application/src/Sentry/examples/_public/SentryExample.Page.al` | 55 | `bc.error_example` | `bc.error-example` | compound word (example code) |
| 25 | `Application/src/Sentry/examples/_public/POSActionSentryExample.Codeunit.al` | 27 | `workflow_parent` | `workflow-parent` | compound word (example code) |
| 26 | `Application/src/Sentry/examples/_public/POSActionSentryExample.Codeunit.al` | 29 | `workflow_child` | `workflow-child` | compound word (example code) |
| 27 | `Application/src/Sentry/examples/_public/POSActionSentryExample.Codeunit.al` | 33 | `workflow_child2` | `workflow-child2` | compound word (example code) |
| 28 | `Application/src/_API_SERVICES/ticketing/handlers/TicketingReservationAgent.Codeunit.al` | 303 | `bc.ticket_api.reservation.initialization` | `bc.ticket-api.reservation.initialization` | `ticket_api` → `ticket-api` |
| 29 | `Application/src/_API_SERVICES/ticketing/handlers/TicketingReservationAgent.Codeunit.al` | 314 | `bc.ticket_api.reservation.insert-request` | `bc.ticket-api.reservation.insert-request` | same module prefix |
| 30 | `Application/src/_API_SERVICES/ticketing/handlers/TicketingReservationAgent.Codeunit.al` | 358 | `bc.ticket_api.reservation.finalize` | `bc.ticket-api.reservation.finalize` | same module prefix |
| 31 | `Application/src/_API_SERVICES/ticketing/handlers/TicketingReservationAgent.Codeunit.al` | 367 | `bc.ticket_api.reservation.decorate-response` | `bc.ticket-api.reservation.decorate-response` | same module prefix |

### Dynamic span descriptions (StrSubstNo templates)

| # | File | Line | Old | New |
|---|------|------|-----|-----|
| 32 | `Application/src/POS Background Tasks/POSBackgrTaskManager.Codeunit.al` | 49 | `bc.pos.background_task.execute:%1` | `bc.pos.background-task.execute:%1` |
| 33 | `Application/src/POS Background Tasks/POSBackgrTaskManager.Codeunit.al` | 70 | `bc.pos.background_task.enqueue:%1` | `bc.pos.background-task.enqueue:%1` |
| 34 | `Application/src/POS Background Tasks/POSBackgrTaskManager.Codeunit.al` | 148 | `bc.pos.background_task.complete:%1` | `bc.pos.background-task.complete:%1` |
| 35 | `Application/src/POS Background Tasks/POSBackgrTaskManager.Codeunit.al` | 168 | `bc.pos.background_task.error:%1` | `bc.pos.background-task.error:%1` |
| 36 | `Application/src/POS Background Tasks/POSBackgrTaskManager.Codeunit.al` | 191 | `bc.pos.background_task.cancel:%1` | `bc.pos.background-task.cancel:%1` |
| 37 | `Application/src/POS Core/_public/POSDragonglassAPI.Codeunit.al` | 34 | `invoke_method_%1` | `invoke-method:%1` |
| 38 | `Application/src/_API_SERVICES/ticketing/TicketingAPI.Codeunit.al` | 112 | `bc.ticket_api.handler.%1` | `bc.ticket-api.handler.%1` |
| 39 | `Application/src/_API_SERVICES/memberships/MembershipsAPI.Codeunit.al` | 236 | `bc.membership_api.handler.%1` | `bc.membership-api.handler.%1` |
| 40 | `Application/src/_API_SERVICES/speedgate/ApiSpeedgate.Codeunit.al` | 147 | `bc.speedgate_api.handler.%1` | `bc.speedgate-api.handler.%1` |
| 41 | `Application/src/POS Input Box/_public/POSInputBoxEvtHandler.Codeunit.al` | 87 | `bc.pos.inputbox.check_scope:%1_%2` | `bc.pos.inputbox.check-scope:%1.%2` |
| 42 | `Application/src/__Legacy (STILL SUPPORTED)/Click & Collect/NpCsTaskProcessor.Codeunit.al` | 29 | `process_task_%1` | `process-task:%1` |

### Steps

- [ ] **Step 1:** Apply all 42 renames listed above (string replacement in each file)
- [ ] **Step 2:** Compile with `/bcdev` to verify no typos or broken strings
- [ ] **Step 3:** Commit: `fix(sentry): replace underscores in span descriptions with hyphens`

---

## Task 2: Add nested spans inside post-processing block

**File:** `Application/src/POS Core/_public/POSSaleLine.Codeunit.al`
**Procedure:** `InsertLineInternal` (line 685)

Add new `Codeunit "NPR Sentry Span"` variables and wrap each module call in a span.

- [ ] **Step 1:** Add local variables in `InsertLineInternal`

Add after existing `PostProcessingSpan` variable (line 695):

```al
        CouponsSpan: Codeunit "NPR Sentry Span";
        WalletSpan: Codeunit "NPR Sentry Span";
        TicketSpan: Codeunit "NPR Sentry Span";
        MemberSpan: Codeunit "NPR Sentry Span";
        HtmlDisplaySpan: Codeunit "NPR Sentry Span";
        ProxyDisplaySpan: Codeunit "NPR Sentry Span";
        WorkflowSpan: Codeunit "NPR Sentry Span";
        SubscribersSpan: Codeunit "NPR Sentry Span";
```

- [ ] **Step 2:** Wrap each module call inside the post-processing block

Replace the body between `StartSpan(PostProcessingSpan, ...)` and `PostProcessingSpan.Finish()` with:

```al
        Sentry.StartSpan(PostProcessingSpan, 'bc.pos.line.insert.post-processing');

        Rec.UpdateAmounts(Rec);
        if (not (Rec.GetSkipCalcDiscount())) then
            POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOS(Rec);

        Sentry.StartSpan(SubscribersSpan, 'bc.pos.line.insert.post-processing.subscribers-before-workflows');
        OnAfterInsertPOSSaleLineBeforeWorkflows(Rec);
        SubscribersSpan.Finish();

        Sentry.StartSpan(CouponsSpan, 'bc.pos.line.insert.post-processing.coupons');
        POSIssueOnSale.AddNewSaleCoupons(Rec);
        CouponsSpan.Finish();

        Sentry.StartSpan(WalletSpan, 'bc.pos.line.insert.post-processing.wallet');
        WalletCreate.CreateIntermediateWallet(Rec);
        WalletSpan.Finish();

        Sentry.StartSpan(TicketSpan, 'bc.pos.line.insert.post-processing.ticket');
        TicketRetailMgt.UpdateTicketOnSaleLineInsert(Rec);
        TicketSpan.Finish();

        Sentry.StartSpan(MemberSpan, 'bc.pos.line.insert.post-processing.member');
        POSActMemberMgt.UpdateMembershipOnSaleLineInsert(Rec);
        MemberSpan.Finish();

        Sentry.StartSpan(HtmlDisplaySpan, 'bc.pos.line.insert.post-processing.html-display');
        HTMLDisplay.UpdateHTMLDisplay();
        HtmlDisplaySpan.Finish();

        Sentry.StartSpan(ProxyDisplaySpan, 'bc.pos.line.insert.post-processing.proxy-display');
        POSProxyDisplay.UpdateDisplay(Rec);
        ProxyDisplaySpan.Finish();

        Sentry.StartSpan(WorkflowSpan, 'bc.pos.line.insert.post-processing.workflows');
        InvokeOnAfterInsertSaleLineWorkflow(Rec);
        WorkflowSpan.Finish();

        RefreshCurrent();

        Sentry.StartSpan(SubscribersSpan, 'bc.pos.line.insert.post-processing.subscribers-before-commit');
        OnAfterInsertPOSSaleLineBeforeCommit(Rec);
        OnAfterInsertPOSSaleLine(Rec);
        SubscribersSpan.Finish();

        Commit();

        Sentry.StartSpan(SubscribersSpan, 'bc.pos.line.insert.post-processing.subscribers-after-commit');
        OnAfterInsertPOSSaleLineAfterCommit(Rec);
        SubscribersSpan.Finish();

        POSSale.RefreshCurrent();

        Line := Rec;

        PostProcessingSpan.Finish();
```

Note: `SubscribersSpan` is reused for the three subscriber groups (before-workflows, before-commit, after-commit) since they are sequential and non-overlapping.

- [ ] **Step 3:** Compile with `/bcdev` to verify
- [ ] **Step 4:** Commit: `perf(sentry): add nested spans to pos sale line post-processing for spike diagnosis`
