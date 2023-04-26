let main = async ({ workflow}) => {
    debugger;
    let result = await workflow.respond("prepareWorkflow");
    if (result.workflowName == "") {
        return;
    }
    if (result.workflowName == 'START_POS') {
        await workflow.run(result.workflowName);
    }
    else
    {
        await workflow.run(result.workflowName, { parameters: result.parameters })
    }
};