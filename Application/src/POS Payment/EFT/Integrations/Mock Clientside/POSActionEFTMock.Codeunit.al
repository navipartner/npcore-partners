
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
'let main=async({workflow:l,hwc:a,popup:i,context:e,captions:r})=>{let t=await i.simplePayment({showStatus:!0,title:r.workflowTitle,amount:e.request.CurrencyCode+" "+e.request.SuggestedAmountUserLocal,onAbort:async()=>{await i.confirm(r.confirmAbort)&&(t.updateStatus(r.statusAborting),await a.invoke("EFTMock",{Type:"RequestCancel",EntryNo:e.request.EntryNo},n))},abortValue:{completed:"Aborted"}}),n,u={Success:!1},o={Success:!1};e.success=!1,e.tryEndSale=!1;try{n=a.registerResponseHandler(async s=>{switch(s.Type){case"Lookup":case"Transaction":case"Void":try{if(console.log("[EFT Mock] Transaction Completed."),t.updateStatus(r.statusFinalizing),o=await l.respond("FinalizePaymentRequest",{hwcResponse:s}),!s.Success)throw new Error(s.ResultString);if(s.Success&&!o.Success)throw new Error(o.Message);if(e.request.AmountIn==704)throw new Error("AmountIn with value 704 forces an exception in MOCK hwc response handler.");u=s,a.unregisterResponseHandler(n)}catch(c){a.unregisterResponseHandler(n,c)}break;case"UpdateDisplay":if(console.log("[EFT Mock] Update Display. "+s.DisplayLine),t.updateStatus(s.DisplayLine),e.request.AmountIn==703)throw"AmountIn with value 703 forces an exception in MOCK hwc response handler.";break}}),t.updateStatus(r.statusAuthorizing),t.enableAbort(!0),await a.invoke("EFTMock",e.request,n),await a.waitForContextCloseAsync(n),e.success=u.Success&&o.Success}catch(s){throw i.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+(s.message||"Unknown error")+"</h3></center>"}),s}finally{t&&t.close()}return{success:e.success,tryEndSale:e.success}};'
        );
    end;

}
