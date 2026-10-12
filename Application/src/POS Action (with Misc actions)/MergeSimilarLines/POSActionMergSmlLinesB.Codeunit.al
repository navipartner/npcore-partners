codeunit 6059982 "NPR POSAction: Merg.Sml.LinesB"
{
    Access = Internal;
    procedure ColapseSaleLines(var POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempSaleLinePOSToDelete: Record "NPR POS Sale Line" temporary;
        TempLotSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActMergSimlLinesEvents: Codeunit "NPR POSActMergSimlLinesEvents";
        NoLinesErr: Label 'No adequate sale lines are available in the current sale';
        CollapseNotSupportedMsg: Label 'Collapse is not supported for the Items: %1';
        NotCollapsedItems: text;
        CollapseSupported: Boolean;
        LotQty: Decimal;
    begin
        SaleLinePOS.SetCurrentKey("No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Discount Type", '<>%1', SaleLinePOS."Discount Type"::Manual);
        SaleLinePOS.SetRange("Manual Item Sales Price", false);
        SaleLinePOS.SetRange("Coupon Applied", false);

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
            SaleLinePOS.SetRange("Lot No.", SaleLinePOS."Lot No.");
            SaleLinePOS.SetRange("Serial No.", SaleLinePOS."Serial No.");
            SaleLinePOS.SetRange("Manual Item Sales Price", false);
            SaleLinePOS.SetRange("Coupon Applied", false);

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

                    TempSaleLinePOSToDelete := SaleLinePOS;
                    TempSaleLinePOSToDelete.Insert();

                    while SaleLinePOS.Next() > 0 do begin
                        TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;

                        TempSaleLinePOSToDelete := SaleLinePOS;
                        TempSaleLinePOSToDelete.Insert();
                    end;
                    TempSaleLinePOS.Modify();

                end;
            end;

            SaleLinePOS.SetRange("No.");
            SaleLinePOS.SetRange("Variant Code");
            SaleLinePOS.SetRange("Unit Price");
            SaleLinePOS.SetRange("Unit of Measure Code");
            SaleLinePOS.SetRange("Discount %");
            SaleLinePOS.SetRange("Lot No.");
            SaleLinePOS.SetRange("Serial No.");

            POSActMergSimlLinesEvents.OnAfterFindLinesToCollapse(SalePOS, SaleLinePOS);
        until SaleLinePOS.Next() = 0;

        if NotCollapsedItems <> '' then
            Message(StrSubstNo(CollapseNotSupportedMsg, NotCollapsedItems));


        if not TempSaleLinePOS.FindSet() then
            exit;

        DeleteLines(TempSaleLinePOSToDelete);

        // Validate only after the delete and before InsertLine commits, so an error rolls back the delete.
        TempLotSaleLinePOS.Copy(TempSaleLinePOS, true);
        repeat
            if TempSaleLinePOS."Lot No." <> '' then begin
                // InsertLine commits each group, so a lot split over several groups must pass the stock check for its total first.
                TempLotSaleLinePOS.SetRange("No.", TempSaleLinePOS."No.");
                TempLotSaleLinePOS.SetRange("Variant Code", TempSaleLinePOS."Variant Code");
                TempLotSaleLinePOS.SetRange("Lot No.", TempSaleLinePOS."Lot No.");
                if TempLotSaleLinePOS.Count() > 1 then begin
                    TempLotSaleLinePOS.CalcSums(Quantity);
                    LotQty := TempLotSaleLinePOS.Quantity;
                    if LotQty > 0 then begin
                        TempLotSaleLinePOS := TempSaleLinePOS;
                        TempLotSaleLinePOS.Quantity := LotQty;
                        TempLotSaleLinePOS.LotNoValidate();
                    end;
                end;
            end;
            TempSaleLinePOS.Validate(Quantity);
            TempSaleLinePOS.Modify();
        until TempSaleLinePOS.Next() = 0;

        TempSaleLinePOS.FindSet();
        repeat
            SaleLinePOS := TempSaleLinePOS;
            POSSaleLine.SetUseLinePriceVATParams(true);
            POSSaleLine.InsertLine(SaleLinePOS, false);
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

    local procedure DeleteLines(var TempSaleLinePOSToDelete: Record "NPR POS Sale Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if TempSaleLinePOSToDelete.FindSet() then
            repeat
                SaleLinePOS.Get(TempSaleLinePOSToDelete."Register No.", TempSaleLinePOSToDelete."Sales Ticket No.", TempSaleLinePOSToDelete.Date, TempSaleLinePOSToDelete."Sale Type", TempSaleLinePOSToDelete."Line No.");
                SaleLinePOS.Delete();
            until TempSaleLinePOSToDelete.Next() = 0;
    end;

    [Obsolete('Not used anymore. Use OnBeforeCollapseSaleLine in codenunit NPR POSActMergSimlLinesEvents instead.', '2024-06-28')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCollapseSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var CollapseSupported: Boolean)
    begin
    end;
}