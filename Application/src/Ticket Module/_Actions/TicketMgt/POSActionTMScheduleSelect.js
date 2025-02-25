const main = async ({ workflow, context, popup }) => {
  debugger;

  const wfAssign = await workflow.respond("AssignSameSchedule", context);

  if (wfAssign.CancelScheduleSelection) {
    toast.error(wfAssign.Message);
    return { cancel: true };
  }

  if (!wfAssign.EditSchedule) return { cancel: false };

  const wfConfig = await workflow.respond("ConfigureWorkflow", context);

  if (context.EditSchedule) {
    const result = await popup.entertainment.scheduleSelection({
      token: context.TicketToken,
    });
    if (result === null) return { cancel: true }; // selection cancelled
  }

  if (wfConfig.CaptureTicketHolder || context.EditTicketHolder)
    await captureTicketHolderInfo(workflow, wfConfig);

  return { cancel: false };
};

async function captureTicketHolderInfo(workflow, wfConfig) {
  const ticketHolder = await popup.configuration({
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
    ],
  });

  if (ticketHolder !== null)
    await workflow.respond("SetTicketHolder", ticketHolder);
}
