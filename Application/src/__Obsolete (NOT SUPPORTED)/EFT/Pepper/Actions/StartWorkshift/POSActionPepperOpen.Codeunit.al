codeunit 6184481 "NPR POS Action Pepper Open" implements "NPR IPOS Workflow"
{

    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

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
        WorkflowContext.Add('request', HwcRequest);
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
        HwcRequest := Context.GetJsonObject('request');

        HwcRequest.Get('EntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());

        PepperLibrary.BeginWorkshiftResponse(EftTransactionRequest, HwcResponse, WorkflowContext);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPepperOpen.Codeunit.js###
'let main=async({workflow:u,context:l,popup:i,runtime:g,hwc:o,data:d,parameters:f,captions:r,scope:S})=>{debugger;if(l.request==null){({request:l.request}=await u.respond("PrepareOpenRequest"));debugger}debugger;let t,a,n={Success:!1},s={Success:!1};t=await i.simplePayment({showStatus:!0,title:r.workflowTitle,amount:" "});try{a=o.registerResponseHandler(async e=>{switch(console.log("[Pepper] HWC Response Handler [SWS]: "+a+" Type="+e.Type),e.Type){case"StartWorkshiftComplete":try{console.log("[Pepper] Transaction Completed."),t.updateStatus(r.statusFinalizing),s=await u.respond("FinalizeOpenRequest",{hwcResponse:e}),n.Success=e.ResultCode==10;debugger;if(s.hasOwnProperty("WorkflowName")){e.ResultCode==10&&e.StartWorkshiftResponse.RecoveryRequired&&await i.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x2757;</font><h3>"+s.Message+"</h3></center>"}),t&&t.close();let c=await u.run(s.WorkflowName,{context:{request:s}});e.StartWorkshiftResponse.RecoveryRequired&&(s.Success=!1,n.Success=c.Success);debugger}else e.ResultCode!=10&&i.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&!s.Success&&i.message({title:r.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+s.Message+"</h3></center>"}),(l.showSuccessMessage==null&&s.Success||l.showSuccessMessage&&s.Success)&&i.message({caption:"<center><font color=green size=72>&#x2713;</font><h3>"+s.Message+"</h3></center>",title:r.workflowTitle});o.unregisterResponseHandler(a)}catch(c){o.unregisterResponseHandler(a,c)}break;case"AbortComplete":o.unregisterResponseHandler(a);break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),t.updateStatus(e.Message);break}}),t.updateStatus(r.statusExecuting),t.enableAbort(!0);debugger;await o.invoke("EFTPepper",l.request,a),await o.waitForContextCloseAsync(a),t&&t.close();debugger;return{success:n.Success,endSale:s.Success}}catch(e){throw console.error("[Pepper] Error: ",e),t&&t.close(),e}};'
        );
    end;
}
