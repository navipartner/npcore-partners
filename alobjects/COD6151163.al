codeunit 6151163 "MM Loyalty Points UI (Client)"
{
    // #341237/TSA /20190212 CASE 341237 Initial Version
    // MM1.38/TSA/20190527  CASE 338215-01 Transport MM1.38 - 27 May 2019

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Model: DotNet Model;
        ActiveModelID: Guid;
        TransactionEntryNo: Integer;
        TickAbortRequested: Integer;
        Ticks: Integer;
        Done: Boolean;
        AbortRequested: Boolean;
        AbortAttempts: Integer;
        TXT_ABORT: Label 'Abort';

    procedure ShowTransactionDialog(EFTTransactionRequest: Record "EFT Transaction Request";POSFrontEnd: Codeunit "POS Front End Management")
    begin

        Clear(Done);
        Clear(Ticks);
        Clear(TickAbortRequested);
        Clear(AbortRequested);
        Clear(AbortAttempts);
        TransactionEntryNo := EFTTransactionRequest."Entry No.";

        ConstructTransactionDialog(EFTTransactionRequest);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
    end;

    local procedure ConstructTransactionDialog(EFTTransactionRequest: Record "EFT Transaction Request")
    begin

        Model := Model.Model();
        Model.AddHtml(Html(EFTTransactionRequest));
        Model.AddStyle(Css());
        Model.AddScript(Javascript());
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnTransactionDialogResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;Sender: Text;EventName: Text;var Handled: Boolean)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        LoyaltyPointsPSPClient: Codeunit "MM Loyalty Points PSP (Client)";
    begin

        if ModelID <> ActiveModelID then
          exit;
        Handled := true;

        if Done then
          exit; //Event is late - we have already acted on a result.

        case Sender of
          'TransactionCheckResponse' :
            begin
              Ticks += 1;

              if (Ticks > 5) then begin
                FrontEnd.CloseModel(ActiveModelID);

                EFTTransactionRequest.Get (TransactionEntryNo);
                if (EFTTransactionRequest."Result Code" <> 0) then
                  LoyaltyPointsPSPClient.OnServiceRequestResponse (EFTTransactionRequest);

                Done := true;
              end;
            end;

          'TransactionRequestAbort' :
            begin
              EFTTransactionRequest.Get(TransactionEntryNo);

              if (((Ticks - TickAbortRequested) > 80) and (AbortAttempts > 3)) then begin
                //Allow force abort if 80 tickets (20 seconds) has passed since first abort attempt and we are above 3 attempts.
                // EFTAdyenCloudProtocol.ForceCloseTransaction(EFTTransactionRequest);
                FrontEnd.CloseModel(ActiveModelID);
                Done := true;

              end else begin
                AbortTransaction(EFTTransactionRequest);
                if not AbortRequested then begin
                  TickAbortRequested := Ticks;
                  AbortRequested := true;
                end;
              end;

              AbortAttempts += 1;
            end;
        end;
    end;

    local procedure Css(): Text
    begin
        exit(
        '.points-dialog {'+
        '  max-width: 17.5em;' +
        '  max-height: 20em;' +
        '  width: 70vw;'+
        '  height: 80vh;'+
        '  background: linear-gradient(#f4f4f4, #dedede);'+
        ' -webkit-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);'+
        ' -moz-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);'+
        ' box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);'+
        '  display: -webkit-box;'+
        '  display: -moz-box;'+
        '  display: -ms-flexbox;'+
        '  display: -webkit-flex;'+
        '  display: flex;'+
        '  flex-flow: column wrap;'+
        '  justify-content: space-around;'+
        '  align-items: center;' +
        '}'+
        '.points-dialog-item {  '+
        '  margin: auto;  '+
        '  font-weight: bold;  '+
        '  font-family: Helvetica, Verdana, Arial, sans-serif;' +
        '  text-align: center;'+
        '}'+
        '#points-caption { '+
        '  margin-bottom: 0.2em;  '+
        '  font-size: 1em;'+
        '  align-self: flex-start;' +
        '}'+
        '#points-amount { '+
        '  margin-top: 0.2em;  '+
        '  margin-bottom: 1em;  '+
        '  font-size: 2em;'+
        '  align-self: flex-start;' +
        '}'+
        '#points-status { '+
        '  font-size: 1em;'+
        '}'+
        '#points-abort { '+
        '  font-size: 1em;'+
        '  background: grey;'+
        '  border: none;'+
        '  height: 2.5em;'+
        '  width: 80%;'+
        '  align-self: flex-end;' +
        '}' +
        '#points-spinner {'+
        '  display: inline-block;'+
        '  position: relative;'+
        '  width: 64px;'+
        '  height: 64px;'+
        '}'+
        '#points-spinner div {'+
        '  box-sizing: border-box;'+
        '  display: block;'+
        '  position: absolute;'+
        '  width: 51px;'+
        '  height: 51px;'+
        '  margin: 6px;'+
        '  border: 6px solid #000000;'+
        '  border-radius: 50%;'+
        '  animation: points-spinner 1.6s cubic-bezier(0.5, 0, 0.5, 1) infinite;'+
        '  border-color: #000000 transparent transparent transparent;'+
        '}'+
        '#points-spinner div:nth-child(1) {'+
        '  animation-delay: -0.45s;'+
        '}'+
        '#points-spinner div:nth-child(2) {'+
        '  animation-delay: -0.3s;'+
        '}'+
        '#points-spinner div:nth-child(3) {'+
        '  animation-delay: -0.15s;'+
        '}'+
        '@keyframes points-spinner {'+
        '  0% {'+
        '    transform: rotate(0deg);'+
        '  }'+
        '  100% {'+
        '    transform: rotate(360deg);'+
        '  }'+
        '}');
    end;

    local procedure Html(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin

        exit(
        '<div class="points-dialog">' +
          '<span class="points-dialog-item" id="points-caption">' + Format(EFTTransactionRequest."Processing Type") + '</span>' +
          '<span class="points-dialog-item" id="points-amount">' + Format(EFTTransactionRequest."Amount Input",0,'<Precision,2:2><Standard Format,2>') + '</span>  ' +
          '<div class="points-dialog-item" id="points-spinner"><div></div><div></div><div></div><div></div></div>' +
          '<button class="points-dialog-item" id="points-abort" onclick=adyenAbort()>' + TXT_ABORT + '</button>' +
        '</div>');
    end;

    local procedure Javascript(): Text
    begin

        exit(
        'function adyenAbort() {' +
          'n$.respondExplicit("TransactionRequestAbort",{});' +
        '}' +

        'setInterval(function() { n$.respondExplicit("TransactionCheckResponse",{}); }, 250);');
    end;

    local procedure AbortTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
        EFTSetup: Record "EFT Setup";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
    begin

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        // EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 1, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        // AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        // AbortEFTTransactionRequest.MODIFY;
        Commit;
        // EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);

        if (POSSession.IsActiveSession (POSFrontEnd)) then
          if (POSFrontEnd.IsPaused) then
            POSFrontEnd.ResumeWorkflow ();
    end;

    trigger Model::OnModelControlEvent(control: DotNet Control;eventName: Text;data: DotNet Dictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}

