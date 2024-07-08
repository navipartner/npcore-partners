/*
    POSActionCashPayment.Codeunit.js
*/ 
let main = async({workflow, context})=> {
    return await workflow.respond("CapturePayment",{amountToCapture: context.suggestedAmount});
}
