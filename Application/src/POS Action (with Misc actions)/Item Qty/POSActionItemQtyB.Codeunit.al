codeunit 6151375 "NPR POS Action: Item Qty. B"
{
    Access = Internal;

    procedure FindItem(ItemNoBegin: Integer; ItemNoEnd: Integer; Barcode: Text; var Item: Record Item): Boolean
    var
        ItemNo: Text;
    begin
        if ItemNoBegin <= 0 then
            exit(false);
        if ItemNoBegin > ItemNoEnd then
            exit(false);

        if Barcode = '' then
            exit(false);

        ItemNo := CopyStr(Barcode, ItemNoBegin, ItemNoEnd - ItemNoBegin + 1);
        if StrLen(ItemNo) > MaxStrLen(Item."No.") then
            exit(false);

        exit(Item.Get(ItemNo));

    end;

    procedure FindQty(QuantityBegin: Integer; QuantityEnd: Integer; QuantityDecimalPosition: Integer; Barcode: Text; var Quantity: Decimal): Boolean
    begin
        if Barcode = '' then
            exit;

        if QuantityBegin <= 0 then
            exit(false);
        if QuantityBegin > QuantityEnd then
            exit(false);

        Barcode := CopyStr(Barcode, QuantityBegin, QuantityEnd - QuantityBegin + 1);
        if not Evaluate(Quantity, Barcode) then
            exit(false);

        if (QuantityDecimalPosition >= QuantityBegin) and (QuantityDecimalPosition <= QuantityEnd) then
            Quantity /= Power(10, QuantityEnd - QuantityDecimalPosition + 1);

        exit(true);

    end;
}