const main = async ({ workflow, popup, captions, parameters }) => {
  const configuration = await workflow.respond("GetConfiguration");

  if (!configuration || !configuration.success) {
    await popup.error(configuration.errorMessage);
    return;
  }

  if (!configuration.guests || configuration.guests.length <= 0) {
    await popup.message(captions.noGuestsToAdd);
    return;
  }

  const settings = [];

  configuration.guests.forEach((guest) => {
    const config = {
      type: "plusminus",
      id: guest.token,
      minValue: 0,
      value: 0,
      caption: guest.description,
    };

    /**
     * -1 means that there is an unlimited amount of possible guests,
     * only add a max value if there is a limitation.
     */
    if (guest.maxNumberOfGuests > -1) {
      config.maxValue = guest.maxNumberOfGuests;

      if (
        Boolean(parameters.restrictToday) === true &&
        guest.guestsAdmittedToday > 0
      ) {
        config.maxValue = guest.maxNumberOfGuests - guest.guestsAdmittedToday;
        config.caption = `${config.caption} (${String(guest.guestsAdmittedToday)} ${captions.alreadyRegistered})`;

        /**
         * In the event that the member has already used all their guests, set this to -1.
         * This will force the frontend to not allow me to select anything.
         */
        if (config.maxValue === 0) {
          config.maxValue = -1;
        }
      }
    }

    settings.push(config);
  });

  const selection = await popup.configuration({
    title: captions.registerGuests,
    settings,
  });

  console.log(selection);

  if (!selection) {
    return;
  }

  const admitTokens = [];

  Object.keys(selection).forEach((key) => {
    admitTokens.push({
      token: key,
      quantity: Number(selection[key]),
    });
  });

  await workflow.respond("AdmitTokens", { admitTokens });
};
