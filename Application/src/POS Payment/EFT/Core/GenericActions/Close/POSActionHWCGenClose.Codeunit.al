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
        Request: JsonObject;
        EftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        Request := Context.GetJsonObject('request');

        Context.SetScope('request');
        EftTransactionRequest.Get(Context.GetInteger('EntryNo'));
        EftTransactionMgt.HandleGenericWorkflowResponse(EftTransactionRequest, Request, HwcResponse, Result);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHWCGenClose.Codeunit.js###
'let main=async({workflow:n,hwc:t,popup:l,context:s,captions:a})=>{let e,r,o={Success:!1},i={Success:!1};s.showSpinner&&(e=await l.simplePayment({showStatus:!0,title:a.workflowTitle,amount:" ",onAbort:async()=>{await l.confirm(a.confirmAbort)&&(e.updateStatus(a.statusAborting),await t.invoke(s.request.HwcName,{Type:"RequestCancel",EntryNo:s.request.EntryNo},r))},abortValue:{completed:"Aborted"}}));try{return r=t.registerResponseHandler(async u=>{switch(u.Type){case s.request.Type:try{console.log("[Generic HWC] Operation "+s.request.Type+" for "+s.request.HwcName+" completed with status "+u.Success),e&&e.updateStatus(a.statusFinalizing),i=await n.respond("ProcessResult",{hwcResponse:u}),(s.showSuccessMessage&&i.Success||!i.Success)&&l.message({caption:i.Message,title:a.workflowTitle}),o=u,t.unregisterResponseHandler(r)}catch(c){t.unregisterResponseHandler(r,c)}break;case"UpdateDisplay":e&&e.updateStatus(u.DisplayLine);break}}),e&&e.updateStatus(a.statusExecuting),e&&e.enableAbort(!0),await t.invoke(s.request.HwcName,s.request,r),await t.waitForContextCloseAsync(r),{success:i.Success}}finally{e&&e.close()}};'
        );
    end;

}
