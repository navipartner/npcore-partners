const main = async ({ workflow, captions }) => {
  try {
    const response = await workflow.respond("HandleMemberAdmitOnEoS");
    const { cardsAdmitted = [], cardsRejected = [] } = response;

    if (cardsAdmitted.length > 0) {
      cardsAdmitted.forEach((member) => {
        if (member && typeof member === "object" && member.cardNo) {
          toast.success(`${member.cardNo}`, {
            title: `${member.firstName || ""} ${member.lastName || ""}`,
          });
        } else {
          console.warn("Missing information in membersAdmitted json:", member);
          toast.success(`${captions.ToastBody.substitute("OK")}`, {
            title: captions.ToastTitle,
          });
        }
      });
    }

    if (cardsRejected.length > 0) {
      for (const rejectMessage of cardsRejected) {
        toast.error(
          `${rejectMessage.reasonCode || "0"} - ${
            rejectMessage.reasonText || "There was no error reason specified."
          } `,
          {
            title: captions.ToastTitle,
          }
        );
      }
    }
  } catch (generalErrorException) {
    toast.error(generalErrorException.message, { title: captions.ToastTitle });
  }
};
