let main = async ({ workflow, popup, parameters, context, captions }) => {  
    debugger;    
    await workflow.respond("addPresetValuesToContext");
    if (!context.seatingCode) {
        context.seatingCode = "";
        if (parameters.FixedSeatingCode) {
            context.seatingCode = parameters.FixedSeatingCode;
        } else {
            switch(parameters.InputType + "") {
                case "0":
                    context.seatingCode = await popup.input({caption: captions.InputTypeLabel});
                    break;
                case "1":
                    context.seatingCode = await popup.numpad({caption: captions.InputTypeLabel});
                    break;
                case "2":
                    await workflow.respond("seatingInput");
                    break;
            }
        }
    };
    if (!context.seatingCode) {return};

    if (!context.waiterPadNo) {
        if (context.seatingCode) {
            await workflow.respond("selectWaiterPad");
        }
    };
    if (!context.waiterPadNo) {return};
            
    await workflow.respond("splitWaiterPad");
}