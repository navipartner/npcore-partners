let main = async ({ workflow, context, captions, parameters }) => {
    context.quantity = 1;
    if (parameters.PromptQuantity) {
        context.quantity = await popup.numpad(captions.VoucherQuantity);
    }
    if (!context.quantity || context.quantity > 100 || context.quantity < 1) {
        await popup.error(captions.InvalidQuantity);
        return;
    }

    context.amount = await popup.numpad(captions.VoucherAmount);
    if (!context.amount || context.amount < 0) {
        await popup.error(captions.InvalidAmount);
        return;
    }

    context.discountPct = 0;
    if (parameters.PromptDiscountPct) {
        context.discountPct = await popup.numpad(captions.VoucherDiscount);
    }
    if (context.discountPct < 0 || context.discountPct > 100) {
        await popup.error(captions.InvalidDiscount);
        return;
    }

    for (i = 1; i < context.quantity + 1; i++) {
        debugger;
        context.voucherNumber = i;
        let { workflowName, integrationRequest, synchronousRequest } = await workflow.respond("PrepareGiftCardLoad");

        if (!synchronousRequest) {
            let { success } = await workflow.run(workflowName, { context: { request: integrationRequest, amount: context.amount } });
            if (!success) {
                return;
            }
        };

        if (context.discountPct !== 0) {
            context.eftEntryNo = integrationRequest.EntryNo;
            await workflow.respond("InsertDiscountLine");
        }
    }
}