codeunit 6184615 "NPR EFT Adyen Abort Trx Task" implements "NPR POS Background Task"
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
        EFTAdyenAbortTrxReq: Codeunit "NPR EFT Adyen AbortTrx Req";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        Request := EFTAdyenAbortTrxReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
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
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
    begin
        //Trx done, either complete (success/failure) or handled error 
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        Evaluate(Completed, Results.Get('Completed'), 9);
        Logs := Results.Get('Logs');

        if Completed then begin
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTask (Done)', Logs);
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTask (Error)', StrSubstNo('Error: %1 \\Callstack: %2 \\%3', Error, ErrorCallStack, Logs));
        end;

        POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', true, false, '');
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
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
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTaskCancelled', '');
        POSActionEFTAdyenCloud.SetAbortStatus(EFTTransactionRequest."Processed Entry No.", false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', false, false, '');
    end;
}