codeunit 6184524 "EFT ISMP Baxi Protocol"
{
    // NPR5.51/CLVA/20190805 CASE 364011 Created object
    // NPR5.53/CLVA/20191029 CASE 374331 Added support for Android

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for %1 payment. ';
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        EntryNo: Integer;
        EFTISMPBaxiIntegration: Codeunit "EFT ISMP Baxi Integration";
        TransactionDone: Boolean;
        ModelAmount: Decimal;
        TXT_ABORT: Label 'Abort';
        Ticks: Integer;
        ErrorCurrencyIsNotDefined: Label 'Currency is not defined in %1';
        CloseOnIdle: Boolean;
        TransactionNo: Integer;
        TickAbortRequested: Integer;
        AbortRequested: Boolean;
        AbortAttempts: Integer;
        ErrorText: Text;
        TimeoutRequested: Boolean;

    procedure IntegrationType(): Text
    begin
        exit('ISMPBAXI');
    end;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request")
    begin
        InitState(EftTransactionRequest);

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::PAYMENT:
                StartPaymentTransaction(EftTransactionRequest); //Via async dialog & background session
        end;
    end;

    local procedure InitState(EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        Clear(Model);
        Clear(ActiveModelID);
        Clear(EntryNo);
        Clear(EFTISMPBaxiIntegration);
        Clear(TransactionDone);
        Clear(Ticks);
        Clear(CloseOnIdle);
        Clear(TransactionNo);
        Clear(ErrorText);
        Clear(TimeoutRequested);

        ModelAmount := GetAmount(EFTTransactionRequest);
    end;

    local procedure StartPaymentTransaction(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        EFTISMPBaxiIntegration: Codeunit "EFT ISMP Baxi Integration";
        EFTISMPBaxiTrxDialog: Codeunit "EFT ISMP Baxi Trx Dialog";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION, IntegrationType());

        EntryNo := EftTransactionRequest."Entry No.";
        EFTISMPBaxiIntegration.InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");
        if not EFTISMPBaxiIntegration.PaymentStart(EftTransactionRequest) then begin
            HandleProtocolError(POSFrontEnd);
            exit;
        end;

        //EFTISMPBaxiTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
        ConstructTransactionDialog(EftTransactionRequest);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
    end;

    local procedure HandleProtocolError(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        ErrorText: Text;
    begin
        TransactionDone := true;
        ErrorText := StrSubstNo(ProtocolError, IntegrationType(), GetLastErrorText);

        EFTTransactionRequest.Get(EntryNo);
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        if not IsNullGuid(ActiveModelID) then
            FrontEnd.CloseModel(ActiveModelID);

        OnAfterProtocolResponse(EFTTransactionRequest);
        Message(ErrorText);
    end;

    local procedure "// Dialog"()
    begin
    end;

    local procedure ConstructTransactionDialog(EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        Model := Model.Model();
        Html(EFTTransactionRequest);
        Model.AddStyle(Css());
        Model.AddScript(Javascript(EFTTransactionRequest));
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
    begin
        Dialog := Factory.Panel().Set('Class', 'adyen-dialog');
        Dialog.FontSize('');

        DialogCaption := Factory.Label(GetCaption(EFTTransactionRequest)).Set('Class', 'adyen-dialog-item').Set('Id', 'adyen-caption');
        DialogCaption.FontSize('');

        DialogAmount := Factory.Label(Format(ModelAmount, 0, '<Precision,2:2><Standard Format,2>')).Set('Class', 'adyen-dialog-item').Set('Id', 'adyen-amount');
        DialogAmount.FontSize('');

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
          DialogAbortButton,
          Factory.Label().Set('Visible', false).Set('Id', 'adyen-timer').SubscribeEvent('click')
        );

        Model.Append(Dialog);
    end;

    local procedure Javascript(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        JSScript: Text;
        Json: Text;
    begin
        JSScript := 'setInterval(function() { $("#adyen-timer").click(); }, 1000);';
        //JSScript += 'mpos.setWindowsId(window.name);';
        //-NPR5.53 [361955]
        //JSScript += 'mpos.startEFTTransaction('+PaymentRequest(EFTTransactionRequest)+');';
        Json := PaymentRequest(EFTTransactionRequest);
        JSScript += 'var userAgent = navigator.userAgent || navigator.vendor || window.opera; if (/android/i.test(userAgent)) { ';
        JSScript += 'window.top.mpos.handleEFTBackendMessage('+Json+'); } ';
        JSScript += 'if (/iPad|iPhone|iPod|Macintosh/.test(userAgent) && !window.MSStream) { ';
        JSScript += 'mpos.startEFTTransaction('+Json+');}';
        //+NPR5.53 [361955]
        exit(JSScript);

        //EXIT('setInterval(function() { $("#adyen-timer").click(); }, 250);');
    end;

    local procedure GetCaption(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY then
            if EFTTransactionRequest."Auxiliary Operation ID" = 2 then begin
                OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
                exit(Format(OriginalEFTTransactionRequest."Processing Type"));
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

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    var
        WebClientDependency: Record "Web Client Dependency";
        ModelIDVar: Variant;
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTInterface: Codeunit "EFT Interface";
    begin
        if ModelID <> ActiveModelID then
            exit;
        Handled := true;

        if TransactionDone then //The event is late, we have already acted on a result.
            exit;

        case Sender of
            'adyen-abort':
                RequestAbort(FrontEnd);
            'adyen-timer':
                CheckResponse(POSSession, FrontEnd);
        end;
    end;

    local procedure RequestAbort(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTISMPBaxiIntegration: Codeunit "EFT ISMP Baxi Integration";
        JSScript: Text;
    begin
        if (Ticks < 3) then
            exit;

        if not CloseOnIdle then begin
          //-NPR5.53 [361955]
          //Model.AddScript('mpos.abortTransaction(window.name);');
          JSScript += 'var userAgent = navigator.userAgent || navigator.vendor || window.opera; if (/android/i.test(userAgent)) { ';
          JSScript += 'window.top.mpos.handleEFTAbortBackendMessage(window.name); } ';
          JSScript += 'if (/iPad|iPhone|iPod|Macintosh/.test(userAgent) && !window.MSStream) { ';
          JSScript += 'mpos.abortTransaction(window.name);}';
          Model.AddScript(JSScript);
          //-NPR5.53 [361955]

            FrontEnd.UpdateModel(Model, ActiveModelID);
        end;

        EFTTransactionRequest.Get(EntryNo);

        if (CloseOnIdle and (EFTTransactionRequest."Result Code" = 2)) or (((Ticks - TickAbortRequested) > 5) and (AbortAttempts > 3)) then begin
            TransactionDone := true;
          EFTTransactionRequest."External Result Known" := true;
            FrontEnd.CloseModel(ActiveModelID);
            Clear(ActiveModelID);
            OnAfterProtocolResponse(EFTTransactionRequest);
        end else begin
            if not AbortRequested then begin
                TickAbortRequested := Ticks;
                AbortRequested := true;
            end;
        end;

        //Add timeout code
        //Add abort attemp

        CloseOnIdle := true;
        AbortAttempts += 1;
    end;

    local procedure CheckResponse(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        EFTISMPBaxiIntegration: Codeunit "EFT ISMP Baxi Integration";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        Ticks += 1;

        EFTTransactionRequest.Get(EntryNo);

        if not EFTISMPBaxiIntegration.GetPaymentStatus(EFTTransactionRequest, TransactionNo) then begin
            HandleProtocolError(FrontEnd);
            exit;
        end;

        if (EFTTransactionRequest.Successful) or (EFTTransactionRequest."Result Code" > 0) then begin
            TransactionDone := true;
          EFTTransactionRequest."External Result Known" := true;
            FrontEnd.CloseModel(ActiveModelID);
            Clear(ActiveModelID);
            if EFTTransactionRequest."Result Code" > 1 then
                ErrorText := EFTTransactionRequest."Result Description";
            OnAfterProtocolResponse(EFTTransactionRequest);
            if ErrorText <> '' then
                Message(ErrorText);
        end else begin
            //Add status lable
            //PaymentStatus := EFTTransactionRequest."Result Description";
            //Model.GetControlById('imgStatus').Set('Source',WebClientDependency.GetDataUri(STRSUBSTNO('MBP-%1',EFTTransactionRequest."Result Code")));
            //Model.GetControlById('lb-status').Set('Caption',PaymentStatus);
            //FrontEnd.UpdateModel(Model, ActiveModelID);
        end;

        if Ticks > 80 then begin
            if not TimeoutRequested then begin
                Model.AddScript('mpos.abortTransaction(window.name);');
                FrontEnd.UpdateModel(Model, ActiveModelID);
                TimeoutRequested := true;
            end;
        end;
    end;

    local procedure "// Api"()
    begin
    end;

    local procedure PaymentRequest(EFTTransactionRequest: Record "EFT Transaction Request") JSON: Text
    var
        MPOSAppSetup: Record "MPOS App Setup";
        BaxiAmount: Decimal;
        BaxiTransTypeId: Integer;
        BaxiAmountInCents: Integer;
        BaxiCurrency: Code[10];
        InAppPrinting: Integer;
        EFTSetup: Record "EFT Setup";
        MerchantID: Text;
        MPOSNetsTransactions: Record "MPOS Nets Transactions";
        BigTextVar: BigText;
        Ostream: OutStream;
    begin
        MPOSAppSetup.Get(EFTTransactionRequest."Register No.");

        MPOSAppSetup.TestField(Enable, true);
        MPOSAppSetup.TestField("Payment Gateway");

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");
        MerchantID := GetMerchantID(EFTSetup);

        if MPOSAppSetup."Handle EFT Print in NAV" then
            InAppPrinting := 0
        else
            InAppPrinting := 1;

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::REFUND:
                begin
                    BaxiAmount := EFTTransactionRequest."Amount Input" * -1;
                    BaxiAmountInCents := BaxiAmount * 100;
                    BaxiTransTypeId := 49;
                end;
            EFTTransactionRequest."Processing Type"::PAYMENT:
                begin
                    BaxiAmount := EFTTransactionRequest."Amount Input";
                    BaxiAmountInCents := BaxiAmount * 100;
                    BaxiTransTypeId := 48;
                end;
        end;

        BaxiCurrency := GetCurrencyCode(EFTTransactionRequest."Currency Code");

        MPOSNetsTransactions.Init;
        MPOSNetsTransactions."Register No." := EFTTransactionRequest."Register No.";
        MPOSNetsTransactions."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        MPOSNetsTransactions."Sales Line No." := EFTTransactionRequest."Sales Line No.";
        MPOSNetsTransactions."Session Id" := EFTTransactionRequest."Reference Number Input";
        MPOSNetsTransactions."Created Date" := CurrentDateTime;
        MPOSNetsTransactions."Currency Code" := BaxiCurrency;
        MPOSNetsTransactions."Merchant Reference" := EFTTransactionRequest."Reference Number Input";

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::REFUND:
                MPOSNetsTransactions."Transaction Type" := MPOSNetsTransactions."Transaction Type"::REFUND;
            EFTTransactionRequest."Processing Type"::PAYMENT:
                MPOSNetsTransactions."Transaction Type" := MPOSNetsTransactions."Transaction Type"::PAY;
        end;

        MPOSNetsTransactions."Transaction Type Id" := BaxiTransTypeId;
        MPOSNetsTransactions.Amount := BaxiAmount;
        MPOSNetsTransactions."Payment Amount In Cents" := BaxiAmountInCents;
        MPOSNetsTransactions."Payment Gateway" := MPOSAppSetup."Payment Gateway";
        MPOSNetsTransactions."Merchant Id" := MerchantID;
        MPOSNetsTransactions."EFT Transaction Entry No." := EFTTransactionRequest."Entry No.";
        MPOSNetsTransactions.Insert(true);

        TransactionNo := MPOSNetsTransactions."Transaction No.";

        JSON := '{ "mPosRequest" : [{ "debug":"false" , "eft":"0" , "amount":"'
                      + Format(BaxiAmountInCents)
                      + '", "currency":"' + BaxiCurrency
                      + '", "reference":"' + EFTTransactionRequest."Reference Number Input"
                      + '", "inappprinting":"' + Format(InAppPrinting)
                      + '", "transactionType":"' + Format(BaxiTransTypeId)
                      + '", "paymentGateWay":"' + MPOSAppSetup."Payment Gateway"
                      + '", "transactionNo":"' + Format(TransactionNo)
                      + '","merchantId":"' + MerchantID + '" }]}';

        BigTextVar.AddText(JSON);
        MPOSNetsTransactions."Request Json".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);

        MPOSNetsTransactions.Modify(true);

        exit(JSON);
    end;

    local procedure GetCurrencyCode(SalesLineCurrencyCode: Code[10]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if SalesLineCurrencyCode <> '' then
            exit(SalesLineCurrencyCode);

        GeneralLedgerSetup.Get;
        if GeneralLedgerSetup."LCY Code" <> '' then
            exit(GeneralLedgerSetup."LCY Code");

        Error(ErrorCurrencyIsNotDefined, GeneralLedgerSetup.TableName);
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure GetMerchantID(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Merchant ID', '', true));
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
    end;

}

