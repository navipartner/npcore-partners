let main = async ({workflow, parameters, context, popup}) => 
{
    let device = null;
    let IsWorkflowCall = context.IsFromWorkflow === true;
    var userAgent = navigator.userAgent || navigator.vendor || window.opera;
    try
    {
        if (/android/i.test(userAgent)) 
            device = "ANDROID";
        else if (/iPad|iPhone|iPod|Macintosh/i.test(userAgent) && !window.MSStream) 
            device = "IOS";
        else
        {
            throw new Error("This action does not work on non-MPOS Devices");
        }
        let FunctionOptions = ['Mock'];
        let MposFunctionResult = null;
        let functionName = IsWorkflowCall 
            ? context.FunctionName
            : FunctionOptions[Number(parameters.Functionality)];
        let functionParam = IsWorkflowCall 
            ? context.FunctionParameter
            : parameters.Parameters;
        let MposFunctionRequest = 
        {
            FunctionName: functionName,
            FunctionParameter: functionParam
        };
        MposFunctionRequest = JSON.stringify(MposFunctionRequest);
        MposFunctionResult = await SendToApp(device, MposFunctionRequest);
        if (IsWorkflowCall)
            return MposFunctionResult;
        else
            workflow.respond(functionName, {mposResponse: MposFunctionResult});
    } catch (e)
    {
        if (IsWorkflowCall)
        {
            return {IsSuccessful: false, ErrorMessage: e.message, Result: null};
        }
        else
        {
            popup.error(e.message, "mPOS Error");
        }
    }
};

async function SendToApp(device, arg)
{
    let errMsg = "<div style=\"text-align: left;\"><p>This device does not support this feature.<br/>Known reasons:<br/>-If you are running iOS version < 14.0.<br/>-The app is not updated.</p></div>";
    if(device === "ANDROID")
    {
        if (window.top.jsBridge && window.top.jsBridge.invokeFunction)
            return JSON.parse(await window.top.jsBridge.invokeFunction(arg));
        else
            throw Error(errMsg);
    }
    else if (device === "IOS")
    {
        if (window.top.webkit && 
            window.top.webkit.messageHandlers && 
            window.top.webkit.messageHandlers.invokeFunction && 
            window.top.webkit.messageHandlers.invokeFunction.postMessage)
            return JSON.parse(await window.top.webkit.messageHandlers.invokeFunction.postMessage(arg));
        else
            throw Error(errMsg);
    }
        
}
function Debug(device, arg)
{
    try{
        if(device === "ANDROID")
            window.top.jsBridge.debug(arg);
        else if (device === "IOS")
            window.webkit.messageHandlers.debug.postMessage(arg);
    } catch {}
    
}