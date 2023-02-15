let main = async ({workflow, parameters}) => {
    debugger;   
    if (parameters.TransferDirection == parameters.TransferDirection["TransferIn"]) {
        return await workflow.respond("TransferIn");
    } else {
        let sourceBin = await workflow.respond("SelectBin");
        return await workflow.respond("TransferOut", sourceBin);
    }
};