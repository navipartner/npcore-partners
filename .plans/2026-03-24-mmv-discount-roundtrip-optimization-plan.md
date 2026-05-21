# Discount Roundtrip Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:executing-plans to implement this plan task-by-task.

**Goal:** Eliminate the unnecessary `PreparePostWorkflows` roundtrip (~200ms) from the DISCOUNT action by merging post-workflow collection into the `ProcessRequest` response.

**Architecture:** Follow the ChangeView pattern (commit `4d7bce8c1`). The `ProcessRequest` AL step applies the discount AND collects post-workflows in one response. The JS reads `postWorkflows` from that response instead of making a second call.

**Tech Stack:** AL (Business Central), JavaScript (POS frontend)

---

### Task 1: Modify AL — merge post-workflows into ProcessRequest

**Files:**
- Modify: `Application/src/POS Action (with Misc actions)/Discount/POSActionDiscount.Codeunit.al:99-121`

**Step 1: Change `ProcessRequest` to return a named variable and append post-workflows**

Replace the current `ProcessRequest` procedure (lines 123-169) with a version that:
1. Uses a named return variable `Response: JsonObject`
2. After the existing discount logic, collects post-workflows and adds them to `Response`

```al
    local procedure ProcessRequest(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        DiscountInput: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        View: Codeunit "NPR POS View";
        ApprovedBySalesperson: Code[20];
        PresetMultiLineDiscTarget: Integer;
        DiscountReasonCode: Code[10];
        DimensionCode: Text;
        DimensionValue: Text;
        DiscountGroupFilter: Text;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        POSSession: Codeunit "NPR POS Session";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        SecureContextId: Text;
        SecureMethodHelper: Codeunit "NPR POS Secure Method Helper";
        POSActionPublishers: Codeunit "NPR POS Action Publishers";
        PostWorkflows: JsonObject;
    begin
        if Context.GetString('secureMethodContextId', SecureContextId) then
            ApprovedBySalesperson := SecureMethodHelper.GetSalespersonCode(SecureContextId);

        DiscountInput := Context.GetDecimal('discountNumber');
        DiscountType := Context.GetIntegerParameter('DiscountType');
        POSActionDiscountB.CheckNegativeAmount(DiscountType, DiscountInput);

        PresetMultiLineDiscTarget := Context.GetIntegerParameter('TotalDiscTargetLines');
        DiscountGroupFilter := Context.GetStringParameter('DiscountGroupFilter');
        InputIncludesTax := Context.GetIntegerParameter('AmtIncludesTax');
        DimensionCode := Context.GetStringParameter('DimensionCode');

        ReadReasonCode(Context, DiscountReasonCode);
        ReadDimensionValue(Context, DimensionValue);

        Sale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLine.RefreshxRec();
        POSSession.GetCurrentView(View);
#pragma warning disable AA0139
        POSActionDiscountB.StoreAdditionalParams(ApprovedBySalesperson, DiscountReasonCode, DimensionCode, DimensionValue, DiscountGroupFilter, InputIncludesTax);
#pragma warning restore
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountInput, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);

        SaleLine.RefreshCurrent();
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLine.OnAfterSetQuantity(SaleLinePOS);

        PostWorkflows.ReadFrom('{}');
        POSActionPublishers.OnAddPostWorkflowsToRunOnDiscount(Context, Sale, SaleLine, PostWorkflows);
        Response.Add('postWorkflows', PostWorkflows);
    end;
```

**Step 2: Remove the `PreparePostWorkflows` case and procedure**

In `RunWorkflow` (lines 99-111), remove lines 108-109:
```al
            'PreparePostWorkflows':
                FrontEnd.WorkflowResponse(PreparePostWorkflows(Context, Sale, SaleLine));
```

Delete the entire `PreparePostWorkflows` procedure (lines 113-121).

**Step 3: Verify the AL file compiles**

Run: `Use /bcdev skill to compile`

---

### Task 2: Modify JS — remove separate PreparePostWorkflows call

