codeunit 6150750 "NPR Generic Data Collect Task" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        TempAddInfoResponse: Record "NPR MM Add. Info. Response" temporary;
        TempAddInfoRequest: Record "NPR MM Add. Info. Request" temporary;
        IAddInfoRequest: Interface "NPR MM IAdd. Info. Request";
        Response: Text;
        Logs: Text;
        JsonObject: JsonObject;
        InStr: InStream;
        SignatureData: Text;
    begin
        TempAddInfoRequest.Init();
        Evaluate(TempAddInfoRequest."EFT Transaction No.", Parameters.Get('EntryNo'));
        TempAddInfoRequest."Integration Version Code" := CopyStr(Parameters.Get('IntegrationVersionCode'), 1, MaxStrLen(TempAddInfoRequest."Integration Version Code"));
        TempAddInfoRequest."Reference Number Input" := CopyStr(Parameters.Get('ReferenceNumberInput'), 1, MaxStrLen(TempAddInfoRequest."Reference Number Input"));
        TempAddInfoRequest."Register No." := CopyStr(Parameters.Get('RegisterNo'), 1, MaxStrLen(TempAddInfoRequest."Register No."));
        TempAddInfoRequest."Hardware ID" := CopyStr(Parameters.Get('HardwareID'), 1, MaxStrLen(TempAddInfoRequest."Hardware ID"));
        Evaluate(TempAddInfoRequest.Mode, Parameters.Get('Mode'));
        case Parameters.Get('IntegrationType') of
            'Adyen':
                IAddInfoRequest := Enum::"NPR MM Add. Info. Request"::Adyen;
        end;

        case Parameters.Get('DataCollectionStep') of
            'Signature':
                TempAddInfoRequest."Data Collection Step" := TempAddInfoRequest."Data Collection Step"::Signature;
            'PhoneNo':
                TempAddInfoRequest."Data Collection Step" := TempAddInfoRequest."Data Collection Step"::PhoneNo;
            'EMail':
                TempAddInfoRequest."Data Collection Step" := TempAddInfoRequest."Data Collection Step"::EMail;
        end;
        IAddInfoRequest.RequestAdditionalInfo(TempAddInfoRequest, TempAddInfoResponse);

        TempAddInfoResponse."Signature Data".CreateInStream(InStr);
        InStr.ReadText(SignatureData);
        JsonObject.Add('Signature', SignatureData);
        JsonObject.Add('PhoneNo', TempAddInfoResponse."Phone No.");
        JsonObject.Add('EMail', TempAddInfoResponse."E-Mail");
        JsonObject.Add('Success', TempAddInfoResponse.Success);
        JsonObject.Add('ConfirmedFlag', TempAddInfoResponse."Confirmed Flag");
        JsonObject.Add('ResponseResult', TempAddInfoResponse."Response Result");
        JsonObject.Add('ErrorCondition', TempAddInfoResponse."Error Condition");
        JsonObject.Add('ScreenTimeout', TempAddInfoResponse."Screen Timeout");
        JsonObject.WriteTo(Response);

        Result.Add('Started', Format(TempAddInfoResponse.Started, 0, 9));
        Result.Add('Completed', Format(TempAddInfoResponse.Completed, 0, 9));
        Result.Add('Response', Response);
        Result.Add('Logs', Logs);
        if not (TempAddInfoResponse.Started) then begin
            Result.Add('Error', GetLastErrorText());
            Result.Add('ErrorCallstack', GetLastErrorCallStack());
        end;
    end;

    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Results: Dictionary of [Text, Text]);
    var
        EFTAdyenTaskStatus: Enum "NPR EFT DataCollect TaskStatus";
        Completed: Boolean;
        Response: Text;
        Error: Text;
        ErrorCallstack: Text;
        EntryNo: Integer;
        Logs: Text;
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx done, either complete (success/failure) or handled error
        Evaluate(EntryNo, Parameters.Get('EntryNo'));
        Evaluate(Completed, Results.Get('Completed'), 9);

        case Parameters.Get('DataCollectionStep') of
            'Signature':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::SignatureResponseReceived;
            'PhoneNo':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::PhoneNoResponseRecevied;
            'EMail':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::EmailResponseReceived;
        end;

        if Completed then begin
            Response := Results.Get('Response');
            Logs := Results.Get('Logs');
            EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'DataCollectionTaskDone (Complete)', Logs);
            Commit();

            POSActionDataCollection.SetTrxResponse(EntryNo, Response, true, true, '');
            POSActionDataCollection.SetTrxStatus(EntryNo, EFTAdyenTaskStatus);
        end else begin
            Error := Results.Get('Error');
            ErrorCallstack := Results.Get('ErrorCallstack');
            EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'DataCollectionTaskDone (Error)', StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionDataCollection.SetTrxResponse(EntryNo, Response, false, true, StrSubstNo('Error: %1 \\Callstack: %2', Error, ErrorCallStack));
            POSActionDataCollection.SetTrxStatus(EntryNo, EFTAdyenTaskStatus);
        end;
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        EFTAdyenTaskStatus: Enum "NPR EFT DataCollect TaskStatus";
        EntryNo: Integer;
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));

        case Parameters.Get('DataCollectionStep') of
            'Signature':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::SignatureResponseReceived;
            'PhoneNo':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::PhoneNoResponseRecevied;
            'EMail':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::EmailResponseReceived;
        end;

        EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'TaskDataCollectionError', '');
        POSActionDataCollection.SetTrxResponse(EntryNo, '', false, true, StrSubstNo('Error: %1 \\Callstack: %2', ErrorText, ErrorCallStack));
        POSActionDataCollection.SetTrxStatus(EntryNo, EFTAdyenTaskStatus);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text])
    var
        EFTAdyenTaskStatus: Enum "NPR EFT DataCollect TaskStatus";
        EntryNo: Integer;
        POSActionDataCollection: Codeunit "NPR POS Action Data Collection";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        //Trx result unknown - log error and start lookup
        Evaluate(EntryNo, Parameters.Get('EntryNo'));

        case Parameters.Get('DataCollectionStep') of
            'Signature':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::SignatureResponseReceived;
            'PhoneNo':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::PhoneNoResponseRecevied;
            'EMail':
                EFTAdyenTaskStatus := EFTAdyenTaskStatus::EmailResponseReceived;
        end;

        EFTAdyenIntegration.WriteGenericDataCollectionLogEntry(EntryNo, 'TaskDataCollectionCancelled', '');
        POSActionDataCollection.SetTrxResponse(EntryNo, '', false, true, StrSubstNo('Error: %1 \\Callstack: %2'));
        POSActionDataCollection.SetTrxStatus(EntryNo, EFTAdyenTaskStatus);
    end;
}
