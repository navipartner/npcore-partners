let main = async ({ workflow, parameters, captions }) => {

  let currLine;

  switch (workflow.scope.view) {
    case "payment":
      currLine = runtime.getData("BUILTIN_PAYMENTLINE");
      break;
    default:
      currLine = runtime.getData("BUILTIN_SALELINE");
  }

  if (!currLine.length || currLine._invalid) {
    await popup.error(captions.notAllowed);
    return;
  }

  if (parameters.ConfirmDialog) {
    if (
      !(await popup.confirm({
        title: captions.title,
        caption: captions.Prompt.substitute(currLine._current[10]),
      }))
    ) {
      return;
    }
  }

  const { preWorkflows } = await workflow.respond("deleteOrGetPreWorkflows");
  if (!preWorkflows || Object.keys(preWorkflows).length === 0) return;
  await processWorkflows(workflow, preWorkflows);
  await workflow.respond("deleteLineAfterPreWorkflows");
};

async function processWorkflows(workflow, listOfWorkflows) {
  if (!listOfWorkflows) return;

  for (const [
    workflowName,
    { mainParameters, customParameters },
  ] of Object.entries(listOfWorkflows)) {
    await workflow.run(workflowName, {
      context: { customParameters },
      parameters: mainParameters,
    });
  }
}
