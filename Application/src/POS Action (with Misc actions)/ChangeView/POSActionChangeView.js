const main = async ({ workflow }) => {
  const { postWorkflows } = await workflow.respond("ChangeView");
  await processWorkflows(workflow, postWorkflows);
};

async function processWorkflows(workflow, workflows) {
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
