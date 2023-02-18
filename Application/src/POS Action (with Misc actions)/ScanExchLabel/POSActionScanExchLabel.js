let main = async ({workflow, popup, captions, parameters}) => {
    if (parameters.PromptForBarcode)
        {    
            let result = await popup.input({title: captions.InpTitle, caption: captions.InpLead});
            if (result === null) {
                return(" ");
            }
            await workflow.respond("ExchangeLabelBarCode", { ExchBarCode: result })
        }
    else
        await workflow.respond("ExchangeLabelBarCode")
}