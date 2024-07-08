let main = async (obj) => {                  
    const {context, workflow, popup} = obj;
    if (window.parent.jsBridge == null || navigator.userAgent.indexOf("Android") == -1)
    {
        await popup.error("You can only use Softpay on Android devices.", "Device error");
        return {"success": false};
    }
    if (window.parent.jsBridge.SoftpayProtocol == null || window.parent.jsBridge.SoftpayProtocol === undefined)
    {
        await popup.error("Softpay integration not found. Either you are using an outdated version of the Mobile App or the device is not supported.", "Device error");
        return {"success": false};
    }
    let request = 
    {
        SoftpayAction: context.request.SoftpayAction,
        Step: null,
        RequestID: null,
        Amount: context.request.Amount,
        Currency: context.request.Currency,
        IntegratorID: context.request.IntegratorID,
        IntegratorCredentials: context.request.IntegratorCredentials.split(""),
        SoftpayUsername: context.request.SoftpayUsername,
        SoftpayPassword: context.request.SoftpayPassword.split("")
        
    };
    let bc = null;
    try
    {
        switch(request.SoftpayAction)
        {
            case "Refund":
            case "Payment":
                var resultWithReqId = await SendMPOSAsync(request);
                bc = await workflow.respond("IDRecieved", {SoftpayResponse: resultWithReqId, SoftpayRequest: request});
                if (bc.success)
                {
                    request.RequestID = resultWithReqId.RequestID;
                    let paymentResponse = await SendMPOSAsync(request);
                    bc = await workflow.respond("TransactionFinished", {SoftpayResponse: paymentResponse, SoftpayRequest: request});
                }
                break;
            case "GetTransaction":
            //case "Cancellation":
                request.RequestID = context.request.RequestID;
                var GetTransactionReq = await SendMPOSAsync(request);
                bc = await workflow.respond("TransactionFinished", {SoftpayResponse: GetTransactionReq, SoftpayRequest: request});
                break;
            default:
                bc = await workflow.respond('Failed', {
                    ErrorMessage: "Command: " + request.SoftpayAction + " Is not supported", 
                    SoftpayRequest: request,
                    SoftpayResponse: null
                });
        }
        
    } catch (e)
    {
        bc = await workflow.respond('Failed', {
            ErrorMessage: e.message, 
            SoftpayRequest: request,
            SoftpayResponse: null
        });
    }
    if (!bc.success)
        await popup.error(bc.errorcaption, bc.errortitle);
    return {"success": bc.succes, "tryEndSale": bc.endSale};
}
let step = 1;
/**
 * Sets the protocol action for the request and sends to mpos and returns JSON parsed obj.
 * @param {SoftpayRequest} request According to specification mentioned in the softpay.md 
 * @returns {SoftpayResponse} According to specification mentioned in the softpay.md
 */
async function SendMPOSAsync(request)
{
    let mpos = window.parent.jsBridge;
    request.Step = step++;
    return JSON.parse(await mpos.SoftpayProtocol(JSON.stringify(request))); 
}