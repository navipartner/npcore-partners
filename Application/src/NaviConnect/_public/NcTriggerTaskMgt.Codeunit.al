﻿codeunit 6151522 "NPR Nc Trigger Task Mgt."
{
    TableNo = "NPR Nc Task";
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Trigger is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

    trigger OnRun()
    var
        NcTask: Record "NPR Nc Task";
        NcTrigger: Record "NPR Nc Trigger";
        TriggerDisabledErr: Label 'Trigger %1 is disabled or missing.', Comment = '%1=Trigger Code';
        NcTriggerCode: Code[20];
        CurrentIteration: Integer;
        MaxIteration: Integer;
        Output: Text;
        Filename: Text;
        Subject: Text;
        Body: Text;
        ExpectedIteration: Decimal;
    begin
        NcTriggerCode := '';
        if GetNcTriggerCode(Rec, NcTriggerCode) then begin
            if not IsEnabled(NcTriggerCode) then
                Error(TriggerDisabledErr, NcTriggerCode);
            AddOutputToTask(NcTriggerCode, Rec, Output, CurrentIteration, MaxIteration, Filename, Subject, Body);
            ExpectedIteration := 1;
            if CurrentIteration < MaxIteration then
                repeat
                    if CurrentIteration <> ExpectedIteration then
                        Error(WrongIterationErr, ExpectedIteration, CurrentIteration);
                    ExpectedIteration := CurrentIteration + 1;
                    NcTask := Rec;
                    NcTask."Entry No." := 0;
                    NcTask."Last Processing Started at" := CurrentDateTime();
                    NcTask."Process Error" := true;
                    NcTask.Insert(true);
                    Commit();
                    AddOutputToTask(NcTriggerCode, NcTask, Output, CurrentIteration, MaxIteration, Filename, Subject, Body);
                    TransferOutput(NcTriggerCode, NcTask, Output, Filename, Subject, Body);
                    NcTask."Last Processing Completed at" := CurrentDateTime();
                    NcTask."Last Processing Duration" := (NcTask."Last Processing Completed at" - NcTask."Last Processing Started at") / 1000;
                    NcTask.Processed := true;
                    NcTask."Process Error" := false;
                    NcTask.Modify();
                    Commit();
                until (CurrentIteration >= MaxIteration);
        end else begin
            GetOutputFromTask(Rec, Output);
        end;
        if Output = '' then begin
            if NcTriggerCode <> '' then begin
                NcTrigger.Get(NcTriggerCode);
                if not NcTrigger."Error on Empty Output" then
                    exit;
            end;
            Error(NoOutputErr);
        end;

        TransferOutput(NcTriggerCode, Rec, Output, Filename, Subject, Body);
    end;

    var
        NoOutputErr: Label 'Output is missing';
        WrongIterationErr: Label 'Technical error: the expected iteration is %1, but the subscriber returned %2.', Comment = '%1=Expected Iteration;%2=Current Iteration';

    local procedure AddOutputToTask(NcTriggerCode: Code[20]; var NcTask: Record "NPR Nc Task"; var Output: Text; var CurrentIteration: Integer; var MaxIteration: Integer; var Filename: Text; var Subject: Text; var Body: Text)
    var
        NcTrigger: Record "NPR Nc Trigger";
        Handled: Boolean;
        OStream: OutStream;
        NoSubscriberErr: Label 'No subscriber found for %1.', Comment = '%1=NC Trigger TableCaption';
    begin
        OnRunNcTriggerTask(NcTriggerCode, Output, NcTask, Handled, CurrentIteration, MaxIteration, Filename, Subject, Body);
        if not Handled then
            Error(NoSubscriberErr, NcTrigger.TableCaption());
        NcTask."Data Output".CreateOutStream(OStream, TEXTENCODING::UTF8);
        OStream.WriteText(Output);
        NcTask.Modify(true);
    end;

    local procedure GetNcTriggerCode(NcTask: Record "NPR Nc Task"; var NcTriggerCode: Code[20]): Boolean
    var
        NcTrigger: Record "NPR Nc Trigger";
    begin
        if NcTask."Table No." <> DATABASE::"NPR Nc Trigger" then
            exit(false);
        NcTrigger.SetPosition(NcTask."Record Position");
        NcTrigger.SetRange(Code, NcTrigger.Code);
        if NcTrigger.FindFirst() then begin
            NcTriggerCode := NcTrigger.Code;
            exit(true);
        end else
            exit(false);
    end;

    local procedure IsEnabled(NCTriggerCode: Code[20]): Boolean
    var
        NcTrigger: Record "NPR Nc Trigger";
    begin
        if NcTrigger.Get(NCTriggerCode) then
            if NcTrigger.Enabled then
                exit(true);
        exit(false);
    end;

    local procedure GetOutputFromTask(var NcTask: Record "NPR Nc Task"; var Output: Text)
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
        NcEndpointFile: Record "NPR Nc Endpoint File";
        NcEndpointFtp: Record "NPR Nc Endpoint FTP";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        InStr: InStream;
        Outstr: OutStream;
        RecRef: RecordRef;
        FieldReference: FieldRef;
        OutputEntryNo: Integer;
        BufferText: Text;
    begin
        if NcTask."Data Output".HasValue() then begin
            NcTask.CalcFields("Data Output");
            NcTask."Data Output".CreateInStream(InStr, TextEncoding::UTF8);
            BufferText := '';
            while not InStr.EOS do begin
                InStr.ReadText(BufferText);
                Output += BufferText;
            end;
            exit;
        end;

        NcTaskMgt.RestoreRecord(NcTask."Entry No.", RecRef);
        case RecRef.Number() of
            DATABASE::"NPR Nc Endpoint FTP":
                FieldReference := RecRef.Field(NcEndpointFtp.FieldNo("Output Nc Task Entry No."));
            DATABASE::"NPR Nc Endpoint E-mail":
                FieldReference := RecRef.Field(NcEndpointEmail.FieldNo("Output Nc Task Entry No."));
            DATABASE::"NPR Nc Endpoint File":
                FieldReference := RecRef.Field(NcEndpointFile.FieldNo("Output Nc Task Entry No."));
            else
                exit;
        end;

        OutputEntryNo := FieldReference.Value();
        Output := NcTriggerSyncMgt.GetOutput(OutputEntryNo);
        NcTask."Data Output".CreateOutStream(Outstr, TextEncoding::UTF8);
        Outstr.WriteText(Output);
        NcTask.Modify(true);
    end;

    internal procedure TransferOutput(NcTriggerCode: Code[20]; var NcTask: Record "NPR Nc Task"; Output: Text; Filename: Text; Subject: Text; Body: Text)
    begin
        OnAfterGetOutputTriggerTask(NcTriggerCode, Output, NcTask, Filename, Subject, Body);
    end;

    internal procedure ManualTransferOutput(NcTriggerCode: Code[20]; var NcTask: Record "NPR Nc Task"; var Output: Text; var Filename: Text; var Subject: Text; var Body: Text): Boolean
    var
        TempTaskOutput: Record "NPR Nc Task Output" temporary;
        IsAssertError: Boolean;
    begin
        WriteArgsForManualTransferOutputNcTriggerTaskMgt(TempTaskOutput, NcTriggerCode, NcTask, Output, FileName, Subject, Body);

        Commit();
        if not Codeunit.Run(Codeunit::"NPR Nc Task Try Catch Mgt.", TempTaskOutput) then begin
            ReadArgsForManualTransferOutputNcTriggerTaskMgt(TempTaskOutput, NcTriggerCode, NcTask, Output, FileName, Subject, Body, IsAssertError);
            exit(IsAssertError);
        end;
    end;

    local procedure ReadArgsForManualTransferOutputNcTriggerTaskMgt(var Rec: Record "NPR Nc Task Output"; NcTriggerCode: Code[20]; var NcTask: Record "NPR Nc Task"; var Output: Text; var FileName: text; var Subject: Text; var Body: Text; var IsAssertError: Boolean)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        JObject: JsonObject;
        RecRef: RecordRef;
        RecId: RecordId;
        InStr: InStream;
        NcTaskRecId, Args : Text;
    begin
        Rec.Response.CreateInStream(InStr);
        InStr.ReadText(Args);

        if JObject.ReadFrom(Args) then begin
            GetJValueFromArg(JObject, 'NcTaskRecId', NcTaskRecId);
            if Evaluate(RecId, NcTaskRecId) then
                if DataTypeManagement.GetRecordRef(RecId, RecRef) then begin
                    RecRef.SetTable(NcTask);
                    if NcTask.Find() then;
                end;
            GetJValueFromArg(JObject, 'NcTriggerCode', NcTriggerCode);
            GetJValueFromArg(JObject, 'Output', Output);
            GetJValueFromArg(JObject, 'FileName', FileName);
            GetJValueFromArg(JObject, 'Subject', Subject);
            GetJValueFromArg(JObject, 'Body', Body);
            GetJValueFromArg(JObject, 'IsAssertError', IsAssertError);
        end;
    end;

    local procedure WriteArgsForManualTransferOutputNcTriggerTaskMgt(var Rec: Record "NPR Nc Task Output"; NcTriggerCode: Code[20]; var NcTask: Record "NPR Nc Task"; Output: Text; FileName: text; Subject: Text; Body: Text)
    var
        JObject: JsonObject;
        OutStr: OutStream;
        Args: Text;
    begin
        JObject.Add('Method', 'ManualTransferOutputNcTriggerTaskMgt');
        JObject.Add('NcTriggerCode', NcTriggerCode);
        JObject.Add('NcTaskRecId', Format(NcTask.RecordId()));
        JObject.Add('Output', Output);
        JObject.Add('FileName', FileName);
        JObject.Add('Subject', Subject);
        JObject.Add('Body', Body);
        JObject.WriteTo(Args);

        Rec.Response.CreateOutStream(OutStr);
        OutStr.WriteText(Args);
    end;

#pragma warning disable AA0139
    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Code[20])
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsCode();
        end;
    end;
#pragma warning restore AA0139

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Text)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsText();
        end;
    end;

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Boolean)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsBoolean();
        end;
    end;

    internal procedure VerifyNoEndpointTriggerLinksExist(EndpointTypeCode: Code[20]; EndpointCode: Code[20])
    var
        NcEndpointTriggerLink: Record "NPR Nc Endpoint Trigger Link";
        EndpointTriggerLinkExistErr: Label '%1 records exist. Please delete these first.', Comment = '%1=Nc Endpoint Trigger Link TableCaption';
    begin
        NcEndpointTriggerLink.Reset();
        NcEndpointTriggerLink.SetRange("Endpoint Code", EndpointCode);
        if not NcEndpointTriggerLink.IsEmpty() then
            Error(EndpointTriggerLinkExistErr, NcEndpointTriggerLink.TableCaption());
    end;

    //Events

    [IntegrationEvent(false, false)]
    local procedure OnRunNcTriggerTask(TriggerCode: Code[20]; var Output: Text; var NcTask: Record "NPR Nc Task"; var Handled: Boolean; var CurrentIteration: Integer; var MaxIterations: Integer; var Filename: Text; var Subject: Text; var Body: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetOutputTriggerTask(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupNcTriggers()
    begin
    end;
}

