let main = async ({ workflow, context}) => {
    debugger;
    let result = await workflow.respond("prepareWorkflow");
    const preWorkflows = result.preWorkflows;

    if (preWorkflows) {
        for (const preWorkflow of Object.entries(preWorkflows)) {
            let [preWorkflowName, preWorkflowParameters] = preWorkflow;
            if (preWorkflowName) {
                let {mainParameters, customParameters} = preWorkflowParameters;
                await workflow.run(preWorkflowName, {context: { customParameters: customParameters }, parameters: mainParameters});
            };
        };
    };

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