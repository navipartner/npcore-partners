
codeunit 6059794 "NPR POS Action: EFT Mock" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'EFT Request Workflow';
        WorkflowTitle: Label 'MOCK Payment';
        Authorizing: Label 'Authorizing...';
        Finalizing: Label 'Finalizing...';
        Aborting: Label 'Aborting...';
        ConfirmAbort: Label 'Are you sure you want to abort this transaction?';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusAuthorizing', Authorizing);
        WorkflowConfig.AddLabel('statusFinalizing', Finalizing);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'FinalizePaymentRequest':
                Frontend.WorkflowResponse(ProcessResult(Context));
        end;
    end;

    local procedure ProcessResult(Context: Codeunit "NPR POS JSON Helper") Result: JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EftMockClientProtocol: Codeunit "NPR EFT Mock Client Prot.";
        HwcResponse: JsonObject;
        HwcRequest: JsonObject;
        EftInterface: Codeunit "NPR EFT Interface";
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcRequest := Context.GetJsonObject('request');
        Context.SetScope('request');

        EftTransactionRequest.Get(Context.GetInteger('EntryNo'));
        EftMockClientProtocol.HandleDeviceResponse(EftTransactionRequest, HwcRequest, HwcResponse, Result);
        EftTransactionRequest.Find('=');

        EftInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTMock.Codeunit.js###
'let main=async({workflow:i,hwc:t,popup:o,context:e,captions:r})=>{let s;e.request.Unattended||(s=await o.simplePayment({showStatus:!0,title:r.workflowTitle,amount:e.request.CurrencyCode+" "+e.request.SuggestedAmountUserLocal,onAbort:async()=>{await o.confirm(r.confirmAbort)&&(s.updateStatus(r.statusAborting),await t.invoke("EFTMock",{Type:"RequestCancel",EntryNo:e.request.EntryNo},n))},abortValue:{completed:"Aborted"}}));let n,u={Success:!1},l={Success:!1};e.success=!1,e.tryEndSale=!1;try{n=t.registerResponseHandler(async a=>{switch(a.Type){case"Lookup":case"Transaction":case"Void":try{if(console.log("[EFT Mock] Transaction Completed."),e.request.AmountIn==14900&&(a.Success=!1),s&&s.updateStatus(r.statusFinalizing),l=await i.respond("FinalizePaymentRequest",{hwcResponse:a}),u=a,e.request.AmountIn==29800)throw new Error("AmountIn with value 29800 forces an exception in MOCK workflow hwc response handler.");t.unregisterResponseHandler(n)}catch(c){t.unregisterResponseHandler(n,c)}break;case"UpdateDisplay":if(console.log("[EFT Mock] Update Display. "+a.DisplayLine),s&&s.updateStatus(a.DisplayLine),e.request.AmountIn==703)throw"AmountIn with value 703 forces an exception in MOCK hwc response handler.";break}}),s&&s.updateStatus(r.statusAuthorizing),s&&s.enableAbort(!0),await t.invoke("EFTMock",e.request,n),await t.waitForContextCloseAsync(n),e.success=u.Success&&l.Success}catch(a){throw s&&o.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+(a.message||"Unknown error")+"</h3></center>"}),a}finally{s&&s.close()}return console.log("[EFT Mock] success: "+e.success+" (hwc: "+u.Success+" bc: "+l.Success+")"),{success:e.success,tryEndSale:e.success}};'
        );
    end;

}
