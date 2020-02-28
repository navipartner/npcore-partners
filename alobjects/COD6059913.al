codeunit 6059913 "Delete CS Posting Buffer"
{
    // NPR5.53/SARA/20191009 CASE 370747 Create object: Clean up CS Posting Buffer (6151397)

    TableNo = "Task Line";

    trigger OnRun()
    begin
        CheckForParameters(Rec);

        if not TimeSlotStillValid then
            exit;

        if GetParameterBool('DEL CS POSTING BUF') then
            DeleteCSPostingBuffer(Rec,CompanyName,GetParameterCalcDate('CS POSTING BUF DATE'));

        if GetParameterBool('DEL CS COMM LOG') then
            DeleteCSCommunicationLog(Rec,CompanyName,GetParameterCalcDate('CS COMM LOG DATE'));
    end;

    var
        Text001: Label 'No Parameters found. Do you with to have empty Parameters added?';
        Text002: Label 'Empty Parameters added. Please fill in the parameters before run this task again';
        Text003: Label ' - %1 records deleted in table %2';
        Text004: Label 'Deleting Entries in %1';
        Text005: Label 'Company: Name=';
        NoOfEntries: Integer;

    procedure CheckForParameters(TaskLine: Record "Task Line")
    var
        DateForm: DateFormula;
        Obj: Record "Object";
    begin
        if TaskLine.ParametersExists then
          exit;
        
        /*
        TaskLine."Table 1 No." := 2000000006;
        EVALUATE(TaskLine."Table 1 Filter", Text005 + COMPANYNAME);
        TaskLine.MODIFY;
        */
        
        //CS Posting Buffer
        TaskLine.InsertParameter('DEL CS POSTING BUF',6);
        TaskLine.InsertParameter('CS POSTING BUF DATE',7);
        Evaluate(DateForm, '<-5Y>');
        TaskLine.SetParameterDateFormula('CS POSTING BUF DATE',DateForm);
        
        //CS Communication Log
        TaskLine.InsertParameter('DEL CS COMM LOG',6);
        TaskLine.InsertParameter('CS COMM LOG DATE',7);
        Evaluate(DateForm, '<-5Y>');
        TaskLine.SetParameterDateFormula('CS COMM LOG DATE',DateForm);
        
        Commit;
        Error(Text002);

    end;

    procedure WriteLogAndCommit(TaskLine: Record "Task Line";TableName: Text[60])
    begin
        TaskLine.AddMessageLine2OutputLog(StrSubstNo(Text003, NoOfEntries, TableName));
        Commit;
    end;

    procedure DeleteCSPostingBuffer(TaskLine: Record "Task Line";CompanyToDelete: Text[50];LastDateToDelete: Date)
    var
        CSPostingBuffer: Record "CS Posting Buffer";
        RecRef: RecordRef;
        NoOfRowsToDelete: Integer;
        Counter: Integer;
    begin
        if LastDateToDelete = 0D then
          exit;
        
        if CompanyToDelete = '' then
          exit;
        
        CSPostingBuffer.ChangeCompany(CompanyToDelete);
        CSPostingBuffer.SetFilter(Created,'<=%1',CreateDateTime(LastDateToDelete,0T));
        CSPostingBuffer.SetRange(Executed,true);
        CSPostingBuffer.SetFilter("Job Queue Status",'<>%1',CSPostingBuffer."Job Queue Status"::Error);
        
        //Set the Best Key
        /*
        RecRef.GETTABLE(CSPostingBuffer);
        RecRef.CURRENTKEYINDEX(GetBestKey(RecRef));
        RecRef.SETTABLE(CreditCardTrans);
        */
        //StartTime := TIME;
        NoOfEntries := CSPostingBuffer.Count;
        /*
        NoOfRowsToDelete := GetNoOfRowsToDelete(CompanyToDelete,DATABASE::"Credit Card Transaction",NoOfEntries);
         IF NoOfRowsToDelete < NoOfEntries THEN BEGIN
           IF CreditCardTrans.FINDSET THEN
              REPEAT
                CreditCardTrans.DELETE;
                Counter += 1;
              UNTIL Counter = NoOfRowsToDelete;
         END ELSE
        */
        if CSPostingBuffer.FindSet then
          CSPostingBuffer.DeleteAll;
        WriteLogAndCommit(TaskLine,CSPostingBuffer.TableCaption);

    end;

    procedure DeleteCSCommunicationLog(TaskLine: Record "Task Line";CompanyToDelete: Text[50];LastDateToDelete: Date)
    var
        CSCommunicationLog: Record "CS Communication Log";
        RecRef: RecordRef;
        NoOfRowsToDelete: Integer;
        Counter: Integer;
    begin
        if LastDateToDelete = 0D then
          exit;
        
        if CompanyToDelete = '' then
          exit;
        
        CSCommunicationLog.ChangeCompany(CompanyToDelete);
        CSCommunicationLog.SetFilter("Request Start",'<=%1',CreateDateTime(LastDateToDelete,0T));
        
        //Set the Best Key
        /*
        RecRef.GETTABLE(CSPostingBuffer);
        RecRef.CURRENTKEYINDEX(GetBestKey(RecRef));
        RecRef.SETTABLE(CreditCardTrans);
        */
        //StartTime := TIME;
        NoOfEntries := CSCommunicationLog.Count;
        /*
        NoOfRowsToDelete := GetNoOfRowsToDelete(CompanyToDelete,DATABASE::"Credit Card Transaction",NoOfEntries);
         IF NoOfRowsToDelete < NoOfEntries THEN BEGIN
           IF CreditCardTrans.FINDSET THEN
              REPEAT
                CreditCardTrans.DELETE;
                Counter += 1;
              UNTIL Counter = NoOfRowsToDelete;
         END ELSE
        */
        if CSCommunicationLog.FindSet then
          CSCommunicationLog.DeleteAll;
        WriteLogAndCommit(TaskLine,CSCommunicationLog.TableCaption);

    end;
}

