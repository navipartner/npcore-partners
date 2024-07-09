#pragma warning disable AA0139
codeunit 6184478 "NPR Pepper Transaction HWC"
{
    Access = Internal;

    var
        _LastResultCode: Integer;
        _Envelope: JsonObject;
        _Transaction: JsonObject;
        _TrxResult: JsonObject;
        _InitializedRequest: Boolean;
        _InitializedResponse: Boolean;
        _AdditionalParameters: Text;


    procedure InitializeProtocol()
    var
        PepperTerminalCaptions: Codeunit "NPR Pepper Terminal Captions";
        PepperLabels: JsonObject;
    begin

        ClearAll();
        _Envelope.ReadFrom('{}');
        _Envelope.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_PEPPER_TRX));
        _Envelope.Add('HwcName', 'EFTPepper');

        PepperTerminalCaptions.GetLabels(PepperLabels);

        _Envelope.Add('Type', 'Transaction');
        _Envelope.Add('Captions', PepperLabels);

        _LastResultCode := -999998;
        _InitializedRequest := true;
    end;

    procedure AssembleHwcRequest(): JsonObject
    var
        AdditionalParameters: Text;
        XmlWrapperText: Label '<xml>%1</xml>';
    begin

        if (_Transaction.Contains('AdditionalParameters')) then
            AdditionalParameters := AsText(_Transaction, 'AdditionalParameters', 0);

        if (_AdditionalParameters <> '') then
            AdditionalParameters += _AdditionalParameters;

        if (AdditionalParameters <> '') then
            _Transaction.Add('XmlAdditionalParameters', StrSubstNo(XmlWrapperText, AdditionalParameters));

        _Envelope.Add('TransactionRequest', _Transaction);
        exit(_Envelope)
    end;

    procedure SetTimeout(TimeoutMilliSeconds: Integer)
    begin

        if (not _InitializedRequest) then
            InitializeProtocol();

        if (TimeoutMilliSeconds = 0) then
            TimeoutMilliSeconds := 15000;

        _Envelope.Add('Timeout', TimeoutMilliSeconds);
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20])
    begin

        if (not _InitializedRequest) then
            InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
            _Envelope.Add('PepperReceiptEncoding', PepperEncodingName);
    end;

    procedure SetHwcVerboseLogLevel()
    begin
        _Envelope.Add('LogLevel', 'Verbose');
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        IStream: InStream;
    begin

        if (not _InitializedRequest) then
            InitializeProtocol();

        _Envelope.Add('EntryNo', EntryNo);

        EFTTransactionRequest.SetAutoCalcFields("Additional Info");
        EFTTransactionRequest.Get(EntryNo);

        if (EFTTransactionRequest."Additional Info".HasValue()) then begin
            EFTTransactionRequest."Additional Info".CreateInStream(IStream);
            IStream.ReadText(_AdditionalParameters);
        end;

    end;

    procedure SetRecovery() SuccessCode: Integer
    begin
        if (not _InitializedRequest) then
            InitializeProtocol();

        _Transaction.Add('TrxType', 0);
        _Transaction.Add('Amount', '0');
        _Transaction.Add('Currency', 'EUR');
        _Transaction.Add('TrackPresence', 0);
        _Transaction.Add('CardInformation', '');
        _Transaction.Add('TrxRefNbrIn', '');
        _Transaction.Add('MbxPosRefNbr', '');
        _Transaction.Add('OriginalDecimalAmount', 0);

        exit(-900); //Transaction not yet sent
    end;

    procedure SetPaymentOfGoods(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; CashBackAmountInCents: Integer; Currency: Code[10]; TrackPresence: Integer; CardInformation: Text[40]; TrxRefNbr: Text[12]; MbxPosRefNbr: Text[20]; Offline: Boolean) SuccessCode: Integer
    var
        XmlParamsLbl: Label '<CashBackAmount>%1</CashBackAmount>', Locked = true;
    begin
        if (not _InitializedRequest) then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // Error (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        if (OriginalAmountInDecimal < 0) then
            exit(-998); //Error (NEGATIVE_NOT_ALLOWED, OriginalAmountInDecimal);

        if (CashBackAmountInCents < 0) then
            exit(-998); //Error (NEGATIVE_NOT_ALLOWED, CashBackAmountInDecimal);

        if (Offline) then
            _Transaction.Add('TrxType', 50)
        else
            _Transaction.Add('TrxType', 10);

        _Transaction.Add('Amount', Format(PepperAmountInCents));

        if (CashBackAmountInCents <> 0) then begin
            _Transaction.Add('AdditionalParameters', StrSubstNo(XmlParamsLbl, CashBackAmountInCents));
        end;

        _Transaction.Add('Currency', Currency);
        _Transaction.Add('TrackPresence', TrackPresence);
        _Transaction.Add('CardInformation', CardInformation);
        _Transaction.Add('TrxRefNbrIn', TrxRefNbr);
        _Transaction.Add('MbxPosRefNbr', MbxPosRefNbr);
        _Transaction.Add('OriginalDecimalAmount', OriginalAmountInDecimal);

        exit(-910); //Transaction not yet sent
    end;

    procedure SetVoidPaymentOfGoods(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; Currency: Code[10]; TrxRefNbr: Text[12]) SuccessCode: Integer
    var
    begin
        if (not _InitializedRequest) then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // Error (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        _Transaction.Add('TrxType', 20);
        _Transaction.Add('Amount', Format(PepperAmountInCents));
        _Transaction.Add('Currency', Currency);
        _Transaction.Add('TrxRefNbrIn', TrxRefNbr);

        _Transaction.Add('TrackPresence', 0);
        _Transaction.Add('CardInformation', '');
        _Transaction.Add('MbxPosRefNbr', '');
        _Transaction.Add('OriginalDecimalAmount', 0);

        exit(-920); //Transaction not yet sent
    end;

    procedure SetRefund(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; Currency: Code[10]; TrxRefNbr: Text[12]) SuccessCode: Integer
    begin
        if (not _InitializedRequest) then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // Error (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        _Transaction.Add('TrxType', 60);
        _Transaction.Add('Amount', Format(PepperAmountInCents));
        _Transaction.Add('Currency', Currency);
        _Transaction.Add('TrxRefNbrIn', TrxRefNbr);

        _Transaction.Add('TrackPresence', 0);
        _Transaction.Add('CardInformation', '');
        _Transaction.Add('MbxPosRefNbr', '');

        _Transaction.Add('OriginalDecimalAmount', OriginalAmountInDecimal * -1);

        exit(-960); //Transaction not yet sent
    end;

    #region Response
    procedure SetResponse(HwcResponse: JsonObject)
    begin

        // Lets blow up on invalid response
        _LastResultCode := AsInteger(HwcResponse, 'ResultCode');
        _Transaction := AsObject(HwcResponse, 'TransactionResponse');
        _TrxResult := AsObject(_Transaction, 'TrxResult');

        _InitializedResponse := true;
    end;

    procedure GetTrx_ResultCode() ResultCode: Integer
    begin
        if (not _InitializedResponse) then
            exit(-999999);

        exit(_LastResultCode);
    end;

    procedure GetTrx_DisplayText() DisplayText: Text[40]
    begin

        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_TrxResult, 'DisplayText', MaxStrLen(DisplayText)));
    end;

    procedure GetTrx_CardInformation(var CardType: Text[4]; var CardName: Text[24]; var CardNumber: Text[30]; var CardExpDate: Text[4])
    begin

        if (not _InitializedResponse) then
            exit;

        CardType := AsText(_TrxResult, 'CardType', MaxStrLen(CardType));
        CardName := AsText(_TrxResult, 'CardName', MaxStrLen(CardName));
        CardNumber := AsText(_TrxResult, 'CardNbr', MaxStrLen(CardNumber));
        CardExpDate := AsText(_TrxResult, 'CardExpDate', MaxStrLen(CardExpDate));
        exit;
    end;

    procedure GetTrx_AuthorizationInfo(var ReferenceNumber: Text[12]; var TransactionDate: Text[8]; var TransactionTime: Text[6]; var AuthorizationNumber: Text[16]; var TerminalID: Text[30]; var ReceiptSignature: Option; var BookkeepingPeriod: Text[4])
    begin

        if (not _InitializedResponse) then
            exit;

        ReferenceNumber := AsText(_TrxResult, 'TrxRefNbrOut', MaxStrLen(ReferenceNumber));
        TransactionDate := AsText(_TrxResult, 'TrxDate', MaxStrLen(TransactionDate));
        TransactionTime := AsText(_TrxResult, 'TrxTime', MaxStrLen(TransactionTime));
        AuthorizationNumber := AsText(_TrxResult, 'AuthNbr', MaxStrLen(AuthorizationNumber));
        TerminalID := AsText(_TrxResult, 'TerminalId', MaxStrLen(TerminalID));
        if (Evaluate(ReceiptSignature, Format(AsInteger(_TrxResult, 'ReceiptSignature')))) then;
        BookkeepingPeriod := AsText(_TrxResult, 'BookkeepPeriod', MaxStrLen(BookkeepingPeriod));

        exit;
    end;

    procedure GetTrx_Amount() Amount: Integer
    begin
        if (not _InitializedResponse) then
            exit(0);

        if (not Evaluate(Amount, AsText(_TrxResult, 'Amount', 0))) then
            Amount := 0;

        exit(Amount);
    end;

    procedure GetTrx_ReferralText(var ReferralText: Text[20]): Boolean
    begin
        if (not _InitializedResponse) then
            exit(false);

        ReferralText := AsText(_TrxResult, 'ReferralText', MaxStrLen(ReferralText));
        Exit(ReferralText <> '');
    end;

    procedure GetTrx_JournalLevel(Level: Text[10]): Boolean
    begin
        if (not _InitializedResponse) then
            exit(false);

        Level := AsText(_TrxResult, 'JournalLevel', MaxStrLen(Level));
        exit(Level <> '');
    end;

    procedure GetTrx_CustomerReceipt() ReceiptText: Text
    begin
        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_Transaction, 'ReceiptOne', 0));
    end;

    procedure GetTrx_MerchantReceipt() ReceiptText: Text
    begin
        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_Transaction, 'ReceiptTwo', 0));
    end;

    procedure GetTrx_AdditionalParameters(var AdditionalParameter: Text): Boolean
    begin
        if (not _InitializedResponse) then
            exit(false);

        AdditionalParameter := AsText(_TrxResult, 'AdditionalParameters', 0);
        if (AdditionalParameter = '') then
            exit(false);

        exit(not (StrPos(AdditionalParameter, '<xml></xml>') > 0));
    end;

    [Obsolete('Not required', '2023-06-28')]
    procedure GetTrx_AbandonedTransaction() IsAbandoned: Boolean
    begin
    end;

    #endregion

    #region jsonHelpers
    local procedure AsObject(JObject: JsonObject; KeyName: Text): JsonObject
    var
        JToken: JsonToken;
    begin
        JObject.Get(KeyName, JToken);
        exit(JToken.AsObject());
    end;

    local procedure AsInteger(JObject: JsonObject; KeyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        JObject.Get(KeyName, JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure AsText(JObject: JsonObject; KeyName: Text; MaxLength: Integer): Text
    var
        JToken: JsonToken;
        Result: Text;
        OverflowError: Label 'The key "%1" has a max length of %2, but the value "%3" is %4.';
    begin
        JObject.Get(KeyName, JToken);
        Result := JToken.AsValue().AsText();
        if ((MaxLength > 0) and (StrLen(Result) > MaxLength)) then
            Error(OverflowError, KeyName, MaxLength, Result, StrLen(Result));

        exit(Result);
    end;
    #endregion
}
