
let main = async ({ workflow, context, popup, captions }) => {
    context.EntryNo = context.request.EntryNo;

    let _dialogRef = await popup.simplePayment({
        title: captions.title,
        initialStatus: captions.initialStatus,
        showStatus: true,
        amount: context.request.formattedAmount,
        onAbort: async () => { await workflow.respond("requestAbort"); }
    });

    let trxPromise = new Promise((resolve, reject) => {
        let pollFunction = async () => {
            try {
                let pollResponse = await workflow.respond("poll");
                if (pollResponse.done) {
                    if (pollResponse.signatureRequired) {
                        if (!await popup.confirm(captions.approveSignature)) {
                            await workflow.respond("signatureDecline");
                        }
                    }
                    debugger;
                    context.success = pollResponse.success;
                    resolve();
                    return;
                }
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
        await workflow.respond("startTransaction");
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