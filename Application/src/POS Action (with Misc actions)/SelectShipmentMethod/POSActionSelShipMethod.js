const main = async ({ workflow }) => {
  const processSelectionResult = await workflow.respond("selectShipmentMethod");
  return { success: processSelectionResult.success };
};
