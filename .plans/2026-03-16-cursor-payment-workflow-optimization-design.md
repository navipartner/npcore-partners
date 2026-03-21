# Payment Workflow Optimization — Design Document

> **Linear issue:** CORE-163 — Performance issue on payments
> **Date:** 2026-03-16

## Problem

Every payment button click (PAYMENT_2) makes 3 sequential BC roundtrips before the user sees anything:

1. `preparePreWorkflows` — collects pre-workflows (e.g., SALE_DIMENSION, CalcDiscounts)
2. `preparePaymentWorkflow` — the actual payment preparation (method, amount, flags)
3. `preparePostWorkflows` — collects post-workflows (e.g., HU Laurel fiscal display)

Each roundtrip costs ~200ms on BC SaaS. That's ~400ms of unnecessary overhead for steps 1 and 3 which are empty for most customers.

## Prior Art

`POSActionEndSale` already implements the optimized pattern: it merges pre-workflows + business logic into one call and only makes a second call if pre-workflow subscribers exist.

```
// EndSale JS — optimized pattern
({ preWorkflows, postWorkflows } = await workflow.respond("endSaleWithPreWorkflows"));
if (preWorkflows) {
    await processWorkflows(preWorkflows);
    ({ postWorkflows } = await workflow.respond("endSaleWithoutPreWorkflows"));
}
await processWorkflows(postWorkflows);
```

The corresponding AL checks `PreWorkflows.Keys.Count()` and exits early when subscribers added workflows, or falls through to the full business logic when no pre-workflows exist.

## Key Findings

### Pre-workflows
- `OnAddPreWorkflowsToRun` is an `internal` event on `PaymentProcessingEvents`
- Subscribers: `CalcDiscounts` (adds CALC_DISCOUNTS workflow when total discounts exist), plus `AddSaleDimensionWorkflow` (direct call, not event-based)
- Pre-workflow collection can be merged into the main call using the EndSale pattern

### Post-workflows
- `OnAddPostWorkflowsToRun` is an `internal` event on `PaymentProcessingEvents` (codeunit is `Access = Public`, but the event procedure is `internal`)
- **No PTE can subscribe** — `internal` event procedures are invisible outside the extension regardless of codeunit access level
- **Only subscriber: HU Laurel** (`HULAuditMgt.OnAddPostWorkflowsToRun`)
- The subscriber reads `paymentAmount` from Context to display on a fiscal display. Moving post-workflow collection before user input would give wrong/empty amount data
- The subscriber has **no side effects** — pure record reads + JSON construction

Since we fully control the subscriber, we can convert it from an event subscriber to a direct function call, giving us full control over when and whether to call it.

## Design

### Approach: Merge pre-workflows + payment preparation; detect post-workflow needs via direct call

Follow the EndSale pattern for pre-workflows. For post-workflows, replace the event subscriber with a direct function call so we can cheaply detect whether post-workflows are needed without actually building them.

### HU Laurel changes (`HULAuditMgt.Codeunit.al`)

1. **Delete** the `[EventSubscriber]` for `OnAddPostWorkflowsToRun` entirely
2. **Add** two new `internal` procedures:
   - `HasPaymentPostprocessingWorkflow(Sale: Codeunit "NPR POS Sale"): Boolean` — lightweight check: reads POS unit, calls `IsHULaurelAuditEnabled`. No JSON building.
   - `AddPaymentPostprocessingWorkflow(Context, Sale, PaymentLine, var PostWorkflows)` — the actual workflow builder (same logic as the deleted subscriber body)
3. **Remove** the `OnAddPostWorkflowsToRun` event publisher from `PaymentProcessingEvents` — it's no longer fired and can be re-introduced in a better way if needed

### Payment workflow backend changes (`POSActionPaymentWF2.Codeunit.al`)

**Step routing (`RunWorkflow`):**

| Step name | Handler | When called |
|-----------|---------|-------------|
| `preparePaymentWorkflow` | `PreparePaymentWithPreprocessing` | First call (merged entry point) |
| `continuePaymentWorkflow` | `PreparePaymentAndDetectPostprocessing` | After frontend ran preprocessing workflows |
| `preparePostWorkflows` | `CollectPostprocessingWorkflows` | Only when `needsPostprocessingWorkflows` is true |
| `SetMembershipSubscPayerEmail` | (unchanged) | When membership email needed |
| `doLegacyPaymentWorkflow` | (unchanged) | Legacy payment path |

Remove old `preparePreWorkflows` step (dead code after JS change).

**`PreparePaymentWithPreprocessing`** (new, follows EndSale pattern):
```
PreWorkflows := AddPreWorkflowsToRun(Context);
if PreWorkflows.Keys.Count() <> 0 then begin
    Response.Add('preWorkflows', PreWorkflows);
    exit;  // Frontend runs these, then calls continuePaymentWorkflow
end;
Response := PreparePaymentAndDetectPostprocessing(Sale, PaymentLine, Context);
```

**`PreparePaymentAndDetectPostprocessing`** (new):
```
Response := PreparePayment(Sale, PaymentLine, Context);
if HULAuditMgt.HasPaymentPostprocessingWorkflow(Sale) then
    Response.Add('needsPostprocessingWorkflows', true);
```

