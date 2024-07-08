let main = async ({workflow, popup, scope, parameters, context, runtime, data }) => {
    debugger
    const { preWorkflows, postWorkflows } = await workflow.respond('endSaleWithPreWorkflows');
    if (preWorkflows) {
        await processWorkflows(preWorkflows);
        const { postWorkflows } = await workflow.respond('endSaleWithoutPreWorkflows');
        await processWorkflows(postWorkflows);
    } else {
        await processWorkflows(postWorkflows);
    }
};

async function processWorkflows(workflows) {
    if (workflows) {
        for (const workflowEntry of Object.entries(workflows)) {
            let [workflowName, workflowParameters] = workflowEntry;
            if (workflowName) {
                let { mainParameters, customParameters } = workflowParameters;
                await workflow.run(workflowName, { context: { customParameters: customParameters }, parameters: mainParameters });
            };
        };
    };
}