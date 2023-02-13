codeunit 6150655 "NPR Print Whs. Price Label"
{
    TableNo = "Warehouse Activity Header";

    trigger OnRun()
    var
        LabelLibrary: Codeunit "NPR Label Library";
        RecordVar: Variant;
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        RecordVar := Rec;
        LabelLibrary.PrintLabel(RecordVar, ReportSelectionRetail."Report Type"::"Price Label".AsInteger());
    end;

}
