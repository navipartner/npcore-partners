let main = async ({ workflow, popup, parameters, context, captions }) => {
    debugger;
    await workflow.respond("AddPresetValuesToContext");
    //Select seating
    if (!context.seatingCode) {
        context.seatingCode = "";
        if (parameters.SeatingCode) {
            context.seatingCode = parameters.SeatingCode;
        } else {
            switch (parameters.InputType + "") {
                case "0":
                    context.seatingCode = await popup.input({ caption: captions.SeatingIDLbl });
                    break;
                case "1":
                    context.seatingCode = await popup.numpad({ caption: captions.SeatingIDLbl });
                    break;
                case "2":
                    await workflow.respond("SelectSeating");
                    break;
            }
        }
    };
    if (!context.seatingCode) { return };

    //Select waiter pad
    if (!context.waiterPadNo) {
        await workflow.respond("SelectWaiterPad");
    };
    if (!context.waiterPadNo) { return };

    //Split waiter pads/bills
    await workflow.respond("GenerateSplitBillContext");
    console.log("Context: " + JSON.stringify(context));
    result = await popup.hospitality.splitBill({ caption: captions.PopupCaption, waiterPadNo: context.waiterPadNo, items: context.items, bills: context.bills });
    if (result) { await workflow.respond("DoSplit", result) };
    if (context.CleanupMessageText) {
        popup.message(context.CleanupMessageText);
    }
}