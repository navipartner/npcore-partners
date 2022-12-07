let main = async ({workflow, parameters,popup, captions, context}) => {
    if (parameters.DepositType == 1){
        context.PromptValue = await popup.input({caption: captions.InvoiceNoPrompt})
    }
    if (parameters.DepositType == 2){
        context.PromptAmt = await popup.numpad({caption: captions.AmountPrompt})
    }
    if (parameters.DepositType == 4){
        context.PromptValue = await popup.input({caption: captions.CrMemoNoPrompt})
    }
    await workflow.respond("CreateDeposit");
};