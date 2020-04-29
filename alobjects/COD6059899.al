codeunit 6059899 "Data Log Management"
{
    // DL1.00/MHA /20140801              NP-AddOn: Data Log
    //                                   - This codeunit contains functions for logging Records Changes.
    // DL1.01/MHA /20140820              Added/Updated Data Processing Functions
    // DL1.02/MHA /20140820              Added Subscriber functionality for retrieving new Records.
    //                                   - Removed TempDataLogSubscriber and replaced with real subscribers as they may change frequently due to Last Log Entry No.
    // DL1.03/MHA /20140909  CASE 184907 Added Update of Subscribers Last Date Modified when getting new records.
    // DL1.04/MHA /20141017  CASE 184907 Refactored GetNewRecords functions in order to retrieve new records chronologically.
    // DL1.05/MHA /20141128  CASE 188079 Refactored GetNewRecords from handling each table one at a time to get all new records in one batch.
    //                                   - Renamed function GetNewRecordsFromTableID() to InsertNewTempRecords().
    //                                   - Added Extra filter to OnDatabaseTriggers as they might be loaded from other modules.
    // DL1.06/MHA /20150126  CASE 203653 Changed functions for getting new records according to MaxCount.
    // DL1.07/MHA /20150515  CASE 207589 Moved subscriber functionality to Data Log Subscriber Mgt.
    // DL1.09/MHA /20151124  CASE 227978 All and only primary keys are logged during rename.
    // DL1.12/TS  /20170317  CASE 269142 Delete Previous Record after renaming of primary key
    // DL1.13/MHA /20170801  CASE 285518 Temporary Tables should not be logged
    // DL1.15/MHA /20171123  CASE 297502 Added function DisableDataLog()
    // NPR5.38/LS  /20171218 CASE 300124 Set property OnMissingLicense to Skip on all Functions
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.48/MHA /20190213  CASE 344618 Fields with ObsoleteState = Removed should be ignored

    Permissions = TableData "Data Log Setup (Table)"=rimd,
                  TableData "Data Log Record"=rimd;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Error creating %1 - %2. It already exists.';
        DataLogSubscriberMgt: Codeunit "Data Log Subscriber Mgt.";
        DataLogChecked: Boolean;
        DataLogActivated: Boolean;
        MonitoredTablesLoaded: Boolean;
        TempDataLogSetup: Record "Data Log Setup (Table)" temporary;
        DataLogDisabled: Boolean;
        "--- Debug": Integer;
        StartTime: Time;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterGetDatabaseTableTriggerSetup', '', true, false)]
    procedure GetDatabaseTableTriggerSetup(TableId: Integer;var OnDatabaseInsert: Boolean;var OnDatabaseModify: Boolean;var OnDatabaseDelete: Boolean;var OnDatabaseRename: Boolean)
    var
        DataLogSetupTable: Record "Data Log Setup (Table)";
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
        //-DL1.15 [297502]
        if DataLogDisabled then
          exit;
        //+DL1.15 [297502]
        //-DL1.13 [285518]
        if RecRef.IsTemporary then
          exit;
        //+DL1.13 [285518]
        TimeStamp := CurrentDateTime;
        if not MonitoredTablesLoaded then begin
          MonitoredTablesLoaded := true;
          LoadMonTables;
        end;
        if (not TempDataLogSetup.Get(RecRef.Number)) or (TempDataLogSetup."Log Insertion" = TempDataLogSetup."Log Insertion"::" ") then
          exit;

        RecordEntryNo := InsertDataRecord(RecRef,TimeStamp,0);
        if TempDataLogSetup."Log Insertion" = TempDataLogSetup."Log Insertion"::Detailed then
          InsertDataFields(RecRef,RecordEntryNo,TimeStamp,false);

        //-DL1.07
        //ProcessRecord('',TRUE,RecordEntryNo);
        DataLogSubscriberMgt.ProcessRecord('',true,RecordEntryNo);
        //+DL1.07
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseModify', '', true, false)]
    procedure OnDatabaseModify(RecRef: RecordRef)
    var
        TimeStamp: DateTime;
        RecordEntryNo: BigInteger;
    begin
        //-DL1.15 [297502]
        if DataLogDisabled then
          exit;
        //+DL1.15 [297502]
        //-DL1.13 [285518]
        if RecRef.IsTemporary then
          exit;
        //+DL1.13 [285518]
        TimeStamp := CurrentDateTime;
        if not MonitoredTablesLoaded then begin
          MonitoredTablesLoaded := true;
          LoadMonTables;
        end;
        if (not TempDataLogSetup.Get(RecRef.Number)) or (TempDataLogSetup."Log Modification" = TempDataLogSetup."Log Modification"::" ")
        then
          exit;

        RecordEntryNo := InsertDataRecord(RecRef,TimeStamp,1);
        if TempDataLogSetup."Log Modification" in [TempDataLogSetup."Log Modification"::Detailed,TempDataLogSetup."Log Modification"::
        Changes] then
          InsertDataFields(RecRef,RecordEntryNo,TimeStamp,TempDataLogSetup."Log Modification" = TempDataLogSetup."Log Modification"::
        Changes);

        //-DL1.07
        //ProcessRecord('',TRUE,RecordEntryNo);
        DataLogSubscriberMgt.ProcessRecord('',true,RecordEntryNo);
        //+DL1.07
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseDelete', '', true, false)]
    procedure OnDatabaseDelete(RecRef: RecordRef)
    var
        FieldRef1: FieldRef;
        SkipDeletion: Boolean;
        TimeStamp: DateTime;
        RecordEntryNo: BigInteger;
    begin
        //-DL1.15 [297502]
        if DataLogDisabled then
          exit;
        //+DL1.15 [297502]
        //-DL1.13 [285518]
        if RecRef.IsTemporary then
          exit;
        //+DL1.13 [285518]
        TimeStamp := CurrentDateTime;
        if not MonitoredTablesLoaded then begin
          MonitoredTablesLoaded := true;
          LoadMonTables;
        end;
        if (not TempDataLogSetup.Get(RecRef.Number)) or (TempDataLogSetup."Log Deletion" = TempDataLogSetup."Log Deletion"::" ") then
          exit;

        RecordEntryNo := InsertDataRecord(RecRef,TimeStamp,3);
        if TempDataLogSetup."Log Deletion" = TempDataLogSetup."Log Deletion"::Detailed then
          InsertDataFields(RecRef,RecordEntryNo,TimeStamp,false);
        //-DL1.07
        //ProcessRecord('',TRUE,RecordEntryNo);
        DataLogSubscriberMgt.ProcessRecord('',true,RecordEntryNo);
        //+DL1.07
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterOnDatabaseRename', '', true, false)]
    procedure OnDatabaseRename(RecRef: RecordRef;xRecRef: RecordRef)
    var
        TimeStamp: DateTime;
        RecordEntryNo: BigInteger;
        PreviousRecordEntryNo: BigInteger;
    begin
        //-DL1.15 [297502]
        if DataLogDisabled then
          exit;
        //+DL1.15 [297502]
        //-DL1.13 [285518]
        if RecRef.IsTemporary then
          exit;
        //+DL1.13 [285518]
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

        //-DL1.12 [269142]
        PreviousRecordEntryNo :=  InsertDataRecord(xRecRef,TimeStamp,3);
        DataLogSubscriberMgt.ProcessRecord('',true,PreviousRecordEntryNo );
        //+DL1.12 [269142]
        RecordEntryNo := InsertDataRecordRename(RecRef,xRecRef,TimeStamp,2);
        //-DL1.09
        //IF (TempDataLogSetup."Log Deletion" = TempDataLogSetup."Log Deletion"::Detailed) OR
        //   (TempDataLogSetup."Log Modification" = TempDataLogSetup."Log Modification"::Detailed) OR
        //   (TempDataLogSetup."Log Insertion" = TempDataLogSetup."Log Insertion"::Detailed) THEN
        //  InsertDataFields(XRecRef,RecordEntryNo,TimeStamp,FALSE)
        //ELSE
        //  InsertPKDataFields(RecRef,XRecRef, RecordEntryNo,TimeStamp,FALSE);
        InsertPKDataFields(RecRef,xRecRef, RecordEntryNo,TimeStamp,false);
        //+DL1.09

        //-DL1.07
        //ProcessRecord('',TRUE,RecordEntryNo);
        DataLogSubscriberMgt.ProcessRecord('',true,RecordEntryNo);
        //+DL1.07
    end;

    procedure "--- Setup"()
    begin
    end;

    [Scope('Personalization')]
    procedure InitializeIntegrationRecords(TableID: Integer)
    var
        RecRef: RecordRef;
    begin
        LoadMonTables;
        with RecRef do begin
          Open(TableID,false);
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
        DataLogSetup: Record "Data Log Setup (Table)";
        DataLogSubscriber: Record "Data Log Subscriber";
    begin
        TempDataLogSetup.DeleteAll;
        if DataLogSetup.FindSet then
          repeat
            TempDataLogSetup.Init;
            TempDataLogSetup := DataLogSetup;
            TempDataLogSetup.Insert;
          until DataLogSetup.Next = 0;
    end;

    [Scope('Personalization')]
    procedure DisableDataLog(Disable: Boolean)
    begin
        //-DL1.15 [297502]
        DataLogDisabled := Disable;
        //+DL1.15 [297502]
    end;

    local procedure "--- Database"()
    begin
    end;

    local procedure InsertDataFields(var RecRef: RecordRef;RecordEntryNo: BigInteger;LastModified: DateTime;LogChanges: Boolean)
    var
        DataLogField: Record "Data Log Field";
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
        Field.SetRange(TableNo,RecRef.Number);
        //-NPR5.48 [344618]
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        //+NPR5.48 [344618]
        if Field.FindSet then
          repeat
            FieldRef := RecRef.Field(Field."No.");
            FieldRefInit := RecRefInit.Field(Field."No.");
            if CheckValueChanged then begin
              xFieldRef := xRecRef.Field(Field."No.");
              FieldValueChanged := (xFieldRef.Value <> FieldRef.Value) and (UpperCase(Format(xFieldRef.Class)) <> 'FLOWFIELD');
            end;
            if (Format(FieldRef.Value,0,9) <> Format(FieldRefInit.Value,0,9)) or (FieldValueChanged) then begin
              if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                FieldRef.CalcField;
              DataLogField.Init;
              DataLogField."Entry No." := 0;
              DataLogField."Table ID" := RecRef.Number;
              DataLogField."Log Date" := LastModified;
              DataLogField."Field No." := FieldRef.Number;
              DataLogField."Field Value" := Format(FieldRef.Value,0,9);
              DataLogField."Data Log Record Entry No." := RecordEntryNo;
              DataLogField."Field Value Changed" := FieldValueChanged;
              if FieldValueChanged then
                DataLogField."Previous Field Value" := Format(xFieldRef.Value,0,9);
              DataLogField.Insert;
            end;
          until Field.Next = 0;

        RecRefInit.Close;
    end;

    local procedure InsertPKDataFields(var RecRef: RecordRef;var XRecRef: RecordRef;RecordEntryNo: BigInteger;LastModified: DateTime;LogChanges: Boolean)
    var
        DataLogField: Record "Data Log Field";
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
          DataLogField."Field Value" := Format(FieldRef.Value,0,9);
          DataLogField."Previous Field Value" := Format(XFieldRef.Value,0,9);
          DataLogField."Data Log Record Entry No." := RecordEntryNo;
          DataLogField.Insert;
        end;
    end;

    local procedure InsertDataRecord(var RecRef: RecordRef;LastModified: DateTime;TypeOfChange: Option Insert,Modify,Rename,Delete) RecordEntryNo: BigInteger
    var
        DataLogRecord: Record "Data Log Record";
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

    local procedure InsertDataRecordRename(var RecRef: RecordRef;var XRecRef: RecordRef;LastModified: DateTime;TypeOfChange: Option Insert,Modify,Rename,Delete) RecordEntryNo: BigInteger
    var
        DataLogRecord: Record "Data Log Record";
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
}

