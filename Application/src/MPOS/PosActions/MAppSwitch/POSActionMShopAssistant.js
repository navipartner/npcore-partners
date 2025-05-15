let main = async ({ captions, workflow }) => {

    let Request =
    {
        RequestMethod: 'SHOPASSISTANT',
        BaseAddress: '',
        Endpoint: '',
        PrintJob: '',
        RequestType: '',
        ErrorCaption: captions.Err_ShopAssistantFailed,
    };

    await workflow.run("MPOS_API", {
        context: {
            InvokeType: "ACTION",
            FunctionName: "SHOPASSISTANT",
            FunctionArgument: Request
        }
    });


};