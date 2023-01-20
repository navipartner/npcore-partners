let main = async ({workflow, parameters,popup, captions, context}) => {
    if (parameters.DepositType == 1){
        context.PromptValue = await popup.input({caption: captions.InvoiceNoPrompt})
        if (context.PromptValue === null) {
            return;
        }
    }
    if (parameters.DepositType == 2){
        context.PromptAmt = await popup.numpad({caption: captions.AmountPrompt})
        if (context.PromptAmt === null) {
            return;
        }
    }
    if (parameters.DepositType == 4){
        context.PromptValue = await popup.input({caption: captions.CrMemoNoPrompt})
        if (context.PromptValue === null) {
            return;
        }
    }

    await workflow.respond("CreateDeposit");

    if (parameters.EditDescription) {
        debugger;
        workflow.context.Desc1 = await popup.input({ title: captions.editDesc_title, caption: captions.editDesc_lead})
        if (workflow.context.Desc1 === null || workflow.context.Desc1 === '') {
            return;
        }
        await workflow.respond("ChangeDesc"); 
    }
};