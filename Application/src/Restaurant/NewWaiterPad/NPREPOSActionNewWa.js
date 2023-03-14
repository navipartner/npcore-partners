let main = async ({ workflow, popup, parameters, context, captions }) => {
    await workflow.respond("addPresetValuesToContext");
    //Select seating
    if ((!context.seatingCode) || (!parameters.UseSeatingFromContext)){
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

    //New waiter pad
    if (context.confirmString) {
        result = await popup.confirm({caption: captions.ConfirmLabel, label: captions.confirmString}); 
        if (result) { return };
    };

    //Ask for number of guests
    if (parameters.AskForNumberOfGuests) {
        context.numberOfGuests = await popup.numpad({caption: captions.NumberOfGuestsLabel});
        if (!context.numberOfGuests) { return }
    }

    //New waiter pad
    if (context.seatingCode) {
        await workflow.respond("newWaiterPad");
    }

    //Action Message
    if (context.actionMessage) {
        await popup.message({caption: captions.ActionMessageLabel, label: captions.actionMessage});
        return;
    };   
}