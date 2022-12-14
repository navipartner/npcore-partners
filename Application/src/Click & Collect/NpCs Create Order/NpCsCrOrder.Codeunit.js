let main = async ({ workflow, context, popup, parameters, captions}) => {

    switch(parameters.fromStoreCode + "") {
        case "0":
            await workflow.respond("SelectFromStoreCodeFromPOSRelation"); 
            break;
        case "1":
            await workflow.respond("SelectFromStoreCodeFromStoreCodeParameter");
            break;
        case "2":
            await workflow.respond("SelectFromStoreCodeFromLocationFilterParameter");
            break; 
            } 
    if (!context.fromStoreCode) {return}

    if (!context.toStoreCode) {
        await workflow.respond("SelectToStoreCode");
        if (context.ConfirmMissingStock) {
            if (context.MissingStockInCompanyLbl.length > 0) {
                if (!(await popup.confirm({ title: captions.ConfirmSetStoreForMissingStock, caption: context.MissingStockInCompanyLbl }))) {
                    return;
                } 
            }
        } 
    }

    if (!context.workflowCode) {
        await workflow.respond("SelectWorkflow")
    }

    if (!context.customerNo) {
        await workflow.respond("SelectCustomer")
    }

    if (!context.prepaymentPercent) {
        context.prepaymentPercent = await popup.numpad({caption: captions.SetPrepaymentPercentage,value: parameters.prepaymentPercent});
    }

    await workflow.respond("CreateCollectOrder");

    if (context.HandlePrepaymentFailed) {
        if (context.HandlePrepaymentFailReasonMsg.length > 0) {
            await popup.message(context.HandlePrepaymentFailReasonMsg);
        }
    }                
};