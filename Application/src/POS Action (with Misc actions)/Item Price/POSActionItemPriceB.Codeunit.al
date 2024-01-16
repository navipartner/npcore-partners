codeunit 6059853 "NPR POS Action - Item Price B"
{
    Access = Internal;

    procedure GetSalesLineNo(POSSession: Codeunit "NPR POS Session"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        POSSale.GetCurrentSale(SalePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if (not SaleLinePOS.FindLast()) then
            SaleLinePOS."Line No." := -1;
    end;

    procedure GetSalesLine(POSSession: Codeunit "NPR POS Session"; var SaleLinePOS: Record "NPR POS Sale Line"; LineNumber: Integer): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line No.", '>%1', LineNumber);
        exit(SaleLinePOS.FindFirst());
    end;

    procedure DeleteLines(POSSession: Codeunit "NPR POS Session"; LineNumber: Integer)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (LineNumber = -1) then
            POSSaleLine.DeleteAll()
        else
            while (SaleLinePOS."Line No." > LineNumber) do begin
                POSSaleLine.DeleteLine();
                POSSaleLine.SetLast();
                POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            end;
    end;
}