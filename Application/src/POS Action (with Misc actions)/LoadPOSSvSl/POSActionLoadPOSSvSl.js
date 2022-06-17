let main = async ({parameters,captions}) => {

    let ScanSalesTicketNo = parameters.ScanSalesTicketNo;

    switch("" + parameters.QuoteInputType){
        case "0":
            ScanSalesTicketNo = await popup.numpad({title: captions.SalesTicketNo, caption: captions.SalesTicketNo});
            break;
        case "2":
            ScanSalesTicketNo = await popup.input({title: captions.SalesTicketNo, caption: captions.SalesTicketNo});
            break;
        default:
            ScanSalesTicketNo = await workflow.respond("select_quote");        
    }
    if (Object.keys(ScanSalesTicketNo).length !== 0)
    {
        if (parameters.PreviewBeforeLoad){
            await workflow.respond("preview",ScanSalesTicketNo)
        }    
        await workflow.respond("load_from_quote",ScanSalesTicketNo)

    }

};
