let main = async ({context, captions, popup}) => 
{
    let InvokeType = context.InvokeType ?? null;
    let FunctionName = context.FunctionName ?? null;
    let FunctionArgument = context.FunctionArgument ?? null;
    try
    {
        debugger;
        //Check if it is a valid Device.
        var userAgent = navigator.userAgent || navigator.vendor || window.opera;
        let device = null;
        if (/android/i.test(userAgent)) 
            device = "ANDROID";
        else if (/iPad|iPhone|iPod|Macintosh/i.test(userAgent) && !window.MSStream) 
            device = "IOS";
        if (!device)
            throw new Error(captions.LblNotMposDevice);
        
        switch(InvokeType)
        {
            case "FUNCTION":
                let FunctionRequest = {
                    FunctionName: FunctionName,
                    FunctionParameter: FunctionArgument
                };
                switch(device)
                {
                    case "ANDROID":
                        if(!window.top.jsBridge || !window.top.jsBridge.invokeFunction)
                            throw new Error();
                        return JSON.parse(await window.top.jsBridge.invokeFunction(JSON.stringify(FunctionRequest)));
                    case "IOS":
                        if (!window.top.webkit || !window.top.webkit.messageHandlers || !window.top.webkit.messageHandlers.invokeFunction)
                            throw new Error();
                        return JSON.parse(await window.top.webkit.messageHandlers.invokeFunction.postMessage(FunctionRequest));
                }
                break;
            case "ACTION":
                let ActionRequest = {
                    RequestMethod: FunctionName
                };
                ActionRequest = Object.assign(ActionRequest, FunctionArgument);
                switch(device)
                {
                    case "ANDROID":
                        if(!window.top.jsBridge || !window.top.jsBridge.invokeAction)
                            throw new Error();
                        //Receives JSon String on Android
                        if (window.top.jsBridge)
                            await window.top.jsBridge.invokeAction(JSON.stringify(ActionRequest));
                        else
                        {
                            try
                            {
                                await window.top.mpos.invokeAction(JSON.stringify(ActionRequest));
                            }
                            catch(e)
                            {
                                //If old version?
                                await window.top.mpos.handleBackendMessage(jsonObject);
                            } 
                        }
                        break;
                    case "IOS":
                        if (!window.top.webkit || !window.top.webkit.messageHandlers || !window.top.webkit.messageHandlers.invokeAction)
                            throw new Error();
                        //Receives Json Object and converts to string in App.
                        await window.top.webkit.messageHandlers.invokeAction.postMessage(ActionRequest);
                        break;
                }
                break;
            default:
                popup.error("The MPOS Api has been called with invalid InvokeOptions. This is a programming error, please contact your vendor.", "Programming Error");
                break;
        }
    } 
    catch (e)
    {
        if (InvokeType === "FUNCTION")
        {
            return {IsSuccessful: false, ErrorMessage: e.message, Result: null};
        }
        else
        {
            popup.error(e.message, "mPOS Error");
        }
    }
};