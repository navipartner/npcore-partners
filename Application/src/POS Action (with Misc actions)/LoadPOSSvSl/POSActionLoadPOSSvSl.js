let main = async ({ parameters, captions, context }) => {

    context.SelectedSalesTicketNo = parameters.ScanSalesTicketNo;

    if (!context.SelectedSalesTicketNo) {
        switch ("" + parameters.QuoteInputType) {
            case "0":
                context.SelectedSalesTicketNo = await popup.numpad({ title: captions.SalesTicketNo, caption: captions.SalesTicketNo });
                if (!context.SelectedSalesTicketNo) { return };
                break;
            case "2":
                context.SelectedSalesTicketNo = await popup.input({ title: captions.SalesTicketNo, caption: captions.SalesTicketNo });
                if (!context.SelectedSalesTicketNo) { return };
                break;
        }
    }
    await workflow.respond();
};
