codeunit 6151520 "NPR Nc Trigger Sync. Mgt."
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcTriggerScheduler: Codeunit "NPR Nc Trigger Scheduler";
        NcTrigger: Record "NPR Nc Trigger";
        TriggerCode: Code[20];
        RecRef: RecordRef;
        TaskEntryNo: BigInteger;
    begin
        JQParamStrMgt.Parse(Rec."Parameter String");

        Evaluate(TriggerCode, JQParamStrMgt.GetParamValueAsText(NcTriggerScheduler.GetParamName()));
        if TriggerCode = '' then
            exit;

        NcTrigger.Get(TriggerCode);
        RecRef.Get(NcTrigger.RecordId);
        InsertTask(RecRef, TaskEntryNo);
    end;

    procedure InsertTask(var Recref: RecordRef; var TaskEntryNo: BigInteger)
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
        NcTask: Record "NPR Nc Task";
        FldRef: FieldRef;
        NcTaskProcessor: Record "NPR Nc Task Processor";
    begin
        NcTaskSetup.SetCurrentKey("Table No.");
        NcTaskSetup.SetRange("Table No.", Recref.Number);
        if not NcTaskSetup.FindFirst() then
            InsertSetup(NcTaskSetup, Recref);

        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask."Task Processor Code" := NcTaskSetup."Task Processor Code";
        if Recref.Number = Database::"NPR Nc Trigger" then begin
            FldRef := Recref.Field(60);
            if Format(FldRef.Value) <> '' then
                if NcTaskProcessor.Get(Format(FldRef.Value)) then
                    NcTask."Task Processor Code" := NcTaskProcessor.Code;
        end;
        NcTask.Validate(Type, NcTask.Type::Insert);
        NcTask."Company Name" := CompanyName;
        NcTask."Table No." := Recref.Number;
        NcTask."Table Name" := Recref.Name;
        NcTask."Record Position" := Recref.GetPosition(false);
        NcTask."Log Date" := CurrentDateTime;
        NcTask."Record Value" := CopyStr(DelStr(Format(Recref.RecordId), 1, StrLen(Recref.Name) + 2), 1, MaxStrLen(NcTask."Record Value"));
        NcTask.Insert();
        TaskEntryNo := NcTask."Entry No.";
    end;

    procedure AddResponse(var NcTask: Record "NPR Nc Task"; ResponseText: Text)
    var
        StreamOut: OutStream;
        StreamIn: InStream;
        PreviousResponse: Text;
    begin
        NcTask.CalcFields(Response);
        if NcTask.Response.HasValue() then begin
            NcTask.Response.CreateInStream(StreamIn, TextEncoding::UTF8);
            StreamIn.Read(PreviousResponse);
        end else
            PreviousResponse := '';

        NcTask.Response.CreateOutStream(StreamOut, TextEncoding::UTF8);
        StreamOut.Write(PreviousResponse + ResponseText);
    end;

    procedure FillFields(NcTask: Record "NPR Nc Task"; TempEndpoint: Variant)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldRecord: Record "Field";
        NcTaskField: Record "NPR Nc Task Field";
    begin
        if not TempEndpoint.IsRecord() then
            exit;

        RecRef.GetTable(TempEndpoint);
        FieldRecord.Reset();
        FieldRecord.SetRange(TableNo, RecRef.Number);
        if FieldRecord.FindSet() then
            repeat
                FieldRecord.Init();
                FldRef := RecRef.Field(FieldRecord."No.");
                NcTaskField."Entry No." := 0;
                NcTaskField."Field No." := FieldRecord."No.";
                NcTaskField."Field Name" := FldRef.Name;
                NcTaskField."Previous Value" := Format(FldRef.Value, 0, 9);
                NcTaskField."New Value" := FldRef.Value;
                NcTaskField."Log Date" := CurrentDateTime();
                NcTaskField."Task Entry No." := NcTask."Entry No.";
                NcTaskField.Insert();
            until FieldRecord.Next() = 0;
    end;

    procedure GetOutput(NcTaskentryNo: Integer) OutputText: Text
    var
        NcTask: Record "NPR Nc Task";
        MissingOutputErr: Label 'FTP Task not executed because there was no output to send.';
        MissingOutputTaskErr: Label 'Output Task %1 could not be found. The task with output may have been deleted before it could be transferred.', Comment = '%1="NPR Nc Task"."Entry No."';
        InStr: InStream;
        BufferText: Text;
    begin
        if not NcTask.Get(NcTaskentryNo) then
            Error(MissingOutputTaskErr, NcTaskentryNo);

        if not NcTask."Data Output".HasValue() then
            Error(MissingOutputErr);

        NcTask.CalcFields("Data Output");
        NcTask."Data Output".CreateInStream(InStr, TextEncoding::UTF8);
        BufferText := '';
        while not InStr.EOS do begin
            InStr.ReadText(BufferText);
            OutputText += BufferText;
        end;
    end;

    local procedure InsertSetup(var NcTaskSetup: Record "NPR Nc Task Setup"; RecRef: RecordRef)
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
    begin
        NcTaskSetup.Init();
        NcTaskProcessor.FindFirst();
        NcTaskSetup."Task Processor Code" := NcTaskProcessor.Code;
        NcTaskSetup."Entry No." := 0;
        NcTaskSetup.Validate("Table No.", RecRef.Number);
        NcTaskSetup.Validate("Codeunit ID", Codeunit::"NPR Nc Trigger Task Mgt.");
        NcTaskSetup.Insert(true);
    end;
}

