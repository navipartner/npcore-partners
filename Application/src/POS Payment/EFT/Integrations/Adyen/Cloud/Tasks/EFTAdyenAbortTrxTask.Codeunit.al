codeunit 6184615 "NPR EFT Adyen Abort Trx Task" implements "NPR POS Background Task"
{
    Access = Internal;

    var
        DataCollectionLbl: Label 'DATA_COLLECTION', Locked = true;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: Text;
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        Request: Text;
        EFTSetup: Record "NPR EFT Setup";
        ApiKey: Text;
        URL: Text;
        Completed: Boolean;
        Logs: Text;
        CalledFromActionWF: Text;
        StatusCode: Integer;
        EFTAdyenAbortTrxReq: Codeunit "NPR EFT Adyen AbortTrx Req";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        GetEftTransactionRequestAndLogError(EntryNo, 20, 100, 'ExecuteBackgroundTask', EFTTransactionRequest);

        if CalledFromActionWF <> DataCollectionLbl then
            EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        Request := EFTAdyenAbortTrxReq.GetRequestJson(EFTTransactionRequest);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        if CalledFromActionWF = DataCollectionLbl then
            ApiKey := EFTAdyenCloudIntegrat.GetAPIKeyFromReturnCollectionSetup()
        else
            ApiKey := EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, ApiKey, URL, 1000 * 60 * 5, Response, StatusCode);
        Logs := EFTAdyenCloudProtocol.GetLogBuffer();

        Result.Add('Completed', Format(Completed, 0, 9));
        Result.Add('Response', Response);
        Result.Add('Logs', Logs);
        if not (Completed) then begin
            Result.Add('Error', GetLastErrorText());
            Result.Add('ErrorCallstack', GetLastErrorCallStack());
        end;
    end;

    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Results: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Completed: Boolean;
        Error: Text;
        ErrorCallstack: Text;
        CalledFromActionWF: Text;
        EntryNo: Integer;
        Logs: Text;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
    begin
        //Trx done, either complete (success/failure) or handled error 
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        GetEftTransactionRequestAndLogError(EntryNo, 20, 100, 'BackgroundTaskSuccessContinuation', EFTTransactionRequest);

        Evaluate(Completed, Results.Get('Completed'), 9);
        Logs := Results.Get('Logs');

        if Completed then
            if CalledFromActionWF = DataCollectionLbl then
                EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EFTTransactionRequest."Entry No.", 'AbortTrxTask (Done)', Logs)
            else
                EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTask (Done)', Logs)
        else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            if CalledFromActionWF = DataCollectionLbl then
                EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EFTTransactionRequest."Entry No.", 'AbortTrxTask (Error)', StrSubstNo('Error: %1 \\Callstack: %2 \\%3', Error, ErrorCallStack, Logs))
            else
                EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTask (Error)', StrSubstNo('Error: %1 \\Callstack: %2 \\%3', Error, ErrorCallStack, Logs));
        end;

        if CalledFromActionWF = DataCollectionLbl then
            POSActionDataCollection.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false)
        else
            POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', true, false, '');
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        CalledFromActionWF: Text;
        EntryNo: Integer;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        GetEftTransactionRequestAndLogError(EntryNo, 20, 100, 'BackgroundTaskErrorContinuation', EFTTransactionRequest);

        if CalledFromActionWF = DataCollectionLbl then
            EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EFTTransactionRequest."Entry No.", 'AbortTrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack))
        else
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        if CalledFromActionWF = DataCollectionLbl then
            POSActionDataCollection.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false)
        else
            POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', false, false, '');
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        CalledFromActionWF: Text;
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        GetEftTransactionRequestAndLogError(EntryNo, 20, 100, 'BackgroundTaskCancelled', EFTTransactionRequest);

        if CalledFromActionWF = DataCollectionLbl then
            EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EFTTransactionRequest."Entry No.", 'AbortTrxTaskCancelled', '')
        else
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTaskCancelled', '');
        if CalledFromActionWF = DataCollectionLbl then
            POSActionDataCollection.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false)
        else
            POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', false, false, '');
    end;

    //When read scale out is configured in the database
    //the record is not always immediately available in the read only replica database
    //so you need to retry some time to get the record 
    local procedure GetEftTransactionRequest(EntryNo: Integer; MaxRetryCount: Integer; SleepDuration: Integer; var EFTTransactionRequest: Record "NPR EFT Transaction Request") Found: Boolean;
    var
        RetryCount: Integer;
        EndLoop: Boolean;
        CurrentSleepDuration: Integer;
    begin
        repeat
            Clear(EFTTransactionRequest);
            SelectLatestVersion();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
            EFTTransactionRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
#ENDIF
            Found := EFTTransactionRequest.Get(EntryNo);
            RetryCount += 1;
            EndLoop := Found or (RetryCount >= MaxRetryCount);

            if not Found and not EndLoop and (SleepDuration <> 0) then begin
                CurrentSleepDuration := SleepDuration * Power(2, RetryCount - 1);
                if CurrentSleepDuration > 2000 then
                    CurrentSleepDuration := 2000;
                Sleep(CurrentSleepDuration);
            end;
        until EndLoop;
    end;

    local procedure GetEftTransactionRequestAndLogError(EntryNo: Integer; MaxRetryCount: Integer; SleepDuration: Integer; FunctionName: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        StartTime: Time;
        EndTime: Time;
        Duration: Decimal;
        ErrorMessageText: Text;
        NotFoundEftTransactionRequestErrorLbl: Label 'EFT Transaction Request with entry no. %1 was not found.', Comment = '%1 - entryNo';
    begin
        StartTime := Time;

        if GetEftTransactionRequest(EntryNo, MaxRetryCount, SleepDuration, EFTTransactionRequest) then
            exit;

        EndTime := Time;
        Duration := EndTime - StartTime;
        ErrorMessageText := StrSubstNo(NotFoundEftTransactionRequestErrorLbl, EntryNo);

        EmitTelemetry(FunctionName, Duration, ErrorMessageText);
        Error(NotFoundEftTransactionRequestErrorLbl, EntryNo);
    end;

    local procedure EmitTelemetry(FunctionName: Text; Duration: Duration; ErrorMessageText: Text)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);


        CustomDimensions.Add('NPR_FunctionName', FunctionName);
        CustomDimensions.Add('NPR_DurationMs', Format(Duration, 0, 9));
        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        Session.LogMessage('NPR_AdyenAbortTrx', ErrorMessageText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}