codeunit 6184519 "EFT Adyen Cloud Trx Dialog"
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // NPR5.49/MMV /20190305 CASE 345188 Added support for AcquireCard
    // NPR5.49/MMV /20190409 CASE 351678 Check response via codeunit.run instead of tryfunction
    // NPR5.50/MMV /20190430 CASE 352465 Added support for silent price reduction after customer recognition.
    // NPR5.51/MMV /20190827 CASE 357279 Changed timings on dialog
    // NPR5.53/MMV /20191120 CASE 377533 Added force abort button
    // NPR5.53/MMV /20200126 CASE 377533 Changed force abort timer limit

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for %1 payment. ';
        ERROR_INVOKE: Label 'Error: Service endpoint responded with HTTP status %1';
        TransactionEntryNo: Integer;
        ERROR_WS_SESSION: Label 'Error: Could not start background session for Adyen webservice invoke';
        Done: Boolean;
        ERROR_RECEIPT: Label 'Error: Could not create terminal receipt data';
        ERROR_HEADER_CATEGORY: Label 'Error: Header category %1, expected %2';
        VOID_SUCCESS: Label 'Transaction %1 was successfully voided';
        VOID_FAILURE: Label 'Transaction %1 could not be voided: %2\%3';
        DIAGNOSE: Label 'Terminal Status: %1\Terminal Connection: %2\Host Connection: %3';
        UNKNOWN: Label 'Unknown';
        TXT_ABORT: Label 'Abort';
        AbortRequested: Boolean;
        ModelAmount: Decimal;
        TXT_FORCE_ABORT: Label 'Force Abort';
        TransactionStartTime: DateTime;
        FirstAbortRequestedTime: DateTime;
        CONFIRM_FORCE_ABORT: Label 'WARNING:\Force abort will close the transaction dialog without receiving transaction result. This should only be used if the terminal has frozen or is unresponsive. Use lookup afterwards to recover any approved transactions!\Continue with force abort?';

    procedure ShowTransactionDialog(EFTTransactionRequest: Record "EFT Transaction Request"; POSFrontEnd: Codeunit "POS Front End Management")
    begin
        Clear(Done);
        //-NPR5.53 [377533]
        Clear(FirstAbortRequestedTime);
        //+NPR5.53 [377533]
        Clear(AbortRequested);
        TransactionEntryNo := EFTTransactionRequest."Entry No.";
        ModelAmount := GetAmount(EFTTransactionRequest);
        //-NPR5.53 [377533]
        TransactionStartTime := EFTTransactionRequest.Started;
        //+NPR5.53 [377533]

        ConstructTransactionDialog(EFTTransactionRequest);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
    end;

    local procedure ConstructTransactionDialog(EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        Model := Model.Model();
        Html(EFTTransactionRequest);
        Model.AddStyle(Css());
        Model.AddScript(Javascript());
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnTransactionDialogResponse(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
    begin
        if ModelID <> ActiveModelID then
            exit;
        Handled := true;

        if Done then
          exit; //Event is late - we have already acted on a result.

        case Sender of
          'adyen-timer' : CheckResponse(POSSession, FrontEnd);
          'adyen-abort' : RequestAbort(FrontEnd);
          'adyen-force-abort' : ForceAbort(FrontEnd);
        end;
    end;

    local procedure CheckResponse(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
        EFTTransactionRequest: Record "EFT Transaction Request";
        ContinueOnTransactionEntryNo: Integer;
        EFTAdyenCloudBackgndResp: Codeunit "EFT Adyen Backgnd. Response";
    begin
        EFTTransactionRequest."Entry No." := TransactionEntryNo;
        if not EFTAdyenCloudBackgndResp.Run(EFTTransactionRequest) then
            exit;

        Done := true;

        if EFTAdyenCloudIntegration.ContinueAfterAcquireCard(POSSession, TransactionEntryNo, ContinueOnTransactionEntryNo) then begin
          EFTTransactionRequest.Get(ContinueOnTransactionEntryNo);
          if ModelAmount <> EFTTransactionRequest."Amount Input" then begin
            ModelAmount := EFTTransactionRequest."Amount Input";
            Model.GetControlById('adyen-amount').Set('Caption',Format(ModelAmount,0,'<Precision,2:2><Standard Format,2>'));
            FrontEnd.UpdateModel(Model, ActiveModelID);
          end;
          TransactionEntryNo := ContinueOnTransactionEntryNo; //Switch to waiting for Payment Transaction

        //-NPR5.53 [377533]
          TransactionStartTime := EFTTransactionRequest.Started;
          Clear(FirstAbortRequestedTime);
        //+NPR5.53 [377533]
          Clear(AbortRequested);
          Clear(Done);
          exit;
        end;

        FrontEnd.CloseModel(ActiveModelID);
    end;

    local procedure RequestAbort(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
    begin
        EFTTransactionRequest.Get(TransactionEntryNo);

        //-NPR5.53 [377533]
        EFTAdyenCloudIntegration.AbortTransaction(EFTTransactionRequest);

        if not AbortRequested then begin
        //-NPR5.53 [377533]
          FirstAbortRequestedTime := CurrentDateTime;
        //+NPR5.53 [377533]
          AbortRequested := true;
        end;

        //-NPR5.53 [377533]
        if (CurrentDateTime - FirstAbortRequestedTime) > (1000 * 60) then begin //Force Abort button visible 1 minute after first abort attempt.
        //+NPR5.53 [377533]
          Model.GetControlById('adyen-force-abort').Set('Visible', true);
          FrontEnd.UpdateModel(Model, ActiveModelID);
        end;
    end;

    local procedure ForceAbort(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
    begin
        //-NPR5.53 [377533]
        if not Confirm(CONFIRM_FORCE_ABORT, false) then
          exit;
        //+NPR5.53 [377533]
        EFTTransactionRequest.Get(TransactionEntryNo);
        EFTAdyenCloudProtocol.ForceCloseTransaction(EFTTransactionRequest);
        FrontEnd.CloseModel(ActiveModelID);
        Done := true;
    end;

    local procedure Css(): Text
    begin
        exit(
        '.adyen-dialog {' +
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
        '.adyen-dialog-item {  ' +
        '  margin: auto;  ' +
        '  font-weight: bold;  ' +
        '  font-family: Helvetica, Verdana, Arial, sans-serif;' +
        '  text-align: center;' +
        '}' +
        '#adyen-caption { ' +
        '  margin-bottom: 0.2em;  ' +
        '  font-size: 1em;' +
        '  align-self: flex-start;' +
        '}' +
        '#adyen-amount { ' +
        '  margin-top: 0.2em;  ' +
        '  margin-bottom: 1em;  ' +
        '  font-size: 2em;' +
        '  align-self: flex-start;' +
        '}' +
        '#adyen-status { ' +
        '  font-size: 1em;' +
        '}' +
        '#adyen-abort { ' +
        '  font-size: 1em;' +
        '  background: grey;' +
        '  border: none;' +
        '  line-height: 2.5em;' +
        '  cursor: pointer;' +
        '  width: 80%;'+
        '  align-self: flex-end;' +
        '}' +
        '#adyen-force-abort { '+
        '  font-size: 1em;'+
        '  background: grey;'+
        '  border: none;'+
        '  line-height: 2.5em;'+
        '  cursor: pointer;' +
        '  width: 80%;' +
        '  align-self: flex-end;' +
        '}' +
        '#adyen-spinner {' +
        '  display: inline-block;' +
        '  position: relative;' +
        '  width: 64px;' +
        '  height: 64px;' +
        '}' +
        '#adyen-spinner div {' +
        '  box-sizing: border-box;' +
        '  display: block;' +
        '  position: absolute;' +
        '  width: 51px;' +
        '  height: 51px;' +
        '  margin: 6px;' +
        '  border: 6px solid #000000;' +
        '  border-radius: 50%;' +
        '  animation: adyen-spinner 1.6s cubic-bezier(0.5, 0, 0.5, 1) infinite;' +
        '  border-color: #000000 transparent transparent transparent;' +
        '}' +
        '#adyen-spinner div:nth-child(1) {' +
        '  animation-delay: -0.45s;' +
        '}' +
        '#adyen-spinner div:nth-child(2) {' +
        '  animation-delay: -0.3s;' +
        '}' +
        '#adyen-spinner div:nth-child(3) {' +
        '  animation-delay: -0.15s;' +
        '}' +
        '@keyframes adyen-spinner {' +
        '  0% {' +
        '    transform: rotate(0deg);' +
        '  }' +
        '  100% {' +
        '    transform: rotate(360deg);' +
        '  }' +
        '}');
    end;

    local procedure Html(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        Factory: DotNet npNetControlFactory;
        Dialog: DotNet npNetPanel;
        DialogCaption: DotNet npNetLabel;
        DialogAbortButton: DotNet npNetLabel;
        DialogAmount: DotNet npNetLabel;
        DialogForceAbortButton: DotNet npNetLabel;
    begin
        Dialog := Factory.Panel().Set('Class', 'adyen-dialog');
        Dialog.FontSize('');

        DialogCaption := Factory.Label(GetCaption(EFTTransactionRequest)).Set('Class', 'adyen-dialog-item').Set('Id', 'adyen-caption');
        DialogCaption.FontSize('');

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and (EFTTransactionRequest."Auxiliary Operation ID" <> 2) then begin
          DialogAmount := Factory.Label('').Set('Class','adyen-dialog-item').Set('Id','adyen-amount');
        end else begin
          DialogAmount := Factory.Label(Format(ModelAmount,0,'<Precision,2:2><Standard Format,2>')).Set('Class','adyen-dialog-item').Set('Id','adyen-amount');
        end;
        DialogAmount.FontSize('');

        DialogForceAbortButton := Factory.Label(TXT_FORCE_ABORT).Set('Class','adyen-dialog-item').Set('Id','adyen-force-abort').SubscribeEvent('click');
        DialogForceAbortButton.Set('Visible', false);
        DialogForceAbortButton.FontSize('');

        DialogAbortButton := Factory.Label(TXT_ABORT).Set('Class', 'adyen-dialog-item').Set('Id', 'adyen-abort').SubscribeEvent('click');
        DialogAbortButton.FontSize('');

        Dialog.Append(
          DialogCaption,
          DialogAmount,
          Factory.Panel().Set('Class', 'adyen-dialog-item').Set('Id', 'adyen-spinner')
            .Append(
              Factory.Panel().Set('Id', 'adyen-spinner-inner1'),
              Factory.Panel().Set('Id', 'adyen-spinner-inner2'),
              Factory.Panel().Set('Id', 'adyen-spinner-inner3'),
              Factory.Panel().Set('Id', 'adyen-spinner-inner4')
            ),
          DialogForceAbortButton,
          DialogAbortButton
        );

        Dialog.Append(
          Factory.Label().Set('Visible', false).Set('Id', 'adyen-timer').SubscribeEvent('click')
        );

        Model.Append(Dialog);
    end;

    local procedure Javascript(): Text
    begin
        exit('setInterval(function() { $("#adyen-timer").click(); }, 1000);');
    end;

    local procedure GetCaption(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY then begin
          case EFTTransactionRequest."Auxiliary Operation ID" of
            2 :
              begin
                OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
                exit(Format(OriginalEFTTransactionRequest."Processing Type"));
              end;
            4 :
              begin
                exit(EFTTransactionRequest."Auxiliary Operation Desc.");
              end;
            5 :
              begin
                exit(EFTTransactionRequest."Auxiliary Operation Desc.");
              end;
          end;
        end;

        exit(Format(EFTTransactionRequest."Processing Type"));
    end;

    local procedure GetAmount(EFTTransactionRequest: Record "EFT Transaction Request"): Decimal
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY then
            if EFTTransactionRequest."Auxiliary Operation ID" = 2 then begin
                OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
                exit(OriginalEFTTransactionRequest."Amount Input");
            end;

        exit(EFTTransactionRequest."Amount Input");
    end;
}