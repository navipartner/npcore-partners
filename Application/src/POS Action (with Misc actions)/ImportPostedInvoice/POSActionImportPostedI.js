
let main = async ({workflow,context,captions,parameters}) => {
    
    if (parameters.ScanExchangeLabel) {
        context.Barcode = await popup.input ({title: captions.editScanLabel_title, caption: captions.editScanLabel_title});
        if (context.Barcode) {
            await workflow.respond("ScanLabel"); 
             
        }
        else {
            return(" ");
        }
        
                       
    }
        else
        {
            await workflow.respond("SelectInvoice");
        }
    
};
