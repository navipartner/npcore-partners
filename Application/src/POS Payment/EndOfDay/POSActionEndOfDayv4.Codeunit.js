/*
    POSActionEndOfDayV4.Codeunit.js
*/
let main = async ({ workflow, popup, scope, parameters}) => {

    const _autoOpenTill = parameters['Auto-Open Cash Drawer'];

    await workflow.respond('ValidateRequirements');

    // Ask EFT integrations to close
    let _arrayOfWorkflows = await workflow.respond('DiscoverEftIntegrationsForEndOfDay');
    debugger;
    for (var i=0; i<_arrayOfWorkflows.length; i++)
        await workflow.run(_arrayOfWorkflows[i].WorkflowName, {context: _arrayOfWorkflows[i]});

    if (_autoOpenTill)
        await workflow.respond('OpenCashDrawer');

    await workflow.respond('DoEndOfDay');
}