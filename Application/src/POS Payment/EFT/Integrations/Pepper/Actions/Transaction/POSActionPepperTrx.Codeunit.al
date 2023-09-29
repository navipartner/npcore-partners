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
'let main=async({workflow:c,context:a,popup:s,runtime:T,hwc:o,data:m,parameters:b,captions:i,scope:q})=>{debugger;let g=!0,f=!1,n=await s.simplePayment({showStatus:!0,title:i.workflowTitle,amount:a.request.TransactionRequest.Currency+" "+a.request.TransactionRequest.OriginalDecimalAmount.toFixed(2),onAbort:async()=>{await s.confirm(i.confirmAbort)&&(f=!0,n.updateStatus(i.statusAborting),a.request.TransactionRequest.Operation="AbortTransaction",await o.invoke("EFTPepper",a.request,l))},abortValue:{completed:"Aborted"}}),l,d={Success:!1},t={Success:!1};try{l=o.registerResponseHandler(async e=>{try{switch(e.Type){case"TransactionComplete":try{if(f)return;g=!1,console.log("[Pepper] Transaction Completed."),n.updateStatus(i.statusFinalizing),t=await c.respond("FinalizeTransactionRequest",{hwcResponse:e}),d.Success=e.ResultCode>0;debugger;if(t.hasOwnProperty("WorkflowName")){n&&n.close();let r=await c.run(t.WorkflowName,{context:{request:t}});d.Success=r.success,t.Success=r.endSale;debugger;o.unregisterResponseHandler(l)}else e.ResultCode<=0&&(console.warn("Got a negative response code from Pepper: "+e.ResultCode),s.message({title:i.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"})),e.ResultCode>0&&!t.Success&&(console.warn("Got a negative response code from BC on finalizing transaction: "+t.Message),s.message({title:i.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+t.Message+"</h3></center>"})),e.ResultCode==30&&a.request.TransactionRequest.TrxType==0&&(console.info("Transaction was recovered OK."),s.message({title:i.workflowTitle,caption:"<center><font color=green size=72>&#x2713;</font><h3>Transaction was recovered OK.</h3></center>"}),t.Success=!1),n.updateStatus(i.statusCommitting),a.request.TransactionRequest.Operation="CommitTransaction",await o.invoke("EFTPepper",a.request,l)}catch(r){debugger;o.unregisterResponseHandler(l,r)}break;case"CommitComplete":debugger;o.unregisterResponseHandler(l);break;case"AbortComplete":debugger;g&&(t=await c.respond("FinalizeAbortRequest",{hwcResponse:e}),!e.ResultCode==10&&s.message({title:i.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&s.message({caption:"<center><font color=green size=72>&#10003;</font><h3>"+t.Message+"</h3></center>",title:i.workflowTitle}),o.unregisterResponseHandler(l));break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),n.updateStatus(e.Message);break;case"TellerRequest":debugger;switch(e.TellerRequest.Type){case"NumPad":e.TellerRequest.NumPad.value=await s.numpad(e.TellerRequest.NumPad);break;case"StringPad":e.TellerRequest.StringPad.value=await s.input(e.TellerRequest.StringPad);break;case"OptionMenu":let r=null,u=e.TellerRequest.OptionMenu;for(u.oneTouch=u.options.length>0;!r&&u.oneTouch;)r=await s.optionsMenu(u),r||await s.message("Please make a selection.");r&&(u.id=r.id);break}a.request.TellerResponse=e.TellerRequest,a.request.TransactionRequest.Operation="TellerResponse";debugger;await o.invoke("EFTPepper",a.request,l);break;case"TellerRequestComplete":break}}catch(r){console.error("[Pepper] Error in HWC handler ["+l+"] exception: "+r.toString())}}),n.updateStatus(i.statusAuthorizing),n.enableAbort(!1);debugger;return await o.invoke("EFTPepper",a.request,l),await o.waitForContextCloseAsync(l),n.close(),{success:d.Success,tryEndSale:t.Success}}catch(e){throw console.error("[Pepper] Error: ",e.toString()),n&&n.close(),e}};'
        );
    end;
}
