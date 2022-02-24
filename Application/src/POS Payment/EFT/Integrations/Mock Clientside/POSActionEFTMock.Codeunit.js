let main = async ({ workflow, hwc, popup, context, captions}) => {  
    workflow.keepAlive();
    
    let _dialogRef = popup.simplePayment({
        showStatus: true, 
        title: captions.workflowTitle,
        amount: context.hwcRequest.CurrencyCode + " " + context.hwcRequest.SuggestedAmountUserLocal,
        onAbort: async () => {
            if (await popup.confirm(captions.confirmAbort)) {
                _dialogRef.updateStatus (captions.statusAborting);
                await hwc.invoke(
                    context.hwcRequest.HwcName,
                    {
                        Type: "RequestCancel",
                        EntryNo: context.hwcRequest.EntryNo,
                    },
                    _contextId,
                );
            }
        },
        abortValue: {completed: "Aborted"},
    });
    
    let _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            switch (hwcResponse.Type) {
                case "Lookup":
                case "Transaction":
                case "Void":
                    try {
                        console.log ("[EFT Mock] Transaction Completed.");

                        _dialogRef.updateStatus (captions.statusFinalizing);
                        _bcResponse = await workflow.respond ("FinalizePaymentRequest", {hwcResponse: hwcResponse});
                        
                        if (!hwcResponse.Success)
                            popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+hwcResponse.ResultString+"</h3></center>"})

                        if (hwcResponse.Success && !_bcResponse.Success)
                            popup.message ({title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>"+_bcResponse.Message+"</h3></center>"})

                        if (context.hwcRequest.AmountIn == 704) 
                            throw "AmountIn with value 704 forces an exception in MOCK hwc response handler.";
                        
                        _hwcResponse = hwcResponse;
                        hwc.unregisterResponseHandler(_contextId);
                    }
                    catch (e) {
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
                    break;

                case "UpdateDisplay":
                    console.log ("[EFT Mock] Update Display. "+hwcResponse.DisplayLine);
                    _dialogRef.updateStatus(hwcResponse.DisplayLine);
                    if (context.hwcRequest.AmountIn == 703) 
                        throw "AmountIn with value 703 forces an exception in MOCK hwc response handler.";
                    break;
            }
        });

        _dialogRef.updateStatus (captions.statusAuthorizing);
        _dialogRef.enableAbort(true);

        await hwc.invoke(
            context.hwcRequest.HwcName,
            context.hwcRequest,
            _contextId
        );
        
        await hwc.waitForContextCloseAsync(_contextId);
        workflow.complete({"success": _hwcResponse.Success, "endSale": _bcResponse.Success});
        _dialogRef.close();
    }
    catch (e) {
        console.error ("[EFT Mock] Error: ", e);

        if (_dialogRef)
            _dialogRef.close();

        workflow.complete({"success": false, "endSale": false});
        throw e;
    }
}

