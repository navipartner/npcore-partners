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
    // NPR5.51/MMV /20190702 CASE 355433 Added amount to AcquireCard
    //                                   Added capture delay parameter support.
    // NPR5.53/MMV /20191120 CASE 378608 Set invariantculture when parsing from newtonsoft to prevent thread culture impact.
    //                                   Removed single instance.
    // NPR5.53/MMV /20191211 CASE 377533 Rewrote parsing to be in sync with undocumented API behaviour (all reject notifications -> no conclusive result)
    //                                   Rewrote log handling to supporting table to prevent cross session locks.
    //                                   Rewrote background session management.
    //                                   Added disable recurring contract API request
    // NPR5.53/MMV /20200128 CASE 377533 Added auto abort if API returns InProgress and we find a matching candidate on most recently logged trx.
    //                                   Added variable lookup timeout.
    // NPR5.54/MMV /20200218 CASE 387990 Added response status code buffer.
    //                                   Parse web exception on error to fill buffer.
    //                                   Handle acquire card hard error.
    // NPR5.54/MMV /20200227 CASE 364340 Changed background session method.


    trigger OnRun()
    begin
    end;

    var
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_INVOKE: Label 'Error: Service endpoint responded with HTTP status %1';
        ERROR_RECEIPT: Label 'Error: Could not create terminal receipt data';
        ERROR_HEADER_CATEGORY: Label 'Error: Header category %1, expected %2';
        ERROR_UNKNOWN_EVENT: Label 'Unknown event json';
        VOID_SUCCESS: Label 'Transaction %1 was successfully voided';
        VOID_FAILURE: Label 'Transaction %1 could not be voided: %2\%3';
        DIAGNOSE: Label 'Terminal Status: %1\Terminal Connection: %2\Host Connection: %3';
        UNKNOWN: Label 'Unknown';
        RequestResponseBuffer: Text;
        ABORT_ACQUIRE_SWIPE_HEADER: Label 'Card Scanned';
        ABORT_ACQUIRE_SWIPE_LINE: Label 'Please Remove Card';
        ResponseStatusCodeBuffer: Integer;
        ResponseErrorBodyBuffer: Text;

    local procedure IntegrationType(): Text
    begin
        exit('ADYEN_CLOUD');
    end;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request")
    begin
        // All the request types that show a front-end dialog while waiting for terminal customer interaction, are asynchronous using STARTSESSION to perform a long timeout webservice request.
        // The POS user session will poll a table until a response record appears or timeout is reached.
        // The reason is that Adyens transaction API requires concurrent requests which a single user session does not support in pure C/AL.

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT:
                StartPaymentTransaction(EftTransactionRequest); //Via async dialog & background session
            EftTransactionRequest."Processing Type"::REFUND:
                StartRefundTransaction(EftTransactionRequest); //Via async dialog & background session
            EftTransactionRequest."Processing Type"::VOID:
                VoidTransaction(EftTransactionRequest); //Via blocking ws invoke
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupTransaction(EftTransactionRequest); //Via blocking ws invoke
            EftTransactionRequest."Processing Type"::SETUP:
                SetupTerminal(EftTransactionRequest); //Via blocking ws invoke
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        AbortTransaction(EftTransactionRequest); //via blocking ws invoke
                    2:
                        StartAcquireCard(EftTransactionRequest); //Via async dialog & background session
                    3:
                        AbortAcquireCard(EftTransactionRequest); //via blocking ws invoke
                                                                 //-NPR5.53 [377533]
                    4:
                        StartAcquireCard(EftTransactionRequest); //Via async dialog & background session
                    5:
                        StartAcquireCard(EftTransactionRequest); //Via async dialog & background session
                    6:
                        DisableRecurringContract(EftTransactionRequest); //via blocking ws invoke
                                                                         //+NPR5.53 [377533]
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
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTTransactionAsyncRequest: Record "EFT Transaction Async Request";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
    begin
        //-NPR5.53 [377533]
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        //-NPR5.54 [364340]
        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);
        //+NPR5.54 [364340]
        Commit;

        StartSession(SessionId, CODEUNIT::"EFT Adyen Backgnd. Trx Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo('Queued trx session ID %1', SessionId), '');

        Clear(SessionId);
        StartSession(SessionId, CODEUNIT::"EFT Adyen Backgnd. Lookup Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo('Queued lookup session ID %1', SessionId), '');
        //+NPR5.53 [377533]

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if (EFTAdyenCloudIntegration.GetAcquireCardFirst(EFTSetup) or (EFTAdyenCloudIntegration.GetCreateRecurringContract(EFTSetup) <> 0)) then
            if GetLinkedCardAcquisition(EftTransactionRequest, AcquireCardRequest) then
                exit; //Dialog already open

        EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndPaymentTransaction(var EftTransactionRequest: Record "EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        //-NPR5.53 [377533]
        EFTAdyenResponseParser.SetResponseData('Payment', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData('RejectNotification', Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify;
        end;

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]

        //-NPR5.53 [377533]
        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
        //+NPR5.53 [377533]
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
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTTransactionAsyncRequest: Record "EFT Transaction Async Request";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
    begin
        //-NPR5.53 [377533]
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        //-NPR5.54 [364340]
        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);
        //+NPR5.54 [364340]
        Commit;

        StartSession(SessionId, CODEUNIT::"EFT Adyen Backgnd. Trx Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo('Queued trx session ID %1', SessionId), '');

        Clear(SessionId);
        StartSession(SessionId, CODEUNIT::"EFT Adyen Backgnd. Lookup Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo('Queued lookup session ID %1', SessionId), '');
        //+NPR5.53 [377533]

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        if EFTAdyenCloudIntegration.GetAcquireCardFirst(EFTSetup) then
            if GetLinkedCardAcquisition(EftTransactionRequest, AcquireCardRequest) then
                exit; //Dialog already open

        EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndRefundTransaction(var EftTransactionRequest: Record "EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        //-NPR5.53 [377533]
        EFTAdyenResponseParser.SetResponseData('Payment', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData('RejectNotification', Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify;
        end;

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]

        //-NPR5.53 [377533]
        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
        //+NPR5.53 [377533]
    end;

    local procedure VoidTransaction(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        Response: Text;
        EFTSetup: Record "EFT Setup";
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        if OriginalEFTTransactionRequest.Recovered then
            OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Recovered by Entry No.");

        //-NPR5.53 [377533]
        if not InvokeVoid(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify;
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTAdyenResponseParser.SetResponseData('Void', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData('RejectNotification', Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify;
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]

        //-NPR5.53 [377533]
        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
        //+NPR5.53 [377533]
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "EFT Transaction Request")
    var
        Response: Text;
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        EFTSetup: Record "EFT Setup";
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        //-NPR5.53 [377533]
        //-NPR5.53 [377533]
        if not InvokeLookup(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, 1000 * 60, Response) then begin
            //+NPR5.53 [377533]
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify;
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTAdyenResponseParser.SetResponseData('TransactionStatus', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData('RejectNotification', Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify;
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]

        //-NPR5.53 [377533]
        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
        //+NPR5.53 [377533]
    end;

    local procedure SetupTerminal(EftTransactionRequest: Record "EFT Transaction Request")
    var
        Response: Text;
        MessageString: Text;
        EFTSetup: Record "EFT Setup";
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        //-NPR5.53 [377533]
        if not InvokeDiagnoseTerminal(EftTransactionRequest, EFTSetup, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify;
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTAdyenResponseParser.SetResponseData('Diagnose', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData('RejectNotification', Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify;
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]

        //-NPR5.53 [377533]
        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
        //+NPR5.53 [377533]
    end;

    procedure AbortTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTSetup: Record "EFT Setup";
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(OriginalEFTTransactionRequest."Register No.", OriginalEFTTransactionRequest."Original POS Payment Type Code");

        if InvokeAbortTransaction(EFTTransactionRequest, EFTSetup) then begin
            EFTTransactionRequest."External Result Known" := true;
            EFTTransactionRequest.Successful := true;
        end else
            EFTTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));

        EFTTransactionRequest.Modify;

        HandleProtocolResponse(EFTTransactionRequest);
    end;

    procedure ForceCloseTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
    begin
        //-NPR5.53 [377533]
        EFTTrxBackgroundSessionMgt.MarkRequestAsDone(EFTTransactionRequest."Entry No.");
        //+NPR5.53 [377533]

        EFTTransactionRequest."Force Closed" := true;
        EFTTransactionRequest.Modify;

        HandleProtocolResponse(EFTTransactionRequest);

        //-NPR5.54 [387990]
        EFTAdyenCloudIntegration.ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest);
        //+NPR5.54 [387990]
    end;

    local procedure StartAcquireCard(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        SessionId: Integer;
        EFTAdyenCloudTrxDialog: Codeunit "EFT Adyen Cloud Trx Dialog";
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTTransactionAsyncRequest: Record "EFT Transaction Async Request";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
    begin
        //-NPR5.53 [377533]
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        //-NPR5.54 [364340]
        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);
        //+NPR5.54 [364340]
        Commit;

        StartSession(SessionId, CODEUNIT::"EFT Adyen Backgnd. Trx Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo('Queued trx session ID %1', SessionId), '');
        //+NPR5.53 [377533]

        EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndAcquireCard(EftTransactionRequest: Record "EFT Transaction Request"; Response: Text)
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        //-NPR5.53 [377533]
        EFTAdyenResponseParser.SetResponseData('CardAcquisition', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData('RejectNotification', Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify;
        end;

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]

        //-NPR5.53 [377533]
        if (not EftTransactionRequest.Successful) then begin
            EFTAdyenCloudIntegration.ProcessOriginalTrxAfterAcquireCardFailure(EftTransactionRequest);
        end;
        //+NPR5.53 [377533]

        //-NPR5.53 [377533]
        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
        //+NPR5.53 [377533]
    end;

    local procedure AbortAcquireCard(EftTransactionRequest: Record "EFT Transaction Request")
    var
        Response: Text;
        EFTSetup: Record "EFT Setup";
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        //-NPR5.53 [377533]
        if not InvokeAbortAcquireCard(EftTransactionRequest, EFTSetup, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify;
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTAdyenResponseParser.SetResponseData('AbortAcquireCard', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData('RejectNotification', Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify;
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]
    end;

    local procedure DisableRecurringContract(EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        ParseSuccess: Boolean;
        EFTSetup: Record "EFT Setup";
        Response: Text;
    begin
        //-NPR5.53 [377533]
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeDisableRecurringContract(EftTransactionRequest, EFTSetup, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify;
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTAdyenResponseParser.SetResponseData('DisableContract', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify;
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]
    end;

    procedure ProcessAsyncResponse(TransactionEntryNo: Integer)
    var
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
        EFTTransactionRequest: Record "EFT Transaction Request";
        InStream: InStream;
        Text: Text;
        Response: Text;
        RecordFound: Boolean;
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
    begin
        //-NPR5.53 [377533]
        EFTTrxBackgroundSessionMgt.TryGetResponseRecord(TransactionEntryNo, EFTTransactionAsyncResponse);

        if EFTTransactionAsyncResponse.Error then begin
            EFTTransactionRequest.LockTable;
            EFTTransactionRequest.Get(TransactionEntryNo);
            EFTTransactionRequest."NST Error" := EFTTransactionAsyncResponse."Error Text";
            //-NPR5.54 [387990]
            EFTTransactionRequest."External Result Known" := not EFTTransactionAsyncResponse."Transaction Started";
            EFTAdyenCloudIntegration.ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest);
            //+NPR5.54 [387990]
            HandleProtocolResponse(EFTTransactionRequest);
        end else begin
            EFTTransactionAsyncResponse.Response.CreateInStream(InStream, TEXTENCODING::UTF8);
            while (not InStream.EOS) do begin
                InStream.ReadText(Text);
                Response += Text;
            end;

            EFTTransactionAsyncResponse.Delete;
            Commit;
            EFTTransactionRequest.Get(TransactionEntryNo);

            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    EndPaymentTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::REFUND:
                    EndRefundTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::AUXILIARY:
                    case EFTTransactionRequest."Auxiliary Operation ID" of
                        2:
                            EndAcquireCard(EFTTransactionRequest, Response);
                        4:
                            EndAcquireCard(EFTTransactionRequest, Response);
                        5:
                            EndAcquireCard(EFTTransactionRequest, Response);
                    end;
            end;
        end;
        //+NPR5.53 [377533]
    end;

    local procedure "// API"()
    begin
    end;

    [TryFunction]
    procedure InvokePayment(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; var Response: Text)
    var
        Body: Text;
        JsonConvert: DotNet JsonConvert;
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
                 '},' +
                 '"PaymentData":{' +
                    GetCardAcquisitionJSON(EftTransactionRequest, false) +
                 '}' +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 600 * 1000, EftTransactionRequest);
    end;

    [TryFunction]
    procedure InvokeRefund(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; var Response: Text)
    var
        JsonConvert: DotNet JsonConvert;
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
                    '"PaymentType":"Refund"' +
                    GetCardAcquisitionJSON(EftTransactionRequest, true) +
                 '}' +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 600 * 1000, EftTransactionRequest);
    end;

    [TryFunction]
    local procedure InvokeVoid(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; OriginalEFTTransactionRequest: Record "EFT Transaction Request"; var Response: Text)
    var
        JsonConvert: DotNet JsonConvert;
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
        //-NPR5.53 [377533]
        //-NPR5.53 [377533]
        //         '"SaleData":{' +
        //            '"SaleToAcquirerData":"' + GetSaleToAcquirerData(EftTransactionRequest, EFTSetup) + '"' +
        //         '},' +
        //+NPR5.53 [377533]
        //+NPR5.53 [377533]
                 '"OriginalPOITransaction":{' +
                    '"POITransactionID":{' +
        //-NPR5.53 [377533]
        //               '"TimeStamp":"' + GetDateTime() + '",' +
                       '"TimeStamp":"' + GetTransactionDateTime(OriginalEFTTransactionRequest) + '",' +
        //+NPR5.53 [377533]
                       '"TransactionID":' + JsonConvert.ToString(OriginalEFTTransactionRequest."Reference Number Output") + '' +
                    '}' +
                 '},' +
                 '"ReversalReason":"MerchantCancel"' +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 20 * 1000, EftTransactionRequest);
    end;

    [TryFunction]
    local procedure InvokeAbortTransaction(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup")
    var
        JsonConvert: DotNet JsonConvert;
        Body: Text;
    begin
        Body :=
        '{' +
            '"SaleToPOIRequest":{' +
                '"AbortRequest":{' +
                    '"AbortReason":"MerchantAbort",' +
                    '"MessageReference":{' +
                        '"ServiceID":"' + JsonConvert.ToString(EftTransactionRequest."Processed Entry No.") + '",' +
                          '"MessageCategory":"' + GetAbortMessageCategory(EftTransactionRequest) + '"' +
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

        InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 10 * 1000, EftTransactionRequest);
    end;

    [TryFunction]
    procedure InvokeAcquireCard(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; var Response: Text)
    var
        JsonConvert: DotNet JsonConvert;
        Body: Text;
    begin
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
                 '"CardAcquisitionTransaction":{' +
        //-NPR5.53 [377533]
        //            '"TotalAmount":' + GetAmount(EftTransactionRequest) +
                      GetCardAcquisitionTransactionJSON(EftTransactionRequest) +
        //+NPR5.53 [377533]
                  '}' +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 600 * 1000, EftTransactionRequest);
    end;

    [TryFunction]
    local procedure InvokeAbortAcquireCard(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; var Response: Text)
    var
        Body: Text;
        JsonConvert: DotNet JsonConvert;
    begin
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
        //-NPR5.53 [377533]
                 CustomAbortAcquireTerminalMessage(EftTransactionRequest) +
        //+NPR5.53 [377533]
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 10 * 1000, EftTransactionRequest);
    end;

    [TryFunction]
    procedure InvokeLookup(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; OriginalEftTransactionRequest: Record "EFT Transaction Request"; TimeoutMs: Integer; var Response: Text)
    var
        JsonConvert: DotNet JsonConvert;
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

        //-NPR5.53 [377533]
        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), TimeoutMs, EftTransactionRequest);
        //+NPR5.53 [377533]
    end;

    [TryFunction]
    local procedure InvokeDiagnoseTerminal(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; var Response: Text)
    var
        JsonConvert: DotNet JsonConvert;
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

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 20 * 1000, EftTransactionRequest);
    end;

    [TryFunction]
    procedure InvokeDisableRecurringContract(EftTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; var Response: Text)
    var
        Body: Text;
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        JsonConvert: DotNet npNetJsonConvert;
    begin
        //-NPR5.53 [377533]
        Body :=
         '{' +
           '"shopperReference":' + JsonConvert.ToString(EftTransactionRequest."External Customer ID") + ',' +
           '"merchantAccount":' + JsonConvert.ToString(EFTAdyenCloudIntegration.GetMerchantAccount(EFTSetup)) +
         '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetRecurringURL(EftTransactionRequest, EFTSetup, 'disable'), 20 * 1000, EftTransactionRequest);
        //+NPR5.53 [377533]
    end;

    local procedure InvokeAPI(Body: Text; APIKey: Text; URL: Text; TimeoutMs: Integer; EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        HttpWebRequest: DotNet npNetHttpWebRequest;
        ReqStream: DotNet npNetStream;
        ReqStreamWriter: DotNet npNetStreamWriter;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        ResponseStream: DotNet npNetStream;
        ResponseStreamReader: DotNet npNetStreamReader;
        HttpStatusCode: DotNet npNetHttpStatusCode;
        Response: Text;
        Convert: DotNet npNetConvert;
        WebRequestHelper: Codeunit "Web Request Helper";
        ResponseNavStream: InStream;
        ResponseHeaders: DotNet npNetNameValueCollection;
        WebException: DotNet npNetWebException;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        TempBlob: Codeunit "Temp Blob";
    begin
        //-NPR5.53 [377533]
        ClearRequestResponseBuffer();
        //+NPR5.53 [377533]
        //-NPR5.54 [387990]
        ClearResponseErrorBodyBuffer();
        ClearResponseStatusCodeBuffer();
        //+NPR5.54 [387990]

        AppendRequestResponseBuffer(Body, 'Request');

        HttpWebRequest := HttpWebRequest.Create(URL);
        HttpWebRequest.ContentType('application/json');
        HttpWebRequest.Headers.Add('x-api-key', APIKey);
        HttpWebRequest.Method('POST');
        HttpWebRequest.Timeout(TimeoutMs);
        //-NPR5.54 [387990]
        HttpWebRequest.KeepAlive(false);
        //+NPR5.54 [387990]

        ReqStream := HttpWebRequest.GetRequestStream;
        ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
        ReqStreamWriter.Write(Body);
        ReqStreamWriter.Flush;
        ReqStreamWriter.Close;

        //-NPR5.54 [387990]
        // HttpWebResponse := HttpWebRequest.GetResponse;
        // ResponseStream := HttpWebResponse.GetResponseStream;
        // ResponseStreamReader := ResponseStreamReader.StreamReader(ResponseStream);
        // Response := ResponseStreamReader.ReadToEnd();
        // HttpWebResponse.Close();
        // ResponseStreamReader.Close();
        //
        // AppendRequestResponseBuffer(Response, 'Response');
        //
        // IF NOT HttpWebResponse.StatusCode.Equals(HttpStatusCode.OK) THEN
        //  ERROR(ERROR_INVOKE, FORMAT(HttpWebResponse.StatusCode));

        TempBlob.CreateInStream(ResponseNavStream, TEXTENCODING::UTF8);

        if WebRequestHelper.GetWebResponse(HttpWebRequest, HttpWebResponse, ResponseNavStream, HttpStatusCode, ResponseHeaders, false) then begin
            while (not ResponseNavStream.EOS) do
                ResponseNavStream.Read(Response);
            AppendRequestResponseBuffer(Response, 'Response');
            ResponseStatusCodeBuffer := HttpWebResponse.StatusCode;
            HttpWebResponse.Close();
        end else begin
            ResponseErrorBodyBuffer := WebRequestHelper.GetWebResponseError(WebException, URL);
            if WebException.Status.Equals(WebExceptionStatus.ProtocolError) then begin
                HttpWebResponse := WebException.Response;
                ResponseStatusCodeBuffer := HttpWebResponse.StatusCode;
            end;
            AppendRequestResponseBuffer(StrSubstNo('(%1) %2', ResponseStatusCodeBuffer, ResponseErrorBodyBuffer), 'Response');
        end;

        if not (ResponseStatusCodeBuffer = 200) then begin
            Error(ERROR_INVOKE, URL, Format(ResponseStatusCodeBuffer));
        end;
        //+NPR5.54 [387990]

        exit(Response);
    end;

    local procedure "// Aux"()
    begin
    end;

    procedure GetAPIKey(EFTSetup: Record "EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        exit(EFTAdyenCloudIntegration.GetAPIKey(EFTSetup));
    end;

    local procedure GetTerminalURL(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
    begin
        case EFTTransactionRequest.Mode of
            EFTTransactionRequest.Mode::Production:
                exit('https://terminal-api-live.adyen.com/sync');
            EFTTransactionRequest.Mode::"TEST Remote":
                exit('https://terminal-api-test.adyen.com/sync');
            EFTTransactionRequest.Mode::"TEST Local":
                Error('Unsupported parameter, %1: %2', EFTTransactionRequest.FieldCaption(Mode), EFTTransactionRequest.Mode);
        end;
    end;

    local procedure GetRecurringURL(EFTTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"; Endpoint: Text): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
    begin
        //-NPR5.53 [377533]
        case EFTTransactionRequest.Mode of
            EFTTransactionRequest.Mode::Production:
                exit(StrSubstNo('https://%1-pal-live.adyenpayments.com/pal/servlet/Recurring/v49/%2', EFTAdyenCloudIntegration.GetRecurringURLPrefix(EFTSetup), Endpoint));
            EFTTransactionRequest.Mode::"TEST Remote":
                exit(StrSubstNo('https://pal-test.adyen.com/pal/servlet/Recurring/v49/%1', Endpoint));
            EFTTransactionRequest.Mode::"TEST Local":
                Error('Unsupported parameter, %1: %2', EFTTransactionRequest.FieldCaption(Mode), EFTTransactionRequest.Mode);
        end;
        //+NPR5.53 [377533]
    end;

    local procedure GetDateTime(): Text
    begin
        exit(Format(CurrentDateTime, 0, 9));
    end;

    local procedure GetTransactionDateTime(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        //-NPR5.53 [377533]
        exit(Format(EFTTransactionRequest.Started, 0, 9));
        //+NPR5.53 [377533]
    end;

    local procedure GetSaleToAcquirerData(EFTTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        Value: Text;
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
        CaptureDelayHours: Integer;
    begin
        //-NPR5.53 [377533]
        if (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then begin
            //+NPR5.53 [377533]
            Value := 'tenderOption=ReceiptHandler&tenderOption=GetAdditionalData';

            case EFTAdyenCloudIntegration.GetCreateRecurringContract(EFTSetup) of
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::NO:
                    ;
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::ONECLICK:
                    Value += '&recurringContract=ONECLICK&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::RECURRING:
                    Value += '&recurringContract=RECURRING&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::RECURRING_ONECLICK:
                    Value += '&recurringContract=ONECLICK,RECURRING&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
            end;

            CaptureDelayHours := EFTAdyenCloudIntegration.GetCaptureDelayHours(EFTSetup);
            if CaptureDelayHours >= 0 then
                Value += '&captureDelayHours=' + Format(CaptureDelayHours);

            //-NPR5.53 [377533]
        end else
            if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::VOID then begin
                Value := 'tenderOption=ReceiptHandler';
            end;
        //+NPR5.53 [377533]

        exit(Value);
    end;

    local procedure GetTransactionConditions(EFTTransactionRequest: Record "EFT Transaction Request"; EFTSetup: Record "EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        Condition: Integer;
        ConditionBrand: Text;
        Json: Text;
    begin
        Condition := EFTAdyenCloudIntegration.GetTransactionCondition(EFTSetup);
        case Condition of
            0:
                exit('');
            1:
                ConditionBrand := 'alipay';
            2:
                ConditionBrand := 'wechat';
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
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT,
          EFTTransactionRequest."Processing Type"::REFUND:
                exit(Format(EFTTransactionRequest."Amount Input", 0, 9));

            EFTTransactionRequest."Processing Type"::AUXILIARY:
                begin
                    EFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
                    exit(Format(EFTTransactionRequest."Amount Input", 0, 9));
                end;

            else
                EFTTransactionRequest.FieldError("Processing Type");
        end;
    end;

    local procedure GetCashbackAmount(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        exit(Format(EFTTransactionRequest."Cashback Amount", 0, 9));
    end;

    local procedure GetLookupCategory(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT,
          EFTTransactionRequest."Processing Type"::REFUND:
                exit('Payment');
            EFTTransactionRequest."Processing Type"::VOID:
                exit('Reversal');
            else
                Error('Unsupported lookup of %1 %2', EFTTransactionRequest.FieldCaption("Processing Type"), EFTTransactionRequest."Processing Type");
        end;
    end;

    local procedure GetAbortMessageCategory(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        EFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then
            exit('Payment');
        //-NPR5.53 [377533]
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and (EFTTransactionRequest."Auxiliary Operation ID" in [2, 4, 5]) then
            //+NPR5.53 [377533]
            exit('CardAcquisition');
    end;

    local procedure GetLinkedCardAcquisition(EFTTransactionRequest: Record "EFT Transaction Request"; var AcquireCardRequestOut: Record "EFT Transaction Request"): Boolean
    begin
        AcquireCardRequestOut.SetRange("Initiated from Entry No.", EFTTransactionRequest."Entry No.");
        AcquireCardRequestOut.SetRange("Processing Type", AcquireCardRequestOut."Processing Type"::AUXILIARY);
        AcquireCardRequestOut.SetRange("Auxiliary Operation ID", 2);
        AcquireCardRequestOut.SetRange(Successful, true);
        exit(AcquireCardRequestOut.FindFirst);
    end;

    local procedure GetCardAcquisitionJSON(EFTTransactionRequest: Record "EFT Transaction Request"; PrefixComma: Boolean): Text
    var
        AcquireCardRequest: Record "EFT Transaction Request";
        JsonConvert: DotNet JsonConvert;
        AcquireDateTime: DateTime;
        Output: Text;
    begin
        if not GetLinkedCardAcquisition(EFTTransactionRequest, AcquireCardRequest) then
            exit('');

        AcquireDateTime := CreateDateTime(AcquireCardRequest."Transaction Date", AcquireCardRequest."Transaction Time");

        if PrefixComma then
            Output += ',';

        Output +=
        '"CardAcquisitionReference":{' +
          '"TransactionID":' + JsonConvert.ToString(AcquireCardRequest."Reference Number Output") + ',' +
          '"TimeStamp":"' + Format(AcquireDateTime, 0, 9) + '"' +
        '}';

        exit(Output);
    end;

    local procedure GetCardAcquisitionTransactionJSON(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        //-NPR5.53 [377533]
        with EFTTransactionRequest do begin
            if ("Processing Type" in ["Processing Type"::PAYMENT, "Processing Type"::REFUND])
              or (("Processing Type" = "Processing Type"::AUXILIARY) and ("Auxiliary Operation ID" = 2)) then begin
                exit('"TotalAmount":' + GetAmount(EFTTransactionRequest));
            end else begin
                exit('');
            end;
        end;
        //+NPR5.53 [377533]
    end;

    local procedure CustomAbortAcquireTerminalMessage(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        OriginalTrxRequest: Record "EFT Transaction Request";
        JsonConvert: DotNet npNetJsonConvert;
    begin
        //-NPR5.53 [377533]
        if not OriginalTrxRequest.Get(EFTTransactionRequest."Processed Entry No.") then
            exit('');

        if not (OriginalTrxRequest."Auxiliary Operation ID" in [4, 5]) then
            exit('');

        exit(
          ',' +
          '"TransactionAction":"AbortTransaction",' +
          '"DisplayOutput": {' +
            '"Device": "CustomerDisplay",' +
            '"InfoQualify": "Display",' +
            '"OutputContent": {' +
                '"PredefinedContent": {' +
                    '"ReferenceID": "CustomAnimated"' +
                '},' +
                '"OutputFormat": "Text",' +
                '"OutputText": [' +
                    '{' +
                        '"Text": ' + JsonConvert.ToString(ABORT_ACQUIRE_SWIPE_HEADER) + '' +
                    '},' +
                    '{' +
                        '"Text": ' + JsonConvert.ToString(ABORT_ACQUIRE_SWIPE_LINE) + '' +
                    '}' +
                ']' +
            '}' +
        '}');
        //+NPR5.53 [377533]
    end;

    procedure CancelTrxIfTerminalThrewInProgressError(EFTTransactionRequest: Record "EFT Transaction Request"; Response: Text)
    var
        EFTAdyenAbortLastTrx: Codeunit "EFT Adyen Abort Unfinished Trx";
    begin
        //-NPR5.53 [377533]
        //If a previous transaction attempt is still running on the terminal (i.e. we are out of sync), attempt to cancel it to save us the risk of going financially out of sync as well.
        //This should only occur if NAV crashed or dialog force closed while waiting for a previous trx response.
        //We specifically look for the last hanging transaction on the CURRENT register no., to prevent automatic cancelling across registers for shared terminals.

        Commit;
        EFTAdyenAbortLastTrx.SetResponse(Response);
        if EFTAdyenAbortLastTrx.Run(EFTTransactionRequest) then; //Don't allow any errors. We are at the end of another transaction response handler
        //+NPR5.53 [377533]
    end;

    local procedure WriteLogEntry(EFTSetup: Record "EFT Setup"; IsError: Boolean; EntryNo: Integer; Description: Text; LogContents: Text)
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
    begin
        //-NPR5.53 [377533]
        case EFTAdyenCloudIntegration.GetLogLevel(EFTSetup) of
            EFTAdyenPaymentTypeSetup."Log Level"::ERROR:
                if IsError then
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents)
                else
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, '');

            EFTAdyenPaymentTypeSetup."Log Level"::FULL:
                EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents);

            EFTAdyenPaymentTypeSetup."Log Level"::NONE:
                EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, '');
        end;
        //+NPR5.53 [377533]
    end;

    local procedure AppendRequestResponseBuffer(Text: Text; Header: Text)
    var
        LF: Char;
        CR: Char;
        EFTSetup: Record "EFT Setup";
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        CR := 13;
        LF := 10;

        //-NPR5.53 [377533]
        //OutStream.WRITETEXT(FORMAT(CR) + FORMAT(LF) + FORMAT(CR) + FORMAT(LF) + '===' + Header + '===' + FORMAT(CR) + FORMAT(LF) + Text);

        RequestResponseBuffer += (Format(CR) + Format(LF) + Format(CR) + Format(LF) + '===' + Header + ' (' + Format(CreateDateTime(Today, Time), 0, 9) + ')===' + Format(CR) + Format(LF) + Text);
        //+NPR5.53 [377533]
    end;

    procedure ClearRequestResponseBuffer()
    begin
        //-NPR5.53 [377533]
        Clear(RequestResponseBuffer);
        //+NPR5.53 [377533]
    end;

    procedure GetRequestResponseBuffer(): Text
    begin
        //-NPR5.53 [377533]
        exit(RequestResponseBuffer);
        //+NPR5.53 [377533]
    end;

    procedure ClearResponseStatusCodeBuffer()
    begin
        //-NPR5.54 [387990]
        Clear(ResponseStatusCodeBuffer);
        //+NPR5.54 [387990]
    end;

    procedure GetResponseStatusCodeBuffer(): Integer
    begin
        //-NPR5.54 [387990]
        exit(ResponseStatusCodeBuffer);
        //+NPR5.54 [387990]
    end;

    procedure ClearResponseErrorBodyBuffer()
    begin
        //-NPR5.54 [387990]
        Clear(ResponseErrorBodyBuffer);
        //+NPR5.54 [387990]
    end;

    procedure GetResponseErrorBodyBuffer(): Text
    begin
        //-NPR5.54 [387990]
        exit(ResponseErrorBodyBuffer);
        //+NPR5.54 [387990]
    end;

    local procedure HandleError(var EFTTransactionRequest: Record "EFT Transaction Request"; ErrorText: Text)
    begin
        //-NPR5.53 [377533]
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."Result Amount" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        //+NPR5.53 [377533]
    end;

    local procedure HandleProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
    begin
        //-NPR5.53 [377533]
        EFTAdyenCloudIntegration.HandleProtocolResponse(EftTransactionRequest);
        //+NPR5.53 [377533]
    end;
}

