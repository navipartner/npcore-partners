/*
    POSActionHWCGenClose.Codeunit.js
*/
let main = async ({ workflow, hwc, popup, context, captions }) => {
    workflow.keepAlive();

    let _dialogRef, _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    if (context.showSpinner) {
        _dialogRef = popup.simplePayment({
            showStatus: true,
            title: captions.workflowTitle,
            amount: " ",
            onAbort: async () => {
                if (await popup.confirm(captions.confirmAbort)) {
                    _dialogRef.updateStatus(captions.statusAborting);
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
            abortValue: { completed: "Aborted" },
        });
    }

    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            switch (hwcResponse.Type) {
                case context.hwcRequest.Type:
                    try {
                        console.log("[Generic HWC] Operation " + context.hwcRequest.Type + " for " + context.hwcRequest.HwcName + " completed with status " + hwcResponse.Success);

                        if (_dialogRef)_dialogRef.updateStatus(captions.statusFinalizing);
                        _bcResponse = await workflow.respond("ProcessResult", { hwcResponse: hwcResponse });

                        if ((context.showSuccessMessage && _bcResponse.Success) || !_bcResponse.Success)
                            popup.message({ caption: _bcResponse.Message, title: captions.workflowTitle, });
                        
                        _hwcResponse = hwcResponse;
                        hwc.unregisterResponseHandler(_contextId);
                    }
                    catch (e) {
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
                    break;

                case "UpdateDisplay":
                    if (_dialogRef) _dialogRef.updateStatus(hwcResponse.DisplayLine);
                    break;
            }
        });

        if (_dialogRef) _dialogRef.updateStatus(captions.statusExecuting);
        if (_dialogRef) _dialogRef.enableAbort(true);

        await hwc.invoke(
            context.hwcRequest.HwcName,
            context.hwcRequest,
            _contextId
        );

        await hwc.waitForContextCloseAsync(_contextId);
        workflow.complete({ "success": _bcResponse.Success });
        if (_dialogRef) _dialogRef.close();
    }
    catch (e) {
        console.error(e);
        if ((context.showSpinner) && (_dialogRef))
            _dialogRef.close();

        throw e;
    }
}
