#if not CLOUD
codeunit 6184544 "NPR SS Action - Adyen Unatt."
{
    Access = Internal;

    var
        ActionDescription: Label 'Adyen Cloud Unattended Transaction';
        DIALOG_CAPTION: Label 'Continue on terminal';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text[20]
    begin
        exit('ADYEN_CLOUD_SS');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.4');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20(
              'let test = await workflow.respond("StartTrx");' +

              'workflow.keepAlive();' +

              'let dialog = popup.open({' +
                  'title: "Payment",' +
                  'ui: [' +
                      '{' +
                          'type: "label",' +
                          'id: "label1",' +
                          'caption: "' + GetDialogCaption() + '"' +
                      '}' +
                  '],' +
                  'buttons: []' +
              '});' +

              'async function checkResponse() {' +
                'let trxDone = await workflow.respond("CheckResponse");' +
                'if (trxDone) {' +
                  'dialog.close(true);' +
                  'workflow.complete()' +
                '} else {' +
                  'setTimeout(async () => { await checkResponse(); }, 1000);' +
                '}' +
              '};' +

              'await checkResponse();'
            );
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        case WorkflowStep of
            'StartTrx':
                StartTrx(Context);
            'CheckResponse':
                FrontEnd.WorkflowResponse(CheckResponse(Context));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnGetIntegrationRequestWorkflow', '', false, false)]
    local procedure OnGetIntegrationRequestWorkflow(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var IntegrationWorkflow: Text; EftJsonRequest: JsonObject)
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        EFTSetup: Record "NPR EFT Setup";
    begin
        if EFTTransactionRequest."Integration Type" <> EFTAdyenCloudIntegration.IntegrationType() then
            exit;
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if not EFTAdyenCloudIntegration.GetUnattended(EFTSetup) then
            exit;

        IntegrationWorkflow := ActionCode();
    end;

    local procedure StartTrx(Context: Codeunit "NPR POS JSON Management")
    var
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EftEntryNo: Integer;
    begin
        EftEntryNo := Context.GetIntegerOrFail('entryNo', StrSubstNo(ReadingErr, ActionCode()));
        EFTTransactionRequest.Get(EftEntryNo);

        EFTAdyenCloudProtocol.SendEftDeviceRequest(EFTTransactionRequest, false);
    end;
    local procedure CheckResponse(Context: Codeunit "NPR POS JSON Management"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenCloudBackgndResp: Codeunit "NPR EFT Adyen Backgnd. Resp.";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EftEntryNo: Integer;
    begin
        EftEntryNo := Context.GetIntegerOrFail('entryNo', StrSubstNo(ReadingErr, ActionCode()));
        if not EFTTrxBackgroundSessionMgt.ResponseExists(EftEntryNo) then
            exit(false);

        EFTTransactionRequest."Entry No." := EftEntryNo;
        EFTAdyenCloudBackgndResp.SetRunMode(0);
        if not EFTAdyenCloudBackgndResp.Run(EFTTransactionRequest) then
            exit(false);

        //Response was found with a lock, i.e. no dirty read. Process it and close dialog regardless of success status.
        //Display any uncaught errors (extremely critical as payment might have been processed. Will need to be handled via trx lookup, assuming error was transient or missing config).

        EFTTransactionRequest.Reset();
        EFTTransactionRequest."Entry No." := EftEntryNo;
        EFTAdyenCloudBackgndResp.SetRunMode(1);
        EFTAdyenCloudBackgndResp.Run(EFTTransactionRequest);
        exit(true);
    end;

    local procedure GetDialogCaption(): Text
    begin
        exit(DelChr(DIALOG_CAPTION, '=', '"'));
    end;
}
#endif