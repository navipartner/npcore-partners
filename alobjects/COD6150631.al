codeunit 6150631 "POS Post with Task Queue"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created

    TableNo = "Task Line";

    trigger OnRun()
    var
        POSPostEntries: Codeunit "POS Post Entries";
        PostingDateOption: Integer;
        POSEntry: Record "POS Entry";
        POSEntryNoFilter: Text;
        POSPeriodRegisterNoFilter: Text;
    begin
        CheckForParameters(Rec);
        POSPostEntries.SetPostCompressed(Rec.GetParameterBool('COMPRESSED'));
        if Rec.GetParameterBool('ITEMPOSTING') then begin
          POSPostEntries.SetPostItemEntries(true);
          POSEntry.SetFilter("Post Item Entry Status",'<2');
        end;
        if Rec.GetParameterBool('POSPOSTING') then begin
          POSPostEntries.SetPostPOSEntries(true);
          POSEntry.SetFilter("Post Entry Status",'<2');
        end;

        POSPostEntries.SetPostPOSEntries(Rec.GetParameterBool('POSPOSTING'));
        POSPostEntries.SetStopOnError(Rec.GetParameterBool('STOPONERROR'));
        PostingDateOption := Rec.GetParameterInt('DATEOPTION');
        case PostingDateOption of
          0 : ; //No Date Set
          1 : POSPostEntries.SetPostingDate(true,false,Today);        //1: Set Posting Date to Today
          2 : POSPostEntries.SetPostingDate(true,false,WorkDate);     //2: Set Posting Date to Workdate
          3 : POSPostEntries.SetPostingDate(true,true,Today);         //3: Set Posting Date and Document Date to Today
          4 : POSPostEntries.SetPostingDate(true,true,WorkDate);      //4: Set Posting Date and Document Date to Workdate
          5 : POSPostEntries.SetPostingDate(true,false,Today - 1);    //5: Set Posting Date to Yesterday
          6 : POSPostEntries.SetPostingDate(true,false,WorkDate - 1); //6: Set Posting Date to Day before Workdate
          7 : POSPostEntries.SetPostingDate(true,true,Today - 1);     //7: Set Posting Date and Document Date to Yesterday
          8 : POSPostEntries.SetPostingDate(true,true,WorkDate -1);   //8: Set Posting Date and Document Date to Day before Workdate
        end;

        POSEntryNoFilter := Rec.GetParameterText('POSENTRYNOFILTER');
        POSPeriodRegisterNoFilter := Rec.GetParameterText('POSENTRYNOFILTER');
        if POSEntryNoFilter <> '' then
          POSEntry.SetFilter("Entry No.",POSEntryNoFilter);
        if POSPeriodRegisterNoFilter <> '' then
          POSEntry.SetFilter("POS Period Register No.",POSPeriodRegisterNoFilter);

        POSPostEntries.Run(POSEntry);
    end;

    var
        Text001: Label 'No Parameters found. Do you wish to have empty Parameters added?';
        Text002: Label 'Empty Parameters added. Please fill in the parameters before run this task again';
        Text005: Label 'Company: Name=';

    procedure CheckForParameters(TaskLine: Record "Task Line")
    var
        DateForm: DateFormula;
        Obj: Record "Object";
        FieldType: Option Text,Date,Time,DateTime,"Integer",Decimal,Boolean,DateFilter;
    begin
        if TaskLine.ParametersExists then
          exit;

        if GuiAllowed then
          if not Confirm(Text001) then
            exit;

        TaskLine."Table 1 No." := 2000000006;
        Evaluate(TaskLine."Table 1 Filter", Text005 + CompanyName);
        TaskLine.Modify;

        TaskLine.InsertParameter('COMPRESSED',FieldType::Boolean);
        TaskLine.InsertParameter('ITEMPOSTING',FieldType::Boolean);
        TaskLine.InsertParameter('POSPOSTING',FieldType::Boolean);
        TaskLine.InsertParameter('DATEOPTION',FieldType::Integer);
        TaskLine.InsertParameter('STOPONERROR',FieldType::Boolean);
        TaskLine.InsertParameter('POSENTRYNOFILTER',FieldType::Text);
        TaskLine.InsertParameter('PERIODREGNOFILTER',FieldType::Text);
        Commit;
        Error(Text002);
    end;
}

