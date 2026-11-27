#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151089 "NPR API POS EFT"
{
    Access = Internal;

    var
        _Sentry: Codeunit "NPR Sentry";
        _UnsupportedIntegrationTypeLbl: Label '%1 ''%2'' is not supported by the self-service EFT API', Comment = '%1 = EFT Integration Type field caption, %2 = EFT Integration Type';
        _NotCloudFlowLbl: Label '%1 ''%2'' does not use the cloud EFT flow', Comment = '%1 = EFT Integration Type field caption, %2 = EFT Integration Type';

    internal procedure PrepareEFTPayment(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        APIPOSSaleLine: Codeunit "NPR API POS Sale Line";
        POSSale: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        APIPOSSale: Codeunit "NPR API POS Sale";
        Provider: Interface "NPR API EFT Provider";
        POSAgeCheck: Codeunit "NPR POS Age Check";
        Body: JsonToken;
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
        ErrorMessage: Text;
        SaleId: Guid;
        Amount: Decimal;
        HasAmount: Boolean;
        POSUnitNo: Code[10];
        EntryNo: Integer;
        JsonResponse: JsonObject;
    begin
        Request.SkipCacheIfNonStickyRequest(APIPOSSaleLine.POSSaleTableIds());

        if not TryResolveSelfServiceEFTContext(Request, POSSale, EFTSetup, POSUnitNo, SaleId, Response) then
            exit(Response);

        if not TryResolveProvider(EFTSetup, Provider, Response) then
            exit(Response);
        if not Provider.ValidateSetup(EFTSetup, POSUnitNo, ErrorMessage) then
            exit(Response.RespondBadRequest(ErrorMessage));

        Body := Request.BodyJson();
        HasAmount := GetJsonDecimal(Body, 'amount', Amount);
        if not HasAmount then
            Amount := GetRemainingBalance(POSSale);
        if Amount <= 0 then
            exit(Response.RespondBadRequest('Payment amount must be greater than zero'));

        if POSAgeCheck.NeedsApproval(POSSale) then
            exit(Response.RespondBadRequest("NPR API Error Code"::age_check_required, POSAgeCheck.RequiredErrorMessage()));

        // Reconstruct POS session - required by EFT framework (e.g. CalculateCashback needs active session)
        APIPOSSale.ReconstructSession(SaleId);

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
        APIPOSSaleLine: Codeunit "NPR API POS Sale Line";
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        APIPOSSale: Codeunit "NPR API POS Sale";
        POSAgeCheck: Codeunit "NPR POS Age Check";
        SaleId: Guid;
        TransactionId: Guid;
        TerminalApiSaletoPoiRequestJson: Text;
        EncDetailsJson: Text;
        IsLiveEnvironment: Boolean;
        BridgeRequest: JsonObject;
        JsonResponse: JsonObject;
    begin
        Request.SkipCacheIfNonStickyRequest(APIPOSSaleLine.POSSaleTableIds());

        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        if EFTTransactionRequest.Finished <> 0DT then
            exit(Response.RespondBadRequest('Transaction already completed'));

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

        if POSAgeCheck.NeedsApproval(POSSale) then
            exit(Response.RespondBadRequest("NPR API Error Code"::age_check_required, POSAgeCheck.RequiredErrorMessage()));

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
        JsonResponse: JsonObject;
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

        if EFTTransactionRequest.Successful then
            AddSaleDelta(JsonResponse, POSSale, EFTTransactionRequest);

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
        APIPOSSaleLine: Codeunit "NPR API POS Sale Line";
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        APIPOSSale: Codeunit "NPR API POS Sale";
        Provider: Interface "NPR API EFT Provider";
        POSAgeCheck: Codeunit "NPR POS Age Check";
        SaleId: Guid;
        TransactionId: Guid;
        ErrorMessage: Text;
        JsonResponse: JsonObject;
    begin
        Request.SkipCacheIfNonStickyRequest(APIPOSSaleLine.POSSaleTableIds());

        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        if EFTTransactionRequest."External Result Known" and EFTTransactionRequest.Successful then
            exit(Response.RespondBadRequest('Transaction already completed successfully'));
        if (EFTTransactionRequest.Started <> 0DT) and not EFTTransactionRequest."External Result Known" then
            exit(Response.RespondBadRequest('Transaction result is unknown and it cannot be started again. Staff must look it up or void it in Business Central'));
        if EFTTransactionRequest.Started <> 0DT then
            exit(Response.RespondBadRequest('Transaction has already been started and cannot be started again. Prepare a new transaction'));

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

        if POSAgeCheck.NeedsApproval(POSSale) then
            exit(Response.RespondBadRequest("NPR API Error Code"::age_check_required, POSAgeCheck.RequiredErrorMessage()));

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if not TryResolveCloudProvider(EFTSetup, Provider, Response) then
            exit(Response);
        if not Provider.ValidateStart(EFTTransactionRequest, EFTSetup, ErrorMessage) then
            exit(Response.RespondBadRequest(ErrorMessage));

        APIPOSSale.ReconstructSession(SaleId);

        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Modify();
        Commit();

        Provider.StartCloudPayment(EFTTransactionRequest, EFTSetup, POSSale);
        Commit();

        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('processed', true);
        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure PollEFTStatus(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SaleId: Guid;
        TransactionId: Guid;
        Status: Text;
        Successful: Boolean;
        JsonResponse: JsonObject;
    begin
        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        Status := GetTransactionStatus(EFTTransactionRequest);
        Successful := IsPaymentStanding(EFTTransactionRequest);

        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('status', Status);
        JsonResponse.Add('successful', Successful);
        if EFTTransactionRequest."Selfservice Reversal Status" <> EFTTransactionRequest."Selfservice Reversal Status"::" " then
            JsonResponse.Add('reversalStatus', ReversalStatusName(EFTTransactionRequest));

        if EFTTransactionRequest."External Result Known" and (Status <> 'Initiated') then begin
            JsonResponse.Add('resultCode', Format(EFTTransactionRequest."Result Code"));
            JsonResponse.Add('cardNumber', EFTTransactionRequest."Card Number");
            JsonResponse.Add('cardName', EFTTransactionRequest."Card Name");
            JsonResponse.Add('authorizationNumber', EFTTransactionRequest."Authorisation Number");
            JsonResponse.Add('resultMessage', EFTTransactionRequest."Result Display Text");

            if Successful then
                AddSaleDelta(JsonResponse, POSSale, EFTTransactionRequest);
        end;

        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure CancelEFTTransaction(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        Provider: Interface "NPR API EFT Provider";
        SaleId: Guid;
        TransactionId: Guid;
        JsonResponse: JsonObject;
    begin
        if not TryLoadExistingTransaction(Request, POSSale, EFTTransactionRequest, SaleId, TransactionId, Response) then
            exit(Response);

        if EFTTransactionRequest.Started = 0DT then
            exit(Response.RespondBadRequest('Transaction has not been started'));
        if EFTTransactionRequest."Selfservice Reversal Status" = EFTTransactionRequest."Selfservice Reversal Status"::Pending then
            exit(Response.RespondBadRequest('Transaction is waiting for its signature void and cannot be cancelled'));
        if EFTTransactionRequest.Finished <> 0DT then
            exit(Response.RespondBadRequest('Transaction has already finished'));

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if not TryResolveCloudProvider(EFTSetup, Provider, Response) then
            exit(Response);

        Provider.CancelCloudPayment(EFTTransactionRequest, EFTSetup);
        Commit();

        JsonResponse.Add('transactionId', Format(TransactionId, 0, 4).ToLower());
        JsonResponse.Add('cancelRequested', true);
        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure HasUnsettledReversal(POSSale: Record "NPR POS Sale"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Register No.", POSSale."Register No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        EFTTransactionRequest.SetFilter("Selfservice Reversal Status", '%1|%2',
            EFTTransactionRequest."Selfservice Reversal Status"::Pending,
            EFTTransactionRequest."Selfservice Reversal Status"::Unknown);
        exit(not EFTTransactionRequest.IsEmpty());
    end;

    internal procedure TryFindProvider(IntegrationType: Code[20]; var Provider: Enum "NPR API EFT Provider"): Boolean
    var
        Candidate: Interface "NPR API EFT Provider";
        Ordinal: Integer;
    begin
        foreach Ordinal in Provider.Ordinals() do begin
            Provider := Enum::"NPR API EFT Provider".FromInteger(Ordinal);
            Candidate := Provider;
            if Candidate.IntegrationType() = IntegrationType then
                exit(true);
        end;
        exit(false);
    end;

    internal procedure GetFlowName(Provider: Enum "NPR API EFT Provider"): Text
    var
        ProviderImplementation: Interface "NPR API EFT Provider";
        Flow: Enum "NPR API EFT Flow";
    begin
        ProviderImplementation := Provider;
        Flow := ProviderImplementation.Flow();
        case Flow of
            Flow::Cloud:
                exit('cloud');
            Flow::Local:
                exit('local');
        end;
    end;

    local procedure TryResolveProvider(EFTSetup: Record "NPR EFT Setup"; var Provider: Interface "NPR API EFT Provider"; var Response: Codeunit "NPR API Response"): Boolean
    var
        ProviderEnum: Enum "NPR API EFT Provider";
    begin
        if not TryFindProvider(EFTSetup."EFT Integration Type", ProviderEnum) then begin
            Response := Response.RespondBadRequest(StrSubstNo(_UnsupportedIntegrationTypeLbl, EFTSetup.FieldCaption("EFT Integration Type"), EFTSetup."EFT Integration Type"));
            exit(false);
        end;
        Provider := ProviderEnum;
        exit(true);
    end;

    local procedure TryResolveCloudProvider(EFTSetup: Record "NPR EFT Setup"; var Provider: Interface "NPR API EFT Provider"; var Response: Codeunit "NPR API Response"): Boolean
    begin
        if not TryResolveProvider(EFTSetup, Provider, Response) then
            exit(false);
        if Provider.Flow() <> Enum::"NPR API EFT Flow"::Cloud then begin
            Response := Response.RespondBadRequest(StrSubstNo(_NotCloudFlowLbl, EFTSetup.FieldCaption("EFT Integration Type"), EFTSetup."EFT Integration Type"));
            exit(false);
        end;
        exit(true);
    end;

    local procedure AddSaleDelta(var JsonResponse: JsonObject; POSSale: Record "NPR POS Sale"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        APIPOSSale: Codeunit "NPR API POS Sale";
        SaleJson: JsonObject;
        EFTPaymentLineIds: List of [Text];
        EmptySaleLineIds: List of [Text];
        Token: JsonToken;
        FieldName: Text;
    begin
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

        if EFTTransactionRequest."Selfservice Reversal Status" = EFTTransactionRequest."Selfservice Reversal Status"::Pending then
            exit('Initiated');

        if EFTTransactionRequest."External Result Known" then
            exit('Completed');

        exit('Failed');
    end;

    local procedure ReversalStatusName(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        case EFTTransactionRequest."Selfservice Reversal Status" of
            EFTTransactionRequest."Selfservice Reversal Status"::Pending:
                exit('pending');
            EFTTransactionRequest."Selfservice Reversal Status"::Reversed:
                exit('reversed');
            EFTTransactionRequest."Selfservice Reversal Status"::Failed:
                exit('failed');
            EFTTransactionRequest."Selfservice Reversal Status"::Unknown:
                exit('unknown');
        end;
    end;

    local procedure IsPaymentStanding(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        if not EFTTransactionRequest.Successful or EFTTransactionRequest.Reversed then
            exit(false);
        exit(not (EFTTransactionRequest."Selfservice Reversal Status" in [
            EFTTransactionRequest."Selfservice Reversal Status"::Pending,
            EFTTransactionRequest."Selfservice Reversal Status"::Reversed,
            EFTTransactionRequest."Selfservice Reversal Status"::Unknown]));
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
