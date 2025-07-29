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
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
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

        if FeatureFlagsManagement.IsEnabled('refreshcacheadyenaborttrx') then
            SelectLatestVersion();

        EFTTransactionRequest.Get(EntryNo);
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
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        //Trx done, either complete (success/failure) or handled error 
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        if FeatureFlagsManagement.IsEnabled('refreshcacheadyenaborttrx') then
            SelectLatestVersion();

        EFTTransactionRequest.Get(EntryNo);
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
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        if FeatureFlagsManagement.IsEnabled('refreshcacheadyenaborttrx') then
            SelectLatestVersion();

        EFTTransactionRequest.Get(EntryNo);
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
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        CalledFromActionWF: Text;
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        if FeatureFlagsManagement.IsEnabled('refreshcacheadyenaborttrx') then
            SelectLatestVersion();

        EFTTransactionRequest.Get(EntryNo);
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
}