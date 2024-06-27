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
        "Additional Experience",
        "Ticket to Coupon"
    ];
    var inputNames = [
        "Standard",
        "MPOS NFC Scan"
    ];
    
    let functionId = Number(parameters.Function);
    let inputId = Number(parameters.InputMethod);
    let inputMethod = inputNames[inputId];
    let actionSettings = {};
    windowTitle = captions.TicketTitle.substitute(functionNames[functionId].toString());
    actionSettings.FunctionId = functionId;
    actionSettings.DefaultTicketNumber = parameters.DefaultTicketNumber;
    await workflow.respond("ConfigureWorkflow", actionSettings);
    debugger;

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

    actionSettings.TicketNumber = ticketNumber;
    await workflow.respond("RefineWorkflow", actionSettings);
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
    if (context.UseFrontEndUx) {

        const scheduleSelection = await workflow.run('TM_SCHEDULE_SELECT', {
            context: {
                TicketToken: context.TicketToken,
                EditTicketHolder: functionId === 3 || functionId === 5,
                EditSchedule: functionId === 3
            }
        })

        if (scheduleSelection.cancel) {
            toast.warning ('Schedule not updated', {title: windowTitle});
            return;
        }

    } else {
        actionSettings.TicketQuantity = ticketQuantity;
        actionSettings.TicketReference = ticketReference;
        const actionResponse = await workflow.respond("DoAction", actionSettings);

        if (actionResponse.coupon) {
            toast.success (`Coupon: ${actionResponse.coupon.reference_no}`, {title: windowTitle});
            await workflow.run('SCAN_COUPON', { parameters: { ReferenceNo: actionResponse.coupon.reference_no } });
        }
    }

    if (context.Verbose) { 
        await popup.message ({
            caption: context.VerboseMessage, 
            title: windowTitle});
    } else {
        if(context.VerboseMessage){ 
            toast.success (context.VerboseMessage, {title: windowTitle});
        }
    }

}

