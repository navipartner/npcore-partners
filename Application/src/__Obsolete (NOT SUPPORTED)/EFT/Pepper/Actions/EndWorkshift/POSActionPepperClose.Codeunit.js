/*
  POSActionPepperOpen.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope}) => 
{
    debugger;

    if (context.request == null) {
        ({request: context.request } = await workflow.respond("PrepareCloseRequest"));
        debugger;
    }
    debugger;

    let _dialogRef = await popup.simplePayment({
        showStatus: true, 
        title: captions.workflowTitle,
        amount: " ",
    });

    let _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            switch (hwcResponse.Type) {
                case "EndWorkshiftComplete":
                    try {
                        console.log ("[Pepper] Transaction Completed.");

                        _dialogRef.updateStatus (captions.statusFinalizing);
                        _bcResponse = await workflow.respond ("FinalizeCloseRequest", {hwcResponse: hwcResponse});
                        
                        if (hwcResponse.ResultCode != 10)
                            if (!context.hideFailureMessage)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+hwcResponse.ResultString+"</h3></center>"})

                        if (hwcResponse.ResultCode == 10 && !_bcResponse.Success)
                            if (!context.hideFailureMessage)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+_bcResponse.Message+"</h3></center>"})

                        if ((context.showSuccessMessage == undefined && _bcResponse.Success) || (context.showSuccessMessage && _bcResponse.Success))
                            popup.message({ caption: "<center><font color=green size=72>&#x2713;</font><h3>"+_bcResponse.Message+"</h3></center>", title: captions.workflowTitle, });

                        _hwcResponse = hwcResponse;
                        hwc.unregisterResponseHandler(_contextId);
                    }
                    catch (e) {
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
                    break;

                case "AbortComplete":
                    // This is a workflow exit 
                    hwc.unregisterResponseHandler(_contextId);
                    break;

                case "UpdateDisplay":
                    console.log ("[Pepper] Update Display. "+hwcResponse.Message);
                    _dialogRef.updateStatus(hwcResponse.Message);
                    break;
            }
        });

        _dialogRef.updateStatus (captions.statusClosing);
        _dialogRef.enableAbort(true);

        await hwc.invoke(
            "EFTPepper",
            context.request,
            _contextId
        );
        
        await hwc.waitForContextCloseAsync(_contextId);

        if (_dialogRef) {
            _dialogRef.close();
        }

        return({"success": _hwcResponse.Success});
    }
    catch (e) {
        console.error ("[Pepper] Error: ", e);

        if (_dialogRef)
            _dialogRef.close();

        return({"success": false});
    }
};