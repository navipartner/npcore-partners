codeunit 6059787 "NPR POS Action HWC Gen. Close" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action is the starting point for EFT close operations.';
        WorkflowTitle: Label 'Closing Terminal';
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
        HwcRequest: JsonObject;
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcRequest := Context.GetJsonObject('hwcRequest');

        Context.SetScope('hwcRequest');
        EftTransactionMgt.DispatchHwcEftDeviceResponse(Context.GetString('HwcName'), Context.GetString('Type'), HwcRequest, HwcResponse, Result);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHWCGenClose.Codeunit.js###
'let main=async({workflow:c,hwc:a,popup:l,context:s,captions:i})=>{c.keepAlive();let e,r,n={Success:!1},u={Success:!1};s.showSpinner&&(e=l.simplePayment({showStatus:!0,title:i.workflowTitle,amount:" ",onAbort:async()=>{await l.confirm(i.confirmAbort)&&(e.updateStatus(i.statusAborting),await a.invoke(s.hwcRequest.HwcName,{Type:"RequestCancel",EntryNo:s.hwcRequest.EntryNo},r))},abortValue:{completed:"Aborted"}}));try{r=a.registerResponseHandler(async t=>{switch(t.Type){case s.hwcRequest.Type:try{console.log("[Generic HWC] Operation "+s.hwcRequest.Type+" for "+s.hwcRequest.HwcName+" completed with status "+t.Success),e&&e.updateStatus(i.statusFinalizing),u=await c.respond("ProcessResult",{hwcResponse:t}),(s.showSuccessMessage&&u.Success||!u.Success)&&l.message({caption:u.Message,title:i.workflowTitle}),n=t,a.unregisterResponseHandler(r)}catch(o){a.unregisterResponseHandler(r,o)}break;case"UpdateDisplay":e&&e.updateStatus(t.DisplayLine);break}}),e&&e.updateStatus(i.statusExecuting),e&&e.enableAbort(!0),await a.invoke(s.hwcRequest.HwcName,s.hwcRequest,r),await a.waitForContextCloseAsync(r),c.complete({success:u.Success}),e&&e.close()}catch(t){throw console.error(t),s.showSpinner&&e&&e.close(),t}};'
        );
    end;

}
