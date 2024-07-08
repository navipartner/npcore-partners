let main = async ({ workflow }) => {
    return await workflow.respond('run_collect_in_store_orders');
};

let isWorkflowDisabled = async ({ workflow }) => {
    return await workflow.respond('is_workflow_disabled');
}