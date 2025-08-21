const main = async ({ workflow, context, popup, toast, captions }) => {
  debugger;

  const wfAssign = await workflow.respond("AssignSameSchedule", context);

  if (wfAssign.CancelScheduleSelection) {
    toast.error(wfAssign.Message);
    return { cancel: true };
  }

  if (!wfAssign.EditSchedule && !context.EditTicketHolder)
    return { cancel: false };

  const wfConfig = await workflow.respond("ConfigureWorkflow", context);

  if (context.EditSchedule) {
    const result = await popup.entertainment.scheduleSelection({
      token: context.TicketToken,
    });
    if (result === null) return { cancel: true }; // selection cancelled
  }

  if (wfConfig.CaptureTicketHolder || context.EditTicketHolder)
    await captureTicketHolderInfo(workflow, wfConfig, captions);

  return { cancel: false };
};

async function captureTicketHolderInfo(workflow, wfConfig, captions) {
  const ticketHolder = await popup.configuration({
    title: captions.ticketHolderTitle,
    caption: captions.ticketHolderCaption,
    settings: [
      {
        id: "ticketHolderName",
        type: "text",
        caption: captions.ticketHolderNameLabel,
        value: wfConfig.ticketHolderName,
      },
      {
        id: "ticketHolderEmail",
        type: "text",
        caption: captions.ticketHolderEmailLabel,
        value: wfConfig.ticketHolderEmail,
      },
      {
        id: "ticketHolderPhone",
        type: "phoneNumber",
        caption: captions.ticketHolderPhoneLabel,
        value: wfConfig.ticketHolderPhone,
      },
      {
        id: "ticketHolderLanguage",
        type: "radio",
        caption: captions.ticketHolderLanguageLabel,
        options: wfConfig.availableLanguages,
        value: wfConfig.ticketHolderLanguage,
        vertical: false,
      },
    ],
  });

  if (ticketHolder !== null)
    await workflow.respond("SetTicketHolder", ticketHolder);
}
