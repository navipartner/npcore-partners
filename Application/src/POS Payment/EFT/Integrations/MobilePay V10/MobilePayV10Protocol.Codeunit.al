codeunit 6014519 "NPR MobilePayV10 Protocol"
{
    Access = Internal;

    var
        AUTH_TOKEN_Err: Label 'Could not refresh MobilePay authorization token.\%1';
        UNSUPPORTED_POLLSTATUS_PROCESSING_TYPE_Err: Label '%1 isn`t a supported %2 for %3. Only %4 and %5 are supported.';
        CANCEL_DEAD_TRANSACTIONS_JOBQUEUE_DESCRIPTION_Lbl: Label 'Cancel dead (reserved) MobilePay transactions.';
        CREATE_DEAD_TRANSACTIONS_JOBQUEUE_ENTRY_Qst: Label 'Do you want to create a Job Queue task to run cancellation of dead reserved MobilePay transactions?';
        CANCELED_BY_USER_Err: Label 'Action canceled by user.';

        MobilePayResponseExpectedButEmptyErr: Label 'This is a programming bug!!!\MobilePay response content expected but empty.\Can''t read any JSON response content.';
        IsRunningOutOfPosSession: Boolean;
        MobilePayJobQueueCategoryCode_Lbl: Label 'MOBILEPAY', Locked = true;
        MobilePayJobQueueCategoryDescription_Lbl: Label 'MOBILEPAY Tasks';

    internal procedure SendTrxRequest(EftTrxRequest: record "NPR EFT Transaction Request")
    var
        mobilePayAuxRequestType: Enum "NPR MobilePayV10 Aux. Req.";
        mobilePayCorrelation: Codeunit "NPR MobilePayV10 Correlat. ID";
    begin
        mobilePayCorrelation.GenerateNewID(); //For mobilepays backend to correlate create, polling, capture/cancel requests.

        case eftTrxRequest."Processing Type" of
            eftTrxRequest."Processing Type"::PAYMENT:
                StartPaymentTransaction(EftTrxRequest, false); //Via async dialog that polls trx result.

            EftTrxRequest."Processing Type"::REFUND:
                StartRefundTransaction(EftTrxRequest); //Via async dialog that polls trx result.

            EftTrxRequest."Processing Type"::LOOK_UP:
                LookupTransaction(EftTrxRequest); //Via blocking ws invoke

            EftTrxRequest."Processing Type"::AUXILIARY:
                case EftTrxRequest."Auxiliary Operation ID" of
                    mobilePayAuxRequestType::AuthTokenRequest.AsInteger():
                        GetAuthToken(EftTrxRequest);
                    mobilePayAuxRequestType::CreatePOSRequest.AsInteger():
                        CreatePOSInBackend(EftTrxRequest);
                    mobilePayAuxRequestType::DeletePOSRequest.AsInteger():
                        DeletePOSInBackend(EftTrxRequest);
                    mobilePayAuxRequestType::FindActivePayment.AsInteger():
                        FindActivePayment(EftTrxRequest);
                    mobilePayAuxRequestType::FindActiveRefund.AsInteger():
                        FindActiveRefund(EftTrxRequest);
                end;
        end;
    end;

    local procedure StartPaymentTransaction(EftTrxRequest: Record "NPR EFT Transaction Request"; Retry: Boolean)
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayStartPaymentRequest: Codeunit "NPR MobilePayV10 Start Payment";
        success: Boolean;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
        mobilePayDialog: Codeunit "NPR MobilePayV10 Dialog";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if (not IsRunningOutOfPosSession) then begin
            POSSession.GetSession(POSSession, true);
            POSSession.GetFrontEnd(POSFrontEnd, true);
        end;
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        success := mobilePayStartPaymentRequest.Run(EftTrxRequest);
        EftTrxRequest.Find();

        WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to start trx', mobilePayStartPaymentRequest.GetRequestResponse(), true);

        if not success then begin
            if mobilePayStartPaymentRequest.GetResponseHttpCode() <> 0 then begin
                if (TransactionIsCurrentlyActive(mobilePayStartPaymentRequest.GetResponse())) then begin
                    if TryCancelActiveTrx(eftSetup) and (not Retry) then begin
                        EftTrxRequest.Find();
                        StartPaymentTransaction(EftTrxRequest, true);
                        exit;
                    end;

                end;
                if mobilePayStartPaymentRequest.GetResponseHttpCode() <> 200 then begin
                    EftTrxRequest."External Result Known" := true; //We got an API response other than 200 - this means no trx was ever started.
                end;
            end;

            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();
            mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
            exit;
        end;

        if (not IsRunningOutOfPosSession) then begin
            mobilePayDialog.Initialize(POSFrontEnd, EftTrxRequest);
        end;
    end;

    local procedure StartRefundTransaction(EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayStartRefundRequest: Codeunit "NPR MobilePayV10 Start Refund";
        success: Boolean;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
        mobilePayDialog: Codeunit "NPR MobilePayV10 Dialog";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if (not IsRunningOutOfPosSession) then begin
            POSSession.GetSession(POSSession, true);
            POSSession.GetFrontEnd(POSFrontEnd, true);
        end;
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        success := mobilePayStartRefundRequest.Run(EftTrxRequest);
        EftTrxRequest.Find();

        WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to start trx', mobilePayStartRefundRequest.GetRequestResponse(), true);

        if not success then begin
            if mobilePayStartRefundRequest.GetResponseHttpCode() <> 0 then begin
                if (TransactionIsCurrentlyActive(mobilePayStartRefundRequest.GetResponse())) then begin
                    TryCancelActiveTrx(eftSetup);
                end;
                if mobilePayStartRefundRequest.GetResponseHttpCode() <> 200 then begin
                    EftTrxRequest."External Result Known" := true; //We got an API response other than 200 - this means no trx was ever started.
                end;
            end;

            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();
            mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
            exit;
        end;

        if (not IsRunningOutOfPosSession) then begin
            mobilePayDialog.Initialize(POSFrontEnd, EftTrxRequest);
        end;
    end;

    local procedure LookupTransaction(EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        // if mobilepay Id is unknown then GET /v10/payments with header filter on orderId, then GET /v10/payment/paymentId.
        // The reason we might not have their id on storage is if we hit an unexpected error before parsing & committing it initially.

        ClearLastError();

        if EftTrxRequest."Reference Number Output" = '' then begin
            if not FindTrx(EftTrxRequest, eftSetup, false, true) then begin
                HandleError(EftTrxRequest, GetLastErrorText);
                EftTrxRequest.Modify();

                if POSSession.IsActiveSession(POSFrontEnd) then begin
                    mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
                end;

                exit;
            end;
            Commit();
        end;

        if not PollTrxStatus(EftTrxRequest, eftSetup) then begin
            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();

            if POSSession.IsActiveSession(POSFrontEnd) then begin
                mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
            end;

            exit;
        end;
        Commit();

        // If trx is still active, then attempt to cancel and redo GET /v10/payment/paymentId to prevent customer from paying out-of-sync.         

        if (EftTrxRequest."Result Code" in ["NPR MobilePayV10 Result Code"::Initiated.AsInteger(),
                                            "NPR MobilePayV10 Result Code"::IssuedTouser.AsInteger(),
                                            "NPR MobilePayV10 Result Code"::Paired.AsInteger(),
                                            "NPR MobilePayV10 Result Code"::Prepared.AsInteger(),
                                            "NPR MobilePayV10 Result Code"::Reserved.AsInteger()]) then begin
            if RequestAbort(EftTrxRequest, eftSetup) then begin
                EftTrxRequest.Successful := true;
                EftTrxRequest."External Result Known" := true;
            end else begin
                EftTrxRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTrxRequest."NST Error"));
            end;
            EftTrxRequest.Modify();
            Commit();
        end;

        //mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);     // TODO: Causing problems when running CancelDead process (inside no POSSession!!!)

        if POSSession.IsActiveSession(POSFrontEnd) then begin
            mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
        end;
    end;

    local procedure GetAuthToken(EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayAuthRequest: Codeunit "NPR MobilePayV10 Auth";
        success: Boolean;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        if (not ExistCancelDeadTransactionsTask()) then begin
            CreateCancelDeadTransactionsTask(GuiAllowed);
            Commit();
        end;

        success := mobilePayAuthRequest.Run(EftTrxRequest);
        EftTrxRequest.Find();

        if not success then begin
            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();
        end;

        WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to get auth token', mobilePayAuthRequest.GetRequestResponse(), true);
        mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
    end;

    internal procedure CreatePOSInBackend(EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayCreatePOSRequest: Codeunit "NPR MobilePayV10 CreatePOS";
        success: Boolean;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        success := mobilePayCreatePOSRequest.Run(EftTrxRequest);
        EftTrxRequest.Find();

        if not success then begin
            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();
        end;

        WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API', mobilePayCreatePOSRequest.GetRequestResponse(), true);
        mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
    end;

    internal procedure DeletePOSInBackend(EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayDeletePOSRequest: Codeunit "NPR MobilePayV10 Delete POS";
        success: Boolean;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        success := mobilePayDeletePOSRequest.Run(EftTrxRequest);
        EftTrxRequest.Find();

        if not success then begin
            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();
        end;

        WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API', mobilePayDeletePOSRequest.GetRequestResponse(), true);
        mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
    end;

    local procedure FindActivePayment(eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayFindActivePayment: Codeunit "NPR MobilePayV10 FindActi.Pay.";
        success: Boolean;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        // TODO: We need to find all payments using their API and then iterate over them to get details.
        // As far as we know, we can have:
        // - Only 1 active trx ("initiated", "issued to user") per POS device which will block next MobilePay trxs.
        // - 0..n "reserved" (these are also unfinished) trxs but in this case these are not blocking next trxs.
        // We need to handle now only
        success := mobilePayFindActivePayment.Run(EftTrxRequest);
        EftTrxRequest.Find();

        if not success then begin
            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();
        end;

        WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API', mobilePayFindActivePayment.GetRequestResponse(), true);
        mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
    end;

    local procedure FindActiveRefund(eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayFindActiveRefund: Codeunit "NPR MobilePayV10 FindActi.Ref.";
        success: Boolean;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftSetup.FindSetup(EftTrxRequest."Register No.", EftTrxRequest."Original POS Payment Type Code");

        success := mobilePayFindActiveRefund.Run(EftTrxRequest);
        EftTrxRequest.Find();

        if not success then begin
            HandleError(EftTrxRequest, GetLastErrorText);
            EftTrxRequest.Modify();
        end;

        WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API', mobilePayFindActiveRefund.GetRequestResponse(), true);
        mobilePayIntegration.HandleProtocolResponse(EftTrxRequest);
    end;

    internal procedure GetURL(eftSetup: Record "NPR EFT Setup"; AllowUrlSwitching: Boolean): Text;
    var
        url: Text;
        handled: Boolean;
        mobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
    begin
        if (AllowUrlSwitching) then begin
            OnBeforeGetBaseURL(url, handled);
            if handled then
                exit(url);
        end;

        mobilePayPaymentSetup.Get(eftSetup."Payment Type POS");

        case mobilePayPaymentSetup.Environment of
            mobilePayPaymentSetup.Environment::Production:
                exit('https://api.mobilepay.dk');
            mobilePayPaymentSetup.Environment::Sandbox:
                exit('https://api.sandbox.mobilepay.dk');
        end;
    end;

    internal procedure GetURL(eftSetup: Record "NPR EFT Setup"): Text;
    begin
        exit(GetURL(eftSetup, true));
    end;

    internal procedure PollTrxStatus(var eftTrxRequest: Record "NPR EFT Transaction Request"; eftSetup: Record "NPR EFT Setup"): Boolean
    var
        mobilePayPollPaymentRequest: Codeunit "NPR MobilePayV10 Poll Payment";
        mobilePayPollRefundRequest: Codeunit "NPR MobilePayV10 Poll Refund";
        success: Boolean;
        procEftTrxRequest: Record "NPR EFT Transaction Request";
    begin
        if (eftTrxRequest."Processed Entry No." <> 0) and
           (not (eftTrxRequest."Processing Type" in [eftTrxRequest."Processing Type"::PAYMENT, eftTrxRequest."Processing Type"::REFUND]))
        then begin
            procEftTrxRequest.Get(eftTrxRequest."Processed Entry No.");
        end else begin
            procEftTrxRequest := eftTrxRequest;
        end;

        case procEftTrxRequest."Processing Type" of
            procEftTrxRequest."Processing Type"::PAYMENT:
                begin
                    success := mobilePayPollPaymentRequest.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to poll', mobilePayPollPaymentRequest.GetRequestResponse(), true);
                end;
            procEftTrxRequest."Processing Type"::REFUND:
                begin
                    success := mobilePayPollRefundRequest.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to poll', mobilePayPollRefundRequest.GetRequestResponse(), true);
                end;
            else begin
                    Error(UNSUPPORTED_POLLSTATUS_PROCESSING_TYPE_Err,
                        procEftTrxRequest."Processing Type",
                        procEftTrxRequest.FieldCaption("Processing Type"),
                        'PollTrxStatus',
                        procEftTrxRequest."Processing Type"::PAYMENT,
                        procEftTrxRequest."Processing Type"::REFUND);
                end;
        end;
        EftTrxRequest.Find();
        Exit(success);
    end;

    internal procedure CaptureTrx(var eftTrxRequest: Record "NPR EFT Transaction Request"; eftSetup: Record "NPR EFT Setup"): Boolean
    var
        mobilePayCapturePaymentRequest: Codeunit "NPR MobilePayV10 Capt. Payment";
        mobilePayCaptureRefundRequest: Codeunit "NPR MobilePayV10 Capt. Refund";
        success: Boolean;
    begin
        case EftTrxRequest."Processing Type" of
            EftTrxRequest."Processing Type"::PAYMENT:
                begin
                    success := mobilePayCapturePaymentRequest.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to capture', mobilePayCapturePaymentRequest.GetRequestResponse(), true);
                end;
            EftTrxRequest."Processing Type"::REFUND:
                begin
                    success := mobilePayCaptureRefundRequest.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to capture', mobilePayCaptureRefundRequest.GetRequestResponse(), true);
                end;
        end;
        EftTrxRequest.Find();
        Exit(success);
    end;

    internal procedure RequestAbort(var eftTrxRequest: Record "NPR EFT Transaction Request"; eftSetup: Record "NPR EFT Setup"): Boolean
    var
        mobilePayCancelPayment: Codeunit "NPR MobilePayV10 Can.Payment";
        mobilePayCancelRefund: Codeunit "NPR MobilePayV10 Can. Refund";
        success: Boolean;
        procEftTrxRequest: Record "NPR EFT Transaction Request";
    begin
        if (eftTrxRequest."Processed Entry No." <> 0) and
           (not (eftTrxRequest."Processing Type" in [eftTrxRequest."Processing Type"::PAYMENT, eftTrxRequest."Processing Type"::REFUND]))
        then begin
            procEftTrxRequest.Get(eftTrxRequest."Processed Entry No.");
        end else begin
            procEftTrxRequest := eftTrxRequest;
        end;

        case procEftTrxRequest."Processing Type" of
            procEftTrxRequest."Processing Type"::PAYMENT:
                begin
                    success := mobilePayCancelPayment.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to cancel', mobilePayCancelPayment.GetRequestResponse(), true);
                end;
            procEftTrxRequest."Processing Type"::REFUND:
                begin
                    success := mobilePayCancelRefund.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to cancel', mobilePayCancelRefund.GetRequestResponse(), true);
                end;
            else begin
                    Error(UNSUPPORTED_POLLSTATUS_PROCESSING_TYPE_Err,
                        procEftTrxRequest."Processing Type",
                        procEftTrxRequest.FieldCaption("Processing Type"),
                        'RequestAbort',
                        procEftTrxRequest."Processing Type"::PAYMENT,
                        procEftTrxRequest."Processing Type"::REFUND);
                end;
        end;
        EftTrxRequest.Find();
        Exit(success);
    end;

    internal procedure ForceAbort(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        EFTTransactionRequest."Force Closed" := true;
        EFTTransactionRequest.Modify();

        mobilePayIntegration.HandleProtocolResponse(EFTTransactionRequest);
    end;

    internal procedure GetQRBeaconId(eftTrxRequest: Record "NPR EFT Transaction Request"): Text
    var
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        MobilePayPosLbl: Label 'mobilepaypos://pos?id=%1&source=qr', Locked = true;
    begin
        mobilePayUnitSetup.Get(eftTrxRequest."Register No.");
        exit(StrSubstNo(MobilePayPosLbl, mobilePayUnitSetup."Beacon ID").ToLower());
    end;

    internal procedure GetClientVersion(): Text
    begin
        exit('1.1.0');
    end;

    internal procedure WriteLogEntry(EFTSetup: Record "NPR EFT Setup"; IsError: Boolean; EntryNo: Integer; Description: Text; LogContents: Text; CommitChanges: Boolean)
    var
        mobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
    begin
        mobilePayPaymentSetup.Get(EFTSetup."Payment Type POS");
        case mobilePayPaymentSetup."Log Level" of
            mobilePayPaymentSetup."Log Level"::Errors:
                if IsError then
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents)
                else
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, '');

            mobilePayPaymentSetup."Log Level"::All:
                EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents);
        end;

        if (CommitChanges) then begin
            Commit();
        end;
    end;

    internal procedure GetToken(EFTSetup: Record "NPR EFT Setup"): Text
    var
        mobilePayToken: codeunit "NPR MobilePayV10 Token";
        token: Text;
        eftTrxRequest: Record "NPR EFT Transaction Request";
        eftFramework: Codeunit "NPR EFT Framework Mgt.";
        mobilePayAuxRequest: Enum "NPR MobilePayV10 Aux. Req.";
    begin
        if mobilePayToken.TryGetToken(token) then
            exit(token);

        eftFramework.CreateAuxRequest(eftTrxRequest, EFTSetup, mobilePayAuxRequest::AuthTokenRequest.AsInteger(), EFTSetup."POS Unit No.", '');
        Commit();
        eftFramework.SendRequest(eftTrxRequest);
        Commit();

        if mobilePayToken.TryGetToken(token) then
            exit(token);

        eftTrxRequest.Find();
        error(AUTH_TOKEN_Err, eftTrxRequest."NST Error");
    end;

    internal procedure ExistCancelDeadTransactionsTask(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR MobilePayV10 CancelDead");
        exit(not JobQueueEntry.IsEmpty());
    end;

    internal procedure CreateCancelDeadTransactionsTask(WithPrompt: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
    begin
        if (WithPrompt) then begin
            if not Confirm(CREATE_DEAD_TRANSACTIONS_JOBQUEUE_ENTRY_Qst, true) then
                Error(CANCELED_BY_USER_Err);
        end;

        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueCategory.InsertRec(MobilePayJobQueueCategoryCode_Lbl, MobilePayJobQueueCategoryDescription_Lbl);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR MobilePayV10 CancelDead",
            '',
            CANCEL_DEAD_TRANSACTIONS_JOBQUEUE_DESCRIPTION_Lbl,
            CurrentDateTime(),
            020000T,
            030000T,
            NextRunDateFormula,
            JobQueueCategory.Code,
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure TransactionIsCurrentlyActive(response: Text): Boolean
    var
        jsonResponse: JsonObject;
        jsonToken: JsonToken;
    begin
        if jsonResponse.ReadFrom(response) then begin
            if jsonResponse.SelectToken('code', jsonToken) then begin
                exit(jsonToken.AsValue().AsInteger() = 1301); //Is the error for currently active transaction preventing a new one from starting.
            end;
        end;
    end;

    local procedure HandleError(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ErrorText: Text)
    begin
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."Result Amount" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        EFTTransactionRequest."Result Display Text" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
    end;

    internal procedure SetRunningOutOfPosSession(RunningOutOfPosSession: Boolean)
    begin
        IsRunningOutOfPosSession := RunningOutOfPosSession
    end;

    [NonDebuggable]
    internal procedure GetClientId(eftSetup: Record "NPR EFT Setup"): Text
    var
        mobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        mobilePayPaymentSetup.Get(eftSetup."Payment Type POS");

        case mobilePayPaymentSetup.Environment of
            mobilePayPaymentSetup.Environment::Production:
                exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailMobilePayV10ProductionClientId'));
            mobilePayPaymentSetup.Environment::Sandbox:
                exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailMobilePayV10SandboxClientId'));
        end;
    end;

    [NonDebuggable]
    internal procedure GetClientSecret(eftSetup: Record "NPR EFT Setup"): Text
    var
        mobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        mobilePayPaymentSetup.Get(eftSetup."Payment Type POS");

        case mobilePayPaymentSetup.Environment of
            mobilePayPaymentSetup.Environment::Production:
                exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailMobilePayV10ProductionClientSecret'));
            mobilePayPaymentSetup.Environment::Sandbox:
                exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailMobilePayV10SandboxClientSecret'));
        end;
    end;

    internal procedure SetGenericHeaders(EftSetup: Record "NPR EFT Setup"; var ReqMessage: HttpRequestMessage; HttpRequestHelper: Codeunit "NPR HttpRequest Helper")
    var
        headers: HttpHeaders;
        eftTrxRequest: Record "NPR EFT Transaction Request";
    begin
        Clear(eftTrxRequest);
        SetGenericHeaders(EftSetup, ReqMessage, HttpRequestHelper, headers, EftTrxRequest);
    end;

    internal procedure SetGenericHeaders(EftSetup: Record "NPR EFT Setup"; var ReqMessage: HttpRequestMessage; HttpRequestHelper: Codeunit "NPR HttpRequest Helper";
        var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        headers: HttpHeaders;
    begin
        SetGenericHeaders(EftSetup, ReqMessage, HttpRequestHelper, headers, EftTrxRequest);
    end;

    internal procedure SetGenericHeaders(EftSetup: Record "NPR EFT Setup"; var ReqMessage: HttpRequestMessage; HttpRequestHelper: Codeunit "NPR HttpRequest Helper"; var Headers: HttpHeaders;
        var EftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayCorrelation: Codeunit "NPR MobilePayV10 Correlat. ID";
    begin
        ReqMessage.GetHeaders(headers);
        HttpRequestHelper.SetHeaderCollectionObject(Headers);
        HttpRequestHelper.SetHeader('accept', 'application/json');
        HttpRequestHelper.SetHeader('authorization', 'Bearer ' + GetToken(eftSetup));
        HttpRequestHelper.SetHeader('x-ibm-client-id', GetClientId(eftSetup));
        HttpRequestHelper.SetHeader('CorrelationId', mobilePayCorrelation.GetCurrentID());
        HttpRequestHelper.SetHeader('x-mobilepay-client-system-version', GetClientVersion());

        if (EftTrxRequest."Entry No." <> 0) then begin
            EftTrxRequest.TestField(Token);
            HttpRequestHelper.SetHeader('x-mobilepay-idempotency-key', DelChr(Format(EftTrxRequest.Token), '=', '{}'));
        end;
    end;

    internal procedure SendAndPreHandleTheRequest(var HttpClient: HttpClient; var ReqMessage: HttpRequestMessage; var RespMessage: HttpResponseMessage;
        HttpRequestHelper: Codeunit "NPR HttpRequest Helper")
    begin
        SendAndPreHandleTheRequest(HttpClient, ReqMessage, RespMessage, HttpRequestHelper, 5 * 1000, '');
    end;

    internal procedure SendAndPreHandleTheRequest(var HttpClient: HttpClient; var ReqMessage: HttpRequestMessage; var RespMessage: HttpResponseMessage;
        HttpRequestHelper: Codeunit "NPR HttpRequest Helper"; Timeout: Integer)
    begin
        SendAndPreHandleTheRequest(HttpClient, ReqMessage, RespMessage, HttpRequestHelper, Timeout, '');
    end;

    internal procedure SendAndPreHandleTheRequest(var HttpClient: HttpClient; var ReqMessage: HttpRequestMessage; var RespMessage: HttpResponseMessage;
        HttpRequestHelper: Codeunit "NPR HttpRequest Helper"; ThrottlingEndnpoint: Text)
    begin
        SendAndPreHandleTheRequest(HttpClient, ReqMessage, RespMessage, HttpRequestHelper, 5 * 1000, ThrottlingEndnpoint);
    end;

    internal procedure SendAndPreHandleTheRequest(var HttpClient: HttpClient; var ReqMessage: HttpRequestMessage; var RespMessage: HttpResponseMessage;
        HttpRequestHelper: Codeunit "NPR HttpRequest Helper"; Timeout: Integer; ThrottlingEndnpoint: Text)
    var
        retry: Boolean;
        retryCounter: Integer;
        attempts: Integer;
        Request: HttpRequestMessage;
        mobilePayCallThrtl: Codeunit "NPR MobilePayV10 Call Thrtl.";
    begin
        retry := true;
        attempts := 5;

        mobilePayCallThrtl.CheckPollingThrottlingLimitAndWait(ThrottlingEndnpoint);

        while (retry) do begin
            retryCounter += 1;

            HttpRequestHelper.CopyRequest(ReqMessage, Request);

            Clear(respMessage);
            TrySend(Request, RespMessage, Timeout);

            case respMessage.HttpStatusCode of
                0, 500:
                    begin
                        retry := true;
                        attempts -= 1;
                    end;
                else begin
                        retry := not RespMessage.IsSuccessStatusCode;
                        attempts := 0;
                    end;
            end;

            retry := retry and (attempts > 0);

            if (retry) then begin
                Sleep(retryCounter * 1000);
            end;

        end;
    end;

    local procedure TrySend(ReqMessage: HttpRequestMessage; RespMessage: HttpResponseMessage; Timeout: Integer): Boolean
    var
        HttpClient: HttpClient;
    begin
        HttpClient.Timeout := Timeout;
        exit(httpClient.Send(reqMessage, respMessage));
    end;

    internal procedure PreHandlerTheResponse(reqMessage: HttpRequestMessage; var respMessage: HttpResponseMessage;
        var jsonResponse: JsonObject; ResponseBodyExpected: Boolean; PollingEndpoint: Text)
    var
        mobilePayCallThrtl: Codeunit "NPR MobilePayV10 Call Thrtl.";
        stream: InStream;
        errorCode: Text;
        jsonToken: JsonToken;
        pollValue: JsonToken;
        errorCodeLbl: Label '(%1) %2', Locked = true;
    begin
        if not respMessage.IsSuccessStatusCode() then begin

            if respMessage.Content.ReadAs(stream) then begin
                if (jsonResponse.ReadFrom(stream)) then begin
                    if (jsonResponse.SelectToken('pollDelayInMs', pollValue)) and (PollingEndpoint <> '') then begin
                        mobilePayCallThrtl.SetPollingLimit(PollingEndpoint, pollValue.AsValue().AsInteger());
                    end;

                    if jsonResponse.SelectToken('error', jsonToken) then begin
                        error(jsonToken.AsValue().AsText());
                    end;

                    if jsonResponse.SelectToken('code', jsonToken) then begin
                        errorCode := jsonToken.AsValue().AsText();
                        if jsonResponse.SelectToken('message', jsonToken) then begin
                            error(errorCodeLbl, errorCode, jsonToken.AsValue().AsText());
                        end;

                        error(errorCode);
                    end;
                end;
            end;

            // Generic HTTP error handling:
            error('(%1) %2', respMessage.HttpStatusCode, respMessage.ReasonPhrase);
        end;

        // Response is successful
        respMessage.Content.ReadAs(stream);
        if not jsonResponse.ReadFrom(stream) then begin
            if (ResponseBodyExpected) then begin
                error(MobilePayResponseExpectedButEmptyErr);
            end;
        end;

        if (PollingEndpoint <> '') then begin
            if (jsonResponse.SelectToken('pollDelayInMs', pollValue)) then begin
                mobilePayCallThrtl.SetPollingLimit(PollingEndpoint, pollValue.AsValue().AsInteger());
            end;
        end;
    end;

    local procedure FindTrx(var EftTrxRequest: Record "NPR EFT Transaction Request"; EftSetup: Record "NPR EFT Setup"; ActiveOnly: Boolean; OnlyForOriginalEntryNo: Boolean): Boolean
    var
        mobilePayFindPaymentReq: Codeunit "NPR MobilePayV10 Find Payment";
        mobilePayFindRefundReq: Codeunit "NPR MobilePayV10 Find Refund";
        originalEftTrxRequest: Record "NPR EFT Transaction Request";
        tempMobilePayV10Payment: Record "NPR MobilePayV10 Payment" temporary;
        tempMobilePayV10Refund: Record "NPR MobilePayV10 Refund" temporary;
        success: Boolean;
        paymentEftTrxRequest: Record "NPR EFT Transaction Request";
        FindPymReqLbl: Label 'orderId=%1&posId=%2', Locked = true;
        PymIdLbl: Label 'paymentId=%1', Locked = true;
    begin
        originalEftTrxRequest.Get(EftTrxRequest."Processed Entry No.");

        case originalEftTrxRequest."Processing Type" of
            originalEftTrxRequest."Processing Type"::PAYMENT:
                begin
                    tempMobilePayV10Payment.Reset();
                    tempMobilePayV10Payment.DeleteAll();
                    mobilePayFindPaymentReq.SetPaymentDetailBuffer(tempMobilePayV10Payment);

                    mobilePayFindPaymentReq.SetFilter(StrSubstNo(FindPymReqLbl,
                        format(originalEftTrxRequest."Entry No."),
                        format(originalEftTrxRequest."Hardware ID")));
                    success := mobilePayFindPaymentReq.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to get trx ID', mobilePayFindPaymentReq.GetRequestResponse(), true);

                    if (success) then begin
                        GetPaymentDetails(tempMobilePayV10Payment, EftSetup);

                        tempMobilePayV10Payment.Reset();
                        //if tempMobilePayV10Payment.FindFirst() then;    // temp only to see if the values have been updated
                        if (ActiveOnly) then begin
                            tempMobilePayV10Payment.SetFilter(Status, '%1|%2',
                                tempMobilePayV10Payment.Status::Initiated,
                                tempMobilePayV10Payment.Status::IssuedTouser);
                        end;

                        if (OnlyForOriginalEntryNo) then begin
                            tempMobilePayV10Payment.SetRange(OrderId, Format(originalEftTrxRequest."Entry No."));
                        end;

                        // There is just one (MobilePayV10 does allow only 1 by definition) active transaction or not:
                        success := tempMobilePayV10Payment.FindFirst();

                        if (success) then begin
                            if (EftTrxRequest."Reference Number Output" = '') then begin
                                EftTrxRequest."Reference Number Output" := tempMobilePayV10Payment.PaymentId;
                                EftTrxRequest.Modify();
                            end;
                        end;
                    end;
                end;

            originalEftTrxRequest."Processing Type"::REFUND:
                begin
                    paymentEftTrxRequest.Get(originalEftTrxRequest."Processed Entry No.");
                    paymentEftTrxRequest.TestField("Processing Type", paymentEftTrxRequest."Processing Type"::PAYMENT);
                    paymentEftTrxRequest.TestField("Reference Number Output");

                    tempMobilePayV10Refund.Reset();
                    tempMobilePayV10Refund.DeleteAll();
                    mobilePayFindRefundReq.SetRefundDetailBuffer(tempMobilePayV10Refund);

                    mobilePayFindRefundReq.SetFilter(StrSubstNo(PymIdLbl,
                        paymentEftTrxRequest."Reference Number Output"));
                    success := mobilePayFindRefundReq.Run(EftTrxRequest);
                    WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to get trx ID', mobilePayFindRefundReq.GetRequestResponse(), true);

                    if (success) then begin
                        tempMobilePayV10Refund.Reset();
                        // We assume only 1 refund per payment (full refunds only).
                        success := tempMobilePayV10Refund.FindFirst();

                        if (success) then begin
                            if (EftTrxRequest."Reference Number Output" = '') then begin
                                EftTrxRequest."Reference Number Output" := tempMobilePayV10Refund.RefundId;
                                EftTrxRequest.Modify();
                            end;
                        end;
                    end;
                end;
        end;
        EftTrxRequest.Find();
        Exit(success);
    end;

    local procedure GetPaymentDetails(var tempMobilePayV10Payment: Record "NPR MobilePayV10 Payment" temporary; EftSetup: Record "NPR EFT Setup")
    var
        tempMobilePayV10Payment2: Record "NPR MobilePayV10 Payment" temporary;
        eftTransRequest: Record "NPR EFT Transaction Request";
        eftFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        mobilePayV10GetPayment: Codeunit "NPR MobilePayV10 Get Payment";
        mobilePayV10AuxiliaryRequest: Enum "NPR MobilePayV10 Aux. Req.";
        success: Boolean;
    begin
        tempMobilePayV10Payment.Reset();
        tempMobilePayV10Payment2.Copy(tempMobilePayV10Payment, true);

        if (tempMobilePayV10Payment.FindSet()) then begin
            repeat

                tempMobilePayV10Payment2.Get(tempMobilePayV10Payment.PaymentId);

                Clear(eftTransRequest);
                eftFrameworkMgt.CreateAuxRequest(eftTransRequest, EftSetup, mobilePayV10AuxiliaryRequest::GetPaymentDetail.AsInteger(), EftSetup."POS Unit No.", '');
                eftTransRequest."Reference Number Output" := tempMobilePayV10Payment2.PaymentId;
                eftTransRequest.Modify();
                Commit();

                mobilePayV10GetPayment.SetPaymentDetailBuffer(tempMobilePayV10Payment2);
                success := mobilePayV10GetPayment.Run(eftTransRequest);

                WriteLogEntry(eftSetup, not success, eftTransRequest."Entry No.", 'Invoked API to get trx ID', mobilePayV10GetPayment.GetRequestResponse(), true);

            until tempMobilePayV10Payment.Next() = 0;
        end;
    end;

    local procedure TryCancelActiveTrx(eftSetup: Record "NPR EFT Setup"): Boolean
    var
        eftFramework: Codeunit "NPR EFT Framework Mgt.";
        eftTrxRequest: Record "NPR EFT Transaction Request";
        mobilePayAuxRequest: Enum "NPR MobilePayV10 Aux. Req.";
        success: Boolean;
        mobilePayCancelPayment: Codeunit "NPR MobilePayV10 Can.Payment";
        mobilePayCancelRefund: Codeunit "NPR MobilePayV10 Can. Refund";
    begin
        eftFramework.CreateAuxRequest(eftTrxRequest, eftSetup, mobilePayAuxRequest::FindActivePayment.AsInteger(), eftSetup."POS Unit No.", '');
        Commit();
        eftFramework.SendRequest(eftTrxRequest);
        Commit();
        eftTrxRequest.Find();

        if eftTrxRequest.Successful then begin
            //We found an active payment. Attempt to cancel it.
            success := mobilePayCancelPayment.Run(EftTrxRequest);
            WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to cancel', mobilePayCancelPayment.GetRequestResponse(), true);
            exit(success);
        end;
        clear(eftTrxRequest);

        eftFramework.CreateAuxRequest(eftTrxRequest, eftSetup, mobilePayAuxRequest::FindActiveRefund.AsInteger(), eftSetup."POS Unit No.", '');
        Commit();
        eftFramework.SendRequest(eftTrxRequest);
        Commit();
        eftTrxRequest.Find();

        if eftTrxRequest.Successful then begin
            //We found an active refund. Attempt to cancel it.
            success := mobilePayCancelRefund.Run(EftTrxRequest);
            WriteLogEntry(eftSetup, not success, EftTrxRequest."Entry No.", 'Invoked API to cancel', mobilePayCancelRefund.GetRequestResponse(), true);
            exit(success);
        end;
    end;



    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBaseURL(var url: text; var handled: boolean)
    begin
    end;
}
