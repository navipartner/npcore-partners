let main = async ({ workflow, hwc, popup, context, captions }) => {
    let _dialogRef, _contextId, _hwcResponse = {"Success": false}, _bcResponse = {"Success": false};
    debugger;
    if (!context.request.Unattended) {
        _dialogRef = await popup.simplePayment({
            showStatus: true,
            title: captions.workflowTitle,
            amount: " ",
            onAbort: async () => {
                if (await popup.confirm(captions.confirmAbort)) {
                    _dialogRef.updateStatus(captions.statusAborting);
                    await hwc.invoke(
                        context.request.HwcName,
                        {
                            Type: "RequestCancel",
                            EntryNo: context.request.EntryNo,
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
                case context.request.Type:
                    try {
                        console.log("[Generic HWC] Operation " + context.request.Type + " for " + context.request.HwcName + " completed with status " + hwcResponse.Success);

                        if (_dialogRef)_dialogRef.updateStatus(captions.statusFinalizing);
                        _bcResponse = await workflow.respond("ProcessResult", { hwcResponse: hwcResponse });

                        if ((context.showSuccessMessage && _bcResponse.Success) || !_bcResponse.Success)
                        _dialogRef && popup.message({ caption: _bcResponse.Message, title: captions.workflowTitle, });
                        
                        _hwcResponse = hwcResponse;
                        hwc.unregisterResponseHandler(_contextId);
                    }
                    catch (e) {
                        console.error("[Generic HWC] Operation failed: " + e)
                        hwc.unregisterResponseHandler(_contextId, e);
                    }
                    break;

                case "UpdateDisplay":
                    _dialogRef && _dialogRef.updateStatus(hwcResponse.DisplayLine);
                    console.log("[Generic HWC] Operation " + hwcResponse.DisplayLine);
                    break;
            }
        });

        _dialogRef && _dialogRef.updateStatus(captions.statusExecuting);
        _dialogRef && _dialogRef.enableAbort(true);

        await hwc.invoke(
            context.request.HwcName,
            context.request,
            _contextId
        );

        await hwc.waitForContextCloseAsync(_contextId);
        return ({ "success": _bcResponse.Success });
    }
    finally {
        _dialogRef && _dialogRef.close();
    }
}
