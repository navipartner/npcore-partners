codeunit 6151501 "NPR Nc Task Mgt."
{
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        TaskComplete(Rec);
    end;

    var
        FindNewDataTxt: Label 'Finding new Data Log records: @1@@@@@@@@@@@@@@@@\Buffering Data Logs to Tasks: @2@@@@@@@@@@@@@@@@\    Task Quantity:            #5################\Removing Duplicate Tasks:     @3@@@@@@@@@@@@@@@@\    Removed Task Quantity:    #6################\Updating the Task List:       @4@@@@@@@@@@@@@@@@';
        NaviConnectSetup: Record "NPR Nc Setup";
        DataLogSubScriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        Initialized: Boolean;
        Window: Dialog;
        FindNewData2Txt: Label 'Company: #7#####################################\Finding new Data Log records: @1@@@@@@@@@@@@@@@@\Buffering Data Logs to Tasks: @2@@@@@@@@@@@@@@@@\    Task Quantity:            #5################\Removing Duplicate Tasks:     @3@@@@@@@@@@@@@@@@\    Removed Task Quantity:    #6################\Updating the Task List:       @4@@@@@@@@@@@@@@@@';

    local procedure TaskComplete(var NcTask: Record "NPR Nc Task")
    var
        OutStr: OutStream;
        LastErrorText: Text;
    begin
        LastErrorText := GetLastErrorText;
        if not NcTask.Find() then
            exit;

        NcTask."Last Processing Completed at" := CurrentDateTime;
        NcTask."Last Processing Duration" := (NcTask."Last Processing Completed at" - NcTask."Last Processing Started at") / 1000;
        NcTask.Processed := LastErrorText = '';
        NcTask."Process Error" := LastErrorText <> '';
        if LastErrorText <> '' then begin
            Clear(NcTask.Response);
            NcTask.Response.CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.Write(LastErrorText);
        end;
        NcTask.Modify();
    end;

    procedure UpdateTasks(TaskProcessor: Record "NPR Nc Task Processor")
    var
        TaskProcesLine: Record "NPR Nc Task Proces. Line";
        TempDataLogRecord: Record "NPR Data Log Record" temporary;
        TempTask: Record "NPR Nc Task" temporary;
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        if TaskProcessor.Code = '' then
            TaskProcessor.Code := NcSetupMgt.NaviConnectDefaultTaskProcessorCode();
        Initialize();
        Clear(TempDataLogRecord);
        Clear(TempTask);
        TempDataLogRecord.DeleteAll();
        TempTask.DeleteAll();
        if UseDialog() then
            Window.Open(FindNewDataTxt);

        if DataLogSubScriberMgt.GetNewRecords(TaskProcessor.Code, true,
                                              NaviConnectSetup."Max Task Count per Batch", TempDataLogRecord) then begin
            if UseDialog() then
                Window.Update(1, 10000);
            InsertTempTasks(TaskProcessor, '', TempDataLogRecord, TempTask);
            TempDataLogRecord.DeleteAll();
            DeleteDuplicates(TaskProcessor, TempTask);
            InsertTasks(TempTask);
            Commit();
        end;

        if UseDialog() then
            Window.Close();

        Clear(TempDataLogRecord);
        Clear(TempTask);
        TempDataLogRecord.DeleteAll();
        TempTask.DeleteAll();

        TaskProcesLine.SetRange("Task Processor Code", TaskProcessor.Code);
        TaskProcesLine.SetRange(Type, TaskProcesLine.Type::Company);
        TaskProcesLine.SetRange(Code, TaskProcesLine.DataLogCode());
        TaskProcesLine.SetFilter(Value, '<>%1&<>%2', '', CompanyName);
        if TaskProcesLine.FindSet() then begin
            if UseDialog() then
                Window.Open(FindNewData2Txt);
            repeat
                if UseDialog() then
                    Window.Update(7, TaskProcesLine.Value);
                if DataLogSubScriberMgt.GetNewRecordsCompany(TaskProcessor.Code, TaskProcesLine.Value, true,
                                                      NaviConnectSetup."Max Task Count per Batch", TempDataLogRecord) then begin
                    if UseDialog() then
                        Window.Update(1, 10000);
                    InsertTempTasks(TaskProcessor, TaskProcesLine.Value, TempDataLogRecord, TempTask);
                    TempDataLogRecord.DeleteAll();
                    DeleteDuplicates(TaskProcessor, TempTask);
                    InsertTasks(TempTask);
                end;

                Clear(TempDataLogRecord);
                Clear(TempTask);
                TempDataLogRecord.DeleteAll();
                TempTask.DeleteAll();
            until TaskProcesLine.Next() = 0;

            if UseDialog() then
                Window.Close();
        end;
    end;

    procedure CleanTasks()
    var
        Task: Record "NPR Nc Task";
        TaskField: Record "NPR Nc Task Field";
        TaskOutput: Record "NPR Nc Task Output";
    begin
        Initialize();

        Clear(Task);
        Task.SetCurrentKey("Log Date", Processed);
        Task.SetFilter("Log Date", '<%1', CurrentDateTime - NaviConnectSetup."Keep Tasks for");
        Task.SetRange(Processed, true);
        Task.DeleteAll();

        Clear(Task);
        Clear(TaskField);
        if Task.FindFirst() then;
        TaskField.SetCurrentKey("Task Entry No.");
        TaskField.SetFilter("Task Entry No.", '<%1', Task."Entry No.");
        if not TaskField.IsEmpty then
            TaskField.DeleteAll();

        Clear(TaskField);
        TaskField.SetRange("Task Exists", false);
        if not TaskField.IsEmpty then
            TaskField.DeleteAll();

        TaskOutput.SetCurrentKey("Task Entry No.");
        TaskOutput.SetFilter("Task Entry No.", '<%1', Task."Entry No.");
        if not TaskOutput.IsEmpty then
            TaskField.DeleteAll();

        Clear(TaskOutput);
        TaskOutput.SetRange("Task Exists", false);
        if not TaskOutput.IsEmpty then
            TaskOutput.DeleteAll();
    end;

    local procedure InsertTasks(var TempTask: Record "NPR Nc Task" temporary)
    var
        DataLogField: Record "NPR Data Log Field";
        Task: Record "NPR Nc Task";
        TaskField: Record "NPR Nc Task Field";
        Counter: Integer;
        Total: Integer;
    begin
        if not TempTask.IsTemporary then
            exit;

        Clear(TempTask);

        if UseDialog() then begin
            Counter := 0;
            Total := TempTask.Count();
        end;

        DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");

        if TempTask.FindSet() then
            repeat
                if UseDialog() then begin
                    Counter += 1;
                    Window.Update(4, Round((Counter / Total) * 10000, 1));
                end;
                Task.Init();
                Task := TempTask;
                Task."Entry No." := 0;
                Task.Insert(true);

                DataLogField.SetRange("Table ID", TempTask."Table No.");
                DataLogField.SetRange("Data Log Record Entry No.", TempTask."Entry No.");
                if DataLogField.FindSet() then
                    repeat
                        DataLogField.CalcFields("Field Name");
                        TaskField.Init();
                        TaskField."Entry No." := 0;
                        TaskField."Field No." := DataLogField."Field No.";
                        TaskField."Field Name" := DataLogField."Field Name";
                        TaskField."Previous Value" := DataLogField."Previous Field Value";
                        TaskField."New Value" := DataLogField."Field Value";
                        if TempTask.Type in [TempTask.Type::Delete] then
                            TaskField."Previous Value" := TaskField."New Value";
                        TaskField."Log Date" := DataLogField."Log Date";
                        TaskField."Task Entry No." := Task."Entry No.";
                        TaskField.Insert();
                    until DataLogField.Next() = 0;
            until TempTask.Next() = 0;
    end;

    local procedure InsertTempTasks(TaskProcessor: Record "NPR Nc Task Processor"; DataLogCompanyName: Text[30]; var TempDataLogRecord: Record "NPR Data Log Record" temporary; var TempTask: Record "NPR Nc Task" temporary)
    var
        DataLogField: Record "NPR Data Log Field";
        TaskSetup: Record "NPR Nc Task Setup";
        TempTaskSetup: Record "NPR Nc Task Setup" temporary;
        RecRef: RecordRef;
        RecordID: RecordID;
        i: Integer;
        Counter: Integer;
        Total: Integer;
    begin
        if not TempTask.IsTemporary then
            exit;

        i := 0;
        if (DataLogCompanyName <> '') and (DataLogCompanyName <> CompanyName) then
            DataLogField.ChangeCompany(DataLogCompanyName);
        if UseDialog() then begin
            Counter := 0;
            Total := TempDataLogRecord.Count();
        end;
        if TempDataLogRecord.FindSet() then begin
            DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
            TaskSetup.SetCurrentKey("Task Processor Code", "Table No.", "Codeunit ID");
            TaskSetup.SetRange("Task Processor Code", TaskProcessor.Code);
            if TaskSetup.FindSet() then
                repeat
                    TempTaskSetup.Init();
                    TempTaskSetup := TaskSetup;
                    TempTaskSetup.Insert();
                until TaskSetup.Next() = 0;
            repeat
                if UseDialog() then begin
                    Counter += 1;
                    Window.Update(2, Round((Counter / Total) * 10000, 1));
                end;
                TempTaskSetup.SetRange("Table No.", TempDataLogRecord."Table ID");
                TempTaskSetup.SetFilter("Task Processor Code", '<>%1', '');
                if TempTaskSetup.FindSet() then
                    repeat
                        i += 1;
                        if UseDialog() then begin
                            if i mod 10 = 0 then
                                Window.Update(5, i);
                        end;
                        TempDataLogRecord.CalcFields("Table Name");
                        if not TempTask.Get(TempDataLogRecord."Entry No.") then begin
                            TempTask.Init();
                            TempTask."Entry No." := TempDataLogRecord."Entry No.";
                            TempTask."Task Processor Code" := TempTaskSetup."Task Processor Code";
                            case TempDataLogRecord."Type of Change" of
                                TempDataLogRecord."Type of Change"::Insert:
                                    TempTask.Type := TempTask.Type::Insert;
                                TempDataLogRecord."Type of Change"::Modify:
                                    TempTask.Type := TempTask.Type::Modify;
                                TempDataLogRecord."Type of Change"::Delete:
                                    TempTask.Type := TempTask.Type::Delete;
                                TempDataLogRecord."Type of Change"::Rename:
                                    TempTask.Type := TempTask.Type::Rename;
                            end;
                            TempTask."Company Name" := DataLogCompanyName;
                            TempTask."Table No." := TempDataLogRecord."Table ID";
                            RecordID := TempDataLogRecord."Record ID";
                            RecRef := RecordID.GetRecord();
                            TempTask."Record Position" := RecRef.GetPosition(false);
                            TempTask."Record ID" := RecordID;
                            TempTask."Log Date" := TempDataLogRecord."Log Date";
                            TempTask."Record Value" := CopyStr(DelStr(Format(RecRef.RecordId), 1, StrLen(RecRef.Name) + 2), 1, MaxStrLen(TempTask."Record Value"));
                            TempTask.Insert();
                        end;
                    until TempTaskSetup.Next() = 0;
            until TempDataLogRecord.Next() = 0;
        end;
    end;

    local procedure DeleteDuplicates(TaskProcessor: Record "NPR Nc Task Processor"; var TempTask: Record "NPR Nc Task" temporary)
    var
        TempNewUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        TempUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        Checked: Boolean;
        DeleteTempTask: Boolean;
        UniqueTask: Boolean;
        Counter: Integer;
        Counter2: Integer;
        Total: Integer;
    begin
        Initialize();
        if not TempTask.IsTemporary then
            exit;

        if UseDialog() then begin
            Counter := 0;
            Total := TempTask.Count();
        end;

        Counter2 := 0;
        if TempTask.FindSet() then
            repeat
                if UseDialog() then begin
                    Counter += 1;
                    Window.Update(3, Round((Counter / Total) * 10000, 1));
                end;
                Checked := false;
                UniqueTask := false;
                IsUniqueTask(TaskProcessor, TempTask, TempUniqueTaskBuffer, UniqueTask, Checked);
                if not Checked then begin
                    TempNewUniqueTaskBuffer.Init();
                    TempNewUniqueTaskBuffer."Table No." := TempTask."Table No.";
                    TempNewUniqueTaskBuffer."Task Processor Code" := TempTask."Task Processor Code";
                    TempNewUniqueTaskBuffer."Record Position" := TempTask."Record Position";
                    TempNewUniqueTaskBuffer."Codeunit ID" := 0;
                    TempNewUniqueTaskBuffer."Processing Code" := Format(TempTask.Type);
                    UniqueTask := ReqisterUniqueTask(TempNewUniqueTaskBuffer, TempUniqueTaskBuffer);
                end;
                DeleteTempTask := not UniqueTask;
                if DeleteTempTask then begin
                    if UseDialog() then begin
                        Counter2 += 1;
                        if Counter2 mod 10 = 0 then
                            Window.Update(6, Counter2);
                    end;
                    TempTask.Delete();
                end;
            until TempTask.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure IsUniqueTask(TaskProcessor: Record "NPR Nc Task Processor"; var TempTask: Record "NPR Nc Task" temporary; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary; var IsUnique: Boolean; var Checked: Boolean)
    begin
    end;

    procedure ReqisterUniqueTask(NewUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary) IsDuplicate: Boolean
    begin
        UniqueTaskBuffer.SetPosition(NewUniqueTaskBuffer.GetPosition(false));
        if UniqueTaskBuffer.Find() then
            exit;

        UniqueTaskBuffer.Insert();
        exit(true);
    end;

    local procedure AssignValue(var FieldRef: FieldRef; Value: Text[250])
    var
        TextValue: Text[250];
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        DateFormulaValue: DateFormula;
        BigIntegerValue: BigInteger;
        DateTimeValue: DateTime;
    begin
        case UpperCase(Format(FieldRef.Type)) of
            'CODE', 'TEXT':
                begin
                    TextValue := Value;
                    FieldRef.Value := TextValue;
                end;
            'DECIMAL':
                begin
                    if Value = '' then
                        Value := Format(DecimalValue, 0, 9);
                    Evaluate(DecimalValue, Value, 9);
                    FieldRef.Value := DecimalValue;
                end;
            'BOOLEAN':
                begin
                    if Value = '' then
                        Value := Format(BooleanValue, 0, 9);
                    Evaluate(BooleanValue, Value, 9);
                    FieldRef.Value := BooleanValue;
                end;
            'DATEFORMULA':
                begin
                    if Value = '' then
                        Value := Format(DateFormulaValue, 0, 9);
                    Evaluate(DateFormulaValue, Value, 9);
                    FieldRef.Value := DateFormulaValue;
                end;
            'BIGINTEGER':
                begin
                    if Value = '' then
                        Value := Format(BigIntegerValue, 0, 9);
                    Evaluate(BigIntegerValue, Value, 9);
                    FieldRef.Value := BigIntegerValue;
                end;
            'DATETIME':
                begin
                    if Value = '' then
                        Value := Format(DateTimeValue, 0, 9);
                    Evaluate(DateTimeValue, Value, 9);
                    FieldRef.Value := DateTimeValue;
                end;
            'OPTION', 'INTEGER':
                begin
                    if Value = '' then
                        Value := Format(IntegerValue, 0, 9);
                    Evaluate(IntegerValue, Value, 9);
                    FieldRef.Value := IntegerValue;
                end;
            'DATE':
                begin
                    if Value = '' then
                        Value := Format(DateValue, 0, 9);
                    Evaluate(DateValue, Value, 9);
                    FieldRef.Value := DateValue;
                end;
            'TIME':
                begin
                    if Value = '' then
                        Value := Format(TimeValue, 0, 9);
                    Evaluate(TimeValue, Value, 9);
                    FieldRef.Value := TimeValue;
                end;
        end;
    end;

    procedure GetRecRef(NcTask: Record "NPR Nc Task"; var RecRef: RecordRef): Boolean
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        Position: Text;
    begin
        Clear(RecRef);
        if (NcTask."Company Name" = '') or (NcTask."Company Name" = CompanyName) then
            RecRef.Open(NcTask."Table No.")
        else
            RecRef.Open(NcTask."Table No.", false, NcTask."Company Name");

        Position := NcTaskMgt.GetRecordPosition(NcTask);
        RecRef.SetPosition(Position);
        exit(RecRef.Find());
    end;

    procedure RestoreRecord(TaskEntryNo: BigInteger; var RecRef: RecordRef): Boolean
    var
        "Fields": Record "Field";
        Task: Record "NPR Nc Task";
        TaskField: Record "NPR Nc Task Field";
        FieldRef: FieldRef;
        RecRefExisting: RecordRef;
        Position: Text;
    begin
        if not Task.Get(TaskEntryNo) then
            exit(false);
        if (Task."Company Name" = '') or (Task."Company Name" = CompanyName) then
            RecRefExisting.Open(Task."Table No.")
        else
            RecRefExisting.Open(Task."Table No.", false, Task."Company Name");

        Position := GetRecordPosition(Task);
        RecRefExisting.SetPosition(Position);
        if RecRefExisting.Find() then begin
            RecRef := RecRefExisting.Duplicate();

            Clear(TaskField);
            TaskField.SetRange("Task Entry No.", Task."Entry No.");
            TaskField.SetFilter("Previous Value", '<>%1', '');
            if TaskField.FindSet() then
                repeat
                    if "Fields".Get(Task."Table No.", TaskField."Field No.") and ("Fields".ObsoleteState <> "Fields".ObsoleteState::Removed) then begin
                        FieldRef := RecRef.Field(TaskField."Field No.");
                        AssignValue(FieldRef, TaskField."Previous Value");
                    end;
                until TaskField.Next() = 0;
        end else begin
            Clear(RecRef);
            RecRef.Open(Task."Table No.", true);
            RecRef.Init();
            RecRef.SetPosition(Position);

            Clear(TaskField);
            TaskField.SetRange("Task Entry No.", Task."Entry No.");
            if TaskField.FindSet() then
                repeat
                    if "Fields".Get(Task."Table No.", TaskField."Field No.") and ("Fields".ObsoleteState <> "Fields".ObsoleteState::Removed) then begin
                        FieldRef := RecRef.Field(TaskField."Field No.");
                        AssignValue(FieldRef, TaskField."Previous Value");
                    end;
                until TaskField.Next() = 0;
            RecRef.Insert();
        end;
        exit(true);
    end;

    procedure RestoreRecordFromDataLog(RecordEntryNo: BigInteger; RecCompanyName: Text[30]; var RecRef: RecordRef): Boolean
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        FieldRef: FieldRef;
        RecordID: RecordID;
        RecRefExisting: RecordRef;
        RecordPosition: Text;
    begin
        if (RecCompanyName <> '') and (RecCompanyName <> CompanyName) then begin
            DataLogRecord.ChangeCompany(RecCompanyName);
            DataLogField.ChangeCompany(RecCompanyName);
        end;

        if not DataLogRecord.Get(RecordEntryNo) then
            exit(false);

        if (RecCompanyName <> '') and (RecCompanyName <> CompanyName) then
            RecRefExisting.Open(DataLogRecord."Table ID", false, RecCompanyName)
        else
            RecRefExisting.Open(DataLogRecord."Table ID");

        RecordID := DataLogRecord."Record ID";
        RecRef := RecordID.GetRecord();

        RecordPosition := RecRef.GetPosition(false);
        RecRefExisting.SetPosition(RecordPosition);
        if RecRefExisting.Find() then begin
            RecRef := RecRefExisting.Duplicate();

            DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
            DataLogField.SetRange("Table ID", DataLogRecord."Table ID");
            DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
            DataLogField.SetRange("Field Value Changed", true);
            DataLogField.SetAutoCalcFields("Obsolete State");
            if not DataLogField.FindSet() then
                exit(true);

            repeat
                if DataLogField."Obsolete State" <> DataLogField."Obsolete State"::Removed then begin
                    FieldRef := RecRef.Field(DataLogField."Field No.");
                    AssignValue(FieldRef, DataLogField."Previous Field Value");
                end;
            until DataLogField.Next() = 0;

            exit(true);
        end;
        Clear(RecRef);
        RecRef.Open(DataLogRecord."Table ID", true);
        RecRef.Init();
        RecRef.SetPosition(RecordPosition);
        DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
        DataLogField.SetRange("Table ID", DataLogRecord."Table ID");
        DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
        DataLogField.SetAutoCalcFields("Obsolete State");
        if not DataLogField.FindSet() then
            exit(false);

        repeat
            if DataLogField."Obsolete State" <> DataLogField."Obsolete State"::Removed then begin
                FieldRef := RecRef.Field(DataLogField."Field No.");
                if DataLogField."Field Value Changed" then
                    AssignValue(FieldRef, DataLogField."Previous Field Value")
                else
                    AssignValue(FieldRef, DataLogField."Field Value");
            end;
        until DataLogField.Next() = 0;

        RecRef.Insert();
        exit(true);
    end;

    procedure RunSourceCard(NaviConnectTask: Record "NPR Nc Task")
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
        RunCardExecuted: Boolean;
        Position: Text;
    begin
        RecRef.Open(NaviConnectTask."Table No.");
        Position := GetRecordPosition(NaviConnectTask);
        RecRef.SetPosition(Position);
        RecRef.SetRecFilter();

        RunSourceCardEvent(RecRef, RunCardExecuted);
        if RunCardExecuted then
            exit;

        PageMgt.PageRun(RecRef);
    end;

    [IntegrationEvent(false, false)]
    local procedure RunSourceCardEvent(var RecRef: RecordRef; var RunCardExecuted: Boolean)
    begin
    end;

    procedure Initialize()
    begin
        if not Initialized then begin
            NaviConnectSetup.Get();
            Initialized := true;
        end;
    end;

    procedure RecExists(var RecRef: RecordRef; RecCompanyName: Text): Boolean
    var
        RecRefExists: RecordRef;
    begin
        if RecCompanyName = '' then
            RecRefExists.Open(RecRef.Number)
        else
            RecRefExists.Open(RecRef.Number, false, RecCompanyName);
        RecRefExists.SetPosition(RecRef.GetPosition(false));
        exit(RecRefExists.Find());
    end;

    local procedure UseDialog(): Boolean
    begin
        exit(GuiAllowed);
    end;

    procedure GetRecordPosition(NcTask: Record "NPR Nc Task") RecordPosition: Text
    var
        RecordID: RecordID;
        RecRef: RecordRef;
    begin
        RecordPosition := NcTask."Record Position";
        if Format(NcTask."Record ID") <> '' then begin
            RecordID := NcTask."Record ID";
            RecRef := RecordID.GetRecord();
            RecordPosition := RecRef.GetPosition(false);
        end;

        exit(RecordPosition);
    end;
}

