let main = async ({ workflow, context, parameters }) => {
    const { workflowName, workflowVersion, itemno, itemQuantity, itemIdentifierType } = await workflow.respond("do_lookup");

    if (workflowVersion > 1) await workflow.run(workflowName, { parameters: { itemNo: itemno, itemQuantity: itemQuantity, itemIdentifierType: itemIdentifierType } });
    if (workflowVersion == 1) await workflow.respond("doLegacyWorkflow", { selected_itemno: itemno });  
};