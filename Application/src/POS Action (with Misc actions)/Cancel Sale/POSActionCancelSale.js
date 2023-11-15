let main = async ({workflow,captions,popup}) => {

    if (await popup.confirm({title: captions.title, caption: captions.prompt})) {
    
        await workflow.respond("CheckSaleBeforeCancel");
        await workflow.respond("CancelSale");
    }
    else
        return(" ");      
    };