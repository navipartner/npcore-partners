let main = async ({ workflow, popup, parameters, captions }) => {    
    if  ((parameters.SelectionDialogType == parameters.SelectionDialogType["TextField"]) && 
        ((parameters.Setting == parameters.Setting["Choose Receipt"]) || 
        (parameters.Setting == parameters.Setting["Choose Receipt Large"]))) {
        var result = await popup.input({title: captions.Title, caption: captions.EnterReceiptNoLbl, value: ""})
        if (result == null){
            return (" ")
        }
    }
    await workflow.respond("ManualReceiptNo",{ManualReceiptNo: result})
}