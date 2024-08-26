let main = async ({ workflow, hwc, popup, context, captions }) => {
    let _dialogRef, _contextId, _bcResponse = {"Success": false};
    await workflow.respond("SetValuesToContext");
    
    if (context.showSpinner) {
        _dialogRef = await popup.simpleSpinner({
            caption: captions.workflowTitle,
            onAbort: async () => {
                if (await popup.confirm(captions.confirmAbort)) {
                    _dialogRef.updateStatus(captions.statusAborting);
                    await hwc.invoke(
                        context.hwcRequest.HwcName,
                        {
                            CardAction: "RequestCancel"
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
            switch (hwcResponse.RspType) {
                case "Success":
                    try {
                        console.log("[BelgianEid HWC] ", hwcResponse);

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
                    break;

                case "TokenWait":
                    if (_dialogRef) _dialogRef.updateStatus(captions.rspTypeTokenWait);
                    console.log("[BelgianEid HWC] TokenWait ", hwcResponse);
                    break;

                case "Update":
                    if (_dialogRef) _dialogRef.updateStatus(captions.rspTypeUpdate);
                    console.log("[BelgianEid HWC] TokenWait ", hwcResponse);
                    break;

                case "Error":
                    if (_dialogRef) _dialogRef.updateStatus(captions.rspTypeError);
                    console.log("[BelgianEid HWC] Error ", hwcResponse);
                    hwc.unregisterResponseHandler(_contextId);
                    popup.error({ caption: hwcResponse.Message, title: captions.workflowTitle });
                    break;

                case "Unknown":
                    if (_dialogRef) _dialogRef.updateStatus(captions.rspTypeUnknown);
                    console.log("[BelgianEid HWC] Unknown ", hwcResponse);
                    hwc.unregisterResponseHandler(_contextId);
                    popup.error({ caption: hwcResponse.Message, title: captions.workflowTitle });
                    break;

                case "Cancel":
                    if (_dialogRef) _dialogRef.updateStatus(captions.rspTypeCancel);
                    console.log("[BelgianEid HWC] Cancel ", hwcResponse);
                    hwc.unregisterResponseHandler(_contextId);
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
        return ({ "success": _bcResponse.Success });
    }
    finally {
        if (_dialogRef) _dialogRef.close();
        _dialogRef = null
    }
}
