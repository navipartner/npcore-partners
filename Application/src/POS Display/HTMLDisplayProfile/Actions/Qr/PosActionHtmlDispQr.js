let main = async ({context, parameters, captions}) => {
    context.HtmlDisplayVersion = Number.parseInt(captions.HtmlDisplayVersion);                  
    if (!context.IsNestedWorkflow)
    {
        context.QrShow = parameters.QrShow;
        context.QrTitle = parameters.QrTitle;
        context.QrMessage = parameters.QrMessage;
        context.QrContent = parameters.QrContent;
        context.IsNestedWorkflow = false;
    }

    context.QrShow ??= false;
    context.QrTitle ??= "";
    context.QrMessage ??= "";
    context.QrContent ??= "";
    
    let response = null;
    try
    {
        let request = 
        {
            HtmlDisplayVersion: context.HtmlDisplayVersion,
            DisplayAction: "SendJs",
            JsParameter: JSON.stringify({
                JSAction: "QRPaymentScan",
                Provider: context.QrTitle,
                PaymentAmount: context.QrMessage,
                QrContent: context.QrContent,
                Command: (context.QrShow ? 'Open' : 'Close')
            })
        }
        response = await hwc.invoke("HTMLDisplay", request);
    } 
    catch(e)
    {
        if (!context.IsNestedWorkflow)
            popup.error({title: "Customer Display Error: QR", message: `The ${(context.QrShow ? 'Open' : 'Close')} operation failed with: ${e.message}`});
    }
    return response;
}