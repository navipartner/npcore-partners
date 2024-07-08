codeunit 6059907 "NPR EFT NETS Cloud Abort Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        Completed: Boolean;
        APIToken: Text;
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        Response: Text;
        EntryNo: Integer;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        APIToken := Parameters.Get('APIToken');
        EFTNETSCloudToken.SetToken(APIToken);
        Completed := EFTNETSCloudProtocol.InvokeCancelAction(EFTTransactionRequest, APIToken, Response);

        Result.Add('Completed', Format(Completed, 0, 9));
        Result.Add('Response', Response);
        if not (Completed) then begin
            Result.Add('Error', GetLastErrorText());
            Result.Add('ErrorCallstack', GetLastErrorCallStack());
        end;
    end;

    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Results: Dictionary of [Text, Text]);
    var
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        Completed: Boolean;
        Error: Text;
        ErrorCallstack: Text;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        Evaluate(Completed, Results.Get('Completed'), 9);
        EFTTransactionRequest.Get(EntryNo);

        if Completed then begin
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'AbortTrxTaskDone (Complete)', '');
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'AbortTrxTaskDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
        end;

        POSActionNetsCloudTrx.SetAbortStatus(EntryNo, false);
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);

        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'AbortTrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));

        POSActionNetsCloudTrx.SetAbortStatus(EntryNo, false);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);

        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'AbortTrxTaskTimeout', 'AbortTrxTask timed out');

        POSActionNetsCloudTrx.SetAbortStatus(EntryNo, false);
    end;
}