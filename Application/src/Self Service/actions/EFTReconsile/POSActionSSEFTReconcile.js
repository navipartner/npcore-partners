let main = async ({ workflow }) => {
    let _arrayOfWorkflows = await workflow.respond('GetEftIntegrationsForOnEndOfDay');
    debugger;
    for (var i=0; i<_arrayOfWorkflows.length; i++)
        await workflow.run(_arrayOfWorkflows[i].WorkflowName, {context: _arrayOfWorkflows[i]});
}