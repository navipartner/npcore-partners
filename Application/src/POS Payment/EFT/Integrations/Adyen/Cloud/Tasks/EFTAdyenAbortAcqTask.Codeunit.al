codeunit 6184616 "NPR EFT Adyen Abort Acq. Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: Text;
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        Request: Text;
        EFTSetup: Record "NPR EFT Setup";
        URL: Text;
        Completed: Boolean;
        Logs: Text;
        StatusCode: Integer;
        ProcessedTransactionAuxiliaryOperationID: Integer;
        EFTAdyenAbortAcquireReq: Codeunit "NPR EFT Adyen AbortAcquire Req";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
            Evaluate(EFTTransactionRequest."Processed Entry No.", Parameters.Get('ProcessedEntryNo'));
            EFTTransactionRequest."Reference Number Input" := CopyStr(Parameters.Get('ReferenceNumberInput'), 1, MaxStrLen(EFTTransactionRequest."Reference Number Input"));
            EFTTransactionRequest."Hardware ID" := CopyStr(Parameters.Get('HardwareID'), 1, MaxStrLen(EFTTransactionRequest."Hardware ID"));
            EFTTransactionRequest."Integration Version Code" := CopyStr(Parameters.Get('IntegrationVersionCode'), 1, MaxStrLen(EFTTransactionRequest."Integration Version Code"));
            Evaluate(EFTTransactionRequest.Mode, Parameters.Get('Mode'));
            Evaluate(ProcessedTransactionAuxiliaryOperationID, Parameters.Get('ProcessedTransactionAuxiliaryOperationID'));
        end else
            EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then
            Request := EFTAdyenAbortAcquireReq.GetRequestJson(EFTTransactionRequest, EFTSetup, ProcessedTransactionAuxiliaryOperationID)
        else
            Request := EFTAdyenAbortAcquireReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 60 * 5, Response, StatusCode);
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
        EntryNo: Integer;
        Logs: Text;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
            Evaluate(EFTTransactionRequest."Processed Entry No.", Parameters.Get('ProcessedEntryNo'));
        end else
            EFTTransactionRequest.Get(EntryNo);
        Evaluate(Completed, Results.Get('Completed'), 9);
        Logs := Results.Get('Logs');

        if Completed then begin
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortAcqTask (Done)', Logs);
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortAcqTask (Error)', StrSubstNo('Error: %1 \\Callstack: %2 \\%3', Error, ErrorCallStack, Logs));
        end;

        POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', true, false, '');
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
            Evaluate(EFTTransactionRequest."Processed Entry No.", Parameters.Get('ProcessedEntryNo'));
        end else
            EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortAcqTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', false, false, '');
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
            Evaluate(EFTTransactionRequest."Processed Entry No.", Parameters.Get('ProcessedEntryNo'));
        end else
            EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortAcqTaskCancelled', '');
        POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', false, false, '');
    end;
}