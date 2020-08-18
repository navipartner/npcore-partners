codeunit 6184544 "SS Action - Adyen Unattended"
{
    // NPR5.55/JAKUBV/20200807  CASE 386254 Transport NPR5.55 - 31 July 2020


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Adyen Cloud Unattended Transaction';
        DIALOG_CAPTION: Label 'Continue on terminal';

    local procedure ActionCode(): Text
    begin
        exit ('ADYEN_CLOUD_SS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.4');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction20(
            ActionCode(),
            ActionDescription,
            ActionVersion())
          then begin
            RegisterWorkflow20(
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

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        case WorkflowStep of
          'StartTrx' : StartTrx(POSSession, Context, FrontEnd);
          'CheckResponse' : FrontEnd.WorkflowResponse(CheckResponse(POSSession, Context, FrontEnd));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnGetIntegrationRequestWorkflow', '', false, false)]
    local procedure OnGetIntegrationRequestWorkflow(EFTTransactionRequest: Record "EFT Transaction Request";var IntegrationWorkflow: Text)
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        EFTSetup: Record "EFT Setup";
    begin
        if EFTTransactionRequest."Integration Type" <> EFTAdyenCloudIntegration.IntegrationType() then
          exit;
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if not EFTAdyenCloudIntegration.GetUnattended(EFTSetup) then
          exit;

        IntegrationWorkflow := ActionCode();
    end;

    local procedure StartTrx(POSSession: Codeunit "POS Session";Context: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
        EFTTransactionRequest: Record "EFT Transaction Request";
        EftEntryNo: Integer;
    begin
        EftEntryNo := Context.GetInteger('entryNo', true);
        EFTTransactionRequest.Get(EftEntryNo);

        EFTAdyenCloudProtocol.SendEftDeviceRequest(EFTTransactionRequest, false);
    end;

    local procedure CheckResponse(POSSession: Codeunit "POS Session";Context: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management"): Boolean
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
        EFTTransactionRequest: Record "EFT Transaction Request";
        ContinueOnTransactionEntryNo: Integer;
        EFTAdyenCloudBackgndResp: Codeunit "EFT Adyen Backgnd. Response";
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EftEntryNo: Integer;
    begin
        EftEntryNo := Context.GetInteger('entryNo', true);
        if not EFTTrxBackgroundSessionMgt.ResponseExists(EftEntryNo) then
          exit(false);

        EFTTransactionRequest."Entry No." := EftEntryNo;
        EFTAdyenCloudBackgndResp.SetRunMode(0);
        if not EFTAdyenCloudBackgndResp.Run(EFTTransactionRequest) then
          exit(false);

        //Response was found with a lock, i.e. no dirty read. Process it and close dialog regardless of success status.
        //Display any uncaught errors (extremely critical as payment might have been processed. Will need to be handled via trx lookup, assuming error was transient or missing config).

        EFTTransactionRequest.Reset;
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

