codeunit 6150655 "NPR Print Whs. Price Label"
{
    TableNo = "Warehouse Activity Header";

    trigger OnRun()
    var
        LabelManagement: Codeunit "NPR Label Management";
        RecordVar: Variant;
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        RecordVar := Rec;
        LabelManagement.PrintLabel(RecordVar, ReportSelectionRetail."Report Type"::"Price Label".AsInteger());
    end;

}
