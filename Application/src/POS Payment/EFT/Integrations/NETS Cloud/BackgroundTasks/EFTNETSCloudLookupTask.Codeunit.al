codeunit 6059892 "NPR EFT NETS Cloud Lookup Task" implements "NPR POS Background Task"
{
    Access = Internal;
    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        Completed: Boolean;
        APIToken: Text;
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        EntryNo: Integer;
        Logs: Text;
        EFTNETSCloudRespParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        Sleep(5 * 1000); //Magic sleep - if we lookup too quickly after a lost trx result we do not retrieve it..

        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        APIToken := Parameters.Get('APIToken');
        EFTNETSCloudToken.SetToken(APIToken);

        ClearLastError();
        Completed := EFTNETSCloudProtocol.InvokeLookupLastTransaction(EftTransactionRequest, EFTSetup, EftTransactionRequest, 1000 * 60, APIToken, Response);
        Logs := EFTNETSCloudProtocol.GetLogBuffer();

        if Completed then begin
            Completed := EFTNETSCloudRespParser.IsLookupResponseRelatedToTransaction(Response, EFTTransactionRequest);
        end;

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
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Error: Text;
        ErrorCallstack: Text;
        Completed: Boolean;
        EntryNo: Integer;
        Logs: Text;
        Response: Text;
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
    begin
        //check if orderId matches or lookup is for older trx.
        //trigger endPayment function with success if lookup had a match. Otherwise trigger endPayment function with error.

        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        Evaluate(Completed, Results.Get('Completed'), 9);

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'LookupTaskDone (Complete)', Logs);
            Commit();
            EFTNETSCloudProtocol.ProcessAsyncResponse(EntryNo, true, Response, '');
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'LookupTaskDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            Commit();
            EFTNETSCloudProtocol.ProcessAsyncResponse(EFTTransactionRequest."Entry No.", false, '', '');
        end;

        POSActionNetsCloudTrx.SetTrxStatus(EntryNo, Enum::"NPR EFT NETSCloud Trx Status"::ResponseReceived);
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'LookupTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        Commit();
        EFTNETSCloudProtocol.ProcessAsyncResponse(EFTTransactionRequest."Entry No.", false, '', ErrorText);
        POSActionNetsCloudTrx.SetTrxStatus(EntryNo, Enum::"NPR EFT NETSCloud Trx Status"::ResponseReceived);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNo: Integer;
        POSActionNetsCloudTrx: Codeunit "NPR POS Action: NetsCloud Trx";
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        EFTTransactionRequest.Get(EntryNo);
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'LookupTaskTimeout', '');
        Commit();
        EFTNETSCloudProtocol.ProcessAsyncResponse(EFTTransactionRequest."Entry No.", false, '', 'Lookup Task Timeout');
        POSActionNetsCloudTrx.SetTrxStatus(EntryNo, Enum::"NPR EFT NETSCloud Trx Status"::ResponseReceived);
    end;
}