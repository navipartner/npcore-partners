await workflow.respond("AddPresetValuesToContext");
let saleLines = runtime.getData("BUILTIN_SALELINE");
let currentQty = parseFloat(saleLines._current[12]);
if (($parameters.Constraint == $parameters.Constraint["Positive Quantity Only"]) && (currentQty < 0)) {
    popup.error($labels.MustBePositive);
    return;
};
if (($parameters.Constraint == $parameters.Constraint["Negative Quantity Only"]) && (currentQty > 0)) {
    popup.error($labels.MustBeNegative);
    return;
};
$context.PromptQuantity =
    ($parameters.InputType == $parameters.InputType["Ask"]) ? await popup.numpad({ caption: $labels.QtyCaption, value: currentQty }) :
        ($parameters.InputType == $parameters.InputType["Fixed"]) ? $parameters.ChangeToQuantity :
            ($parameters.InputType == $parameters.InputType["Increment"]) ? currentQty + $parameters.IncrementQuantity : null;
if (!$context.PromptQuantity) { return; };
if ($parameters.MaxQuantityAllowed) {
    if (($parameters.MaxQuantityAllowed != 0) && (Math.abs($context.PromptQuantity) > $parameters.MaxQuantityAllowed)) {
        popup.error($labels.CannotExceedMaxQty + " " + $parameters.MaxQuantityAllowed);
        return;
    };
};
if (($parameters.PromptUnitPriceOnNegativeInput) && ($parameters.NegativeInput ? $context.PromptQuantity > 0 : $context.PromptQuantity < 0)) {
    $context.PromptUnitPrice = await popup.numpad({ caption: $labels.PriceCaption, value: saleLines._current[15] });
};
if ($context.PromptForReason) {
    await workflow.respond("AskForReturnReason");
};
workflow.respond();