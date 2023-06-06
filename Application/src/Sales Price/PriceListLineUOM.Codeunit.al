codeunit 6150961 "NPR Price List Line UOM"
{
    Access = Internal;

    procedure GetUnitPriceFromSalesPriceList(ItemNo: Code[20]; UnitofMeasure: Code[10]): Decimal
    var
#IF (BC17 OR BC18 OR BC19 OR BC20)
#pragma warning disable AL0432
        SalesPrice: Record "Sales Price";
#pragma warning restore AL0432
#ENDIF
        PriceListLine: Record "Price List Line";
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        case PriceCalculationMgt.IsExtendedPriceCalculationEnabled() of
            true:
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
            false:
#IF (BC17 OR BC18 OR BC19 OR BC20)
                begin
                    SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"All Customers");
                    SalesPrice.SetFilter("Starting Date", '%1|<=%2', 0D, Today);
                    SalesPrice.SetFilter("Ending Date", '%1|>=%2', 0D, Today);
                    SalesPrice.SetRange("Item No.", ItemNo);
                    SalesPrice.SetRange("Unit of Measure Code", UnitOfMeasure);
                    if SalesPrice.FindFirst() then
                        exit(SalesPrice."Unit Price");
                end;
#ELSE
                exit;
#ENDIF
        end;
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
