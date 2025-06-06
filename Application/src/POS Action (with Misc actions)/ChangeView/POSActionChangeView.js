let main = async ({ }) => {
    
   await workflow.respond("ChangeView");

   let { postWorkflows} = await workflow.respond("AddPostWorkflowsToRun");
   await processWorkflows(postWorkflows);
};

async function processWorkflows(workflows) {
  if (!workflows) return;

  for (const [workflowName,{ mainParameters, customParameters },] of Object.entries(workflows)) {
    await workflow.run(workflowName, {context: { customParameters },parameters: mainParameters,});
  }
}