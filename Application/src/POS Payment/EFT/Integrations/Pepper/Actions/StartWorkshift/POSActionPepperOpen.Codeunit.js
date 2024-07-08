/*
  POSActionPepperOpen.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope}) => 
{
    debugger;

    if (context.request == null) {
        ({request: context.request} = await workflow.respond("PrepareOpenRequest"));
        debugger;
    }
    debugger;
    
    let _dialogRef, _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    _dialogRef = await popup.simplePayment({
        showStatus: true,
        title: captions.workflowTitle,
        amount: " ",
    });
    
    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            console.log("[Pepper] HWC Response Handler [SWS]: "+_contextId+" Type="+hwcResponse.Type);
            switch (hwcResponse.Type) {
                case "StartWorkshiftComplete":
                    try {
                        console.log ("[Pepper] Transaction Completed.");

                        _dialogRef.updateStatus (captions.statusFinalizing);
                        _bcResponse = await workflow.respond ("FinalizeOpenRequest", {hwcResponse: hwcResponse});
                        _hwcResponse.Success = (hwcResponse.ResultCode == 10) ? true : false;

                        debugger;
                        if (_bcResponse.hasOwnProperty('WorkflowName')) {
                            // When the start workshift workflow is run as a automatic response to a failed transaction, the transaction is attempted.
                            // or when the terminal has determined that previous transaction must be recovered, the transaction is attempted.
                            if (hwcResponse.ResultCode == 10 && hwcResponse.StartWorkshiftResponse.RecoveryRequired)
                                await popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x2757;</font><h3>"+ _bcResponse.Message +"</h3></center>"});

                            if (_dialogRef) {
                                _dialogRef.close(); 
                            }
                            let recovery = await workflow.run(_bcResponse.WorkflowName, { context: { request: _bcResponse } });

                            if (hwcResponse.StartWorkshiftResponse.RecoveryRequired) {
                                _bcResponse.Success = false;
                                _hwcResponse.Success = recovery.Success
                            }
                            debugger;
                        
                        } else {
                            if (hwcResponse.ResultCode != 10)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+hwcResponse.ResultString+"</h3></center>"});

                            if (hwcResponse.ResultCode == 10 && !_bcResponse.Success)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+_bcResponse.Message+"</h3></center>"});
                        
                            if ((context.showSuccessMessage == undefined && _bcResponse.Success) || (context.showSuccessMessage && _bcResponse.Success))
                                popup.message({ caption: "<center><font color=green size=72>&#x2713;</font><h3>"+_bcResponse.Message+"</h3></center>", title: captions.workflowTitle, });

                        };

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

        _dialogRef.updateStatus (captions.statusExecuting);
        _dialogRef.enableAbort(true);
        debugger;

        await hwc.invoke("EFTPepper", context.request, _contextId);
        await hwc.waitForContextCloseAsync(_contextId);

        if (_dialogRef) {
            _dialogRef.close();
        }

        debugger;
        return ({"success": _hwcResponse.Success, "endSale": _bcResponse.Success});
    }
    catch (e) {
        console.error ("[Pepper] Error: ", e);

        if (_dialogRef)
            _dialogRef.close();

        throw e;
    }
};