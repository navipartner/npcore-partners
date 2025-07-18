let main = async ({ workflow, hwc, popup, context, captions }) => {
    await workflow.respond("SetValuesToContext");

    const result1 = await handleHwcRequest(hwc, workflow, popup, captions, context.hwcRequest1);
    if (!result1.Success)
        return {sucess: false};

    const result2 = await handleHwcRequest(hwc, workflow, popup, captions, context.hwcRequest2);

    return {
        success: result1.Success && result2.Success
    };
};

async function handleHwcRequest(hwc, workflow, popup, captions, hwcRequest) {
    let _contextId;
    let _bcResponse = { Success: false };

    _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
        if (hwcResponse.Success) {
            try {
                console.log("[Hungary Laurel HWC]", hwcResponse);
                
                hwcResponse.HwcInvokeCall = false;
                _bcResponse = await workflow.respond("Process", { hwcResponse });

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

    try {
        await hwc.invoke(hwcRequest.HwcName, hwcRequest, _contextId);
    } catch (invokeErr) {
        hwc.unregisterResponseHandler(_contextId);
        return await workflow.respond("Process", {
            hwcResponse:{
                Success: false,
                ErrorMessage: "HWC Invoke failed: " + invokeErr.message,
                HwcInvokeCall: true
            }
        });
    }
    await hwc.waitForContextCloseAsync(_contextId);

    return _bcResponse;
}
