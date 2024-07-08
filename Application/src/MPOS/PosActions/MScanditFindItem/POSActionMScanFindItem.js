let main = async ({captions, workflow, popup}) => {
    
    let bc = await workflow.respond("GetScanditRequest");
    if (bc.foundbarcode)
    {
        let Request =
        {
            RequestMethod: 'SCANDITFINDITEM',
            BaseAddress:  '',
            Endpoint:  '',
            PrintJob:  bc.barcode,
            RequestType:  '',
            ErrorCaption:  captions.Err_ScanditFailed,
        };
        
        await workflow.run("MPOS_API", {
            context: {
                InvokeType: "ACTION",
                FunctionName: "SCANDITFINDITEM",
                FunctionArgument: Request
            }
        });
    }
    else
    {
        popup.error(captions.LblNoBarcodeFound);
    }
};