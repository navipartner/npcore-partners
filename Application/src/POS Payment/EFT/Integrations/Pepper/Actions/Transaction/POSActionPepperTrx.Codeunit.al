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
        EftInterface: Codeunit "NPR EFT Interface";
        HwcResponse: JsonObject;
        HwcRequest: JsonObject;
        JToken: JsonToken;
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcRequest := Context.GetJsonObject('request');

        HwcRequest.Get('EntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());
        PepperLibrary.TrxResponse(EftTransactionRequest, HwcResponse, WorkflowContext);

        if (EftTransactionRequest."Result Code" <> -999) then
            EftInterface.EftIntegrationResponse(EftTransactionRequest);
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
'let main=async({workflow:u,context:r,popup:a,runtime:f,hwc:o,data:T,parameters:m,captions:s,scope:b})=>{debugger;let c=!0,g=!1,i=await a.simplePayment({showStatus:!0,title:s.workflowTitle,amount:r.request.TransactionRequest.Currency+" "+r.request.TransactionRequest.OriginalDecimalAmount.toFixed(2),onAbort:async()=>{await a.confirm(s.confirmAbort)&&(g=!0,i.updateStatus(s.statusAborting),r.request.TransactionRequest.Operation="AbortTransaction",await o.invoke("EFTPepper",r.request,l))},abortValue:{completed:"Aborted"}}),l,d={Success:!1},t={Success:!1};try{l=o.registerResponseHandler(async e=>{try{switch(e.Type){case"TransactionComplete":try{if(g)return;c=!1,console.log("[Pepper] Transaction Completed."),i.updateStatus(s.statusFinalizing),t=await u.respond("FinalizeTransactionRequest",{hwcResponse:e}),d.Success=e.ResultCode>0;debugger;if(t.hasOwnProperty("WorkflowName")){i&&i.close();let n=await u.run(t.WorkflowName,{context:{request:t}});d.Success=n.success,t.Success=n.endSale;debugger;o.unregisterResponseHandler(l)}else e.ResultCode<=0&&(console.warn("Got a negative response code from Pepper: "+e.ResultCode),a.message({title:s.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"})),e.ResultCode>0&&!t.Success&&(console.warn("Got a negative response code from BC on finalizing transaction: "+t.Message),a.message({title:s.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+t.Message+"</h3></center>"})),e.ResultCode==30&&r.request.TransactionRequest.TrxType==0&&(console.info("Transaction was recovered OK."),a.message({title:s.workflowTitle,caption:"<center><font color=green size=72>&#x2713;</font><h3>Transaction was recovered OK.</h3></center>"}),t.Success=!1),i.updateStatus(s.statusCommitting),r.request.TransactionRequest.Operation="CommitTransaction",await o.invoke("EFTPepper",r.request,l)}catch(n){debugger;o.unregisterResponseHandler(l,n)}break;case"CommitComplete":debugger;o.unregisterResponseHandler(l);break;case"AbortComplete":debugger;c&&(t=await u.respond("FinalizeAbortRequest",{hwcResponse:e}),!e.ResultCode==10&&a.message({title:s.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&a.message({caption:"<center><font color=green size=72>&#10003;</font><h3>"+t.Message+"</h3></center>",title:s.workflowTitle}),o.unregisterResponseHandler(l));break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),i.updateStatus(e.Message);break;case"TellerRequest":debugger;switch(e.TellerRequest.Type){case"NumPad":e.TellerRequest.NumPad.value=await a.numpad(e.TellerRequest.NumPad);break;case"StringPad":e.TellerRequest.StringPad.value=await a.stringpad(e.TellerRequest.StringPad);break;case"OptionMenu":let n=null;do n=await a.optionsMenu(e.TellerRequest.OptionMenu),n||await a.message("Please make a selection.");while(!n);e.TellerRequest.OptionMenu.id=n.id;break}r.request.TellerResponse=e.TellerRequest,r.request.TransactionRequest.Operation="TellerResponse";debugger;await o.invoke("EFTPepper",r.request,l);break;case"TellerRequestComplete":break}}catch(n){console.error("[Pepper] Error in HWC handler ["+l+"] exception: "+n.toString())}}),i.updateStatus(s.statusAuthorizing),i.enableAbort(!0);debugger;return await o.invoke("EFTPepper",r.request,l),await o.waitForContextCloseAsync(l),i.close(),{success:d.Success,tryEndSale:t.Success}}catch(e){throw console.error("[Pepper] Error: ",e.toString()),i&&i.close(),e}};'
        );
    end;
}
