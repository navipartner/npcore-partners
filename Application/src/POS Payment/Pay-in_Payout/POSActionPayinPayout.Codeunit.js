/*
    POSActionPayinPayout.js

    This workflow can be invoked as sub workflow to payment or as top workflow from an action.
*/
let main = async ({workflow, context, popup, parameters, captions}) => {
    
    const paymentDetails = {
        accountNumber:  parameters.FixedAccountCode ?? '', 
        description: '<Specify payout description>',
        amount: context.suggestedAmount ?? 0, // suggested amount is prompted for in top payment workflow
        reasonCode: parameters.FixedReasonCode ?? '' 
    };
    // We need a non-zero amount.
    if (paymentDetails.amount == 0)  {
        paymentDetails.amount = await popup.numpad ({caption: captions.amountLabel, title: ''});
        if (paymentDetails.amount === null || paymentDetails.amount == 0) return {success: false, endSale: false};
    }
    
    // Get account number and description from BC Lookup
    if (paymentDetails.accountNumber == '') 
        ({accountNumber: paymentDetails.accountNumber, description: paymentDetails.description} = await workflow.respond('GetAccount'));
        
    // Prompt user for an alternative description 
    paymentDetails.description = await popup.input ({caption: 'Enter Description', title: '', value: paymentDetails.description});
    if (paymentDetails.description === null) return {success: false, endSale: false};
    
    // Get reason code from BC Lookup, not mandatory.
    if ((parameters.LookupReasonCode ?? false)) {
        ({reasonCode: paymentDetails.reasonCode} = await workflow.respond('GetReason'));
        if (paymentDetails.reasonCode === null) paymentDetails.reasonCode = '';
    }
    
    // Let BC process the action
    return await workflow.respond('HandlePayment', paymentDetails);
    
};