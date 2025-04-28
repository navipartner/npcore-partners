codeunit 6248368 "NPR POS Action: HU L FP Mgt." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer methods.';
        ParamMethodCaptionLbl: Label 'Method';
        ParamMethodDescrLbl: Label 'Specifies the Method used.';
        ParamMethodOptionsCaptionLbl: Label 'Open Fiscal Day,Close Fiscal Day,Log In,Cashier FCU Report,Open Cash Drawer,Get FCU Daily Total,Print Receipt Copy,Refiscalize Sale from Audit Log,Void Current Sale';
        ParamMethodOptionsLbl: Label 'openFiscalDay,closeFiscalDay,cashierFCUReport,getDailyTotal,resetPrinter,setEuroRate,printReceiptCopy,refiscalizeAuditLog,voidCurrentSale', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter('Method', ParamMethodOptionsLbl, '', ParamMethodCaptionLbl, ParamMethodDescrLbl, ParamMethodOptionsCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'SetValuesToContext':
                SetValuesToContext(Context, Sale, Setup);
            'Process':
                FrontEnd.WorkflowResponse(ProcessLaurelMiniPOSData(Context, Sale, Setup));
        end;
    end;

    procedure SetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    begin
        POSActionHULFPMgtB.SetRequestValuesToContext(Context, Sale, Setup);
    end;

    local procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"): JsonObject
    begin
        exit(POSActionHULFPMgtB.ProcessLaurelMiniPOSData(Context, Sale, Setup));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHULReceipt.js###
'let main=async({workflow:o,hwc:a,popup:n,context:r,captions:t})=>{let e,i,s={Success:!1};await o.respond("SetValuesToContext"),r.showSpinner&&(e=await n.spinner({caption:t.workflowTitle,abortEnabled:!1}));try{return i=a.registerResponseHandler(async l=>{if(l.Success)try{console.log("[Hungary Laurel HWC] ",l),e&&e.updateCaption(t.statusProcessing),s=await o.respond("Process",{hwcResponse:l}),a.unregisterResponseHandler(i),s.Success?s.ShowSuccessMessage&&n.message({caption:s.Message,title:t.workflowTitle}):n.error({caption:s.Message,title:t.workflowTitle})}catch(c){a.unregisterResponseHandler(i,c)}}),e&&e.updateCaption(t.statusExecuting),await a.invoke(r.hwcRequest.HwcName,r.hwcRequest,i),await a.waitForContextCloseAsync(i),{success:s.Success}}finally{e&&e.close(),e=null}};'
        );
    end;

    var
        POSActionHULFPMgtB: Codeunit "NPR POS Action: HU L FP Mgt. B";
}