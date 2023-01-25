let main = async ({ workflow, context, popup, parameters, captions}) => {
    debugger;

    if (parameters.ReferenceBarcode === "")
    {
        workflow.context.ReferenceBarcode = await popup.input({ title: captions.title, caption: captions.refprompt})
        if (workflow.context.ReferenceBarcode === null){
            return;
        }
    }
    if (parameters.AskReturnReason){
        const{ReturnReasonCode} = await workflow.respond("PromptForReason");
        await workflow.respond("handle",{ReturnReasonCode:ReturnReasonCode});
    }
    else
        await workflow.respond("handle"); 

    if (parameters.ExportReturnOrd){ 
            await workflow.respond("ExportPurchaseReturnOrder");  
        }
}