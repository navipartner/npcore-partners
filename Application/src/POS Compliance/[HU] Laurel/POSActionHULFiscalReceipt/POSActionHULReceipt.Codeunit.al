codeunit 6248254 "NPR POS Action: HU L Receipt" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer methods.';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetActionScript());
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
'let main=async({workflow:o,hwc:a,popup:n,context:r,captions:t})=>{let e,i,s={Success:!1};await o.respond("SetValuesToContext"),r.showSpinner&&(e=await n.spinner({caption:t.workflowTitle,abortEnabled:!1}));try{return i=a.registerResponseHandler(async l=>{if(l.Success)try{console.log("[Hungary Laurel HWC] ",l),e&&e.updateCaption(t.statusProcessing),s=await o.respond("Process",{hwcResponse:l}),a.unregisterResponseHandler(i),s.Success?s.ShowSuccessMessage&&n.message({caption:s.Message,title:t.workflowTitle}):n.error({caption:s.Message,title:t.workflowTitle})}catch(c){a.unregisterResponseHandler(i,c)}}),e&&e.updateCaption(t.statusExecuting),await a.invoke(r.hwcRequest.HwcName,r.hwcRequest,i),await a.waitForContextCloseAsync(i),{success:s.Success}}finally{e&&e.close(),e=null}};'
        );
    end;

    var
        POSActionHULReceiptB: Codeunit "NPR POS Action: HU L Receipt B";
}
