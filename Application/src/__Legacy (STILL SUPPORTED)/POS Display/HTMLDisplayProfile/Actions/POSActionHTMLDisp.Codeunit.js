let main = async (obj) => {                  
    const {context, popup, captions, parameters} = obj;
    try{
        context.HtmlDisplayVersion = Number.parseInt(captions.HtmlDisplayVersion);
        let hwcRequest = null;
        switch(String(parameters.CustomerDisplayOp))
        {
            case "OPEN":
                hwcRequest = {
                    Version: context.HtmlDisplayVersion,
                    DisplayAction: "Open",
                    WindowScreenNo: parameters.ScreenNo
                };
                if (parameters.DownloadMedia)
                {
                    let bc = await workflow.respond('LocalMediaObject');
                    hwcRequest.LocalMediaInfo = bc.LocalMediaObject;
                }
                break;
            case "UPDATE":
                let bc = await workflow.respond('UpdateRequest');
                hwcRequest = bc.Request;
                break;
            case "CLOSE":
                hwcRequest = {
                    Version: context.HtmlDisplayVersion,
                    DisplayAction: "Close"
                };
                break;
        }
        await hwc.invoke("HTMLDisplay", hwcRequest);
    } 
    catch(e)
    {
        popup.error(e);
    }
}