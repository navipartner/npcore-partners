codeunit 6151476 "NPR Discount Calc Buffer Utils"
{
    Access = Internal;

    internal procedure GetLastEntryNo(var TempCurrDiscountCalcBuffer: Record "NPR Discount Calc. Buffer" temporary) LastEntryNo: Integer;
    var
        TempDiscountCalcBuffer: Record "NPR Discount Calc. Buffer" temporary;
    begin
        TempDiscountCalcBuffer := TempCurrDiscountCalcBuffer;
        TempCurrDiscountCalcBuffer.Reset();
        if not TempCurrDiscountCalcBuffer.FindLast() then
            Clear(TempCurrDiscountCalcBuffer);

        LastEntryNo := TempCurrDiscountCalcBuffer."Entry No.";

        TempCurrDiscountCalcBuffer := TempDiscountCalcBuffer;
    end;

    internal procedure CopyInfoFromMixDiscountLine(var TempCurrDiscountCalcBuffer: Record "NPR Discount Calc. Buffer" temporary; MixedDiscountLine: Record "NPR Mixed Discount Line")
    begin
        TempCurrDiscountCalcBuffer."Disc. Grouping Type" := MixedDiscountLine."Disc. Grouping Type";
        TempCurrDiscountCalcBuffer."Discount Code" := MixedDiscountLine.Code;
        TempCurrDiscountCalcBuffer."No." := MixedDiscountLine."No.";
        TempCurrDiscountCalcBuffer."Variant Code" := MixedDiscountLine."Variant Code";
        TempCurrDiscountCalcBuffer."Discount Record ID" := MixedDiscountLine.RecordId;
    end;

    internal procedure CopyInfoFromPOSSaleLine(var TempCurrDiscountCalcBuffer: Record "NPR Discount Calc. Buffer" temporary; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        TempCurrDiscountCalcBuffer."Sales Register No." := SaleLinePOS."Register No.";
        TempCurrDiscountCalcBuffer."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        TempCurrDiscountCalcBuffer."Sales Date" := SaleLinePOS.Date;
        TempCurrDiscountCalcBuffer."Sales Line No." := SaleLinePOS."Line No.";
        TempCurrDiscountCalcBuffer."Sales Record ID" := SaleLinePOS.RecordId;
        TempCurrDiscountCalcBuffer."Sales Quantity" := SaleLinePOS.Quantity;
    end;

    internal procedure FillMixDiscountCaclulationInformation(var TempCurrDiscountCalcBuffer: Record "NPR Discount Calc. Buffer" temporary; MixDiscountCode: Code[20]; MinDiscountQty: Decimal; ActualDiscountAmount: Decimal; ActualItemQty: Decimal; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        MixedDiscountManagement: Codeunit "NPR Mixed Discount Management";
    begin
        TempCurrDiscountCalcBuffer."Discount Code" := MixDiscountCode;
        TempCurrDiscountCalcBuffer."Actual Discount Amount" := ActualDiscountAmount;
        TempCurrDiscountCalcBuffer."Actual Item Qty." := ActualItemQty;
        TempCurrDiscountCalcBuffer."Discount. Min. Quantity" := MinDiscountQty;
        MixedDiscountManagement.FilterNotDiscountedLines(TempSaleLinePOs);
        TempCurrDiscountCalcBuffer."Not Discounted Lines Exist" := not TempSaleLinePOs.IsEmpty;
        if not TempCurrDiscountCalcBuffer."Not Discounted Lines Exist" then
            exit;

        TempSaleLinePOS.CalcSums(Quantity);
        TempCurrDiscountCalcBuffer."Not Discounted Lines Quantity" := TempSaleLinePOS.Quantity;

        TempSaleLinePOS.Reset();
        TempMixedDiscount.SetRange("Mix Type", TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::Combination);
        TempMixedDiscount.SetFilter("Min. Quantity", '<=%1', TempCurrDiscountCalcBuffer."Not Discounted Lines Quantity");
        TempCurrDiscountCalcBuffer.Recalculate := not TempMixedDiscount.IsEmpty;
    end;

    internal procedure CopyDiscountBuffer(var FromDiscountCalcBuffer: Record "NPR Discount Calc. Buffer"; var ToDiscountCalcBuffer: Record "NPR Discount Calc. Buffer")
    var
        DiscountCalcBuffer: Record "NPR Discount Calc. Buffer";
    begin
        DiscountCalcBuffer := FromDiscountCalcBuffer;

        ToDiscountCalcBuffer.Reset();
        if not ToDiscountCalcBuffer.IsEmpty then
            ToDiscountCalcBuffer.DeleteAll();

        if not FromDiscountCalcBuffer.FindSet(false) then
            exit;

        repeat
            ToDiscountCalcBuffer.Init();
            ToDiscountCalcBuffer := FromDiscountCalcBuffer;
            ToDiscountCalcBuffer.Insert();
        until FromDiscountCalcBuffer.Next() = 0;

        FromDiscountCalcBuffer := DiscountCalcBuffer;
    end;
}