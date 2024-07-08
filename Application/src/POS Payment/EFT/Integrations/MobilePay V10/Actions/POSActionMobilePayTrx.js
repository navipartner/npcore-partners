
let main = async ({ workflow, context, popup }) => {
    // State shared between frontend & backend
    context.EntryNo = context.request.EntryNo;
    context.done = false;
    context.abortRequested = false;
    context.success = false;
    context.lastStatusCode = 0;
    context.lastStatusDescription = "";

    let _dialogRef = await popup.mobilePay({
        title: context.request.transactionCaption,
        initialStatus: context.lastStatusDescription,
        showStatus: true,
        amount: context.request.formattedAmount,
        qr: {
            value: context.request.qr,
        },
        onAbort: async () => { await workflow.respond("requestAbort") }
    });
    _dialogRef.enableAbort(true);

    let trxPromise = new Promise((resolve, reject) => {
        let pollFunction = async () => {
            try {
                await workflow.respond("poll");
                if (context.done) {
                    resolve();
                    return;
                }
                _dialogRef.updateStatus(context.lastStatusDescription);
            }
            catch (exception) {
                //try to request abort on mobilepays API to bring us back in sync before we fail on our side
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
        if (context.request.QrOnCustomerDisplay)
        {
            await workflow.run("HTML_DISPLAY_QR", {context: 
                { 
                    IsNestedWorkflow: true,
                    QrShow: true,
                    QrTitle: "MobilePay",
                    QrMessage: context.request.formattedAmount,
                    QrContent: context.request.qr
                }});
        }
        await trxPromise;
    }
    finally {
        if (_dialogRef) {
            _dialogRef.close();
        }
        if (context.request.QrOnCustomerDisplay)
        {
            await workflow.run("HTML_DISPLAY_QR", {context: 
            {
                IsNestedWorkflow: true,
                QrShow: false,
                QrTitle: "MobilePay",
            }});    
        }    
    }

    return ({ "success": context.success, "tryEndSale": context.success });
};