﻿codeunit 6059898 "NPR Data Log Sub. Mgt."
{
    Access = Public;

    Permissions = TableData "NPR Data Log Setup (Table)" = rimd,
                  TableData "NPR Data Log Record" = rimd;

    trigger OnRun()
    begin
        CleanDataLog();
    end;


    local procedure AssignValue(var FieldRef: FieldRef; Value: Text[250])
    var
        DateFormulaValue: DateFormula;
        TextValue: Text[250];
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        BigIntegerValue: BigInteger;
        DateTimeValue: DateTime;
    begin
        case LowerCase(Format(FieldRef.Type)) of
            'code', 'text':
                begin
                    TextValue := Value;
                    FieldRef.Value := TextValue;
                end;
            'decimal':
                begin
                    Evaluate(DecimalValue, Value, 9);
                    FieldRef.Value := DecimalValue;
                end;
            'boolean':
                begin
                    Evaluate(BooleanValue, Value, 9);
                    FieldRef.Value := BooleanValue;
                end;
            'dateformula':
                begin
                    Evaluate(DateFormulaValue, Value, 9);
                    FieldRef.Value := DateFormulaValue;
                end;
            'biginteger':
                begin
                    Evaluate(BigIntegerValue, Value, 9);
                    FieldRef.Value := BigIntegerValue;
                end;
            'datetime':
                begin
                    Evaluate(DateTimeValue, Value, 9);
                    FieldRef.Value := DateTimeValue;
                end;
            'option', 'integer':
                begin
                    Evaluate(IntegerValue, Value, 9);
                    FieldRef.Value := IntegerValue;
                end;
            'date':
                begin
                    Evaluate(DateValue, Value, 9);
                    FieldRef.Value := DateValue;
                end;
            'time':
                begin
                    Evaluate(TimeValue, Value, 9);
                    FieldRef.Value := TimeValue;
                end;
        end;
    end;

    internal procedure CleanDataLog()
    var
        DataLogField: Record "NPR Data Log Field";
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogRecord: Record "NPR Data Log Record";
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
        TimeStamp: DateTime;
    begin
        Clear(DataLogSetup);
        DataLogRecord.SetCurrentKey("Log Date", "Table ID");
        Clear(DataLogField);
        DataLogField.SetCurrentKey("Log Date", "Table ID");
        if DataLogSetup.FindSet() then
            repeat
                TimeStamp := CurrentDateTime - DataLogSetup."Keep Log for";

                DataLogProcessingEntry.SetRange("Table Number", DataLogSetup."Table ID");
                DataLogProcessingEntry.SetFilter("Inserted at", '<%1', TimeStamp);
                if DataLogProcessingEntry.FindFirst() then begin
                    DataLogProcessingEntry.DeleteAll();
                    Commit();
                end;

                DataLogField.SetRange("Table ID", DataLogSetup."Table ID");
                DataLogField.SetFilter("Log Date", '<%1', TimeStamp);
                DataLogField.DeleteAll();

                DataLogRecord.SetRange("Table ID", DataLogSetup."Table ID");
                DataLogRecord.SetFilter("Log Date", '<%1', TimeStamp);
                DataLogRecord.DeleteAll();
                Commit();
            until DataLogSetup.Next() = 0;

        TimeStamp := CreateDateTime(CalcDate('<-3M>', Today), 0T);

        DataLogProcessingEntry.SetRange("Table Number", DataLogSetup."Table ID");
        DataLogProcessingEntry.SetFilter("Inserted at", '<%1', TimeStamp);
        if DataLogProcessingEntry.FindFirst() then begin
            DataLogProcessingEntry.DeleteAll();
            Commit();
        end;

        DataLogField.SetRange("Table ID");
        DataLogField.SetFilter("Log Date", '<%1', TimeStamp);
        DataLogField.DeleteAll();

        DataLogRecord.SetRange("Table ID");
        DataLogRecord.SetFilter("Log Date", '<%1', TimeStamp);
        DataLogRecord.DeleteAll();
    end;

    internal procedure GetNewRecords(SubscriberCode: Code[30]; ModifySubscriber: Boolean; MaxRecords: Integer; var TempDataLogRecord: Record "NPR Data Log Record" temporary) NewRecords: Boolean
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        TempDataLogSubscriber: Record "NPR Data Log Subscriber" temporary;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempDataLogRecord);
        if not RecRef.IsTemporary then
            exit(false);
        TempDataLogRecord.DeleteAll();
        TempDataLogSubscriber.DeleteAll();

        Clear(DataLogSubscriber);
        DataLogSubscriber.SetRange(Code, SubscriberCode);
        DataLogSubscriber.SetFilter("Company Name", '%1|%2', '', CompanyName);
        if not DataLogSubscriber.FindSet() then
            exit(false);

        repeat
            InsertNewTempRecords('', DataLogSubscriber."Table ID", DataLogSubscriber."Last Log Entry No.", MaxRecords, TempDataLogRecord);
            if ModifySubscriber then begin
                TempDataLogSubscriber.Init();
                TempDataLogSubscriber := DataLogSubscriber;
                TempDataLogSubscriber."Last Date Modified" := CurrentDateTime;
                TempDataLogSubscriber.Insert();
                Clear(TempDataLogRecord);
            end;
        until DataLogSubscriber.Next() = 0;

        if MaxRecords > 0 then begin
            if TempDataLogRecord.Count() > MaxRecords then begin
                if MaxRecords = 1 then
                    TempDataLogRecord.FindFirst()
                else begin
                    TempDataLogRecord.FindSet();
                    TempDataLogRecord.Next(MaxRecords - 1);
                end;
                TempDataLogRecord.SetFilter("Entry No.", '>%1', TempDataLogRecord."Entry No.");
                TempDataLogRecord.DeleteAll();
                if TempDataLogSubscriber.FindSet() then
                    repeat
                        Clear(TempDataLogRecord);
                        TempDataLogRecord.SetRange("Table ID", TempDataLogSubscriber."Table ID");
                        if TempDataLogRecord.FindLast() then;
                        TempDataLogSubscriber."Last Log Entry No." := TempDataLogRecord."Entry No.";
                        TempDataLogSubscriber.Modify();
                    until TempDataLogSubscriber.Next() = 0;
            end;
            Clear(TempDataLogRecord);
        end;

        if not ModifySubscriber then
            exit(TempDataLogRecord.FindSet());

        DataLogSubscriber.FindSet();
        repeat
            TempDataLogSubscriber.Get(DataLogSubscriber.Code, DataLogSubscriber."Table ID", DataLogSubscriber."Company Name");
            if TempDataLogSubscriber."Last Log Entry No." > 0 then begin
                DataLogSubscriber."Last Log Entry No." := TempDataLogSubscriber."Last Log Entry No.";
                DataLogSubscriber."Last Date Modified" := TempDataLogSubscriber."Last Date Modified";
                DataLogSubscriber.Modify(true);
            end;
            TempDataLogSubscriber.Delete();
        until DataLogSubscriber.Next() = 0;

        Clear(TempDataLogRecord);
        exit(TempDataLogRecord.FindSet());
    end;

    internal procedure GetNewRecordsCompany(SubscriberCode: Code[30]; SubscriberCompanyName: Text[30]; ModifySubscriber: Boolean; MaxRecords: Integer; var TempDataLogRecord: Record "NPR Data Log Record" temporary) NewRecords: Boolean
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        TempDataLogSubscriber: Record "NPR Data Log Subscriber" temporary;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempDataLogRecord);
        if not RecRef.IsTemporary then
            exit(false);
        TempDataLogRecord.DeleteAll();
        TempDataLogSubscriber.DeleteAll();

        Clear(DataLogSubscriber);
        DataLogSubscriber.SetRange(Code, SubscriberCode);
        DataLogSubscriber.SetRange("Company Name", SubscriberCompanyName);
        if not DataLogSubscriber.FindSet() then
            exit(false);

        repeat
            InsertNewTempRecords(SubscriberCompanyName, DataLogSubscriber."Table ID",
                                 DataLogSubscriber."Last Log Entry No.", MaxRecords, TempDataLogRecord);
            if ModifySubscriber then begin
                TempDataLogSubscriber.Init();
                TempDataLogSubscriber := DataLogSubscriber;
                TempDataLogSubscriber."Last Date Modified" := CurrentDateTime;
                TempDataLogSubscriber.Insert();
                Clear(TempDataLogRecord);
            end;
        until DataLogSubscriber.Next() = 0;

        if MaxRecords > 0 then begin
            if TempDataLogRecord.Count() > MaxRecords then begin
                if MaxRecords = 1 then
                    TempDataLogRecord.FindFirst()
                else begin
                    TempDataLogRecord.FindSet();
                    TempDataLogRecord.Next(MaxRecords - 1);
                end;
                TempDataLogRecord.SetFilter("Entry No.", '>%1', TempDataLogRecord."Entry No.");
                TempDataLogRecord.DeleteAll();
                if TempDataLogSubscriber.FindSet() then
                    repeat
                        Clear(TempDataLogRecord);
                        TempDataLogRecord.SetRange("Table ID", TempDataLogSubscriber."Table ID");
                        if TempDataLogRecord.FindLast() then;
                        TempDataLogSubscriber."Last Log Entry No." := TempDataLogRecord."Entry No.";
                        TempDataLogSubscriber.Modify();
                    until TempDataLogSubscriber.Next() = 0;
            end;
            Clear(TempDataLogRecord);
        end;

        if not ModifySubscriber then
            exit(TempDataLogRecord.FindSet());

        DataLogSubscriber.FindSet();
        repeat
            TempDataLogSubscriber.Get(DataLogSubscriber.Code, DataLogSubscriber."Table ID", DataLogSubscriber."Company Name");
            if TempDataLogSubscriber."Last Log Entry No." > 0 then begin
                DataLogSubscriber."Last Log Entry No." := TempDataLogSubscriber."Last Log Entry No.";
                DataLogSubscriber."Last Date Modified" := TempDataLogSubscriber."Last Date Modified";
                DataLogSubscriber.Modify(true);
            end;
            TempDataLogSubscriber.Delete();
        until DataLogSubscriber.Next() = 0;

        Clear(TempDataLogRecord);
        exit(TempDataLogRecord.FindSet());
    end;

    local procedure InsertNewTempRecords(SubscriberCompanyName: Text[30]; TableID: Integer; var LastLogEntryNo: BigInteger; MaxRecords: Integer; var TempDataLogRecord: Record "NPR Data Log Record" temporary)
    var
        DataLogRecord: Record "NPR Data Log Record";
        Counter: Integer;
    begin
        Counter := 0;
        Clear(DataLogRecord);
        if (CompanyName <> '') and (SubscriberCompanyName <> CompanyName) then
            if not DataLogRecord.ChangeCompany(SubscriberCompanyName) then
                exit;
        DataLogRecord.SetCurrentKey("Table ID");
        DataLogRecord.SetRange("Table ID", TableID);
        DataLogRecord.SetFilter("Entry No.", '>%1', LastLogEntryNo);
        if (DataLogRecord.IsEmpty()) then
            exit;

        DataLogRecord.FindSet();
        repeat
            Counter += 1;
            TempDataLogRecord.Init();
            TempDataLogRecord := DataLogRecord;
            TempDataLogRecord.Insert();
            LastLogEntryNo := DataLogRecord."Entry No.";
        until (DataLogRecord.Next() = 0) or ((MaxRecords > 0) and (Counter >= MaxRecords));
    end;

    internal procedure ProcessRecord(DataLogSubscriber: Record "NPR Data Log Subscriber"; DataLogRecord: Record "NPR Data Log Record")
    var
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
        DirectProcessing: Boolean;
    begin
        if DataLogSubscriber."Data Processing Codeunit ID" <= 0 then
            exit;

        DataLogProcessingEntry.Init();
        DataLogProcessingEntry."Entry No." := 0;
        DataLogProcessingEntry."Inserted at" := CurrentDateTime();
        DataLogProcessingEntry."Subscriber Code" := DataLogSubscriber.Code;
        DataLogProcessingEntry."Table Number" := DataLogSubscriber."Table ID";
        DataLogProcessingEntry."Data Log Entry No." := DataLogRecord."Entry No.";
        DataLogProcessingEntry."Data Log Record Value" := CopyStr(format(DataLogRecord."Record ID"), 1, MaxStrLen(DataLogProcessingEntry."Data Log Record Value"));
        DataLogProcessingEntry.Insert(true);

        // Certain license types in Business Central (at the time of development; device users and delegated admins)
        // cannot create tasks on the task scheduler. This causes a runtime error.
        // To ensure that we avoid that, we will force a user not being able to create a task to use
        // direct processing.
        DirectProcessing := ((DataLogSubscriber."Direct Data Processing") or (not TaskScheduler.CanCreateTask()));

        if (DirectProcessing) then
            Codeunit.Run(Codeunit::"NPR Data Log Processing Mgt.", DataLogProcessingEntry)
        else
            TaskScheduler.CreateTask(
              Codeunit::"NPR Data Log Processing Mgt.", Codeunit::"NPR Data Log Proces. Err. Mgt.", true, CompanyName(),
              DataLogRecord."Log Date" + (DataLogSubscriber."Delayed Data Processing (sec)" * 1000), DataLogProcessingEntry.RecordId);
    end;

    procedure RestoreRecordToRecRef(RecordEntryNo: BigInteger; Previous: Boolean; var RecRef: RecordRef): Boolean
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        FieldRef: FieldRef;
        RecordID: RecordID;
    begin
        if not DataLogRecord.Get(RecordEntryNo) then
            exit(false);

        DataLogField.SetCurrentKey("Table ID", "Data Log Record Entry No.");
        DataLogField.SetRange("Table ID", DataLogRecord."Table ID");
        DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
        DataLogField.SetAutoCalcFields("Obsolete State");
        if not DataLogField.FindSet() then begin
            if Previous then
                exit(false);
            RecordID := DataLogRecord."Record ID";
            RecRef := RecordID.GetRecord();
            exit(RecRef.Find());
        end;

        Clear(RecRef);
        RecRef.Open(DataLogRecord."Table ID");
        RecRef.Init();
        repeat
            if DataLogField."Obsolete State" <> DataLogField."Obsolete State"::Removed then begin
                FieldRef := RecRef.Field(DataLogField."Field No.");
                if Previous and DataLogField."Field Value Changed" then
                    AssignValue(FieldRef, DataLogField."Previous Field Value")
                else
                    AssignValue(FieldRef, DataLogField."Field Value");
            end;
        until DataLogField.Next() = 0;
        exit(true);
    end;
}

