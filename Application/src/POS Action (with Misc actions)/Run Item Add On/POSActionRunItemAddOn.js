const main = async ({ workflow, popup, context, captions }) => {
  const { AskForApplyToLine, ApplyToDialogOptions } =
    await workflow.respond("DefineBaseLineNo");

  if (AskForApplyToLine) {
    const result = await popup.optionsMenu({
      title: captions.SelectLine,
      oneTouch: true,
      options: ApplyToDialogOptions,
    });
    if (!result) {
      return;
    }
    context.BaseLineNo = result.id;
  }

  const {
    ApplyItemAddOnNo,
    CompulsoryAddOn,
    UserSelectionRequired,
    ItemAddonConfigAsString,
  } = await workflow.respond("GetSalesLineAddonConfigJson");

  let ItemAddonsResult = {};
  if (UserSelectionRequired) {
    const AddonConfig = JSON.parse(ItemAddonConfigAsString);
    const UserSelectedAddons = await popup.configuration(AddonConfig);
    ItemAddonsResult = await workflow.respond("SetItemAddons", {
      ApplyItemAddOnNo: ApplyItemAddOnNo,
      CompulsoryAddOn: CompulsoryAddOn,
      UserSelectionRequired: UserSelectionRequired,
      UserSelectedAddons: UserSelectedAddons,
    });
  } else {
    ItemAddonsResult = await workflow.respond("SetItemAddons", {
      ApplyItemAddOnNo: ApplyItemAddOnNo,
      CompulsoryAddOn: CompulsoryAddOn,
      UserSelectionRequired: UserSelectionRequired,
    });
  }

  if (
    ItemAddonsResult.TicketTokens &&
    ItemAddonsResult.TicketTokens.length > 0
  ) {
    for (const token of ItemAddonsResult.TicketTokens) {
      await workflow.run("TM_SCHEDULE_SELECT", {
        context: {
          TicketToken: token,
          EditSchedule: true,
        },
      });
    }
  }
};
