/*
  POSActionPepperOpen.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope}) => 
{
    debugger;
    if (context.request == null)
        (context.request = await workflow.respond("PrepareRequest"));
    
    debugger;  
    let _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    let _dialogRef = await popup.simplePayment({
        showStatus: true, 
        title: captions.workflowTitle,
        amount: " ",
    });
    
    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            switch (hwcResponse.Type) {
                case "AuxiliaryComplete":
                    try {
                        console.log ("[Pepper] AUX Operation Complete.");

                        _dialogRef.updateStatus (captions.statusFinalizing);
                        _bcResponse = await workflow.respond ("FinalizeRequest", {hwcResponse: hwcResponse});
                        
                        if (_bcResponse.hasOwnProperty('WorkflowName')) {
                            
                            if (_dialogRef) {
                                _dialogRef.close();
                            }
                            await workflow.run(_bcResponse.WorkflowName, { context: { request: _bcResponse } });                            

                        } else {
                            if (hwcResponse.ResultCode != 10)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+hwcResponse.ResultString+"</h3></center>"});

                            if (hwcResponse.ResultCode == 10 && !_bcResponse.Success)
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+_bcResponse.Message+"</h3></center>"});
                    
                            _hwcResponse = hwcResponse;
                        }
                        hwc.unregisterResponseHandler(_contextId);
                    }
                    catch (e) {
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
                    break;

                case "UpdateDisplay":
                    console.log ("[Pepper] Update Display. "+hwcResponse.Message);
                    _dialogRef.updateStatus(hwcResponse.Message);
                    break;
            }
        });

        _dialogRef.updateStatus (captions.statusExecuting);
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

        throw e;
    }
};