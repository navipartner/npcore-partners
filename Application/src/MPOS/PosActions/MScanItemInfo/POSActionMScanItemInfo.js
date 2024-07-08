let main = async ({captions, workflow}) => {
    
    let Request =
    {
        RequestMethod: 'SCANDITITEMINFO',
        BaseAddress:  '',
        Endpoint:  '',
        PrintJob:  '',
        RequestType:  '',
        ErrorCaption:  captions.Err_ScanditFailed,
    };
    
    await workflow.run("MPOS_API", {
        context: {
            InvokeType: "ACTION",
            FunctionName: "SCANDITITEMINFO",
            FunctionArgument: Request
        }
    });
    

};