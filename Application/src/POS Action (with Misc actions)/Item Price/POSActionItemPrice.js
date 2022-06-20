let main = async ({workflow,captions,parameters}) => {

    let itemno =  await popup.input({title: captions.title, caption: captions.caption});
    
    if (itemno === null) {
        return(" ");
    }
    const{workflowName} = await workflow.respond("createitem");
    
    await workflow.run(workflowName, {parameters:{itemNo: itemno, itemQuantity: 1, itemIdentifierType: parameters.itemIdentifierType}});  

    const {confirm_message} = await workflow.respond("gatherinfo");

    popup.message({title: captions.confirm_title, caption: confirm_message});

};