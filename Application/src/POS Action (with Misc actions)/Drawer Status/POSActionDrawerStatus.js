let main = async ({ workflow, hwc, popup, context, captions }) => {
    let _dialogRef, _contextId, _bcResponse = {"Success": false};
    await workflow.respond("SetValuesToContext");
    
    if (context.showSpinner) {
        _dialogRef = await popup.simpleSpinner({
            caption: captions.workflowTitle,
            onAbort: async () => {
                popup.message({ caption: captions.abortErrorMessage, title: captions.workflowTitle, })
            },
            abortValue: { completed: "Aborted" },
        });
    }

    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            if (hwcResponse.Success) {
                    try {
                        console.log("[Cash Drawer HWC] ", hwcResponse);

                        if (_dialogRef) _dialogRef.updateStatus(captions.statusProcessing);

                        _bcResponse = await workflow.respond("Process", { hwcResponse: hwcResponse });
                        
                        hwc.unregisterResponseHandler(_contextId);

                        if (_bcResponse.Success) {
                            if (_bcResponse.ShowSuccessMessage) {
                                popup.message({ caption: _bcResponse.Message, title: captions.workflowTitle });
                            }
                        } else {
                            popup.error({ caption: _bcResponse.Message, title: captions.workflowTitle });
                        }
                    }
                    catch (e) { 
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
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
        return ({ "success": _bcResponse.Success });
    }
    finally {
        if (_dialogRef) _dialogRef.close();
        _dialogRef = null
    }
}
