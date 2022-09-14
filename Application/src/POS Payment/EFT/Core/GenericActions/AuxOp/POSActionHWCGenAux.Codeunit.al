codeunit 6059788 "NPR POS Action HWC Gen. Aux" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action is the starting point for EFT auxiliary operations.';
        WorkflowTitle: Label 'Auxiliary Operation';
        Executing: Label 'Executing...';
        Finalizing: Label 'Finalizing...';
        Aborting: Label 'Aborting...';
        ConfirmAbort: Label 'Are you sure you want to abort this operation?';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusExecuting', Executing);
        WorkflowConfig.AddLabel('statusFinalizing', Finalizing);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'ProcessResult':
                Frontend.WorkflowResponse(ProcessResult(Context));
        end;
    end;

    local procedure ProcessResult(Context: Codeunit "NPR POS JSON Helper") Result: JsonObject
    var
        EftTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcResponse: JsonObject;
        Request: JsonObject;
        EftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        Request := Context.GetJsonObject('request');

        Context.SetScope('hwcRequest');
        EftTransactionRequest.Get(Context.GetIntegeR('EntryNo'));
        EftTransactionMgt.HandleGenericWorkflowResponse(EftTransactionRequest, Request, HwcResponse, Result);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHWCGenAux.Codeunit.js###
'let main=async({workflow:c,hwc:a,popup:l,context:s,captions:t})=>{let e,i,n={Success:!1},r={Success:!1};s.showSpinner&&(e=await l.simplePayment({showStatus:!1,title:t.workflowTitle,amount:" ",onAbort:async()=>{await l.confirm(t.confirmAbort)&&(e.updateStatus(t.statusAborting),await a.invoke(s.hwcRequest.HwcName,{Type:"RequestCancel",EntryNo:s.hwcRequest.EntryNo},i))},abortValue:{completed:"Aborted"}}));try{return i=a.registerResponseHandler(async u=>{switch(u.Type){case s.hwcRequest.Type:try{console.log("[Generic HWC] Operation "+s.hwcRequest.Type+" for "+s.hwcRequest.HwcName+" completed with status "+u.Success),e&&e.updateStatus(t.statusFinalizing),r=await c.respond("ProcessResult",{hwcResponse:u}),(s.showSuccessMessage&&r.Success||!r.Success)&&l.message({caption:r.Message,title:t.workflowTitle}),n=u,a.unregisterResponseHandler(i)}catch(o){a.unregisterResponseHandler(i,o)}break;case"UpdateDisplay":e&&e.updateStatus(u.DisplayLine);break}}),e&&e.updateStatus(t.statusExecuting),e&&e.enableAbort(!0),await a.invoke(s.hwcRequest.HwcName,s.hwcRequest,i),await a.waitForContextCloseAsync(i),{success:r.Success}}finally{e&&e.close()}};'
        );
    end;
}
