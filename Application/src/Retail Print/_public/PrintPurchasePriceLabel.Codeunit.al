codeunit 6059922 "NPR Print Purchase Price Label"
{
    TableNo = "Purchase Header";

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