**`CollectPostprocessingWorkflows`** (replaces old `PreparePostWorkflows`):
```
PostWorkflows.ReadFrom('{}');
HULAuditMgt.AddPaymentPostprocessingWorkflow(Context, Sale, PaymentLine, PostWorkflows);
Response.Add('postWorkflows', PostWorkflows);
```

**`PreparePayment`**: unchanged.

**`AddPreWorkflowsToRun`**: unchanged (still fires `OnAddPreWorkflowsToRun` event).

**Event `OnAddPostWorkflowsToRun`** on `PaymentProcessingEvents`: removed. Can be re-introduced in a better way if needed in the future.

### Payment workflow frontend changes (`POSActionPaymentWF2.Codeunit.js`)

```javascript
const main = async ({ workflow, popup, parameters, context, captions }) => {
  const { HideAmountDialog, HideZeroAmountDialog } = parameters;

  let result = await workflow.respond("preparePaymentWorkflow");

  if (result.preWorkflows) {
    for (const [name, params] of Object.entries(result.preWorkflows)) {
      if (name) await workflow.run(name, { parameters: params });
    }
    result = await workflow.respond("continuePaymentWorkflow");
  }

  const {
    dispatchToWorkflow, paymentType, remainingAmount, paymentDescription,
    amountPrompt, forceAmount, mmPaymentMethodAssigned, collectReturnInformation,
    EnableMemberSubscPayerEmail, membershipEmail,     needsPostprocessingWorkflows,
  } = result;

  if (mmPaymentMethodAssigned) {
    if (!(await popup.confirm(captions.paymentMethodAssignedCaption))) return {};
  }
  if (EnableMemberSubscPayerEmail) {
    context.membershipPayerEmail = await popup.input({
      title: captions.MembershipSubscPayerEmailTitle,
      caption: captions.MembershipSubscPayerEmailCaption,
      value: membershipEmail,
    });
    if (context.membershipPayerEmail === null) return {};
    await workflow.respond("SetMembershipSubscPayerEmail");
  }

  let suggestedAmount = remainingAmount;
  if (!HideAmountDialog && (!HideZeroAmountDialog || remainingAmount > 0)) {
    suggestedAmount = await popup.numpad({
      title: paymentDescription,
      caption: amountPrompt,
      value: remainingAmount,
    });
    if (suggestedAmount === null) return {};
    if (suggestedAmount === 0 && remainingAmount > 0) return {};
  }
  if (collectReturnInformation) {
    if (remainingAmount === suggestedAmount) {
      const dataCollectionResponse = await workflow.run("DATA_COLLECTION", {
        parameters: { requestCollectInformation: "ReturnInformation" },
      });
      if (!dataCollectionResponse.success) return {};
    }
  }

  if (needsPostprocessingWorkflows) {
    let { postWorkflows } = await workflow.respond("preparePostWorkflows", {
      paymentAmount: suggestedAmount,
    });
    await processWorkflows(postWorkflows);
  }

  if (suggestedAmount === 0 && remainingAmount === 0 && !forceAmount) {
    await workflow.run("END_SALE", {
      parameters: { calledFromWorkflow: "PAYMENT_2", paymentNo: parameters.paymentNo },
    });
    return {};
  }

  const paymentResult = await workflow.run(dispatchToWorkflow, {
    context: { paymentType, suggestedAmount, remainingAmount },
  });

  if (paymentResult.legacy) {
    context.fallbackAmount = suggestedAmount;
    await workflow.respond("doLegacyPaymentWorkflow");
  } else if (paymentResult.tryEndSale && parameters.tryEndSale) {
    await workflow.run("END_SALE", {
      parameters: { calledFromWorkflow: "PAYMENT_2", paymentNo: parameters.paymentNo },
    });
  }

  return { success: paymentResult.success };
};

async function processWorkflows(workflows) {
  if (!workflows) return;
  for (const [workflowName, { mainParameters, customParameters }] of Object.entries(workflows)) {
    await workflow.run(workflowName, {
      context: { customParameters },
      parameters: mainParameters,
    });
  }
}
```

## Roundtrip Summary

| Scenario | Before | After | Savings |
|----------|--------|-------|---------|
| No preprocessing, HU Laurel not enabled (95%+) | 3 | **1** | ~400ms |
| No preprocessing, HU Laurel enabled | 3 | **2** | ~200ms |
| Has preprocessing subscribers, HU Laurel not enabled | 3 | **2** | ~200ms |
| Has preprocessing + HU Laurel enabled | 3 | **3** | 0ms |

## What Stays Unchanged

- `AddPreWorkflowsToRun` + `OnAddPreWorkflowsToRun` event (pre-workflows still use the event)
- `PreparePayment` procedure (core payment preparation logic)
- All user dialog logic (membership email, numpad, data collection)
- Payment dispatch flow (`dispatchToWorkflow`, legacy, END_SALE)
- `processWorkflows` helper function
- `PaymentProcessingEvents` codeunit (only `OnAddPostWorkflowsToRun` removed; other events unchanged)

## Future Considerations

If `OnAddPostWorkflowsToRun` ever needs to be exposed as public for PTEs, the control flow can be extended with an `EventSubscription` table check to detect external subscribers and decide whether to make a separate call, similar to how `POSActionInsertItem` checks for subscribers.
