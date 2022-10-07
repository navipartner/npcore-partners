codeunit 6059893 "NPR EFT NETS Cloud Trx Task" implements "NPR POS Background Task"
{
    Access = Internal;
    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        Completed: Boolean;
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        APIToken: Text;
        EntryNo: Integer;
        Logs: Text;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        APIToken := Parameters.Get('APIToken');
        EFTNETSCloudToken.SetToken(APIToken);

        ClearLastError();
        Completed := EFTNETSCloudProtocol.InvokeTransaction(EFTTransactionRequest, EFTSetup, APIToken, Response);
        Logs := EFTNETSCloudProtocol.GetLogBuffer();

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
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Completed: Boolean;
        Response: Text;
        Error: Text;
        ErrorCallstack: Text;
        EntryNo: Integer;
        Logs: Text;
    begin
        //Trx done, either complete (success/failure) or handled error 
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        Evaluate(Completed, Results.Get('Completed'), 9);

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'TrxTaskDone (Complete)', Logs);
            Commit();
            EFTNETSCloudProtocol.ProcessAsyncResponse(EFTTransactionRequest."Entry No.", true, Response, '');
            POSActionNetsCloudTrx.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT NETSCloud Trx Status"::ResponseReceived);
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'TrxTaskDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionNetsCloudTrx.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT NETSCloud Trx Status"::LookupNeeded);
        end;
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EntryNo: Integer;
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'TrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        POSActionNetsCloudTrx.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT NETSCloud Trx Status"::LookupNeeded);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EntryNo: Integer;
    begin
        //Trx result unknown - log error and start lookup        
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'TrxTaskCancelled', '');
        POSActionNetsCloudTrx.SetTrxStatus(EFTTransactionRequest."Entry No.", Enum::"NPR EFT NETSCloud Trx Status"::LookupNeeded);
    end;
}