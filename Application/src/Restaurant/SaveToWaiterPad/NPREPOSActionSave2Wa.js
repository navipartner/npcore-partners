let main = async ({workflow, context, popup, parameters, captions}) => {
    await workflow.respond("AddPresetValuesToContext");
    //seatingInput
    if (!context.seatingCode) {
        if (parameters.FixedSeatingCode) {
            context.seatingCode = parameters.FixedSeatingCode
        } else {
            switch(param.InputType + "") {
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
    }
    //createNewWaiterPad
    if ((context.seatingCode) && (context.confirmString)) {
        if (await popup.confirm({caption: captions.confirmLabel, label: context.confirmString})){
            await workflow.respond("createNewWaiterPad");
        } else {
            return
        }
    }       
    //selectWaiterPad
    if (!context.waiterPadNo) {
        if (context.seatingCode) {
            await workflow.respond("selectWaiterPad");
        }
    }
    //saveSale2Pad
    if (context.waiterPadNo) {
        await workflow.respond("saveSale2Pad");
    }
}