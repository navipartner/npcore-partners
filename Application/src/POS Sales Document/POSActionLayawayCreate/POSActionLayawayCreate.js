let main = async ({ workflow, parameters, popup, captions }) => {
    let PercDownpayment;
    
    if (parameters.PromptDownpayment) {
        PercDownpayment = await popup.numpad({title: captions.DownpaymentPctTitle, caption: captions.DownpaymentPctLead, value: parameters.DownpaymentPercent});
        if (PercDownpayment == null) return;
    }else
        PercDownpayment = parameters.DownpaymentPercent;

    await workflow.respond("CreateLayaway", {PercDownpayment:PercDownpayment});
}