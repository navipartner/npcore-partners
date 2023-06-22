/*
    POSActionPaymentWithCheck.Codeunit.js
*/
let main = async ({ workflow, captions, context }) => {
    const { askForCheckNo } = await workflow.respond("PrepareWorkflow");
    
    if (askForCheckNo) {
        context.checkNo = await popup.input({ title: captions.checkTitle, caption: captions.checkNoDescription });
    }
    return await workflow.respond("CapturePayment", { amountToCapture: context.suggestedAmount, checkNo: context.checkNo });
}
