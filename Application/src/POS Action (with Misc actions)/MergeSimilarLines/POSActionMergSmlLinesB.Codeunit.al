codeunit 6059982 "NPR POSAction: Merg.Sml.LinesB"
{
    Access = Internal;
    procedure ColapseSaleLines(var POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NoLinesErr: Label 'No adequate sale lines are available in the current sale';
    begin
        SaleLinePOS.SetCurrentKey("No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Discount Type", '<>%1', SaleLinePOS."Discount Type"::Manual);
        if not SaleLinePOS.FindSet() then
            Error(NoLinesErr);

        POSSession.GetSaleLine(POSSaleLine);

        repeat

            SaleLinePOS.SetRange("No.", SaleLinePOS."No.");
            SaleLinePOS.SetRange("Variant Code", SaleLinePOS."Variant Code");
            SaleLinePOS.SetRange("Unit Price", SaleLinePOS."Unit Price");
            SaleLinePOS.SetRange("Unit of Measure Code", SaleLinePOS."Unit of Measure Code");
            SaleLinePOS.SetRange("Discount %", SaleLinePOS."Discount %");

            if SaleLinePOS.Count() > 1 then begin

                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert();

                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
                POSSaleLine.DeleteLine();

                while SaleLinePOS.Next() > 0 do begin
                    TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
                    POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
                    POSSaleLine.DeleteLine();
                end;

                TempSaleLinePOS.Modify();
            end;

            SaleLinePOS.SetRange("No.");
            SaleLinePOS.SetRange("Variant Code");
            SaleLinePOS.SetRange("Unit Price");
            SaleLinePOS.SetRange("Unit of Measure Code");
            SaleLinePOS.SetRange("Discount %");
        until SaleLinePOS.Next() = 0;

        if not TempSaleLinePOS.FindSet() then
            exit;

        repeat
            SaleLinePOS := TempSaleLinePOS;
            POSSaleLine.SetUseLinePriceVATParams(true);
            POSSaleLine.InsertLine(SaleLinePOS);

            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            SaleLinePOS.Modify();
            POSSaleLine.RefreshCurrent();
        until TempSaleLinePOS.Next() = 0;
    end;
}