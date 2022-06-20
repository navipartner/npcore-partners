let main = async ({workflow,context,parameters}) => {
    const {itemno} = await workflow.respond("do_lookup");
    const{workflowName,workflowVersion} = await workflow.respond("prepareWorkflow");

    if (workflowVersion == 1) await workflow.respond("doLegacyWorkflow",{selected_itemno:itemno});

    if (workflowVersion >=2) { 
        const {itemQuantity,itemIdentifierType} = await workflow.respond("complete_lookup",{selected_itemno:itemno});
        await workflow.run(workflowName, {parameters:{itemNo: itemno, itemQuantity: itemQuantity, itemIdentifierType: itemIdentifierType}});  
    }     
};