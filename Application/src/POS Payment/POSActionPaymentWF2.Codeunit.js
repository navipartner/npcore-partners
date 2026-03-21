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
