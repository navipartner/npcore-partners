let main = async ({ workflow, hwc, popup, context, captions }) => {
    let _dialogRef, _contextId, _bcResponse, _hwcResponse = { "Success": false};
    await workflow.respond("SetValuesToContext");

    if (context.showSpinner) {
        _dialogRef = await popup.spinner({
            caption: captions.workflowTitle,
            abortEnabled: false
        });
    }

    try {
        _contextId = hwc.registerResponseHandler(async (response) => {
            _hwcResponse = response;
            if (_hwcResponse.Success) {
                try {
                    console.log("[Hungary Laurel HWC] ", _hwcResponse);

                    if (_dialogRef) _dialogRef.updateCaption(captions.statusProcessing);

                    _bcResponse = await workflow.respond("Process", { hwcResponse: _hwcResponse});

                    hwc.unregisterResponseHandler(_contextId);

                    if (_bcResponse.Success) {
                        if (_bcResponse.ShowSuccessMessage) {
                            popup.message({ caption: _bcResponse.Message, title: captions.workflowTitle });
                        }
                    } else {
                        popup.error({ caption: _bcResponse.Message, title: captions.workflowTitle });
                    }
                } catch (e) {
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
        return ({ "success": _bcResponse.Success});
    } finally {
        if (_dialogRef) _dialogRef.close();
        _dialogRef = null;
        await processResponseIfErrorAndCallResetWorkflow(workflow, _hwcResponse);
    }
};

async function processResponseIfErrorAndCallResetWorkflow(workflow, hwcResponse) {
    if (!hwcResponse || !hwcResponse.Success) return;
    let iErrCode = null;
    
    try {
        let responseMessage = JSON.parse(hwcResponse.ResponseMessage);
        iErrCode = responseMessage.result.iErrCode;
    } catch (e) {
        console.error("Invalid JSON in hwcResponse.ResponseMessage:", e);
        return;
    }

    if (iErrCode && !['0', '531', '586', '598', '599'].includes(iErrCode))
        await processWorkflow(workflow, 'HUL_RESET_PRINTER');
}

async function processWorkflow(workflow, workflowName) {
    if (!workflowName) return;

    await workflow.run(workflowName, { });
}