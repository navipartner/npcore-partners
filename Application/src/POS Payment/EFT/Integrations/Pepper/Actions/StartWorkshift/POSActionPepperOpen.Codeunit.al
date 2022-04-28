codeunit 6184481 "NPR POS Action Pepper Open" implements "NPR IPOS Workflow"
{

    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Pepper EFT Open';
        WorkflowTitle: Label 'Open Terminal';
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

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Record "NPR POS Sale";
    begin
        case Step of
            'PrepareOpenRequest':
                begin
                    SetupMgr.GetPOSUnit(POSUnit);
                    SaleMgr.GetCurrentSale(POSSale);
                    FrontEnd.WorkflowResponse(PrepareOpenRequest(POSUnit, POSSale));
                end;

            'FinalizeOpenRequest':
                FrontEnd.WorkflowResponse(FinalizeOpenRequest(Context));
        end;
    end;

    local procedure PrepareOpenRequest(POSUnit: Record "NPR POS Unit"; POSSale: Record "NPR POS Sale") WorkflowContext: JsonObject
    var
        PepperLibrary: Codeunit "NPR Pepper Library HWC";
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        HwcRequest: JsonObject;
    begin
        PepperLibrary.GetEFTSetup(POSUnit, EFTSetup);
        EFTIntegration.CreateBeginWorkshiftRequest(EFTTransactionRequest, EFTSetup, POSUnit."No.", POSSale."Sales Ticket No.");
        PepperLibrary.MakeHwcDeviceRequest(EFTTransactionRequest, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure FinalizeOpenRequest(Context: Codeunit "NPR POS JSON Helper") WorkflowContext: JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        PepperLibrary: Codeunit "NPR Pepper Library HWC";
        HwcResponse: JsonObject;
        HwcRequest: JsonObject;
        JToken: JsonToken;
    begin
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcRequest := Context.GetJsonObject('hwcRequest');

        HwcRequest.Get('EntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());

        PepperLibrary.BeginWorkshiftResponse(EftTransactionRequest, HwcResponse, WorkflowContext);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPepperOpen.Codeunit.js###
'let main=async({workflow:n,context:a,popup:i,runtime:g,hwc:l,data:d,parameters:f,captions:r,scope:m})=>{debugger;if(a.hwcRequest==null){({hwcRequest:a.hwcRequest}=await n.respond("PrepareOpenRequest"));debugger}debugger;let s,o,u={Success:!1},t={Success:!1};s=i.simplePayment({showStatus:!0,title:r.workflowTitle,amount:" "});try{o=l.registerResponseHandler(async e=>{switch(e.Type){case"StartWorkshiftComplete":try{console.log("[Pepper] Transaction Completed."),s.updateStatus(r.statusFinalizing),t=await n.respond("FinalizeOpenRequest",{hwcResponse:e});debugger;if(t.hasOwnProperty("WorkflowName")){e.ResultCode==10&&e.StartWorkshiftResponse.RecoveryRequired&&await i.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x2757;</font><h3>"+t.Message+"</h3></center>"}),s.close();let c=await n.run(t.WorkflowName,{context:{hwcRequest:t}});debugger}else e.ResultCode!=10&&i.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&!t.Success&&i.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+t.Message+"</h3></center>"}),(a.showSuccessMessage==null&&t.Success||a.showSuccessMessage&&t.Success)&&i.message({caption:"<center><font color=green size=72>&#x2713;</font><h3>"+t.Message+"</h3></center>",title:r.workflowTitle}),u=e;l.unregisterResponseHandler(o)}catch(c){l.unregisterResponseHandler(o,c)}break;case"AbortComplete":l.unregisterResponseHandler(o);break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),s.updateStatus(e.Message);break}}),s.updateStatus(r.statusExecuting),s.enableAbort(!0);debugger;return await l.invoke(a.hwcRequest.HwcName,a.hwcRequest,o),await l.waitForContextCloseAsync(o),s.close(),{success:u.Success,endSale:!1}}catch(e){throw console.error("[Pepper] Error: ",e),s&&s.close(),e}};'
        );
    end;
}
