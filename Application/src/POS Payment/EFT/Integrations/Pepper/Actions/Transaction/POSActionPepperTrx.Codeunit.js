/*
  POSActionPepperOpen.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope}) => 
{
    debugger;

    let _canAbort = true;
    let _aborting = false;

    let _dialogRef = await popup.simplePayment({
        showStatus: true, 
        title: captions.workflowTitle,
        amount: context.request.TransactionRequest.Currency + " " + context.request.TransactionRequest.OriginalDecimalAmount.toFixed(2),
        onAbort: async () => {
            if (await popup.confirm(captions.confirmAbort)) {
                _aborting = true;
                _dialogRef.updateStatus (captions.statusAborting);
                context.request.TransactionRequest.Operation = "AbortTransaction";
                await hwc.invoke(
                    "EFTPepper",
                    context.request,
                    _contextId
                );
            }
        },
        abortValue: {completed: "Aborted"},
    });

    let _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            try {
                switch (hwcResponse.Type) {
                case "TransactionComplete":
                    try {
                        if (_aborting) 
                            return; // exit via abort functionality

                        _canAbort = false;
                        console.log ("[Pepper] Transaction Completed.");

                        _dialogRef.updateStatus (captions.statusFinalizing);
                        _bcResponse = await workflow.respond ("FinalizeTransactionRequest", {hwcResponse: hwcResponse});
                        _hwcResponse.Success = (hwcResponse.ResultCode > 0) ? true : false;
                        debugger;

                        if (_bcResponse.hasOwnProperty('WorkflowName')) {
                            // If Pepper TRX fails due to terminal not open and status allows auto-open, the start workshift workflow will be run.

                            if (_dialogRef) {
                                _dialogRef.close();
                            }
                            let swr = await workflow.run(_bcResponse.WorkflowName, { context: { request: _bcResponse }});
                            _hwcResponse.Success = swr.success;
                            _bcResponse.Success = swr.endSale;
                            debugger;
                            
                            hwc.unregisterResponseHandler(_contextId);
                        } else {
                            // Show negative feedback to user
                            if (hwcResponse.ResultCode <= 0) {
                                console.warn("Got a negative response code from Pepper: "+hwcResponse.ResultCode);
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+hwcResponse.ResultString+"</h3></center>"});
                            }

                            if (hwcResponse.ResultCode > 0 && !_bcResponse.Success) {
                                console.warn("Got a negative response code from BC on finalizing transaction: "+_bcResponse.Message);
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+_bcResponse.Message+"</h3></center>"});
                            }

                            // Always confirm recovered transaction
                            if (hwcResponse.ResultCode == 30 && context.request.TransactionRequest.TrxType == 0) {
                                console.info("Transaction was recovered OK.");
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=green size=72>&#x2713;</font><h3>"+"Transaction was recovered OK."+"</h3></center>"});
                                _bcResponse.Success = false; // Do not auto-end sale
                            }
                            
                            // Confirm to Pepper that BC is updated and end the workflow on CommitComplete
                            _dialogRef.updateStatus (captions.statusCommitting);
                            context.request.TransactionRequest.Operation = "CommitTransaction";
                            await hwc.invoke("EFTPepper", context.request, _contextId);
                        };
                    }
                    catch (e) {
                        debugger;
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
                    break;

                case "CommitComplete":
                    // This is a workflow exit 
                    debugger;
                    hwc.unregisterResponseHandler(_contextId);
                    break;

                case "AbortComplete":
                    // This is a workflow exit
                    debugger;
                    if (_canAbort) {
                        _bcResponse = await workflow.respond ("FinalizeAbortRequest", {hwcResponse: hwcResponse});
                        if (!hwcResponse.ResultCode == 10)
                            popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+hwcResponse.ResultString+"</h3></center>"});

                        if (hwcResponse.ResultCode == 10)
                            popup.message({ caption: "<center><font color=green size=72>&#10003;</font><h3>"+_bcResponse.Message+"</h3></center>", title: captions.workflowTitle, });

                        hwc.unregisterResponseHandler(_contextId);
                    }
                    break;

                case "UpdateDisplay":
                    console.log ("[Pepper] Update Display. "+hwcResponse.Message);
                    _dialogRef.updateStatus(hwcResponse.Message);
                    break;
                
                case "TellerRequest":
                    debugger;
                    switch (hwcResponse.TellerRequest.Type) {
                        case "NumPad":
                            hwcResponse.TellerRequest.NumPad.value = await popup.numpad (hwcResponse.TellerRequest.NumPad);
                            break;
                        case "StringPad":
                            hwcResponse.TellerRequest.StringPad.value = await popup.input (hwcResponse.TellerRequest.StringPad);
                            break;
                        case "OptionMenu":
                            let selection = null;
                            let optionMenu =  hwcResponse.TellerRequest.OptionMenu;
                            optionMenu.oneTouch = (optionMenu.options.length > 0);

                            while (!selection && optionMenu.oneTouch) {
                                selection = await popup.optionsMenu(optionMenu);
                                if (!selection) {
                                    await popup.message("Please make a selection.");
                                }
                            }

                            if (selection) {
                                optionMenu.id = selection.id;
                            }
                            break;
                    }
                    context.request.TellerResponse = hwcResponse.TellerRequest;
                    context.request.TransactionRequest.Operation = "TellerResponse";
                    debugger;
                        await hwc.invoke("EFTPepper", context.request, _contextId);
                    break;

                case "TellerRequestComplete":
                    // HWC response to TellerResponse operation. Nothing to do here.
                    break;
                }
            } catch (e) {
                console.error ("[Pepper] Error in HWC handler ["+_contextId+"] exception: " +e.toString());
            }
        });

        _dialogRef.updateStatus (captions.statusAuthorizing);
        _dialogRef.enableAbort(true);
        debugger;

        await hwc.invoke("EFTPepper", context.request, _contextId);
        await hwc.waitForContextCloseAsync(_contextId);
        _dialogRef.close();

        return ({ "success": _hwcResponse.Success, "tryEndSale": _bcResponse.Success });
    }
    catch (e) {
        console.error ("[Pepper] Error: ", e.toString());

        if (_dialogRef)
            _dialogRef.close();

        throw e;
    }
};