let main = async ({ workflow, popup, parameters, captions }) => {    
    debugger; 
    if (!(parameters["Issue Digital Receipts"] || parameters["Print Physical Receipts"])) return;
    
    if  ((parameters.SelectionDialogType == parameters.SelectionDialogType["TextField"]) && 
        ((parameters.Setting == parameters.Setting["Choose Receipt"]) || 
        (parameters.Setting == parameters.Setting["Choose Receipt Large"]))) {
        var result = await popup.input({title: captions.Title, caption: captions.EnterReceiptNoLbl, value: ""})
        if (result == null){
            return (" ")
        }
    }
   const{ qrCodeLink, footerText } = await workflow.respond("ManualReceiptNo",{ManualReceiptNo: result});
   if (qrCodeLink){
    await workflow.run('VIEW_DIG_RCPT_QRCODE', { parameters: { qrCodeLink: qrCodeLink, footerText: footerText } });
   }
}