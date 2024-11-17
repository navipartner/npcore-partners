let main = async ({
    workflow,
    captions,
    parameters
}) => {

    let itemno = await popup.stringpad({
        title: captions.title,
        caption: captions.caption
    });

    if (itemno === null) {
        return (" ");
    }
    const {
        workflowName
    } = await workflow.respond("createitem");

    await workflow.run(workflowName, {
        parameters: {
            itemNo: itemno.toString(),
            itemQuantity: 1,
            itemIdentifierType: 0
        }
    });
}