let main = async ({workflow,captions,parameters}) => 
{
    if (parameters.barcode) {

        barcode = parameters.barcode
        
    }   else {
        
        barcode =  await popup.input({caption: captions.Barcode});
        
        if (barcode === null) {
            return(" ");
        }
    }    

    const{workflowName, itemno, itemQuantity, itemIdentifierType} = await workflow.respond("InsertItemQty",{BarCode : barcode});

    await workflow.run(workflowName, {parameters:{itemNo: itemno, itemQuantity: itemQuantity, itemIdentifierType: itemIdentifierType}});
};