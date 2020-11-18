codeunit 6151534 "NPR Nc Try Catch Mgt."
{
    TableNo = "NPR Nc Task Output";

    trigger OnRun()
    var
        JObject: JsonObject;
        Method: Text;
        MethodNotFoundErr: Label 'Internal error. Method name not provide for "Nc Try Catch". Please, contact your system administrator.';
    begin
        if not ReadJsonArgumentsWithMethodName(Rec, Method, JObject) then
            Error(MethodNotFoundErr);
        case Method of
            'ManualTransferOutputNcTriggerTaskMgt':
                begin
                    ManualTransferOutputNcTriggerTaskMgt(Rec, JObject);
                end;
        end;
    end;

    local procedure ManualTransferOutputNcTriggerTaskMgt(var NcTaskOutput: Record "NPR Nc Task Output"; var JObject: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        NcTriggerTaskMgt: Codeunit "NPR Nc Trigger Task Mgt.";
        OutStr: OutStream;
        NcTriggerCode: Code[20];
        Output, FileName, Subject, Body, NcTaskRecId : Text;
    begin
        ReadArgsForManualTransferOutputNcTriggerTaskMgt(JObject, NcTriggerCode, NcTask, Output, FileName, Subject, Body);

        if Output <> '' then begin
            NcTask."Data Output".CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.WriteText(Output);
        end;
        Commit();
        NcTriggerTaskMgt.TransferOutput(NcTriggerCode, NcTask, Output, FileName, Subject, Body);

        WriteArgsForManualTransferOutputNcTriggerTaskMgt(NcTaskOutput, NcTriggerCode, NcTask, Output, FileName, Subject, Body);

        Commit();
        Error('');
    end;

    local procedure ReadJsonArgumentsWithMethodName(var Rec: Record "NPR Nc Task Output"; var Method: Text; var JObject: JsonObject): Boolean
    var
        InStr: InStream;
        Args: Text;
    begin
        Rec.Response.CreateInStream(InStr);
        InStr.ReadText(Args);
        if not JObject.ReadFrom(Args) then
            exit(false);
        GetJValueFromArg(JObject, 'Method', Method);
        exit(Method <> '');
    end;

    local procedure ReadArgsForManualTransferOutputNcTriggerTaskMgt(JObject: JsonObject; NcTriggerCode: Code[20]; var NcTask: Record "NPR Nc Task"; var Output: Text; var FileName: text; var Subject: Text; var Body: Text)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        JToken: JsonToken;
        JValue: JsonValue;
        RecRef: RecordRef;
        RecId: RecordId;
        InStr: InStream;
        NcTaskRecId, Args : Text;
    begin
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
    end;

    local procedure WriteArgsForManualTransferOutputNcTriggerTaskMgt(var Rec: Record "NPR Nc Task Output"; NcTriggerCode: Code[20]; var NcTask: Record "NPR Nc Task"; var Output: Text; var FileName: text; var Subject: Text; var Body: Text)
    var
        JObject: JsonObject;
        OutStr: OutStream;
        Args: Text;
    begin
        Clear(Rec);
        JObject.Add('NcTriggerCode', NcTriggerCode);
        JObject.Add('NcTaskRecId', Format(NcTask.RecordId()));
        JObject.Add('Output', Output);
        JObject.Add('FileName', FileName);
        JObject.Add('Subject', Subject);
        JObject.Add('Body', Body);
        JObject.Add('AssertError', true);
        JObject.WriteTo(Args);

        Rec.Response.CreateOutStream(OutStr);
        OutStr.WriteText(Args);
    end;

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
}