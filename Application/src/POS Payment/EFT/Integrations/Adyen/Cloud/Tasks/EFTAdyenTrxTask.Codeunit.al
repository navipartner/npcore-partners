codeunit 6184588 "NPR EFT Adyen Trx Task" implements "NPR POS Background Task"
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
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTSetup: Record "NPR EFT Setup";
        URL: Text;
        Completed: Boolean;
        Logs: Text;
        StatusCode: Integer;
        Started: Boolean;
        OriginalRecovered: Boolean;
        EFTAdyenVoidReq: Codeunit "NPR EFT Adyen Void Req";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
            EFTTransactionRequest."Integration Version Code" := CopyStr(Parameters.Get('IntegrationVersionCode'), 1, MaxStrLen(EFTTransactionRequest."Integration Version Code"));
            EFTTransactionRequest."Reference Number Input" := CopyStr(Parameters.Get('ReferenceNumberInput'), 1, MaxStrLen(EFTTransactionRequest."Reference Number Input"));
            EFTTransactionRequest."Hardware ID" := CopyStr(Parameters.Get('HardwareID'), 1, MaxStrLen(EFTTransactionRequest."Hardware ID"));
            Evaluate(EFTTransactionRequest.Mode, Parameters.Get('Mode'));
            EFTTransactionRequest."Sales Ticket No." := CopyStr(Parameters.Get('SalesTicketNo'), 1, MaxStrLen(EFTTransactionRequest."Sales Ticket No."));
            EFTTransactionRequest."Currency Code" := CopyStr(Parameters.Get('CurrencyCode'), 1, MaxStrLen(EFTTransactionRequest."Currency Code"));
            Evaluate(EFTTransactionRequest."Amount Input", Parameters.Get('AmountInput'), 9);
            Evaluate(EFTTransactionRequest."Cashback Amount", Parameters.Get('CashbackAmount'), 9);
            Evaluate(EFTTransactionRequest."Processing Type", Parameters.Get('ProcessingType'));
            EFTTransactionRequest."Internal Customer ID" := CopyStr(Parameters.Get('InternalCustomerID'), 1, MaxStrLen(EFTTransactionRequest."Internal Customer ID"));
            Evaluate(EFTTransactionRequest."Manual Capture", Parameters.Get('ManualCapture'));
            EFTTransactionRequest.Token := CopyStr(Parameters.Get('Token'), 1, MaxStrLen(EFTTransactionRequest.Token));
            Evaluate(EFTTransactionRequest."Processed Entry No.", Parameters.Get('ProcessedEntryNo'));
            Evaluate(EFTTransactionRequest.Recovered, Parameters.Get('Recovered'));
            Evaluate(EFTTransactionRequest.Started, Parameters.Get('Started'), 9);
        end else
            EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND:
                Request := EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup);
            EFTTransactionRequest."Processing Type"::VOID:
                if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
                    Evaluate(OriginalRecovered, Parameters.Get('OriginalRecovered'));
                    Request := EFTAdyenVoidReq.GetRequestJson(EFTTransactionRequest, EFTSetup, OriginalRecovered, Parameters.Get('OriginalRefNumberOutput'), Parameters.Get('LookupRefNumberOutput'));
                end else
                    Request := EFTAdyenVoidReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
            else
                Error('Unsupported operation');
        end;

        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        Sentry.StartSpan(Span, 'bc.pos.adyen.cloud.http_request');
        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 60 * 5, Response, StatusCode);
        Span.Finish();
        Started := StatusCode in [0, 200]; //if we got 403 or other 4xx, transaction didn't even start 
        Logs := EFTAdyenCloudProtocol.GetLogBuffer();

        Result.Add('Started', Format(Started, 0, 9));
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
        Started: Boolean;
        Response: Text;
        Error: Text;
        ErrorCallstack: Text;
        EntryNo: Integer;
        Logs: Text;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        //Trx done, either complete (success/failure) or handled error
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
        end else
            EFTTransactionRequest.Get(EntryNo);
        Evaluate(Completed, Results.Get('Completed'), 9);
        Evaluate(Started, Results.Get('Started'), 9);

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TrxTaskDone (Complete)', Logs);
            Commit();
            POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", Response, true, true, '');
            POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::ResultReceived);
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TrxTaskDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            if Started then begin
                POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::LookupNeeded);
            end else begin
                //A not-started request ends without lookup on failure as no transaction was even started yet.                
                POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", Response, false, false, StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
                POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::ResultReceived);
            end;
        end;
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
        end else
            EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::LookupNeeded);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if FeatureFlagsManagement.IsEnabled('adyenBackgroundTaskOptimization') then begin
            EFTTransactionRequest."Entry No." := EntryNo;
            EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
            EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
        end else
            EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'TrxTaskError', '');
        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::LookupNeeded);
    end;
}