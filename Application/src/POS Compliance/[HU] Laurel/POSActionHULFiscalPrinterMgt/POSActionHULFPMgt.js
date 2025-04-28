let main = async ({ workflow, hwc, popup, context, captions }) => {
    let _dialogRef, _contextId, _bcResponse = { "Success": false };
    await workflow.respond("SetValuesToContext");

    if (context.showSpinner) {
        _dialogRef = await popup.spinner({
            caption: captions.workflowTitle,
            abortEnabled: false
        });
    }

    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            if (hwcResponse.Success) {
                try {
                    console.log("[Hungary Laurel HWC] ", hwcResponse);

                    if (_dialogRef) _dialogRef.updateCaption(captions.statusProcessing);

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

        if (_dialogRef) _dialogRef.updateCaption(captions.statusExecuting);

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
