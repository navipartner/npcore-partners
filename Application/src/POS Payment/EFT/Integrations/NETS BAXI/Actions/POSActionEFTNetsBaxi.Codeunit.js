let main = async ({ workflow, hwc, popup, context, captions }) => {
    debugger;

    if (context.request.OfflinePhoneAuth) {
        if (!await popup.confirm(captions.PhoneApprovalRequired)) {
            await workflow.respond("PhoneAuthCancelled");
            return ({ "success": false, "tryEndSale": false });
        }
        let phoneApprovalCode = await popup.stringpad(captions.PhoneApprovalInput);
        if (phoneApprovalCode === null) {
            await workflow.respond("PhoneAuthCancelled");
            return ({ "success": false, "tryEndSale": false });
        }

        context.request.TransactionParameters.PhoneAuthCode = phoneApprovalCode;
    }

    let _dialogRef;
    if (!context.request.Unattended) {
        _dialogRef = await popup.simplePayment({
            showStatus: context.request.Type === "Transaction",
            title: context.request.TypeCaption,
            amount: context.request.AmountCaption,
            onAbort: async () => {
                await hwc.invoke(
                    "EFTNetsBaxi",
                    {
                        Type: "RequestAbort",
                        EntryNo: context.request.EntryNo,
                    },
                    _contextId,
                );
            },
        });
    }
    

    let _contextId;
    let bcResponse;
    context.success = false;

    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            debugger;
            try {
                switch (hwcResponse.Type) {
                    case "Transaction":
                        bcResponse = await workflow.respond("TransactionCompleted", hwcResponse);
                        if (bcResponse.voidTransaction) {
                            await workflow.run(bcResponse.voidWorkflow, { context: { request: bcResponse.voidWorkflowRequest } });
                        }
                        context.success = bcResponse.BCSuccess;
                        hwc.unregisterResponseHandler(_contextId); //done
                        break;

                    case "DisplayUpdate":
                        _dialogRef && _dialogRef.updateStatus(hwcResponse.DisplayUpdateResponse.Text);
                        break;

                    case "Open":
                    case "Close":
                    case "GetLastResult":
                    case "Administration":
                        bcResponse = await workflow.respond("OperationCompleted", hwcResponse);
                        if (bcResponse.voidTransaction) {
                            await workflow.run(bcResponse.voidWorkflow, { context: { request: bcResponse.voidWorkflowRequest } });
                        }
                        context.success = bcResponse.BCSuccess;
                        hwc.unregisterResponseHandler(_contextId); //done
                        break;
                }
            }
            catch (e) {
                hwc.unregisterResponseHandler(_contextId, e); //exception
            }
        });

        if (context.request.Type === "Transaction") {
            _dialogRef && _dialogRef.updateStatus(captions.statusInitializing);
            _dialogRef && _dialogRef.enableAbort(true);
        }

        await hwc.invoke(
            "EFTNetsBaxi",
            context.request,
            _contextId
        );
        await hwc.waitForContextCloseAsync(_contextId);
    }
    finally {
        _dialogRef && _dialogRef.close();        
    }
    return ({ "success": context.success, "tryEndSale": context.success });
}

