codeunit 6014517 "NPR MobilePayV10 Dialog"
{
    SingleInstance = true;

    var
        _model: DotNet NPRNetModel;
        _activeModelID: Guid;
        _trxEntryNo: Integer;
        _done: Boolean;
        _abortRequested: Boolean;
        _firstAbortRequestedTime: DateTime;
        _lastStatusCode: Integer;

        Lbl_ABORT: Label 'Abort';
        Lbl_FORCE_ABORT: Label 'Force Abort';
        Lbl_CONFIRM_FORCE_ABORT: Label 'WARNING:\Force abort will close the transaction dialog without receiving transaction result. This should only be used if mobilepay is unresponsive. Use lookup afterwards to recover any approved transactions!\Continue with force abort?';


    internal procedure Initialize(POSFrontEnd: Codeunit "NPR POS Front End Management"; eftTrxRequest: Record "NPR EFT Transaction Request")
    begin
        Clear(_done);
        Clear(_firstAbortRequestedTime);
        Clear(_abortRequested);
        _trxEntryNo := eftTrxRequest."Entry No.";

        ConstructTransactionDialog(eftTrxRequest);
        _activeModelID := POSFrontEnd.ShowModel(_model);
    end;

    local procedure ConstructTransactionDialog(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        _model := _model.Model();
        Html(EFTTransactionRequest);
        _model.AddStyle(Css());
        _model.AddScript(Javascript(EFTTransactionRequest));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnTransactionDialogResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
        if ModelID <> _activeModelID then
            exit;
        Handled := true;

        if _done then
            exit; //Event is late - we have already acted on a result.

        case Sender of
            'mobilepay-timer':
                CheckResponse(FrontEnd);
            'mobilepay-abort':
                RequestAbort(FrontEnd);
            'mobilepay-force-abort':
                ForceAbort(FrontEnd);
        end;
    end;

    local procedure CheckResponse(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        eftTrxRequest: Record "NPR EFT Transaction Request";
        eftSetup: Record "NPR EFT Setup";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        mobilePayResultCode: Enum "NPR MobilePayV10 Result Code";
        captured: Boolean;
        captureAttempts: Integer;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftTrxRequest.Get(_trxEntryNo);
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");

        mobilePayProtocol.PollTrxStatus(eftTrxRequest, eftSetup);

        Commit();

        if eftTrxRequest."Result Code" = mobilePayResultCode::Reserved.AsInteger() then begin
            //Trx needs to be captured.
            while (not captured) and (captureAttempts < 3) do begin
                captured := mobilePayProtocol.CaptureTrx(eftTrxRequest, eftSetup);
                Commit();
                captureAttempts += 1;
            end;
        end;

        if eftTrxRequest."Result Code" in
            [mobilePayResultCode::Captured.AsInteger(),
            mobilePayResultCode::CancelledByUser.AsInteger(),
             mobilePayResultCode::CancelledByClient.AsInteger(),
             mobilePayResultCode::CancelledByMobilePay.AsInteger(),
             mobilePayResultCode::ExpiredAndCancelled.AsInteger(),
             mobilePayResultCode::RejectedByMobilePayDueToAgeRestrictions.AsInteger()] then begin
            //Trx is done
            FrontEnd.CloseModel(_activeModelID);
            _done := true;
            mobilePayIntegration.HandleProtocolResponse(eftTrxRequest);
            exit;
        end;

        if (eftTrxRequest."Result Code" <> _lastStatusCode) then begin
            //Update front end
            _model.GetControlById('mobilepay-status').Set('Caption', Format("NPR MobilePayV10 Result Code".FromInteger(eftTrxRequest."Result Code")));
            FrontEnd.UpdateModel(_model, _activeModelID);
            _lastStatusCode := eftTrxRequest."Result Code";
        end;
    end;

    local procedure RequestAbort(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftSetup: Record "NPR EFT Setup";
    begin
        EFTTransactionRequest.Get(_trxEntryNo);
        eftSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not _abortRequested then begin
            _firstAbortRequestedTime := CurrentDateTime;
            _abortRequested := true;
        end;

        mobilePayProtocol.RequestAbort(EFTTransactionRequest, eftSetup);

        if (CurrentDateTime - _firstAbortRequestedTime) > (1000 * 60) then begin //Force Abort button visible 1 minute after first abort attempt.
            _model.GetControlById('mobilepay-force-abort').Set('Visible', true);
            FrontEnd.UpdateModel(_model, _activeModelID);
        end;
    end;

    local procedure ForceAbort(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        if not Confirm(Lbl_CONFIRM_FORCE_ABORT, false) then
            exit;
        EFTTransactionRequest.Get(_trxEntryNo);

        mobilePayProtocol.ForceAbort(EFTTransactionRequest);
        FrontEnd.CloseModel(_activeModelID);
        _done := true;
    end;

    local procedure Css(): Text
    begin
        exit(
        '.mobilepay-dialog {' +
        '  max-width: 14em;' +
        '  max-height: 28em;' +
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
        '.mobilepay-dialog-item {  ' +
        '  margin: auto;  ' +
        '  font-weight: bold;  ' +
        '  font-family: Helvetica, Verdana, Arial, sans-serif;' +
        '  text-align: center;' +
        '}' +
        '#mobilepay-caption { ' +
        '  margin-bottom: 0.2em;  ' +
        '  font-size: 1em;' +
        '  align-self: flex-start;' +
        '}' +
        '#mobilepay-amount { ' +
        '  margin-top: 0.2em;  ' +
        '  margin-bottom: 1em;  ' +
        '  font-size: 2em;' +
        '  align-self: flex-start;' +
        '}' +
        '#mobilepay-status { ' +
        '  font-size: 1em;' +
        '}' +
        '#mobilepay-abort { ' +
        '  font-size: 1em;' +
        '  background: grey;' +
        '  border: none;' +
        '  line-height: 2.5em;' +
        '  cursor: pointer;' +
        '  width: 80%;' +
        '  align-self: flex-end;' +
        '}' +
        '#mobilepay-force-abort { ' +
        '  font-size: 1em;' +
        '  background: grey;' +
        '  border: none;' +
        '  line-height: 2.5em;' +
        '  cursor: pointer;' +
        '  width: 80%;' +
        '  align-self: flex-end;' +
        '}' +
        '#mobilepay-spinner {' +
        '  display: inline-block;' +
        '  position: relative;' +
        '  width: 64px;' +
        '  height: 64px;' +
        '}' +
        '#mobilepay-spinner div {' +
        '  box-sizing: border-box;' +
        '  display: block;' +
        '  position: absolute;' +
        '  width: 51px;' +
        '  height: 51px;' +
        '  margin: 6px;' +
        '  border: 6px solid #000000;' +
        '  border-radius: 50%;' +
        '  animation: mobilepay-spinner 1.6s cubic-bezier(0.5, 0, 0.5, 1) infinite;' +
        '  border-color: #000000 transparent transparent transparent;' +
        '}' +
        '#mobilepay-spinner div:nth-child(1) {' +
        '  animation-delay: -0.45s;' +
        '}' +
        '#mobilepay-spinner div:nth-child(2) {' +
        '  animation-delay: -0.3s;' +
        '}' +
        '#mobilepay-spinner div:nth-child(3) {' +
        '  animation-delay: -0.15s;' +
        '}' +
        '@keyframes mobilepay-spinner {' +
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
        DialogStatus: DotNet NPRNetLabel;
        DialogAbortButton: DotNet NPRNetLabel;
        DialogAmount: DotNet NPRNetLabel;
        DialogForceAbortButton: DotNet NPRNetLabel;
    begin
        Dialog := Factory.Panel().Set('Class', 'mobilepay-dialog');
        Dialog.FontSize('');

        DialogCaption := Factory.Label(Format(EFTTransactionRequest."Processing Type")).Set('Class', 'mobilepay-dialog-item').Set('Id', 'mobilepay-caption');
        DialogCaption.FontSize('');
        DialogStatus := Factory.Label('').Set('Class', 'mobilepay-dialog-item').Set('Id', 'mobilepay-status');
        DialogStatus.FontSize('');
        DialogAmount := Factory.Label(Format(EFTTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>')).Set('Class', 'mobilepay-dialog-item').Set('Id', 'mobilepay-amount');
        DialogAmount.FontSize('');

        DialogForceAbortButton := Factory.Label(Lbl_FORCE_ABORT).Set('Class', 'mobilepay-dialog-item').Set('Id', 'mobilepay-force-abort').SubscribeEvent('click');
        DialogForceAbortButton.Set('Visible', false);
        DialogForceAbortButton.FontSize('');

        DialogAbortButton := Factory.Label(Lbl_ABORT).Set('Class', 'mobilepay-dialog-item').Set('Id', 'mobilepay-abort').SubscribeEvent('click');
        DialogAbortButton.FontSize('');

        Dialog.Append(
          DialogCaption,
          DialogStatus,
          DialogAmount);
        Dialog.Append(
          Factory.Panel().Set('Id', 'qrcode'),
          Factory.Panel().Set('Class', 'mobilepay-dialog-item').Set('Id', 'mobilepay-spinner')
            .Append(
              Factory.Panel().Set('Id', 'mobilepay-spinner-inner1'),
              Factory.Panel().Set('Id', 'mobilepay-spinner-inner2'),
              Factory.Panel().Set('Id', 'mobilepay-spinner-inner3'),
              Factory.Panel().Set('Id', 'mobilepay-spinner-inner4')
            ),
          DialogForceAbortButton,
          DialogAbortButton
        );

        Dialog.Append(
          Factory.Label().Set('Visible', false).Set('Id', 'mobilepay-timer').SubscribeEvent('click')
        );

        _model.Append(Dialog);
    end;

    local procedure Javascript(eftTrxRequest: Record "NPR EFT Transaction Request"): Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        exit(
            'setInterval(function() { $("#mobilepay-timer").click(); }, 1000);' +
            WebClientDependency.GetJavaScript('QRCODE') +
            'new QRCode(document.getElementById("qrcode"), { width: 146, height: 146, colorDark: "#003f63", colorLight: "white", text: "' + mobilePayProtocol.GetQRBeaconId(eftTrxRequest) + '" });');
    end;
}