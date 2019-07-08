codeunit 6184518 "EFT Adyen Cloud Protocol"
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // 
    // https://docs.adyen.com/developers/point-of-sale/build-your-integration/terminal-api-integration-overview
    // 
    // NPR5.49/MMV /20190219 CASE 345188 Handle void of recovered transactions correctly.
    //                                   Don't throw exceptions when checking response document optional elements.
    // NPR5.49/MMV /20190409 CASE 351678 Check response via codeunit.run instead of tryfunction
    // NPR5.49/MMV /20190410 CASE 347476 Added request/response logging support
    // NPR5.50/MMV /20190429 CASE 353340 Removed modify within TryFunction when logging.
    // NPR5.50/MMV /20190516 CASE 355433 Increased abort request timeout

    SingleInstance = true;
    TableNo = "EFT Transaction Request";

    trigger OnRun()
    begin
        BackgroundServiceInvoke(Rec);
    end;

    var
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for %1 payment. ';
        ERROR_INVOKE: Label 'Error: Service endpoint responded with HTTP status %1';
        ERROR_WS_SESSION: Label 'Error: Could not start background session for Adyen webservice invoke';
        ERROR_RECEIPT: Label 'Error: Could not create terminal receipt data';
        ERROR_HEADER_CATEGORY: Label 'Error: Header category %1, expected %2';
        VOID_SUCCESS: Label 'Transaction %1 was successfully voided';
        VOID_FAILURE: Label 'Transaction %1 could not be voided: %2\%3';
        DIAGNOSE: Label 'Terminal Status: %1\Terminal Connection: %2\Host Connection: %3';
        UNKNOWN: Label 'Unknown';

    local procedure IntegrationType(): Text
    begin
        exit('ADYEN_CLOUD');
    end;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request")
    begin
        // All the request types that show a front-end dialog while waiting for terminal customer interaction, are asynchronous using STARTSESSION to perform a long timeout webservice request.
        // (See OnRun trigger of this codeunit).
        // The POS user session will poll a table until a response record appears or timeout is reached.
        // The reason is that Adyens transaction API requires concurrent requests which a single user session does not support in pure C/AL.

        case EftTransactionRequest."Processing Type" of
          EftTransactionRequest."Processing Type"::Payment : StartPaymentTransaction(EftTransactionRequest); //Via async dialog & background session
          EftTransactionRequest."Processing Type"::Refund : StartRefundTransaction(EftTransactionRequest); //Via async dialog & background session
          EftTransactionRequest."Processing Type"::Void : VoidTransaction(EftTransactionRequest); //Via blocking ws invoke
          EftTransactionRequest."Processing Type"::Lookup : LookupTransaction(EftTransactionRequest); //Via blocking ws invoke
          EftTransactionRequest."Processing Type"::Setup : SetupTerminal(EftTransactionRequest); //Via blocking ws invoke
          EftTransactionRequest."Processing Type"::Auxiliary :
            case EftTransactionRequest."Auxiliary Operation ID" of
              1 : AbortTransaction(EftTransactionRequest); //via blocking ws invoke
        //-NPR5.49 [345188]
              2 : StartAcquireCard(EftTransactionRequest); //Via async dialog & background session
              3 : AbortAcquireCard(EftTransactionRequest); //via blocking ws invoke
        //+NPR5.49 [345188]
            end;
        end;
    end;

    local procedure "// Operations"()
    begin
    end;

    local procedure StartPaymentTransaction(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        SessionId: Integer;
        EFTAdyenCloudTrxDialog: Codeunit "EFT Adyen Cloud Trx Dialog";
        EFTSetup: Record "EFT Setup";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        AcquireCardRequest: Record "EFT Transaction Request";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_SESSION, IntegrationType());

        if not StartSession(SessionId, CODEUNIT::"EFT Adyen Cloud Protocol", CompanyName, EftTransactionRequest) then
          Error(ERROR_WS_SESSION);

        //-NPR5.49 [345188]
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        if EFTAdyenCloudIntegration.GetAcquireCardFirst(EFTSetup) then
          if GetLinkedCardAcquisition(EftTransactionRequest, AcquireCardRequest) then
            exit; //Dialog already open
        //+NPR5.49 [345188]

        EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndPaymentTransaction(var EftTransactionRequest: Record "EFT Transaction Request";Response: Text)
    var
        tmpCreditCardTransaction: Record "Credit Card Transaction" temporary;
    begin
        if ParsePaymentTransaction(Response, EftTransactionRequest, tmpCreditCardTransaction) then begin
          if CreateReceiptData(EftTransactionRequest, tmpCreditCardTransaction) then
            EftTransactionRequest."External Result Received" := true
          else
            EftTransactionRequest."NST Error" := CopyStr(ERROR_RECEIPT, 1, MaxStrLen(EftTransactionRequest."NST Error"));
        end else
          EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));

        EftTransactionRequest.Successful := EftTransactionRequest.Successful and EftTransactionRequest."External Result Received";

        if EftTransactionRequest.Successful then
          EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output";

        //-NPR5.49 [347476]
        ClearLogAfterResult(EftTransactionRequest);
        //+NPR5.49 [347476]
        EftTransactionRequest.Modify;

        //-NPR5.49 [345188]
        OnAfterProtocolResponse(EftTransactionRequest);
        //+NPR5.49 [345188]
    end;

    local procedure StartRefundTransaction(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        SessionId: Integer;
        Response: Text;
        EFTAdyenCloudTrxDialog: Codeunit "EFT Adyen Cloud Trx Dialog";
        EFTSetup: Record "EFT Setup";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        AcquireCardRequest: Record "EFT Transaction Request";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_SESSION, IntegrationType());

        if not StartSession(SessionId, CODEUNIT::"EFT Adyen Cloud Protocol", CompanyName, EftTransactionRequest) then
          Error(ERROR_WS_SESSION);

        //-NPR5.49 [345188]
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        if EFTAdyenCloudIntegration.GetAcquireCardFirst(EFTSetup) then
          if GetLinkedCardAcquisition(EftTransactionRequest, AcquireCardRequest) then
            exit; //Dialog already open
        //+NPR5.49 [345188]

        EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndRefundTransaction(var EftTransactionRequest: Record "EFT Transaction Request";Response: Text)
    var
        tmpCreditCardTransaction: Record "Credit Card Transaction" temporary;
    begin
        if ParsePaymentTransaction(Response, EftTransactionRequest, tmpCreditCardTransaction) then begin
          if CreateReceiptData(EftTransactionRequest, tmpCreditCardTransaction) then
             EftTransactionRequest."External Result Received" := true
          else
            EftTransactionRequest."NST Error" := CopyStr(ERROR_RECEIPT, 1, MaxStrLen(EftTransactionRequest."NST Error"));
        end else
          EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));

        EftTransactionRequest.Successful := EftTransactionRequest.Successful and EftTransactionRequest."External Result Received";

        if EftTransactionRequest.Successful then
          EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output" * -1;

        //-NPR5.49 [347476]
        ClearLogAfterResult(EftTransactionRequest);
        //+NPR5.49 [347476]
        EftTransactionRequest.Modify;

        //-NPR5.49 [345188]
        OnAfterProtocolResponse(EftTransactionRequest);
        //+NPR5.49 [345188]
    end;

    local procedure VoidTransaction(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        Response: Text;
        EFTSetup: Record "EFT Setup";
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        //-NPR5.49 [345188]
        if OriginalEFTTransactionRequest.Recovered then
          OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Recovered by Entry No.");
        //+NPR5.49 [345188]

        if InvokeVoid(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, Response) then
          if ParseVoidTransaction(Response, EftTransactionRequest) then
            EftTransactionRequest."External Result Received" := true;

        if not EftTransactionRequest."External Result Received" then
          EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));

        EftTransactionRequest.Successful := EftTransactionRequest.Successful and EftTransactionRequest."External Result Received";

        if EftTransactionRequest.Successful then
          EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Input";

        //-NPR5.49 [347476]
        ClearLogAfterResult(EftTransactionRequest);
        //+NPR5.49 [347476]
        EftTransactionRequest.Modify;
        OnAfterProtocolResponse(EftTransactionRequest);
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "EFT Transaction Request")
    var
        Response: Text;
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        EFTSetup: Record "EFT Setup";
        tmpCreditCardTransaction: Record "Credit Card Transaction" temporary;
    begin
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        //Delete any unprocessed async responses that might be hanging, since we are now re-querying adyens backend for the truth.
        if EFTTransactionAsyncResponse.Get(OriginalEFTTransactionRequest."Entry No.") then
          EFTTransactionAsyncResponse.Delete;

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if InvokeLookup(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, Response) then
          if ParseStatusTransaction(Response, EftTransactionRequest, tmpCreditCardTransaction) then
            if CreateReceiptData(EftTransactionRequest, tmpCreditCardTransaction) then
              EftTransactionRequest."External Result Received" := true;

        if not EftTransactionRequest."External Result Received" then
          EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));

        EftTransactionRequest.Successful := EftTransactionRequest.Successful and EftTransactionRequest."External Result Received";

        if EftTransactionRequest.Successful then
          EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output";

        //-NPR5.49 [347476]
        ClearLogAfterResult(EftTransactionRequest);
        //+NPR5.49 [347476]
        EftTransactionRequest.Modify;
        OnAfterProtocolResponse(EftTransactionRequest);
    end;

    local procedure SetupTerminal(EftTransactionRequest: Record "EFT Transaction Request")
    var
        Response: Text;
        MessageString: Text;
        EFTSetup: Record "EFT Setup";
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if InvokeDiagnoseTerminal(EftTransactionRequest, EFTSetup, Response) then
          if ParseDiagnoseTransaction(Response, EftTransactionRequest) then
            EftTransactionRequest."External Result Received" := true;

        if not EftTransactionRequest."External Result Received" then
          EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));

        EftTransactionRequest.Successful := EftTransactionRequest."External Result Received";
        //-NPR5.49 [347476]
        ClearLogAfterResult(EftTransactionRequest);
        //+NPR5.49 [347476]
        EftTransactionRequest.Modify;
        OnAfterProtocolResponse(EftTransactionRequest);
    end;

    procedure AbortTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTSetup: Record "EFT Setup";
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(OriginalEFTTransactionRequest."Register No.", OriginalEFTTransactionRequest."Original POS Payment Type Code");

        if InvokeAbortTransaction(EFTTransactionRequest, EFTSetup) then begin
          EFTTransactionRequest."External Result Received" := true;
          EFTTransactionRequest.Successful := true;
        end else
          EFTTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));

        //-NPR5.49 [347476]
        ClearLogAfterResult(EFTTransactionRequest);
        //+NPR5.49 [347476]
        EFTTransactionRequest.Modify;
    end;

    procedure ForceCloseTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        EFTTransactionRequest."Force Closed" := true;
        EFTTransactionRequest.Modify;

        OnAfterProtocolResponse(EFTTransactionRequest);
    end;

    local procedure StartAcquireCard(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        SessionId: Integer;
        EFTAdyenCloudTrxDialog: Codeunit "EFT Adyen Cloud Trx Dialog";
    begin
        //-NPR5.49 [345188]
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_SESSION, IntegrationType());

        if not StartSession(SessionId, CODEUNIT::"EFT Adyen Cloud Protocol", CompanyName, EftTransactionRequest) then
          Error(ERROR_WS_SESSION);

        EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
        //+NPR5.49 [345188]
    end;

    local procedure EndAcquireCard(EftTransactionRequest: Record "EFT Transaction Request";Response: Text)
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        //-NPR5.49 [345188]
        if ParseCardAcquisition(Response, EftTransactionRequest) then
          EftTransactionRequest."External Result Received" := true
        else
          EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));

        EftTransactionRequest.Successful := EftTransactionRequest.Successful and EftTransactionRequest."External Result Received";
        //-NPR5.49 [347476]
        ClearLogAfterResult(EftTransactionRequest);
        //+NPR5.49 [347476]
        EftTransactionRequest.Modify;

        if not EftTransactionRequest.Successful then begin
          OriginalEFTTransactionRequest.Get(EftTransactionRequest."Initiated from Entry No.");
          OriginalEFTTransactionRequest.Recoverable := false; //Since AcquireCard failed we know the primary transaction "failed correctly" since we never started it.
          OriginalEFTTransactionRequest."Result Description" := EftTransactionRequest."Result Description";
          OriginalEFTTransactionRequest."Result Display Text" := EftTransactionRequest."Result Display Text";
          OriginalEFTTransactionRequest.Modify;

          OnAfterProtocolResponse(OriginalEFTTransactionRequest);
        end;
        //+NPR5.49 [345188]
    end;

    local procedure AbortAcquireCard(EftTransactionRequest: Record "EFT Transaction Request")
    var
        Response: Text;
        EFTSetup: Record "EFT Setup";
    begin
        //-NPR5.49 [345188]
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if InvokeAbortAcquireCard(EftTransactionRequest, EFTSetup, Response) then
          if ParseAbortAcquireCard(Response, EftTransactionRequest) then
            EftTransactionRequest."External Result Received" := true;

        if not EftTransactionRequest."External Result Received" then
          EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));

        EftTransactionRequest.Successful := EftTransactionRequest.Successful and EftTransactionRequest."External Result Received";
        //-NPR5.49 [347476]
        ClearLogAfterResult(EftTransactionRequest);
        //+NPR5.49 [347476]
        EftTransactionRequest.Modify;
        //+NPR5.49 [345188]
    end;

    local procedure "// API"()
    begin
    end;

    local procedure BackgroundServiceInvoke(EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
        EFTAdyenCloudBackground: Codeunit "EFT Adyen Cloud Backgnd. Req.";
    begin
        ClearLastError;

        if not EFTAdyenCloudBackground.Run(EftTransactionRequest) then begin
          EFTTransactionAsyncResponse.Init;
          EFTTransactionAsyncResponse.Error := true;
          EFTTransactionAsyncResponse."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionAsyncResponse."Error Text"));
          EFTTransactionAsyncResponse.Insert;
        end;
    end;

    [TryFunction]
    procedure InvokePayment(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";var Response: Text)
    var
        Body: Text;
        JsonConvert: DotNet npNetJsonConvert;
    begin
        Body :=
        '{' +
           '"SaleToPOIRequest":{' +
              '"MessageHeader":{' +
                 '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") + ',' +
                 '"MessageClass":"Service",' +
                 '"MessageCategory":"Payment",' +
                 '"MessageType":"Request",' +
                 '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
                 '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
                 '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") +
              '},' +
              '"PaymentRequest":{' +
                 '"SaleData":{' +
                    '"SaleToAcquirerData":"' + GetSaleToAcquirerData(EftTransactionRequest, EFTSetup) + '",' +
                    '"SaleTransactionID":{' +
                       '"TransactionID":' + JsonConvert.ToString(EftTransactionRequest."Sales Ticket No.") + ',' +
                       '"TimeStamp":"' + GetDateTime() + '"' +
                    '},' +
                    '"SaleReferenceID":' + JsonConvert.ToString(EftTransactionRequest.Token) +
                 '},' +
                 '"PaymentTransaction":{' +
                    '"AmountsReq":{' +
                       '"Currency":' + JsonConvert.ToString(EftTransactionRequest."Currency Code") + ',' +
                       '"RequestedAmount":' + GetAmount(EftTransactionRequest) + ',' +
                       '"CashBackAmount":' + GetCashbackAmount(EftTransactionRequest) +
                    '}' +
                    GetTransactionConditions(EftTransactionRequest, EFTSetup) +
        //-NPR5.49 [345188]
        //         '}' +
                 '},' +
                 '"PaymentData":{' +
                    GetCardAcquisitionJSON(EftTransactionRequest) +
                 '}' +
        //+NPR5.49 [345188]
              '}' +
           '}' +
        '}';

        //-NPR5.49 [347476]
        //Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 600 * 1000);
        Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 600 * 1000, EftTransactionRequest);
        //+NPR5.49 [347476]
    end;

    [TryFunction]
    procedure InvokeRefund(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";var Response: Text)
    var
        JsonConvert: DotNet npNetJsonConvert;
        Body: Text;
    begin
        Body :=
        '{' +
           '"SaleToPOIRequest":{' +
              '"MessageHeader":{' +
                 '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
                 '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") + ',' +
                 '"MessageCategory":"Payment",' +
                 '"MessageType":"Request",' +
                 '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
                 '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") + ',' +
                 '"MessageClass":"Service"' +
              '},' +
              '"PaymentRequest":{' +
                 '"SaleData":{' +
                    '"SaleToAcquirerData":"' + GetSaleToAcquirerData(EftTransactionRequest, EFTSetup) + '",' +
                    '"SaleTransactionID":{' +
                       '"TimeStamp":"' + GetDateTime + '",' +
                       '"TransactionID":' + JsonConvert.ToString(EftTransactionRequest."Sales Ticket No.") + '' +
                    '},' +
                    '"SaleReferenceID":' + JsonConvert.ToString(EftTransactionRequest.Token) +
                 '},' +
                 '"PaymentTransaction":{' +
                    GetTransactionConditions(EftTransactionRequest, EFTSetup) +
                    '"AmountsReq":{' +
                       '"Currency":' + JsonConvert.ToString(EftTransactionRequest."Currency Code") + ',' +
                       '"RequestedAmount":' + GetAmount(EftTransactionRequest) +
                    '}' +
                 '},' +
                 '"PaymentData":{' +
        //-NPR5.49 [345188]
        //            '"PaymentType":"Refund"' +
                    '"PaymentType":"Refund",' +
                    GetCardAcquisitionJSON(EftTransactionRequest) +
        //+NPR5.49 [345188]
                 '}' +
              '}' +
           '}' +
        '}';

        //-NPR5.49 [347476]
        //Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 600 * 1000);
        Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 600 * 1000, EftTransactionRequest);
        //+NPR5.49 [347476]
    end;

    [TryFunction]
    local procedure InvokeVoid(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";OriginalEFTTransactionRequest: Record "EFT Transaction Request";var Response: Text)
    var
        JsonConvert: DotNet npNetJsonConvert;
        Body: Text;
    begin
        Body :=
        '{' +
           '"SaleToPOIRequest":{' +
              '"MessageHeader":{' +
                 '"MessageClass":"Service",' +
                 '"MessageType":"Request",' +
                 '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") + ',' +
                 '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
                 '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") + ',' +
                 '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
                 '"MessageCategory":"Reversal"' +
              '},' +
              '"ReversalRequest":{' +
                 '"OriginalPOITransaction":{' +
                    '"POITransactionID":{' +
                       '"TimeStamp":"' + GetDateTime() + '",' +
                       '"TransactionID":' + JsonConvert.ToString(OriginalEFTTransactionRequest."Reference Number Output") + '' +
                    '}' +
                 '},' +
                 '"ReversalReason":"MerchantCancel"' +
              '}' +
           '}' +
        '}';

        //-NPR5.49 [347476]
        //Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 20 * 1000);
        Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 20 * 1000, EftTransactionRequest);
        //+NPR5.49 [347476]
    end;

    [TryFunction]
    local procedure InvokeAbortTransaction(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup")
    var
        JsonConvert: DotNet npNetJsonConvert;
        Body: Text;
    begin
        Body :=
        '{' +
            '"SaleToPOIRequest":{' +
                '"AbortRequest":{' +
                    '"AbortReason":"MerchantAbort",' +
                    '"MessageReference":{' +
                        '"ServiceID":"' + JsonConvert.ToString(EftTransactionRequest."Processed Entry No.") + '",' +
        //-NPR5.49 [345188]
        //                '"MessageCategory":"Payment"' +
                          '"MessageCategory":"' + GetAbortMessageCategory(EftTransactionRequest) + '"' +
        //+NPR5.49 [345188]
                    '}' +
                '},' +
                '"MessageHeader":{' +
                    '"MessageType":"Request",' +
                    '"MessageCategory":"Abort",' +
                    '"MessageClass":"Service",' +
                    '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
                    '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
                    '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") + ',' +
                    '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") +
                '}' +
            '}' +
        '}';

        //-NPR5.50 [355433]
        //Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 5 * 1000, EftTransactionRequest);
        Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 10 * 1000, EftTransactionRequest);
        //+NPR5.50 [355433]
    end;

    [TryFunction]
    procedure InvokeAcquireCard(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";var Response: Text)
    var
        JsonConvert: DotNet npNetJsonConvert;
        Body: Text;
    begin
        //-NPR5.49 [345188]
        Body :=
         '{' +
           '"SaleToPOIRequest":{' +
             '"MessageHeader":{' +
                    '"MessageType":"Request",' +
                    '"MessageCategory":"CardAcquisition",' +
                    '"MessageClass":"Service",' +
                    '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
                    '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
                    '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") + ',' +
                    '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") +
                '},' +
              '"CardAcquisitionRequest":{' +
                 '"SaleData":{' +
                    '"SaleTransactionID":{' +
                       '"TimeStamp":"' + GetDateTime + '",' +
                       '"TransactionID":' + JsonConvert.ToString(EftTransactionRequest."Sales Ticket No.") +
                    '}' +
                 '},' +
                 '"CardAcquisitionTransaction":{}' +
              '}' +
           '}' +
        '}';

        //-NPR5.49 [347476]
        //Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 600 * 1000);
        Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 600 * 1000, EftTransactionRequest);
        //+NPR5.49 [347476]
        //+NPR5.49 [345188]
    end;

    [TryFunction]
    local procedure InvokeAbortAcquireCard(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";var Response: Text)
    var
        Body: Text;
        JsonConvert: DotNet npNetJsonConvert;
    begin
        //-NPR5.49 [345188]
        Body :=
         '{' +
           '"SaleToPOIRequest":{' +
             '"MessageHeader":{' +
                    '"MessageType":"Request",' +
                    '"MessageCategory":"EnableService",' +
                    '"MessageClass":"Service",' +
                    '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
                    '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
                    '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") + ',' +
                    '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") +
                '},' +
              '"EnableServiceRequest":{' +
                 '"TransactionAction":"AbortTransaction"' +
              '}' +
           '}' +
        '}';

        //-NPR5.49 [347476]
        //Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 5 * 1000);
        Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 5 * 1000, EftTransactionRequest);
        //+NPR5.49 [347476]
        //+NPR5.49 [345188]
    end;

    [TryFunction]
    local procedure InvokeLookup(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";OriginalEftTransactionRequest: Record "EFT Transaction Request";var Response: Text)
    var
        JsonConvert: DotNet npNetJsonConvert;
        Body: Text;
    begin
        Body :=
        '{' +
          '"SaleToPOIRequest":{' +
            '"MessageHeader":{' +
              '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") + ',' +
              '"MessageClass":"Service",' +
              '"MessageCategory":"TransactionStatus",' +
              '"MessageType":"Request",' +
              '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
              '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
              '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") + '' +
            '},' +
            '"TransactionStatusRequest":{' +
              '"DocumentQualifier" : [' +
                '"CashierReceipt",' +
                '"CustomerReceipt"' +
              '],' +
              '"ReceiptReprintFlag":true,' +
              '"MessageReference":{' +
                '"MessageCategory":"' + GetLookupCategory(OriginalEftTransactionRequest) + '",' +
                '"SaleID":' + JsonConvert.ToString(OriginalEftTransactionRequest."Register No.") + ',' +
                '"ServiceID":' + JsonConvert.ToString(OriginalEftTransactionRequest."Reference Number Input") + '' +
              '}' +
            '}' +
          '}' +
        '}';

        //-NPR5.49 [347476]
        //Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 20 * 1000);
        Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 20 * 1000, EftTransactionRequest);
        //+NPR5.49 [347476]
    end;

    [TryFunction]
    local procedure InvokeDiagnoseTerminal(var EftTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";var Response: Text)
    var
        JsonConvert: DotNet npNetJsonConvert;
        Body: Text;
    begin
        Body :=
        '{' +
           '"SaleToPOIRequest":{' +
              '"MessageHeader":{' +
                 '"ProtocolVersion":' + JsonConvert.ToString(EftTransactionRequest."Integration Version Code") + ',' +
                 '"MessageClass":"Service",' +
                 '"MessageCategory":"Diagnosis",' +
                 '"MessageType":"Request",' +
                 '"ServiceID":' + JsonConvert.ToString(EftTransactionRequest."Reference Number Input") + ',' +
                 '"SaleID":' + JsonConvert.ToString(EftTransactionRequest."Register No.") + ',' +
                 '"POIID":' + JsonConvert.ToString(EftTransactionRequest."Hardware ID") +
              '},' +
              '"DiagnosisRequest":{' +
                 '"HostDiagnosisFlag":true' +
              '}' +
           '}' +
        '}';

        //-NPR5.49 [347476]
        //Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 20 * 1000);
        Response := Invoke(Body, GetAPIKey(EFTSetup), GetServiceURL(EftTransactionRequest), 20 * 1000, EftTransactionRequest);
        //+NPR5.49 [347476]
    end;

    local procedure Invoke(Body: Text;APIKey: Text;URL: Text;TimeoutMs: Integer;var EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        HttpWebRequest: DotNet npNetHttpWebRequest;
        ReqStream: DotNet npNetStream;
        ReqStreamWriter: DotNet npNetStreamWriter;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        ResponseStream: DotNet npNetStream;
        ResponseStreamReader: DotNet npNetStreamReader;
        HttpStatusCode: DotNet npNetHttpStatusCode;
        Response: Text;
        OutStream: OutStream;
    begin
        //-NPR5.49 [347476]
        EFTTransactionRequest.Logs.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        AppendToLogStream(OutStream, Body, 'Request', EFTTransactionRequest);
        //+NPR5.49 [347476]

        HttpWebRequest := HttpWebRequest.Create(URL);
        HttpWebRequest.ContentType('application/json');
        //-NPR5.49 [345188]
        //HttpWebRequest.Headers.Add('Authorization', 'Basic ' + Authorization);
        HttpWebRequest.Headers.Add('x-api-key', APIKey);
        //+NPR5.49 [345188]
        HttpWebRequest.Method('POST');
        HttpWebRequest.Timeout(TimeoutMs);

        ReqStream := HttpWebRequest.GetRequestStream;
        ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
        ReqStreamWriter.Write(Body);
        ReqStreamWriter.Flush;
        ReqStreamWriter.Close;

        HttpWebResponse := HttpWebRequest.GetResponse;
        if not HttpWebResponse.StatusCode.Equals(HttpStatusCode.OK) then
          Error(ERROR_INVOKE, Format(HttpWebResponse.StatusCode));

        ResponseStream := HttpWebResponse.GetResponseStream;
        ResponseStreamReader := ResponseStreamReader.StreamReader(ResponseStream);
        Response := ResponseStreamReader.ReadToEnd();
        HttpWebResponse.Close();
        ResponseStreamReader.Close();

        //-NPR5.49 [347476]
        AppendToLogStream(OutStream, Response, 'Response', EFTTransactionRequest);
        //+NPR5.49 [347476]

        exit(Response);
    end;

    procedure ProcessAsyncResponse(TransactionEntryNo: Integer)
    var
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
        EFTTransactionRequest: Record "EFT Transaction Request";
        InStream: InStream;
        Text: Text;
        Response: Text;
        RecordFound: Boolean;
    begin
        //-NPR5.49 [351678]
        //IF NOT TryAcquireAsyncResponseLock(TransactionEntryNo, EFTTransactionAsyncResponse) THEN
        //  EXIT(FALSE);
        EFTTransactionAsyncResponse.LockTable;
        EFTTransactionAsyncResponse.SetAutoCalcFields(Response);
        EFTTransactionAsyncResponse.Get(TransactionEntryNo);
        //+NPR5.49 [351678]

        if EFTTransactionAsyncResponse.Error then begin
        //-NPR5.49 [351678]
        //  IF NOT TryAcquireRequestLock(TransactionEntryNo, EFTTransactionRequest) THEN
        //    EXIT(FALSE);
          EFTTransactionRequest.LockTable;
          EFTTransactionRequest.Get(TransactionEntryNo);
        //+NPR5.49 [351678]
          EFTTransactionRequest."NST Error" := EFTTransactionAsyncResponse."Error Text";
          //-NPR5.49 [345188]
          OnAfterProtocolResponse(EFTTransactionRequest);
          //+NPR5.49 [345188]
        end else begin
          EFTTransactionAsyncResponse.Response.CreateInStream(InStream, TEXTENCODING::UTF8);
          while (not InStream.EOS) do begin
            InStream.ReadText(Text);
            Response += Text;
          end;

        //-NPR5.49 [351678]
        //  IF NOT EFTTransactionAsyncResponse.DELETE THEN
        //    EXIT(FALSE);
        //
        //  IF NOT TryAcquireRequestLock(TransactionEntryNo, EFTTransactionRequest) THEN
        //    EXIT(FALSE);
          EFTTransactionAsyncResponse.Delete;

          EFTTransactionRequest.LockTable;
          EFTTransactionRequest.Get(TransactionEntryNo);
        //+NPR5.49 [351678]

          case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::Payment : EndPaymentTransaction(EFTTransactionRequest, Response);
            EFTTransactionRequest."Processing Type"::Refund : EndRefundTransaction(EFTTransactionRequest, Response);
        //-NPR5.49 [345188]
            EFTTransactionRequest."Processing Type"::Auxiliary :
              case EFTTransactionRequest."Auxiliary Operation ID" of
                2 : EndAcquireCard(EFTTransactionRequest, Response);
              end;
        //+NPR5.49 [345188]
          end;
        end;

        //-NPR5.49 [345188]
        //OnAfterProtocolResponse(EFTTransactionRequest);
        //+NPR5.49 [345188]

        //-NPR5.49 [351678]
        //EXIT(TRUE);
        //+NPR5.49 [351678]
    end;

    local procedure "// Parsing"()
    begin
    end;

    [TryFunction]
    local procedure ParsePaymentTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request";var tmpCreditCardTransaction: Record "Credit Card Transaction" temporary)
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.49 [345188]
        //JObject := JObject.Parse(Response).Item('SaleToPOIResponse');
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');
        //+NPR5.49 [345188]

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken, EFTTransactionRequest);

        JObject := JObject.Item('PaymentResponse');
        ParsePaymentResponse(JObject, EFTTransactionRequest, tmpCreditCardTransaction);
    end;

    [TryFunction]
    local procedure ParseVoidTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.49 [345188]
        //JObject := JObject.Parse(Response).Item('SaleToPOIResponse');
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');
        //+NPR5.49 [345188]

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken, EFTTransactionRequest);

        JObject := JObject.Item('ReversalResponse');
        ParseReversalResponse(JObject, EFTTransactionRequest);
    end;

    [TryFunction]
    local procedure ParseStatusTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request";var tmpCreditCardTransaction: Record "Credit Card Transaction" temporary)
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.49 [345188]
        //JObject := JObject.Parse(Response).Item('SaleToPOIResponse');
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');
        //+NPR5.49 [345188]

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken, EFTTransactionRequest);

        JObject := JObject.Item('TransactionStatusResponse');
        ParseStatusResponse(JObject, EFTTransactionRequest, tmpCreditCardTransaction);
    end;

    [TryFunction]
    local procedure ParseDiagnoseTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.49 [345188]
        //JObject := JObject.Parse(Response).Item('SaleToPOIResponse');
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');
        //+NPR5.49 [345188]

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken,EFTTransactionRequest);

        JObject := JObject.Item('DiagnosisResponse');
        EFTTransactionRequest."Result Display Text" := CopyStr(ParseDiagnoseResponse(JObject, EFTTransactionRequest), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
    end;

    [TryFunction]
    local procedure ParseCardAcquisition(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.49 [345188]
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken,EFTTransactionRequest);

        JObject := JObject.Item('CardAcquisitionResponse');
        ParseCardAcquisitionResponse(JObject, EFTTransactionRequest);
        //+NPR5.49 [345188]
    end;

    [TryFunction]
    local procedure ParseAbortAcquireCard(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.49 [345188]
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken,EFTTransactionRequest);

        TrySelectToken(JObject, 'EnableServiceResponse.Response', JToken, true);
        ParseResponse(JToken, EFTTransactionRequest);
        //+NPR5.49 [345188]
    end;

    local procedure ParsePaymentResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request";var tmpCreditCardTransaction: Record "Credit Card Transaction" temporary)
    var
        JToken: DotNet npNetJObject;
        TransactionDateTime: DateTime;
        EFTAdyenCloudSignDialog: Codeunit "EFT Adyen Cloud Sign Dialog";
    begin
        TrySelectToken(JObject, 'Response', JToken, true);
        ParseResponse(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentReceipt', JToken, false) then
          ParseReceipts(JToken, EFTTransactionRequest, tmpCreditCardTransaction);

        TrySelectToken(JObject, 'POIData', JToken, true);
        //-NPR5.49 [345188]
        ParsePOIData(JToken, EFTTransactionRequest);
        // EFTTransactionRequest."Reference Number Output" := JToken.Item('POITransactionID').Item('TransactionID').ToString();
        // EFTTransactionRequest."External Transaction ID" := EFTTransactionRequest."Reference Number Output";
        //+NPR5.49 [345188]

        if TrySelectToken(JToken, 'POIReconciliationID', JToken, false) then
          EFTTransactionRequest."Reconciliation ID" := JToken.ToString();

        if TrySelectToken(JObject, 'PaymentResult.PaymentInstrumentData', JToken, false) then
          ParsePaymentInstrumentData(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentResult.PaymentAcquirerData.AcquirerID', JToken, false) then
          EFTTransactionRequest."Acquirer ID" := JToken.ToString();

        if TrySelectToken(JObject, 'PaymentResult.PaymentAcquirerData.ApprovalCode', JToken, false) then
          EFTTransactionRequest."Authorisation Number" := JToken.ToString();

        if EFTTransactionRequest.Successful then begin
          if TrySelectToken(JObject, 'PaymentResult.CurrencyConversion[0]', JToken, false) then begin
            Evaluate(EFTTransactionRequest."DCC Used", JToken.Item('CustomerApprovedFlag').ToString());
            if EFTTransactionRequest."DCC Used" then begin
              Evaluate(EFTTransactionRequest."DCC Amount", JToken.Item('ConvertedAmount').Item('AmountValue').ToString());
              EFTTransactionRequest."DCC Currency Code" := JToken.Item('ConvertedAmount').Item('Currency').ToString();
            end;
          end;

          if TrySelectToken(JObject, 'PaymentResult.CapturedSignature', JToken, false) then begin
            EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Terminal";
            EFTAdyenCloudSignDialog.SetSignatureData(EFTTransactionRequest, JToken.ToString()); //Store signature data in global state for rendering later.
          end;

          if TrySelectToken(JObject, 'PaymentResult.AuthenticationMethod', JToken, false) then
            ParseAuthenticationMethod(JToken, EFTTransactionRequest);

          if TrySelectToken(JObject, 'PaymentResult.AmountsResp.AuthorizedAmount', JToken, false) then
            Evaluate(EFTTransactionRequest."Amount Output", JToken.ToString());

          if EFTTransactionRequest."Currency Code" = '' then
            if TrySelectToken(JObject, 'PaymentResult.AmountsResp.Currency', JToken, false) then
              EFTTransactionRequest."Currency Code" := JToken.ToString();

          if TrySelectToken(JObject, 'PaymentResult.AmountsResp.TotalFeesAmount', JToken, false) then
            Evaluate(EFTTransactionRequest."Fee Amount", JToken.ToString());

          if TrySelectToken(JObject, 'PaymentResult.AmountsResp.TipAmount', JToken, false) then
            Evaluate(EFTTransactionRequest."Tip Amount", JToken.ToString());
        end;
    end;

    local procedure ParseReversalResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        ParseResponse(JObject.Item('Response'), EFTTransactionRequest);

        if EFTTransactionRequest.Successful then
          EFTTransactionRequest."Amount Output" := EFTTransactionRequest."Amount Input";
    end;

    local procedure ParseStatusResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request";var tmpCreditCardTransaction: Record "Credit Card Transaction" temporary)
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        StatusResponse: DotNet npNetJObject;
    begin
        StatusResponse := JObject.Item('Response');

        if (StatusResponse.Item('Result').ToString = 'Success') then begin
          JObject := JObject.Item('RepeatedMessageResponse');

          OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
          ValidateHeader(JObject.Item('MessageHeader'), OriginalEFTTransactionRequest);

          case OriginalEFTTransactionRequest."Processing Type" of
            OriginalEFTTransactionRequest."Processing Type"::Payment,
            OriginalEFTTransactionRequest."Processing Type"::Refund :
              ParsePaymentResponse(JObject.Item('RepeatedResponseMessageBody').Item('PaymentResponse'), EFTTransactionRequest, tmpCreditCardTransaction);

            OriginalEFTTransactionRequest."Processing Type"::Void :
              begin
                ParseReversalResponse(JObject.Item('RepeatedResponseMessageBody').Item('ReversalResponse'), EFTTransactionRequest);
        //-NPR5.49 [345188]
                if EFTTransactionRequest.Successful then begin
                  EFTTransactionRequest."Amount Output" := OriginalEFTTransactionRequest."Amount Input";
                  EFTTransactionRequest."Currency Code" := OriginalEFTTransactionRequest."Currency Code";
                end;
        //+NPR5.49 [345188]
              end;
          end
        end;

        ParseResponse(StatusResponse, EFTTransactionRequest); //Sets trx record result to match the lookup response rather than the repeated response result.
    end;

    local procedure ParseDiagnoseResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        TerminalStatus: Text;
        TerminalCommunication: Text;
        HostStatus: Text;
        JToken: DotNet npNetJObject;
    begin
        TerminalCommunication := UNKNOWN;
        if TrySelectToken(JObject, 'POIStatus.CommunicationOKFlag', JToken, false) then
          TerminalCommunication := JToken.ToString();

        TrySelectToken(JObject, 'POIStatus.GlobalStatus', JToken, true);
        TerminalStatus := JToken.ToString();

        HostStatus := UNKNOWN;
        if TrySelectToken(JObject, 'HostStatus[0].IsReachableFlag', JToken, false) then
          HostStatus := JToken.ToString();

        exit(StrSubstNo(DIAGNOSE, TerminalStatus, TerminalCommunication, HostStatus));
    end;

    local procedure ParseCardAcquisitionResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.49 [345188]
        TrySelectToken(JObject, 'Response', JToken, true);
        ParseResponse(JToken, EFTTransactionRequest);

        if not EFTTransactionRequest.Successful then
          exit;

        TrySelectToken(JObject, 'POIData', JToken, true);
        ParsePOIData(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentInstrumentData', JToken, false) then
          ParsePaymentInstrumentData(JToken, EFTTransactionRequest);
        //+NPR5.49 [345188]
    end;

    local procedure ParseResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JToken: DotNet npNetJObject;
    begin
        EFTTransactionRequest.Successful := (JObject.Item('Result').ToString = 'Success');

        if TrySelectToken(JObject, 'AdditionalResponse', JToken, false) then
          ParseAdditionalDataString(JToken, EFTTransactionRequest);

        if not EFTTransactionRequest.Successful then
          if TrySelectToken(JObject, 'ErrorCondition', JToken, false) then
            EFTTransactionRequest."Result Description" := JToken.ToString();
    end;

    local procedure ParsePaymentInstrumentData(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JToken: DotNet npNetJObject;
    begin
        if TrySelectToken(JObject, 'PaymentInstrumentType', JToken, false) then
          EFTTransactionRequest."Payment Instrument Type" := JToken.ToString();

        if TrySelectToken(JObject, 'CardData.MaskedPan', JToken, false) then
          EFTTransactionRequest."Card Number" := JToken.ToString();

        if TrySelectToken(JObject, 'CardData.PaymentToken', JToken, false) then
          if JToken.Item('TokenRequestedType').ToString() = 'Customer' then
            EFTTransactionRequest."External Customer ID" := JToken.Item('TokenValue').ToString();

        if TrySelectToken(JObject, 'StoredValueAccountID', JToken, false) then begin
          EFTTransactionRequest."Stored Value Account Type" := JToken.Item('StoredValueAccountType').ToString();
          EFTTransactionRequest."Stored Value ID" := JToken.Item('StoredValueID').ToString();
          if TrySelectToken(JToken, 'StoredValueProvider', JToken, false) then
            EFTTransactionRequest."Stored Value Provider" := JToken.ToString();
        end;
    end;

    local procedure ParsePOIData(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        TransactionDateTime: DateTime;
    begin
        //-NPR5.49 [345188]
        EFTTransactionRequest."Reference Number Output" := JObject.Item('POITransactionID').Item('TransactionID').ToString();
        EFTTransactionRequest."External Transaction ID" := EFTTransactionRequest."Reference Number Output";
        Evaluate(TransactionDateTime, JObject.Item('POITransactionID').Item('TimeStamp').ToString(), 9);
        EFTTransactionRequest."Transaction Date" := DT2Date(TransactionDateTime);
        EFTTransactionRequest."Transaction Time" := DT2Time(TransactionDateTime);
        //+NPR5.49 [345188]
    end;

    local procedure ParseAuthenticationMethod(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        i: Integer;
    begin
        if JObject.Count = 0 then
          exit;

        for i := 0 to JObject.Count-1 do begin
          case JObject.Item(i).ToString() of
            'SignatureCapture' :
              begin
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
              end;
          end;
        end;
    end;

    local procedure ParseReceipts(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request";var tmpCreditCardTransaction: Record "Credit Card Transaction" temporary)
    var
        i: Integer;
        EntryNo: Integer;
        ReceiptNo: Integer;
        OutStream: OutStream;
        DocumentQualifier: Text;
        JToken: DotNet npNetJObject;
        OutputFormat: Text;
        j: Integer;
        Line: Text;
        NameValueCollection: DotNet npNetNameValueCollection;
        "Key": Text;
        Name: Text;
        Value: Text;
        ParsePrint: Boolean;
        TotalLength: Integer;
        RequiredSignature: Boolean;
    begin
        if JObject.Count() < 1 then
          exit;

        for i := 0 to (JObject.Count()-1) do begin

          ParsePrint := true;
          DocumentQualifier := JObject.Item(i).Item('DocumentQualifier').ToString();
          case DocumentQualifier of
            'CustomerReceipt' : EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream, TEXTENCODING::UTF8);
            'CashierReceipt' :
              begin
                RequiredSignature := false;
                if TrySelectToken(JObject.Item(i), 'RequiredSignatureFlag', JToken, false) then
                  Evaluate(RequiredSignature, JToken.ToString(), 9);

                if RequiredSignature then begin
                  EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream, TEXTENCODING::UTF8);
                  EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
                end else
                  ParsePrint := false;
              end;
            else
              ParsePrint := false;
          end;

          if ParsePrint then begin
            ReceiptNo += 1;

            if JObject.Item(i).Item('OutputContent').Item('OutputFormat').ToString() = 'Text' then begin
              JToken := JObject.Item(i).Item('OutputContent').Item('OutputText');
              for j := 0 to (JToken.Count()-1) do begin

                Name := '';
                Value := '';
                ParseQueryString(JToken.Item(j).Item('Text').ToString(), NameValueCollection);
                foreach Key in NameValueCollection do begin
                  case Key of
                    'name' : Name := NameValueCollection.Get(Key);
                    'value' : Value := NameValueCollection.Get(Key);
                  end;
                end;

                OutStream.WriteText(StrSubstNo('%1  %2\', Name, Value));

                Name := SubstituteCurrencyChars(Name);
                Value := SubstituteCurrencyChars(Value);

                tmpCreditCardTransaction.Date := Today;
                tmpCreditCardTransaction."Transaction Time" := Time;
                tmpCreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
                tmpCreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
                tmpCreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
                tmpCreditCardTransaction."Receipt No." := ReceiptNo;

                TotalLength := StrLen(Name) + StrLen(Value) + 2;
                if TotalLength = 2 then
                  tmpCreditCardTransaction.Text := ' '
                else if TotalLength <= 40 then
                  tmpCreditCardTransaction.Text := Name + PadStr('', 40-StrLen(Name)-StrLen(Value), ' ') + Value;

                tmpCreditCardTransaction."Entry No." += 1;
                tmpCreditCardTransaction.Insert;
              end;
            end;
          end;
        end;
    end;

    local procedure ParseAdditionalDataString(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        NameValueCollection: DotNet npNetNameValueCollection;
        "Key": Text;
    begin
        ParseQueryString(JObject.ToString(), NameValueCollection);
        foreach Key in NameValueCollection do begin
          case Key of
            'AID' : EFTTransactionRequest."Card Application ID" := NameValueCollection.Get(Key);
            'applicationPreferredName' : EFTTransactionRequest."Card Name" := NameValueCollection.Get(Key);
            'shopperReference' : EFTTransactionRequest."Internal Customer ID" := NameValueCollection.Get(Key);
        //-NPR5.49 [345188]
        //    'alias' : EFTTransactionRequest."External Payment Token" := NameValueCollection.Get(Key); //TODO: Spelling?
        //+NPR5.49 [345188]
            'message' : EFTTransactionRequest."Result Display Text" := CopyStr(NameValueCollection.Get(Key), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
          end;
        end;
    end;

    local procedure ParseQueryString(QueryString: Text;var NameValueCollection: DotNet npNetNameValueCollection)
    var
        HttpUtility: DotNet npNetHttpUtility;
    begin
        NameValueCollection := HttpUtility.ParseQueryString(QueryString);
    end;

    local procedure TrySelectToken(JObject: DotNet npNetJObject;Path: Text;var JToken: DotNet npNetJToken;WithError: Boolean): Boolean
    begin
        //-NPR5.49 [345188]
        //JToken := JObject.SelectToken(Path);
        JToken := JObject.SelectToken(Path, WithError);
        exit(not IsNull(JToken));
        //+NPR5.49 [345188]
    end;

    local procedure ValidateHeader(JObject: DotNet npNetJObject;EFTTransactionRequest: Record "EFT Transaction Request")
    var
        ServiceID: Integer;
        MessageCategory: Text;
        ExpectedMessageCategory: Text;
    begin
        Evaluate(ServiceID, JObject.Item('ServiceID').ToString());
        EFTTransactionRequest.TestField("Entry No.", ServiceID);

        case EFTTransactionRequest."Processing Type" of
          EFTTransactionRequest."Processing Type"::Refund : ExpectedMessageCategory := 'Payment';
          EFTTransactionRequest."Processing Type"::Payment : ExpectedMessageCategory := 'Payment';
          EFTTransactionRequest."Processing Type"::Lookup : ExpectedMessageCategory := 'TransactionStatus';
          EFTTransactionRequest."Processing Type"::Void : ExpectedMessageCategory := 'Reversal';
          EFTTransactionRequest."Processing Type"::Setup : ExpectedMessageCategory := 'Diagnosis';
        //-NPR5.49 [345188]
          EFTTransactionRequest."Processing Type"::Auxiliary :
            case EFTTransactionRequest."Auxiliary Operation ID" of
              2 : ExpectedMessageCategory := 'CardAcquisition';
              3 : ExpectedMessageCategory := 'EnableService';
            end;
        //+NPR5.49 [345188]
        end;
        MessageCategory := JObject.Item('MessageCategory').ToString();
        if MessageCategory <> ExpectedMessageCategory then
          Error(ERROR_HEADER_CATEGORY, MessageCategory, ExpectedMessageCategory);
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure ParseJSON(JSON: Text;var JObject: DotNet npNetJObject)
    var
        MemStream: DotNet npNetMemoryStream;
        StreamReader: DotNet npNetStreamReader;
        Encoding: DotNet npNetEncoding;
        JsonTextReader: DotNet npNetJsonTextReader;
        DateParseHandling: DotNet npNetDateParseHandling;
    begin
        //-NPR5.49 [345188]
        MemStream := MemStream.MemoryStream(Encoding.UTF8.GetBytes(JSON));
        StreamReader := StreamReader.StreamReader(MemStream,Encoding.UTF8);
        JsonTextReader := JsonTextReader.JsonTextReader(StreamReader);
        JsonTextReader.DateParseHandling := DateParseHandling.None;
        JObject := JObject.Load(JsonTextReader);
        //+NPR5.49 [345188]
    end;

    local procedure CreateReceiptData(EFTTransactionRequest: Record "EFT Transaction Request";var tmpCreditCardTransaction: Record "Credit Card Transaction" temporary): Boolean
    var
        CreditCardTransaction: Record "Credit Card Transaction";
        EntryNo: Integer;
        ReceiptNo: Integer;
    begin
        if not tmpCreditCardTransaction.FindSet then
          exit(true);

        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then begin
          EntryNo := CreditCardTransaction."Entry No.";
          ReceiptNo := CreditCardTransaction."Receipt No.";
        end;
        CreditCardTransaction.Reset;

        repeat
          CreditCardTransaction.Init;
          CreditCardTransaction := tmpCreditCardTransaction;
          CreditCardTransaction."Entry No." := EntryNo + tmpCreditCardTransaction."Entry No.";
          CreditCardTransaction."Receipt No." := ReceiptNo + tmpCreditCardTransaction."Receipt No.";
          if not CreditCardTransaction.Insert then
            exit(false);
        until tmpCreditCardTransaction.Next = 0;

        exit(true);
    end;

    local procedure IsMPOSDevice(RegisterId: Code[10]): Boolean
    var
        MPOSAppSetup: Record "MPOS App Setup";
    begin
        if MPOSAppSetup.Get(RegisterId) then
          exit(MPOSAppSetup.Enable);
        exit(false);
    end;

    local procedure SubstituteCurrencyChars(Value: Text): Text
    var
        String: DotNet npNetString;
    begin
        //Make print data more encoding agnostic.
        if StrPos(Value, '�') > 0 then begin
          String := Value;
          exit(String.Replace('�', 'EUR'));
        end;

        exit(Value);
    end;

    procedure GetAPIKey(EFTSetup: Record "EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        //-NPR5.49 [345188]
        //EXIT(Convert.ToBase64String(Encoding.GetEncoding('ISO-8859-1').GetBytes(EFTAdyenCloudIntegration.GetAPIUser(EFTSetup)+':'+EFTAdyenCloudIntegration.GetAPIPassword(EFTSetup))));
        exit(EFTAdyenCloudIntegration.GetAPIKey(EFTSetup));
        //+NPR5.49 [345188]
    end;

    local procedure GetServiceURL(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
    begin
        case EFTTransactionRequest.Mode of
          EFTTransactionRequest.Mode::Production : exit('https://terminal-api-live.adyen.com/sync');
          EFTTransactionRequest.Mode::"TEST Remote" : exit('https://terminal-api-test.adyen.com/sync');
          EFTTransactionRequest.Mode::"TEST Local" : Error('Unsupported parameter, %1: %2', EFTTransactionRequest.FieldCaption(Mode), EFTTransactionRequest.Mode);
        end;
    end;

    local procedure GetDateTime(): Text
    begin
        exit(Format(CurrentDateTime,0,9));
    end;

    local procedure GetSaleToAcquirerData(EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        Value: Text;
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        Value := 'tenderOption=ReceiptHandler&tenderOption=GetAdditionalData';

        //-NPR5.49 [345188]
        // IF EFTAdyenCloudIntegration.GetCreateRecurringContract(EFTSetup) THEN BEGIN
        //  Value += '&recurringContract=RECURRING';
        // END;
        case EFTAdyenCloudIntegration.GetCreateRecurringContract(EFTSetup) of
          EFTAdyenPaymentTypeSetup."Create Recurring Contract"::NO : ;
          EFTAdyenPaymentTypeSetup."Create Recurring Contract"::ONECLICK : Value += '&recurringContract=ONECLICK&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
          EFTAdyenPaymentTypeSetup."Create Recurring Contract"::RECURRING : Value += '&recurringContract=RECURRING&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
          EFTAdyenPaymentTypeSetup."Create Recurring Contract"::RECURRING_ONECLICK : Value += '&recurringContract=ONECLICK,RECURRING&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
        end;
        //+NPR5.49 [345188]

        exit(Value);
    end;

    local procedure GetTransactionConditions(EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        Condition: Integer;
        ConditionBrand: Text;
        Json: Text;
    begin
        Condition := EFTAdyenCloudIntegration.GetTransactionCondition(EFTSetup);
        case Condition of
          0 : exit('');
          1 : ConditionBrand := 'alipay';
          2 : ConditionBrand := 'wechat';
        end;

        exit(
        '"TransactionConditions":{' +
            '"AllowedPaymentBrand":[' +
              '"' + ConditionBrand + '"' +
            ']' +
        '}');
    end;

    local procedure GetAmount(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        exit(Format(EFTTransactionRequest."Amount Input",0,9));
    end;

    local procedure GetCashbackAmount(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        exit(Format(EFTTransactionRequest."Cashback Amount",0,9));
    end;

    local procedure GetLookupCategory(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        case EFTTransactionRequest."Processing Type" of
          EFTTransactionRequest."Processing Type"::Payment,
          EFTTransactionRequest."Processing Type"::Refund :
            exit('Payment');
          EFTTransactionRequest."Processing Type"::Void :
            exit('Reversal');
          else
            Error('Unsupported lookup of %1 %2', EFTTransactionRequest.FieldCaption("Processing Type"), EFTTransactionRequest."Processing Type");
        end;
    end;

    local procedure GetAbortMessageCategory(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        //-NPR5.49 [345188]
        EFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::Payment) then
          exit('Payment');
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::Auxiliary) and (EFTTransactionRequest."Auxiliary Operation ID" = 2) then
          exit('CardAcquisition');
        //+NPR5.49 [345188]
    end;

    local procedure GetLinkedCardAcquisition(EFTTransactionRequest: Record "EFT Transaction Request";var AcquireCardRequestOut: Record "EFT Transaction Request"): Boolean
    begin
        //-NPR5.49 [345188]
        AcquireCardRequestOut.SetRange("Initiated from Entry No.", EFTTransactionRequest."Entry No.");
        AcquireCardRequestOut.SetRange("Processing Type", AcquireCardRequestOut."Processing Type"::Auxiliary);
        AcquireCardRequestOut.SetRange("Auxiliary Operation ID", 2);
        AcquireCardRequestOut.SetRange(Successful, true);
        exit(AcquireCardRequestOut.FindFirst);
        //+NPR5.49 [345188]
    end;

    local procedure GetCardAcquisitionJSON(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        AcquireCardRequest: Record "EFT Transaction Request";
        JsonConvert: DotNet npNetJsonConvert;
        AcquireDateTime: DateTime;
    begin
        //-NPR5.49 [345188]
        if not GetLinkedCardAcquisition(EFTTransactionRequest, AcquireCardRequest) then
          exit('');

        AcquireDateTime := CreateDateTime(AcquireCardRequest."Transaction Date", AcquireCardRequest."Transaction Time");

        exit(
        '"CardAcquisitionReference":{' +
          '"TransactionID":' + JsonConvert.ToString(AcquireCardRequest."Reference Number Output") + ',' +
          '"TimeStamp":"' + Format(AcquireDateTime,0,9) + '"' +
        '}'
        );
        //+NPR5.49 [345188]
    end;

    local procedure AppendToLogStream(var OutStream: OutStream;Text: Text;Header: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        LF: Char;
        CR: Char;
        EFTSetup: Record "EFT Setup";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [347476]
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if EFTAdyenCloudIntegration.GetLogLevel(EFTSetup) = EFTAdyenPaymentTypeSetup."Log Level"::NONE then
          exit;

        CR := 13;
        LF := 10;

        OutStream.WriteText(Format(CR) + Format(LF) + Format(CR) + Format(LF) + '===' + Header + '===' + Format(CR) + Format(LF) + Text);
        //-NPR5.50 [353340]
        // EFTTransactionRequest.MODIFY;
        // COMMIT;
        //+NPR5.50 [353340]
        //+NPR5.49 [347476]
    end;

    local procedure ClearLogAfterResult(var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTSetup: Record "EFT Setup";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [347476]
        if not EFTTransactionRequest."External Result Received" then
          exit;

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if EFTAdyenCloudIntegration.GetLogLevel(EFTSetup) <> EFTAdyenPaymentTypeSetup."Log Level"::ERROR then
          exit;

        EFTTransactionRequest.CalcFields(Logs);
        Clear(EFTTransactionRequest.Logs);
        //+NPR5.49 [347476]
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
    end;
}

