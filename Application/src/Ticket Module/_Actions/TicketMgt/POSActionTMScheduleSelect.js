let main = async ({ workflow, context, popup, parameters, captions}) => 
{
    debugger;
    const wfConfig = await workflow.respond('ConfigureWorkflow', context);

    debugger;
    let r = await popup.entertainment.scheduleSelection({ token: context.TicketToken });
    if (r === null) 
        return {cancel: true}; // selection cancelled

    if (wfConfig.CaptureTicketHolder || context.EditTicketHolder) 
        await captureTicketHolderInfo(workflow, context, wfConfig);

    return {cancel: false};
};

async function captureTicketHolderInfo(workflow, context, wfConfig)
{
    let ticketHolder = await popup.configuration({
        title: wfConfig.ticketHolderTitle,
        caption: wfConfig.ticketHolderCaption,
        settings: [
            {
                id: "ticketHolderName",
                type: "text",
                caption: wfConfig.ticketHolderNameLabel,
                value: wfConfig.ticketHolderName,
            },
            {
                id: "ticketHolderEmail",
                type: "text",
                caption: wfConfig.ticketHolderEmailLabel,
                value: wfConfig.ticketHolderEmail,
            },
            {
                id: "ticketHolderPhone",
                type: "phoneNumber",
                caption: wfConfig.ticketHolderPhoneLabel,
                value: wfConfig.ticketHolderPhone,
            },
        ]
    });

    if (ticketHolder !== null)
        await workflow.respond("SetTicketHolder", ticketHolder);
};