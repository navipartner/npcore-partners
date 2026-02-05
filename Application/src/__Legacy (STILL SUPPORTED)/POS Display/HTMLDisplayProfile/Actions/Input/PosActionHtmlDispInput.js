let main = async ({context, popup, captions}) => {    
    context.HtmlDisplayVersion = Number.parseInt(captions.HtmlDisplayVersion);              
    let response = null;
    try
    {
        let bcResult = await workflow.respond('PrepareInputRequest');
        switch(bcResult.Result)
        {
            case "GET_INPUT":
                break;
            case "NOT_SELECTED":
                popup.error(captions.ErrPOSEntryNotSelected);
                return;
            case "INPUT_EXISTS":
                popup.error(captions.ErrPOSEntryInputExists);
                return;
            default:
                popup.error(captions.ErrPOSEntryUndefined);
                return;
        }
        let _dialogRef = null;
        let abort = false;
        let collectPrx = new Promise(async (res, rej) => {
            try{
                async function CollectAndHandle()
                {
                    _dialogRef = await popup.simplePayment({
                        title: "Collect Signature",
                        initialStatus: "awaiting customer",
                        showStatus: true,
                        amountStyle: {fontSize: "0px"},
                        abortEnabled: true,
                        onAbort: async () => {
                            abort = true;
                            await hwc.invoke('HTMLDisplay', {
                                Cancel: true,
                                Version: context.HtmlDisplayVersion
                            });
                        }
                    });
                    debugger;
                    let response = await hwc.invoke('HTMLDisplay', context.Request);
                    _dialogRef.close();
                    if (!response.IsSuccessfull && response.Error === "Cancel")
                        return res();
                    let bc = await workflow.respond('InputCollected', response);
                    if(bc.ReCollectInput)
                        setTimeout(CollectAndHandle, 200);
                    else
                        res();
                    
                }
                CollectAndHandle();
            } catch(e)
            {
                rej(e);
            }
            finally{
                if (_dialogRef)
                    _dialogRef.close();
            }
        });
        await collectPrx;
        let bc = await workflow.respond("UpdateReceiptView");
        if (bc.Request)
            await hwc.invoke("HTMLDisplay", bc.Request);
    } 
    catch(e)
    {
        popup.error(e);
    }
}