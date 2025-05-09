const main = async ({ workflow, context, popup, parameters, captions }) => {
  let spinnerDialog = null;

  if (context.customParameters.showSpinner) {
    spinnerDialog = await popup.spinner({
      caption: "Checking and admitting tickets...",
      abortEnabled: false,
    });
  }

  try {
    const { tickets } = await workflow.respond("HandleTicketAdmitOnEoS");

    if (tickets.length > 0) {
      for (const ticketNo of tickets) {
        toast.success(`${captions.ToastBody.substitute(ticketNo)}`, {
          title: captions.ToastTitle,
        });
      }
    }
  } catch (generalErrorException) {
    toast.error(generalErrorException.message, { title: captions.ToastTitle });
  } finally {
    if (spinnerDialog) {
      spinnerDialog.close();
    }
  }
};
