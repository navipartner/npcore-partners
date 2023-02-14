let main = async (obj) => {                  
    try{
        const {popup, captions, parameters} = obj;
        switch(parameters.CustomerDisplayOp.toString())
        {
            case "OPEN":
                OpenCloseDisplay(true);
                break;
            case "CLOSE":
                OpenCloseDisplay(false);
                break
            case "GET_INPUT":
                await CollectInput(obj);
                break;
            default:
                popup.error(captions.ErrUnknownOperation + ": '" + parameters.CustomerDisplayOp.toString() +"'");
                break;
        }
    } 
    catch(e)
    {
        popup.error(e);
    }
}

async function CollectInput(obj)
{
    const {hwc, workflow, popup, captions} = obj;
    objParam = {
            
        JSAction: "GetInput",
        InputType: "Phone & Signature"
        
    }
    let selectResult = await workflow.respond('POSEntryNo');
        switch(selectResult)
        {
            case "GET_INPUT":
                break;
            case "NOT_SELECTED":
                popup.error(captions.ErrPOSEntryNotSelected);
                return;
            case "INPUT_EXISTS":
                popup.error(captions.ErrPOSEntryInputExists);
                return;
            default:
                popup.error(captions.ErrPOSEntryUndefined);
                return;
        }
        let exitLoop = false;
        while(!exitLoop)
        {
            let result = await hwc.invoke("HTMLDisplay", {
                DisplayAction: "SendJS",
                JSParameter: JSON.stringify(objParam)
            });
            exitLoop = await workflow.respond('InputCollected', result.JSON.Input);
        }
}
async function OpenCloseDisplay(open)
{
    await hwc.invoke("HTMLDisplay", {
        DisplayAction: (open ? "Open" : "Close")
    });
}