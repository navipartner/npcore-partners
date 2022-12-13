let main = async ({workflow,context,captions,parameters}) => {
    
    if (parameters.ScanExchangeLabel) {
        context.OrdNo = await popup.input({title: captions.editScanLabel_title, caption: captions.editScanLabel_title});
        await workflow.respond("ScanLabel");                
    }
        else
        {
            await workflow.respond("SelectInvoice");
        }
    
};