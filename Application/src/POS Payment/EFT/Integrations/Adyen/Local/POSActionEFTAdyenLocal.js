
let main = async ({ workflow, context, popup, captions }) => {
    context.EntryNo = context.request.EntryNo;

    let _dialogRef = await popup.simplePayment({
        title: context.request.TypeCaption,
        initialStatus: captions.initialStatus,
        showStatus: true,
        amount: context.request.formattedAmount,
        onAbort: async () => { await workflow.respond("requestAbort"); }
    });

    let trxPromise = new Promise((resolve, reject) => {
        let pollFunction = async () => {
            try {
                let pollResponse = await workflow.respond("poll");
                if (pollResponse.newEntryNo) {
                    context.EntryNo = pollResponse.newEntryNo;
                    return;
                }
                if (pollResponse.signatureRequired) {
                    let signatureResult = false;
                    if (pollResponse.signatureType === "Receipt") {
                        signatureResult = confirm("Approve receipt?");
                    }
                    if (pollResponse.signatureType === "Bitmap") {
                        let signatureData = JSON.parse(pollResponse.signatureBitmap);
                        let signaturePopup = popup.signatureValidation();
                        signaturePopup.updateSignature(signatureData.SignaturePoint);
                        signatureResult = await signaturePopup.completeAsync();
                    }
                    if (!signatureResult) {
                        let voidResponse = await workflow.respond("signatureDecline");
                        context.EntryNo = voidResponse.newEntryNo;
                        //starts a void transaction and keeps polling
                        return;
                    }
                };
                if (pollResponse.done) {
                    debugger;
                    context.success = pollResponse.success;
                    resolve();
                    return;
                };
            }
            catch (exception) {
                try { await workflow.respond("requestAbort"); } catch { }
                reject(exception);
                return;
            }
            setTimeout(pollFunction, 1000);
        };
        setTimeout(pollFunction, 1000);
    });

    try {
        let startTrxResponse = await workflow.respond("startTransaction");
        if (startTrxResponse.newEntryNo) {
            context.EntryNo = startTrxResponse.newEntryNo;
        }

        _dialogRef.updateStatus(captions.activeStatus);
        _dialogRef.enableAbort(true);
        await trxPromise;
    }
    finally {
        if (_dialogRef) {
            _dialogRef.close();
        }
    }

    return ({ "success": context.success, "tryEndSale": context.success });
};