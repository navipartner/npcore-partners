codeunit 6059914 "Delete CS Stock Takes"
{
    // NPR5.53/SARA/20191009 CASE 370747 Create object: Clean up CS Stock Takes (6151392)

    TableNo = "Task Line";

    trigger OnRun()
    begin
        CheckForParameters(Rec);

        if not TimeSlotStillValid then
            exit;

        if GetParameterBool('DEL CS STOCK TAKES') then
            DeleteCSStockTakes(Rec,CompanyName,GetParameterCalcDate('CS STOCK TAKES DATE'));
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


        //CS Stock Takes
        TaskLine.InsertParameter('DEL CS STOCK TAKES',6);
        TaskLine.InsertParameter('CS STOCK TAKES DATE',7);
        Evaluate(DateForm, '<-14D>');
        TaskLine.SetParameterDateFormula('CS STOCK TAKES DATE',DateForm);


        Commit;
        Error(Text002);
    end;

    procedure WriteLogAndCommit(TaskLine: Record "Task Line";TableName: Text[60])
    begin
        TaskLine.AddMessageLine2OutputLog(StrSubstNo(Text003, NoOfEntries, TableName));
        Commit;
    end;

    procedure DeleteCSStockTakes(TaskLine: Record "Task Line";CompanyToDelete: Text[50];LastDateToDelete: Date)
    var
        CSStockTakes: Record "CS Stock-Takes";
        CSStockTakesData: Record "CS Stock-Takes Data";
        RecRef: RecordRef;
        NoOfRowsToDelete: Integer;
        Counter: Integer;
    begin
        if LastDateToDelete = 0D then
          exit;

        if CompanyToDelete = '' then
          exit;

        CSStockTakes.ChangeCompany(CompanyToDelete);
        CSStockTakes.SetFilter(Created,'<=%1',CreateDateTime(LastDateToDelete,0T));
        CSStockTakes.SetRange("Journal Posted",true);
        NoOfEntries := CSStockTakes.Count;
        if CSStockTakes.FindSet then
          CSStockTakes.DeleteAll(true);

        WriteLogAndCommit(TaskLine,CSStockTakes.TableCaption);
    end;
}