**Files:**
- Modify: `Application/src/POS Action (with Misc actions)/Discount/POSActionDiscount.js`

**Step 1: Update the JS source file**

Replace lines 97-101 (the two separate calls) with a single destructuring call:

```javascript
    const { postWorkflows } = await workflow.respond("ProcessRequest", { discountNumber: discountNumber, discountReason, dimensionValue });
    await processWorkflows(workflow, postWorkflows);
```

Also fix the `processWorkflows` function (lines 104-110) to accept `workflow` as a parameter (same pattern as the ChangeView fix):

```javascript
async function processWorkflows(workflow, workflows) {
  if (!workflows) return;

  for (const [workflowName, { mainParameters, customParameters }] of Object.entries(workflows)) {
    await workflow.run(workflowName, { context: { customParameters }, parameters: mainParameters });
  }
}
```

Remove the `debugger;` statement on line 2 (leftover debug artifact).

**Step 2: Regenerate the minified inline copy in the AL file**

Minify the updated JS and replace the inline string in `GetActionScript()` (line 175 of the .al file). The minified JS must match the source `.js` file exactly in behavior.

The minified version:

```javascript
const main=async({workflow:a,captions:e,parameters:s,popup:o})=>{let n,t,i,r={discountReason:s.FixedReasonCode};""==r.discountReason&&(s.LookupReasonCode||s.ReasonCodeMandatory)&&(r=await a.respond("LookupReasonCode")),i=s.DimensionCode;let u={dimensionValue:s.DimensionValue};switch(""!=i&&""==u.dimensionValue&&(u=await a.respond("AddDimensionValue")),n=s.FixedDiscountNumber,s._parameters.DiscountType){case 0:t=e.DiscountLabel0,0==n&&(n=await o.numpad(t));break;case 1:t=e.DiscountLabel1,0==n&&(n=await o.numpad(t));break;case 2:t=e.DiscountLabel2,0==n&&(n=await o.numpad(t));break;case 3:t=e.DiscountLabel3,0==n&&(n=await o.numpad(t));break;case 4:t=e.DiscountLabel4,0==n&&(n=await o.numpad(t));break;case 5:t=e.DiscountLabel5,0==n&&(n=await o.numpad(t));break;case 6:t=e.DiscountLabel6,0==n&&(n=await o.numpad(t));break;case 7:t=e.DiscountLabel7,0==n&&(n=await o.numpad(t));break;case 8:t=e.DiscountLabel8,0==n&&(n=await o.numpad(t));break;case 9:case 10:break;case 11:t=e.DiscountLabel11,0==n&&(n=await o.numpad(t));break;case 12:t=e.DiscountLabel12,0==n&&(n=await o.numpad(t))}if(null===n)return;const{postWorkflows:c}=await a.respond("ProcessRequest",{discountNumber:n,discountReason:r,dimensionValue:u});await processWorkflows(a,c)};async function processWorkflows(a,e){if(e)for(const[s,{mainParameters:o,customParameters:n}]of Object.entries(e))await a.run(s,{context:{customParameters:n},parameters:o})}
```

---

### Task 3: Compile and commit

**Step 1: Compile the AL app**

Run: `Use /bcdev skill to download symbols and compile`
Expected: Clean compilation with no errors.

**Step 2: Commit**

```bash
git add "Application/src/POS Action (with Misc actions)/Discount/POSActionDiscount.Codeunit.al" "Application/src/POS Action (with Misc actions)/Discount/POSActionDiscount.js"
git commit -m "perf: merge post-workflow roundtrip into ProcessRequest for DISCOUNT action

Eliminates separate PreparePostWorkflows roundtrip (~200ms) by collecting
post-workflows in the ProcessRequest response. Same pattern as ChangeView
(4d7bce8c1) and Payment (d67c3ce8b) optimizations.

Before: ProcessRequest → PreparePostWorkflows (2 roundtrips)
After:  ProcessRequest + PostWorkflows (1 roundtrip)"
```
