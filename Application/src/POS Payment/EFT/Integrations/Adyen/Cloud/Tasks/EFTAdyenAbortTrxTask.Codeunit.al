codeunit 6184615 "NPR EFT Adyen Abort Trx Task" implements "NPR POS Background Task"
{
    Access = Internal;

    var
        DataCollectionLbl: Label 'DATA_COLLECTION', Locked = true;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        Response: Text;
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        Request: Text;
        EFTSetup: Record "NPR EFT Setup";
        ApiKey: Text;
        URL: Text;
        Completed: Boolean;
        Logs: Text;
        CalledFromActionWF: Text;
        StatusCode: Integer;
        EFTAdyenAbortTrxReq: Codeunit "NPR EFT Adyen AbortTrx Req";
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
        ProcessedEntryNo: Integer;
        ReferenceNumberInput: Code[20];
        HardwareID: Text[250];
        IntegrationVersionCode: Code[10];
        Mode: Option Production,"TEST Local","TEST Remote";
        ProcessingType: Text;
        AuxiliaryOperationID: Integer;
    begin
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));
        Evaluate(ProcessedEntryNo, Parameters.Get('ProcessedEntryNo'));
        ReferenceNumberInput := CopyStr(Parameters.Get('ReferenceNumberInput'), 1, MaxStrLen(ReferenceNumberInput));
        HardwareID := CopyStr(Parameters.Get('HardwareID'), 1, MaxStrLen(HardwareID));
        IntegrationVersionCode := CopyStr(Parameters.Get('IntegrationVersionCode'), 1, MaxStrLen(IntegrationVersionCode));
        Evaluate(Mode, Parameters.Get('Mode'));
        ProcessingType := Parameters.Get('ProcessingType');
        Evaluate(AuxiliaryOperationID, Parameters.Get('AuxiliaryOperationID'));

        if CalledFromActionWF <> DataCollectionLbl then
            EFTSetup.FindSetup(RegisterNo, OriginalPOSPaymentTypeCode);

        Request := EFTAdyenAbortTrxReq.GetRequestJson(ProcessedEntryNo, ReferenceNumberInput, RegisterNo, HardwareID, IntegrationVersionCode, ProcessingType, AuxiliaryOperationID);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(Mode);

        if CalledFromActionWF = DataCollectionLbl then
            ApiKey := EFTAdyenCloudIntegrat.GetAPIKeyFromReturnCollectionSetup()
        else
            ApiKey := EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup);

        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, ApiKey, URL, 1000 * 60 * 5, Response, StatusCode);
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
        Completed: Boolean;
        Error: Text;
        ErrorCallstack: Text;
        CalledFromActionWF: Text;
        EntryNo: Integer;
        Logs: Text;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
        ProcessedEntryNo: Integer;
    begin
        //Trx done, either complete (success/failure) or handled error
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));
        Evaluate(ProcessedEntryNo, Parameters.Get('ProcessedEntryNo'));

        Evaluate(Completed, Results.Get('Completed'), 9);
        Logs := Results.Get('Logs');

        if Completed then
            if CalledFromActionWF = DataCollectionLbl then
                EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'AbortTrxTask (Done)', Logs)
            else
                EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'AbortTrxTask (Done)', Logs)
        else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            if CalledFromActionWF = DataCollectionLbl then
                EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'AbortTrxTask (Error)', StrSubstNo('Error: %1 \\Callstack: %2 \\%3', Error, ErrorCallStack, Logs))
            else
                EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'AbortTrxTask (Error)', StrSubstNo('Error: %1 \\Callstack: %2 \\%3', Error, ErrorCallStack, Logs));
        end;

        if CalledFromActionWF = DataCollectionLbl then
            POSActionDataCollection.SetAbortStatus(ProcessedEntryNo, false)
        else
            POSActionEFTAdyenCloud.SetAbortStatus(ProcessedEntryNo, false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', true, false, '');
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        CalledFromActionWF: Text;
        EntryNo: Integer;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
        ProcessedEntryNo: Integer;
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));
        Evaluate(ProcessedEntryNo, Parameters.Get('ProcessedEntryNo'));

        if CalledFromActionWF = DataCollectionLbl then
            EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'AbortTrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack))
        else
            EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'AbortTrxTaskError', StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        if CalledFromActionWF = DataCollectionLbl then
            POSActionDataCollection.SetAbortStatus(ProcessedEntryNo, false)
        else
            POSActionEFTAdyenCloud.SetAbortStatus(ProcessedEntryNo, false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', false, false, '');
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        EntryNo: Integer;
        POSActionEFTAdyenCloud: Codeunit "NPR POS Action EFT Adyen Cloud";
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        CalledFromActionWF: Text;
        RegisterNo: Code[10];
        OriginalPOSPaymentTypeCode: Code[10];
        ProcessedEntryNo: Integer;
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        if Parameters.ContainsKey('CalledFromActionWF') then
            Evaluate(CalledFromActionWF, Parameters.Get('CalledFromActionWF'));

        RegisterNo := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(RegisterNo));
        OriginalPOSPaymentTypeCode := CopyStr(Parameters.Get('OriginalPOSPaymentTypeCode'), 1, MaxStrLen(OriginalPOSPaymentTypeCode));
        Evaluate(ProcessedEntryNo, Parameters.Get('ProcessedEntryNo'));

        if CalledFromActionWF = DataCollectionLbl then
            EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'AbortTrxTaskCancelled', '')
        else
            EFTAdyenIntegration.WriteLogEntry(RegisterNo, OriginalPOSPaymentTypeCode, EntryNo, false, 'AbortTrxTaskCancelled', '');
        if CalledFromActionWF = DataCollectionLbl then
            POSActionDataCollection.SetAbortStatus(ProcessedEntryNo, false)
        else
            POSActionEFTAdyenCloud.SetAbortStatus(ProcessedEntryNo, false);
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, '', false, false, '');
    end;
}