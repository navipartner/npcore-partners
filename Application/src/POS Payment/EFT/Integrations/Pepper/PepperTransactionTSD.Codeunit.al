#if not CLOUD
codeunit 6184492 "NPR Pepper Transaction TSD"
{
    Access = Internal;
    // NPR5.30/TSA/20170123  CASE 263458 Refactored for Transcendence
    // NPR5.35/BR /20170815  CASE 284379 Added support for Cashback


    trigger OnRun()
    begin
    end;

    var
        InitializedRequest: Boolean;
        InitializedResponse: Boolean;
        TransactionRequest: DotNet NPRNetTransactionRequest0;
        TransactionResponse: DotNet NPRNetTransactionResponse0;
        LastRestCode: Integer;
        TrxResult: DotNet NPRNetTrxResult0;
        Labels: DotNet NPRNetProcessLabels0;
        PepperTerminalCaptions: Codeunit "NPR Pepper Term. Captions TSD";
        TrxIsAbandoned: Boolean;

    procedure InitializeProtocol()
    begin

        ClearAll();

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionResponse := TransactionResponse.TransactionResponse();

        PepperTerminalCaptions.GetLabels(Labels);
        TransactionRequest.ProcessLabels := Labels;

        LastRestCode := -999998;
        InitializedRequest := true;
        TransactionRequest.ShowPinPadStatusDialog := true;
    end;

    procedure SetTimout(TimeoutMillies: Integer)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        if (TimeoutMillies = 0) then
            TimeoutMillies := 15000;

        TransactionRequest.TimeoutMillies := TimeoutMillies;
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20]; NavisionEncodingName: Code[20])
    begin

        if not InitializedRequest then
            InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
            TransactionRequest.PepperReceiptEncoding := PepperEncodingName;

        // Default value is ISO-8859-1
        if (NavisionEncodingName <> '') then
            TransactionRequest.NavisionReceiptEncoding := NavisionEncodingName;
    end;

    procedure SetRecovery() SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam0;
    begin
        if not InitializedRequest then
            InitializeProtocol();

        TrxParam := TrxParam.TrxParam();

        TrxParam.TrxType := 0;
        TrxParam.Amount := '0';
        TrxParam.Currency := 'EUR';
        TrxParam.TrackPresence := 0;
        TrxParam.CardInformation := '';
        TrxParam.TrxRefNbrIn := '';
        TrxParam.MbxPosRefNbr := '';
        TrxParam.OriginalDecimalAmount := 0;

        TransactionRequest.TrxParam := TrxParam;
        TransactionRequest.SimpleProgressDialog := true;

        exit(-900); //Transaction not yet sent
    end;

    procedure SetPaymentOfGoods(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; CashBackAmountInCents: Integer; Currency: Code[10]; TrackPresence: Integer; CardInformation: Text[40]; TrxRefNbr: Text[12]; MbxPosRefNbr: Text[20]; Offline: Boolean) SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam0;
        XmlParamsLbl: Label '<xml><CashBackAmount>%1</CashBackAmount></xml>', Locked = true;
    begin
        if not InitializedRequest then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        if (OriginalAmountInDecimal < 0) then
            exit(-998); //ERROR (NEGATIVE_NOT_ALLOWED, OriginalAmountInDecimal);

        if (CashBackAmountInCents < 0) then
            exit(-998); //ERROR (NEGATIVE_NOT_ALLOWED, CashBackAmountInDecimal);

        TrxParam := TrxParam.TrxParam();

        if Offline then
            TrxParam.TrxType := 50
        else
            TrxParam.TrxType := 10;

        TrxParam.Amount := Format(PepperAmountInCents);

        if CashBackAmountInCents <> 0 then begin
            TrxParam.XmlAdditionalParameters := StrSubstNo(XmlParamsLbl, CashBackAmountInCents);
        end;

        TrxParam.Currency := Currency;
        TrxParam.TrackPresence := TrackPresence;
        TrxParam.CardInformation := CardInformation;
        TrxParam.TrxRefNbrIn := TrxRefNbr;
        TrxParam.MbxPosRefNbr := MbxPosRefNbr;
        TrxParam.OriginalDecimalAmount := OriginalAmountInDecimal;

        TransactionRequest.TrxParam := TrxParam;
        TransactionRequest.SimpleProgressDialog := false;

        exit(-910); //Transaction not yet sent
    end;

    procedure SetVoidPaymentOfGoods(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; Currency: Code[10]; TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam0;
    begin
        if not InitializedRequest then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        TrxParam := TrxParam.TrxParam();

        TrxParam.TrxType := 20;
        TrxParam.Amount := Format(PepperAmountInCents);
        TrxParam.Currency := Currency;
        TrxParam.TrxRefNbrIn := TrxRefNbr;

        TrxParam.TrackPresence := 0;
        TrxParam.CardInformation := '';
        TrxParam.MbxPosRefNbr := '';
        TrxParam.OriginalDecimalAmount := 0;

        TransactionRequest.TrxParam := TrxParam;
        TransactionRequest.SimpleProgressDialog := true;

        exit(-920); //Transaction not yet sent
    end;

    procedure SetRefund(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; Currency: Code[10]; TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam0;
    begin
        if not InitializedRequest then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        TrxParam := TrxParam.TrxParam();

        TrxParam.TrxType := 60;
        TrxParam.Amount := Format(PepperAmountInCents);
        TrxParam.Currency := Currency;
        TrxParam.TrxRefNbrIn := TrxRefNbr;

        TrxParam.TrackPresence := 0;
        TrxParam.CardInformation := '';
        TrxParam.MbxPosRefNbr := '';

        // TrxParam.OriginalDecimalAmount := 0;
        TrxParam.OriginalDecimalAmount := OriginalAmountInDecimal * -1; //-+NPR5.27 [256388]

        TransactionRequest.TrxParam := TrxParam;

        // TransactionRequest.SimpleProgressDialog := TRUE;
        TransactionRequest.SimpleProgressDialog := false; //-+NPR5.27 [256388]

        exit(-960); //Transaction not yet sent
    end;

    procedure GetTrx_ResultCode() ResultCode: Integer
    begin

        if (not InitializedResponse) then
            exit(-999999);

        LastRestCode := TrxResult.ResultCode;
        exit(LastRestCode);
    end;

    procedure GetTrx_DisplayText() DisplayText: Text[40]
    begin

        if (not InitializedResponse) then
            exit('');

        exit(TrxResult.DisplayText);
    end;

    procedure GetTrx_CardInformation(var CardType: Text[4]; var CardName: Text[24]; var CardNumber: Text[30]; var CardExpDate: Text[4])
    begin

        if (not InitializedResponse) then
            exit;

        CardType := TrxResult.CardType;
        CardName := TrxResult.CardName;
        CardNumber := TrxResult.CardNbr;
        CardExpDate := TrxResult.CardExpDate;
        exit;
    end;

    procedure GetTrx_AuthorizationInfo(var ReferenceNumber: Text[12]; var TransactionDate: Text[8]; var TransactionTime: Text[6]; var AuthorizationNumber: Text[16]; var TerminalID: Text[30]; var ReceiptSignature: Option; var BookkeepingPeriod: Text[4])
    begin

        if (not InitializedResponse) then
            exit;

        ReferenceNumber := TrxResult.TrxRefNbrOut;
        TransactionDate := TrxResult.TrxDate;
        TransactionTime := TrxResult.TrxTime;
        AuthorizationNumber := TrxResult.AuthNbr;
        TerminalID := TrxResult.TerminalId;
        if (Evaluate(ReceiptSignature, Format(TrxResult.ReceiptSignature))) then;
        BookkeepingPeriod := TrxResult.BookkeepPeriod;

        exit;
    end;

    procedure GetTrx_Amount() Amount: Integer
    begin

        if (not InitializedResponse) then
            exit(0);

        if not Evaluate(Amount, TrxResult.Amount) then
            Amount := 0;

        exit(Amount);
    end;

    procedure GetTrx_ReferralText() ReferralText: Text[20]
    begin

        if (not InitializedResponse) then
            exit('');

        exit(TrxResult.ReferralText);
    end;

    procedure GetTrx_JournalLevel() Level: Integer
    var
        tmpstr: Text;
    begin

        if (not InitializedResponse) then
            exit(0);

        tmpstr := TrxResult.JournalLevel;
        if (Evaluate(Level, tmpstr)) then;
        exit(Level);
    end;

    procedure GetTrx_CustomerReceipt() ReceiptText: Text
    begin

        if (not InitializedResponse) then
            exit('');

        exit(TransactionResponse.ReceiptOne);
    end;

    procedure GetTrx_MerchantReceipt() ReceiptText: Text
    begin

        if (not InitializedResponse) then
            exit('');

        exit(TransactionResponse.ReceiptTwo);
    end;

    procedure GetTrx_AbandonedTransaction() IsAbandoned: Boolean
    begin

        exit(TrxIsAbandoned);
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if not InitializedRequest then
            InitializeProtocol();

        TransactionRequest.RequestEntryNo := EntryNo;
    end;

    procedure InvokeDevice(var FrontEnd: Codeunit "NPR POS Front End Management"; var POSSession: Codeunit "NPR POS Session")
    begin

        FrontEnd.InvokeDevice(TransactionRequest, 'Pepper_EftTrx', 'EftTrx');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnDeviceResponse', '', false, false)]
    local procedure OnDeviceResponse(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin

        if (ActionName <> 'Pepper_EftTrx') then
            exit;

        // Pepper has a VOID response. Actual Return Data is on the CloseForm Event
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        TrxParam: DotNet NPRNetTrxParam0;
    begin

        if (ActionName <> 'Pepper_EftTrx') then
            exit;

        //IF (CONFIRM ('Event %1 %2 %3 - HelloTime was: %4', TRUE, ActionName, EventName, ResponseRequired, HelloTime)) THEN ERROR ('stop');
        Handled := true;

        case EventName of
            'AbandonedTransactionResponse':
                begin
                    if (Data <> '') then begin
                        TransactionResponse := TransactionResponse.Deserialize(Data);
                        TrxResult := TransactionResponse.TrxResult;
                        // TrxParam := TransactionResponse.TrxParam;

                        InitializedResponse := true;

                        EFTTransactionRequest.Get(TransactionResponse.RequestEntryNo);
                        EFTTransactionRequest."Entry No." := 0;
                        EFTTransactionRequest."Initiated from Entry No." := TransactionResponse.RequestEntryNo;

                        EFTTransactionRequest."Pepper Trans. Subtype Code" := Format(TrxParam.TrxType);
                        EFTTransactionRequest."Reference Number Input" := TrxParam.TrxRefNbrIn;
                        EFTTransactionRequest."Amount Input" := TrxParam.OriginalDecimalAmount;

                        TrxIsAbandoned := true;
                        EFTTransactionRequest.Insert();
                        Commit();
                        OnTransactionReponse(EFTTransactionRequest."Entry No.");
                    end;
                    ReturnData := '';

                end;
            'CloseForm':
                begin
                    TransactionResponse := TransactionResponse.Deserialize(Data);
                    TrxResult := TransactionResponse.TrxResult;
                    InitializedResponse := true;

                    EFTTransactionRequest.Get(TransactionResponse.RequestEntryNo);
                    OnTransactionReponse(EFTTransactionRequest."Entry No.");
                end;
        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnTransactionReponse(EFTPaymentRequestID: Integer)
    begin
    end;
}
#endif
