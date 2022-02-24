
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
        EftFramework: Codeunit "NPR EFT Framework Mgt.";
        HwcResponse: JsonObject;
        HwcRequest: JsonObject;
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcRequest := Context.GetJsonObject('hwcRequest');
        Context.SetScope('hwcRequest');

        EftTransactionRequest.Get(
           EftMockClientProtocol.HandleDeviceResponse(Context.GetString('HwcName'), Context.GetString('Type'), HwcRequest, HwcResponse, Result));

        EftFramework.EftIntegrationResponseReceived(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnGetIntegrationRequestWorkflow', '', false, false)]
    local procedure OnGetIntegrationRequestWorkflow(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var IntegrationWorkflow: Text; EftJsonRequest: JsonObject)
    var
        MockProtocol: Codeunit "NPR EFT Mock Client Prot.";
    begin
        if (not EFTTransactionRequest.IsType(MockProtocol.IntegrationType())) then
            exit;

        if (not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT,
                                                             EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
                                                             EFTTransactionRequest."Processing Type"::REFUND])) then
            exit;

        IntegrationWorkflow := Format(Enum::"NPR POS Workflow"::EFT_MOCK_CLIENT);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTMock.Codeunit.js###
'let main=async({workflow:o,hwc:n,popup:c,context:t,captions:a})=>{o.keepAlive();let s=c.simplePayment({showStatus:!0,title:a.workflowTitle,amount:t.hwcRequest.CurrencyCode+" "+t.hwcRequest.SuggestedAmountUserLocal,onAbort:async()=>{await c.confirm(a.confirmAbort)&&(s.updateStatus(a.statusAborting),await n.invoke(t.hwcRequest.HwcName,{Type:"RequestCancel",EntryNo:t.hwcRequest.EntryNo},r))},abortValue:{completed:"Aborted"}}),r,l={Success:!1},i={Success:!1};try{r=n.registerResponseHandler(async e=>{switch(e.Type){case"Lookup":case"Transaction":case"Void":try{if(console.log("[EFT Mock] Transaction Completed."),s.updateStatus(a.statusFinalizing),i=await o.respond("FinalizePaymentRequest",{hwcResponse:e}),e.Success||c.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.Success&&!i.Success&&c.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+i.Message+"</h3></center>"}),t.hwcRequest.AmountIn==704)throw"AmountIn with value 704 forces an exception in MOCK hwc response handler.";l=e,n.unregisterResponseHandler(r)}catch(u){n.unregisterResponseHandler(r,u)}break;case"UpdateDisplay":if(console.log("[EFT Mock] Update Display. "+e.DisplayLine),s.updateStatus(e.DisplayLine),t.hwcRequest.AmountIn==703)throw"AmountIn with value 703 forces an exception in MOCK hwc response handler.";break}}),s.updateStatus(a.statusAuthorizing),s.enableAbort(!0),await n.invoke(t.hwcRequest.HwcName,t.hwcRequest,r),await n.waitForContextCloseAsync(r),o.complete({success:l.Success,endSale:i.Success}),s.close()}catch(e){throw console.error("[EFT Mock] Error: ",e),s&&s.close(),o.complete({success:!1,endSale:!1}),e}};'
        );
    end;

}
