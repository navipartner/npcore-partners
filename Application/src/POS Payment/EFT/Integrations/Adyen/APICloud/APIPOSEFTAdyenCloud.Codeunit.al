#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151089 "NPR API POS EFT Adyen Cloud"
{
    Access = Internal;

    var
        _Sentry: Codeunit "NPR Sentry";

    internal procedure PrepareEFTPayment(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        SSProfile: Record "NPR SS Profile";
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
        PaymentMethodCode: Code[10];
        EntryNo: Integer;
        JsonResponse: JsonObject;
    begin
        if not Evaluate(SaleId, Request.Paths().Get(3)) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        Body := Request.BodyJson();
        HasAmount := GetJsonDecimal(Body, 'amount', Amount);

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleId) then
            exit(Response.RespondResourceNotFound());

        POSUnitNo := GetPOSUnitFromUserSetup();
        if POSUnitNo = '' then
            exit(Response.RespondBadRequest('No POS Unit assigned to current user'));

        // Enforce UNATTENDED POS type
        if not POSUnit.Get(POSUnitNo) then
            exit(Response.RespondBadRequest('POS Unit not found'));
        if POSUnit."POS Type" <> POSUnit."POS Type"::UNATTENDED then
            exit(Response.RespondBadRequest('EFT API is only supported on UNATTENDED POS units'));

        // Resolve selfservice card payment method from POS Self Service Profile
        if POSUnit."POS Self Service Profile" = '' then
            exit(Response.RespondBadRequest('POS Unit has no Self Service Profile configured'));
        if not SSProfile.Get(POSUnit."POS Self Service Profile") then
            exit(Response.RespondBadRequest('Self Service Profile not found'));
        PaymentMethodCode := SSProfile."Selfservice Card Payment Meth.";
        if PaymentMethodCode = '' then
            exit(Response.RespondBadRequest('Self Service Profile has no selfservice card payment method configured'));

        // Validate EFT Setup
        EFTSetup.FindSetup(POSUnitNo, PaymentMethodCode);
        if EFTSetup."EFT Integration Type" <> EFTAdyenIntegration.CloudIntegrationType() then
            exit(Response.RespondBadRequest('EFT Setup is not configured for Adyen Cloud integration'));

        // Determine amount
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
    begin
        exit(Response.RespondBadRequest('Local EFT build request is not yet supported'));
    end;

    internal procedure ParseEFTResponse(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(Response.RespondBadRequest('Local EFT parse response is not yet supported'));
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
        if not Evaluate(SaleId, Request.Paths().Get(3)) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(TransactionId, Request.Paths().Get(5)) then
            exit(Response.RespondBadRequest('Invalid transactionId format'));

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleId) then
            exit(Response.RespondResourceNotFound());

        EFTTransactionRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        if not EFTTransactionRequest.GetBySystemId(TransactionId) then
            exit(Response.RespondResourceNotFound());

        if not TransactionBelongsToSale(EFTTransactionRequest, POSSale) then
            exit(Response.RespondResourceNotFound());

        if EFTTransactionRequest."External Result Known" and EFTTransactionRequest.Successful then
            exit(Response.RespondBadRequest('Transaction already completed successfully'));

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

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
        if not Evaluate(SaleId, Request.Paths().Get(3)) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(TransactionId, Request.Paths().Get(5)) then
            exit(Response.RespondBadRequest('Invalid transactionId format'));

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleId) then
            exit(Response.RespondResourceNotFound());

        EFTTransactionRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        if not EFTTransactionRequest.GetBySystemId(TransactionId) then
            exit(Response.RespondResourceNotFound());

        if not TransactionBelongsToSale(EFTTransactionRequest, POSSale) then
            exit(Response.RespondResourceNotFound());

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
        if not Evaluate(SaleId, Request.Paths().Get(3)) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(TransactionId, Request.Paths().Get(5)) then
            exit(Response.RespondBadRequest('Invalid transactionId format'));

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleId) then
            exit(Response.RespondResourceNotFound());

        EFTTransactionRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        if not EFTTransactionRequest.GetBySystemId(TransactionId) then
            exit(Response.RespondResourceNotFound());

        if not TransactionBelongsToSale(EFTTransactionRequest, POSSale) then
            exit(Response.RespondResourceNotFound());

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

    local procedure TransactionBelongsToSale(EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSSale: Record "NPR POS Sale"): Boolean
    begin
        exit(
            (EFTTransactionRequest."Sales Ticket No." = POSSale."Sales Ticket No.") and
            (EFTTransactionRequest."Register No." = POSSale."Register No.")
        );
    end;

    local procedure GetTransactionStatus(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        if not EFTTransactionRequest."External Result Known" then begin
            if EFTTransactionRequest.Started <> 0DT then
                exit('Initiated');
            exit('Prepared');
        end;

        if EFTTransactionRequest.Successful then
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
