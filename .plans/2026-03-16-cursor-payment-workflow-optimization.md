# Payment Workflow Optimization — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reduce payment button BC roundtrips from 3 to 1 (common case) by merging preprocessing + payment preparation + postprocessing detection into a single call.

**Architecture:** Follow the EndSale pattern for preprocessing workflows. Convert HU Laurel's event subscriber to direct function calls for postprocessing workflow detection. Frontend restructured to use a single initial call with conditional follow-ups.

**Tech Stack:** AL (Business Central), JavaScript (POS frontend)

---

### Task 1: Add direct callable procedures to HU Laurel

**Files:**
- Modify: `Application/src/POS Compliance/[HU] Laurel/HULAuditMgt.Codeunit.al`

**Step 1: Add `HasPaymentPostprocessingWorkflow` procedure**

Add this new procedure after line 469 (after the existing `OnAddPostWorkflowsToRun` subscriber):

```al
    internal procedure HasPaymentPostprocessingWorkflow(Sale: Codeunit "NPR POS Sale"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        if not POSUnit.Get(POSSale."Register No.") then
            exit(false);
        exit(IsHULaurelAuditEnabled(POSUnit."POS Audit Profile"));
    end;
```

**Step 2: Add `AddPaymentPostprocessingWorkflow` procedure**

Add right after `HasPaymentPostprocessingWorkflow`:

```al
    internal procedure AddPaymentPostprocessingWorkflow(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; var PostWorkflows: JsonObject)
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Record "NPR POS Sale";
        POSActionHULFPDisplay: Codeunit "NPR POS Action: HUL FP Display";
        ActionParameters: JsonObject;
        MainParameters: JsonObject;
        PaymentAmount: Decimal;
        PaymentAmountText: Text;
    begin
        Sale.GetCurrentSale(POSSale);
        if not POSUnit.Get(POSSale."Register No.") then
            exit;
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if Evaluate(PaymentAmount, Context.GetString('paymentAmount'), 9) then begin
            if PaymentAmount = 0 then
                exit;
            PaymentAmountText := FormatDecimalValue(PaymentAmount)
        end else
            PaymentAmountText := Context.GetString('paymentAmount');

        MainParameters.Add(POSActionHULFPDisplay.RowOneMessageParameterName(), GetPOSPaymentMethodDesc(Context.GetStringParameter('paymentNo')));
        MainParameters.Add(POSActionHULFPDisplay.RowTwoMessageParameterName(), FormatTwoColumnCustDisplayText(' ', PaymentAmountText));
        MainParameters.Add(POSActionHULFPDisplay.CalledFromParameterName(), DisplayCalledFrom::payment);
        ActionParameters.Add('mainParameters', MainParameters);
        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::HUL_FP_DISPLAY), ActionParameters);
    end;
```

**Step 3: Remove the event subscriber**

Delete the entire event subscriber procedure at lines 440-469:
```al
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Payment Processing Events", 'OnAddPostWorkflowsToRun', '', false, false)]
    local procedure OnAddPostWorkflowsToRun(...)
    ...
    end;
```

The logic is now covered by the two new direct callable procedures above.

**Step 4: Commit**

```bash
git add "Application/src/POS Compliance/[HU] Laurel/HULAuditMgt.Codeunit.al"
git commit -m "refactor(CORE-163): extract HU Laurel postprocessing workflow into direct callable procedures

Replace the OnAddPostWorkflowsToRun event subscriber with two direct callable
procedures: HasPaymentPostprocessingWorkflow (lightweight check) and
AddPaymentPostprocessingWorkflow (actual workflow builder). This enables the
payment workflow to detect and collect postprocessing workflows without
unnecessary BC roundtrips.

The internal event on PaymentProcessingEvents is left declared but unused.
It can be re-introduced in a better way if needed in the future."
```

---

### Task 2: Refactor payment workflow backend (AL)

**Files:**
- Modify: `Application/src/POS Payment/POSActionPaymentWF2.Codeunit.al`

