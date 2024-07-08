let main = async ({}) => {
    const success = await workflow.respond("TryEndSale");
    return ({"endSaleExecuted": true, "endSaleSuccess": success});
};

