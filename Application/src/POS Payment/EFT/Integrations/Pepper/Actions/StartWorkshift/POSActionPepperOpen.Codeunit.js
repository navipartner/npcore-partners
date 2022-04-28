/*
  POSActionPepperOpen.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope}) => 
{
    debugger;

    if (context.hwcRequest == null) {
        ({hwcRequest: context.hwcRequest} = await workflow.respond ("PrepareOpenRequest"));
        debugger;
    }
    debugger;
    
    let _dialogRef, _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    _dialogRef = popup.simplePayment({
        showStatus: true,
        title: captions.workflowTitle,
        amount: " ",
    });
    
    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            switch (hwcResponse.Type) {
                case "StartWorkshiftComplete":
                    try {
                        console.log ("[Pepper] Transaction Completed.");

                        _dialogRef.updateStatus (captions.statusFinalizing);
                        _bcResponse = await workflow.respond ("FinalizeOpenRequest", {hwcResponse: hwcResponse});
                        
                        debugger;
                        if (_bcResponse.hasOwnProperty('WorkflowName')) {
                            
                            if (hwcResponse.ResultCode == 10 && hwcResponse.StartWorkshiftResponse.RecoveryRequired)
                                await popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x2757;</font><h3>"+ _bcResponse.Message +"</h3></center>"});

                            _dialogRef.close();
                            let recovery = await workflow.run(_bcResponse.WorkflowName, {context: {hwcRequest: _bcResponse}});
                            debugger;

                        } else {
                            if (hwcResponse.ResultCode != 10)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+hwcResponse.ResultString+"</h3></center>"});

                            if (hwcResponse.ResultCode == 10 && !_bcResponse.Success)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+_bcResponse.Message+"</h3></center>"});
                        
                            if ((context.showSuccessMessage == undefined && _bcResponse.Success) || (context.showSuccessMessage && _bcResponse.Success))
                                popup.message({ caption: "<center><font color=green size=72>&#x2713;</font><h3>"+_bcResponse.Message+"</h3></center>", title: captions.workflowTitle, });

                            _hwcResponse = hwcResponse;
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
        await hwc.invoke(
            context.hwcRequest.HwcName,
            context.hwcRequest,
            _contextId
        );
        
        await hwc.waitForContextCloseAsync(_contextId);
        _dialogRef.close();
        
        return ({"success": _hwcResponse.Success, "endSale": false});
    }
    catch (e) {
        console.error ("[Pepper] Error: ", e);

        if (_dialogRef)
            _dialogRef.close();

        throw e;
    }
};