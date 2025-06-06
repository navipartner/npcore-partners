let main = async ({ workflow, parameters, captions }) => {
    debugger;
    switch (workflow.scope.view) {
        case "payment":
            var currLine = runtime.getData("BUILTIN_PAYMENTLINE");
            break;
        default:
            var currLine = runtime.getData("BUILTIN_SALELINE");
    }

    if ((!currLine.length) || (currLine._invalid)) {
        await popup.error(captions.notallowed);
        return;
    };

    if (parameters.ConfirmDialog) {
        if (!await popup.confirm({ title: captions.title, caption: captions.Prompt.substitute(currLine._current[10]) })) {
            return;
        };
    };
    
    let {preWorkflows} = await workflow.respond("preparePreWorkflows");

    await processWorkflows(preWorkflows);
    await workflow.respond("deleteLine");
};

async function processWorkflows(workflows) {
  if (!workflows) return;

  for (const [workflowName, { mainParameters, customParameters },] of Object.entries(workflows)) {
    await workflow.run(workflowName, {context: { customParameters },parameters: mainParameters,});
  }
}