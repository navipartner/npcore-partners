codeunit 6184534 "NPR EFT NETSCloud Protocol"
{
#pragma warning disable AA0139
    Access = Internal;

    var
        _RequestResponseBuffer: Text;
        _ResponseStatusCodeBuffer: Integer;
        _ResponseErrorBodyBuffer: Text;


    procedure ProcessRequestSynchronously(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        // These requests are fully processed with normal blocking AL, without a POS workflow or POS dialog.
        // The transaction (purchase/refund) and abort requests are invoked from a background task from a POS workflow.

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::CLOSE:
                Reconciliation(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::VOID:
                VoidTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupLastTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    2:
                        BalanceEnquiry(EftTransactionRequest);
                    3:
                        DownloadDataset(EftTransactionRequest);
                    4:
                        DownloadSoftware(EftTransactionRequest);
                end;
        end;
    end;

    local procedure Reconciliation(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        EFTNETSResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if not InvokeReconciliation(EftTransactionRequest, GetToken(EFTSetup), Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());
            exit;
        end;

        EFTNETSResponseParser.SetResponseData('Reconciliation', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());

        HandleProtocolResponse(EftTransactionRequest);
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
    end;

    local procedure EndGiftCardLoadTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTNETSResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
    begin
        EFTNETSResponseParser.SetResponseData('GiftCardLoad', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
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

        if not InvokeVoid(EftTransactionRequest, GetToken(EFTSetup), Response) then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('VoidLast', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure LookupLastTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        Response: Text;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
        ParseSuccess: Boolean;
        LookupSuccess: Boolean;
    begin
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        LookupSuccess := InvokeLookupLastTransaction(EftTransactionRequest, EFTSetup, OriginalEFTTransactionRequest, 1000 * 60, GetToken(EFTSetup), Response);
        if LookupSuccess then
            LookupSuccess := EFTNETSCloudResponseParser.IsLookupResponseRelatedToTransaction(Response, OriginalEftTransactionRequest);

        if not LookupSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
            HandleProtocolResponse(EftTransactionRequest);
            WriteLogEntry(EFTSetup, true, EftTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('LookupLast', Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EftTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure BalanceEnquiry(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        ParseSuccess: Boolean;
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not InvokeBalanceEnquiry(EFTTransactionRequest, GetToken(EFTSetup), Response) then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
            HandleProtocolResponse(EFTTransactionRequest);
            WriteLogEntry(EFTSetup, true, EFTTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('BalanceEnquiry', Response, EFTTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EFTTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());

        HandleProtocolResponse(EFTTransactionRequest);
    end;

    local procedure DownloadDataset(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        ParseSuccess: Boolean;
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not InvokeDownloadDataset(EFTTransactionRequest, GetToken(EFTSetup), Response) then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
            HandleProtocolResponse(EFTTransactionRequest);
            WriteLogEntry(EFTSetup, true, EFTTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('TerminalDataset', Response, EFTTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EFTTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());

        HandleProtocolResponse(EFTTransactionRequest);
    end;

    local procedure DownloadSoftware(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        ParseSuccess: Boolean;
        EFTNETSCloudResponseParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not InvokeDownloadSoftware(EFTTransactionRequest, GetToken(EFTSetup), Response) then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
            HandleProtocolResponse(EFTTransactionRequest);
            WriteLogEntry(EFTSetup, true, EFTTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());
            exit;
        end;

        EFTNETSCloudResponseParser.SetResponseData('TerminalSoftware', Response, EFTTransactionRequest."Entry No.");
        ParseSuccess := EFTNETSCloudResponseParser.Run();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EFTTransactionRequest, GetLastErrorText);
            EFTTransactionRequest.Modify();
        end;

        WriteLogEntry(EFTSetup, ParseSuccess, EFTTransactionRequest."Entry No.", 'Invoke result', GetLogBuffer());

        HandleProtocolResponse(EFTTransactionRequest);
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

        InvokeTerminalList(EFTTransactionRequest, GetToken(EFTSetup), Response);
        exit(Response);
    end;

    procedure TerminalSettings(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        Response: Text;
    begin
        //Invoked from setup, not written, dummy eft trx record
        EFTTransactionRequest."Integration Type" := EFTNETSCloudIntegration.IntegrationType();
        EFTTransactionRequest."Hardware ID" := EFTNETSCloudIntegration.GetTerminalID(EFTSetup);
        if EFTNETSCloudIntegration.GetEnvironment(EFTSetup) <> 0 then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";

        InvokeTerminalSettings(EFTTransactionRequest, GetToken(EFTSetup), Response);
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

    procedure ProcessAsyncResponse(EntryNo: Integer; Completed: Boolean; Response: Text; Error: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);

        if Completed then begin

            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    EndPaymentTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::REFUND:
                    EndRefundTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                    EndGiftCardLoadTransaction(EFTTransactionRequest, Response);
            end;
        end else begin
            EFTTransactionRequest."NST Error" := Error;
            HandleProtocolResponse(EFTTransactionRequest);
        end;
    end;

    [TryFunction]
    local procedure InvokeLogin(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var Response: Text)
    var
        Body: Text;
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        Endpoint: Text;
        JSON: JsonObject;
    begin
        JSON.Add('username', EFTNETSCloudIntegration.GetAPIUsername(EFTSetup));
        JSON.Add('password', EFTNETSCloudIntegration.GetAPIPassword(EFTSetup));
        JSON.WriteTo(Body);

        Endpoint := '/v1/login';
        Response := InvokeAPI(Body, '', GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 10 * 1000, false);
    end;

    [TryFunction]
    local procedure InvokeReconciliation(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/administration', Locked = true;
        JSON: JsonObject;
    begin
        JSON.Add('action', 'reconciliation');
        JSON.WriteTo(Body);

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 60 * 1000, true);
    end;

    [TryFunction]
    procedure InvokeTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/transaction', Locked = true;
        JSON: JsonObject;
    begin
        case true of
            (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::PAYMENT) and (EftTransactionRequest."Cashback Amount" = 0):
                begin
                    JSON.Add('transactionType', 'purchase');
                    JSON.Add('amount', FormatAmount(EftTransactionRequest."Amount Input"));
                end;
            (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::PAYMENT) and (EftTransactionRequest."Cashback Amount" > 0) and (EftTransactionRequest."Amount Input" > 0):
                begin
                    JSON.Add('transactionType', 'purchaseWithCashback');
                    JSON.Add('amountCashback', FormatAmount(EftTransactionRequest."Cashback Amount"));
                    JSON.Add('amount', FormatAmount(EftTransactionRequest."Amount Input" - EftTransactionRequest."Cashback Amount"));
                end;
            (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::REFUND):
                begin
                    JSON.Add('transactionType', 'returnOfGoods');
                    JSON.Add('amount', FormatAmount(EftTransactionRequest."Amount Input"));
                end;
            (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::GIFTCARD_LOAD):
                begin
                    JSON.Add('transactionType', 'deposit');
                    JSON.Add('amount', FormatAmount(EftTransactionRequest."Amount Input"));
                end;
        end;
        JSON.Add('orderId', Format(EftTransactionRequest."Entry No."));
        JSON.WriteTo(Body);

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 300 * 1000, true);
    end;

    [TryFunction]
    local procedure InvokeVoid(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/transaction', Locked = true;
        JSON: JsonObject;
    begin
        JSON.Add('amount', FormatAmount(EftTransactionRequest."Amount Input"));
        JSON.WriteTo(Body);

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'DELETE', Endpoint, 60 * 1000, true);
    end;

    [TryFunction]
    procedure InvokeLookupLastTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; OriginalEftTransactionRequest: Record "NPR EFT Transaction Request"; TimeoutMs: Integer; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/transaction', Locked = true;
    begin
        Body :=
        '';

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'GET', Endpoint, TimeoutMs, true);
    end;

    [TryFunction]
    procedure InvokeCancelAction(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/administration', Locked = true;
        JSON: JsonObject;
    begin
        JSON.Add('action', 'cancelAction');
        JSON.WriteTo(Body);

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 10 * 1000, true);
    end;

    [TryFunction]
    local procedure InvokeDownloadDataset(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/administration', Locked = true;
        JSON: JsonObject;
    begin
        JSON.Add('action', 'downloadDataset');
        JSON.WriteTo(Body);

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 300 * 1000, true);
    end;

    [TryFunction]
    local procedure InvokeDownloadSoftware(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/administration', Locked = true;
        JSON: JsonObject;
    begin
        JSON.Add('action', 'downloadSoftware');
        JSON.WriteTo(Body);

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 300 * 1000, true);
    end;

    [TryFunction]
    local procedure InvokeBalanceEnquiry(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/administration', Locked = true;
        JSON: JsonObject;
    begin
        JSON.Add('action', 'balanceInquiry');
        JSON.Add('amount', 0);
        JSON.WriteTo(Body);

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'POST', Endpoint, 300 * 1000, true);
    end;

    [TryFunction]
    local procedure InvokeTerminalSettings(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
        EndpointLbl: Label '/v1/terminal/%1/settings', Locked = true;
    begin
        Body :=
        '';

        Endpoint := StrSubstNo(EndpointLbl, EftTransactionRequest."Hardware ID");
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'GET', Endpoint, 10 * 1000, false);
    end;

    [TryFunction]
    local procedure InvokeTerminalList(EftTransactionRequest: Record "NPR EFT Transaction Request"; Token: Text; var Response: Text)
    var
        Body: Text;
        Endpoint: Text;
    begin
        Body :=
        '';

        Endpoint := '/v1/terminal';
        Response := InvokeAPI(Body, Token, GetServiceURL(EftTransactionRequest), 'GET', Endpoint, 10 * 1000, false);
    end;

    local procedure InvokeAPI(Body: Text; Token: Text; URL: Text; Method: Text; Endpoint: Text; TimeoutMs: Integer; AllowBadRequest: Boolean): Text
    var
        Http: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ErrorInvokeLbl: Label 'Error: Service endpoint %1 responded with HTTP status %2';
        ReqRespLbl: Label '(%1) \\%2', Locked = true;
        ResponseBody: Text;
    begin
        ClearLogBuffers();

        AppendRequestResponseBuffer(Body, 'Request');

        Request.SetRequestUri(URL + Endpoint);
        Request.Method := Method;
        Request.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + Token);
        Http.Timeout := TimeoutMs;

        If Method <> 'GET' then begin
            Request.Content.WriteFrom(Body);
            Request.Content.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
        end;

        Http.Send(Request, Response);
        _ResponseStatusCodeBuffer := Response.HttpStatusCode;

        if not (Response.IsSuccessStatusCode) then begin
            if not ((Response.HttpStatusCode = 400) and AllowBadRequest) then begin
                Error(ErrorInvokeLbl, URL, Format(_ResponseStatusCodeBuffer));
            end;
        end;

        Response.Content.ReadAs(ResponseBody);
        AppendRequestResponseBuffer(StrSubstNo(ReqRespLbl, _ResponseStatusCodeBuffer, ResponseBody), 'Response');
        Exit(ResponseBody);
    end;

    procedure GetToken(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        Token: Text;
        JSON: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if EFTNETSCloudToken.TryGetToken(Token) then
            exit(Token);

        JSON := LoginAndGetToken(EFTSetup);
        JObject.ReadFrom(JSON);
        JObject.Get('token', JToken);
        Token := JToken.AsValue().AsText();

        EFTNETSCloudToken.SetToken(Token);
        exit(Token);
    end;

    local procedure GetServiceURL(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        case EFTTransactionRequest.Mode of
            EFTTransactionRequest.Mode::Production:
                if FeatureFlagsManagement.IsEnabled('netscloudnewurl') then
                    exit('https://connectcloud.aws.nets.eu')
                else
                    exit('https://api1.cloudconnect.nets.eu');
            EFTTransactionRequest.Mode::"TEST Remote":
                exit('https://connectcloud-test.aws.nets.eu');
            EFTTransactionRequest.Mode::"TEST Local":
                EFTTransactionRequest.FieldError(Mode);
        end;
    end;

    local procedure FormatAmount(Amount: Decimal): Integer
    var
        AmountInt: Integer;
    begin
        Evaluate(AmountInt, (DelChr(Format(Abs(Amount), 0, '<Precision,2:2><Standard Format,9>'), '=', '.')));
        exit(AmountInt);
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

    procedure WriteLogEntry(EFTTransactionRequest: Record "NPR EFT Transaction Request"; IsError: Boolean; Description: Text; LogContents: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        WriteLogEntry(EFTSetup, IsError, EFTTransactionRequest."Entry No.", Description, LogContents);
    end;

    local procedure AppendRequestResponseBuffer(Text: Text; Header: Text)
    var
        LF: Char;
        CR: Char;
    begin
        CR := 13;
        LF := 10;

        _RequestResponseBuffer += (Format(CR) + Format(LF) + Format(CR) + Format(LF) + '===' + Header + ' (' + Format(CreateDateTime(Today, Time), 0, 9) + ')===' + Format(CR) + Format(LF) + Text);
    end;

    procedure ClearLogBuffers()
    begin
        Clear(_RequestResponseBuffer);
        Clear(_ResponseStatusCodeBuffer);
        Clear(_ResponseErrorBodyBuffer);
    end;

    procedure GetLogBuffer(): Text
    begin
        exit(_RequestResponseBuffer);
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
#pragma warning restore AA0139
}
