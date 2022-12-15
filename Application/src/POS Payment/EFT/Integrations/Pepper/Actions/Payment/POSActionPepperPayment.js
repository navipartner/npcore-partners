/*
    POSActionPepperPayment.Codeunit.js
*/
let main = async ({ workflow, popup, scope, parameters, context }) => {

    debugger;
    const {HideAmountDialog, HideZeroAmountDialog} = parameters;
    const {paymentNo, remainingAmount, paymentDescription, amountPrompt} = await workflow.respond("PreparePepperPayment");

    debugger;
    let suggestedAmount = remainingAmount;
    if ((!HideAmountDialog) && ((!HideZeroAmountDialog) || (remainingAmount > 0))) {
        suggestedAmount = await popup.numpad ({title: paymentDescription, caption: amountPrompt, value: remainingAmount});
        if (suggestedAmount === null) return; // user cancelled dialog
    };

    debugger;
    const eftRequest = await workflow.respond('CreateEftRequest', {paymentNo: paymentNo, suggestedAmount: suggestedAmount});
    const {integrationRequest, showSuccessMessage, showSpinner, workflowName } = eftRequest;
   
    debugger;
    const eftResult = await workflow.run(workflowName, { context: { request: integrationRequest, showSpinner: showSpinner, showSuccessMessage: showSuccessMessage } });
    const {success, tryEndSale}  = eftResult;
    
    debugger;
    if (success && tryEndSale)
        await workflow.respond("TryEndSale", {paymentNo: paymentNo});
    
};

