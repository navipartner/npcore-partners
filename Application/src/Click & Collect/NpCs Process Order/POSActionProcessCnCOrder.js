let main = async ({}) => {
    return await workflow.respond('run_collect_in_store_orders');
};

let isWorkflowDisabled = async ({workflow, context, popup, runtime, hwc, data, parameters, captions, scope}) => {
    return workflow.respond('is_workflow_disabled');
}