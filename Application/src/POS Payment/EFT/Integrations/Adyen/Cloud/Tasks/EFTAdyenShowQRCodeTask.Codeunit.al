codeunit 6151112 "NPR EFT Adyen Show QRCode Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        QRCodeSetupHeader: Record "NPR QR Code Setup Header";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        AdyenQRCodeShowReq: Codeunit "NPR Adyen QRCode Show Req.";
        StatusCode: Integer;
        MinimumDisplayTimeSec: Integer;
        Response: Text;
        Request: Text;
        URL: Text;
        Logs: Text;
        QRCodeLink: Text;
        Completed: Boolean;
        Started: Boolean;
    begin
        QRCodeLink := Parameters.Get('qrCodeLink');
        Evaluate(MinimumDisplayTimeSec, Parameters.Get('minimumDisplayTimeSec'));
        QRCodeSetupHeader.Get(Parameters.Get('QRCodeSetupCode'));

        PopulateEFTTransactionRequestFromParameters(EFTTransactionRequest, Parameters);

        Request := AdyenQRCodeShowReq.GetRequestJson(EFTTransactionRequest, QRCodeLink, MinimumDisplayTimeSec);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, QRCodeSetupHeader.GetApiKey(), URL, 1000 * 60 * 5, Response, StatusCode);
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
        EntryNo: Integer;
        Completed: Boolean;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        Evaluate(Completed, Results.Get('Completed'), 9);
        MarkRequestCompleted(EntryNo, Completed);
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EntryNo: Integer;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        MarkRequestCompleted(EntryNo, false);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
    begin
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        MarkRequestCompleted(EntryNo, false);
    end;

    local procedure MarkRequestCompleted(EntryNo: Integer; Succeeded: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if EFTTransactionRequest.Get(EntryNo) then begin
            EFTTransactionRequest.Successful := Succeeded;
            EFTTransactionRequest."External Result Known" := true;
            EFTTransactionRequest."Result Processed" := true;
            EFTTransactionRequest.Finished := CurrentDateTime;
            EFTTransactionRequest."Confirmed Flag" := true;
            EFTTransactionRequest.Modify();
            Commit();
        end;
    end;

    local procedure PopulateEFTTransactionRequestFromParameters(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; Parameters: Dictionary of [Text, Text])
    begin
        Evaluate(EFTTransactionRequest."Entry No.", Parameters.Get('EntryNo'));
        EFTTransactionRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(EFTTransactionRequest."Register No."));
        EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
        EFTTransactionRequest."Reference Number Input" := CopyStr(Parameters.Get('ReferenceNumberInput'), 1, MaxStrLen(EFTTransactionRequest."Reference Number Input"));
        EFTTransactionRequest."Hardware ID" := CopyStr(Parameters.Get('HardwareID'), 1, MaxStrLen(EFTTransactionRequest."Hardware ID"));
        Evaluate(EFTTransactionRequest.Mode, Parameters.Get('Mode'));
    end;
}
