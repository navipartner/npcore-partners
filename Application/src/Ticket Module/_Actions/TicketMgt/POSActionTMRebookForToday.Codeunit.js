const main = async ({ workflow, popup, captions }) => {
  const userInput = {};

  const ticketReference = await popup.input({
    caption: captions.TicketReferencePrompt,
    title: captions.WindowTitle,
  });

  if (!ticketReference) return;

  userInput.TicketReference = ticketReference;
  await workflow.respond("RebookForToday", userInput);
};