**Step 1: Update RunWorkflow case statement**

Replace the current case statement (lines 35-48):

```al
        case Step of
            'preparePreWorkflows':
                Frontend.WorkflowResponse(PreparePreWorkflows(Context));
            'preparePaymentWorkflow':
                Frontend.WorkflowResponse(PreparePayment(Sale, PaymentLine, Context));
            'SetMembershipSubscPayerEmail':
                SetMembershipSubscPayerEmail(Context, Sale);
            'tryEndSale':
                Frontend.WorkflowResponse(AttemptEndSale(Context));
            'doLegacyPaymentWorkflow':
                Frontend.WorkflowResponse(DoLegacyPayment(Context, FrontEnd));
            'preparePostWorkflows':
                Frontend.WorkflowResponse(PreparePostWorkflows(Context, Sale, PaymentLine));
        end;
```

With:

```al
        case Step of
            'preparePaymentWorkflow':
                Frontend.WorkflowResponse(PreparePaymentWithPreprocessing(Sale, PaymentLine, Context));
            'continuePaymentWorkflow':
                Frontend.WorkflowResponse(PreparePaymentAndDetectPostprocessing(Sale, PaymentLine, Context));
            'SetMembershipSubscPayerEmail':
                SetMembershipSubscPayerEmail(Context, Sale);
            'tryEndSale':
                Frontend.WorkflowResponse(AttemptEndSale(Context));
            'doLegacyPaymentWorkflow':
                Frontend.WorkflowResponse(DoLegacyPayment(Context, FrontEnd));
            'preparePostWorkflows':
                Frontend.WorkflowResponse(CollectPostprocessingWorkflows(Context, Sale, PaymentLine));
        end;
```

**Step 2: Add `PreparePaymentWithPreprocessing` procedure**

Add this new procedure after the `RunWorkflow` procedure (after line 49). This follows the EndSale pattern:

```al
    local procedure PreparePaymentWithPreprocessing(Sale: codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        PreWorkflows: JsonObject;
    begin
        PreWorkflows := AddPreWorkflowsToRun(Context);
        if PreWorkflows.Keys.Count() <> 0 then begin
            Response.Add('preWorkflows', PreWorkflows);
            exit(Response);
        end;

        Response := PreparePaymentAndDetectPostprocessing(Sale, PaymentLine, Context);
    end;
```

**Step 3: Add `PreparePaymentAndDetectPostprocessing` procedure**

Add right after `PreparePaymentWithPreprocessing`:

```al
    local procedure PreparePaymentAndDetectPostprocessing(Sale: codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
    begin
        Response := PreparePayment(Sale, PaymentLine, Context);

        if HULAuditMgt.HasPaymentPostprocessingWorkflow(Sale) then
            Response.Add('needsPostprocessingWorkflows', true);
    end;
```

**Step 4: Replace `PreparePostWorkflows` with `CollectPostprocessingWorkflows`**

Replace the existing `PreparePostWorkflows` procedure (lines 115-123):

```al
    local procedure PreparePostWorkflows(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line") Response: JsonObject
    var
        PmtProcessingEvents: Codeunit "NPR Payment Processing Events";
        PostWorkflows: JsonObject;
    begin
        PostWorkflows.ReadFrom('{}');
        PmtProcessingEvents.OnAddPostWorkflowsToRun(Context, Sale, PaymentLine, PostWorkflows);
        Response.Add('postWorkflows', PostWorkflows);
    end;
```

With:

```al
    local procedure CollectPostprocessingWorkflows(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line") Response: JsonObject
    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
        PostWorkflows: JsonObject;
    begin
        PostWorkflows.ReadFrom('{}');
        HULAuditMgt.AddPaymentPostprocessingWorkflow(Context, Sale, PaymentLine, PostWorkflows);
        Response.Add('postWorkflows', PostWorkflows);
    end;
```

**Step 5: Remove dead `PreparePreWorkflows` procedure**

