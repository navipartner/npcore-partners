/*
  POSActionPepperOpen.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope}) => 
{
    debugger;
    
    if (context.hwcRequest == null) {
        ({hwcRequest: context.hwcRequest} = await workflow.respond ("PrepareTransactionRequest"));
        debugger;
    }
    debugger;

    let _canAbort = true;
    let _aborting = false;

    let _dialogRef = popup.simplePayment({
        showStatus: true, 
        title: captions.workflowTitle,
        amount: context.hwcRequest.TransactionRequest.Currency + " " + context.hwcRequest.TransactionRequest.OriginalDecimalAmount,
        onAbort: async () => {
            if (await popup.confirm(captions.confirmAbort)) {
                _aborting = true;
                _dialogRef.updateStatus (captions.statusAborting);
                context.hwcRequest.TransactionRequest.Operation = "AbortTransaction";
                await hwc.invoke(
                    context.hwcRequest.HwcName,
                    context.hwcRequest,
                    _contextId
                );
            }
        },
        abortValue: {completed: "Aborted"},
    });

    let _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            switch (hwcResponse.Type) {
                case "TransactionComplete":
                    try {
                        if (_aborting) 
                            return; // exit via abort functionality

                        _canAbort = false;
                        console.log ("[Pepper] Transaction Completed.");

                        _dialogRef.updateStatus (captions.statusFinalizing);
                        _bcResponse = await workflow.respond ("FinalizeTransactionRequest", {hwcResponse: hwcResponse});
                        _hwcResponse = hwcResponse;

                        debugger;
                        if (_bcResponse.hasOwnProperty('WorkflowName')) {
                            
                            _dialogRef.close();
                            await workflow.run(_bcResponse.WorkflowName, {context: {hwcRequest: _bcResponse}});
                            debugger;

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
                            if (hwcResponse.ResultCode == 30 && context.hwcRequest.TransactionRequest.TrxType == 0) {
                                console.info("Transaction was recovered OK.");
                                popup.message ({title: captions.workflowTitle, caption: "<center><font color=green size=72>&#x2713;</font><h3>"+"Transaction was recovered OK."+"</h3></center>"});
                                _bcResponse.Success = false; // Dont auto-end sale
                            }
                        };

                        // Confirm to Pepper that BC is updated and end the workflow on CommitComplete
                        context.hwcRequest.TransactionRequest.Operation = "CommitTransaction";
                        hwc.invoke(
                            context.hwcRequest.HwcName,
                            context.hwcRequest,
                            _contextId
                        );

                        _dialogRef.updateStatus (captions.statusCommitting);

                    }
                    catch (e) {
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
                    break;

                case "CommitComplete":
                    // This is a workflow exit 
                    hwc.unregisterResponseHandler(_contextId);
                    break;

                case "AbortComplete":
                    // This is a workflow exit
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
                            hwcResponse.TellerRequest.StringPad.value = await popup.stringpad (hwcResponse.TellerRequest.StringPad);
                            break;
                        case "OptionMenu":
                            ({id: hwcResponse.TellerRequest.OptionMenu.id} = await popup.optionsMenu (hwcResponse.TellerRequest.OptionMenu));
                            break;
                    }
                    context.hwcRequest.TellerResponse = hwcResponse.TellerRequest;
                    context.hwcRequest.TransactionRequest.Operation = "TellerResponse";
                    debugger;
                    await hwc.invoke(context.hwcRequest.HwcName, context.hwcRequest, _contextId);
                    break;

                case "TellerRequestComplete":
                    // HWC response to TellerResponse operation. Nothing to do here.
                    break;
            }
        });

        _dialogRef.updateStatus (captions.statusAuthorizing);
        _dialogRef.enableAbort(true);

        await hwc.invoke(context.hwcRequest.HwcName, context.hwcRequest, _contextId);
        await hwc.waitForContextCloseAsync(_contextId);
        _dialogRef.close();

        return ({"success": _hwcResponse.Success, "endSale": _bcResponse.Success});
    }
    catch (e) {
        console.error ("[Pepper] Error: ", e);

        if (_dialogRef)
            _dialogRef.close();

        throw e;
    }
};