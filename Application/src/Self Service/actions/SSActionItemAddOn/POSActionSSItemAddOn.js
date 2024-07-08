let main = async ({ workflow, context, popup}) => {
  let addonJson = await workflow.respond("GetSalesLineAddonConfigJson");
  let addonConfig = JSON.parse(addonJson);
  context.userSelectedAddons = await popup.configuration (addonConfig);
  if (context.userSelectedAddons) {await workflow.respond ("SetItemAddons")};
  };