Delete the `PreparePreWorkflows` procedure (lines 95-99) since it's no longer called:

```al
    local procedure PreparePreWorkflows(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    begin
        Response.Add('preWorkflows', AddPreWorkflowsToRun(Context));
        exit(Response);
    end;
```

`AddPreWorkflowsToRun` stays — it's called by the new `PreparePaymentWithPreprocessing`.

**Step 6: Remove the unused `OnAddPostWorkflowsToRun` internal event publisher**

In `Application/src/POS Payment/_public/PaymentProcessingEvents.Codeunit.al`, delete the event publisher (lines 10-13):

```al
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; var PostWorkflows: JsonObject)
    begin
    end;
```

This event is no longer fired. It can be re-introduced in a better way if needed in the future.

**Step 7: Commit**

```bash
git add "Application/src/POS Payment/POSActionPaymentWF2.Codeunit.al" "Application/src/POS Payment/_public/PaymentProcessingEvents.Codeunit.al"
git commit -m "refactor(CORE-163): merge payment workflow BC roundtrips in backend

- preparePaymentWorkflow now collects preprocessing workflows first (EndSale
  pattern): exits early with preWorkflows if subscribers exist, otherwise falls
  through to full payment preparation + postprocessing detection.
- New continuePaymentWorkflow step for after preprocessing workflows ran.
- Postprocessing detection uses direct HULAuditMgt call, returning
  needsPostprocessingWorkflows flag.
- preparePostWorkflows step kept for when needsPostprocessingWorkflows is true,
  now using direct HULAuditMgt.AddPaymentPostprocessingWorkflow call.
- Removed unused OnAddPostWorkflowsToRun event publisher."
```

---

### Task 3: Refactor payment workflow frontend (JS)

**Files:**
- Modify: `Application/src/POS Payment/POSActionPaymentWF2.Codeunit.js`

**Step 1: Rewrite the JS file**

Replace the entire contents of `POSActionPaymentWF2.Codeunit.js` with:

```javascript
/*
    POSActionPaymentWF2.Codeunit.js
*/
const main = async ({ workflow, popup, parameters, context, captions }) => {
  const { HideAmountDialog, HideZeroAmountDialog } = parameters;

  let result = await workflow.respond("preparePaymentWorkflow");

  if (result.preWorkflows) {
    for (const [preWorkflowName, preWorkflowParameters] of Object.entries(
      result.preWorkflows
    )) {
      if (preWorkflowName) {
        await workflow.run(preWorkflowName, {
          parameters: preWorkflowParameters,
        });
      }
    }
    result = await workflow.respond("continuePaymentWorkflow");
  }

  const {
    dispatchToWorkflow,
    paymentType,
    remainingAmount,
    paymentDescription,
    amountPrompt,
    forceAmount,
    mmPaymentMethodAssigned,
    collectReturnInformation,
    EnableMemberSubscPayerEmail,
    membershipEmail,
    needsPostprocessingWorkflows,
  } = result;

  if (mmPaymentMethodAssigned) {
    if (!(await popup.confirm(captions.paymentMethodAssignedCaption)))
      return {};
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
        parameters: {
          requestCollectInformation: "ReturnInformation",
        },
      });
      if (!dataCollectionResponse.success) {
        return {};
      }
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
      parameters: {
        calledFromWorkflow: "PAYMENT_2",
        paymentNo: parameters.paymentNo,
      },
    });
    return {};
  }

  const paymentResult = await workflow.run(dispatchToWorkflow, {
    context: {
      paymentType: paymentType,
      suggestedAmount: suggestedAmount,
      remainingAmount: remainingAmount,
    },
  });

  if (paymentResult.legacy) {
    context.fallbackAmount = suggestedAmount;
    await workflow.respond("doLegacyPaymentWorkflow");
  } else if (paymentResult.tryEndSale && parameters.tryEndSale) {
    await workflow.run("END_SALE", {
      parameters: {
        calledFromWorkflow: "PAYMENT_2",
        paymentNo: parameters.paymentNo,
      },
    });
  }

  return { success: paymentResult.success };
};

async function processWorkflows(workflows) {
  if (!workflows) return;

  for (const [
    workflowName,
    { mainParameters, customParameters },
  ] of Object.entries(workflows)) {
    await workflow.run(workflowName, {
      context: { customParameters },
      parameters: mainParameters,
    });
  }
}
```

