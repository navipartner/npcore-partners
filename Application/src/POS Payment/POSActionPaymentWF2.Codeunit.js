/*
    POSActionPaymentWF2.Codeunit.js
*/
let main = async ({ workflow, popup, scope, parameters, context }) => {

    const { HideAmountDialog, HideZeroAmountDialog } = parameters;
    const { dispatchToWorkflow, paymentType, remainingAmount, paymentDescription, amountPrompt, preWorkflows } = await workflow.respond("preparePaymentWorkflow");

    if (preWorkflows) {
        for (const preWorkflow of Object.entries(preWorkflows)) {
            let [preWorkflowName, preWorkflowParameters] = preWorkflow;
            if (preWorkflowName) {
                await workflow.run(preWorkflowName, { parameters: preWorkflowParameters });
            };
        };
    };

    let suggestedAmount = remainingAmount;
    if ((!HideAmountDialog) && ((!HideZeroAmountDialog) || (remainingAmount > 0))) {
        suggestedAmount = await popup.numpad({ title: paymentDescription, caption: amountPrompt, value: remainingAmount });
        if (!suggestedAmount) return; // user cancelled dialog
    };

    let paymentResult = await workflow.run(dispatchToWorkflow, { context: { paymentType: paymentType, suggestedAmount: suggestedAmount } });

    if (paymentResult.legacy) {
        context.fallbackAmount = suggestedAmount;
        await workflow.respond("doLegacyPaymentWorkflow");
    } else if (paymentResult.tryEndSale) {
        await workflow.respond("tryEndSale");
    }
};
