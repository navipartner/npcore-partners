codeunit 6184642 "NPR EFT Adyen Setup Check Task" implements "NPR POS Background Task"
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
        EFTAdyenDiagnoseReq: Codeunit "NPR EFT Adyen Diagnose Req";
        EFTSetup: Record "NPR EFT Setup";
        URL: Text;
        Completed: Boolean;
        Logs: Text;
        StatusCode: Integer;
        Started: Boolean;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        Request := EFTAdyenDiagnoseReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 10, Response, StatusCode);
        Started := StatusCode in [0, 200]; //if we got 403 or other 4xx transaction didn't even start 
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
        Response: Text;
        Error: Text;
        ErrorCallstack: Text;
        EntryNo: Integer;
        Logs: Text;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx done, either complete (success/failure) or handled error 
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        Evaluate(Completed, Results.Get('Completed'), 9);

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'SetupTaskDone (Complete)', Logs);
            Commit();
            POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", Response, true, true, '');
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'SetupTaskDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", Response, false, false, '');
        end;

        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::ResultReceived);
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'SetupTaskError', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", '', false, false, StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::ResultReceived);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'SetupTaskError', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", '', false, false, '');
        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::ResultReceived);
    end;
}