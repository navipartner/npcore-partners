
let main = async ({ workflow, context, popup, captions }) => {
    context.EntryNo = context.request.EntryNo;

    let _dialogRef = await popup.simplePayment({
        title: context.request.TypeCaption,
        initialStatus: captions.initialStatus,
        showStatus: true,
        amount: context.request.formattedAmount,
        onAbort: async () => { await workflow.respond("requestAbort"); }
    });

    try {
        let startTrxResponse = await workflow.respond("startTransaction");
        if (startTrxResponse.newEntryNo) {
            context.EntryNo = startTrxResponse.newEntryNo;
        }
        if (startTrxResponse.selfService){
        _dialogRef && _dialogRef.updateStatus(captions.activeStatusSS);
        } else {
        _dialogRef && _dialogRef.updateStatus(captions.activeStatus);
        }
        _dialogRef && _dialogRef.enableAbort(true);
        await trxPromise(context, captions, popup, workflow);
    }
    finally {
        _dialogRef && _dialogRef.close();
    }

    return ({ "success": context.success, "tryEndSale": context.success });
};

function trxPromise(context, captions, popup, workflow) {
    return new Promise((resolve, reject) => {
        let pollFunction = async () => {
            try {
                let pollResponse = await workflow.respond("poll");
                if (pollResponse.newEntryNo) {
                    debugger;
                    context.EntryNo = pollResponse.newEntryNo;
                    setTimeout(pollFunction, 1000);
                    return;
                }
                if (pollResponse.signatureRequired) {
                    let signatureResult = false;
                    if (!context.request.unattended && pollResponse.signatureType === "Receipt") {
                        signatureResult = await popup.confirm(captions.approveSignature);
                    }
                    if (!context.request.unattended && pollResponse.signatureType === "Bitmap") {
                        debugger;
                        let signatureData = JSON.parse(pollResponse.signatureBitmap);
                        let signaturePopup = await popup.signatureValidation({signature: signatureData.SignaturePoint});
                        debugger;
                        signatureResult = await signaturePopup.completeAsync();
                    }
                    if (!signatureResult) {
                        let voidResponse = await workflow.respond("signatureDecline");
                        context.EntryNo = voidResponse.newEntryNo;
                        //starts a void transaction and keeps polling
                        setTimeout(pollFunction, 1000);
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
                debugger;
                try { await workflow.respond("requestAbort"); } catch { }
                reject(exception);
                return;
            }
            setTimeout(pollFunction, 1000);
        };
        setTimeout(pollFunction, 1000);
    });
}