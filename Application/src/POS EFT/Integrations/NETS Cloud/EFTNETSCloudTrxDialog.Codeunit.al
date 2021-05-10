codeunit 6184535 "NPR EFT NETSCloud Trx Dialog"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Model: DotNet NPRNetModel;
        ActiveModelID: Guid;
        TransactionEntryNo: Integer;
        Done: Boolean;
        TXT_ABORT: Label 'Abort';
        AbortRequested: Boolean;
        ModelAmount: Decimal;
        TXT_FORCE_ABORT: Label 'Force Abort';
        FirstAbortRequestedTime: DateTime;
        CONFIRM_FORCE_ABORT: Label 'WARNING:\Force abort will close the transaction dialog without receiving transaction result. This should only be used if the terminal has frozen or is unresponsive. Use lookup afterwards to recover any approved transactions!\Continue with force abort?';

    procedure ShowTransactionDialog(EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management")
    begin
        Clear(Done);
        Clear(FirstAbortRequestedTime);
        Clear(AbortRequested);
        TransactionEntryNo := EFTTransactionRequest."Entry No.";
        ModelAmount := GetAmount(EFTTransactionRequest);

        ConstructTransactionDialog(EFTTransactionRequest);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
    end;

    local procedure ConstructTransactionDialog(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        Model := Model.Model();
        Html(EFTTransactionRequest);
        Model.AddStyle(Css());
        Model.AddScript(Javascript());
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnTransactionDialogResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
            exit;
        Handled := true;

        if Done then
            exit; //Event is late - we have already acted on a result.

        case Sender of
            'nets-timer':
                CheckResponse(POSSession, FrontEnd);
            'nets-abort':
                RequestAbort(FrontEnd);
            'nets-force-abort':
                ForceAbort(FrontEnd);
        end;
    end;

    local procedure CheckResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudBgResp: Codeunit "NPR EFT NETSCloud Bg. Resp.";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
    begin
        if not EFTTrxBackgroundSessionMgt.ResponseExists(TransactionEntryNo) then
            exit;

        EFTTransactionRequest."Entry No." := TransactionEntryNo;
        EFTNETSCloudBgResp.SetRunMode(0);
        if not EFTNETSCloudBgResp.Run(EFTTransactionRequest) then
            exit;

        //Response was found with a lock, i.e. no dirty read. Process it and close dialog regardless of success status.
        //Display any uncaught errors (extremely critical as payment might have been processed. Will need to be handled via trx lookup, assuming error was transient or missing config).

        EFTTransactionRequest.Reset();
        EFTTransactionRequest."Entry No." := TransactionEntryNo;
        EFTNETSCloudBgResp.SetRunMode(1);
        if not EFTNETSCloudBgResp.Run(EFTTransactionRequest) then begin
            Message(GetLastErrorText);
            if FrontEnd.IsPaused() then
                FrontEnd.ResumeWorkflow();
        end;

        FrontEnd.CloseModel(ActiveModelID);
        Done := true;
    end;

    local procedure RequestAbort(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
    begin
        EFTTransactionRequest.Get(TransactionEntryNo);

        EFTNETSCloudIntegration.AbortTransaction(EFTTransactionRequest);

        if not AbortRequested then begin
            FirstAbortRequestedTime := CurrentDateTime;
            AbortRequested := true;
        end;

        if (CurrentDateTime - FirstAbortRequestedTime) > (1000 * 60) then begin //Force Abort button visible 1 minute after first abort attempt.
            Model.GetControlById('nets-force-abort').Set('Visible', true);
            FrontEnd.UpdateModel(Model, ActiveModelID);
        end;
    end;

    local procedure ForceAbort(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        if not Confirm(CONFIRM_FORCE_ABORT, false) then
            exit;
        EFTTransactionRequest.Get(TransactionEntryNo);
        EFTNETSCloudProtocol.ForceCloseTransaction(EFTTransactionRequest);
        FrontEnd.CloseModel(ActiveModelID);
        Done := true;
    end;

    local procedure Css(): Text
    begin
        exit(
        '.nets-dialog {' +
        '  max-width: 17.5em;' +
        '  max-height: 20em;' +
        '  width: 70vw;' +
        '  height: 80vh;' +
        '  background: linear-gradient(#f4f4f4, #dedede);' +
        ' -webkit-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);' +
        ' -moz-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);' +
        '  box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);' +
        '  display: -webkit-box;' +
        '  display: -moz-box;' +
        '  display: -ms-flexbox;' +
        '  display: -webkit-flex;' +
        '  display: flex;' +
        '  flex-flow: column wrap;' +
        '  justify-content: space-around;' +
        '  align-items: center;' +
        '}' +
        '.nets-dialog-item {  ' +
        '  margin: auto;  ' +
        '  font-weight: bold;  ' +
        '  font-family: Helvetica, Verdana, Arial, sans-serif;' +
        '  text-align: center;' +
        '}' +
        '#nets-caption { ' +
        '  margin-bottom: 0.2em;  ' +
        '  font-size: 1em;' +
        '  align-self: flex-start;' +
        '}' +
        '#nets-amount { ' +
        '  margin-top: 0.2em;  ' +
        '  margin-bottom: 1em;  ' +
        '  font-size: 2em;' +
        '  align-self: flex-start;' +
        '}' +
        '#nets-status { ' +
        '  font-size: 1em;' +
        '}' +
        '#nets-abort { ' +
        '  font-size: 1em;' +
        '  background: grey;' +
        '  border: none;' +
        '  line-height: 2.5em;' +
        '  cursor: pointer;' +
        '  width: 80%;' +
        '  align-self: flex-end;' +
        '}' +
        '#nets-force-abort { ' +
        '  font-size: 1em;' +
        '  background: grey;' +
        '  border: none;' +
        '  line-height: 2.5em;' +
        '  cursor: pointer;' +
        '  width: 80%;' +
        '  align-self: flex-end;' +
        '}' +
        '#nets-spinner {' +
        '  display: inline-block;' +
        '  position: relative;' +
        '  width: 64px;' +
        '  height: 64px;' +
        '}' +
        '#nets-spinner div {' +
        '  box-sizing: border-box;' +
        '  display: block;' +
        '  position: absolute;' +
        '  width: 51px;' +
        '  height: 51px;' +
        '  margin: 6px;' +
        '  border: 6px solid #000000;' +
        '  border-radius: 50%;' +
        '  animation: nets-spinner 1.6s cubic-bezier(0.5, 0, 0.5, 1) infinite;' +
        '  border-color: #000000 transparent transparent transparent;' +
        '}' +
        '#nets-spinner div:nth-child(1) {' +
        '  animation-delay: -0.45s;' +
        '}' +
        '#nets-spinner div:nth-child(2) {' +
        '  animation-delay: -0.3s;' +
        '}' +
        '#nets-spinner div:nth-child(3) {' +
        '  animation-delay: -0.15s;' +
        '}' +
        '@keyframes nets-spinner {' +
        '  0% {' +
        '    transform: rotate(0deg);' +
        '  }' +
        '  100% {' +
        '    transform: rotate(360deg);' +
        '  }' +
        '}');
    end;

    local procedure Html(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        Factory: DotNet NPRNetControlFactory;
        Dialog: DotNet NPRNetPanel;
        DialogCaption: DotNet NPRNetLabel;
        DialogAbortButton: DotNet NPRNetLabel;
        DialogAmount: DotNet NPRNetLabel;
        DialogForceAbortButton: DotNet NPRNetLabel;
    begin
        Dialog := Factory.Panel().Set('Class', 'nets-dialog');
        Dialog.FontSize('');

        DialogCaption := Factory.Label(GetCaption(EFTTransactionRequest)).Set('Class', 'nets-dialog-item').Set('Id', 'nets-caption');
        DialogCaption.FontSize('');

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and (EFTTransactionRequest."Auxiliary Operation ID" <> 2) then begin
            DialogAmount := Factory.Label('').Set('Class', 'nets-dialog-item').Set('Id', 'nets-amount');
        end else begin
            DialogAmount := Factory.Label(Format(ModelAmount, 0, '<Precision,2:2><Standard Format,2>')).Set('Class', 'nets-dialog-item').Set('Id', 'nets-amount');
        end;
        DialogAmount.FontSize('');

        DialogForceAbortButton := Factory.Label(TXT_FORCE_ABORT).Set('Class', 'nets-dialog-item').Set('Id', 'nets-force-abort').SubscribeEvent('click');
        DialogForceAbortButton.Set('Visible', false);
        DialogForceAbortButton.FontSize('');

        DialogAbortButton := Factory.Label(TXT_ABORT).Set('Class', 'nets-dialog-item').Set('Id', 'nets-abort').SubscribeEvent('click');
        DialogAbortButton.FontSize('');

        Dialog.Append(
          DialogCaption,
          DialogAmount,
          Factory.Panel().Set('Class', 'nets-dialog-item').Set('Id', 'nets-spinner')
            .Append(
              Factory.Panel().Set('Id', 'nets-spinner-inner1'),
              Factory.Panel().Set('Id', 'nets-spinner-inner2'),
              Factory.Panel().Set('Id', 'nets-spinner-inner3'),
              Factory.Panel().Set('Id', 'nets-spinner-inner4')
            ),
          DialogForceAbortButton,
          DialogAbortButton
        );

        Dialog.Append(
          Factory.Label().Set('Visible', false).Set('Id', 'nets-timer').SubscribeEvent('click')
        );

        Model.Append(Dialog);
    end;

    local procedure Javascript(): Text
    begin
        exit('setInterval(function() { $("#nets-timer").click(); }, 1000);');
    end;

    local procedure GetCaption(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(Format(EFTTransactionRequest."Processing Type"));
    end;

    local procedure GetAmount(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Decimal
    begin
        exit(EFTTransactionRequest."Amount Input");
    end;
}

