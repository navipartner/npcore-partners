codeunit 6248254 "NPR POS Action: HU L Receipt" implements "NPR IPOS Workflow"
{
    Access = Internal;


    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        WorkflowTitleLbl: Label 'HU Laurel Receipt';
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer methods.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitleLbl);
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'SetValuesToContext':
                SetValuesToContext(Context, Sale, Setup);
            'Process':
                FrontEnd.WorkflowResponse(ProcessLaurelMiniPOSData(Context, Sale));
        end;
    end;

    procedure SetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    begin
        POSActionHULReceiptB.SetRequestValuesToContext(Context, Sale, Setup);
    end;

    local procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject
    begin
        exit(POSActionHULReceiptB.ProcessLaurelMiniPOSData(Context, Sale));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionHULReceipt.js###
        'let main=async({workflow:e,hwc:s,popup:o,context:n,captions:t})=>{let r,a,c,l={Success:!1};await e.respond("SetValuesToContext"),n.showSpinner&&(r=await o.spinner({caption:t.workflowTitle,abortEnabled:!1}));try{return a=s.registerResponseHandler((async n=>{if(l=n,l.Success)try{console.log("[Hungary Laurel HWC] ",l),r&&r.updateCaption(t.statusProcessing),c=await e.respond("Process",{hwcResponse:l}),s.unregisterResponseHandler(a),c.Success?c.ShowSuccessMessage&&o.message({caption:c.Message,title:t.workflowTitle}):o.error({caption:c.Message,title:t.workflowTitle})}catch(e){s.unregisterResponseHandler(a,e)}})),r&&r.updateCaption(t.statusExecuting),await s.invoke(n.hwcRequest.HwcName,n.hwcRequest,a),await s.waitForContextCloseAsync(a),{success:c.Success}}finally{r&&r.close(),r=null,await processResponseIfErrorAndCallResetWorkflow(e,l)}};async function processResponseIfErrorAndCallResetWorkflow(e,s){if(!s||!s.Success)return;let o=null;try{o=JSON.parse(s.ResponseMessage).result.iErrCode}catch(e){return void console.error("Invalid JSON in hwcResponse.ResponseMessage:",e)}o&&!["0","531","586","598","599"].includes(o)&&await processWorkflow(e,"HUL_RESET_PRINTER")}async function processWorkflow(e,s){s&&await e.run(s,{})}'
        );
    end;

    var
        POSActionHULReceiptB: Codeunit "NPR POS Action: HU L Receipt B";
}