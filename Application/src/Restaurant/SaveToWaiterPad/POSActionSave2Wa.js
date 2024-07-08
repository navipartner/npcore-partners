let main = async ({ workflow, context, popup, parameters, captions }) => {
    await workflow.respond("addPresetValuesToContext");
    //seatingInput
    if (!context.seatingCode) {
        if (parameters.FixedSeatingCode) {
            context.seatingCode = parameters.FixedSeatingCode;
        } else {
            switch (parameters.InputType + "") {
                case "0":
                    {
                        let result = await popup.input({ caption: captions.InputTypeLabel });
                        if (!result) { return };
                        context.seatingCode = result;
                        break;
                    }
                case "1":
                    {
                        let result = await popup.numpad({ caption: captions.InputTypeLabel });
                        if (!result) { return };
                        context.seatingCode = result;
                        break;
                    }
            }
        }
    }
    await workflow.respond("seatingInput");
    if (!context.seatingCode) {
        return;
    }

    //createNewWaiterPad
    if ((context.seatingCode) && (context.confirmString)) {
        if (await popup.confirm({ title: captions.confirmLabel, caption: context.confirmString })) {
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

    if (context.ShowResultMessage) {
        popup.message(context.ResultMessageText);
    };
}