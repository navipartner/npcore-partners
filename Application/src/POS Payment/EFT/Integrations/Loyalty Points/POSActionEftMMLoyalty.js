let main = async ({ workflow, popup, context, captions }) => { 
    debugger;
    
    let _dialogRef;
    if (!context.request.Unattended) {
        _dialogRef = await popup.simplePayment({
            showStatus: true,
            title: context.request.TypeCaption,
            amount: context.request.AmountCaption,
            onAbort: async () => {
            },
        });
    }
    
    let _bcResponse;
    try {
        context.soapResponse = await workflow.respond("InvokePaymentService", context);
        
    } finally {
        if (context.soapResponse === undefined) {
            _bcResponse.success = false;
        } else {
            _bcResponse = await workflow.respond("TransactionCompleted", context);
        }

        _dialogRef && _dialogRef.close();
        debugger;
    }

    return ({ "success": _bcResponse.success, "tryEndSale": _bcResponse.success });
}