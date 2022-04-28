codeunit 6184482 "NPR POS Action Pepper Trx" implements "NPR IPOS Workflow"
{

    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Pepper EFT Transaction';
        WorkflowTitle: Label 'Transaction';
        Authorizing: Label 'Authorizing...';
        Finalizing: Label 'Finalizing...';
        Aborting: Label 'Aborting...';
        Committing: Label 'Committing...';
        ConfirmAbort: Label 'Are you sure you want to abort this operation?';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusAuthorizing', Authorizing);
        WorkflowConfig.AddLabel('statusFinalizing', Finalizing);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('statusCommitting', Committing);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    begin
        case Step of
            'FinalizeTransactionRequest':
                FrontEnd.WorkflowResponse(FinalizeTransactionRequest(Context));
            'FinalizeAbortRequest':
                FrontEnd.WorkflowResponse(FinalizeAbortRequest());

        end;
    end;

    local procedure FinalizeTransactionRequest(Context: Codeunit "NPR POS JSON Helper") WorkflowContext: JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        PepperLibrary: Codeunit "NPR Pepper Library HWC";
        EftFramework: Codeunit "NPR EFT Framework Mgt.";

        HwcResponse: JsonObject;
        HwcRequest: JsonObject;
        JToken: JsonToken;
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcRequest := Context.GetJsonObject('hwcRequest');

        HwcRequest.Get('EntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());
        PepperLibrary.TrxResponse(EftTransactionRequest, HwcResponse, WorkflowContext);

        if (EftTransactionRequest."Result Code" <> -999) then
            EftFramework.EftIntegrationResponseReceived(EftTransactionRequest);
    end;

    local procedure FinalizeAbortRequest() WorkflowResponse: JsonObject
    var
    begin
        WorkflowResponse.ReadFrom('{}');
        WorkflowResponse.Add('Success', true);
        WorkflowResponse.Add('Message', 'Aborted');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPepperTrx.Codeunit.js###
'let main=async({workflow:u,context:t,popup:s,runtime:m,hwc:l,data:f,parameters:q,captions:a,scope:R})=>{debugger;if(t.hwcRequest==null){({hwcRequest:t.hwcRequest}=await u.respond("PrepareTransactionRequest"));debugger}debugger;let o=!0,c=!1,i=s.simplePayment({showStatus:!0,title:a.workflowTitle,amount:t.hwcRequest.TransactionRequest.Currency+" "+t.hwcRequest.TransactionRequest.OriginalDecimalAmount,onAbort:async()=>{await s.confirm(a.confirmAbort)&&(c=!0,i.updateStatus(a.statusAborting),t.hwcRequest.TransactionRequest.Operation="AbortTransaction",await l.invoke(t.hwcRequest.HwcName,t.hwcRequest,n))},abortValue:{completed:"Aborted"}}),n,d={Success:!1},r={Success:!1};try{return n=l.registerResponseHandler(async e=>{switch(e.Type){case"TransactionComplete":try{if(c)return;o=!1,console.log("[Pepper] Transaction Completed."),i.updateStatus(a.statusFinalizing),r=await u.respond("FinalizeTransactionRequest",{hwcResponse:e}),d=e;debugger;if(r.hasOwnProperty("WorkflowName")){i.close(),await u.run(r.WorkflowName,{context:{hwcRequest:r}});debugger}else e.ResultCode<=0&&(console.warn("Got a negative response code from Pepper: "+e.ResultCode),s.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"})),e.ResultCode>0&&!r.Success&&(console.warn("Got a negative response code from BC on finalizing transaction: "+r.Message),s.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+r.Message+"</h3></center>"})),e.ResultCode==30&&t.hwcRequest.TransactionRequest.TrxType==0&&(console.info("Transaction was recovered OK."),s.message({title:a.workflowTitle,caption:"<center><font color=green size=72>&#x2713;</font><h3>Transaction was recovered OK.</h3></center>"}),r.Success=!1);t.hwcRequest.TransactionRequest.Operation="CommitTransaction",l.invoke(t.hwcRequest.HwcName,t.hwcRequest,n),i.updateStatus(a.statusCommitting)}catch(g){l.unregisterResponseHandler(n,g)}break;case"CommitComplete":l.unregisterResponseHandler(n);break;case"AbortComplete":o&&(r=await u.respond("FinalizeAbortRequest",{hwcResponse:e}),!e.ResultCode==10&&s.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&s.message({caption:"<center><font color=green size=72>&#10003;</font><h3>"+r.Message+"</h3></center>",title:a.workflowTitle}),l.unregisterResponseHandler(n));break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),i.updateStatus(e.Message);break;case"TellerRequest":debugger;switch(e.TellerRequest.Type){case"NumPad":e.TellerRequest.NumPad.value=await s.numpad(e.TellerRequest.NumPad);break;case"StringPad":e.TellerRequest.StringPad.value=await s.stringpad(e.TellerRequest.StringPad);break;case"OptionMenu":({id:e.TellerRequest.OptionMenu.id}=await s.optionsMenu(e.TellerRequest.OptionMenu));break}t.hwcRequest.TellerResponse=e.TellerRequest,t.hwcRequest.TransactionRequest.Operation="TellerResponse";debugger;await l.invoke(t.hwcRequest.HwcName,t.hwcRequest,n);break;case"TellerRequestComplete":break}}),i.updateStatus(a.statusAuthorizing),i.enableAbort(!0),await l.invoke(t.hwcRequest.HwcName,t.hwcRequest,n),await l.waitForContextCloseAsync(n),i.close(),{success:d.Success,endSale:r.Success}}catch(e){throw console.error("[Pepper] Error: ",e),i&&i.close(),e}};'
        );
    end;
}
