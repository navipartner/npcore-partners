/*
    POSActionPaymentWF2.Codeunit.js
*/
const main = async ({ workflow, popup, parameters, context }) => {
  const { HideAmountDialog, HideZeroAmountDialog } = parameters;
  const { preWorkflows } = await workflow.respond("preparePreWorkflows");

  if (preWorkflows) {
    for (const preWorkflow of Object.entries(preWorkflows)) {
      const [preWorkflowName, preWorkflowParameters] = preWorkflow;
      if (preWorkflowName) {
        await workflow.run(preWorkflowName, {
          parameters: preWorkflowParameters,
        });
      }
    }
  }

  const {
    dispatchToWorkflow,
    paymentType,
    remainingAmount,
    paymentDescription,
    amountPrompt,
  } = await workflow.respond("preparePaymentWorkflow");

  let suggestedAmount = remainingAmount;
  if (!HideAmountDialog && (!HideZeroAmountDialog || remainingAmount > 0)) {
    suggestedAmount = await popup.numpad({
      title: paymentDescription,
      caption: amountPrompt,
      value: remainingAmount,
    });
    if (suggestedAmount === null) return; // user cancelled dialog
    if (suggestedAmount == 0 && remainingAmount > 0) return; // user paid 0 with remaining amount
  }

  if (suggestedAmount == 0 && remainingAmount == 0) {
    await workflow.run("END_SALE", {
      parameters: {
        calledFromWorkflow: "PAYMENT_2",
        paymentNo: parameters.paymentNo,
      },
    });
    return;
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
  } else if (paymentResult.tryEndSale) {
    await workflow.run("END_SALE", {
      parameters: {
        calledFromWorkflow: "PAYMENT_2",
        paymentNo: parameters.paymentNo,
      },
    });
  }
};
