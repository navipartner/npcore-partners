codeunit 6184484 "NPR POS Action Pepper Aux" implements "NPR IPOS Workflow"
{

    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Pepper EFT Auxiliary Functions';
        WorkflowTitle: Label 'Auxiliary Functions';
        Executing: Label 'Executing...';
        Finalizing: Label 'Finalizing...';
        Aborting: Label 'Aborting...';
        ConfirmAbort: Label 'Are you sure you want to abort this operation?';
        AuxCaption: Label 'EFT Auxiliary Operation';
        AuxDescription: Label 'Auxiliary operations manages certain settings on the terminal.';
        AuxOptions: Label 'StrMenu,Abort,PAN Suppression ON,PAN Suppression OFF,Custom Menu,Ticket Reprint,Summary Report,Diagnostics,System Info,Display with Num Input,TINA Activation,TINA Query,Show Custom Menu,Activate Offline Mode,Deactivate Offline Mode', locked = true, MaxLength = 250;
        AuxOptionCaptions: Label 'String Menu,Abort,PAN Suppression ON,PAN Suppression OFF,Custom Menu,Ticket Reprint,Summary Report,Diagnostics,System Info,Display with Num Input,TINA Activation,TINA Query,Show Custom Menu,Activate Offline Mode,Deactivate Offline Mode', locked = true, MaxLength = 250;

    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusExecuting', Executing);
        WorkflowConfig.AddLabel('statusFinalizing', Finalizing);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
        WorkflowConfig.AddOptionParameter('auxCommand', AuxOptions, 'Ticket Reprint', AuxCaption, AuxDescription, AuxOptionCaptions);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    var
    begin
        case Step of
            'PrepareRequest':
                Frontend.WorkflowResponse(PrepareRequest(Context, SaleMgr));
            'FinalizeRequest':
                FrontEnd.WorkflowResponse(FinalizeRequest(Context));
        end;
    end;

    local procedure PrepareRequest(Context: codeunit "NPR POS JSON Helper"; SaleMgr: codeunit "NPR POS Sale") Result: JsonObject
    var
        EFTSetup: Record "NPR EFT Setup";
        Sale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PepperLibrary: Codeunit "NPR Pepper Library HWC";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        AuxCommand: Integer;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
    begin
        SaleMgr.GetCurrentSale(Sale);

        AuxCommand := Context.GetIntegerParameter('auxCommand');
        if (AuxCommand = -1) then
            AuxCommand := 0; // StrMenu

        PepperLibrary.GetEFTSetup(Sale."Register No.", EFTSetup);
        EFTTransactionRequest.Get(EFTTransactionMgt.PrepareAuxOperation(EFTSetup, Sale."Register No.", Sale."Sales Ticket No.", AuxCommand, Result, Mechanism, Workflow));
    end;

    local procedure FinalizeRequest(Context: Codeunit "NPR POS JSON Helper") WorkflowContext: JsonObject
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

        PepperLibrary.AuxFunctionResponse(EftTransactionRequest, HwcResponse, WorkflowContext);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPepperAux.Codeunit.js###
'let main=async({workflow:i,context:o,popup:n,runtime:d,hwc:r,data:g,parameters:f,captions:a,scope:p})=>{debugger;o.request==null&&(o.request=await i.respond("PrepareRequest"));debugger;let l,u={Success:!1},s={Success:!1},t=await n.simplePayment({showStatus:!0,title:a.workflowTitle,amount:" "});try{return l=r.registerResponseHandler(async e=>{switch(e.Type){case"AuxiliaryComplete":try{console.log("[Pepper] AUX Operation Complete."),t.updateStatus(a.statusFinalizing),s=await i.respond("FinalizeRequest",{hwcResponse:e}),s.hasOwnProperty("WorkflowName")?(t&&t.close(),await i.run(s.WorkflowName,{context:{request:s}})):(e.ResultCode!=10&&n.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&!s.Success&&n.message({title:a.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+s.Message+"</h3></center>"}),u=e),r.unregisterResponseHandler(l)}catch(c){r.unregisterResponseHandler(l,c)}break;case"UpdateDisplay":console.log("[Pepper] Update Display. "+e.Message),t.updateStatus(e.Message);break}}),t.updateStatus(a.statusExecuting),t.enableAbort(!0),await r.invoke("EFTPepper",o.request,l),await r.waitForContextCloseAsync(l),t&&t.close(),{success:u.Success}}catch(e){throw console.error("[Pepper] Error: ",e),t&&t.close(),e}};'
        );
    end;


}
