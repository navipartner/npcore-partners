let main = async ({workflow, context, popup, parameters, captions}) => {

    let ReturnReasonCode;    
    let saleLines = runtime.getData("BUILTIN_SALELINE");
    let currentQty = parseFloat(saleLines._current[12]);
    if (
        parameters.Constraint ==
        parameters.Constraint["Positive Quantity Only"] &&
        currentQty < 0
    ) {
        popup.error(captions.MustBePositive);
        return;
    }
    if (
        parameters.Constraint ==
        parameters.Constraint["Negative Quantity Only"] &&
        currentQty > 0
    ) {
        popup.error(captions.MustBeNegative);
        return;
    }
    context.PromptQuantity =
        parameters.InputType == 0
            ? await popup.numpad({ caption: captions.QtyCaption, value: currentQty })
            : parameters.InputType == 1
                ? parameters.ChangeToQuantity
                : parameters.InputType == 2
                    ? currentQty + parameters.IncrementQuantity
                    : null;
    if (!context.PromptQuantity) {
        return;
    }
    if (parameters.MaxQuantityAllowed) {
        if (
            parameters.MaxQuantityAllowed != 0 &&
            Math.abs(context.PromptQuantity) > parameters.MaxQuantityAllowed
        ) {
            popup.error(
                captions.CannotExceedMaxQty + " " + parameters.MaxQuantityAllowed
            );
            return;
        }
    }
    let PromptForReason = await workflow.respond("AddPresetValuesToContext");
    if (
        parameters.PromptUnitPriceOnNegativeInput &&
        (parameters.NegativeInput
            ? context.PromptQuantity > 0
            : context.PromptQuantity < 0)
    ) {
        context.PromptUnitPrice = await popup.numpad({
            caption: captions.PriceCaption,
            value: saleLines._current[15],
        });
        if (!context.PromptUnitPrice) return;
    }

    if (PromptForReason["PromptForReason"]) {
        ReturnReasonCode = await workflow.respond("AskForReturnReason");
        context.PromptForReason = true;
    }
    else
    {
        context.PromptForReason = false;
        ReturnReasonCode = "";
    }

    await workflow.respond("ChangeQty",ReturnReasonCode);
};
