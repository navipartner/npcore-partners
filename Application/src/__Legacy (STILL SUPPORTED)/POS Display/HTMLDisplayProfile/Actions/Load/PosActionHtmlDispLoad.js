let main = async ({context, popup, captions, parameters}) => {                  
    context.HtmlDisplayVersion = Number.parseInt(captions.HtmlDisplayVersion);
    if (!context.IsNestedWorkflow)
    {
        context.LoadAction = String(parameters.LoadAction);
        context.DownloadMedia = parameters.DownloadMedia;
        context.WebsiteUrl = parameters.WebsiteUrl;
        context.UseVirtualKeyboardPlugin = parameters.UseVirtualKeyboardPlugin;
        context.IsNestedWorkflow = false;
    }
    let request = {
        Version: context.HtmlDisplayVersion
    };
    let response = null;
    try
    {
        if (context.LoadAction === "Profile")
        {
            request.DisplayAction = "LoadWebsite";
            request.Website = "";
            if (parameters.DownloadMedia)
                request.LocalMediaInfo = await workflow.respond("LocalMediaInfo", response);
        }
        else if (context.LoadAction === "Website")
        {
            request.DisplayAction = "LoadWebsite";
            request.Website = context.WebsiteUrl;
            request.Plugins = [
                (context.UseVirtualKeyboardPlugin ? "VirtualKeyboard" : "")
            ];
            request.Plugins.filter((a) => {a !== null && a !== ""})
        }
        response = await hwc.invoke("HTMLDisplay", request);
        let bc = await workflow.respond("ShouldUpdateReceipt", response);
        if (bc.Request)
            await hwc.invoke("HTMLDisplay", bc.Request);
    } 
    catch(e)
    {
        popup.error(e);
    }
    return response;
}