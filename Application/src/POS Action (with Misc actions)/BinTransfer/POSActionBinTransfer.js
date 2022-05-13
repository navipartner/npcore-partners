let main = async ({parametars,context}) => {
    SourceBin = await workflow.respond("SelectBin");
    return await workflow.respond("Transfer",SourceBin);
};