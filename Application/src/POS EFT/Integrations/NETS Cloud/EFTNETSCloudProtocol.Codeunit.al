codeunit 6184534 "NPR EFT NETSCloud Protocol"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020
    // NPR5.55/MMV /20200525 CASE 405984 Fixed undocumented breaking change in NETS backend update.


    trigger OnRun()
    begin
    end;

    var
        ERROR_INVOKE: Label 'Error: Service endpoint %1 responded with HTTP status %2';
        RequestResponseBuffer: Text;
        ResponseStatusCodeBuffer: Integer;
        ResponseErrorBodyBuffer: Text;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        // All the request types that show a front-end dialog while waiting for terminal customer interaction, are asynchronous using STARTSESSION to perform a long timeout webservice request.
        // The POS user session will poll a table until a response record appears or timeout is reached.
        // The reason is that NETS API requires concurrent requests which a single user session does not support in pure C/AL.

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::CLOSE:
                Reconciliation(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::PAYMENT:
                StartPaymentTransaction(EftTransactionRequest); //Via async dialog & background session
            EftTransactionRequest."Processing Type"::REFUND:
                StartRefundTransaction(EftTransactionRequest); //Via async dialog & background session
            EftTransactionRequest."Processing Type"::VOID:
                VoidTransaction(EftTransactionRequest); //Via blocking ws invoke
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupLastTransaction(EftTransactionRequest); //Via blocking ws invoke
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        CancelAction(EftTransactionRequest); //Via blocking ws invoke
                    2:
                        BalanceEnquiry(EftTransactionRequest); //Via blocking ws invoke
                    3:
                        DownloadDataset(EftTransactionRequest); //Via blocking ws invoke
                    4:
                        DownloadSoftware(EftTransactionRequest); //Via blocking ws invoke
                end;
        end;
    end;

    local procedure "// Operations"()
    begin
    end;

    local procedure Reconciliation(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        EFTNETSResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeReconciliation(EftTransactionRequest, EFTSetup, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTNETSResponseParser.SetResponseData('Reconciliation', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure StartPaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        SessionId: Integer;
        EFTNETSCloudTrxDialog: Codeunit "NPR EFT NETSCloud Trx Dialog";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        EFTSetup: Record "NPR EFT Setup";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);
        Commit();

        StartSession(SessionId, CODEUNIT::"NPR EFT NETSCloud Bg. Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo('Queued trx session ID %1', SessionId), '');

        EFTNETSCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndPaymentTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTNETSResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
    begin
        EFTNETSResponseParser.SetResponseData('Payment', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    local procedure StartRefundTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        SessionId: Integer;
        EFTNETSCloudTrxDialog: Codeunit "NPR EFT NETSCloud Trx Dialog";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        EFTSetup: Record "NPR EFT Setup";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        EFTTrxBackgroundSessionMgt.CreateRequestRecord(EftTransactionRequest, EFTTransactionAsyncRequest);
        Commit();

        StartSession(SessionId, CODEUNIT::"NPR EFT NETSCloud Bg. Req.", CompanyName, EFTTransactionAsyncRequest);
        EFTTransactionLoggingMgt.WriteLogEntry(EftTransactionRequest."Entry No.", StrSubstNo('Queued trx session ID %1', SessionId), '');

        EFTNETSCloudTrxDialog.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EndRefundTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
    begin
        EFTNETSCloudResponseParser.SetResponseData('Payment', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
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
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
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

        EFTNETSCloudResponseParser.SetResponseData('VoidLast', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    local procedure LookupLastTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        Response: Text;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
    begin
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeLookupLastTransaction(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, 1000 * 60, Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('LookupLast', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EftTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EftTransactionRequest, Response);
        end;
    end;

    procedure CancelAction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: Text;
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
    begin
        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(OriginalEFTTransactionRequest."Register No.", OriginalEFTTransactionRequest."Original POS Payment Type Code");

        if not InvokeCancelAction(EFTTransactionRequest, EFTSetup, Response) then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
            HandleProtocolResponse(EFTTransactionRequest);
            WriteLogEntry(EFTSetup, true, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('Cancel', Response, EFTTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EFTTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EFTTransactionRequest, Response);
        end;
    end;

    local procedure BalanceEnquiry(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        ParseSuccess: Boolean;
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not InvokeBalanceEnquiry(EFTTransactionRequest, EFTSetup, Response) then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
            HandleProtocolResponse(EFTTransactionRequest);
            WriteLogEntry(EFTSetup, true, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('BalanceEnquiry', Response, EFTTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EFTTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EFTTransactionRequest, Response);
        end;
    end;

    local procedure DownloadDataset(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        ParseSuccess: Boolean;
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not InvokeDownloadDataset(EFTTransactionRequest, EFTSetup, Response) then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
            HandleProtocolResponse(EFTTransactionRequest);
            WriteLogEntry(EFTSetup, true, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('TerminalDataset', Response, EFTTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EFTTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EFTTransactionRequest, Response);
        end;
    end;

    local procedure DownloadSoftware(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        ParseSuccess: Boolean;
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not InvokeDownloadSoftware(EFTTransactionRequest, EFTSetup, Response) then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
            HandleProtocolResponse(EFTTransactionRequest);
            WriteLogEntry(EFTSetup, true, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('TerminalSoftware', Response, EFTTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EFTTransactionRequest."Entry No.", 'Invoke result', GetRequestResponseBuffer());

        HandleProtocolResponse(EFTTransactionRequest);

        if ParseSuccess then begin
            CancelTrxIfTerminalThrewInProgressError(EFTTransactionRequest, Response);
        end;
    end;

    procedure TerminalList(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        Response: Text;
    begin
        //Invoked from setup, not logged, dummy eft trx record
        EFTTransactionRequest."Integration Type" := EFTNETSCloudIntegration.IntegrationType();
        EFTTransactionRequest."Hardware ID" := EFTNETSCloudIntegration.GetTerminalID(EFTSetup);
        if EFTNETSCloudIntegration.GetEnvironment(EFTSetup) <> 0 then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";

        InvokeTerminalList(EFTTransactionRequest, EFTSetup, Response);
        exit(Response);
    end;

    procedure TerminalSettings(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        Response: Text;
    begin
        //Invoked from setup, not logged, dummy eft trx record
        EFTTransactionRequest."Integration Type" := EFTNETSCloudIntegration.IntegrationType();
        EFTTransactionRequest."Hardware ID" := EFTNETSCloudIntegration.GetTerminalID(EFTSetup);
        if EFTNETSCloudIntegration.GetEnvironment(EFTSetup) <> 0 then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";

        InvokeTerminalSettings(EFTTransactionRequest, EFTSetup, Response);
        exit(Response);
    end;

    local procedure LoginAndGetToken(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        Response: Text;
    begin
        //Invoked implicitly by all requests if token is missing/expired, not logged, dummy eft trx record
        EFTTransactionRequest."Integration Type" := EFTNETSCloudIntegration.IntegrationType();
        EFTTransactionRequest."Hardware ID" := EFTNETSCloudIntegration.GetTerminalID(EFTSetup);
        if EFTNETSCloudIntegration.GetEnvironment(EFTSetup) <> 0 then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";

        InvokeLogin(EFTTransactionRequest, EFTSetup, Response);
        exit(Response);
    end;

    procedure ForceCloseTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
    begin
        EFTTrxBackgroundSessionMgt.MarkRequestAsDone(EFTTransactionRequest."Entry No.");

        EFTTransactionRequest."Force Closed" := true;
        EFTTransactionRequest.Modify();

        HandleProtocolResponse(EFTTransactionRequest);
    end;

    procedure ProcessAsyncResponse(TransactionEntryNo: Integer)
    var
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        InStream: InStream;
        Text: Text;
        Response: Text;
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
    begin
        EFTTrxBackgroundSessionMgt.TryGetResponseRecord(TransactionEntryNo, EFTTransactionAsyncResponse);

        if EFTTransactionAsyncResponse.Error then begin
            EFTTransactionRequest.LockTable();
            EFTTransactionRequest.Get(TransactionEntryNo);
            EFTTransactionRequest."NST Error" := EFTTransactionAsyncResponse."Error Text";
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
            end;
        end;
    end;

    local procedure "// API"()
    begin
    end;

    [TryFunction]
    local procedure InvokeLogin(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        JsonConvert: DotNet NPRNetJsonConvert;
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"username":' + JsonConvert.ToString(EFTNETSCloudIntegration.GetAPIUsername(EFTSetup)) + ',' +
          '"password":' + JsonConvert.ToString(EFTNETSCloudIntegration.GetAPIPassword(EFTSetup)) +
        '}';

        Endpoint := '/v1/login';
        Response := InvokeAPI(Body, '', GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 10 * 1000, EftTransactionRequest, false);
    end;

    [TryFunction]
    local procedure InvokeReconciliation(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"action":"reconciliation"' +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/administration', EftTransactionRequest."Hardware ID");
        //-NPR5.55 [405984]
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 60 * 1000, EftTransactionRequest, true);
        //+NPR5.55 [405984]
    end;

    [TryFunction]
    procedure InvokePayment(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        JsonConvert: DotNet NPRNetJsonConvert;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"transactionType": "purchase",' +
          '"amount":' + JsonConvert.ToString(GetAmount(EftTransactionRequest)) +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/transaction', EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 600 * 1000, EftTransactionRequest, true);
    end;

    [TryFunction]
    procedure InvokeRefund(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        JsonConvert: DotNet NPRNetJsonConvert;
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"transactionType": "returnOfGoods",' +
          '"amount":' + JsonConvert.ToString(GetAmount(EftTransactionRequest)) +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/transaction', EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 600 * 1000, EftTransactionRequest, true);
    end;

    [TryFunction]
    local procedure InvokeVoid(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"; var Response: Text)
    var
        JsonConvert: DotNet NPRNetJsonConvert;
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"amount":' + JsonConvert.ToString(GetAmount(EftTransactionRequest)) +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/transaction', EftTransactionRequest."Hardware ID");
        //-NPR5.55 [405984]
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'DELETE', Endpoint, 60 * 1000, EftTransactionRequest, true);
        //+NPR5.55 [405984]
    end;

    [TryFunction]
    procedure InvokeLookupLastTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; OriginalEftTransactionRequest: Record "NPR EFT Transaction Request"; TimeoutMs: Integer; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '';

        Endpoint := StrSubstNo('/v1/terminal/%1/transaction', EftTransactionRequest."Hardware ID");
        //-NPR5.55 [405984]
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'GET', Endpoint, TimeoutMs, EftTransactionRequest, true);
        //+NPR5.55 [405984]
    end;

    [TryFunction]
    local procedure InvokeCancelAction(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"action" : "cancelAction"' +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/administration', EftTransactionRequest."Hardware ID");
        //-NPR5.55 [405984]
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 10 * 1000, EftTransactionRequest, true);
        //+NPR5.55 [405984]
    end;

    [TryFunction]
    local procedure InvokeDownloadDataset(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"action" : "downloadDataset"' +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/administration', EftTransactionRequest."Hardware ID");
        //-NPR5.55 [405984]
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 600 * 1000, EftTransactionRequest, true);
        //+NPR5.55 [405984]
    end;

    [TryFunction]
    local procedure InvokeDownloadSoftware(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"action" : "downloadSoftware"' +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/administration', EftTransactionRequest."Hardware ID");
        //-NPR5.55 [405984]
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 600 * 1000, EftTransactionRequest, true);
        //+NPR5.55 [405984]
    end;

    [TryFunction]
    local procedure InvokeBalanceEnquiry(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '{' +
          '"action" : "balanceInquiry"' +
        '}';

        Endpoint := StrSubstNo('/v1/terminal/%1/administration', EftTransactionRequest."Hardware ID");
        //-NPR5.55 [405984]
        Response := InvokeAPI(Body, GetTokenFromRequestRecord(EftTransactionRequest), GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 600 * 1000, EftTransactionRequest, true);
        //+NPR5.55 [405984]
    end;

    [TryFunction]
    local procedure InvokeTerminalSettings(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '';

        Endpoint := StrSubstNo('/v1/terminal/%1/settings', EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, GetToken(EFTSetup), GetServiceURL(EftTransactionRequest), 'GET', Endpoint, 10 * 1000, EftTransactionRequest, false);
    end;

    [TryFunction]
    local procedure InvokeTerminalList(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '';

        Endpoint := '/v1/terminal';
        Response := InvokeAPI(Body, GetToken(EFTSetup), GetServiceURL(EftTransactionRequest), 'GET', Endpoint, 10 * 1000, EftTransactionRequest, false);
    end;

    local procedure InvokeAPI(Body: Text; Token: Text; URL: Text; Method: Text; Endpoint: Text; TimeoutMs: Integer; EFTTransactionRequest: Record "NPR EFT Transaction Request"; AllowBadRequest: Boolean): Text
    var
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        ReqStream: DotNet NPRNetStream;
        ReqStreamWriter: DotNet NPRNetStreamWriter;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        ResponseNavStream: InStream;
        HttpStatusCode: DotNet NPRNetHttpStatusCode;
        Response: Text;
        WebRequestHelper: Codeunit "Web Request Helper";
        ResponseHeaders: DotNet NPRNetNameValueCollection;
        WebException: DotNet NPRNetWebException;
        WebExceptionStatus: DotNet NPRNetWebExceptionStatus;
        TempBlob: Codeunit "Temp Blob";
        ResponseText: Text;
    begin
        ClearRequestResponseBuffer();
        ClearResponseErrorBodyBuffer();
        ClearResponseStatusCodeBuffer();

        AppendRequestResponseBuffer(Body, 'Request');

        HttpWebRequest := HttpWebRequest.Create(URL + Endpoint);
        if Token <> '' then begin
            HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + Token);
        end;
        HttpWebRequest.Method(Method);
        HttpWebRequest.Timeout(TimeoutMs);
        HttpWebRequest.KeepAlive(false);

        if Method <> 'GET' then begin
            HttpWebRequest.ContentType('application/json');

            ReqStream := HttpWebRequest.GetRequestStream;
            ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
            ReqStreamWriter.Write(Body);
            ReqStreamWriter.Flush;
            ReqStreamWriter.Close();
        end;

        TempBlob.CreateInStream(ResponseNavStream, TEXTENCODING::UTF8);

        if WebRequestHelper.GetWebResponse(HttpWebRequest, HttpWebResponse, ResponseNavStream, HttpStatusCode, ResponseHeaders, false) then begin
            while (not ResponseNavStream.EOS) do begin
                ResponseNavStream.Read(ResponseText);
                Response += ResponseText;
            end;
            ResponseStatusCodeBuffer := HttpWebResponse.StatusCode;
            AppendRequestResponseBuffer(StrSubstNo('(%1)   \\%2', ResponseStatusCodeBuffer, Response), 'Response');
            HttpWebResponse.Close();
        end else begin
            ResponseErrorBodyBuffer := WebRequestHelper.GetWebResponseError(WebException, URL);
            if WebException.Status.Equals(WebExceptionStatus.ProtocolError) then begin
                HttpWebResponse := WebException.Response;
                ResponseStatusCodeBuffer := HttpWebResponse.StatusCode;
                HttpWebResponse.GetResponseStream.CopyTo(ResponseNavStream);
                while (not ResponseNavStream.EOS) do begin
                    ResponseNavStream.Read(ResponseText);
                    Response += ResponseText;
                end;
            end;
            AppendRequestResponseBuffer(StrSubstNo('(%1) %2   \\%3', ResponseStatusCodeBuffer, ResponseErrorBodyBuffer, Response), 'Response');
        end;

        if not ((ResponseStatusCodeBuffer in [200, 201]) or (AllowBadRequest and (ResponseStatusCodeBuffer = 400))) then begin
            Error(ERROR_INVOKE, URL, Format(ResponseStatusCodeBuffer));
        end;

        exit(Response);
    end;

    local procedure "// Aux"()
    begin
    end;

    procedure GetToken(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        Token: Text;
        JSON: Text;
        JObject: DotNet NPRNetJObject;
    begin
        if EFTNETSCloudToken.TryGetToken(Token) then
            exit(Token);

        JSON := LoginAndGetToken(EFTSetup);
        JObject := JObject.Parse(JSON);
        Token := JObject.Item('token').ToString();

        EFTNETSCloudToken.SetToken(Token);
        exit(Token);
    end;

    local procedure GetTokenFromRequestRecord(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        InStream: InStream;
        TextBuffer: Text;
        Token: Text;
    begin
        EFTTransactionRequest.CalcFields("Access Token");
        EFTTransactionRequest."Access Token".CreateInStream(InStream, TEXTENCODING::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(TextBuffer);
            Token += TextBuffer;
        end;
        exit(Token);
    end;

    local procedure GetServiceURL(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        case EFTTransactionRequest.Mode of
            EFTTransactionRequest.Mode::Production:
                exit('https://api1.cloudconnect.nets.eu');
            EFTTransactionRequest.Mode::"TEST Remote":
                exit('https://testapi.cloudconnect.ml:8080');
            EFTTransactionRequest.Mode::"TEST Local":
                EFTTransactionRequest.FieldError(Mode);
        end;
    end;

    local procedure GetDateTime(): Text
    begin
        exit(Format(CurrentDateTime, 0, 9));
    end;

    local procedure GetAmount(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(DelChr(Format(Abs(EFTTransactionRequest."Amount Input"), 0, '<Precision,2:2><Standard Format,9>'), '=', '.'));
    end;

    local procedure GetCashbackAmount(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(DelChr(Format(EFTTransactionRequest."Cashback Amount", 0, '<Precision,2:2><Standard Format,9>'), '=', '.'));
    end;

    procedure CancelTrxIfTerminalThrewInProgressError(EFTTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    begin
        //This is not required for this integratipn type. Terminal will auto cancel if hit with a new request while another is active.
    end;

    local procedure WriteLogEntry(EFTSetup: Record "NPR EFT Setup"; IsError: Boolean; EntryNo: Integer; Description: Text; LogContents: Text)
    var
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
    begin
        case EFTNETSCloudIntegration.GetLogLevel(EFTSetup) of
            EFTNETSCloudPaymentSetup."Log Level"::ERROR:
                if IsError then
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents)
                else
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, '');

            EFTNETSCloudPaymentSetup."Log Level"::FULL:
                EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents);

            EFTNETSCloudPaymentSetup."Log Level"::NONE:
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
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
    begin
        EFTNETSCloudIntegration.HandleProtocolResponse(EftTransactionRequest);
    end;
}

