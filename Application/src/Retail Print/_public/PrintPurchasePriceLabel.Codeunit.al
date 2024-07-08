codeunit 6059922 "NPR Print Purchase Price Label"
{
    TableNo = "Purchase Header";

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