# Discount Workflow Roundtrip Optimization

## Problem

Every DISCOUNT action click makes a separate `PreparePostWorkflows` roundtrip (~200ms) after `ProcessRequest`. The only subscriber to `OnAddPostWorkflowsToRunOnDiscount` is HU Laurel (Hungarian POS units), meaning 95%+ of users pay ~200ms for an empty response.

This is the same pattern fixed in:
- ChangeView (`4d7bce8c1`) — merged AddPostWorkflowsToRun into ChangeView response
- Payment (`d67c3ce8b`) — merged pre/post workflow collection into payment preparation

## Solution

Merge `PreparePostWorkflows` into the `ProcessRequest` step (ChangeView pattern). No backward compatibility shim for the removed step.

### Before (2 roundtrips for common path)
```
Frontend → BC: ProcessRequest        (~Xms)
Frontend → BC: PreparePostWorkflows  (~200ms)  ← unnecessary
```

### After (1 roundtrip)
```
Frontend → BC: ProcessRequest + PostWorkflows  (~Xms)
```

## Changes

### POSActionDiscount.Codeunit.al
- `RunWorkflow`: Remove `'PreparePostWorkflows'` case
- `ProcessRequest`: After applying the discount, call post-workflow collection and include `postWorkflows` in the response JsonObject
- Remove `PreparePostWorkflows` procedure (inlined into ProcessRequest)

### POSActionDiscount.js (and minified inline copy)
- Remove `await workflow.respond("PreparePostWorkflows")` call (line 99)
- Destructure `postWorkflows` from the `ProcessRequest` response
- Pass `workflow` reference to `processWorkflows` helper (same fix as ChangeView)
- Regenerate minified inline copy in .al file

## Impact
- HU Laurel's `OnAddPostWorkflowsToRunOnDiscount` event subscriber continues to work — the event fires in the same procedure, just called from a different step
- No new objects, dependencies, or schema changes
- ~200ms saved on every discount action click
