const main = async ({ parameters }) => {
  const { success } = await workflow.respond("ChangePaymentMethod");
  if (!success) return;
  if (parameters.tryEndSale) {
    await workflow.run("END_SALE", {
      parameters: {
        calledFromWorkflow: "MM_CHANGE_PMT_METHOD",
        endSaleWithBalancing: false,
        startNewSale: true,
      },
    });
  }
};
