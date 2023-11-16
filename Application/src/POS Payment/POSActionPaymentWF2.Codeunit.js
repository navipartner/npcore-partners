/*
    POSActionPaymentWF2.Codeunit.js
*/
let main = async ({ workflow, popup, scope, parameters, context }) => {

    const { HideAmountDialog, HideZeroAmountDialog } = parameters;
    const { preWorkflows } = await workflow.respond("preparePreWorkflows");

    if (preWorkflows) {
        for (const preWorkflow of Object.entries(preWorkflows)) {
            let [preWorkflowName, preWorkflowParameters] = preWorkflow;
            if (preWorkflowName) {
                await workflow.run(preWorkflowName, { parameters: preWorkflowParameters });
            };
        };
    };

    const { dispatchToWorkflow, paymentType, remainingAmount, paymentDescription, amountPrompt, endSaleWorkflowEnabled } = await workflow.respond("preparePaymentWorkflow");

    let suggestedAmount = remainingAmount;
    if ((!HideAmountDialog) && ((!HideZeroAmountDialog) || (remainingAmount > 0))) {
        suggestedAmount = await popup.numpad({ title: paymentDescription, caption: amountPrompt, value: remainingAmount });
        if (suggestedAmount === null) return; // user cancelled dialog
    };

    if(remainingAmount == 0){
        if (endSaleWorkflowEnabled) {
            await workflow.run('END_SALE', { parameters: { calledFromWorkflow: 'PAYMENT_2', paymentNo: parameters.paymentNo } });
        } else {
            await workflow.respond("tryEndSale");
        }
        return;
    }

    let paymentResult = await workflow.run(dispatchToWorkflow, { context: { paymentType: paymentType, suggestedAmount: suggestedAmount } });

    if (paymentResult.legacy) {
        context.fallbackAmount = suggestedAmount;
        await workflow.respond("doLegacyPaymentWorkflow");
    } else if (paymentResult.tryEndSale) {
        if (endSaleWorkflowEnabled) {
            await workflow.run('END_SALE', { parameters: { calledFromWorkflow: 'PAYMENT_2', paymentNo: parameters.paymentNo } });
        } else {
            await workflow.respond("tryEndSale");
        }
    }
};
