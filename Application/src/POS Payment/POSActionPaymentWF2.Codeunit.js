/*
    POSActionPaymentWF2.Codeunit.js
*/
let main = async ({ workflow, popup, scope, parameters, context }) => {

    const {HideAmountDialog, HideZeroAmountDialog} = parameters;
    const {dispatchToWorkflow, paymentType, remainingAmount, paymentDescription, amountPrompt} = await workflow.respond("preparePaymentWorkflow");

    let suggestedAmount = remainingAmount;
    if ((!HideAmountDialog) && ((!HideZeroAmountDialog) || (remainingAmount > 0))) {
        suggestedAmount = await popup.numpad ({title: paymentDescription, caption: amountPrompt, value: remainingAmount});
        if (suggestedAmount === null) return; // user cancelled dialog
    };

    let paymentResult = await workflow.run(dispatchToWorkflow, { context: {paymentType: paymentType, suggestedAmount: suggestedAmount}});
    
    if (paymentResult.legacy) {
        context.fallbackAmount = suggestedAmount;
        await workflow.respond("doLegacyPaymentWorkflow");
    } else if (paymentResult.tryEndSale) {
        await workflow.respond("tryEndSale");
    }
};

