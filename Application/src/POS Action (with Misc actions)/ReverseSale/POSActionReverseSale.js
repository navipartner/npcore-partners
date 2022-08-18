let main = async ({workflow}) => {
    
    const{parameters} = await workflow.respond("import_sales_doc");
    
    await workflow.run("IMPORT_POSTED_INV", {parameters: parameters});

    await workflow.respond("export_SalesDoc");
};