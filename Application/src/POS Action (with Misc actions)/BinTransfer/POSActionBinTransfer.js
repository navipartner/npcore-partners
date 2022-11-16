let main = async () => {
    let sourceBin = await workflow.respond("SelectBin");
    return await workflow.respond("Transfer", sourceBin);
};