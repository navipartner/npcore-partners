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
'let main=async({workflow:u,context:r,popup:n,runtime:f,hwc:l,data:T,parameters:m,captions:a,scope:b})=>{debugger;let c=!0,g=!1,s=await n.simplePayment({showStatus:!0,title:a.workflowTitle,amount:r.request.TransactionRequest.Currency+" "+r.request.TransactionRequest.OriginalDecimalAmount.toFixed(2),onAbort:async()=>{await n.confirm(a.confirmAbort)&&(g=!0,s.updateStatus(a.statusAborting),r.request.TransactionRequest.Operation="AbortTransaction",await l.invoke("EFTPepper",r.request,i))},abortValue:{completed:"Aborted"}}),i,d={Success:!1},t={Success:!1};try{i=l.registerResponseHandler(async e=>{try{switch(e.Type){case"TransactionComplete":try{if(g)return;c=!1,console.log("[Pepper] Transaction Completed."),s.updateStatus(a.statusFinalizing),t=await u.respond("FinalizeTransactionRequest",{hwcResponse:e}),d.Success=e.ResultCode>0;debugger;if(t.hasOwnProperty("WorkflowName")){s&&s.close();let o=await u.run(t.WorkflowName,{context:{request:t}});d.Success=o.success,t.Success=o.endSale;debugger;l.unregisterResponseHandler(i)}else e.ResultCode<=0&&(console.warn("Got a negative response code from Pepper: "+e.ResultCode),n.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"})),e.ResultCode>0&&!t.Success&&(console.warn("Got a negative response code from BC on finalizing transaction: "+t.Message),n.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+t.Message+"</h3></center>"})),e.ResultCode==30&&r.request.TransactionRequest.TrxType==0&&(console.info("Transaction was recovered OK."),n.message({title:a.workflowTitle,caption:"<center><font color=green size=72>&#x2713;</font><h3>Transaction was recovered OK.</h3></center>"}),t.Success=!1),s.updateStatus(a.statusCommitting),r.request.TransactionRequest.Operation="CommitTransaction",await l.invoke("EFTPepper",r.request,i)}catch(o){debugger;l.unregisterResponseHandler(i,o)}break;case"CommitComplete":debugger;l.unregisterResponseHandler(i);break;case"AbortComplete":debugger;c&&(t=await u.respond("FinalizeAbortRequest",{hwcResponse:e}),!e.ResultCode==10&&n.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&n.message({caption:"<center><font color=green size=72>&#10003;</font><h3>"+t.Message+"</h3></center>",title:a.workflowTitle}),l.unregisterResponseHandler(i));break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),s.updateStatus(e.Message);break;case"TellerRequest":debugger;switch(e.TellerRequest.Type){case"NumPad":e.TellerRequest.NumPad.value=await n.numpad(e.TellerRequest.NumPad);break;case"StringPad":e.TellerRequest.StringPad.value=await n.stringpad(e.TellerRequest.StringPad);break;case"OptionMenu":({id:e.TellerRequest.OptionMenu.id}=await n.optionsMenu(e.TellerRequest.OptionMenu));break}r.request.TellerResponse=e.TellerRequest,r.request.TransactionRequest.Operation="TellerResponse";debugger;await l.invoke("EFTPepper",r.request,i);break;case"TellerRequestComplete":break}}catch(o){console.error("[Pepper] Error in HWC handler ["+i+"] exception: "+o.toString())}}),s.updateStatus(a.statusAuthorizing),s.enableAbort(!0);debugger;return await l.invoke("EFTPepper",r.request,i),await l.waitForContextCloseAsync(i),s.close(),{success:d.Success,tryEndSale:t.Success}}catch(e){throw console.error("[Pepper] Error: ",e.toString()),s&&s.close(),e}};'
        );
    end;
}
