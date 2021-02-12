codeunit 6059899 "NPR Data Log Management"
{
    Permissions = TableData "NPR Data Log Setup (Table)" = rimd,
                  TableData "NPR Data Log Record" = rimd;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TempDataLogSetup: Record "NPR Data Log Setup (Table)" temporary;
        TempDataLogSetupField: Record "NPR Data Log Setup (Field)" temporary;
        TempDataLogSubscriber: Record "NPR Data Log Subscriber" temporary;
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        DataLogChecked: Boolean;
        DataLogActivated: Boolean;
        MonitoredTablesLoaded: Boolean;
        DataLogDisabled: Boolean;
        Text001: Label 'Error creating %1 - %2. It already exists.';

        //--- Debug ---
        StartTime: Time;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterGetDatabaseTableTriggerSetup', '', true, false)]
    procedure GetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    var
        DataLogSetupTable: Record "NPR Data Log Setup (Table)";
    begin
        if CompanyName = '' then
            exit;

        if not DataLogChecked then begin
            DataLogChecked := true;
            DataLogActivated := not DataLogSetupTable.IsEmpty;
        end;

        if not DataLogActivated then
            exit;

        if not MonitoredTablesLoaded then begin
            MonitoredTablesLoaded := true;
            LoadMonTables;
        end;

        if TempDataLogSetup.Get(TableId) then begin
            OnDatabaseInsert := TempDataLogSetup."Log Insertion" <> TempDataLogSetup."Log Insertion"::" ";
            OnDatabaseModify := TempDataLogSetup."Log Modification" <> TempDataLogSetup."Log Modification"::" ";
            OnDatabaseDelete := TempDataLogSetup."Log Deletion" <> TempDataLogSetup."Log Deletion"::" ";
            OnDatabaseRename := OnDatabaseInsert or OnDatabaseModify or OnDatabaseDelete;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseInsert', '', true, false)]
    procedure OnDatabaseInsert(RecRef: RecordRef)
    var
        TimeStamp: DateTime;
        RecordEntryNo: BigInteger;
    begin
        if DataLogDisabled then
            exit;
        if RecRef.IsTemporary then
            exit;

        TimeStamp := CurrentDateTime;
        if not MonitoredTablesLoaded then begin
            MonitoredTablesLoaded := true;
            LoadMonTables;
        end;
        if (not TempDataLogSetup.Get(RecRef.Number)) or (TempDataLogSetup."Log Insertion" = TempDataLogSetup."Log Insertion"::" ") then
            exit;

        RecordEntryNo := InsertDataRecord(RecRef, TimeStamp, 0);
        if TempDataLogSetup."Log Insertion" = TempDataLogSetup."Log Insertion"::Detailed then
            InsertDataFields(RecRef, RecordEntryNo, TimeStamp, false);

        ProcessDataLogRecord(RecordEntryNo, RecRef.Number);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseModify', '', true, false)]
    procedure OnDatabaseModify(RecRef: RecordRef)
    var
        TimeStamp: DateTime;
        RecordEntryNo: BigInteger;
    begin
        if DataLogDisabled then
            exit;
        if RecRef.IsTemporary then
            exit;

        TimeStamp := CurrentDateTime;
        if not MonitoredTablesLoaded then begin
            MonitoredTablesLoaded := true;
            LoadMonTables;
        end;
        if (not TempDataLogSetup.Get(RecRef.Number)) or (TempDataLogSetup."Log Modification" = TempDataLogSetup."Log Modification"::" ") then
            exit;

        if OnlyIgroredFieldsModified(RecRef) then
            exit;

        RecordEntryNo := InsertDataRecord(RecRef, TimeStamp, 1);
        if TempDataLogSetup."Log Modification" in [TempDataLogSetup."Log Modification"::Detailed, TempDataLogSetup."Log Modification"::Changes] then
            InsertDataFields(RecRef, RecordEntryNo, TimeStamp, TempDataLogSetup."Log Modification" = TempDataLogSetup."Log Modification"::Changes);

        ProcessDataLogRecord(RecordEntryNo, RecRef.Number);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseDelete', '', true, false)]
    procedure OnDatabaseDelete(RecRef: RecordRef)
    var
        FieldRef1: FieldRef;
        SkipDeletion: Boolean;
        TimeStamp: DateTime;
        RecordEntryNo: BigInteger;
    begin
        if DataLogDisabled then
            exit;
        if RecRef.IsTemporary then
            exit;

        TimeStamp := CurrentDateTime;
        if not MonitoredTablesLoaded then begin
            MonitoredTablesLoaded := true;
            LoadMonTables;
        end;
        if (not TempDataLogSetup.Get(RecRef.Number)) or (TempDataLogSetup."Log Deletion" = TempDataLogSetup."Log Deletion"::" ") then
            exit;

        RecordEntryNo := InsertDataRecord(RecRef, TimeStamp, 3);
        if TempDataLogSetup."Log Deletion" = TempDataLogSetup."Log Deletion"::Detailed then
            InsertDataFields(RecRef, RecordEntryNo, TimeStamp, false);

        ProcessDataLogRecord(RecordEntryNo, RecRef.Number);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseRename', '', true, false)]
    procedure OnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef)
    var
        TimeStamp: DateTime;
        RecordEntryNo: BigInteger;
        PreviousRecordEntryNo: BigInteger;
    begin
        if DataLogDisabled then
            exit;
        if RecRef.IsTemporary then
            exit;

        TimeStamp := CurrentDateTime;
        if not MonitoredTablesLoaded then begin
            MonitoredTablesLoaded := true;
            LoadMonTables;
        end;
        if not TempDataLogSetup.Get(RecRef.Number) then
            exit;
        if (TempDataLogSetup."Log Insertion" = TempDataLogSetup."Log Insertion"::" ") and
           (TempDataLogSetup."Log Modification" = TempDataLogSetup."Log Modification"::" ") and
           (TempDataLogSetup."Log Deletion" = TempDataLogSetup."Log Deletion"::" ") then
            exit;

        PreviousRecordEntryNo := InsertDataRecord(xRecRef, TimeStamp, 3);
        ProcessDataLogRecord(PreviousRecordEntryNo, xRecRef.Number);
        RecordEntryNo := InsertDataRecordRename(RecRef, xRecRef, TimeStamp, 2);
        InsertPKDataFields(RecRef, xRecRef, RecordEntryNo, TimeStamp, false);

        ProcessDataLogRecord(RecordEntryNo, RecRef.Number);
    end;

    local procedure ProcessDataLogRecord(RecordEntryNo: BigInteger; TableId: Integer)
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
    begin
        Clear(TempDataLogSubscriber);
        TempDataLogSubscriber.SetRange("Table ID", TableId);
        TempDataLogSubscriber.SetFilter("Company Name", '=%1', '');
        TempDataLogSubscriber.SetFilter("Data Processing Codeunit ID", '>%1', 0);
        if TempDataLogSubscriber.IsEmpty then
            exit;

        if not DataLogRecord.Get(RecordEntryNo) then
            exit;

        TempDataLogSubscriber.FindSet();
        repeat
            DataLogSubscriberMgt.ProcessRecord(TempDataLogSubscriber, DataLogRecord);
        until TempDataLogSubscriber.Next() = 0;
    end;

    //--- Setup ---

    procedure InitializeIntegrationRecords(TableID: Integer)
    var
        RecRef: RecordRef;
    begin
        LoadMonTables;
        with RecRef do begin
            Open(TableID, false);
            if FindSet(false) then
                repeat
                    OnDatabaseInsert(RecRef);
                until Next = 0;
            Close;
        end;
    end;

    local procedure IsIntegrationRecord(TableID: Integer): Boolean
    begin
        exit(TempDataLogSetup.Get(TableID));
    end;

    local procedure LoadMonTables()
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
    begin
        TempDataLogSetup.DeleteAll;
        if DataLogSetup.FindSet then
            repeat
                TempDataLogSetup.Init;
                TempDataLogSetup := DataLogSetup;
                TempDataLogSetup.Insert;
            until DataLogSetup.Next = 0;

        Clear(TempDataLogSubscriber);
        TempDataLogSubscriber.SetFilter("Company Name", '=%1', '');
        IF DataLogSubscriber.FindSet() THEN
            repeat
                TempDataLogSubscriber.Init();
                TempDataLogSubscriber := DataLogSubscriber;
                TempDataLogSubscriber.Insert();
            until DataLogSubscriber.Next() = 0;
    end;

    procedure DisableDataLog(Disable: Boolean)
    begin
        DataLogDisabled := Disable;
    end;

    //--- Database ---

    local procedure InsertDataFields(var RecRef: RecordRef; RecordEntryNo: BigInteger; LastModified: DateTime; LogChanges: Boolean)
    var
        DataLogField: Record "NPR Data Log Field";
        "Field": Record "Field";
        FieldRef: FieldRef;
        FieldRefInit: FieldRef;
        xFieldRef: FieldRef;
        RecRefInit: RecordRef;
        xRecRef: RecordRef;
        CheckValueChanged: Boolean;
        FieldValueChanged: Boolean;
    begin
        CheckValueChanged := false;
        FieldValueChanged := false;
        if LogChanges then begin
            xRecRef := RecRef.Duplicate;
            CheckValueChanged := xRecRef.Find;
        end;
        RecRefInit.Open(RecRef.Number);

        Field.Reset;
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        if Field.FindSet then
            repeat
                FieldRef := RecRef.Field(Field."No.");
                if not IsIgnoredField(RecRef.Number, FieldRef.Number) then begin
                    FieldRefInit := RecRefInit.Field(Field."No.");
                    if CheckValueChanged then begin
                        xFieldRef := xRecRef.Field(Field."No.");
                        FieldValueChanged := (xFieldRef.Value <> FieldRef.Value) and (UpperCase(Format(xFieldRef.Class)) <> 'FLOWFIELD');
                    end;
                    if (Format(FieldRef.Value, 0, 9) <> Format(FieldRefInit.Value, 0, 9)) or (FieldValueChanged) then begin
                        if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                            FieldRef.CalcField;
                        DataLogField.Init;
                        DataLogField."Entry No." := 0;
                        DataLogField."Table ID" := RecRef.Number;
                        DataLogField."Log Date" := LastModified;
                        DataLogField."Field No." := FieldRef.Number;
                        DataLogField."Field Value" := Format(FieldRef.Value, 0, 9);
                        DataLogField."Data Log Record Entry No." := RecordEntryNo;
                        DataLogField."Field Value Changed" := FieldValueChanged;
                        if FieldValueChanged then
                            DataLogField."Previous Field Value" := Format(xFieldRef.Value, 0, 9);
                        DataLogField.Insert;
                    end;
                end;
            until Field.Next = 0;

        RecRefInit.Close;
    end;

    local procedure InsertPKDataFields(var RecRef: RecordRef; var XRecRef: RecordRef; RecordEntryNo: BigInteger; LastModified: DateTime; LogChanges: Boolean)
    var
        DataLogField: Record "NPR Data Log Field";
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
        XKeyRef: KeyRef;
        XFieldRef: FieldRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        XKeyRef := XRecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);
            XFieldRef := XKeyRef.FieldIndex(i);
            DataLogField.Init;
            DataLogField."Entry No." := 0;
            DataLogField."Table ID" := RecRef.Number;
            DataLogField."Log Date" := LastModified;
            DataLogField."Field No." := FieldRef.Number;
            DataLogField."Field Value" := Format(FieldRef.Value, 0, 9);
            DataLogField."Previous Field Value" := Format(XFieldRef.Value, 0, 9);
            DataLogField."Data Log Record Entry No." := RecordEntryNo;
            DataLogField.Insert;
        end;
    end;

    local procedure InsertDataRecord(var RecRef: RecordRef; LastModified: DateTime; TypeOfChange: Option Insert,Modify,Rename,Delete) RecordEntryNo: BigInteger
    var
        DataLogRecord: Record "NPR Data Log Record";
    begin
        with DataLogRecord do begin
            Init;
            "Entry No." := 0;
            "Record ID" := RecRef.RecordId;
            "Table ID" := RecRef.Number;
            "Log Date" := LastModified;
            "Type of Change" := TypeOfChange;
            "User ID" := UserId;
            Insert;
        end;

        exit(DataLogRecord."Entry No.");
    end;

    local procedure InsertDataRecordRename(var RecRef: RecordRef; var XRecRef: RecordRef; LastModified: DateTime; TypeOfChange: Option Insert,Modify,Rename,Delete) RecordEntryNo: BigInteger
    var
        DataLogRecord: Record "NPR Data Log Record";
    begin
        with DataLogRecord do begin
            Init;
            "Entry No." := 0;
            "Record ID" := RecRef.RecordId;
            "Old Record ID" := XRecRef.RecordId;
            "Table ID" := RecRef.Number;
            "Log Date" := LastModified;
            "Type of Change" := TypeOfChange;
            "User ID" := UserId;
            Insert;
        end;

        exit(DataLogRecord."Entry No.");
    end;

    local procedure OnlyIgroredFieldsModified(var RecRef: RecordRef): Boolean
    var
        DataLogSetupField: Record "NPR Data Log Setup (Field)";
        "Field": Record "Field";
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
    begin
        if NoIgnoreListIsSetupForTable(RecRef.Number) then
            exit(false);

        xRecRef := RecRef.Duplicate;
        if not xRecRef.Find then
            exit(false);

        Field.SetRange(TableNo, RecRef.Number);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetRange(Class, Field.Class::Normal);
        if Field.FindSet then
            repeat
                FldRef := RecRef.Field(Field."No.");
                xFldRef := xRecRef.Field(Field."No.");
                if xFldRef.Value <> FldRef.Value then begin
                    if not IsIgnoredField(RecRef.Number, FldRef.Number) then
                        exit(false);
                end;
            until Field.Next = 0;

        exit(true);
    end;

    local procedure NoIgnoreListIsSetupForTable(TableID: Integer): Boolean
    var
        DataLogSetupField: Record "NPR Data Log Setup (Field)";
    begin
        if TempDataLogSetupField.Get(TableID, 0) then
            exit(true);

        TempDataLogSetupField.SetRange("Table ID", TableID);
        if not TempDataLogSetup.IsEmpty then
            exit(false);

        DataLogSetupField.SetRange("Table ID", TableID);
        DataLogSetupField.SetRange("Ignore Modification", true);
        if DataLogSetupField.IsEmpty then begin
            TempDataLogSetupField.Init();
            TempDataLogSetupField."Table ID" := TableID;
            TempDataLogSetupField."Field No." := 0;
            TempDataLogSetupField.Insert();
            exit(true);
        end else
            exit(false);
    end;

    local procedure IsIgnoredField(TableID: Integer; FieldNo: Integer): Boolean
    var
        DataLogSetupField: Record "NPR Data Log Setup (Field)";
    begin
        if NoIgnoreListIsSetupForTable(TableID) then
            exit(false);

        if not TempDataLogSetupField.get(TableID, FieldNo) then begin
            if not DataLogSetupField.get(TableID, FieldNo) then begin
                TempDataLogSetupField.Init();
                TempDataLogSetupField."Table ID" := TableID;
                TempDataLogSetupField."Field No." := FieldNo;
            end else
                TempDataLogSetupField := DataLogSetupField;
            TempDataLogSetupField.Insert();
        end;
        exit(TempDataLogSetupField."Ignore Modification");
    end;
}