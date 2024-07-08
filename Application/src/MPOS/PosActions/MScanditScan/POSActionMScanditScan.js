let main = async ({context, captions, workflow}) => {
    
    //For returning the result rather than posting it in EAN box.
    if (context.ReturnScanResult)
    {
        let result = await workflow.run("MPOS_API", {
            context: {
                InvokeType: "FUNCTION",
                FunctionName: "SCANDITSCAN",
                FunctionArgument: {}
            }
        });
        return result;
    }
    //Posting in EAN Box from POS.
    else
    {   
        let MposRequest =
        {
            RequestMethod: 'SCANDITSCAN',
            BaseAddress:  '',
            Endpoint:  '',
            PrintJob:  '',
            RequestType:  '',
            ErrorCaption:  captions.Err_ScanditFailed,
        };
        
        await workflow.run("MPOS_API", {
            context: {
                InvokeType: "ACTION",
                FunctionName: "SCANDITSCAN",
                FunctionArgument: MposRequest
            }
        });
    }
};