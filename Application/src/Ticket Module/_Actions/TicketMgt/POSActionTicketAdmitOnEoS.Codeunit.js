const main = async ({ workflow, context, popup, captions }) => {
  let spinnerDialog = null;

  if (context.customParameters.showSpinner) {
    spinnerDialog = await popup.spinner({
      caption: "Checking and admitting tickets...",
      abortEnabled: false,
    });
  }

  try {
    const response = await workflow.respond("HandleTicketAdmitOnEoS");
    const { ticketsAdmitted = [], ticketsRejected = [] } = response;

    if (ticketsAdmitted.length > 0) {
      ticketsAdmitted.forEach((ticket) => {
        if (
          ticket &&
          typeof ticket === "object" &&
          ticket.externalTicketNo &&
          ticket.itemNo &&
          ticket.description
        ) {
          toast.success(`${ticket.externalTicketNo}`, {
            title: `${ticket.itemNo} - ${ticket.description}`,
          });
        } else {
          console.warn("Invalid ticket structure in ticketsAdmitted:", ticket);
          toast.success(`${captions.ToastBody.substitute("OK")}`, {
            title: captions.ToastTitle,
          });
        }
      });
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
