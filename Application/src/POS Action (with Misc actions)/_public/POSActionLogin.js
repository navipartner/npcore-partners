let main = async ({ workflow, context }) => {
    debugger;
    let result = await workflow.respond("prepareWorkflow");
    const preWorkflows = result.preWorkflows;

    if (result.workflowName == "") {
        await processPreWorkflows(preWorkflows);
        return;
    }

    if (result.workflowName == 'START_POS') {
        const { posStarted } = await workflow.run(result.workflowName);
        if (posStarted) {
            await processPreWorkflows(preWorkflows);
        };
    }
    else {
        await workflow.run(result.workflowName, { parameters: result.parameters })
    }
};

async function processPreWorkflows(preWorkflows) {
    if (preWorkflows) {
        for (const preWorkflow of Object.entries(preWorkflows)) {
            let [preWorkflowName, preWorkflowParameters] = preWorkflow;
            if (preWorkflowName) {
                let { mainParameters, customParameters } = preWorkflowParameters;
                await workflow.run(preWorkflowName, { context: { customParameters: customParameters }, parameters: mainParameters });
            };
        };
    };
}
