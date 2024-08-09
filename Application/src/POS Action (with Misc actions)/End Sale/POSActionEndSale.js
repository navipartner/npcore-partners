const main = async ({ workflow }) => {
  let postWorkflows, preWorkflows;
  ({ preWorkflows, postWorkflows } = await workflow.respond(
    "endSaleWithPreWorkflows"
  ));
  if (preWorkflows) {
    await processWorkflows(preWorkflows);
    ({ postWorkflows } = await workflow.respond("endSaleWithoutPreWorkflows"));
  }
  await processWorkflows(postWorkflows);
};

async function processWorkflows(workflows) {
  if (!workflows) return;

  for (const [
    workflowName,
    { mainParameters, customParameters },
  ] of Object.entries(workflows)) {
    await workflow.run(workflowName, {
      context: { customParameters },
      parameters: mainParameters,
    });
  }
}
