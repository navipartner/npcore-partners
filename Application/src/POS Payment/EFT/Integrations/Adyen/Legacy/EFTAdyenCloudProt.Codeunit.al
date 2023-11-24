﻿#if not CLOUD
codeunit 6184518 "NPR EFT Adyen Cloud Prot."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR28.0';
    ObsoleteReason = 'Replaced with version without .NET variables';

    trigger OnRun()
    begin
    end;

    var
        ERROR_INVOKE: Label 'Error: Service endpoint responded with HTTP status %1';
        RequestResponseBuffer: Text;
        ABORT_ACQUIRE_SWIPE_HEADER: Label 'Card Scanned';
        ABORT_ACQUIRE_SWIPE_LINE: Label 'Please Remove Card';
        ResponseStatusCodeBuffer: Integer;
        ResponseErrorBodyBuffer: Text;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; OpenDialog: Boolean)
    begin
        // All the request types that show a front-end dialog while waiting for terminal customer interaction, are asynchronous using STARTSESSION to perform a long timeout webservice request.
        // The POS user session will poll a table until a response record appears or timeout is reached.
        // The reason is that Adyens transaction API requires concurrent requests which a single user session does not support in pure C/AL.

        //-NPR5.55 [386254]
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT:
                StartPaymentTransaction(EftTransactionRequest, OpenDialog); //Via async dialog & background session
            EftTransactionRequest."Processing Type"::REFUND:
                StartRefundTransaction(EftTransactionRequest, OpenDialog); //Via async dialog & background session
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
                        StartAcquireCard(EftTransactionRequest, OpenDialog); //Via async dialog & background session
                    3:
                        AbortAcquireCard(EftTransactionRequest); //via blocking ws invoke
                    4:
                        StartAcquireCard(EftTransactionRequest, OpenDialog); //Via async dialog & background session
                    5:
                        StartAcquireCard(EftTransactionRequest, OpenDialog); //Via async dialog & background session
                    6:
                        DisableRecurringContract(EftTransactionRequest); //via blocking ws invoke
                end;
        end;
        //+NPR5.55 [386254]
    end;

    local procedure StartPaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; OpenDialog: Boolean)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        SessionId: Integer;
        EFTAdyenCloudTrxDialog: Codeunit "NPR EFT Adyen Cloud Trx Dia.";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        AcquireCardRequest: Record "NPR EFT Transaction Request";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        QueuedTrxSessionLbl: Label 'Queued trx session ID %1';
        QueuedLookupSessionLbl: Label 'Queued lookup session ID %1';
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);

        Commit();

        StartSession(SessionId, CODEUNIT::"NPR EFT Adyen Bnd. Trx Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo(QueuedTrxSessionLbl, SessionId), '');

        Clear(SessionId);
        StartSession(SessionId, CODEUNIT::"NPR EFT Adyen Bgd. Lookup Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo(QueuedLookupSessionLbl, SessionId), '');

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if (EFTAdyenCloudIntegration.GetAcquireCardFirst(EFTSetup) or (EFTAdyenCloudIntegration.GetCreateRecurringContract(EFTSetup) <> 0)) then
            if GetLinkedCardAcquisition(EftTransactionRequest, AcquireCardRequest) then
                exit; //Dialog already open

        if OpenDialog then
            EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndPaymentTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
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
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    local procedure StartRefundTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; OpenDialog: Boolean)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        SessionId: Integer;
        EFTAdyenCloudTrxDialog: Codeunit "NPR EFT Adyen Cloud Trx Dia.";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        AcquireCardRequest: Record "NPR EFT Transaction Request";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        QueuedTrxSessionLbl: Label 'Queued trx session ID %1';
        QueuedLookupSessionLbl: Label 'Queued lookup session ID %1';
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);

        Commit();

        StartSession(SessionId, CODEUNIT::"NPR EFT Adyen Bnd. Trx Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo(QueuedTrxSessionLbl, SessionId), '');

        Clear(SessionId);
        StartSession(SessionId, CODEUNIT::"NPR EFT Adyen Bgd. Lookup Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo(QueuedLookupSessionLbl, SessionId), '');

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        if EFTAdyenCloudIntegration.GetAcquireCardFirst(EFTSetup) then
            if GetLinkedCardAcquisition(EftTransactionRequest, AcquireCardRequest) then
                exit; //Dialog already open

        if OpenDialog then
            EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndRefundTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
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
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    local procedure VoidTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: Text;
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        if OriginalEFTTransactionRequest.Recovered then
            OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Recovered by Entry No.");

        if not InvokeVoid(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
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
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        Response: Text;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeLookup(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, 1000 * 60, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
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
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    local procedure SetupTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        Response: Text;
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeDiagnoseTerminal(EftTransactionRequest, EFTSetup, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
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
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    procedure AbortTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(OriginalEFTTransactionRequest."Register No.", OriginalEFTTransactionRequest."Original POS Payment Type Code");

        if InvokeAbortTransaction(EFTTransactionRequest, EFTSetup) then begin
            EFTTransactionRequest."External Result Known" := true;
            EFTTransactionRequest.Successful := true;
        end else
            EFTTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));

        EFTTransactionRequest.Modify();

        HandleProtocolResponse(EFTTransactionRequest);
    end;

    procedure ForceCloseTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
    begin
        EFTTrxBackgroundSessionMgt.MarkRequestAsDone(EFTTransactionRequest."Entry No.");

        EFTTransactionRequest."Force Closed" := true;
        EFTTransactionRequest.Modify();

        HandleProtocolResponse(EFTTransactionRequest);

        //-NPR5.54 [387990]
        EFTAdyenCloudIntegration.ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest);
        //+NPR5.54 [387990]
    end;

    local procedure StartAcquireCard(EftTransactionRequest: Record "NPR EFT Transaction Request"; OpenDialog: Boolean)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        SessionId: Integer;
        EFTAdyenCloudTrxDialog: Codeunit "NPR EFT Adyen Cloud Trx Dia.";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        QueuedTrxSessionLbl: Label 'Queued trx session ID %1';
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);

        Commit();

        StartSession(SessionId, CODEUNIT::"NPR EFT Adyen Bnd. Trx Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo(QueuedTrxSessionLbl, SessionId), '');

        if OpenDialog then
            EFTAdyenCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndAcquireCard(EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
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
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);

        if (not EftTransactionRequest.Successful) then begin
            EFTAdyenCloudIntegration.ProcessOriginalTrxAfterAcquireCardFailure(EftTransactionRequest);
        end;

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    local procedure AbortAcquireCard(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        Response: Text;
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeAbortAcquireCard(EftTransactionRequest, EFTSetup, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
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
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure DisableRecurringContract(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        ParseSuccess: Boolean;
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeDisableRecurringContract(EftTransactionRequest, EFTSetup, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTAdyenResponseParser.SetResponseData('DisableContract', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
    end;

    procedure ProcessAsyncResponse(TransactionEntryNo: Integer)
    var
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        InStream: InStream;
        Text: Text;
        Response: Text;
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
    begin
        EFTTrxBackgroundSessionMgt.TryGetResponseRecord(TransactionEntryNo, EFTTransactionAsyncResponse);

        if EFTTransactionAsyncResponse.Error then begin
            EFTTransactionRequest.LockTable();
            EFTTransactionRequest.Get(TransactionEntryNo);
            EFTTransactionRequest."NST Error" := EFTTransactionAsyncResponse."Error Text";
            EFTTransactionRequest."External Result Known" := not EFTTransactionAsyncResponse."Transaction Started";
            EFTAdyenCloudIntegration.ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest);
            HandleProtocolResponse(EFTTransactionRequest);
        end else begin
            EFTTransactionAsyncResponse.Response.CreateInStream(InStream, TEXTENCODING::UTF8);
            while (not InStream.EOS) do begin
                InStream.ReadText(Text);
                Response += Text;
            end;

            EFTTransactionAsyncResponse.Delete();
            Commit();
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
    end;


    [TryFunction]
    procedure InvokePayment(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
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
                    GetTransactionConditions(EFTSetup) +
                 '},' +
                 '"PaymentData":{' +
                    GetCardAcquisitionJSON(EftTransactionRequest, false) +
                 '}' +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 600 * 1000);
    end;

    [TryFunction]
    procedure InvokeRefund(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
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
                       '"TimeStamp":"' + GetDateTime() + '",' +
                       '"TransactionID":' + JsonConvert.ToString(EftTransactionRequest."Sales Ticket No.") + '' +
                    '},' +
                    '"SaleReferenceID":' + JsonConvert.ToString(EftTransactionRequest.Token) +
                 '},' +
                 '"PaymentTransaction":{' +
                    GetTransactionConditions(EFTSetup) +
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

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 600 * 1000);
    end;

    [TryFunction]
    local procedure InvokeVoid(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"; var Response: Text)
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
                 '"OriginalPOITransaction":{' +
                    '"POITransactionID":{' +
                       '"TimeStamp":"' + GetTransactionDateTime(OriginalEFTTransactionRequest) + '",' +
                       '"TransactionID":' + JsonConvert.ToString(OriginalEFTTransactionRequest."Reference Number Output") + '' +
                    '}' +
                 '},' +
                 '"ReversalReason":"MerchantCancel"' +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 20 * 1000);
    end;

    [TryFunction]
    local procedure InvokeAbortTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup")
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

        InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 10 * 1000);
    end;

    [TryFunction]
    procedure InvokeAcquireCard(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
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
                       '"TimeStamp":"' + GetDateTime() + '",' +
                       '"TransactionID":' + JsonConvert.ToString(EftTransactionRequest."Sales Ticket No.") +
                    '}' +
                 '},' +
                 '"CardAcquisitionTransaction":{' +
                      GetCardAcquisitionTransactionJSON(EftTransactionRequest) +
                  '}' +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 600 * 1000);
    end;

    [TryFunction]
    local procedure InvokeAbortAcquireCard(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
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
                 CustomAbortAcquireTerminalMessage(EftTransactionRequest) +
              '}' +
           '}' +
        '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 10 * 1000);
    end;

    [TryFunction]
    procedure InvokeLookup(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; OriginalEftTransactionRequest: Record "NPR EFT Transaction Request"; TimeoutMs: Integer; var Response: Text)
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

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), TimeoutMs);
    end;

    [TryFunction]
    local procedure InvokeDiagnoseTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
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

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetTerminalURL(EftTransactionRequest), 20 * 1000);
    end;

    [TryFunction]
    procedure InvokeDisableRecurringContract(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        JsonConvert: DotNet NPRNetJsonConvert;
    begin
        Body :=
         '{' +
           '"shopperReference":' + JsonConvert.ToString(EftTransactionRequest."External Customer ID") + ',' +
           '"merchantAccount":' + JsonConvert.ToString(EFTAdyenCloudIntegration.GetMerchantAccount(EFTSetup)) +
         '}';

        Response := InvokeAPI(Body, GetAPIKey(EFTSetup), GetRecurringURL(EftTransactionRequest, EFTSetup, 'disable'), 20 * 1000);
    end;

    local procedure InvokeAPI(Body: Text; APIKey: Text; URL: Text; TimeoutMs: Integer): Text
    var
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        ReqStream: DotNet NPRNetStream;
        ReqStreamWriter: DotNet NPRNetStreamWriter;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        HttpStatusCode: DotNet NPRNetHttpStatusCode;
        Response: Text;
        WebRequestHelper: Codeunit "Web Request Helper";
        ResponseNavStream: InStream;
        ResponseHeaders: DotNet NPRNetNameValueCollection;
        WebException: DotNet NPRNetWebException;
        WebExceptionStatus: DotNet NPRNetWebExceptionStatus;
        TempBlob: Codeunit "Temp Blob";
        ResponseLbl: Label '(%1) %2', Locked = true;
    begin
        ClearRequestResponseBuffer();

        ClearResponseErrorBodyBuffer();
        ClearResponseStatusCodeBuffer();

        AppendRequestResponseBuffer(Body, 'Request');

        HttpWebRequest := HttpWebRequest.Create(URL);
        HttpWebRequest.ContentType('application/json');
        HttpWebRequest.Headers.Add('x-api-key', APIKey);
        HttpWebRequest.Method('POST');
        HttpWebRequest.Timeout(TimeoutMs);
        HttpWebRequest.KeepAlive(false);

        ReqStream := HttpWebRequest.GetRequestStream();
        ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
        ReqStreamWriter.Write(Body);
        ReqStreamWriter.Flush();
        ReqStreamWriter.Close();

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
            AppendRequestResponseBuffer(StrSubstNo(ResponseLbl, ResponseStatusCodeBuffer, ResponseErrorBodyBuffer), 'Response');
        end;

        if not (ResponseStatusCodeBuffer = 200) then begin
            Error(ERROR_INVOKE, Format(ResponseStatusCodeBuffer));
        end;

        exit(Response);
    end;

    procedure GetAPIKey(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
    begin
        exit(EFTAdyenCloudIntegration.GetAPIKey(EFTSetup));
    end;

    local procedure GetTerminalURL(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
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

    local procedure GetRecurringURL(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; Endpoint: Text): Text
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        UriLiveLbl: Label 'https://%1-pal-live.adyenpayments.com/pal/servlet/Recurring/v49/%2', Locked = true;
        UriTestRemoteLbl: Label 'https://pal-test.adyen.com/pal/servlet/Recurring/v49/%1', Locked = true;
    begin
        case EFTTransactionRequest.Mode of
            EFTTransactionRequest.Mode::Production:
                exit(StrSubstNo(UriLiveLbl, EFTAdyenCloudIntegration.GetRecurringURLPrefix(EFTSetup), Endpoint));
            EFTTransactionRequest.Mode::"TEST Remote":
                exit(StrSubstNo(UriTestRemoteLbl, Endpoint));
            EFTTransactionRequest.Mode::"TEST Local":
                Error('Unsupported parameter, %1: %2', EFTTransactionRequest.FieldCaption(Mode), EFTTransactionRequest.Mode);
        end;
    end;

    local procedure GetDateTime(): Text
    begin
        exit(Format(CurrentDateTime(), 0, 9));
    end;

    local procedure GetTransactionDateTime(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(Format(EFTTransactionRequest.Started, 0, 9));
    end;

    local procedure GetSaleToAcquirerData(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        Value: Text;
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        CaptureDelayHours: Integer;
    begin
        if (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then begin
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

        end else
            if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::VOID then begin
                Value := 'tenderOption=ReceiptHandler';
            end;

        exit(Value);
    end;

    local procedure GetTransactionConditions(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        Condition: Integer;
        ConditionBrand: Text;
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

    local procedure GetAmount(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
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

    local procedure GetCashbackAmount(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(Format(EFTTransactionRequest."Cashback Amount", 0, 9));
    end;

    local procedure GetLookupCategory(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
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

    local procedure GetAbortMessageCategory(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        EFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then
            exit('Payment');
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and (EFTTransactionRequest."Auxiliary Operation ID" in [2, 4, 5]) then
            exit('CardAcquisition');
    end;

    local procedure GetLinkedCardAcquisition(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var AcquireCardRequestOut: Record "NPR EFT Transaction Request"): Boolean
    begin
        AcquireCardRequestOut.SetRange("Initiated from Entry No.", EFTTransactionRequest."Entry No.");
        AcquireCardRequestOut.SetRange("Processing Type", AcquireCardRequestOut."Processing Type"::AUXILIARY);
        AcquireCardRequestOut.SetRange("Auxiliary Operation ID", 2);
        AcquireCardRequestOut.SetRange(Successful, true);
        exit(AcquireCardRequestOut.FindFirst());
    end;

    local procedure GetCardAcquisitionJSON(EFTTransactionRequest: Record "NPR EFT Transaction Request"; PrefixComma: Boolean): Text
    var
        AcquireCardRequest: Record "NPR EFT Transaction Request";
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

    local procedure GetCardAcquisitionTransactionJSON(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        if (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND])
  or ((EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and (EFTTransactionRequest."Auxiliary Operation ID" = 2)) then begin
            exit('"TotalAmount":' + GetAmount(EFTTransactionRequest));
        end else begin
            exit('');
        end;
    end;

    local procedure CustomAbortAcquireTerminalMessage(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        OriginalTrxRequest: Record "NPR EFT Transaction Request";
        JsonConvert: DotNet NPRNetJsonConvert;
    begin
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
    end;

    procedure CancelTrxIfTerminalThrewInProgressError(EFTTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenAbortLastTrx: Codeunit "NPR EFT Adyen Abort Unfin. Trx";
    begin
        //If a previous transaction attempt is still running on the terminal (i.e. we are out of sync), attempt to cancel it to save us the risk of going financially out of sync as well.
        //This should only occur if NAV crashed or dialog force closed while waiting for a previous trx response.
        //We specifically look for the last hanging transaction on the CURRENT register no., to prevent automatic cancelling across registers for shared terminals.

        Commit();
        EFTAdyenAbortLastTrx.SetResponse(Response);
        if EFTAdyenAbortLastTrx.Run(EFTTransactionRequest) then; //Don't allow any errors. We are at the end of another transaction response handler
    end;

    local procedure WriteLogEntry(EFTSetup: Record "NPR EFT Setup"; IsError: Boolean; EntryNo: Integer; Description: Text; LogContents: Text)
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
    begin
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
    end;

    local procedure AppendRequestResponseBuffer(Text: Text; Header: Text)
    var
        LF: Char;
        CR: Char;
    begin
        CR := 13;
        LF := 10;

        RequestResponseBuffer += (Format(CR) + Format(LF) + Format(CR) + Format(LF) + '===' + Header + ' (' + Format(CreateDateTime(Today, Time), 0, 9) + ')===' + Format(CR) + Format(LF) + Text);
    end;

    procedure ClearRequestResponseBuffer()
    begin
        Clear(RequestResponseBuffer);
    end;

    procedure GetRequestResponseBuffer(): Text
    begin
        exit(RequestResponseBuffer);
    end;

    procedure ClearResponseStatusCodeBuffer()
    begin
        Clear(ResponseStatusCodeBuffer);
    end;

    procedure GetResponseStatusCodeBuffer(): Integer
    begin
        exit(ResponseStatusCodeBuffer);
    end;

    procedure ClearResponseErrorBodyBuffer()
    begin
        Clear(ResponseErrorBodyBuffer);
    end;

    procedure GetResponseErrorBodyBuffer(): Text
    begin
        exit(ResponseErrorBodyBuffer);
    end;

    local procedure HandleError(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ErrorText: Text)
    begin
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."Result Amount" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
    end;

    local procedure HandleProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
    begin
        EFTAdyenCloudIntegration.HandleProtocolResponse(EftTransactionRequest);
    end;
}
#endif
