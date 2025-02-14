let main = async ({ workflow }) => {
  const { entryNo, showSpinner, showSuccessMessage, workflowName, integrationRequest } = await workflow.respond("prepareAcquireCard");

  await workflow.run(workflowName, { context: { request: integrationRequest, showSpinner, showSuccessMessage }});

  /**
   * Structure of the response:
   *
   * {
   *    "maskedPan": "..."
   *    "parToken": "..."
   * }
   *
   */
  const details = await workflow.respond("getCardDetails", { context: { entryNo }});
  debugger;
  return details;
};
