codeunit 6059898 "NPR Data Log Sub. Mgt."
{
    // DL1.07/MH/20150515  CASE 214248 Object created
    // DL1.08/MH/20150824  CASE 221341 Error with skipped records when max records is reached corrected
    // DL1.10/MHA/20160412 CASE 239117 Added function GetNewRecordsCompany() for intercompany Subscribers
    // DL9.14/BR /20170810 CASE 286526 Fixed error where the last line in each batch was not being sent.
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External

    Permissions = TableData "NPR Data Log Setup (Table)" = rimd,
                  TableData "NPR Data Log Record" = rimd;

    trigger OnRun()
    begin
        CleanDataLog();
    end;

    var
        Text001: Label 'Error creating %1 - %2. It already exists.';
        DataLogChecked: Boolean;
        DataLogActivated: Boolean;
        MonitoredTablesLoaded: Boolean;
        TempDataLogSetup: Record "NPR Data Log Setup (Table)" temporary;
        "--- Debug": Integer;
        StartTime: Time;

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

    procedure CleanDataLog()
    var
        DataLogField: Record "NPR Data Log Field";
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogRecord: Record "NPR Data Log Record";
        TimeStamp: DateTime;
    begin
        Clear(DataLogSetup);
        DataLogRecord.SetCurrentKey("Log Date", "Table ID");
        Clear(DataLogField);
        DataLogField.SetCurrentKey("Log Date", "Table ID");
        if DataLogSetup.FindSet then
            repeat
                TimeStamp := CurrentDateTime - DataLogSetup."Keep Log for";
                DataLogField.SetRange("Table ID", DataLogSetup."Table ID");
                DataLogField.SetFilter("Log Date", '<%1', TimeStamp);
                DataLogField.DeleteAll;

                DataLogRecord.SetRange("Table ID", DataLogSetup."Table ID");
                DataLogRecord.SetFilter("Log Date", '<%1', TimeStamp);
                DataLogRecord.DeleteAll;
                Commit;
            until DataLogSetup.Next = 0;

        TimeStamp := CreateDateTime(CalcDate('<-3M>', Today), 0T);
        DataLogField.SetRange("Table ID");
        DataLogField.SetFilter("Log Date", '<%1', TimeStamp);
        DataLogField.DeleteAll;

        DataLogRecord.SetRange("Table ID");
        DataLogRecord.SetFilter("Log Date", '<%1', TimeStamp);
        DataLogRecord.DeleteAll;
    end;

    procedure GetNewRecords(SubscriberCode: Code[30]; ModifySubscriber: Boolean; MaxRecords: Integer; var TempDataLogRecord: Record "NPR Data Log Record" temporary) NewRecords: Boolean
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        TempDataLogSubscriber: Record "NPR Data Log Subscriber" temporary;
        RecRef: RecordRef;
        LastLogEntryNo: BigInteger;
        TableFilter: Text[1024];
    begin
        RecRef.GetTable(TempDataLogRecord);
        if not RecRef.IsTemporary then
            exit(false);
        TempDataLogRecord.DeleteAll;
        TempDataLogSubscriber.DeleteAll;

        Clear(DataLogSubscriber);
        DataLogSubscriber.SetRange(Code, SubscriberCode);
        //-DL1.10
        DataLogSubscriber.SetFilter("Company Name", '%1|%2', '', CompanyName);
        //+DL1.10
        if not DataLogSubscriber.FindSet then
            exit(false);

        repeat
            //-DL1.10
            //InsertNewTempRecords(DataLogSubscriber."Table ID",DataLogSubscriber."Last Log Entry No.",MaxRecords,TempDataLogRecord);
            InsertNewTempRecords('', DataLogSubscriber."Table ID", DataLogSubscriber."Last Log Entry No.", MaxRecords, TempDataLogRecord);
            //+DL1.10
            if ModifySubscriber then begin
                TempDataLogSubscriber.Init;
                TempDataLogSubscriber := DataLogSubscriber;
                TempDataLogSubscriber."Last Date Modified" := CurrentDateTime;
                TempDataLogSubscriber.Insert;
                Clear(TempDataLogRecord);
            end;
        until DataLogSubscriber.Next = 0;

        if MaxRecords > 0 then begin
            if TempDataLogRecord.Count > MaxRecords then begin
                if MaxRecords = 1 then
                    TempDataLogRecord.FindFirst
                else begin
                    TempDataLogRecord.FindSet;
                    TempDataLogRecord.Next(MaxRecords - 1);
                end;
                TempDataLogRecord.SetFilter("Entry No.", '>%1', TempDataLogRecord."Entry No.");
                TempDataLogRecord.DeleteAll;
                //-DL1.08
                if TempDataLogSubscriber.FindSet then
                    repeat
                        Clear(TempDataLogRecord);
                        TempDataLogRecord.SetRange("Table ID", TempDataLogSubscriber."Table ID");
                        if TempDataLogRecord.FindLast then;
                        TempDataLogSubscriber."Last Log Entry No." := TempDataLogRecord."Entry No.";
                        TempDataLogSubscriber.Modify;
                    until TempDataLogSubscriber.Next = 0;
                //+DL1.08
            end;
            Clear(TempDataLogRecord);
        end;

        if not ModifySubscriber then
            exit(TempDataLogRecord.FindSet);

        DataLogSubscriber.FindSet;
        repeat
            //-DL1.10
            //TempDataLogSubscriber.GET(DataLogSubscriber.Code,DataLogSubscriber."Table ID");
            TempDataLogSubscriber.Get(DataLogSubscriber.Code, DataLogSubscriber."Table ID", DataLogSubscriber."Company Name");
            //+DL1.10
            //-DL1.08
            //DataLogSubscriber.TRANSFERFIELDS(TempDataLogSubscriber);
            //DataLogSubscriber.MODIFY(TRUE);
            if TempDataLogSubscriber."Last Log Entry No." > 0 then begin
                DataLogSubscriber."Last Log Entry No." := TempDataLogSubscriber."Last Log Entry No.";
                DataLogSubscriber."Last Date Modified" := TempDataLogSubscriber."Last Date Modified";
                DataLogSubscriber.Modify(true);
            end;
            //+DL1.08
            TempDataLogSubscriber.Delete;
        until DataLogSubscriber.Next = 0;

        Clear(TempDataLogRecord);
        exit(TempDataLogRecord.FindSet);
    end;

    procedure GetNewRecordsCompany(SubscriberCode: Code[30]; SubscriberCompanyName: Text[30]; ModifySubscriber: Boolean; MaxRecords: Integer; var TempDataLogRecord: Record "NPR Data Log Record" temporary) NewRecords: Boolean
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        TempDataLogSubscriber: Record "NPR Data Log Subscriber" temporary;
        RecRef: RecordRef;
        LastLogEntryNo: BigInteger;
        TableFilter: Text[1024];
    begin
        //-DL1.10
        RecRef.GetTable(TempDataLogRecord);
        if not RecRef.IsTemporary then
            exit(false);
        TempDataLogRecord.DeleteAll;
        TempDataLogSubscriber.DeleteAll;

        Clear(DataLogSubscriber);
        DataLogSubscriber.SetRange(Code, SubscriberCode);
        DataLogSubscriber.SetRange("Company Name", SubscriberCompanyName);
        if not DataLogSubscriber.FindSet then
            exit(false);

        repeat
            InsertNewTempRecords(SubscriberCompanyName, DataLogSubscriber."Table ID",
                                 DataLogSubscriber."Last Log Entry No.", MaxRecords, TempDataLogRecord);
            if ModifySubscriber then begin
                TempDataLogSubscriber.Init;
                TempDataLogSubscriber := DataLogSubscriber;
                TempDataLogSubscriber."Last Date Modified" := CurrentDateTime;
                TempDataLogSubscriber.Insert;
                Clear(TempDataLogRecord);
            end;
        until DataLogSubscriber.Next = 0;

        if MaxRecords > 0 then begin
            if TempDataLogRecord.Count > MaxRecords then begin
                if MaxRecords = 1 then
                    TempDataLogRecord.FindFirst
                else begin
                    TempDataLogRecord.FindSet;
                    TempDataLogRecord.Next(MaxRecords - 1);
                end;
                TempDataLogRecord.SetFilter("Entry No.", '>%1', TempDataLogRecord."Entry No.");
                TempDataLogRecord.DeleteAll;
                if TempDataLogSubscriber.FindSet then
                    repeat
                        Clear(TempDataLogRecord);
                        TempDataLogRecord.SetRange("Table ID", TempDataLogSubscriber."Table ID");
                        if TempDataLogRecord.FindLast then;
                        TempDataLogSubscriber."Last Log Entry No." := TempDataLogRecord."Entry No.";
                        TempDataLogSubscriber.Modify;
                    until TempDataLogSubscriber.Next = 0;
            end;
            Clear(TempDataLogRecord);
        end;

        if not ModifySubscriber then
            exit(TempDataLogRecord.FindSet);

        DataLogSubscriber.FindSet;
        repeat
            TempDataLogSubscriber.Get(DataLogSubscriber.Code, DataLogSubscriber."Table ID", DataLogSubscriber."Company Name");
            if TempDataLogSubscriber."Last Log Entry No." > 0 then begin
                DataLogSubscriber."Last Log Entry No." := TempDataLogSubscriber."Last Log Entry No.";
                DataLogSubscriber."Last Date Modified" := TempDataLogSubscriber."Last Date Modified";
                DataLogSubscriber.Modify(true);
            end;
            TempDataLogSubscriber.Delete;
        until DataLogSubscriber.Next = 0;

        Clear(TempDataLogRecord);
        exit(TempDataLogRecord.FindSet);
        //+DL1.10
    end;

    local procedure InsertNewTempRecords(SubscriberCompanyName: Text[30]; TableID: Integer; var LastLogEntryNo: BigInteger; MaxRecords: Integer; var TempDataLogRecord: Record "NPR Data Log Record" temporary)
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        RecRef: RecordRef;
        Counter: Integer;
        Continue: Integer;
    begin
        Counter := 0;
        Clear(DataLogRecord);
        //-DL1.10
        if (CompanyName <> '') and (SubscriberCompanyName <> CompanyName) then
            if not DataLogRecord.ChangeCompany(SubscriberCompanyName) then
                exit;
        //+DL1.10
        DataLogRecord.SetCurrentKey("Table ID");
        DataLogRecord.SetRange("Table ID", TableID);
        DataLogRecord.SetFilter("Entry No.", '>%1', LastLogEntryNo);
        if not DataLogRecord.FindSet then
            exit;

        repeat
            Counter += 1;
            TempDataLogRecord.Init;
            TempDataLogRecord := DataLogRecord;
            TempDataLogRecord.Insert;
            //-DL9.14 [286526]
            LastLogEntryNo := DataLogRecord."Entry No.";
        //+DL9.14 [286526]
        until (DataLogRecord.Next = 0) or ((MaxRecords > 0) and (Counter >= MaxRecords));
        //-DL9.14 [286526]
        //LastLogEntryNo := DataLogRecord."Entry No.";
        //+DL9.14 [286526]
    end;

    procedure ProcessNewRecords(SubscriberCode: Code[10])
    var
        TempDataLogRecord: Record "NPR Data Log Record" temporary;
    begin
        TempDataLogRecord.DeleteAll;
        if GetNewRecords(SubscriberCode, true, 0, TempDataLogRecord) then begin
            if TempDataLogRecord.FindSet then
                repeat
                    ProcessRecord(SubscriberCode, false, TempDataLogRecord."Entry No.");
                until TempDataLogRecord.Next = 0;
        end;
    end;

    procedure ProcessRecord(SubscriberCode: Code[10]; DirectDataProcessing: Boolean; var RecordEntryNo: BigInteger)
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        DataLogRecord: Record "NPR Data Log Record";
    begin
        if not DataLogRecord.Get(RecordEntryNo) then
            exit;

        Clear(DataLogSubscriber);
        DataLogSubscriber.SetFilter(Code, SubscriberCode);
        DataLogSubscriber.SetFilter("Data Processing Codeunit ID", '>%1', 0);
        DataLogSubscriber.SetFilter("Direct Data Processing", '%1', DirectDataProcessing);
        if not DataLogSubscriber.FindSet then
            exit;

        repeat
            CODEUNIT.Run(DataLogSubscriber."Data Processing Codeunit ID", DataLogRecord);
        until DataLogSubscriber.Next = 0;
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
        DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
        if not DataLogField.FindSet then begin
            if Previous then
                exit(false);
            RecordID := DataLogRecord."Record ID";
            RecRef := RecordID.GetRecord;
            exit(RecRef.Find);
        end;

        Clear(RecRef);
        RecRef.Open(DataLogRecord."Table ID");
        RecRef.Init;
        repeat
            FieldRef := RecRef.Field(DataLogField."Field No.");
            if Previous and DataLogField."Field Value Changed" then
                AssignValue(FieldRef, DataLogField."Previous Field Value")
            else
                AssignValue(FieldRef, DataLogField."Field Value");
        until DataLogField.Next = 0;
        exit(true);
    end;
}

