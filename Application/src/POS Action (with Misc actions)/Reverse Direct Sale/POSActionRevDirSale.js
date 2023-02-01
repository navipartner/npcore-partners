let main = async ({ workflow, context, scope, popup, parameters, captions }) => {

    workflow.context.receipt = await popup.input({ title: captions.title, caption: captions.receiptprompt}) 
    if (workflow.context.receipt === null) {
        return;
    }
    if (workflow.context.receipt.length > 50) {
        await popup.error(captions.lengtherror);
        return(" ");
    }
    var PromptForReason = await workflow.respond("reason");

    if (PromptForReason)
    {
        var ReturnReasonCode = await workflow.respond("SelectReturnReason");
        if (ReturnReasonCode === null) {
            return;
        }
    }
    else
    {
        var ReturnReasonCode = '';
    }

    await workflow.respond("handle",{PromptForReason, ReturnReasonCode});
}