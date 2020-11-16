codeunit 6151501 "NPR Nc Task Mgt."
{
    // NC1.00/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // NC1.01/MHA /20150126  CASE 199932 Added Cleanup
    // NC1.01/MHA /20150126  CASE 199932 Added NpXml IsDuplicate function - May be ommitted if module [NX] is not installed
    // NC1.04/MHA /20150213  CASE 199932 Renamed functions:
    //                                 - DeleteDuplicateTempTasks --> DeleteDuplicates
    //                                 - InsertTasksFromTempTasks --> InsertTasks
    //                                 - InsertTempTasksFromDataLogs --> InsertTempTasks
    //                                 - TaskRestoreRecord --> RestoreRecord
    //                                 - TempTaskRestoreRecord --> RestoreRecordTemp
    // NC1.06/MHA /20150224  CASE 206395 Updated function RestoreRecord() to restore from stored values only
    // NC1.13/MHA /20150414  CASE 211360 Added Primary Key Fields fields for easier record identification
    // NC1.16/MHA /20150519  CASE 214257 Updated DataLogMgt to DataLogSubscriberMgt [DL1.07]
    // NC1.17/MHA /20150622  CASE 215533 Added NpXmlSetup
    // NC1.18/MHA /20150710  CASE 218282 Added COMMIT to UpdateTasks()
    // NC1.20/MHA /20151008  CASE 224357 Reworked RestoreRecordTemp() for better performance
    // NC1.21/TS  /20151014 CASE 225075 Modified Code to take Max Import From Naviconnect Setup
    // NC1.22/MHA /20160125 CASE 232733 Task Queue Worker Group replaced by NaviConnect Task Processor
    // NC1.22/MHA /20160415 CASE 231214 Added multi company data log
    // NC1.22/TS /20160427  CASE 240229 New Value should be stored in Previous Value for Rename
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20160901  CASE 247479 Added function IsNpXmlTask() for differentiating IsDuplicate Check
    // NC2.01/MHA /20160914  CASE 242551 Wrong filter removed in RestoreRecordTemp() and missing filter added in RestoreRecord()
    // NC2.05/MHA /20170615  CASE 280860 Refactored Cleanup() on Nc Task Field
    // NC2.07/MHA /20171016  CASE 293599 Removed buffering of fields in UpdateTasks() to increase performance
    // NC2.07/MHA /20171027  CASE 294737 RestoreRecord now restored non-existing Rec to Temporary
    // NC2.08/MHA /20171127  CASE 297750 Function CleanTasks() made Public and removed from UpdateTasks()
    // NC2.08/TS  /20171204  CASE 298597 Tasks shold be inserted only once.
    // NC2.08/MHA /20180110  CASE 301296 Replaced function RestoreRecordToRecRef() with RestoreRecordFromDataLog()
    // NC2.12/MHA /20180418  CASE 308107 Deleted functions IsDuplicate(),IsNpXmlTask() and added functions IsUniqueTask(),ReqisterUniqueTask()
    // NC2.14/MHA /20180629  CASE 308107 Added Task Output to CleanTasks()
    // NC2.14/MHA /20180629  CASE 320762 Added Record ID to Nc Tasks
    // NC2.22/MHA /20190613  CASE 358499 Added function TaskComplete()
    // NC2.24/MHA /20191126  CASE 378811 Fixed previous value for Rename in InsertTasks() and removed green code

    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        //-NC2.22 [358499]
        TaskComplete(Rec);
        //-NC2.22 [358499]
    end;

    var
        Text001: Label 'Finding new Data Log records: @1@@@@@@@@@@@@@@@@\Buffering Data Logs to Tasks: @2@@@@@@@@@@@@@@@@\    Task Quantity:            #5################\Removing Duplicate Tasks:     @3@@@@@@@@@@@@@@@@\    Removed Task Quantity:    #6################\Updating the Task List:       @4@@@@@@@@@@@@@@@@';
        NaviConnectSetup: Record "NPR Nc Setup";
        DataLogSubScriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        Initialized: Boolean;
        Window: Dialog;
        DataLogEntryNo: Integer;
        Text002: Label 'Company: #7#####################################\Finding new Data Log records: @1@@@@@@@@@@@@@@@@\Buffering Data Logs to Tasks: @2@@@@@@@@@@@@@@@@\    Task Quantity:            #5################\Removing Duplicate Tasks:     @3@@@@@@@@@@@@@@@@\    Removed Task Quantity:    #6################\Updating the Task List:       @4@@@@@@@@@@@@@@@@';

    local procedure TaskComplete(var NcTask: Record "NPR Nc Task")
    var
        OutStr: OutStream;
        LastErrorText: Text;
    begin
        //-NC2.22 [358499]
        LastErrorText := GetLastErrorText;
        if not NcTask.Find then
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
        NcTask.Modify;
        //+NC2.22 [358499]
    end;

    procedure UpdateTasks(TaskProcessor: Record "NPR Nc Task Processor")
    var
        TaskProcesLine: Record "NPR Nc Task Proces. Line";
        TempDataLogRecord: Record "NPR Data Log Record" temporary;
        TempTask: Record "NPR Nc Task" temporary;
        RecordID: RecordID;
    begin
        if TaskProcessor.Code = '' then
            TaskProcessor.Code := 'NC';
        Initialize();
        Clear(TempDataLogRecord);
        Clear(TempTask);
        TempDataLogRecord.DeleteAll;
        TempTask.DeleteAll;
        if UseDialog then
            Window.Open(Text001);

        if DataLogSubScriberMgt.GetNewRecords(TaskProcessor.Code, true,
                                              NaviConnectSetup."Max Task Count per Batch", TempDataLogRecord) then begin
            if UseDialog then
                Window.Update(1, 10000);
            //-NC2.07 [293599]
            InsertTempTasks(TaskProcessor, '', TempDataLogRecord, TempTask);
            //+NC2.07 [293599]
            TempDataLogRecord.DeleteAll;
            //-NC2.07 [293599]
            DeleteDuplicates(TaskProcessor, TempTask);
            InsertTasks(TempTask);
            //+NC2.07 [293599]
            Commit;
        end;

        if UseDialog then
            Window.Close;

        Clear(TempDataLogRecord);
        Clear(TempTask);
        TempDataLogRecord.DeleteAll;
        TempTask.DeleteAll;

        TaskProcesLine.SetRange("Task Processor Code", TaskProcessor.Code);
        TaskProcesLine.SetRange(Type, TaskProcesLine.Type::Company);
        TaskProcesLine.SetRange(Code, TaskProcesLine.DataLogCode());
        TaskProcesLine.SetFilter(Value, '<>%1&<>%2', '', CompanyName);
        if TaskProcesLine.FindSet then begin
            if UseDialog then
                Window.Open(Text002);
            repeat
                if UseDialog then
                    Window.Update(7, TaskProcesLine.Value);
                if DataLogSubScriberMgt.GetNewRecordsCompany(TaskProcessor.Code, TaskProcesLine.Value, true,
                                                      NaviConnectSetup."Max Task Count per Batch", TempDataLogRecord) then begin
                    if UseDialog then
                        Window.Update(1, 10000);
                    //-NC2.07 [293599]
                    InsertTempTasks(TaskProcessor, TaskProcesLine.Value, TempDataLogRecord, TempTask);
                    //+NC2.07 [293599]
                    TempDataLogRecord.DeleteAll;
                    //-NC2.07 [293599]
                    DeleteDuplicates(TaskProcessor, TempTask);
                    InsertTasks(TempTask);
                    //+NC2.07 [293599]
                end;

                Clear(TempDataLogRecord);
                //-NC2.07 [293599]
                //CLEAR(TempTaskField);
                //+NC2.07 [293599]
                Clear(TempTask);
                TempDataLogRecord.DeleteAll;
                //-NC2.07 [293599]
                //TempTaskField.DELETEALL;
                //+NC2.07 [293599]
                TempTask.DeleteAll;
            until TaskProcesLine.Next = 0;

            if UseDialog then
                Window.Close;
        end;
    end;

    local procedure "--- Task Mgt."()
    begin
    end;

    procedure CleanTasks()
    var
        Task: Record "NPR Nc Task";
        TaskField: Record "NPR Nc Task Field";
        TaskOutput: Record "NPR Nc Task Output";
    begin
        Initialize();

        //-NC2.05 [280860]
        // CLEAR(TaskField);
        // TaskField.SETCURRENTKEY("Log Date",Processed);
        // TaskField.SETFILTER("Log Date",'<%1',CURRENTDATETIME - NaviConnectSetup."Keep Tasks for");
        // TaskField.SETRANGE(Processed,TRUE);
        // TaskField.DELETEALL;
        //+NC2.05 [280860]

        Clear(Task);
        Task.SetCurrentKey("Log Date", Processed);
        Task.SetFilter("Log Date", '<%1', CurrentDateTime - NaviConnectSetup."Keep Tasks for");
        Task.SetRange(Processed, true);
        Task.DeleteAll;

        Clear(Task);
        Clear(TaskField);
        if Task.FindFirst then;
        //-NC2.05 [280860]
        TaskField.SetCurrentKey("Task Entry No.");
        //+NC2.05 [280860]
        TaskField.SetFilter("Task Entry No.", '<%1', Task."Entry No.");
        //-NC2.05 [280860]
        //TaskField.DELETEALL;
        if not TaskField.IsEmpty then
            TaskField.DeleteAll;
        //+NC2.05 [280860]

        //-NC2.05 [280860]
        Clear(TaskField);
        TaskField.SetRange("Task Exists", false);
        if not TaskField.IsEmpty then
            TaskField.DeleteAll;
        //+NC2.05 [280860]

        //-NC2.14 [308107]
        TaskOutput.SetCurrentKey("Task Entry No.");
        TaskOutput.SetFilter("Task Entry No.", '<%1', Task."Entry No.");
        if not TaskOutput.IsEmpty then
            TaskField.DeleteAll;

        Clear(TaskOutput);
        TaskOutput.SetRange("Task Exists", false);
        if not TaskOutput.IsEmpty then
            TaskOutput.DeleteAll;
        //+NC2.14 [308107]
    end;

    local procedure InsertTasks(var TempTask: Record "NPR Nc Task" temporary)
    var
        DataLogField: Record "NPR Data Log Field";
        Task: Record "NPR Nc Task";
        TaskField: Record "NPR Nc Task Field";
        Counter: Integer;
        Total: Integer;
    begin
        //-NC2.07 [293599]
        //RecRef.GETTABLE(TempTask);
        //IF NOT RecRef.ISTEMPORARY THEN
        //  EXIT;
        //
        //RecRef.GETTABLE(TempTaskField);
        //IF NOT RecRef.ISTEMPORARY THEN
        //  EXIT;
        if not TempTask.IsTemporary then
            exit;
        //+NC2.07 [293599]

        Clear(TempTask);
        //-NC2.07 [293599]
        //CLEAR(TempTaskField);
        //+NC2.07 [293599]

        if UseDialog then begin
            Counter := 0;
            Total := TempTask.Count;
        end;

        //-NC2.07 [292577]
        DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
        //+NC2.07 [292577]

        if TempTask.FindSet then
            repeat
                if UseDialog then begin
                    Counter += 1;
                    Window.Update(4, Round((Counter / Total) * 10000, 1));
                end;
                Task.Init;
                Task := TempTask;
                Task."Entry No." := 0;
                Task.Insert(true);

                //-NC2.07 [292577]
                //TempTaskField.SETRANGE("Task Entry No.",TempTask."Entry No.");
                //IF TempTaskField.FINDSET THEN
                //  REPEAT
                //    TaskField.INIT;
                //    TaskField := TempTaskField;
                //    TaskField."Entry No." := 0;
                //    TaskField."Task Entry No." := Task."Entry No.";
                //    TaskField.INSERT(TRUE);
                //  UNTIL TempTaskField.NEXT = 0;
                DataLogField.SetRange("Table ID", TempTask."Table No.");
                DataLogField.SetRange("Data Log Record Entry No.", TempTask."Entry No.");
                if DataLogField.FindSet then
                    repeat
                        DataLogField.CalcFields("Field Name");
                        TaskField.Init;
                        TaskField."Entry No." := 0;
                        TaskField."Field No." := DataLogField."Field No.";
                        TaskField."Field Name" := DataLogField."Field Name";
                        TaskField."Previous Value" := DataLogField."Previous Field Value";
                        TaskField."New Value" := DataLogField."Field Value";
                        //-NC2.24 [378811]
                        if TempTask.Type in [TempTask.Type::Delete] then
                            TaskField."Previous Value" := TaskField."New Value";
                        //+NC2.24 [378811]
                        TaskField."Log Date" := DataLogField."Log Date";
                        TaskField."Task Entry No." := Task."Entry No.";
                        TaskField.Insert;
                    until DataLogField.Next = 0;
            //+NC2.07 [292577]
            until TempTask.Next = 0;
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
        //-NC2.07 [293599]
        //RecRef.GETTABLE(TempTask);
        //IF NOT RecRef.ISTEMPORARY THEN
        //  EXIT;
        //
        //RecRef.GETTABLE(TempTaskField);
        //IF NOT RecRef.ISTEMPORARY THEN
        //  EXIT;
        if not TempTask.IsTemporary then
            exit;
        //+NC2.07 [293599]

        i := 0;
        //-NC2.07 [293599]
        //j := 0;
        //+NC2.07 [293599]
        if (DataLogCompanyName <> '') and (DataLogCompanyName <> CompanyName) then
            DataLogField.ChangeCompany(DataLogCompanyName);
        if UseDialog then begin
            Counter := 0;
            Total := TempDataLogRecord.Count;
        end;
        if TempDataLogRecord.FindSet then begin
            DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
            TaskSetup.SetRange("Task Processor Code", TaskProcessor.Code);
            if TaskSetup.FindSet then
                repeat
                    TempTaskSetup.Init;
                    TempTaskSetup := TaskSetup;
                    TempTaskSetup.Insert;
                until TaskSetup.Next = 0;
            repeat
                if UseDialog then begin
                    Counter += 1;
                    Window.Update(2, Round((Counter / Total) * 10000, 1));
                end;
                TempTaskSetup.SetRange("Table No.", TempDataLogRecord."Table ID");
                TempTaskSetup.SetFilter("Task Processor Code", '<>%1', '');
                if TempTaskSetup.FindSet then
                    repeat
                        i += 1;
                        if UseDialog then begin
                            if i mod 10 = 0 then
                                Window.Update(5, i);
                        end;
                        TempDataLogRecord.CalcFields("Table Name");
                        //-NC2.08 [298597]
                        if not TempTask.Get(TempDataLogRecord."Entry No.") then begin
                            //+NC2.08 [298597]
                            TempTask.Init;
                            //-NC2.07 [293599]
                            //TempTask."Entry No." := i;
                            TempTask."Entry No." := TempDataLogRecord."Entry No.";
                            //+NC2.07 [293599]
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
                            //-NC2.12 [308107]
                            //TempTask."Table Name" := TempDataLogRecord."Table Name";
                            //+NC2.12 [308107]
                            RecordID := TempDataLogRecord."Record ID";
                            RecRef := RecordID.GetRecord;
                            TempTask."Record Position" := RecRef.GetPosition(false);
                            //-NC2.14 [320762]
                            TempTask."Record ID" := RecordID;
                            //+NC2.14 [320762]
                            TempTask."Log Date" := TempDataLogRecord."Log Date";
                            TempTask."Record Value" := CopyStr(DelStr(Format(RecRef.RecordId), 1, StrLen(RecRef.Name) + 2), 1, MaxStrLen(TempTask."Record Value"));
                            TempTask.Insert;
                            //-NC2.08 [298597]
                        end;
                    //+NC2.08 [298597]
                    //-NC2.07 [293599]
                    //DataLogField.SETRANGE("Table ID",TempDataLogRecord."Table ID");
                    //DataLogField.SETRANGE("Data Log Record Entry No.",TempDataLogRecord."Entry No.");
                    //DataLogField.SETRANGE("Field Value Changed");
                    //IF DataLogField.FINDSET THEN
                    //  REPEAT
                    //    j += 1;
                    //    DataLogField.CALCFIELDS("Field Name");
                    //    TempTaskField.INIT;
                    //    TempTaskField."Entry No." := j;
                    //    TempTaskField."Field No." := DataLogField."Field No.";
                    //    TempTaskField."Field Name" := DataLogField."Field Name";
                    //    TempTaskField."Previous Value" := DataLogField."Previous Field Value";
                    //    TempTaskField."New Value" := DataLogField."Field Value";
                    //    IF TempDataLogRecord."Type of Change" IN [TempDataLogRecord."Type of Change"::Delete,TempDataLogRecord."Type of Change"::Rename] THEN
                    //      TempTaskField."Previous Value" := TempTaskField."New Value";
                    //    TempTaskField."Log Date" := DataLogField."Log Date";
                    //    TempTaskField."Task Entry No." := TempTask."Entry No.";
                    //    TempTaskField.INSERT;
                    //  UNTIL DataLogField.NEXT = 0;
                    //+NC2.07 [293599]
                    until TempTaskSetup.Next = 0;
            until TempDataLogRecord.Next = 0;
        end;
    end;

    local procedure "--- Reduce Tasks"()
    begin
    end;

    local procedure DeleteDuplicates(TaskProcessor: Record "NPR Nc Task Processor"; var TempTask: Record "NPR Nc Task" temporary)
    var
        NewUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary;
        Checked: Boolean;
        DeleteTempTask: Boolean;
        UniqueTask: Boolean;
        Counter: Integer;
        Counter2: Integer;
        Total: Integer;
    begin
        Initialize();
        //-NC2.12 [308107]
        //CLEAR(NpXmlTriggerMgt);
        //TempDataLogRecord
        //+NC2.12 [308107]
        //-NC2.07 [293599]
        //RecRef.GETTABLE(TempTask);
        //IF NOT RecRef.ISTEMPORARY THEN
        //  EXIT;
        //
        //RecRef.GETTABLE(TempTaskField);
        //IF NOT RecRef.ISTEMPORARY THEN
        //  EXIT;
        if not TempTask.IsTemporary then
            exit;
        //+NC2.07 [293599]

        if UseDialog then begin
            Counter := 0;
            Total := TempTask.Count;
        end;

        Counter2 := 0;
        if TempTask.FindSet then
            repeat
                if UseDialog then begin
                    Counter += 1;
                    Window.Update(3, Round((Counter / Total) * 10000, 1));
                end;
                //-NC2.07 [293599]
                //DeleteTempTask := IsDuplicate(TaskProcessor,TempTask,TempTaskField);
                //-NC2.12 [308107]
                //DeleteTempTask := IsDuplicate(TaskProcessor,TempTask);
                Checked := false;
                UniqueTask := false;
                IsUniqueTask(TaskProcessor, TempTask, UniqueTaskBuffer, UniqueTask, Checked);
                if not Checked then begin
                    NewUniqueTaskBuffer.Init;
                    NewUniqueTaskBuffer."Table No." := TempTask."Table No.";
                    NewUniqueTaskBuffer."Task Processor Code" := TempTask."Task Processor Code";
                    NewUniqueTaskBuffer."Record Position" := TempTask."Record Position";
                    NewUniqueTaskBuffer."Codeunit ID" := 0;
                    NewUniqueTaskBuffer."Processing Code" := Format(TempTask.Type);
                    UniqueTask := ReqisterUniqueTask(NewUniqueTaskBuffer, UniqueTaskBuffer);
                end;
                DeleteTempTask := not UniqueTask;
                //+NC2.12 [308107]
                //+NC2.07 [293599]
                if DeleteTempTask then begin
                    if UseDialog then begin
                        Counter2 += 1;
                        if Counter2 mod 10 = 0 then
                            Window.Update(6, Counter2);
                    end;

                    //-NC2.07 [293599]
                    //CLEAR(TempTaskField);
                    //TempTaskField.SETRANGE("Task Entry No.",TempTask."Entry No.");
                    //TempTaskField.DELETEALL;
                    //+NC2.07 [293599]
                    TempTask.Delete;
                end;
            until TempTask.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure IsUniqueTask(TaskProcessor: Record "NPR Nc Task Processor"; var TempTask: Record "NPR Nc Task" temporary; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary; var IsUnique: Boolean; var Checked: Boolean)
    begin
    end;

    procedure ReqisterUniqueTask(NewUniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary; var UniqueTaskBuffer: Record "NPR Nc Unique Task Buffer" temporary) IsDuplicate: Boolean
    begin
        UniqueTaskBuffer.SetPosition(NewUniqueTaskBuffer.GetPosition(false));
        if UniqueTaskBuffer.Find then
            exit;

        UniqueTaskBuffer.Insert;
        exit(true);
    end;

    procedure "--- Task Restore"()
    begin
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
        //-NC2.14 [320762]
        Clear(RecRef);
        if (NcTask."Company Name" = '') or (NcTask."Company Name" = CompanyName) then
            RecRef.Open(NcTask."Table No.")
        else
            RecRef.Open(NcTask."Table No.", false, NcTask."Company Name");

        Position := NcTaskMgt.GetRecordPosition(NcTask);
        RecRef.SetPosition(Position);
        exit(RecRef.Find);
        //+NC2.14 [320762]
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

        //-NC2.14 [320762]
        //RecRefExisting.SETPOSITION(Task."Record Position");
        Position := GetRecordPosition(Task);
        RecRefExisting.SetPosition(Position);
        //+NC2.14 [320762]
        if RecRefExisting.Find then begin
            RecRef := RecRefExisting.Duplicate;

            Clear(TaskField);
            TaskField.SetRange("Task Entry No.", Task."Entry No.");
            //-NC2.01 [242551]
            TaskField.SetFilter("Previous Value", '<>%1', '');
            //+NC2.01 [242551]
            if TaskField.FindFirst then
                repeat
                    if Fields.Get(Task."Table No.", TaskField."Field No.") then begin
                        FieldRef := RecRef.Field(TaskField."Field No.");
                        AssignValue(FieldRef, TaskField."Previous Value");
                    end;
                until TaskField.Next = 0;
        end else begin
            //-NC2.07 [294737]
            //IF (Task."Company Name" = '') OR (Task."Company Name" = COMPANYNAME) THEN
            //  RecRef.OPEN(Task."Table No.")
            //ELSE
            //  RecRef.OPEN(Task."Table No.",FALSE,Task."Company Name");
            Clear(RecRef);
            RecRef.Open(Task."Table No.", true);
            //+NC2.07 [294737]
            RecRef.Init;
            //-NC2.14 [320762]
            //RecRef.SETPOSITION(Task."Record Position");
            RecRef.SetPosition(Position);
            //+NC2.14 [320762]

            Clear(TaskField);
            TaskField.SetRange("Task Entry No.", Task."Entry No.");
            if TaskField.FindFirst then
                repeat
                    if Fields.Get(Task."Table No.", TaskField."Field No.") then begin
                        FieldRef := RecRef.Field(TaskField."Field No.");
                        AssignValue(FieldRef, TaskField."Previous Value");
                    end;
                until TaskField.Next = 0;
            //-NC2.07 [294737]
            RecRef.Insert;
            //+NC2.07 [294737]
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
        //-NC2.08 [301296]
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
        RecRef := RecordID.GetRecord;

        RecordPosition := RecRef.GetPosition(false);
        RecRefExisting.SetPosition(RecordPosition);
        if RecRefExisting.Find then begin
            RecRef := RecRefExisting.Duplicate;

            DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
            DataLogField.SetRange("Table ID", DataLogRecord."Table ID");
            DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
            DataLogField.SetRange("Field Value Changed", true);
            if not DataLogField.FindSet then
                exit(true);

            repeat
                FieldRef := RecRef.Field(DataLogField."Field No.");
                AssignValue(FieldRef, DataLogField."Previous Field Value");
            until DataLogField.Next = 0;

            exit(true);
        end;
        Clear(RecRef);
        RecRef.Open(DataLogRecord."Table ID", true);
        RecRef.Init;
        RecRef.SetPosition(RecordPosition);
        DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
        DataLogField.SetRange("Table ID", DataLogRecord."Table ID");
        DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
        if not DataLogField.FindSet then
            exit(false);

        repeat
            FieldRef := RecRef.Field(DataLogField."Field No.");
            if DataLogField."Field Value Changed" then
                AssignValue(FieldRef, DataLogField."Previous Field Value")
            else
                AssignValue(FieldRef, DataLogField."Field Value");
        until DataLogField.Next = 0;

        RecRef.Insert;
        exit(true);
        //+NC2.08 [301296]
    end;

    procedure "--- UI"()
    begin
    end;

    procedure RunSourceCard(NaviConnectTask: Record "NPR Nc Task")
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
        RunCardExecuted: Boolean;
        Position: Text;
    begin
        RecRef.Open(NaviConnectTask."Table No.");
        //-NC2.14 [320762]
        //RecRef.SETPOSITION(NaviConnectTask."Record Position");
        Position := GetRecordPosition(NaviConnectTask);
        RecRef.SetPosition(Position);
        //+NC2.14 [320762]
        RecRef.SetRecFilter;

        RunSourceCardEvent(RecRef, RunCardExecuted);
        if RunCardExecuted then
            exit;

        PageMgt.PageRun(RecRef);
    end;

    [IntegrationEvent(false, false)]
    local procedure RunSourceCardEvent(var RecRef: RecordRef; var RunCardExecuted: Boolean)
    begin
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure Initialize()
    begin
        if not Initialized then begin
            NaviConnectSetup.Get;
            //-NC2.12 [308107]
            //NpXmlSetup.GET;
            //+NC2.12 [308107]
            Initialized := true;
        end;
    end;

    procedure RecExists(var RecRef: RecordRef; RecCompanyName: Text): Boolean
    var
        RecRefExists: RecordRef;
    begin
        //-NC2.07 [294737]
        if RecCompanyName = '' then
            RecRefExists.Open(RecRef.Number)
        else
            RecRefExists.Open(RecRef.Number, false, RecCompanyName);
        RecRefExists.SetPosition(RecRef.GetPosition(false));
        exit(RecRefExists.Find);
        //+NC2.07 [294737]
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
        //-NC2.14 [320762]
        RecordPosition := NcTask."Record Position";
        if Format(NcTask."Record ID") <> '' then begin
            RecordID := NcTask."Record ID";
            RecRef := RecordID.GetRecord;
            RecordPosition := RecRef.GetPosition(false);
        end;

        exit(RecordPosition);
        //+NC2.14 [320762]
    end;
}

