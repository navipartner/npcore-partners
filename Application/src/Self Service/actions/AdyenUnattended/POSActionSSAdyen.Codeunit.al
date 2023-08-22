#if not CLOUD
codeunit 6184544 "NPR POS Action - SS Adyen" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Unattended Adyen Cloud Transaction';
        DIALOG_CAPTION: Label 'Continue on terminal';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('selfserviceStatus', DelChr(DIALOG_CAPTION, '=', '"'));
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'StartTrx':
                StartTrx(Context);
            'CheckResponse':
                FrontEnd.WorkflowResponse(CheckResponse(Context));
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnParepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Workflow: Text; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism")
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        EFTSetup: Record "NPR EFT Setup";
    begin
        if EFTTransactionRequest."Integration Type" <> EFTAdyenCloudIntegration.IntegrationType() then
            exit;
        if EFTTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::PAYMENT then
            exit;
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if not EFTAdyenCloudIntegration.GetUnattended(EFTSetup) then
            exit;

        Request.Add('EntryNo', EFTTransactionRequest."Entry No.");
        RequestMechanism := RequestMechanism::POSWorkflow;
        Workflow := Format(Enum::"NPR POS Workflow"::SS_ADYEN_CLOUD);
    end;

    local procedure StartTrx(Context: Codeunit "NPR POS JSON Helper")
    var
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EftEntryNo: Integer;
    begin
        EftEntryNo := Context.GetInteger('EntryNo');
        EFTTransactionRequest.Get(EftEntryNo);

        EFTAdyenCloudProtocol.SendEftDeviceRequest(EFTTransactionRequest, false);
    end;

    local procedure CheckResponse(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenCloudBackgndResp: Codeunit "NPR EFT Adyen Backgnd. Resp.";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EftEntryNo: Integer;
    begin
        EftEntryNo := Context.GetInteger('EntryNo');
        if not EFTTrxBackgroundSessionMgt.ResponseExists(EftEntryNo) then begin
            Response.Add('trxDone', false);
            exit;
        end;

        EFTTransactionRequest."Entry No." := EftEntryNo;
        EFTAdyenCloudBackgndResp.SetRunMode(0);
        if not EFTAdyenCloudBackgndResp.Run(EFTTransactionRequest) then begin
            Response.Add('trxDone', false);
            exit;
        end;

        //Response was found with a lock, i.e. no dirty read. Process it and close dialog regardless of success status.
        //Display any uncaught errors (extremely critical as payment might have been processed. Will need to be handled via trx lookup, assuming error was transient or missing config).

        EFTTransactionRequest.Reset();
        EFTTransactionRequest."Entry No." := EftEntryNo;
        EFTAdyenCloudBackgndResp.SetRunMode(1);
        EFTAdyenCloudBackgndResp.Run(EFTTransactionRequest);

        EFTTransactionRequest.Find('=');
        Response.Add('trxDone', true);
        Response.Add('BCSuccess', EFTTransactionRequest.Successful);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSAdyenUnatt.js###
'let main=async({workflow:t,popup:r,captions:c,context:e})=>{e.EntryNo=e.request.EntryNo,await t.respond("StartTrx");let i=await r.open({title:"Payment",ui:[{type:"label",id:"label1",caption:c.selfserviceStatus}],buttons:[]});return await new Promise((n,l)=>{let a=async()=>{try{let s=await t.respond("CheckResponse");if(s.trxDone){e.success=s.BCSuccess,i.close(),n();return}setTimeout(a,1e3)}catch(s){l(s)}};setTimeout(a,1e3)}),{success:e.success,tryEndSale:e.success}};'
        );
    end;
}
#endif
