/*
    POSActionPepperInstall.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope }) => {
    
    let _dialogRef, _contextId, _hwcResponse = { "Success": false }, _bcResponse = { "Success": false };

    _dialogRef = popup.simplePayment({
        showStatus: true,
        title: captions.workflowTitle,
        amount: " ",
        onAbort: async () => {
            if (await popup.confirm(captions.confirmAbort)) {
                hwc.unregisterResponseHandler(_contextId);
            }
        },
        abortValue: { completed: "Aborted" },
    });

    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            switch (hwcResponse.Type) {
                case "DownloadFileRequest":
                    ({hwcRequest: context.hwcRequest} = await workflow.respond('DownloadToClient', { hwcResponse: hwcResponse }));
                    await hwc.invoke(
                        context.hwcRequest.HwcName,
                        context.hwcRequest,
                        _contextId
                    );
                    break;

                case "InstallComplete":
                    _bcResponse = await workflow.respond("FinalizeRequest", { hwcResponse: hwcResponse });

                    if (hwcResponse.ResultCode != 10)
                        popup.message({ title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>" + hwcResponse.ResultString + "</h3></center>" });

                    if (hwcResponse.ResultCode == 10) {
                        popup.message({ caption: "<center><font color=green size=72>&#x2713;</font><h3>" + hwcResponse.ResultString + "</h3></center>", title: captions.workflowTitle, });
                        context.hwcRequest.Operation = "HWCRestartConnector";
                        await hwc.invoke(
                            context.hwcRequest.HwcName,
                            context.hwcRequest,
                            _contextId
                        );
                    }

                    hwc.unregisterResponseHandler(_contextId);
                    break;

                case "UpdateDisplay":
                    _dialogRef.updateStatus(hwcResponse.Message);
                    break;
            }
        });

        _dialogRef.updateStatus(captions.prepareInstall);
        _dialogRef.enableAbort(true);
        ({hwcRequest: context.hwcRequest} = await workflow.respond('PrepareRequest'));
        
        debugger;
        await hwc.invoke(
            context.hwcRequest.HwcName,
            context.hwcRequest,
            _contextId
        );

        await hwc.waitForContextCloseAsync(_contextId);
        _dialogRef.close();
        
    } catch (e) {
        console.error("[Pepper] Install Error: ", e);

        if (_dialogRef)
            _dialogRef.close();

        throw e;
    }
};