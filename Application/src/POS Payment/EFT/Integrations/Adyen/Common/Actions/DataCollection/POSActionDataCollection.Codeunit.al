codeunit 6248387 "NPR POS Action Data Collection" implements "NPR IPOS Workflow"
{
    Access = Internal;
    SingleInstance = true;

    var
        _trxStatus: Dictionary of [Integer, Integer]; //EntryNo, AdyenCloudTrxStatusEnum
        _trxAbortStatus: Dictionary of [Integer, Boolean]; //EntryNo, BackgroundTaskIsRunning
        _trxResponse: Dictionary of [Integer, List of [Text]];

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action collects data from the customer in terms of signature, phone number and e-mail.';
        DataCollectionTitle: Label 'Data Collection';
        CaptionRequestCollectInformation: Label 'Request Collect Information';
        RequestCollectionInformationOption: Label 'ReturnInformation,AcquireSignature', Locked = true;
        RequestCollectionInformationOptionCaption: Label 'Return Information,Acquire Signature';
        InformationCollectedContextLbl: Label 'Information Context';
        InformationCollectedContextDescLbl: Label 'Defines the context(reason) of the information collected from the customer.';
        InitialStatusLbl: Label 'Initializing';
        CollectingDataStatusLbl: Label 'Collecting Data';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('dataCollectionTitle', DataCollectionTitle);
        WorkflowConfig.AddLabel('initialStatus', InitialStatusLbl);
        WorkflowConfig.AddLabel('collectingDataStatus', CollectingDataStatusLbl);
        WorkflowConfig.AddOptionParameter(
            'requestCollectInformation',
            RequestCollectionInformationOption,
#pragma warning disable AA0139
            SelectStr(1, RequestCollectionInformationOption),
#pragma warning restore
            CaptionRequestCollectInformation,
            RequestCollectionInformationOptionCaption,
            RequestCollectionInformationOptionCaption);
        WorkflowConfig.AddTextParameter('informationContext', '', InformationCollectedContextLbl, InformationCollectedContextDescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: Codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    var
        RequestCollectInformationOption: Option ReturnInformation,AcquireSignature;
    begin
        RequestCollectInformationOption := Context.GetIntegerParameter('requestCollectInformation');
        case RequestCollectInformationOption of
            RequestCollectInformationOption::ReturnInformation:
                //Return Information Collection
                case Step of
                    'collectData':
                        FrontEnd.WorkflowResponse(CollectData(SaleMgr));
                    'poll':
                        FrontEnd.WorkflowResponse(PollResponse(Context.GetInteger('EntryNo')));
                    'signatureDecline':
                        FrontEnd.WorkflowResponse(SignatureDecline(Context.GetInteger('EntryNo')));
                    'signatureApprove':
                        FrontEnd.WorkflowResponse(SignatureApprove(Context));
                    'requestAbort':
                        RequestTrxAbort(Context.GetInteger('EntryNo'));
                end;
            RequestCollectInformationOption::AcquireSignature:
                case Step of
                    'collectSignature':
                        FrontEnd.WorkflowResponse(CollectInsertedSignature(Context, SaleMgr));
                end;
        end;
    end;

    local procedure CollectData(SaleMgr: Codeunit "NPR POS Sale"): JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        MMMemberInfoIntSetup: Record "NPR MM Member Info. Int. Setup";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        POSActionDataCollectionB: Codeunit "NPR POS Action DataCollectionB";
        Parameters: Dictionary of [Text, Text];
        TaskId: Integer;
        PhoneNoReqEntryNo: Integer;
        SignatureReqEntryNo: Integer;
        EMailReqEntryNo: Integer;
        Response: JsonObject;
    begin
        ClearGlobalState();

        MMMemberInfoIntSetup.Get();

        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);

        SaleMgr.GetCurrentSale(SalePOS);

        case true of
            POSActionDataCollectionB.RequestSignature(SalePOS, SignatureReqEntryNo):
                begin
                    Response.Add('newEntryNo', SignatureReqEntryNo);
                    EftTransactionRequest.Get(SignatureReqEntryNo);
                    _trxStatus.Set(SignatureReqEntryNo, Enum::"NPR EFT DataCollect TaskStatus"::Initiated.AsInteger());
                end;
            POSActionDataCollectionB.RequestPhoneNo(SalePOS, PhoneNoReqEntryNo):
                begin
                    Response.Add('newEntryNo', PhoneNoReqEntryNo);
                    EftTransactionRequest.Get(PhoneNoReqEntryNo);
                    _trxStatus.Set(SignatureReqEntryNo, Enum::"NPR EFT DataCollect TaskStatus"::Initiated.AsInteger());
                end;
            POSActionDataCollectionB.RequestEMail(SalePOS, EMailReqEntryNo):
                begin
                    Response.Add('newEntryNo', EMailReqEntryNo);
                    EftTransactionRequest.Get(EMailReqEntryNo);
                    _trxStatus.Set(SignatureReqEntryNo, Enum::"NPR EFT DataCollect TaskStatus"::Initiated.AsInteger());
                end;
        end;

        Parameters.Add('EntryNo', Format(EftTransactionRequest."Entry No."));
        Parameters.Add('IntegrationType', Format(MMMemberInfoIntSetup."Request Return Info"));

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    "NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger():
                        begin
                            Parameters.Add('DataCollectionStep', Format(Enum::"NPR Data Collect Step"::Signature));
                            _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT DataCollect TaskStatus"::SignatureResponseInitiated.AsInteger());
                            POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::GENERIC_DATA_COLLECTION, Parameters, 1000 * 60 * 5);
                        end;
                    "NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger():
                        begin
                            Parameters.Add('DataCollectionStep', Format(Enum::"NPR Data Collect Step"::PhoneNo));
                            _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT DataCollect TaskStatus"::PhoneNoResponseInitiated.AsInteger());
                            POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::GENERIC_DATA_COLLECTION, Parameters, 1000 * 60 * 5);
                        end;
                    "NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger():
                        begin
                            Parameters.Add('DataCollectionStep', Format(Enum::"NPR Data Collect Step"::EMail));
                            _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT DataCollect TaskStatus"::EmailResponseInitiated.AsInteger());
                            POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::GENERIC_DATA_COLLECTION, Parameters, 1000 * 60 * 5);
                        end;
                end;
        end;

        Response.Add('taskId', TaskId);
        Response.Add('selfService', EftTransactionRequest."Self Service");
        exit(Response);
    end;

    local procedure PollResponse(EntryNo: Integer): JsonObject
    var
        TrxStatus: Enum "NPR EFT DataCollect TaskStatus";
        Response: JsonObject;
    begin
        TrxStatus := Enum::"NPR EFT DataCollect TaskStatus".FromInteger(_trxStatus.Get(EntryNo));

        case TrxStatus of
            TrxStatus::SignatureResponseReceived:
                begin
                    exit(ProcessSignatureRequest(EntryNo));
                end;
            TrxStatus::PhoneNoResponseRecevied:
                begin
                    exit(ProcessAcquirePhoneNoRequest(EntryNo));
                end;
            TrxStatus::EmailResponseReceived:
                begin
                    exit(ProcessAcquireEMailRequest(EntryNo));
                end;
            TrxStatus::ResultReceived:
                begin
                    exit(ProcessResult(EntryNo));
                end;
            else begin
                Response.Add('done', false);
                Response.Add('success', false);
                exit(Response);
            end;
        end;
    end;

    local procedure ProcessSignatureRequest(EntryNo: Integer): JsonObject
    var
        MMMemberInfoIntSetup: Record "NPR MM Member Info. Int. Setup";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR POS Sale";
        POSActionDataCollectionB: Codeunit "NPR POS Action DataCollectionB";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        POSSession: Codeunit "NPR POS Session";
        ContinueOnEntryNo: Integer;
        Response: JsonObject;
        Parameters: Dictionary of [Text, Text];
        TaskId: Integer;
        ResultMessageOut: Text;
        PhoneNoReqEntryNo: Integer;
        EMailReqEntryNo: Integer;
    begin
        if not ProcessResponse(EntryNo) then
            exit;

        EFTTransactionRequest.Get(EntryNo);
        if EFTTransactionRequest."Result Code" = -10 then begin
            // Previous Trx is still in progress on terminal. Fire off abort in background to help it back to idle while processing this failure.
            TryAbortMostRecentTrx(EFTTransactionRequest);
        end;

        SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        MMMemberInfoIntSetup.Get();
        Parameters.Add('IntegrationType', Format(MMMemberInfoIntSetup."Request Return Info"));

        if POSActionDataCollectionB.ContinueAfterDataCollectionVerification(EntryNo, ContinueOnEntryNo) then begin
            case true of
                POSActionDataCollectionB.RequestPhoneNo(SalePOS, PhoneNoReqEntryNo):
                    begin
                        _trxStatus.Set(ContinueOnEntryNo, Enum::"NPR EFT DataCollect TaskStatus"::PhoneNoResponseInitiated.AsInteger());

                        Response.Add('newEntryNo', PhoneNoReqEntryNo);
                        EftTransactionRequest.Get(PhoneNoReqEntryNo);
                        _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::Initiated.AsInteger());

                        Parameters.Add('EntryNo', Format(EftTransactionRequest."Entry No."));
                        Parameters.Add('DataCollectionStep', Format(Enum::"NPR Data Collect Step"::PhoneNo));
                        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
                        _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT DataCollect TaskStatus"::PhoneNoResponseInitiated.AsInteger());
                        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::GENERIC_DATA_COLLECTION, Parameters, 1000 * 60 * 5);

                        Response.Add('taskId', TaskId);
                        Response.Add('done', false);
                    end;
                POSActionDataCollectionB.RequestEMail(SalePOS, EMailReqEntryNo):
                    begin
                        _trxStatus.Set(ContinueOnEntryNo, Enum::"NPR EFT DataCollect TaskStatus"::EmailResponseInitiated.AsInteger());

                        Response.Add('newEntryNo', EMailReqEntryNo);
                        EftTransactionRequest.Get(EMailReqEntryNo);
                        _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::Initiated.AsInteger());

                        Parameters.Add('EntryNo', Format(EftTransactionRequest."Entry No."));
                        Parameters.Add('DataCollectionStep', Format(Enum::"NPR Data Collect Step"::EMail));
                        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
                        _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT DataCollect TaskStatus"::EmailResponseInitiated.AsInteger());
                        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::GENERIC_DATA_COLLECTION, Parameters, 1000 * 60 * 5);

                        Response.Add('taskId', TaskId);
                        Response.Add('done', false);
                    end;
                else begin
                    if (not EFTTransactionRequest."Self Service") then begin
                        if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
                            Message(ResultMessageOut);
                        end;
                    end;

                    _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::ResultReceived.AsInteger());

                    Response.Add('done', false);
                    Response.Add('success', true);
                end;
            end;
        end else begin
            if (not EFTTransactionRequest."Self Service") then begin
                if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
                    Message(ResultMessageOut);
                end;
            end;

            _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::ResultReceived.AsInteger());

            Response.Add('done', true);
            Response.Add('success', false);
        end;

        exit(Response);
    end;

    local procedure ProcessAcquirePhoneNoRequest(EntryNo: Integer): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MMMemberInfoIntSetup: Record "NPR MM Member Info. Int. Setup";
        SalePOS: Record "NPR POS Sale";
        POSActionDataCollectionB: Codeunit "NPR POS Action DataCollectionB";
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        ResultMessageOut: Text;
        ContinueOnEntryNo: Integer;
        TaskId: Integer;
        EMailReqEntryNo: Integer;
        Parameters: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        if not ProcessResponse(EntryNo) then
            exit;

        EFTTransactionRequest.Get(EntryNo);
        if EFTTransactionRequest."Result Code" = -10 then begin
            // Previous Trx is still in progress on terminal. Fire off abort in background to help it back to idle while processing this failure.
            TryAbortMostRecentTrx(EFTTransactionRequest);
        end;

        SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");

        if POSActionDataCollectionB.ContinueAfterDataCollectionVerification(EntryNo, ContinueOnEntryNo) then begin
            case true of
                POSActionDataCollectionB.RequestEMail(SalePOS, EMailReqEntryNo):
                    begin
                        _trxStatus.Set(ContinueOnEntryNo, Enum::"NPR EFT DataCollect TaskStatus"::EmailResponseInitiated.AsInteger());

                        Response.Add('newEntryNo', EMailReqEntryNo);
                        EftTransactionRequest.Get(EMailReqEntryNo);
                        _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::Initiated.AsInteger());

                        Parameters.Add('EntryNo', Format(EftTransactionRequest."Entry No."));
                        MMMemberInfoIntSetup.Get();
                        Parameters.Add('IntegrationType', Format(MMMemberInfoIntSetup."Request Return Info"));
                        Parameters.Add('DataCollectionStep', Format(Enum::"NPR Data Collect Step"::EMail));
                        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
                        _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT DataCollect TaskStatus"::EmailResponseInitiated.AsInteger());
                        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::GENERIC_DATA_COLLECTION, Parameters, 1000 * 60 * 5);

                        Response.Add('taskId', TaskId);
                        Response.Add('done', false);
                    end;
                else begin
                    if (not EFTTransactionRequest."Self Service") then begin
                        if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
                            Message(ResultMessageOut);
                        end;
                    end;

                    _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::ResultReceived.AsInteger());

                    Response.Add('done', false);
                    Response.Add('success', true);
                end;
            end;
        end else begin
            if (not EFTTransactionRequest."Self Service") then begin
                if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
                    Message(ResultMessageOut);
                end;
            end;

            _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::ResultReceived.AsInteger());

            Response.Add('done', true);
            Response.Add('success', false);
        end;

        exit(Response);
    end;

    local procedure ProcessAcquireEMailRequest(EntryNo: Integer): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        POSActionDataCollectionB: Codeunit "NPR POS Action DataCollectionB";
        ResultMessageOut: Text;
        ContinueOnEntryNo: Integer;
        Response: JsonObject;
    begin
        if not ProcessResponse(EntryNo) then
            exit;

        EFTTransactionRequest.Get(EntryNo);
        if EFTTransactionRequest."Result Code" = -10 then begin
            // Previous Trx is still in progress on terminal. Fire off abort in background to help it back to idle while processing this failure.
            TryAbortMostRecentTrx(EFTTransactionRequest);
        end;
        if POSActionDataCollectionB.ContinueAfterDataCollectionVerification(EntryNo, ContinueOnEntryNo) then begin
            if (not EFTTransactionRequest."Self Service") then begin
                if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
                    Message(ResultMessageOut);
                end;
            end;

            _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::ResultReceived.AsInteger());

            Response.Add('done', false);
            Response.Add('success', true);
        end
        else begin
            if (not EFTTransactionRequest."Self Service") then begin
                if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
                    Message(ResultMessageOut);
                end;
            end;

            _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::ResultReceived.AsInteger());

            Response.Add('done', true);
            Response.Add('success', false);
        end;
        exit(Response);
    end;

    local procedure ProcessResponse(EntryNo: Integer): Boolean
    var
        POSActionDataCollectionB: Codeunit "NPR POS Action DataCollectionB";
        ResponseList: List of [Text];
        Completed: Boolean;
        Started: Boolean;
    begin
        if not _trxResponse.Get(EntryNo, ResponseList) then
            exit(false);

        Evaluate(Completed, ResponseList.Get(2));
        Evaluate(Started, ResponseList.Get(3));
        POSActionDataCollectionB.ProcessResponse(EntryNo, ResponseList.Get(1), Completed, Started, ResponseList.Get(4));
        Commit();
        exit(true);
    end;

    local procedure TryAbortMostRecentTrx(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
        EntryNoToAbort: Integer;
    begin
        if not EFTAdyenAbortMgmt.CanAbortLastUnfinishedTrx(EFTTransactionRequest, EntryNoToAbort) then
            exit;

        RequestTrxAbort(EntryNoToAbort);
    end;

    local procedure SignatureApprove(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        POSActionDataCollectionB: Codeunit "NPR POS Action DataCollectionB";
        InformationContextParameterValue: Text;
        InformationContext: Text[250];
        EntryNo: Integer;
        Response: JsonObject;
    begin
        EntryNo := Context.GetInteger('EntryNo');
        if Context.GetStringParameter('informationContext', InformationContextParameterValue) then
            InformationContext := CopyStr(InformationContextParameterValue, 1, MaxStrLen(InformationContext));
        POSActionDataCollectionB.PopualteDataAfterSignatureApprove(EntryNo, Enum::"NPR POS Costumer Input Context"::RETURN_INFORMATION, _trxStatus, InformationContext);
        Response.Add('done', true);
        Response.Add('success', true);
        exit(Response);
    end;

    local procedure SignatureDecline(EntryNo: Integer): JsonObject
    var
        Response: JsonObject;
        DataDeclinedLbl: Label 'Collected data declined, please try again.';
    begin
        RequestTrxAbort(EntryNo);

        _trxStatus.Set(EntryNo, Enum::"NPR EFT DataCollect TaskStatus"::ResultReceived.AsInteger());
        Message(DataDeclinedLbl);

        Response.Add('done', true);
        Response.Add('success', false);

        exit(Response);
    end;

    local procedure ProcessResult(EntryNo: Integer): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AuxEFTTransactionRequest: Record "NPR EFT Transaction Request";
        ReturnInfoCollectSetup: Record "NPR Return Info Collect Setup";
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        POSSession: Codeunit "NPR POS Session";
        EFTAdyenSignatureBuffer: Codeunit "NPR EFT Adyen Signature Buffer";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        SignatureEntryNo: Integer;
        EFTTransactionNo: Integer;
        SignatureJson: Text;
        ResultMessageOut: Text;
        PhoneNoData: Text;
        EMailData: Text;
        DataVerificationRequired: Boolean;
        ShowEMail: Boolean;
        ShowPhoneNo: Boolean;
        Response: JsonObject;
    begin
        if not ProcessResponse(EntryNo) then
            exit;

        EFTTransactionRequest.Get(EntryNo);
        ReturnInfoCollectSetup.Get();
        if ReturnInfoCollectSetup."Collect Signature" or ReturnInfoCollectSetup."Collect Phone No." or ReturnInfoCollectSetup."Collect E-Mail" then
            DataVerificationRequired := true;

        Commit();

        if (not EftTransactionRequest.Successful) then begin
            if EFTTransactionRequest."Result Code" = -10 then begin
                // Previous Trx is still in progress on terminal. Fire off abort in background to help it back to idle while processing this failure.
                TryAbortMostRecentTrx(EFTTransactionRequest);
            end;
        end;

        if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then
            Message(ResultMessageOut);

        // Needed because POS lines could have been updated in the background task continuation
        // so the delta calculation on user session does not work as it happened outside the action.
        POSSession.RequestFullRefresh();

        Response.Add('dataVerificationRequired', DataVerificationRequired);

        foreach EFTTransactionNo in _trxStatus.Keys do begin
            if EFTTransactionNo <> 0 then begin
                AuxEFTTransactionRequest.Get(EFTTransactionNo);
                case AuxEFTTransactionRequest."Auxiliary Operation ID" of
                    Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger():
                        PhoneNoData := AuxEFTTransactionRequest."Result Description";
                    Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger():
                        EMailData := AuxEFTTransactionRequest."Result Description";
                end;
            end;
        end;

        ShowPhoneNo := ReturnInfoCollectSetup."Collect Phone No.";
        ShowEMail := ReturnInfoCollectSetup."Collect E-Mail";
        if SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.") then begin
            if (SalePOS."Customer No." <> '') and Customer.Get(SalePOS."Customer No.") then begin
                ShowPhoneNo := (ReturnInfoCollectSetup."Collect Phone No.") and (Customer."Phone No." = '');
                ShowEMail := (ReturnInfoCollectSetup."Collect E-Mail") and (Customer."E-Mail" = '');
            end;
        end;

        EFTAdyenSignatureBuffer.GetSignatureData(SignatureJson, SignatureEntryNo);
        Response.Add('showSignature', ReturnInfoCollectSetup."Collect Signature");
        Response.Add('showPhoneNo', ShowPhoneNo);
        Response.Add('showEmail', ShowEMail);
        Response.Add('signatureType', 'Bitmap');
        Response.Add('signatureBitmap', SignatureJson);
        Response.Add('phoneNoData', PhoneNoData);
        Response.Add('emailData', EMailData);

        Response.Add('done', true);
        Response.Add('success', EFTTransactionRequest.Successful);
        exit(Response);
    end;

    local procedure RequestTrxAbort(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        ReturnInfoCollectSetup: Record "NPR Return Info Collect Setup";
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        TaskId: Integer;
        AbortReqEntryNo: Integer;
        AbortTaskActive: Boolean;
        Parameters: Dictionary of [Text, Text];
    begin
        if _trxAbortStatus.Get(EntryNo, AbortTaskActive) then begin
            if AbortTaskActive then begin
                exit; //Only start at most 1 task for attempting to abort trx. When task is done it will reset this boolean.
            end;
        end;
        _trxAbortStatus.Set(EntryNo, true);

        EFTTransactionRequest.Get(EntryNo);

        EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EFTTransactionRequest."Entry No.", 'Requesting abort of transaction', '');
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        AbortReqEntryNo := EFTAdyenAbortMgmt.CreateAbortDataCollectionTransactionRequest(EFTTransactionRequest);
        AbortEFTTransactionRequest.Get(AbortReqEntryNo);
        ReturnInfoCollectSetup.Get();
        if ReturnInfoCollectSetup.Environment = ReturnInfoCollectSetup.Environment::Live then
            AbortEFTTransactionRequest.Mode := AbortEFTTransactionRequest.Mode::Production
        else
            AbortEFTTransactionRequest.Mode := AbortEFTTransactionRequest.Mode::"TEST Remote";
        AbortEFTTransactionRequest.Modify();
        Parameters.Add('EntryNo', Format(AbortReqEntryNo));
        Parameters.Add('CalledFromActionWF', 'DATA_COLLECTION');
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_ABORT, Parameters, 1000 * 10);
    end;

    local procedure CollectInsertedSignature(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        DataCollectionBuffer: Record "NPR Data Collection Buffer";
        SignatureText: Text;
        InformationContextParameter: Text[250];
        LineNo: Integer;
        Found: Boolean;
        SignaturePoints: JsonObject;
        SignatureToken: JsonToken;
    begin
        if not Context.GetJsonObject('signaturePoints', SignaturePoints) then
            exit;
        if not SignaturePoints.Get('signature', SignatureToken) then
            exit;
        InformationContextParameter := CopyStr(Context.GetStringParameter('informationContext'), 1, MaxStrLen(InformationContextParameter));

        SignatureToken.WriteTo(SignatureText);

        Sale.GetCurrentSale(SalePOS);

        DataCollectionBuffer.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if DataCollectionBuffer.FindLast() then
            LineNo := DataCollectionBuffer."Line No." + 10000;
        DataCollectionBuffer.Reset();

        DataCollectionBuffer.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        DataCollectionBuffer.SetRange("Information Context", InformationContextParameter);
        Found := DataCollectionBuffer.FindFirst();
        if not Found then begin
            DataCollectionBuffer.Init();
            DataCollectionBuffer."Line No." := LineNo;
            DataCollectionBuffer."Sales Ticket No." := SalePOS."Sales Ticket No.";
            DataCollectionBuffer.Context := DataCollectionBuffer.Context::"ACQUIRE_SIGNATURE";
            DataCollectionBuffer.WriteSignatureData(SignatureText);
            DataCollectionBuffer."Information Context" := InformationContextParameter;
            DataCollectionBuffer.Insert();
        end else begin
            DataCollectionBuffer.CalcFields("Signature Data");
            Clear(DataCollectionBuffer."Signature Data");
            DataCollectionBuffer.WriteSignatureData(SignatureText);
            DataCollectionBuffer.Modify();
        end;
    end;

    local procedure ClearGlobalState()
    begin
        clear(_trxStatus);
        clear(_trxAbortStatus);
    end;

    internal procedure SetTrxStatus(EntryNo: Integer; StatusIn: Enum "NPR EFT DataCollect TaskStatus")
    begin
        _trxStatus.Set(EntryNo, StatusIn.AsInteger());
    end;

    internal procedure SetTrxResponse(EntryNo: Integer; Response: Text; Completed: Boolean; Started: Boolean; ErrorText: Text)
    var
        ResponseList: List of [Text];
    begin
        ResponseList.Add(Response);
        ResponseList.Add(Format(Completed));
        ResponseList.Add(Format(Started));
        ResponseList.Add(ErrorText);
        _trxResponse.Set(EntryNo, ResponseList);
    end;

    procedure SetAbortStatus(EntryNo: Integer; StatusIn: Boolean)
    begin
        _trxAbortStatus.Set(EntryNo, StatusIn);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDataCollection.js###
'let main=async({workflow:a,context:i,popup:n,captions:s,parameters:r})=>{debugger;switch(r.requestCollectInformation.toInt()){case r.requestCollectInformation.ReturnInformation:let t=await n.simplePayment({title:s.dataCollectionTitle,abortEnabled:!0,amount:" ",amountStyle:{fontSize:"0px"},initialStatus:s.initialStatus,showStatus:!0,onAbort:async()=>{await a.respond("requestAbort")}});try{let u=await a.respond("collectData");u.newEntryNo&&(i.EntryNo=u.newEntryNo),t&&t.updateStatus(s.collectingDataStatus),t&&t.enableAbort(!0),await trxPromise(i,n,a)}finally{t&&t.close()}return{success:i.success,tryEndSale:i.success};case r.requestCollectInformation.AcquireSignature:const e=await n.inputSignature({title:"Insert Signature"});e!==null&&await a.respond("collectSignature",{signaturePoints:e})}};function trxPromise(a,i,n){return new Promise((s,r)=>{let t=async()=>{try{debugger;let e=await n.respond("poll");if(e.newEntryNo){a.EntryNo=e.newEntryNo,setTimeout(t,1e3);return}if(e.dataVerificationRequired){debugger;let u=!1,l=JSON.parse(e.signatureBitmap||"{}"),o=await i.signatureValidation();if(setTimeout(()=>{o.updateSignature(l,{phoneNoData:e.phoneNoData,emailData:e.emailData,showSignature:e.showSignature,showPhoneNo:e.showPhoneNo,showEmail:e.showEmail})},1e3),u=await o.completeAsync(),u)await n.respond("signatureApprove");else{let c=await n.respond("signatureDecline");a.success=c.success,s();return}}if(e.done){debugger;a.success=e.success,s();return}}catch(e){debugger;try{await n.respond("requestAbort")}catch{}r(e);return}setTimeout(t,1e3)};setTimeout(t,1e3)})}'
        );
    end;
}
