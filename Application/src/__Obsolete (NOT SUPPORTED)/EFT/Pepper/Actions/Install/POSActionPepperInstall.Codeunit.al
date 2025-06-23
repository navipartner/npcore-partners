codeunit 6184489 "NPR POS Action Pepper Install" implements "NPR IPOS Workflow"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action performs Pepper Install';
        WorkflowTitle: Label 'Pepper installation';
        PrepareInstall: Label 'Preparing...';
        DownloadFile: Label 'Downloading File...';
        InstallingPepper: Label 'Installing Pepper...';
        Aborting: Label 'Aborting...';
        ConfirmAbort: Label 'Are you sure you want to abort this operation?';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('prepareInstall', PrepareInstall);
        WorkflowConfig.AddLabel('downloadFile', DownloadFile);
        WorkflowConfig.AddLabel('installPepper', InstallingPepper);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Record "NPR POS Sale";
    begin
        case Step of
            'PrepareRequest':
                begin
                    SetupMgr.GetPOSUnit(POSUnit);
                    SaleMgr.GetCurrentSale(POSSale);
                    FrontEnd.WorkflowResponse(PrepareRequest(POSUnit, POSSale));
                end;
            'DownloadToClient':
                FrontEnd.WorkflowResponse(DownloadToClient(Context));
            'FinalizeRequest':
                FrontEnd.WorkflowResponse(FinalizeRequest(Context));
        end;
    end;

    local procedure PrepareRequest(POSUnit: Record "NPR POS Unit"; POSSale: Record "NPR POS Sale") WorkflowContext: JsonObject
    var
        PepperLibrary: Codeunit "NPR Pepper Library HWC";
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        HwcRequest: JsonObject;
    begin
        PepperLibrary.GetEFTSetup(POSUnit, EFTSetup);
        EFTIntegration.CreateVerifySetupRequest(EFTTransactionRequest, EFTSetup, POSUnit."No.", POSSale."Sales Ticket No.");
        PepperLibrary.MakeHwcDeviceRequest(EFTTransactionRequest, HwcRequest);
        WorkflowContext.Add('request', HwcRequest);
    end;

    local procedure DownloadToClient(Context: codeunit "NPR POS JSON Helper") WorkflowContext: JsonObject
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

        HwcResponse.Get('InstallResponse', JToken);
        JToken.AsObject().Get('DownloadToPath', JToken);

        HwcRequest.ReadFrom('{}');
        PepperLibrary.DownloadFileToClient(EftTransactionRequest, JToken.AsValue().AsText(), HwcRequest);

        WorkflowContext.Add('request', HwcRequest);
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

        PepperLibrary.InstallPepperResponse(EftTransactionRequest, HwcResponse, WorkflowContext);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPepperInstall.Codeunit.js###
'let main=async({workflow:o,context:s,popup:l,runtime:u,hwc:r,data:d,parameters:f,captions:i,scope:p})=>{let t,a,c={Success:!1},n={Success:!1};t=await l.simplePayment({showStatus:!0,title:i.workflowTitle,amount:" ",onAbort:async()=>{await l.confirm(i.confirmAbort)&&r.unregisterResponseHandler(a)},abortValue:{completed:"Aborted"}});try{a=r.registerResponseHandler(async e=>{switch(e.Type){case"DownloadFileRequest":({request:s.request}=await o.respond("DownloadToClient",{hwcResponse:e})),await r.invoke("EFTPepper",s.request,a);break;case"InstallComplete":n=await o.respond("FinalizeRequest",{hwcResponse:e}),e.ResultCode!=10&&l.message({title:i.workflowTitle,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+e.ResultString+"</h3></center>"}),e.ResultCode==10&&(l.message({caption:"<center><font color=green size=72>&#x2713;</font><h3>"+e.ResultString+"</h3></center>",title:i.workflowTitle}),s.request.Operation="HWCRestartConnector",await r.invoke("EFTPepper",s.request,a)),r.unregisterResponseHandler(a);break;case"UpdateDisplay":t.updateStatus(e.Message);break}}),t.updateStatus(i.prepareInstall),t.enableAbort(!0),{request:s.request}=await o.respond("PrepareRequest");debugger;await r.invoke("EFTPepper",s.request,a),await r.waitForContextCloseAsync(a),t&&t.close()}catch(e){throw console.error("[Pepper] Install Error: ",e),t&&t.close(),e}};'
        );
    end;
}
