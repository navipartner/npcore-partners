let main = async ({ workflow, hwc, popup, context, captions }) => {  
    let _dialogRef = await popup.simplePayment({
        showStatus: true, 
        title: captions.workflowTitle,
        amount: context.request.CurrencyCode + " " + context.request.SuggestedAmountUserLocal,
        onAbort: async () => {
            if (await popup.confirm(captions.confirmAbort)) {
                _dialogRef.updateStatus (captions.statusAborting);
                await hwc.invoke(
                    "EFTMock",
                    {
                        Type: "RequestCancel",
                        EntryNo: context.request.EntryNo,
                    },
                    _contextId,
                );
            }
        },
        abortValue: {completed: "Aborted"},
    });
    
    let _contextId;
    let _hwcResponse = { "Success": false };
    let _bcResponse = { "Success": false };
    context.success = false;
    context.tryEndSale = false;

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
                            throw new Error(hwcResponse.ResultString);

                        if (hwcResponse.Success && !_bcResponse.Success)
                            throw new Error(_bcResponse.Message);

                        if (context.request.AmountIn == 704) 
                            throw new Error("AmountIn with value 704 forces an exception in MOCK hwc response handler.");
                        
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
                    if (context.request.AmountIn == 703) 
                        throw "AmountIn with value 703 forces an exception in MOCK hwc response handler.";
                    break;
            }
        });

        _dialogRef.updateStatus (captions.statusAuthorizing);
        _dialogRef.enableAbort(true);

        await hwc.invoke(
            "EFTMock",
            context.request,
            _contextId
        );
        await hwc.waitForContextCloseAsync(_contextId);
        context.success = _hwcResponse.Success && _bcResponse.Success;
    }
    catch (exception) {
        popup.message({ title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>" + (exception.message || "Unknown error") + "</h3></center>" })
        throw exception;
    }
    finally {
        if (_dialogRef) {
            _dialogRef.close();
        }
    }
    return ({ "success": context.success, "tryEndSale": context.success });
}