/*
    POSActionPepperInstall.Codeunit.js
*/
let main = async ({ workflow, context, popup, runtime, hwc, data, parameters, captions, scope }) => {
    
    let _dialogRef, _contextId, _hwcResponse = { "Success": false }, _bcResponse = { "Success": false };

    _dialogRef = await popup.simplePayment({
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
                    ({ request: context.request } = await workflow.respond('DownloadToClient', { hwcResponse: hwcResponse }));
                    await hwc.invoke(
                        "EFTPepper",
                        context.request,
                        _contextId
                    );
                    break;

                case "InstallComplete":
                    _bcResponse = await workflow.respond("FinalizeRequest", { hwcResponse: hwcResponse });

                    if (hwcResponse.ResultCode != 10)
                        popup.message({ title: captions.workflowTitle, caption: "<center><font color=red size=72>&#x274C;</font><h3>" + hwcResponse.ResultString + "</h3></center>" });

                    if (hwcResponse.ResultCode == 10) {
                        popup.message({ caption: "<center><font color=green size=72>&#x2713;</font><h3>" + hwcResponse.ResultString + "</h3></center>", title: captions.workflowTitle, });
                        context.request.Operation = "HWCRestartConnector";
                        await hwc.invoke(
                            "EFTPepper",
                            context.request,
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
        ({ request: context.request } = await workflow.respond('PrepareRequest'));
        
        debugger;
        await hwc.invoke(
            "EFTPepper",
            context.request,
            _contextId
        );

        await hwc.waitForContextCloseAsync(_contextId);

        if (_dialogRef) {
            _dialogRef.close();
        }
        
    } catch (e) {
        console.error("[Pepper] Install Error: ", e);

        if (_dialogRef)
            _dialogRef.close();

        throw e;
    }
};