**Step 2: Commit**

```bash
git add "Application/src/POS Payment/POSActionPaymentWF2.Codeunit.js"
git commit -m "refactor(CORE-163): merge payment workflow BC roundtrips in frontend

- Single initial workflow.respond('preparePaymentWorkflow') now handles
  preprocessing workflows + payment preparation + postprocessing detection.
- Only calls continuePaymentWorkflow if preprocessing workflows were returned.
- Only calls preparePostWorkflows if needsPostprocessingWorkflows is true.
- All user dialog logic (numpad, membership email, etc.) unchanged.
- Reduces common-case roundtrips from 3 to 1 (~400ms savings on BC SaaS)."
```

---

### Task 4: Update the minified JS in GetActionScript

**Files:**
- Modify: `Application/src/POS Payment/POSActionPaymentWF2.Codeunit.al` (line 217-218)

The AL file contains a minified copy of the JS at line 217-218 via `//###NPR_INJECT_FROM_FILE:POSActionPaymentWF2.Codeunit.js###`. This is auto-injected by the build pipeline, so we just need to verify the `NPR_INJECT_FROM_FILE` comment still references the correct filename.

**Step 1: Verify the inject comment**

Check that line 217 of the AL file still reads:
```
//###NPR_INJECT_FROM_FILE:POSActionPaymentWF2.Codeunit.js###
```

If the build pipeline auto-replaces the minified JS from the `.js` file, no manual update is needed. If it does NOT auto-replace, manually minify the JS and update line 218.

**Step 2: Commit (only if manual minification was needed)**

```bash
git add "Application/src/POS Payment/POSActionPaymentWF2.Codeunit.al"
git commit -m "build(CORE-163): update minified JS in GetActionScript"
```

---

### Task 5: Final review and verification

**Step 1: Verify no broken references**

Search the codebase for any remaining references to the removed `preparePreWorkflows` step name in PaymentWF2:

```bash
rg "preparePreWorkflows" --glob "*PaymentWF2*"
```

Expected: no hits.

**Step 2: Verify HU Laurel event subscriber is fully removed**

```bash
rg "EventSubscriber.*OnAddPostWorkflowsToRun" --glob "*HULAuditMgt*"
```

Expected: no hits.

**Step 3: Verify the internal event publisher is removed from PaymentProcessingEvents**

```bash
rg "OnAddPostWorkflowsToRun" --glob "*PaymentProcessingEvents*"
```

Expected: no hits.

**Step 4: Review the flow end-to-end**

Walk through each scenario mentally:

1. **No preprocessing workflows, no HU Laurel** → `preparePaymentWorkflow` returns full payment data, `needsPostprocessingWorkflows` absent/falsy → 1 call
2. **No preprocessing workflows, HU Laurel enabled** → `preparePaymentWorkflow` returns payment data + `needsPostprocessingWorkflows: true` → `preparePostWorkflows` called with `paymentAmount` → 2 calls
3. **Has preprocessing workflows, no HU Laurel** → `preparePaymentWorkflow` returns `preWorkflows` → frontend runs them → `continuePaymentWorkflow` returns payment data → 2 calls
4. **Has preprocessing + HU Laurel** → `preparePaymentWorkflow` returns `preWorkflows` → frontend runs them → `continuePaymentWorkflow` returns payment data + `needsPostprocessingWorkflows: true` → `preparePostWorkflows` → 3 calls

**Step 5: Commit any fixes and push**

```bash
git push -u origin cursor/CORE-163-payment-workflow-optimization-f60b
```
