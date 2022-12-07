let main = async ({ workflow, context, popup, parameters, captions}) => {

    if (parameters.ReferenceBarcode === "")
    {
        workflow.context.ReferenceBarcode = await popup.input({ title: captions.title, caption: captions.refprompt})
        if (workflow.context.ReferenceBarcode === null){
            return;
        }
    }

    const{ReturnReasonCode} = await workflow.respond("PromptForReason");
    await workflow.respond("handle",{ReturnReasonCode:ReturnReasonCode});

    if (parameters.ExportReturnOrd){
        await workflow.respond("ExportReturnOrder");        
    }
}