codeunit 6059982 "NPR POSAction: Merg.Sml.LinesB"
{
    Access = Internal;
    procedure ColapseSaleLines(var POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActMergSimlLinesEvents: Codeunit "NPR POSActMergSimlLinesEvents";
        NoLinesErr: Label 'No adequate sale lines are available in the current sale';
        CollapseNotSupportedMsg: Label 'Collapse is not supported for the Items: %1';
        NotCollapsedItems: text;
        CollapseSupported: Boolean;
    begin
        SaleLinePOS.SetCurrentKey("No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Discount Type", '<>%1', SaleLinePOS."Discount Type"::Manual);

        POSActMergSimlLinesEvents.OnBeforeFindLinesToCollapse(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            Error(NoLinesErr);

        POSSession.GetSaleLine(POSSaleLine);

        repeat

            SaleLinePOS.SetRange("No.", SaleLinePOS."No.");
            SaleLinePOS.SetRange("Variant Code", SaleLinePOS."Variant Code");
            SaleLinePOS.SetRange("Unit Price", SaleLinePOS."Unit Price");
            SaleLinePOS.SetRange("Unit of Measure Code", SaleLinePOS."Unit of Measure Code");
            SaleLinePOS.SetRange("Discount %", SaleLinePOS."Discount %");

            POSActMergSimlLinesEvents.OnBeforeFindSimilarLinesToCollapse(SalePOS, SaleLinePOS);
            if SaleLinePOS.Count() > 1 then begin

                CollapseSupported := true;
                OnBeforeCollapseSaleLine(SaleLinePOS, CollapseSupported);
                POSActMergSimlLinesEvents.OnBeforeCollapseSaleLine(SaleLinePOS, CollapseSupported);
                if not CollapseSupported then
                    CollectNotCollapsedItem(NotCollapsedItems, SaleLinePOS."No.")
                else begin
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
            end;

            SaleLinePOS.SetRange("No.");
            SaleLinePOS.SetRange("Variant Code");
            SaleLinePOS.SetRange("Unit Price");
            SaleLinePOS.SetRange("Unit of Measure Code");
            SaleLinePOS.SetRange("Discount %");

            POSActMergSimlLinesEvents.OnAfterFindLinesToCollapse(SalePOS, SaleLinePOS);
        until SaleLinePOS.Next() = 0;

        if NotCollapsedItems <> '' then
            Message(StrSubstNo(CollapseNotSupportedMsg, NotCollapsedItems));

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

    local procedure CollectNotCollapsedItem(var NotCollapsedItems: Text; ItemNo: Code[20])
    begin
        if NotCollapsedItems = '' then
            NotCollapsedItems := ItemNo
        else
            NotCollapsedItems += ', ' + ItemNo;
    end;

    [Obsolete('Not used anymore. Use OnBeforeCollapseSaleLine in codenunit NPR POSActMergSimlLinesEvents instead.', 'NPR35.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCollapseSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var CollapseSupported: Boolean)
    begin
    end;
}