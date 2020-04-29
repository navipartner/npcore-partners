codeunit 6060065 "Sales Statistic TQ"
{
    // NPR5.42/RA  /20180523 CASE 313503 Created Codeunit
    // NPR5.47/RA  /20181017 CASE 305715 Date should progress
    // NPR5.50/RA  /20190528 CASE 354767 Should calculate for the privius day

    TableNo = "Task Line";

    trigger OnRun()
    var
        LogiqSalesStatistic: Report "Sales Statistic";
        StartDate: Date;
        EndDate: Date;
        Period: Text;
        Host: Text;
        UserName: Text;
        PassWord: Text;
        RemoteDir: Text;
    begin

          StartDate := GetParameterDate('STARTDATE');
          Period    := GetParameterDateFormula('JOURNALPERIOD');
          EndDate   := CalcDate(Period, StartDate);
          if (StartDate = 0D) or (EndDate = 0D) then
            Error(Text001);

          Host      := GetParameterText('HOST');
          UserName  := GetParameterText('USERNAME');
          PassWord  := GetParameterText('PASSWORD');
          RemoteDir := GetParameterText('REMOTEDIR');
          if (Host = '') or (UserName = '') then
            Error(Text002);

          LogiqSalesStatistic.UseRequestPage(false);
          LogiqSalesStatistic.SetParameter(StartDate,
                                           EndDate,
                                           Host,
                                           UserName,
                                           PassWord,
                                           RemoteDir);
          LogiqSalesStatistic.RunModal;

          //-#354767
          //-NPR5.47
          //EndDate := TODAY + 1;
          //+NPR5.47
          EndDate := Today;
          //+354767
          SetParameterDate('STARTDATE', EndDate);
          AddMessageLine2OutputLog(Format(StartDate) + ', ' + Period);
    end;

    var
        Text001: Label 'Date range cant be calculated!';
        Text002: Label 'FTP information is invalid!';

    [EventSubscriber(ObjectType::Table, 6059902, 'OnAfterValidateEvent', 'Object No.', false, false)]
    local procedure Initialize(var Rec: Record "Task Line";var xRec: Record "Task Line";CurrFieldNo: Integer)
    var
        TaskLineParam: Record "Task Line Parameters";
        TaskWorkerGroup: Record "Task Worker Group";
        Text001: Label 'No Parameters found. Do you with to have empty Parameters added?';
        FieldType: Option Text,Date,Time,DateTime,"Integer",Decimal,Boolean,DateFormula;
    begin
        with Rec do begin
          if (xRec."Object No." = 6060065) and ("Object No." <> 6060065) then begin
            TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
            TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
            TaskLineParam.SetRange("Journal Line No.", "Line No.");
            TaskLineParam.DeleteAll;
            "Call Object With Task Record" := false;
            exit;
          end;

          if "Object No." <> 6060065 then
            exit;

          if GuiAllowed then
            if not Confirm(Text001) then
              exit;

          TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
          TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
          TaskLineParam.SetRange("Journal Line No.", "Line No.");
          TaskLineParam.DeleteAll;

          InsertParameter('STARTDATE', FieldType::Date);
          InsertParameter('JOURNALPERIOD', FieldType::DateFormula);
          InsertParameter('HOST', FieldType::Text);
          InsertParameter('USERNAME', FieldType::Text);
          InsertParameter('PASSWORD', FieldType::Text);
          InsertParameter('REMOTEDIR', FieldType::Text);
          "Call Object With Task Record" := true;
        end;
    end;
}

