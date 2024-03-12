const main = async ({workflow, context, parameters, captions}) => {
    await workflow.respond("AddPresetValuesToContext");

    var methodNames = [
        "reportByDate",
        "reportByNumber"
    ];
    
    let methodId = Number(parameters.Method);
    let Method = methodNames[methodId];

    switch(Method) {
        case "reportByDate":{
            workflow.context.startdate = await popup.datepad({ title: captions.title, caption: captions.startDatePrompt, required: true, value: context.defaultdate});
            if (workflow.context.startdate === null) { return;}
        
            workflow.context.enddate = await popup.datepad({ title: captions.title, caption: captions.endDatePrompt, required: true, value: context.defaultdate});
            if (workflow.context.enddate === null) { return;} 
            break;
            }
        case "reportByNumber":{
            workflow.context.zreportdate = await popup.datepad({ title: captions.title, caption: captions.zReportDatePrompt, required: true, value: context.defaultdate});
            if (workflow.context.zreportdate === null) { return;}
        
            workflow.context.receiptnumber = await popup.input({ title: captions.title, caption: captions.receiptNoPrompt});
            if (workflow.context.receiptnumber === null) { return;} 
            break;
            }
    }
    let request = await workflow.respond("CreateHTTPRequestBody");
    let result = await fetchFromPrinter(request);
    await workflow.respond("HandleResponse", { result: result });
  };
  
async function fetchFromPrinter(request) {
    const response = await fetch(request["url"], {
        method: "POST",
        headers: {
            "Content-Type": "application/xml",
        },
        body: request["requestBody"]
    });
    return await response.text();
};