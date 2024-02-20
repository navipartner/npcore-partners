let main = async ({ workflow, context, popup, parameters, captions}) => 
{
    var functionNames = [
        "Admission Count",
        "Register Arrival",
        "Revoke Reservation",
        "Edit Reservation",
        "Reconfirm Reservation",
        "Edit Ticketholder",
        "Change Confirmed Ticket Quantity",
        "Pickup Ticket Reservation",
        "Convert To Membership",
        "Register Departure",
        "Additional Experience"
    ];
    var inputNames = [
        "Standard",
        "MPOS NFC Scan"
    ];
    
    let functionId = Number(parameters.Function);
    let inputId = Number(parameters.InputMethod);
    let inputMethod = inputNames[inputId];
    let responseObj = {};
    windowTitle = captions.TicketTitle.substitute(functionNames[functionId].toString());
    responseObj.FunctionId = functionId;
    responseObj.DefaultTicketNumber = parameters.DefaultTicketNumber;
    await workflow.respond("ConfigureWorkflow", responseObj);
    
    let ticketNumber; 
    if (context.ShowTicketDialog) {
        if (inputMethod === "Standard") {
            ticketNumber = await popup.input ({
                caption: captions.TicketPrompt, 
                title: windowTitle
            });
            
            if (!ticketNumber) 
                return;

        } else if (inputMethod === "MPOS NFC Scan") {
            var mposResult = await workflow.run("MPOS_API", {
                context:
                {
                    IsFromWorkflow: true,
                    FunctionName: "NFC_SCAN",
                    Parameters: {}
                }
            });

            if (!mposResult.IsSuccessful) {
                popup.error(mposResult.ErrorMessage, "mPOS NFC Error");
                return;
            }

            if (!mposResult.Result.ID)
                return;

            ticketNumber = mposResult.Result.ID;
        }
    }
    responseObj.TicketNumber = ticketNumber;
    await workflow.respond("RefineWorkflow", responseObj);
    let ticketQuantity;
    if (context.ShowTicketQtyDialog) { 
        ticketQuantity = await popup.numpad({
            caption: captions.TicketQtyPrompt.substitute(context.TicketMaxQty), 
            title: windowTitle
        });
        if (ticketQuantity === null) // cancel returns null
            return;
    }
    let ticketReference;
    if (context.ShowReferenceDialog) {
        ticketReference = await popup.input({
            caption: captions.ReferencePrompt, 
            title: windowTitle
        });
        if (ticketReference === null) // cancel returns null
            return;
    }
    responseObj.TicketQuantity = ticketQuantity;
    responseObj.TicketReference = ticketReference;
    await workflow.respond("DoAction", responseObj);

    if (context.Verbose) { 
        await popup.message ({
            caption: context.VerboseMessage, 
            title: windowTitle});
    }
};