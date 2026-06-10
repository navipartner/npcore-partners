#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151089 "NPR API POS EFT Adyen Cloud"
{
    Access = Internal;

    var
        _Sentry: Codeunit "NPR Sentry";

    internal procedure PrepareEFTPayment(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        APIPOSSale: Codeunit "NPR API POS Sale";
        Body: JsonToken;
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
        SaleId: Guid;
        Amount: Decimal;
        HasAmount: Boolean;
        POSUnitNo: Code[10];
        EntryNo: Integer;
        JsonResponse: JsonObject;
    begin
        if not TryResolveSelfServiceEFTContext(Request, POSSale, EFTSetup, POSUnitNo, SaleId, Response) then
            exit(Response);

        if not (EFTSetup."EFT Integration Type" in [
                EFTAdyenIntegration.CloudIntegrationType(),
                EFTAdyenIntegration.MposTapToPayIntegrationType()])
        then
            exit(Response.RespondBadRequest('EFT Setup is not configured for an Adyen integration (Cloud or TTP)'));

        Body := Request.BodyJson();
        HasAmount := GetJsonDecimal(Body, 'amount', Amount);
        if not HasAmount then
            Amount := GetRemainingBalance(POSSale);
        if Amount <= 0 then
            exit(Response.RespondBadRequest('Payment amount must be greater than zero'));

        // Reconstruct POS session - required by EFT framework (e.g. CalculateCashback needs active session)
        APIPOSSale.ReconstructSession(SaleId);

        // Create EFT Transaction Request via helper
        EntryNo := EFTTransactionMgt.PreparePayment(
            EFTSetup,
            Amount,
            '',
            POSSale,
            IntegrationRequest,
            Mechanism,
            Workflow
        );

        EFTTransactionRequest.Get(EntryNo);
        // Clear timestamps so lifecycle is clean
        Clear(EFTTransactionRequest.Started);
        Clear(EFTTransactionRequest.Finished);
        EFTTransactionRequest.Modify();
        Commit();

        JsonResponse.Add('transactionId', Format(EFTTransactionRequest.SystemId, 0, 4).ToLower());
        JsonResponse.Add('status', 'Prepared');
        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure BuildEFTRequest(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        APIPOSSale: Codeunit "NPR API POS Sale";
        SaleId: Guid;
        TransactionId: Guid;
        TerminalApiSaletoPoiRequestJson: Text;
        EncDetailsJson: Text;
        IsLiveEnvironment: Boolean;
        BridgeRequest: JsonObject;
        JsonResponse: JsonObject;
    begin
        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        if EFTTransactionRequest.Finished <> 0DT then
            exit(Response.RespondBadRequest('Transaction already completed'));

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if EFTSetup."EFT Integration Type" <> EFTAdyenIntegration.MposTapToPayIntegrationType() then
            exit(Response.RespondBadRequest('EFT Setup is not configured for Adyen TTP integration'));

        // Reconstruct POS session - EFT request builder may resolve POS context via active session.
        APIPOSSale.ReconstructSession(SaleId);

        EFTAdyenIntegration.GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymTypeSetup);

        if EFTAdyenPaymTypeSetup."Local Key Identifier" = '' then
            exit(Response.RespondBadRequest('Adyen Payment Type Setup is missing "Local Key Identifier"'));
        if EFTAdyenPaymTypeSetup."Local Key Passphrase" = '' then
            exit(Response.RespondBadRequest('Adyen Payment Type Setup is missing "Local Key Passphrase"'));

        TerminalApiSaletoPoiRequestJson := EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup);
        EncDetailsJson := EFTAdyenPaymTypeSetup.GetEncryptionKeyMaterialJson();
        IsLiveEnvironment := EFTAdyenPaymTypeSetup.Environment = EFTAdyenPaymTypeSetup.Environment::PRODUCTION;

        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Modify();
        Commit();

        BridgeRequest.Add('RequestType', 'TerminalApiRequest');
        BridgeRequest.Add('IntegrationType', 'TapToPay');
        BridgeRequest.Add('TerminalApiSaletoPoiRequestJson', TerminalApiSaletoPoiRequestJson);
        BridgeRequest.Add('EncDetailsJson', EncDetailsJson);
        BridgeRequest.Add('IsLiveEnvironment', IsLiveEnvironment);

        JsonResponse.Add('bridgeRequest', BridgeRequest);
        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('serviceId', EFTTransactionRequest."Reference Number Input");
        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure ParseEFTResponse(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        APIPOSSale: Codeunit "NPR API POS Sale";
        Body: JsonToken;
        SaleId: Guid;
        TransactionId: Guid;
        ResponseText: Text;
        FieldName: Text;
        JsonResponse: JsonObject;
        SaleJson: JsonObject;
        EFTPaymentLineIds: List of [Text];
        EmptySaleLineIds: List of [Text];
        Token: JsonToken;
    begin
        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if EFTSetup."EFT Integration Type" <> EFTAdyenIntegration.MposTapToPayIntegrationType() then
            exit(Response.RespondBadRequest('EFT Setup is not configured for Adyen TTP integration'));

        Body := Request.BodyJson();
        Body.WriteTo(ResponseText);
        if (ResponseText = '') or (ResponseText = 'null') then
            exit(Response.RespondBadRequest('Missing response body'));

        // Reconstruct POS session - ProcessResponse → EftIntegrationResponse → InsertPaymentLine requires active session.
        APIPOSSale.ReconstructSession(SaleId);

        EFTAdyenResponseHandler.ProcessResponse(EFTTransactionRequest."Entry No.", ResponseText, true, true, '');
        Commit();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");

        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('successful', EFTTransactionRequest.Successful);
        JsonResponse.Add('resultCode', Format(EFTTransactionRequest."Result Code"));
        JsonResponse.Add('resultMessage', EFTTransactionRequest."Result Display Text");
        JsonResponse.Add('cardNumber', EFTTransactionRequest."Card Number");
        JsonResponse.Add('cardName', EFTTransactionRequest."Card Name");
        JsonResponse.Add('authorizationNumber', EFTTransactionRequest."Authorisation Number");

        if EFTTransactionRequest.Successful then begin
            EFTPaymentLineIds.Add(Format(EFTTransactionRequest."Sales Line ID", 0, 4).ToLower());

            SaleJson := APIPOSSale.POSSaleAsJson(POSSale, true, true, EmptySaleLineIds, EFTPaymentLineIds).Build();
            SaleJson.Remove('saleId');
            SaleJson.Remove('receiptNo');
            SaleJson.Remove('posUnit');
            SaleJson.Remove('posStore');
            SaleJson.Remove('date');
            SaleJson.Remove('startTime');
            SaleJson.Remove('customerNo');
            SaleJson.Remove('salespersonCode');
            SaleJson.Remove('vatBusinessPostingGroup');
            foreach FieldName in SaleJson.Keys() do
                if SaleJson.Get(FieldName, Token) then
                    JsonResponse.Add(FieldName, Token);
        end;

        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure GenerateBoardingToken(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup";
        EFTAdyenBoardingToken: Codeunit "NPR EFT Adyen Boarding Token";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        Base64Convert: Codeunit "Base64 Convert";
        Body: JsonToken;
        JToken: JsonToken;
        SaleId: Guid;
        POSUnitNo: Code[10];
        BoardingRequestToken: Text;
        BoardingTokenB64: Text;
        BoardingTokenRaw: Text;
        ErrorText: Text;
        JsonResponse: JsonObject;
    begin
        if not TryResolveSelfServiceEFTContext(Request, POSSale, EFTSetup, POSUnitNo, SaleId, Response) then
            exit(Response);

        if EFTSetup."EFT Integration Type" <> EFTAdyenIntegration.MposTapToPayIntegrationType() then
            exit(Response.RespondBadRequest('EFT Setup is not configured for Adyen TTP integration'));

        EFTAdyenIntegration.GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymTypeSetup);

        if not EFTAdyenUnitSetup.Get(POSUnitNo) then
            exit(Response.RespondBadRequest('POS Unit has no EFT Adyen Unit Setup'));
        if EFTAdyenUnitSetup."In Person Store Id" = '' then
            exit(Response.RespondBadRequest('EFT Adyen Unit Setup is missing "In Person Store Id"'));

        Body := Request.BodyJson();
        if not Body.AsObject().Get('boardingRequestToken', JToken) then
            exit(Response.RespondBadRequest('Missing boardingRequestToken'));
        BoardingRequestToken := JToken.AsValue().AsText();
        if BoardingRequestToken = '' then
            exit(Response.RespondBadRequest('Missing boardingRequestToken'));

        if not EFTAdyenBoardingToken.RequestBoardingToken(EFTAdyenPaymTypeSetup, EFTAdyenUnitSetup."In Person Store Id", BoardingRequestToken, BoardingTokenB64) then begin
            ErrorText := GetLastErrorText();
            _Sentry.AddLastErrorIfProgrammingBug();
            exit(Response.RespondBadRequest(ErrorText));
        end;

        // RequestBoardingToken returns the token base64-encoded for the in-POS bridge workflow.
        // The REST contract returns the raw JWT; the frontend base64-encodes itself before handing to the bridge.
        BoardingTokenRaw := Base64Convert.FromBase64(BoardingTokenB64);

        JsonResponse.Add('boardingToken', BoardingTokenRaw);
        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure StartEFTPayment(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        APIPOSSale: Codeunit "NPR API POS Sale";
        SaleId: Guid;
        TransactionId: Guid;
        RequestJson: Text;
        ResponseText: Text;
        Logs: Text;
        ResponseStatusCode: Integer;
        URL: Text;
        ErrorText: Text;
        JsonResponse: JsonObject;
    begin
        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        if EFTTransactionRequest."External Result Known" and EFTTransactionRequest.Successful then
            exit(Response.RespondBadRequest('Transaction already completed successfully'));

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if EFTSetup."EFT Integration Type" <> EFTAdyenIntegration.CloudIntegrationType() then
            exit(Response.RespondBadRequest('EFT Setup is not configured for Adyen Cloud integration'));

        // Reconstruct POS session - required for ProcessResponse chain which inserts payment lines via EFT framework
        APIPOSSale.ReconstructSession(SaleId);

        // Build request JSON
        RequestJson := EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup);

        // Set Started timestamp and commit before sending
        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Modify();
        Commit();

        // Get terminal URL
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        // Synchronous call to Adyen (5 min timeout for BC SaaS max)
        if not EFTAdyenCloudProtocol.InvokeAPI(RequestJson, GetApiKeyForSetup(EFTSetup), URL, 300000, ResponseText, ResponseStatusCode) then begin
            Logs := EFTAdyenCloudProtocol.GetLogBuffer();
            ErrorText := GetLastErrorText();
            EFTAdyenResponseHandler.ProcessResponse(EFTTransactionRequest."Entry No.", ResponseText, false, true, ErrorText);
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, true, 'API Start (Error)', Logs);
            Commit();
            JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
            JsonResponse.Add('processed', true);
            exit(Response.RespondOK(JsonResponse));
        end;

        Logs := EFTAdyenCloudProtocol.GetLogBuffer();

        // Process successful response
        EFTAdyenResponseHandler.ProcessResponse(EFTTransactionRequest."Entry No.", ResponseText, ResponseStatusCode in [0, 200], true, '');
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'API Start (Complete)', Logs);
        Commit();

        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('processed', true);
        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure PollEFTStatus(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIPOSSale: Codeunit "NPR API POS Sale";
        SaleId: Guid;
        TransactionId: Guid;
        Status: Text;
        FieldName: Text;
        JsonResponse: JsonObject;
        SaleJson: JsonObject;
        EFTPaymentLineIds: List of [Text];
        EmptySaleLineIds: List of [Text];
        Token: JsonToken;
    begin
        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        Status := GetTransactionStatus(EFTTransactionRequest);

        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('status', Status);
        JsonResponse.Add('successful', EFTTransactionRequest.Successful);

        if EFTTransactionRequest."External Result Known" then begin
            JsonResponse.Add('resultCode', Format(EFTTransactionRequest."Result Code"));
            JsonResponse.Add('cardNumber', EFTTransactionRequest."Card Number");
            JsonResponse.Add('cardName', EFTTransactionRequest."Card Name");
            JsonResponse.Add('authorizationNumber', EFTTransactionRequest."Authorisation Number");
            JsonResponse.Add('resultMessage', EFTTransactionRequest."Result Display Text");

            if EFTTransactionRequest.Successful then begin
                EFTPaymentLineIds.Add(Format(EFTTransactionRequest."Sales Line ID", 0, 4).ToLower());

                SaleJson := APIPOSSale.POSSaleAsJson(POSSale, true, true, EmptySaleLineIds, EFTPaymentLineIds).Build();
                SaleJson.Remove('saleId');
                SaleJson.Remove('receiptNo');
                SaleJson.Remove('posUnit');
                SaleJson.Remove('posStore');
                SaleJson.Remove('date');
                SaleJson.Remove('startTime');
                SaleJson.Remove('customerNo');
                SaleJson.Remove('salespersonCode');
                SaleJson.Remove('vatBusinessPostingGroup');
                foreach FieldName in SaleJson.Keys() do
                    if SaleJson.Get(FieldName, Token) then
                        JsonResponse.Add(FieldName, Token);
            end;
        end;

        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure CancelEFTTransaction(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
        EFTAdyenAbortTrxReq: Codeunit "NPR EFT Adyen AbortTrx Req";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        SaleId: Guid;
        TransactionId: Guid;
        AbortEntryNo: Integer;
        AbortRequestJson: Text;
        AbortResponseText: Text;
        AbortResponseStatusCode: Integer;
        URL: Text;
        JsonResponse: JsonObject;
    begin
        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        // Create abort request
        AbortEntryNo := EFTAdyenAbortMgmt.CreateAbortTransactionRequest(EFTTransactionRequest);
        AbortEFTTransactionRequest.Get(AbortEntryNo);

        // Build abort JSON
        AbortRequestJson := EFTAdyenAbortTrxReq.GetRequestJson(AbortEFTTransactionRequest, EFTTransactionRequest);

        // Get API key + URL
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        // Abort is quick, 30s timeout
        if not EFTAdyenCloudProtocol.InvokeAPI(AbortRequestJson, GetApiKeyForSetup(EFTSetup), URL, 30000, AbortResponseText, AbortResponseStatusCode) then begin
            _Sentry.AddLastErrorIfProgrammingBug();
        end;

        Commit();

        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('cancelRequested', true);
        exit(Response.RespondOK(JsonResponse));
    end;

    local procedure TryLoadExistingTransaction(var Request: Codeunit "NPR API Request"; var POSSale: Record "NPR POS Sale"; var EFTTransactionRequest: Record "NPR EFT Transaction Request"; var SaleId: Guid; var TransactionId: Guid; var Response: Codeunit "NPR API Response"): Boolean
    begin
        if not Evaluate(SaleId, Request.Paths().Get(3)) then begin
            Response := Response.RespondBadRequest('Invalid saleId format');
            exit(false);
        end;
        if not Evaluate(TransactionId, Request.Paths().Get(5)) then begin
            Response := Response.RespondBadRequest('Invalid transactionId format');
            exit(false);
        end;

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleId) then begin
            Response := Response.RespondResourceNotFound();
            exit(false);
        end;

        EFTTransactionRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        if not EFTTransactionRequest.GetBySystemId(TransactionId) then begin
            Response := Response.RespondResourceNotFound();
            exit(false);
        end;

        if not TransactionBelongsToSale(EFTTransactionRequest, POSSale) then begin
            Response := Response.RespondResourceNotFound();
            exit(false);
        end;

        exit(true);
    end;

    local procedure TryResolveSelfServiceEFTContext(var Request: Codeunit "NPR API Request"; var POSSale: Record "NPR POS Sale"; var EFTSetup: Record "NPR EFT Setup"; var POSUnitNo: Code[10]; var SaleId: Guid; var Response: Codeunit "NPR API Response"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        SSProfile: Record "NPR SS Profile";
        PaymentMethodCode: Code[10];
    begin
        if not Evaluate(SaleId, Request.Paths().Get(3)) then begin
            Response := Response.RespondBadRequest('Invalid saleId format');
            exit(false);
        end;

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleId) then begin
            Response := Response.RespondResourceNotFound();
            exit(false);
        end;

        POSUnitNo := GetPOSUnitFromUserSetup();
        if POSUnitNo = '' then begin
            Response := Response.RespondBadRequest('No POS Unit assigned to current user');
            exit(false);
        end;

        if not POSUnit.Get(POSUnitNo) then begin
            Response := Response.RespondBadRequest('POS Unit not found');
            exit(false);
        end;
        if POSUnit."POS Type" <> POSUnit."POS Type"::UNATTENDED then begin
            Response := Response.RespondBadRequest('EFT API is only supported on UNATTENDED POS units');
            exit(false);
        end;

        if POSUnit.Status <> POSUnit.Status::OPEN then begin
            Response := Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales (current status: %2).', POSUnit."No.", Format(POSUnit.Status)));
            exit(false);
        end;

        if POSUnit."POS Self Service Profile" = '' then begin
            Response := Response.RespondBadRequest('POS Unit has no Self Service Profile configured');
            exit(false);
        end;
        if not SSProfile.Get(POSUnit."POS Self Service Profile") then begin
            Response := Response.RespondBadRequest('Self Service Profile not found');
            exit(false);
        end;
        PaymentMethodCode := SSProfile."Selfservice Card Payment Meth.";
        if PaymentMethodCode = '' then begin
            Response := Response.RespondBadRequest('Self Service Profile has no selfservice card payment method configured');
            exit(false);
        end;

        EFTSetup.FindSetup(POSUnitNo, PaymentMethodCode);
        exit(true);
    end;

    local procedure TransactionBelongsToSale(EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSSale: Record "NPR POS Sale"): Boolean
    begin
        exit(
            (EFTTransactionRequest."Sales Ticket No." = POSSale."Sales Ticket No.") and
            (EFTTransactionRequest."Register No." = POSSale."Register No.")
        );
    end;

    local procedure GetTransactionStatus(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        if EFTTransactionRequest.Finished = 0DT then begin
            if EFTTransactionRequest.Started = 0DT then
                exit('Prepared');
            exit('Initiated');
        end;

        if EFTTransactionRequest."External Result Known" then
            exit('Completed');

        exit('Failed');
    end;

    local procedure GetRemainingBalance(POSSale: Record "NPR POS Sale"): Decimal
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSalePaymentLine: Record "NPR POS Sale Line";
        TotalAmount: Decimal;
        TotalPayments: Decimal;
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetFilter("Line Type", '<>%1', POSSaleLine."Line Type"::"POS Payment");
        POSSaleLine.CalcSums("Amount Including VAT");
        TotalAmount := POSSaleLine."Amount Including VAT";

        POSSalePaymentLine.SetRange("Register No.", POSSale."Register No.");
        POSSalePaymentLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSalePaymentLine.SetRange("Line Type", POSSalePaymentLine."Line Type"::"POS Payment");
        POSSalePaymentLine.CalcSums("Amount Including VAT");
        TotalPayments := POSSalePaymentLine."Amount Including VAT";

        exit(TotalAmount - TotalPayments);
    end;

    local procedure GetPOSUnitFromUserSetup(): Code[10]
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then
            exit('');
        exit(UserSetup."NPR POS Unit No.");
    end;

    [NonDebuggable]
    local procedure GetApiKeyForSetup(var EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        EFTAdyenIntegration.GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymTypeSetup);
        exit(EFTAdyenPaymTypeSetup.GetApiKey());
    end;

    local procedure GetJsonDecimal(Body: JsonToken; PropertyName: Text; var Value: Decimal): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.AsValue().IsNull() then
            exit(false);
        Value := JToken.AsValue().AsDecimal();
        exit(true);
    end;
}
#endif
