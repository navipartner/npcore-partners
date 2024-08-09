async function main({ workflow, parameters }) {
    const createDocumentReservationAmountSaleResponse = await workflow.respond("CreateDocumentReservationAmountSale");
    if (!createDocumentReservationAmountSaleResponse.success) return;

    const paymentWorkflowResponse = await workflow.run('PAYMENT_2', {
        parameters: {
            HideAmountDialog: true,
            paymentNo: parameters.POSPaymentMethodCode,
            tryEndSale: false
        }
    });
    if (!paymentWorkflowResponse.success) {
        await workflow.run('CANCEL_POS_SALE', { parameters: { silent: true } });
        return;
    }

    return await workflow.respond('ReserverPayment', { salesDocumentID: createDocumentReservationAmountSaleResponse.salesDocumentID });
}