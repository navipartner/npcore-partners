codeunit 6184520 "NPR EFT Adyen Cloud Sign Dia."
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object
    // NPR5.49/MMV /20190410 CASE 347476 Increased signature line width

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Model: DotNet NPRNetModel;
        ActiveModelID: Guid;
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for EFT payment. ';
        TransactionEntryNo: Integer;
        Done: Boolean;
        SignatureData: Text;
        SIGNATURE_VERIFICATION: Label 'Signature Verification';
        APPROVE: Label 'Approve';
        DECLINE: Label 'Decline';

    procedure SetSignatureData(EFTTransactionRequest: Record "NPR EFT Transaction Request"; SignatureDataIn: Text)
    begin
        TransactionEntryNo := EFTTransactionRequest."Entry No.";
        SignatureData := SignatureDataIn;
    end;

    procedure ApproveSignature(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
    begin
        //This function depend on global state SignatureData being stored from transaction response.
        if EFTTransactionRequest."Entry No." <> TransactionEntryNo then
            Error('Stored signature for entry %1 is out of sync with entry %2. This is a programming bug, not a user error', TransactionEntryNo, EFTTransactionRequest."Entry No.");

        if SignatureData = '' then
            Error('Missing signature data for entry %1. This is a programming bug, not a user error', TransactionEntryNo);

        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION);

        CreateSignatureApprovalDialog(EFTTransactionRequest);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
    end;

    local procedure CreateSignatureApprovalDialog(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        Model := Model.Model();
        Model.AddHtml(HTML());
        Model.AddStyle(CSS());
        Model.AddScript(Javascript());
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnSignatureDialogResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    var
        Confirmed: Boolean;
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if ModelID <> ActiveModelID then
            exit;
        Handled := true;

        case Sender of
            'SignatureResponse':
                begin
                    FrontEnd.CloseModel(ActiveModelID);
                    Evaluate(Confirmed, EventName, 9);

                    if not Confirmed then begin
                        EFTTransactionRequest.Get(TransactionEntryNo);
                        EFTAdyenCloudIntegration.VoidTransactionAfterSignatureDecline(EFTTransactionRequest);
                    end else
                        FrontEnd.ResumeWorkflow();
                end;
        end;
    end;

    local procedure CSS(): Text
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
        ' box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);' +
        '  display: -webkit-box;' +
        '  display: -moz-box;' +
        '  display: -ms-flexbox;' +
        '  display: -webkit-flex;' +
        '  display: flex;' +
        '  flex-flow: column wrap;' +
        '  justify-content: space-around;' +
        '  align-items: center;' +
        '}' +
        '#adyen-caption { ' +
        '  font-size: 1em;' +
        '  align-self: flex-start;' +
        '  margin: auto;' +
        '  margin-top: 0.6em;' +
        '  margin-bottom: 0.3em;' +
        '  font-weight: bold;' +
        '  font-family: Helvetica, Verdana, Arial, sans-serif;' +
        '  text-align: center;' +
        '}' +
        '#adyen-signatureCanvas {' +
        '  padding: 0.4em;' +
        '  border: 1px solid black;' +
        '  width: 90%;' +
        '  margin: 0px;' +
        '}' +
        '.adyen-dialog-button { ' +
        '  font-size: 1em;' +
        '  background: grey;' +
        '  border: none;' +
        '  height: 2em;' +
        '  width: 80%;' +
        '  margin: auto;' +
        '  margin-top: 0.3em;' +
        '  margin-bottom: 0.3em;' +
        '  font-weight: bold;' +
        '  font-family: Helvetica, Verdana, Arial, sans-serif;' +
        '  text-align: center;' +
        '  align-self: flex-end;' +
        '}');
    end;

    local procedure HTML(): Text
    begin
        exit(
        '<div class="adyen-dialog">' +
          '<span id="adyen-caption">' + SIGNATURE_VERIFICATION + '</span>' +
          '<canvas id="adyen-signatureCanvas"></canvas>' +
          '<button class="adyen-dialog-button" onclick=adyenSignatureResponse(true)>' + APPROVE + '</button>' +
          '<button class="adyen-dialog-button" onclick=adyenSignatureResponse(false)>' + DECLINE + '</button>' +
        '</div>');
    end;

    local procedure Javascript(): Text
    begin
        exit(
        'function adyenSignatureResponse(approved) {' +
          'n$.respondExplicit("SignatureResponse", approved);' +
        '};' +

        /*
        'var capturedSignature = { ' +
          '"SignaturePoint": [' +
            '{"x": "32","y": "46"},' +
            '{"x": "C8","y": "3C"},' +
            '{"x": "A","y": "50"},' +
            '{"x": "20","y": "1E"},' +
            '{"x": "FFFF","y": "FFFF"}' +
          ']      ' +
        '};
        */

        'function drawAdyenSignature() {' +
          'var capturedSignature = ' + SignatureData + ';' +

          'var canvas = document.getElementById(''adyen-signatureCanvas'');' +
          'canvas.setAttribute(''width'', canvas.style.width);' +
          'canvas.setAttribute(''height'', canvas.style.height);' +

          'if (canvas.getContext) {' +
            'var ctx = canvas.getContext(''2d'');' +
        //-NPR5.49 [347476]
            'ctx.lineWidth = 3;' +
            //+NPR5.49 [347476]

            'if (capturedSignature.SignaturePoint.length > 1)' +
            '{' +
              'ctx.beginPath();' +
              'var firstDot = null;' +

              'for (i = 0; i < capturedSignature.SignaturePoint.length; i++)' +
              '{' +
                'var xPoint = parseInt(capturedSignature.SignaturePoint[i].X, 16);' +
                'var yPoint = parseInt(capturedSignature.SignaturePoint[i].Y, 16);' +

                'if (xPoint !== 65535 || yPoint !== 65535) {' +
                  'if (!firstDot) {' +
                    'ctx.moveTo(xPoint,yPoint);' +
                    'firstDot = true;' +
                  '}' +
                  'else {' +
                    'ctx.lineTo(xPoint,yPoint);' +
                  '}' +
                '}' +
                'else {' +
                  'firstDot = null;' +
                '}' +

              '}' +
              'ctx.stroke();' +
            '}' +
          '}' +
        '}' +

        'drawAdyenSignature();');

    end;
}