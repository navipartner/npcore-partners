codeunit 6150961 "NPR Price List Line UOM"
{
    Access = Internal;

    procedure GetUnitPriceFromSalesPriceList(ItemNo: Code[20]; UnitofMeasure: Code[10]): Decimal
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.SetRange(Status, PriceListLine.Status::Active);
        PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"All Customers");
        PriceListLine.SetRange("Asset Type", "Price Asset Type"::Item);
        PriceListLine.SetFilter("Starting Date", '%1|<=%2', 0D, Today);
        PriceListLine.SetFilter("Ending Date", '%1|>=%2', 0D, Today);
#IF (BC17 OR BC18 OR BC19)
        PriceListLine.SetRange("Asset No.", ItemNo);
#ELSE
        PriceListLine.SetRange("Product No.", ItemNo);
#ENDIF
        PriceListLine.SetRange("Unit of Measure Code", UnitOfMeasure);
        if PriceListLine.FindFirst() then
            exit(PriceListLine."Unit Price");
    end;

    procedure GetQtyPerUOMFromUOM(ItemNo: Code[20]; UOMCode: Code[10]): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ReturnQtyPerUOM: Decimal;
    begin
        if ItemUnitOfMeasure.Get(ItemNo, UOMCode) then;
        ReturnQtyPerUOM := ItemUnitOfMeasure."Qty. per Unit of Measure";
        exit(ReturnQtyPerUOM);
    end;
}
