codeunit 6184482 "Pepper Trx Transaction"
{
    // NPR5.25/TSA/20160513  CASE 239285 Version up to 5.0.398.2
    // NPR5.26/TSA/20160809  CASE 248452 Assembly Version Up - JBAXI Support, General Improvements
    // NPR5.27/TSA/20161026  CASE 256388 Changed how refund dialog is presented to teller - from simple to not simple
    // NPR5.34/BR /20170608  CASE 268698 Added support for voiding refunds
    // NPR5.35/BR /20170815  CASE 284379 Added support for Cashback

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin

        ProcessSignal(Rec);
    end;

    var
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ExpectedResponseType: DotNet npNetType;
        ExpectedResponseId: Guid;
        ProtocolManagerId: Guid;
        ProtocolStage: Integer;
        QueuedRequests: DotNet npNetStack;
        QueuedResponseTypes: DotNet npNetStack;
        "--RequestSpecific": Integer;
        InitializedRequest: Boolean;
        TransactionRequest: DotNet npNetTransactionRequest;
        TransactionResponse: DotNet npNetTransactionResponse;
        LastRestCode: Integer;
        TrxResult: DotNet npNetTrxResult;
        NEGATIVE_NOT_ALLOWED: Label 'Negative amount %1 is not allowed in a Pepper capture transaction.';
        Labels: DotNet npNetProcessLabels;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions";

    local procedure "---Protocol functions"()
    begin
    end;

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet npNetSignal;
        StartSignal: DotNet npNetStartSession;
        QueryCloseSignal: DotNet npNetQueryClosePage;
        Response: DotNet npNetMessageResponse;
    begin

        POSDeviceProxyManager.DeserializeObject(Signal,TempBlob);
        case true of
          Signal.TypeName = Format(GetDotNetType(StartSignal)):
            begin
              QueuedRequests := QueuedRequests.Stack();
              QueuedResponseTypes := QueuedResponseTypes.Stack();

              POSDeviceProxyManager.DeserializeSignal(StartSignal,Signal);
              Start(StartSignal.ProtocolManagerId);
            end;
          Signal.TypeName = Format(GetDotNetType(Response)):
            begin
              POSDeviceProxyManager.DeserializeSignal(Response,Signal);
              MessageResponse(Response.Envelope);
            end;
          Signal.TypeName = Format(GetDotNetType(QueryCloseSignal)):
            if QueryClosePage() then
              POSDeviceProxyManager.AbortByUserRequest(ProtocolManagerId);
        end;
    end;

    local procedure Start(ProtocolManagerIdIn: Guid)
    var
        WebClientDependency: Record "Web Client Dependency";
        VoidResponse: DotNet npNetVoidResponse;
    begin

        ProtocolManagerId := ProtocolManagerIdIn;

         AwaitResponse(
           GetDotNetType(VoidResponse),
           POSDeviceProxyManager.SendMessage(
             ProtocolManagerId, TransactionRequest));
    end;

    local procedure MessageResponse(Envelope: DotNet npNetResponseEnvelope)
    begin

        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then
          Error('Unknown response type: %1 (expected %2)',Envelope.ResponseTypeName,Format(ExpectedResponseType));
    end;

    local procedure QueryClosePage(): Boolean
    begin

        exit(true);
    end;

    local procedure CloseProtocol()
    begin

        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    local procedure AwaitResponse(Type: DotNet npNetType;Id: Guid)
    begin

        ExpectedResponseType := Type;
        ExpectedResponseId := Id;
    end;

    local procedure "---Pepper_Transactions_Supported"()
    begin
    end;

    procedure InitializeProtocol()
    begin

        ClearAll();

        TransactionRequest := TransactionRequest.TransactionRequest ();
        TransactionResponse := TransactionResponse.TransactionResponse ();

        PepperTerminalCaptions.GetLabels (Labels);
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

    procedure SetReceiptEncoding(PepperEncodingName: Code[20];NavisionEncodingName: Code[20])
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
        TrxParam: DotNet npNetTrxParam;
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

        exit (10);
    end;

    procedure SetPaymentOfGoods(OriginalAmountInDecimal: Decimal;PepperAmountInCents: Integer;CashBackAmountInCents: Integer;Currency: Code[10];TrackPresence: Integer;CardInformation: Text[40];TrxRefNbr: Text[12];MbxPosRefNbr: Text[20];Offline: Boolean) SuccessCode: Integer
    var
        TrxParam: DotNet npNetTrxParam;
    begin
        if not InitializedRequest then
          InitializeProtocol();

        if (PepperAmountInCents < 0) then
          exit (-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        if (OriginalAmountInDecimal < 0) then
          exit (-998); //ERROR (NEGATIVE_NOT_ALLOWED, OriginalAmountInDecimal);

        //-NPR5.35 [284379]
        if (CashBackAmountInCents < 0) then
          exit (-998); //ERROR (NEGATIVE_NOT_ALLOWED, CashBackAmountInDecimal);
        //+NPR5.35 [284379]

        TrxParam := TrxParam.TrxParam();

        //-NPR5.22
        //TrxParam.TrxType := 10;
        if Offline then
          TrxParam.TrxType := 50
        else
          TrxParam.TrxType := 10;
        //+NPR5.22
        TrxParam.Amount := Format (PepperAmountInCents);
        //-NPR5.35 [284379]
        if CashBackAmountInCents <> 0 then begin
          TrxParam.XmlAdditionalParameters := StrSubstNo('<xml><CashBackAmount>%1</CashBackAmount></xml>',CashBackAmountInCents);
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

        exit (10);
    end;

    procedure SetVoidPaymentOfGoods(OriginalAmountInDecimal: Decimal;PepperAmountInCents: Integer;Currency: Code[10];TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet npNetTrxParam;
    begin
        if not InitializedRequest then
          InitializeProtocol();

        if (PepperAmountInCents < 0) then
          exit (-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        TrxParam := TrxParam.TrxParam();

        TrxParam.TrxType := 20;
        TrxParam.Amount := Format (PepperAmountInCents);
        TrxParam.Currency := Currency;
        TrxParam.TrxRefNbrIn := TrxRefNbr;

        TrxParam.TrackPresence := 0;
        TrxParam.CardInformation := '';
        TrxParam.MbxPosRefNbr := '';
        TrxParam.OriginalDecimalAmount := 0;

        TransactionRequest.TrxParam := TrxParam;
        TransactionRequest.SimpleProgressDialog := true;

        exit (10);
    end;

    procedure SetVoidRefund(OriginalAmountInDecimal: Decimal;PepperAmountInCents: Integer;Currency: Code[10];TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet npNetTrxParam;
    begin
        //-NPR5.34 [268698]
        if not InitializedRequest then
          InitializeProtocol();

        if (PepperAmountInCents < 0) then
          exit (-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        TrxParam := TrxParam.TrxParam();

        TrxParam.TrxType := 65;
        TrxParam.Amount := Format (PepperAmountInCents);
        TrxParam.Currency := Currency;
        TrxParam.TrxRefNbrIn := TrxRefNbr;

        TrxParam.TrackPresence := 0;
        TrxParam.CardInformation := '';
        TrxParam.MbxPosRefNbr := '';
        TrxParam.OriginalDecimalAmount := 0;

        TransactionRequest.TrxParam := TrxParam;
        TransactionRequest.SimpleProgressDialog := true;

        exit (10);
        //+NPR5.34 [268698]
    end;

    procedure SetRefund(OriginalAmountInDecimal: Decimal;PepperAmountInCents: Integer;Currency: Code[10];TrxRefNbr: Text[12]) SuccessCode: Integer
    var
        TrxParam: DotNet npNetTrxParam;
    begin
        if not InitializedRequest then
          InitializeProtocol();

        if (PepperAmountInCents < 0) then
          exit (-998); // ERROR (NEGATIVE_NOT_ALLOWED, PepperAmountInCents);

        TrxParam := TrxParam.TrxParam();

        TrxParam.TrxType := 60;
        TrxParam.Amount := Format (PepperAmountInCents);
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

        exit (10);
    end;

    local procedure "---Results"()
    begin
    end;

    procedure GetTrx_ResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
          exit (-999999);

        LastRestCode := TrxResult.ResultCode;
        exit (LastRestCode);
    end;

    procedure GetTrx_DisplayText() DisplayText: Text[40]
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (TrxResult.DisplayText);
    end;

    procedure GetTrx_CardInformation(var CardType: Text[4];var CardName: Text[24];var CardNumber: Text[30];var CardExpDate: Text[4])
    begin

        if (not InitializedRequest) then
          exit;

        CardType := TrxResult.CardType;
        CardName := TrxResult.CardName;
        CardNumber := TrxResult.CardNbr;
        CardExpDate := TrxResult.CardExpDate;
        exit;
    end;

    procedure GetTrx_AuthorizationInfo(var ReferenceNumber: Text[12];var TransactionDate: Text[8];var TransactionTime: Text[6];var AuthorizationNumber: Text[16];var TerminalID: Text[30];var ReceiptSignature: Option;var BookkeepingPeriod: Text[4])
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
        if (Evaluate (ReceiptSignature, Format(TrxResult.ReceiptSignature))) then ;
        BookkeepingPeriod := TrxResult.BookkeepPeriod;

        exit;
    end;

    procedure GetTrx_Amount() Amount: Integer
    begin

        if (not InitializedRequest) then
          exit (0);
        //-NPR5.22
        //EVALUATE (Amount, TrxResult.Amount);
        if not Evaluate (Amount, TrxResult.Amount) then
          Amount := 0;
        //+NPR5.22
        exit (Amount);
    end;

    procedure GetTrx_ReferralText() ReferralText: Text[20]
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (TrxResult.ReferralText);
    end;

    procedure GetTrx_JournalLevel() Level: Integer
    var
        tmpstr: Text;
    begin

        if (not InitializedRequest) then
          exit (0);

        tmpstr := TrxResult.JournalLevel;
        if (Evaluate (Level, tmpstr)) then;
        exit (Level);
    end;

    procedure GetTrx_CustomerReceipt() ReceiptText: Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (TransactionResponse.ReceiptOne);
    end;

    procedure GetTrx_MerchantReceipt() ReceiptText: Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (TransactionResponse.ReceiptTwo);
    end;

    local procedure "----"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 6014657, 'ProtocolEvent', '', false, false)]
    local procedure ProtocolEvent(ProtocolCodeunitID: Integer;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text)
    begin

        if (ProtocolCodeunitID <> CODEUNIT::"Pepper Trx Transaction") then
          exit;

        case EventName of
          'CloseForm':
            CloseForm(Data);
        end;
    end;

    local procedure CloseForm(Data: Text)
    begin

        TransactionResponse := TransactionResponse.Deserialize (Data);
        TrxResult := TransactionResponse.TrxResult;
        CloseProtocol ();
    end;
}

