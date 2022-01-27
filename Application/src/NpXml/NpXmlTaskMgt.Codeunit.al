codeunit 6151550 "NPR NpXml Task Mgt."
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    var
        TaskProcessor: Record "NPR Nc Task Processor";
        TempUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        PrevRecRef: RecordRef;
        ProcessComplete: Boolean;
    begin
        TaskProcessor.Get(Rec."Task Processor Code");
        NpXmlTriggerMgt.ResetOutput();
        Clear(RecRef);
        Clear(PrevRecRef);
        NcTaskMgt.RestoreRecord(Rec."Entry No.", PrevRecRef);
        ProcessComplete := true;
        case Rec.Type of
            Rec.Type::Insert:
                begin
                    if NcTaskMgt.GetRecRef(Rec, RecRef) then begin
                        NpXmlTriggerMgt.RunTriggers(TaskProcessor, PrevRecRef, RecRef, Rec, true, false, false, TempUniqueTaskBuffer);
                        ProcessComplete := NpXmlTriggerMgt.GetProcessComplete() and ProcessComplete;
                    end;
                end;
            Rec.Type::Modify:
                begin
                    if NcTaskMgt.GetRecRef(Rec, RecRef) then begin
                        NpXmlTriggerMgt.RunTriggers(TaskProcessor, PrevRecRef, RecRef, Rec, false, true, false, TempUniqueTaskBuffer);
                        ProcessComplete := NpXmlTriggerMgt.GetProcessComplete() and ProcessComplete;
                    end;
                end;
            Rec.Type::Delete:
                begin
                    RecRef2 := PrevRecRef.Duplicate();
                    if NcTaskMgt.RecExists(RecRef2, Rec."Company Name") then
                        RecRef2.Find();

                    NpXmlTriggerMgt.RunTriggers(TaskProcessor, PrevRecRef, RecRef2, Rec, false, false, true, TempUniqueTaskBuffer);
                    ProcessComplete := NpXmlTriggerMgt.GetProcessComplete() and ProcessComplete;
                end;
            Rec.Type::Rename:
                begin
                    RecRef2 := PrevRecRef.Duplicate();
                    if NcTaskMgt.RecExists(RecRef2, Rec."Company Name") then
                        RecRef2.Find();

                    NpXmlTriggerMgt.RunTriggers(TaskProcessor, PrevRecRef, RecRef2, Rec, false, false, true, TempUniqueTaskBuffer);
                    ProcessComplete := NpXmlTriggerMgt.GetProcessComplete() and ProcessComplete;
                    if NcTaskMgt.GetRecRef(Rec, RecRef) then begin
                        NpXmlTriggerMgt.RunTriggers(TaskProcessor, PrevRecRef, RecRef, Rec, true, true, false, TempUniqueTaskBuffer);
                        ProcessComplete := NpXmlTriggerMgt.GetProcessComplete() and ProcessComplete;
                    end;
                end;
        end;

        CommitOutput(Rec);
        CommitResponse(Rec);
        if not ProcessComplete then
            Error(GetLastErrorText);
    end;

    var
        NpXmlTriggerMgt: Codeunit "NPR NpXml Trigger Mgt.";

    local procedure CommitOutput(var Task: Record "NPR Nc Task")
    var
        OutputTempBlob: Codeunit "Temp Blob";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        RecRef: RecordRef;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);

        Task.CalcFields("Data Output");
        if Task."Data Output".HasValue() then begin
            Task."Data Output".CreateInStream(InStr);
            CopyStream(OutStr, InStr);
        end;

        if NpXmlTriggerMgt.GetOutput(OutputTempBlob) then begin
            OutputTempBlob.CreateInStream(InStr);
            CopyStream(OutStr, InStr);
        end;

        RecRef.GetTable(Task);
        TempBlob.ToRecordRef(RecRef, Task.FieldNo("Data Output"));
        RecRef.SetTable(Task);

        Task.Modify(true);
        Commit();
    end;

    local procedure CommitResponse(var Task: Record "NPR Nc Task")
    var
        ResponseTempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        Clear(Task.Response);
        if NpXmlTriggerMgt.GetResponse(ResponseTempBlob) then begin
            RecRef.GetTable(Task);
            ResponseTempBlob.ToRecordRef(RecRef, Task.FieldNo(Response));
            RecRef.SetTable(Task);
        end;
        Task.Modify(true);
        Commit();
        Clear(ResponseTempBlob);
    end;

    procedure SetupNpXml()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        NpXmlTemplate.SetRange("Transaction Task", true);
        if NpXmlTemplate.FindSet() then
            repeat
                NpXmlTemplate.UpdateNaviConnectSetup();
            until NpXmlTemplate.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", 'IsUniqueTask', '', true, true)]
    local procedure IsUniqueTask(TaskProcessor: Record "NPR Nc Task Processor"; var TempTask: Record "NPR Nc Task" temporary; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary; var IsUnique: Boolean; var Checked: Boolean)
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        PrevRecRef: RecordRef;
        RecRef: RecordRef;
    begin
        if not TempTask.IsTemporary then
            exit;
        if not IsNpXmlTask(TaskProcessor, TempTask) then
            exit;

        Checked := true;

        if not NcTaskMgt.RestoreRecordFromDataLog(TempTask."Entry No.", TempTask."Company Name", PrevRecRef) then
            exit;

        if not NcTaskMgt.GetRecRef(TempTask, RecRef) then
            RecRef := PrevRecRef.Duplicate();

        if NpXmlTriggerMgt.IsUniqueTask(TaskProcessor,
          TempTask.Type in [TempTask.Type::Insert, TempTask.Type::Rename],
          TempTask.Type in [TempTask.Type::Modify, TempTask.Type::Rename],
          TempTask.Type in [TempTask.Type::Delete, TempTask.Type::Rename],
          PrevRecRef,
          RecRef,
          UniqueTaskBuffer)
        then
            IsUnique := true;
    end;

    local procedure IsNpXmlTask(TaskProcessor: Record "NPR Nc Task Processor"; Task: Record "NPR Nc Task"): Boolean
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
        NpXmlSetup: Record "NPR NpXml Setup";
    begin
        if not (NpXmlSetup.Get() and NpXmlSetup."NpXml Enabled") then
            exit(false);

        NcTaskSetup.SetCurrentKey("Task Processor Code", "Table No.", "Codeunit ID");
        NcTaskSetup.SetRange("Task Processor Code", TaskProcessor.Code);
        NcTaskSetup.SetRange("Table No.", Task."Table No.");
        NcTaskSetup.SetRange("Codeunit ID", CODEUNIT::"NPR NpXml Task Mgt.");
        exit(NcTaskSetup.FindFirst());
    end;
}

