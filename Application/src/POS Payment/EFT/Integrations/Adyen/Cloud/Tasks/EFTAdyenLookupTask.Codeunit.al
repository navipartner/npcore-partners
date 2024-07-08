codeunit 6184613 "NPR EFT Adyen Lookup Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: Text;
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        Request: Text;
        EFTSetup: Record "NPR EFT Setup";
        URL: Text;
        Completed: Boolean;
        Logs: Text;
        StatusCode: Integer;
        Started: Boolean;
        EFTAdyenLookupReq: Codeunit "NPR EFT Adyen Lookup Req";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        InnerResponse: Text;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.")
        else
            OriginalEFTTransactionRequest := EFTTransactionRequest;

        Request := EFTAdyenLookupReq.GetRequestJson(EFTTransactionRequest, OriginalEFTTransactionRequest, EFTSetup);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 20, Response, StatusCode);
        if Completed then begin
            if (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::LOOK_UP) then begin
                Completed := EFTAdyenResponseParser.IsConclusiveLookupResult(Response, InnerResponse);
                if Completed then
                    Response := InnerResponse;
            end;
        end;

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
        Started: Boolean;
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
        Evaluate(Started, Results.Get('Started'), 9);

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'LookupTaskDone (Complete)', Logs);
            Commit();
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'LookupTaskDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
        end;

        POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", Response, Completed, Started, StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
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
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'LookupTaskError', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", '', false, true, StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
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
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'LookupTaskError', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EFTTransactionRequest."Entry No.", '', false, true, 'Task cancelled');
        POSActionEFTAdyenCloud.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::ResultReceived);
    end;
}