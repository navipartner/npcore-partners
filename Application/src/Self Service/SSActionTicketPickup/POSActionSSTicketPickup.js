let main = async ({ parameters }) => {
    await workflow.respond("printTickets", parameters.scannedValue);
};