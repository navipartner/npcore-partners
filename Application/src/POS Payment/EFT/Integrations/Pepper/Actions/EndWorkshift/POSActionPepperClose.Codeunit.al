codeunit 6184483 "NPR POS Action Pepper Close" implements "NPR IPOS Workflow"
{

    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Pepper EFT Close';
        WorkflowTitle: Label 'Close Terminal';
        Closing: Label 'Closing...';
        Finalizing: Label 'Finalizing...';
        Aborting: Label 'Aborting...';
        ConfirmAbort: Label 'Are you sure you want to abort this operation?';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusClosing', Closing);
        WorkflowConfig.AddLabel('statusFinalizing', Finalizing);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Record "NPR POS Sale";
    begin
        case Step of
            'PrepareCloseRequest':
                begin
                    SetupMgr.GetPOSUnit(POSUnit);
                    SaleMgr.GetCurrentSale(POSSale);
                    FrontEnd.WorkflowResponse(PrepareCloseRequest(POSUnit, POSSale));
                end;
            'FinalizeCloseRequest':
                FrontEnd.WorkflowResponse(FinalizeCloseRequest(Context));
        end;
    end;

    local procedure PrepareCloseRequest(POSUnit: Record "NPR POS Unit"; POSSale: Record "NPR POS Sale") WorkflowContext: JsonObject
    var
        PepperLibrary: Codeunit "NPR Pepper Library HWC";
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        HwcRequest: JsonObject;
    begin
        PepperLibrary.GetEFTSetup(POSUnit, EFTSetup);
        EFTIntegration.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, POSUnit."No.", POSSale."Sales Ticket No.");
        PepperLibrary.MakeHwcDeviceRequest(EFTTransactionRequest, HwcRequest);
        WorkflowContext.Add('request', HwcRequest);
    end;

    local procedure FinalizeCloseRequest(Context: Codeunit "NPR POS JSON Helper") WorkflowContext: JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        PepperLibrary: Codeunit "NPR Pepper Library HWC";
        HwcResponse: JsonObject;
        HwcRequest: JsonObject;
        JToken: JsonToken;
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcRequest := Context.GetJsonObject('request');

        HwcRequest.Get('EntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());

        PepperLibrary.EndWorkshiftResponse(EftTransactionRequest, HwcResponse, WorkflowContext);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPepperClose.Codeunit.js###
'let main=async({workflow:n,context:t,popup:o,runtime:g,hwc:r,data:d,parameters:f,captions:a,scope:p})=>{debugger;if(t.request==null){({request:t.request}=await n.respond("PrepareCloseRequest"));debugger}debugger;let s=await o.simplePayment({showStatus:!0,title:a.workflowTitle,amount:" "}),l,u={Success:!1},i={Success:!1};try{return l=r.registerResponseHandler(async e=>{switch(e.Type){case"EndWorkshiftComplete":try{console.log("[Pepper] Transaction Completed."),s.updateStatus(a.statusFinalizing),i=await n.respond("FinalizeCloseRequest",{hwcResponse:e}),e.ResultCode!=10&&(t.hideFailureMessage||o.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"})),e.ResultCode==10&&!i.Success&&(t.hideFailureMessage||o.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+i.Message+"</h3></center>"})),(t.showSuccessMessage==null&&i.Success||t.showSuccessMessage&&i.Success)&&o.message({caption:"<center><font color=green size=72>&#x2713;</font><h3>"+i.Message+"</h3></center>",title:a.workflowTitle}),u=e,r.unregisterResponseHandler(l)}catch(c){r.unregisterResponseHandler(l,c)}break;case"AbortComplete":r.unregisterResponseHandler(l);break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),s.updateStatus(e.Message);break}}),s.updateStatus(a.statusClosing),s.enableAbort(!0),await r.invoke("EFTPepper",t.request,l),await r.waitForContextCloseAsync(l),s&&s.close(),{success:u.Success}}catch(e){return console.error("[Pepper] Error: ",e),s&&s.close(),{success:!1}}};'
        )
    end;
}
