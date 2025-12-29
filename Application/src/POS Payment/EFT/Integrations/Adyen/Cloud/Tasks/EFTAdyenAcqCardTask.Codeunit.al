codeunit 6184614 "NPR EFT Adyen Acq.Card Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
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
        EFTAdyenCardAcquireReq: Codeunit "NPR EFT Adyen CardAcquire Req";
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
        ReferenceNumberInput: Code[20];
        HardwareID: Text[250];
        IntegrationVersionCode: Code[10];
        SalesTicketNo: Code[20];
        AuxiliaryOperationID: Integer;
        InitiatedFromEntryNo: Integer;
        AmountInput: Decimal;
        Mode: Option Production,"TEST Local","TEST Remote";
    begin
        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));
        ReferenceNumberInput := CopyStr(Parameters.Get('ReferenceNumberInput'), 1, MaxStrLen(ReferenceNumberInput));
        HardwareID := CopyStr(Parameters.Get('HardwareID'), 1, MaxStrLen(HardwareID));
        IntegrationVersionCode := CopyStr(Parameters.Get('IntegrationVersionCode'), 1, MaxStrLen(IntegrationVersionCode));
        SalesTicketNo := CopyStr(Parameters.Get('SalesTicketNo'), 1, MaxStrLen(SalesTicketNo));
        Evaluate(AuxiliaryOperationID, Parameters.Get('AuxiliaryOperationID'));
        Evaluate(InitiatedFromEntryNo, Parameters.Get('InitiatedFromEntryNo'));
        Evaluate(AmountInput, Parameters.Get('AmountInput'));
        Evaluate(Mode, Parameters.Get('Mode'));

        EFTSetup.FindSetup(RegisterNo, OriginalPOSPaymentTypeCode);

        Request := EFTAdyenCardAcquireReq.GetRequestJson(ReferenceNumberInput, RegisterNo, HardwareID, IntegrationVersionCode, SalesTicketNo, AuxiliaryOperationID, InitiatedFromEntryNo, AmountInput);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(Mode);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 60 * 5, Response, StatusCode);
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
        Completed: Boolean;
        Response: Text;
        Error: Text;
        ErrorCallstack: Text;
        EntryNo: Integer;
        Logs: Text;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
    begin
        //Trx done, either complete (success/failure) or handled error
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));

        Evaluate(Completed, Results.Get('Completed'), 9);

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'TaskAcqCardDone (Complete)', Logs);
            Commit();

            POSActionEFTAdyenCloud.SetTrxResponse(EntryNo, Response, true, true, '');
            POSActionEFTAdyenCloud.SetTrxStatus(EntryNo, Enum::"NPR EFT Adyen Task Status"::AcquireCardResponseReceived);
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'TaskAcqCardDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionEFTAdyenCloud.SetTrxResponse(EntryNo, Response, false, true, StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionEFTAdyenCloud.SetTrxStatus(EntryNo, Enum::"NPR EFT Adyen Task Status"::AcquireCardResponseReceived);
        end;
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));

        EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'TaskAcqCardError', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EntryNo, '', false, true, StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        POSActionEFTAdyenCloud.SetTrxStatus(EntryNo, Enum::"NPR EFT Adyen Task Status"::AcquireCardResponseReceived);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));

        EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'TaskAcqCardCancelled', '');
        POSActionEFTAdyenCloud.SetTrxResponse(EntryNo, '', false, true, StrSubstNo('Error: %1 \\Callstack: %2'));
        POSActionEFTAdyenCloud.SetTrxStatus(EntryNo, Enum::"NPR EFT Adyen Task Status"::AcquireCardResponseReceived);
    end;
}