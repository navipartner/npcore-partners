let main = async ({ workflow, captions, parameters, popup }) => {
    let prepaymentValue;
    if (parameters.Dialog) {
        if (parameters.InputIsAmount) {
            prepaymentValue = await popup.numpad({ caption: captions.prepaymentAmountLead, title: captions.prepaymentDialogTitle, value: parameters.FixedValue });
            if (prepaymentValue === null) return;
        } else {
            prepaymentValue = await popup.numpad({ caption: captions.prepaymentPctLead, title: captions.prepaymentDialogTitle, value: parameters.FixedValue });
            if (prepaymentValue === null) return;
        }
    } else
        prepaymentValue = parameters.FixedValue;

    return await workflow.respond("prepayDocument", { prepaymentValue: prepaymentValue });

};