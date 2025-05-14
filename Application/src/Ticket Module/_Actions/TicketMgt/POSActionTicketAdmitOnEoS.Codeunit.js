const main = async ({ workflow, context, popup, captions }) => {
  let spinnerDialog = null;

  if (context.customParameters.showSpinner) {
    spinnerDialog = await popup.spinner({
      caption: "Checking and admitting tickets...",
      abortEnabled: false,
    });
  }

  try {
    const { ticketsAdmitted, ticketsRejected } = await workflow.respond(
      "HandleTicketAdmitOnEoS"
    );

    if (ticketsAdmitted.length > 0) {
      for (const ticketNo of ticketsAdmitted) {
        toast.success(`${captions.ToastBody.substitute(ticketNo)}`, {
          title: captions.ToastTitle,
        });
      }
    }

    if (ticketsRejected.length > 0) {
      for (const rejectMessage of ticketsRejected) {
        toast.error(`${rejectMessage}`, {
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
