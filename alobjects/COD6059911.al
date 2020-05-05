codeunit 6059911 "Delete Old Entries"
{
    // Objects that doesnt exists in all customers databases can be added, but without direct reference. Use the "DeleteByRecRef" method
    // Currently theese objects are implemented:
    // 
    // Object No    Object Name                 Field to filter on    Field Name
    // 6060030      Webshop - Changelog         14                    Import Date
    // 6059824      Web - Import Log            5                     Date
    // 
    // Filterstring to use 6014407|6060030|6059824|6014403|6059904|6059898|6059899
    // 
    // TQ1.22/JDH/20150109 CASE 202183 Changed references to Recref for tables that are not in all our customers databases
    // TQ1.25/JDH/20150417 CASE 211583 Delete IDS Data Packages
    // TQ1.26/TS/20150716  CASE 211152 Added code to check if Data Log Table is available
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // NPR5.29/MMV /20161201 CASE 259957 Removed invalid table ID references blocking data log from being cleaned.
    // NPR5.53/BHR/20190917 CASE 326663 Rework logic to delete data based on table size

    TableNo = "Task Line";

    trigger OnRun()
    var
        Company: Record Company;
        CompView: Text[1024];
        Obj: Record "Object";
    begin
        CheckForParameters(Rec);

        CompView := GetTableView(DATABASE::Company,CompView);
        Company.SetView(CompView);
        if Company.FindSet then repeat
          AddMessageLine2OutputLog(StrSubstNo(Text004, Company.Name));
          Commit;

          //-NPR5.53 [326663]
          //max size of data to delete
          MaxSizeToDelete := GetParameterInt('DEL MAX SIZE DATA_KB');
          OriginalMaxSizeToDelete := MaxSizeToDelete ;
          //+NPR5.53 [326663]

          //Credit Card Transaction
          if GetParameterBool('DEL CREDIT CARD LOG') then
            DeleteCreditCardLog(Rec, Company.Name, GetParameterCalcDate('CREDIT CARD LOG DATE'));

          if not TimeSlotStillValid then
            exit;

          //Webshop Changelog
          //-TQ1.22
          //IF GetParameterBool('DEL WEBSHP CHANGELOG') THEN
          //  DeleteWebShopChangeLog(Rec, Company.Name, GetParameterCalcDate('WEBSHP CHNGELOG DATE'));
          if Obj.Get(Obj.Type::Table,'',6060030) then begin
            if GetParameterBool('DEL WEBSHP CHANGELOG') then
              DeleteByRecRef(Rec, Company.Name, GetParameterCalcDate('WEBSHP CHNGELOG DATE'), 6060030, 14,false);
          end;
          //+TQ1.22

          if not TimeSlotStillValid then
            exit;

          //-NPR5.29 [259957]
          //Webshop Importlog
          //-TQ1.22
          //IF GetParameterBool('DEL WEB IMPORTLOG') THEN
          //  DeleteWebImportLog(Rec, Company.Name, GetParameterCalcDate('WEB IMPORTLOG DATE'));
        //  IF Obj.GET(Obj.Type::Table,'',6059824) THEN BEGIN
        //    IF GetParameterBool('DEL WEB IMPORTLOG') THEN
        //      DeleteByRecRef(Rec, Company.Name, GetParameterCalcDate('WEB IMPORTLOG DATE'), 6059824, 5,FALSE);
        //  END;
        //  //+TQ1.22
        //  IF NOT TimeSlotStillValid THEN
        //    EXIT;
          //+NPR5.29 [259957]


          //IDS Data Package
          //-TQ1.25
          if Obj.Get(Obj.Type::Table,'',6059924) then begin
            if GetParameterBool('DEL IDS PACK') then
              DeleteIDSPackages(Rec, Company.Name, GetParameterCalcDate('IDS PACKAGE DATE'));
          end;

          if not TimeSlotStillValid then
            exit;
          //+TQ1.25

          //TaskLog
          if GetParameterBool('DEL TASKQUEUE LOG') then
            DeleteTaskQueueLog(Rec, Company.Name);

          if not TimeSlotStillValid then
            exit;

          //Data Log
          //-NPR5.29 [259957]
          //-TQ1.26
          //IF Obj.GET(Obj.Type::Table,'',6059824) THEN BEGIN
          //+TQ1.26
          //+NPR5.29 [259957]
          if GetParameterBool('DEL DATA LOG') then
            DeleteDataLog(Rec, Company.Name);
          //-NPR5.29 [259957]
          //END;
          //+NPR5.29 [259957]
          if not TimeSlotStillValid then
            exit;

          //Backup Audit Roll
          if GetParameterBool('BACKUP AUDIT ROLL') then
            BackupAuditRoll(Rec, Company.Name, GetParameterCalcDate('BCK AUDIT ROLL DATE'));

        until Company.Next = 0;
    end;

    var
        Text001: Label 'No Parameters found. Do you with to have empty Parameters added?';
        Text002: Label 'Empty Parameters added. Please fill in the parameters before run this task again';
        NoOfEntries: Integer;
        StartTime: Time;
        Text003: Label ' - %1 records deleted in table %2';
        Text004: Label 'Deleting Entries in %1';
        Text005: Label 'Company: Name=';
        TableInformation: Record "Table Information";
        CurrentTotRecordSize: Decimal;
        MaxSizeToDelete: Decimal;
        NoOfRowsToDeleteAllowed: Integer;
        Counter: Integer;
        OriginalMaxSizeToDelete: Integer;

    procedure CheckForParameters(TaskLine: Record "Task Line")
    var
        DateForm: DateFormula;
        Obj: Record "Object";
    begin
        if TaskLine.ParametersExists then
          exit;

        if GuiAllowed then
          if not Confirm(Text001) then
            exit;

        TaskLine."Table 1 No." := 2000000006;
        Evaluate(TaskLine."Table 1 Filter", Text005 + CompanyName);

        TaskLine.Modify;

        //-NPR5.53 [326663]
        //max size of data to delete
        TaskLine.InsertParameter('DEL MAX SIZE DATA_KB',4);
        TaskLine.SetParameterInt('DEL MAX SIZE DATA_KB',500000);
        //+NPR5.53 [326663]

        //Credit Card Transaction
        TaskLine.InsertParameter('DEL CREDIT CARD LOG',6);
        TaskLine.InsertParameter('CREDIT CARD LOG DATE',7);
        Evaluate(DateForm, '<-5Y>');
        TaskLine.SetParameterDateFormula('CREDIT CARD LOG DATE', DateForm);

        //Webshop ChangeLog
        if Obj.Get(Obj.Type::Table,'',6060030) then begin
          TaskLine.InsertParameter('DEL WEBSHP CHANGELOG',6);
          TaskLine.InsertParameter('WEBSHP CHNGELOG DATE',7);
          Evaluate(DateForm, '<-5Y>');
          TaskLine.SetParameterDateFormula('WEBSHP CHNGELOG DATE', DateForm);
        end;

        //Webshop ImportLog
        TaskLine.InsertParameter('DEL WEB IMPORTLOG',6);
        TaskLine.InsertParameter('WEB IMPORTLOG DATE',7);
        Evaluate(DateForm, '<-5Y>');
        TaskLine.SetParameterDateFormula('WEB IMPORTLOG DATE', DateForm);

        //IDS Data Package
        if Obj.Get(Obj.Type::Table,'',6059924) then begin
          TaskLine.InsertParameter('DEL IDS PACK',6);
          TaskLine.InsertParameter('IDS PACKAGE DATE',7);
          Evaluate(DateForm, '<-6M>');
          TaskLine.SetParameterDateFormula('IDS PACKAGE DATE', DateForm);
        end;

        //TaskLog
        TaskLine.InsertParameter('DEL TASKQUEUE LOG',6);

        //DataLog
        TaskLine.InsertParameter('DEL DATA LOG',6);


        //Audit Roll
        TaskLine.InsertParameter('BACKUP AUDIT ROLL',6);
        TaskLine.InsertParameter('BCK AUDIT ROLL DATE',7);
        Evaluate(DateForm, '<-5Y>');
        TaskLine.SetParameterDateFormula('BCK AUDIT ROLL DATE', DateForm);


        Commit;
        Error(Text002);
    end;

    procedure WriteLogAndCommit(TaskLine: Record "Task Line";TableName: Text[60])
    begin
        TaskLine.AddMessageLine2OutputLog(StrSubstNo(Text003, NoOfEntries, TableName));
        Commit;
    end;

    procedure DeleteCreditCardLog(TaskLine: Record "Task Line";CompanyToDelete: Text[50];LastDateToDelete: Date)
    var
        CreditCardTrans: Record "EFT Receipt";
        RecRef: RecordRef;
    begin
        if LastDateToDelete = 0D then
          exit;

        if CompanyToDelete = '' then
          exit;

        CreditCardTrans.ChangeCompany(CompanyToDelete);
        CreditCardTrans.SetRange(Date,0D, LastDateToDelete);

        //Set the Best Key
        RecRef.GetTable(CreditCardTrans);
        RecRef.CurrentKeyIndex(GetBestKey(RecRef));
        RecRef.SetTable(CreditCardTrans);

        StartTime := Time;
        NoOfEntries := CreditCardTrans.Count;
        //-NPR5.53 [326663
        NoOfRowsToDeleteAllowed := 0;
        Counter := 0;
        NoOfRowsToDeleteAllowed := GetNoOfRowsToDelete(CompanyToDelete,DATABASE::"EFT Receipt",NoOfEntries);
        if (OriginalMaxSizeToDelete <> 0) then begin
         if (NoOfRowsToDeleteAllowed <> 0)  then begin
           NoOfEntries := NoOfRowsToDeleteAllowed;
           if CreditCardTrans.FindSet then
              repeat
                CreditCardTrans.Delete;
                Counter += 1;
                CreditCardTrans.Next;
              until Counter = NoOfRowsToDeleteAllowed;
          end;
         end else
        //+NPR5.53 [326663]
        CreditCardTrans.DeleteAll;
        WriteLogAndCommit(TaskLine, CreditCardTrans.TableCaption);
    end;

    procedure DeleteTaskQueueLog(TaskLine: Record "Task Line";CompanyToDelete: Text[50])
    var
        TaskLog: Record "Task Log (Task)";
        TaskBatch: Record "Task Batch";
        TaskLine2: Record "Task Line";
        LastDateTimeToDelete: DateTime;
        TaskOutputLog: Record "Task Output Log";
    begin
        if CompanyToDelete = '' then
          exit;

        TaskBatch.ChangeCompany(CompanyToDelete);
        TaskLine2.ChangeCompany(CompanyToDelete);
        TaskLog.ChangeCompany(CompanyToDelete);
        TaskOutputLog.ChangeCompany(CompanyToDelete);

        TaskLog.SetCurrentKey("Journal Template Name","Journal Batch Name","Line No.");
        TaskOutputLog.SetCurrentKey("Journal Template Name","Journal Batch Name","Journal Line No.");

        if TaskBatch.FindSet then repeat
          TaskLine2.SetRange("Journal Template Name", TaskBatch."Journal Template Name");
          TaskLine2.SetRange("Journal Batch Name", TaskBatch.Name);
          if TaskLine2.FindSet then repeat
            if TaskLine2."Delete Log After" = 0 then
              TaskLine2."Delete Log After" := TaskBatch."Delete Log After";

            if TaskLine2."Delete Log After" <> 0 then begin
              LastDateTimeToDelete := CurrentDateTime - Abs(TaskLine2."Delete Log After");
              TaskLog.SetRange("Journal Template Name", TaskLine2."Journal Template Name");
              TaskLog.SetRange("Journal Batch Name", TaskLine2."Journal Batch Name");
              TaskLog.SetRange("Line No.", TaskLine2."Line No.");
              TaskLog.SetRange("Starting Time", 0DT, LastDateTimeToDelete);
              StartTime := Time;
              NoOfEntries := TaskLog.Count;
              //-NPR5.53 [326663]
              NoOfRowsToDeleteAllowed := 0;
              Counter := 0;
              NoOfRowsToDeleteAllowed := GetNoOfRowsToDelete(CompanyToDelete,DATABASE::"Task Log (Task)",NoOfEntries);
              if (OriginalMaxSizeToDelete <> 0) then begin
                if (NoOfRowsToDeleteAllowed <> 0)  then begin
                  NoOfEntries := NoOfRowsToDeleteAllowed;
                   if TaskLog.FindSet then
                      repeat
                        TaskLog.Delete;
                        Counter += 1;
                        TaskLog.Next;
                      until Counter = NoOfRowsToDeleteAllowed;
                end;
               end else
              //+NPR5.53 [326663]
              TaskLog.DeleteAll;
              if NoOfEntries <> 0 then
                WriteLogAndCommit(TaskLine, TaskLog.TableCaption);

              TaskOutputLog.SetRange("Journal Template Name", TaskLine2."Journal Template Name");
              TaskOutputLog.SetRange("Journal Batch Name", TaskLine2."Journal Batch Name");
              TaskOutputLog.SetRange("Journal Line No.", TaskLine2."Line No.");
              TaskOutputLog.SetRange("Import DateTime", 0DT, LastDateTimeToDelete);
              NoOfEntries := TaskOutputLog.Count;
              //-NPR5.53 [326663]
              NoOfRowsToDeleteAllowed := 0;
              Counter := 0;
              NoOfRowsToDeleteAllowed := GetNoOfRowsToDelete(CompanyToDelete,DATABASE::"Task Output Log",NoOfEntries);
              if (OriginalMaxSizeToDelete <> 0) then begin
               if (NoOfRowsToDeleteAllowed <> 0) then begin
                 NoOfEntries := NoOfRowsToDeleteAllowed;
                   if TaskOutputLog.FindSet then
                      repeat
                        TaskOutputLog.Delete;
                        Counter += 1;
                        TaskOutputLog.Next;
                      until Counter = NoOfRowsToDeleteAllowed;
                 end;
               end else
              //+NPR5.53 [326663]
              TaskOutputLog.DeleteAll;
              if NoOfEntries <> 0 then
                WriteLogAndCommit(TaskLine, TaskOutputLog.TableCaption);

            end;
          until TaskLine2.Next = 0;
        until TaskBatch.Next = 0;
    end;

    procedure DeleteDataLog(TaskLine: Record "Task Line";CompanyToDelete: Text[50])
    var
        DataLogSetup: Record "Data Log Setup (Table)";
        DataLogField: Record "Data Log Field";
        DataLogRecord: Record "Data Log Record";
        TimeStamp: DateTime;
        RecRef: RecordRef;
    begin
        if CompanyToDelete = '' then
          exit;

        DataLogSetup.ChangeCompany(CompanyToDelete);
        DataLogField.ChangeCompany(CompanyToDelete);
        DataLogRecord.ChangeCompany(CompanyToDelete);

        if DataLogSetup.FindSet then repeat
          if DataLogSetup."Keep Log for" = 0 then
            TimeStamp := CreateDateTime(CalcDate('<-1M>',Today),0T)
          else
            TimeStamp := CurrentDateTime - DataLogSetup."Keep Log for";

          DataLogField.SetCurrentKey("Table ID","Data Log Record Entry No.");
          DataLogField.SetRange("Table ID",DataLogSetup."Table ID");
          DataLogField.SetFilter("Log Date",'<%1',TimeStamp);

          NoOfEntries := DataLogField.Count;
          //-NPR5.53 [326663]
          NoOfRowsToDeleteAllowed := 0;
          Counter := 0;
          NoOfRowsToDeleteAllowed := GetNoOfRowsToDelete(CompanyToDelete,DATABASE::"Data Log Field",NoOfEntries);
          if (OriginalMaxSizeToDelete <> 0) then begin
            if (NoOfRowsToDeleteAllowed <> 0) then begin
              NoOfEntries := NoOfRowsToDeleteAllowed;
              if DataLogField.FindSet then
                repeat
                  DataLogField.Delete;
                  Counter += 1;
                   DataLogField.Next;
                until Counter = NoOfRowsToDeleteAllowed;
            end;
          end else
          //+NPR5.53 [326663]
          DataLogField.DeleteAll;
          if NoOfEntries <> 0 then
            WriteLogAndCommit(TaskLine, DataLogField.TableCaption);

          DataLogRecord.SetCurrentKey("Table ID");
          DataLogRecord.SetRange("Table ID",DataLogSetup."Table ID");
          DataLogRecord.SetFilter("Log Date",'<%1',TimeStamp);

          NoOfEntries += DataLogRecord.Count;
            //-NPR5.53 [326663]
          NoOfRowsToDeleteAllowed := 0;
          Counter := 0;
          NoOfRowsToDeleteAllowed := GetNoOfRowsToDelete(CompanyToDelete,DATABASE::"Data Log Record",NoOfEntries);
          if (OriginalMaxSizeToDelete <> 0) then begin
            if (NoOfRowsToDeleteAllowed <> 0) then begin
              NoOfEntries := NoOfRowsToDeleteAllowed;
              if DataLogRecord.FindSet then
                repeat
                  DataLogRecord.Delete;
                  Counter += 1;
                  DataLogRecord.Next;
                until Counter = NoOfRowsToDeleteAllowed;
            end;
          end else
          //+NPR5.53 [326663]
          DataLogRecord.DeleteAll;
          if NoOfEntries <> 0 then
            WriteLogAndCommit(TaskLine, DataLogRecord.TableCaption);
        until DataLogSetup.Next = 0;
    end;

    procedure DeleteIDSPackages(TaskLine: Record "Task Line";CompanyToDelete: Text[50];LastDateToDelete: Date)
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        FRef2: FieldRef;
    begin
        //-TQ1.25
        if LastDateToDelete = 0D then
          exit;

        if CompanyToDelete = '' then
          exit;

        RecRef.Open(6059924, false, CompanyToDelete);

        FRef := RecRef.Field(11);
        FRef.SetFilter('<%1', CreateDateTime(LastDateToDelete,0T));
        FRef2 := RecRef.Field(20);
        FRef2.SetFilter('%1|%2', 3,6);

        RecRef.CurrentKeyIndex(GetBestKey(RecRef));

        NoOfEntries := RecRef.Count;

        RecRef.DeleteAll(true);

        if NoOfEntries <> 0 then
          WriteLogAndCommit(TaskLine, RecRef.Caption);
        //+TQ1.25
    end;

    procedure DeleteByRecRef(TaskLine: Record "Task Line";CompanyToDelete: Text[50];LastDateToDelete: Date;TableNo: Integer;DateFilterFieldNo: Integer;ExecuteDeleteTrigger: Boolean)
    var
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        //-TQ1.22
        if LastDateToDelete = 0D then
          exit;

        if CompanyToDelete = '' then
          exit;

        RecRef.Open(TableNo, false, CompanyToDelete);

        FRef := RecRef.Field(DateFilterFieldNo);
        case UpperCase(Format(FRef.Type)) of
          'DATE':     FRef.SetFilter('<%1', LastDateToDelete);
          'DATETIME': FRef.SetFilter('<%1', CreateDateTime(LastDateToDelete,0T));
        end;

        RecRef.CurrentKeyIndex(GetBestKey(RecRef));

        NoOfEntries := RecRef.Count;

        //-TQ1.25
        RecRef.DeleteAll(ExecuteDeleteTrigger);
        //-TQ1.25

        if NoOfEntries <> 0 then
          WriteLogAndCommit(TaskLine, RecRef.Caption);
        //+TQ1.22
    end;

    procedure BackupAuditRoll(TaskLine: Record "Task Line";CompanyToBackup: Text[50];LastDateToBackup: Date)
    var
        AuditRoll: Record "Audit Roll";
        AuditRollBck: Record "Audit Roll Backup";
        LastDate: Date;
        TotalNoOfRowsDeleted: Integer;
    begin
        if LastDateToBackup = 0D then
          exit;

        if CompanyToBackup = '' then
          exit;

        AuditRoll.ChangeCompany(CompanyToBackup);
        AuditRollBck.ChangeCompany(CompanyToBackup);
        AuditRoll.SetRange("Sale Date", 0D, LastDateToBackup);
        if AuditRoll.FindFirst then repeat
          AuditRoll.SetRange("Sale Date", AuditRoll."Sale Date");
          NoOfEntries := AuditRoll.Count;
          //-NPR5.53 [326663]
          NoOfRowsToDeleteAllowed := GetNoOfRowsToDelete(CompanyToBackup ,DATABASE::"Audit Roll",NoOfEntries);
            if NoOfRowsToDeleteAllowed <> 0  then begin
          //+NPR5.53 [326663]
              if AuditRoll.FindSet(true, false) then repeat
                AuditRollBck.TransferFields(AuditRoll);
                AuditRollBck.Insert;
                AuditRoll.Delete;
              until AuditRoll.Next = 0;
          //-NPR5.53 [326663]
            end else
              exit;
          //+NPR5.53 [326663]
          AuditRoll.SetRange("Sale Date", 0D, LastDateToBackup);

          if NoOfEntries <> 0 then
            WriteLogAndCommit(TaskLine, AuditRoll.TableCaption);


          if not TaskLine.TimeSlotStillValid then
            exit;

        until AuditRoll.Next = 0;
    end;

    procedure GetBestKey(var RecRef: RecordRef): Integer
    var
        TMPInt: Record "Integer" temporary;
        KRef: KeyRef;
        FRef: FieldRef;
        BestKeyNo: Integer;
        BestScore: Integer;
        Score: Integer;
        Qty: Integer;
        i: Integer;
        j: Integer;
    begin
        //-TQ1.22
        //The function returns the index of the best key to use given the applied filters.
        BestKeyNo := 1;

        //Enumerate all fields with filter. Temporary record used for speed.
        for i := 1 to RecRef.FieldCount do begin
          FRef := RecRef.FieldIndex(i);
          while (not TMPInt.Get(FRef.Number)) and (j <= 255) do begin
            RecRef.FilterGroup(j);
            if FRef.GetFilter <> '' then begin
              TMPInt.Init;
              TMPInt.Number := FRef.Number;
              TMPInt.Insert(false);
            end;
            j += 1;
          end;
          Clear(FRef);
          j := 0;
        end;

        //Loop through all keys to find best match.
        for i := 1 to RecRef.KeyCount do begin
          Clear(Score);
          Clear(Qty);
          KRef := RecRef.KeyIndex(i);
          for j := 1 to KRef.FieldCount do begin
            FRef := KRef.FieldIndex(j);
            if TMPInt.Get(FRef.Number) then begin
              //Score for Placement:
              Score += Power(2, 20 - j);
              //Score for Quantity:
              Qty += 1;
              Score += Power(2, 20 - j) * (Qty - 1)
            end;
            Clear(FRef);
          end;
          if Score > BestScore then begin
            BestKeyNo := i;
            BestScore := Score;
          end;
        end;

        exit(BestKeyNo);
        //+TQ1.22
    end;

    local procedure GetNoOfRowsToDelete(CompanyToDelete: Text;"Table": Integer;OriginalRowCount: Integer): Integer
    var
        ActualRecordSizeToDelete: Integer;
        NoOfRowstodelete: Integer;
    begin
        //-NPR5.53 [326663]
        if OriginalRowCount = 0 then exit(0);
        if MaxSizeToDelete = 0 then exit(0);
         if MaxSizeToDelete > 0 then begin
           TableInformation.SetRange(TableInformation."Company Name",CompanyToDelete);
           TableInformation.SetRange(TableInformation."Table No.",Table);
           if TableInformation.FindFirst then begin
              ActualRecordSizeToDelete := Round((OriginalRowCount  * TableInformation."Record Size") / 1000,1,'=');
             if MaxSizeToDelete > ActualRecordSizeToDelete then begin
                MaxSizeToDelete := MaxSizeToDelete - ActualRecordSizeToDelete;
               exit(OriginalRowCount);
             end else begin
               NoOfRowstodelete := Round((MaxSizeToDelete / TableInformation."Record Size") * 1000,1,'=');
               MaxSizeToDelete := 0 ;
               //NoOfEntries := NoOfRowstodelete;
               exit(NoOfRowstodelete);
             end;
           end;
         end else
          exit(OriginalRowCount);

        //-NPR5.53 [326663]
    end;
}

