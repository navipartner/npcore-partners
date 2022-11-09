codeunit 6059950 "NPR Print Exchange Labels"
{
    procedure PrintLabelsPOSLine(PrintType: Option Single,LineQuantity,All,Selection,Package; var SaleLinePOS: Record "NPR POS Sale Line"; ValidFromDate: Date)
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SaleLinePOS);
        ExchLabelMgt.PrintLabels(PrintType, RecRef, ValidFromDate);
    end;

    procedure PrintLabelsSalesLine(PrintType: Option Single,LineQuantity,All,Selection,Package; var SalesLine: Record "Sales Line"; ValidFromDate: Date)
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SalesLine);
        ExchLabelMgt.PrintLabels(PrintType, RecRef, ValidFromDate);
    end;
}