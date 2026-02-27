const main = async ({ workflow, context, popup, toast, captions }) => {
  const isSingleTokenFlow = 
    Boolean(context.EditSchedule && context.TicketToken) 
    || context.FunctionId === 5; // Edit Ticket Holder by menu choice is also single token but doesn't require schedule selection

  // collected as we go (from workflow responses)
  const state = {
    sameScheduleAssigned: false,
    ticketHolders: [],
    editTicketHolder: false,
  };
  debugger;
  
  if (isSingleTokenFlow) {
    const result = await handleSingleTokenFlow({ workflow, context, popup, toast, state });
    if (result?.cancel) return result;
  } else {
    const result = await handleMultiTokenFlow({ workflow, context, popup, toast, state });
    if (result?.cancel) return result;
  }

  // If we auto-assigned schedules and there are no ticket holders to capture, we're done.
  if (state.sameScheduleAssigned && state.ticketHolders.length === 0) {
    return { cancel: false };
  }

  const wfConfig = await getTicketHolderWorkflowConfig({ workflow, context, state });

  const shouldCapture =
    state.editTicketHolder ||
    wfConfig.CaptureTicketHolder ||
    state.ticketHolders.length > 0;

  if (!shouldCapture) return { cancel: false };

  const configForPopup = normalizeTicketHolderConfig(wfConfig, state.ticketHolders);
  await captureTicketHolderInfo({ workflow, popup, wfConfig: configForPopup, captions });

  return { cancel: false };
};

async function handleSingleTokenFlow({ workflow, context, popup, toast, state }) {
  const wfAssign = await workflow.respond("AssignSameSchedule", context);

  state.ticketHolders = wfAssign.TicketHolders || [];
  state.editTicketHolder = state.ticketHolders.length > 0 || context.EditTicketHolder;

  if (wfAssign.CancelScheduleSelection) {
    toast.error(wfAssign.Message);
    return { cancel: true };
  }

  // nothing more to do (neither schedule nor ticket holder edit requested)
  if (!wfAssign.EditSchedule && !state.editTicketHolder) {
    return { cancel: false };
  }

  // Prompt schedule selection if we are in the “single token edit schedule” scenario
  if (context.EditSchedule && context.TicketToken && !context.TicketTokens) {
    const popupResult = await popup.entertainment.scheduleSelection({ token: context.TicketToken });
    if (popupResult === null) return { cancel: true };
  }

  return null;
}

async function handleMultiTokenFlow({ workflow, context, popup, toast, state }) {
  let tokensNeedingSchedule = [...(context.tokensRequiringScheduleSelection || [])];
  const tokensNeedingHolder = [...(context.tokensRequiringTicketHolder || [])];

  if (tokensNeedingSchedule.length === 1 && tokensNeedingHolder.length > 0) {
    context.TicketTokens = tokensNeedingSchedule;
    state.editTicketHolder = true;
  } else if (tokensNeedingHolder.length > 0) {
    context.TicketTokens = tokensNeedingHolder;
    state.editTicketHolder = true;
  }

  while (tokensNeedingSchedule.length > 0) {
    const token = tokensNeedingSchedule[0];

    const popupResult = await popup.entertainment.scheduleSelection({ token });
    if (popupResult === null) return { cancel: true };

    // if this was the last one, stop 
    if (tokensNeedingSchedule.length === 1) break;

    // Prepare context for workflow
    context.ConfiguredToken = token;
    tokensNeedingSchedule.shift();
    context.setSchedulesForTokens = tokensNeedingSchedule;

    const assign = await workflow.respond("AssignSameScheduleToSet", context);

    if (assign.CancelScheduleSelection) {
      toast.error(assign.Message);
      return { cancel: true };
    }

    state.sameScheduleAssigned = true;

    state.ticketHolders.push(...(assign.TicketHolders || []));
    state.editTicketHolder = state.ticketHolders.length > 0;

    const assigned = assign.AssignedTokens || [];
    if (assigned.length > 0) {
      tokensNeedingSchedule = tokensNeedingSchedule.filter(t => !assigned.includes(t));
    }
  }

  return null;
}

async function getTicketHolderWorkflowConfig({ workflow, context, state }) {
  // Your original logic: only call ConfigureWorkflow when there are no ticketHolders accumulated
  if (!state.editTicketHolder) return {};
  return (await workflow.respond("ConfigureWorkflow", context)) || {};
}

function normalizeTicketHolderConfig(wfConfig, ticketHolders) {
  const cfg = (wfConfig && Object.keys(wfConfig).length > 0) ? { ...wfConfig } : {};

  // defaults
  cfg.ticketHolderName = cfg.ticketHolderName ?? "";
  cfg.ticketHolderEmail = cfg.ticketHolderEmail ?? "";
  cfg.ticketHolderPhone = cfg.ticketHolderPhone ?? "";
  cfg.ticketHolderLanguage = cfg.ticketHolderLanguage ?? "";
  cfg.availableLanguages = cfg.availableLanguages ?? [];

  // prefill from first ticket holder if we have one
  if (ticketHolders.length > 0) {
    const first = ticketHolders[0] || {};
    cfg.ticketHolderName = first.ticketHolderName || cfg.ticketHolderName;
    cfg.ticketHolderEmail = first.ticketHolderEmail || cfg.ticketHolderEmail;
    cfg.ticketHolderPhone = first.ticketHolderPhone || cfg.ticketHolderPhone;
    cfg.ticketHolderLanguage = first.ticketHolderLanguage || cfg.ticketHolderLanguage;
    cfg.availableLanguages = first.availableLanguages || cfg.availableLanguages;
  }

  return cfg;
}

async function captureTicketHolderInfo({ workflow, popup, wfConfig, captions }) {
  const ticketHolder = await popup.configuration({
    title: captions.ticketHolderTitle,
    caption: captions.ticketHolderCaption,
    settings: [
      { id: "ticketHolderName", type: "text", caption: captions.ticketHolderNameLabel, value: wfConfig.ticketHolderName },
      { id: "ticketHolderEmail", type: "text", caption: captions.ticketHolderEmailLabel, value: wfConfig.ticketHolderEmail },
      { id: "ticketHolderPhone", type: "phoneNumber", caption: captions.ticketHolderPhoneLabel, value: wfConfig.ticketHolderPhone },
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

  if (ticketHolder !== null) {
    await workflow.respond("SetTicketHolder", ticketHolder);
  }
}