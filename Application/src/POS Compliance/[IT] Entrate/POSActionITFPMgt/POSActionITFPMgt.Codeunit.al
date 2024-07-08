codeunit 6184662 "NPR POS Action: IT FP Mgt." implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        POSActionITFPMgtB: Codeunit "NPR POS Action: IT FP Mgt. B";
        Method: Option logInPrinter,setUpPrinter,printReceipt,printZReport,printXReport,cashHandling;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer methods.';
        ParamMethodCaptionLbl: Label 'Method';
        ParamMethodDescrLbl: Label 'Specifies the Method used.';
        ParamMethodOptionsCaptionLbl: Label 'Log In Fiscal Printer,Get Fiscal Printer Model,Get Fiscal Printer Payment Methods,Get Fiscal Printer VAT Setup,Print a Fiscal Receipt,Print a Z Report,Print an X Report,Print Last Receipt,Set Logo To Receipt Header';
        ParamMethodOptionsLbl: Label 'logInPrinter,getPrinterModel,getPaymentMethods,getVATSetup,printReceipt,printZReport,printXReport,printLastReceipt,setLogo', Locked = true;
        StatusCodeErr: Label 'Error in communication with the RT printer.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddLabel('statuserror', StatusCodeErr);
        WorkflowConfig.AddOptionParameter('Method',
                                ParamMethodOptionsLbl,
#pragma warning disable AA0139
                                SelectStr(1, ParamMethodOptionsLbl),
#pragma warning restore
                                ParamMethodCaptionLbl,
                                ParamMethodDescrLbl,
                                ParamMethodOptionsCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'CreateHTTPRequestBody':
                FrontEnd.WorkflowResponse(CreateHTTPRequestBody(Context, Sale));
            'HandleResponse':
                HandleResponse(Context, Sale);
        end;
    end;

    local procedure CreateHTTPRequestBody(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Requests: JsonArray;
    begin
        Method := Context.GetIntegerParameter('Method');

        Requests := POSActionITFPMgtB.CreateHTTPRequestBody(Method, Context, Sale);
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    begin
        Method := Context.GetIntegerParameter('Method');

        POSActionITFPMgtB.HandleResponse(Method, Context, Sale);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionITFPMgt.js##
        'const main = async ({workflow, context, captions}) => { const requests = await workflow.respond("CreateHTTPRequestBody"); const resultValues = await fetchFromPrinter(requests, captions); await workflow.respond("HandleResponse", {resultValues: resultValues}); }; async function fetchFromPrinter(requests, captions) { const results = []; await Promise.all(requests.map(async (request, index) => { try { const {url,requestBody} = request; const response = await fetch(url, { method: "POST", headers: { "Content-Type": "application/xml", }, body: requestBody, }); if (response.ok) { const result = await response.text(); results[index] = {index,result}; }; } catch (error) { results[index] = {index, error: captions.statuserror}; } })); return results; }'
        );
    end;
}