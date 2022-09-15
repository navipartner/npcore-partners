let main = async ({ workflow, hwc, popup, context, captions }) => {
    debugger;
    let _dialogRef = await popup.simplePayment({
        showStatus: true,
        title: captions.title,
        amount: context.request.FormattedAmount,
        onAbort: async () => {
            await hwc.invoke(
                "EFTNetsFlexiiterm",
                {
                    Type: "RequestAbort",
                    EntryNo: context.request.EntryNo,
                },
                _contextId,
            );
        },
    });

    let _contextId;
    let hwcRequest;
    context.success = false;

    try {
        _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
            debugger;
            try {
                switch (hwcResponse.Type) {
                    case "CardData":
                        hwcRequest = await workflow.respond("CardData", hwcResponse);
                        await hwc.invoke("EFTNetsFlexiiterm", hwcRequest, _contextId);
                        break;

                    case "ReceiptCheck":
                        hwcRequest = await workflow.respond("ReceiptCheck", hwcResponse);
                        await hwc.invoke("EFTNetsFlexiiterm", hwcRequest, _contextId);
                        break;

                    case "ReceiptData":
                        hwcRequest = await workflow.respond("ReceiptData", hwcResponse);
                        await hwc.invoke("EFTNetsFlexiiterm", hwcRequest, _contextId);
                        break;

                    case "TransactionResult":
                        hwcRequest = await workflow.respond("TransactionResult", hwcResponse);
                        await hwc.invoke("EFTNetsFlexiiterm", hwcRequest, _contextId);
                        break;

                    case "TransactionCompleted":
                        let bcResponse = await workflow.respond("TransactionCompleted", hwcResponse);
                        context.success = bcResponse.BCSuccess;
                        hwc.unregisterResponseHandler(_contextId); //done
                        break;

                    case "RequestMissingReceiptRecheck":
                        let waitForReceipt = await popup.confirm(captions.recheckReceipt);
                        await hwc.invoke("EFTNetsFlexiiterm",
                            {
                                EntryNo: context.request.EntryNo,
                                Type: "RecheckReceiptConfirmResult",
                                RecheckMissingReceipt: waitForReceipt
                            },
                            _contextId);
                        break;

                    case "DisplayUpdate":
                        let status = "";
                        if (hwcResponse.UIStatus)
                            status += hwcResponse.UIStatus + ' ';

                        _dialogRef.updateStatus(status);
                        break;

                    case "RequestGenericConfirm":
                        let confirmation = await popup.confirm(hwcResponse.GenericConfirm);
                        await hwc.invoke("EFTNetsFlexiiterm",
                            {
                                EntryNo: context.request.EntryNo,
                                Type: "GenericConfirmResult",
                                GenericConfirmResult: confirmation
                            },
                            _contextId);
                        break;

                    case "RequestGenericMessage":
                        await popup.message(hwcResponse.GenericMessage);
                        break;

                    case "RequestPhoneApproval":
                        if (!await popup.confirm(captions.PhoneApprovalRequired)) {
                            await hwc.invoke("EFTNetsFlexiiterm",
                                {
                                    EntryNo: context.request.EntryNo,
                                    Type: "PhoneApprovalResult",
                                    PhoneAuthResult: "Cancel"
                                },
                                _contextId);
                            return;
                        }
                        let phoneApprovalCode = await popup.stringpad(captions.PhoneApprovalInput);
                        if (phoneApprovalCode === null) { 
                            await hwc.invoke("EFTNetsFlexiiterm",
                                {
                                    EntryNo: context.request.EntryNo,
                                    Type: "PhoneApprovalResult",
                                    PhoneAuthResult: "Cancel"
                                },
                                _contextId);
                            return;
                        }
                        if (phoneApprovalCode === "") { 
                            await hwc.invoke("EFTNetsFlexiiterm",
                                {
                                    EntryNo: context.request.EntryNo,
                                    Type: "PhoneApprovalResult",
                                    PhoneAuthResult: "Skip"
                                },
                                _contextId);
                            return;
                        }
                        await hwc.invoke("EFTNetsFlexiiterm",
                            {
                                EntryNo: context.request.EntryNo,
                                Type: "PhoneApprovalResult",
                                PhoneAuthResult: "Input",
                                PhoneApprovalCode: phoneApprovalCode
                            },
                            _contextId);
                        break;

                }
            }
            catch (e) {
                hwc.unregisterResponseHandler(_contextId, e);
            }
        });

        _dialogRef.updateStatus(captions.statusInitializing);
        _dialogRef.enableAbort(true);

        await hwc.invoke(
            "EFTNetsFlexiiterm",
            context.request,
            _contextId
        );
        await hwc.waitForContextCloseAsync(_contextId);

        if (!context.success) {
            popup.error({ title: captions.title, caption: "<center><font color=red size=72>&#x274C;</font><h3>" + captions.declined + "</h3></center>" })
        }
    }
    finally {
        if (_dialogRef) {
            _dialogRef.close();
        }
    }
    return ({ "success": context.success, "tryEndSale": context.success });
}

