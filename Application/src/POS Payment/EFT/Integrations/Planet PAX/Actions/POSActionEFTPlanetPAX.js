
let main = async ({ workflow, context, captions, popup }) => {
    context.EFTEntryNo = context.request.EFTEntryNo;
    let _title = '';
    let _iniStatus = '';
    let _amount = '';
    switch(context.request.EFTReqType.toLowerCase())
    {
        case "payment":
            _title = captions.TitlePayment;
            _iniStatus = captions.InitStatusPayment;
            _amount = context.request.formattedAmount;
            context.TaskType = "Payment";
            break;
        case "refund":
            _title = captions.TitleRefund;
            _iniStatus = captions.InitStatusRefund;
            _amount = context.request.formattedAmount;
            context.TaskType = "Refund";
            break;
        default:
            throw new Error("Unsupported EFT Request '" + context.request.EFTReqType.toLowerCase() +"'");
    }
    
    let _dialogRef = await popup.simplePayment({
        title: _title,
        initialStatus: _iniStatus,
        showStatus: true,
        amount: _amount,
        onAbort: async () => 
        { 
            _dialogRef.updateStatus(captions.statusAborting);
            await workflow.respond("abortRequest");
        }});
    
    // Create a Task that polls BC for a response every second.
    let trxPromise = new Promise((resolve, reject) => 
    {
        let pollFunction = async () => {
            try {
                let pollResponse = await workflow.respond("pollRequest");
                if (pollResponse.done) {
                    resolve(pollResponse);
                    return;
                }
            }
            catch (exception) {
                await workflow.respond("abortRequest");
                reject(exception);
                return;
            }
            setTimeout(pollFunction, 1000);
        };
        setTimeout(pollFunction, 1000);
    });
    let bc = null;
    try {
        //Main protocol
        //Start Request
        await workflow.respond("startRequest");
        //Update Diaglog
        _dialogRef.updateStatus(captions.activeStatus);
        _dialogRef.enableAbort(true);
        //Await Polling Task.
        bc = await trxPromise;
        if(bc.needSignature)
            await workflow.respond("promptSignature");
    }
    finally {
        if (_dialogRef) 
            _dialogRef.close();
    }
    return ({ "success": bc.success, "tryEndSale": bc.success });
};
