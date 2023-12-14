codeunit 6060090 "NPR POS Action: Print Item-B"
{
    Access = Internal;

    procedure PrintItem(LineSetting: Option "All Lines","Selected Line"; PrintType: Option Price,Shelf,Sign; QuantityInput: Integer)
    begin
        case LineSetting of
            LineSetting::"All Lines":
                PrintAllLines(PrintType);
            LineSetting::"Selected Line":
                PrintSelectedLine(PrintType, QuantityInput);
        end;
    end;

    local procedure PrintAllLines(PrintType: Option Price,Shelf,Sign)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
        RetailJnlLine: Record "NPR Retail Journal Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        LabelManagement: Codeunit "NPR Label Management";
        GUID: Guid;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        GUID := CreateGuid();

        SaleLinePOS2.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange("Line Type", SaleLinePOS2."Line Type"::Item);

        if SaleLinePOS2.FindSet() then
            repeat
                LabelManagement.ItemToRetailJnlLine(SaleLinePOS2."No.", SaleLinePOS2."Variant Code", Round(Abs(SaleLinePOS2.Quantity), 1, '>'), GUID, RetailJnlLine);
            until SaleLinePOS2.Next() = 0;

        RetailJnlLine.SetRange("No.", GUID);
        if not RetailJnlLine.FindSet() then
            exit;

        PrintRJL(RetailJnlLine, PrintType);

        RetailJnlLine.DeleteAll();
    end;

    local procedure PrintSelectedLine(PrintType: Option Price,Shelf,Sign; QuantityInput: Integer)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        RetailJnlLine: Record "NPR Retail Journal Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        LabelManagement: Codeunit "NPR Label Management";
        GUID: Guid;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        GUID := CreateGuid();

        LabelManagement.ItemToRetailJnlLine(SaleLinePOS."No.", SaleLinePOS."Variant Code", QuantityInput, GUID, RetailJnlLine);

        RetailJnlLine.SetRange("No.", GUID);
        if not RetailJnlLine.FindFirst() then
            exit;

        PrintRJL(RetailJnlLine, PrintType);

        RetailJnlLine.DeleteAll();
    end;

    local procedure PrintRJL(var RetailJnlLine: Record "NPR Retail Journal Line"; PrintType: Option Price,Shelf,Sign)
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        LabelManagement: Codeunit "NPR Label Management";
    begin
        case PrintType of
            PrintType::Price:
                ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Price Label";
            PrintType::Shelf:
                ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Shelf Label";
            PrintType::Sign:
                ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::Sign;
        end;

        Commit();

        LabelManagement.PrintRetailJournal(RetailJnlLine, ReportSelectionRetail."Report Type".AsInteger());
    end;
}
