// TODO: CTRLUPGRADE - this codeunit is remnants after removing old Proxy Manager stargate v1 stuff - INVESTIGATE!

codeunit 6184482 "NPR Pepper Trx Transaction"
{
    // NPR5.25/TSA/20160513  CASE 239285 Version up to 5.0.398.2
    // NPR5.26/TSA/20160809  CASE 248452 Assembly Version Up - JBAXI Support, General Improvements
    // NPR5.27/TSA/20161026  CASE 256388 Changed how refund dialog is presented to teller - from simple to not simple
    // NPR5.34/BR /20170608  CASE 268698 Added support for voiding refunds
    // NPR5.35/BR /20170815  CASE 284379 Added support for Cashback

    SingleInstance = true;

    var
        InitializedRequest: Boolean;
        TransactionRequest: DotNet NPRNetTransactionRequest;
        TransactionResponse: DotNet NPRNetTransactionResponse;
        LastRestCode: Integer;
        TrxResult: DotNet NPRNetTrxResult;
        Labels: DotNet NPRNetProcessLabels;
        PepperTerminalCaptions: Codeunit "NPR Pepper Terminal Captions";

    procedure InitializeProtocol()
    begin

        ClearAll();

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionResponse := TransactionResponse.TransactionResponse();

        PepperTerminalCaptions.GetLabels(Labels);
        TransactionRequest.ProcessLabels := Labels;

        LastRestCode := -999998;
        InitializedRequest := true;
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
        TrxParam: DotNet NPRNetTrxParam;
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

        exit(10);
    end;

    procedure SetPaymentOfGoods(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; CashBackAmountInCents: Integer; Currency: Code[10]; TrackPresence: Integer; CardInformation: Text[40]; TrxRefNbr: Text[12]; MbxPosRefNbr: Text[20]; Offline: Boolean) SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam;
    begin
        if not InitializedRequest then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        if (OriginalAmountInDecimal < 0) then
            exit(-998); //ERROR (NEGATIVE_NOT_ALLOWED, OriginalAmountInDecimal);

        //-NPR5.35 [284379]
        if (CashBackAmountInCents < 0) then
            exit(-998); //ERROR (NEGATIVE_NOT_ALLOWED, CashBackAmountInDecimal);
        //+NPR5.35 [284379]

        TrxParam := TrxParam.TrxParam();

        //-NPR5.22
        //TrxParam.TrxType := 10;
        if Offline then
            TrxParam.TrxType := 50
        else
            TrxParam.TrxType := 10;
        //+NPR5.22
        TrxParam.Amount := Format(PepperAmountInCents);
        //-NPR5.35 [284379]
        if CashBackAmountInCents <> 0 then begin
            TrxParam.XmlAdditionalParameters := StrSubstNo('<xml><CashBackAmount>%1</CashBackAmount></xml>', CashBackAmountInCents);
        end;
        //+NPR5.35 [284379]
        TrxParam.Currency := Currency;
        TrxParam.TrackPresence := TrackPresence;
        TrxParam.CardInformation := CardInformation;
        TrxParam.TrxRefNbrIn := TrxRefNbr;
        TrxParam.MbxPosRefNbr := MbxPosRefNbr;
        TrxParam.OriginalDecimalAmount := OriginalAmountInDecimal;

        TransactionRequest.TrxParam := TrxParam;
        TransactionRequest.SimpleProgressDialog := false;

        exit(10);
    end;

    procedure SetVoidPaymentOfGoods(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; Currency: Code[10]; TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam;
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

        exit(10);
    end;

    procedure SetVoidRefund(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; Currency: Code[10]; TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam;
    begin
        //-NPR5.34 [268698]
        if not InitializedRequest then
            InitializeProtocol();

        if (PepperAmountInCents < 0) then
            exit(-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        TrxParam := TrxParam.TrxParam();

        TrxParam.TrxType := 65;
        TrxParam.Amount := Format(PepperAmountInCents);
        TrxParam.Currency := Currency;
        TrxParam.TrxRefNbrIn := TrxRefNbr;

        TrxParam.TrackPresence := 0;
        TrxParam.CardInformation := '';
        TrxParam.MbxPosRefNbr := '';
        TrxParam.OriginalDecimalAmount := 0;

        TransactionRequest.TrxParam := TrxParam;
        TransactionRequest.SimpleProgressDialog := true;

        exit(10);
        //+NPR5.34 [268698]
    end;

    procedure SetRefund(OriginalAmountInDecimal: Decimal; PepperAmountInCents: Integer; Currency: Code[10]; TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet NPRNetTrxParam;
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

        exit(10);
    end;

    procedure GetTrx_ResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
            exit(-999999);

        LastRestCode := TrxResult.ResultCode;
        exit(LastRestCode);
    end;

    procedure GetTrx_DisplayText() DisplayText: Text[40]
    begin

        if (not InitializedRequest) then
            exit('');

        exit(TrxResult.DisplayText);
    end;

    procedure GetTrx_CardInformation(var CardType: Text[4]; var CardName: Text[24]; var CardNumber: Text[30]; var CardExpDate: Text[4])
    begin

        if (not InitializedRequest) then
            exit;

        CardType := TrxResult.CardType;
        CardName := TrxResult.CardName;
        CardNumber := TrxResult.CardNbr;
        CardExpDate := TrxResult.CardExpDate;
        exit;
    end;

    procedure GetTrx_AuthorizationInfo(var ReferenceNumber: Text[12]; var TransactionDate: Text[8]; var TransactionTime: Text[6]; var AuthorizationNumber: Text[16]; var TerminalID: Text[30]; var ReceiptSignature: Option; var BookkeepingPeriod: Text[4])
    var
        tmpstr: Text;
    begin

        if (not InitializedRequest) then
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

        if (not InitializedRequest) then
            exit(0);
        //-NPR5.22
        //EVALUATE (Amount, TrxResult.Amount);
        if not Evaluate(Amount, TrxResult.Amount) then
            Amount := 0;
        //+NPR5.22
        exit(Amount);
    end;

    procedure GetTrx_CustomerReceipt() ReceiptText: Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(TransactionResponse.ReceiptOne);
    end;

    procedure GetTrx_MerchantReceipt() ReceiptText: Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(TransactionResponse.ReceiptTwo);
    end;
}

