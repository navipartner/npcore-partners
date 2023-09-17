let main = async ({ workflow, context, parameters, popup, captions }) => {
    await workflow.respond("OnBeforeWorkflow");
    var optionNames = ["Select Membership", "View Points", "Redeem Points", "Available Coupons", "Select Membership (EAN Box)"];
    var functionInt = parameters.Function.toInt();

    if (functionInt < 0) { functionInt = 0; };
    
    if (parameters.DefaultInputValue.length > 0) { context.show_dialog = false; };
    
    let windowTitle = captions.LoyaltyWindowTitle.substitute(optionNames[functionInt]);
    
    let membercard_number = '';
    if (context.show_dialog) {
        membercard_number = await popup.input({ caption: captions.MemberCardPrompt, title: windowTitle });
        if (membercard_number === null) { return; }
    };
    
    let result = await workflow.respond("do_work", { membercard_number: membercard_number });
    if (result.workflowName == "") {
        return;
    }
    workflow.run(result.workflowName, { parameters: result.parameters });
};