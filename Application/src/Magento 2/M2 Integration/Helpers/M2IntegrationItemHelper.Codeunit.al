codeunit 6150989 "NPR M2 Integration Item Helper"
{
    Access = Internal;

#if not (BC17 or BC18 or BC19 or BC20)
    internal procedure Sku2ItemNoVariant(Sku: Text[250]; var ItemNo: Code[20]; var VariantCode: Code[10])
    var
        Parts: List of [Text];
        ItemNoTxt: Text[20];
        VariantCodeTxt: Text[10];
    begin
        Clear(ItemNo);
        Clear(VariantCode);

        if (StrPos(Sku, '_') = 0) then begin
#pragma warning disable AA0139
            ItemNo := Sku;
#pragma warning restore AA0139
            exit;
        end;

        Parts := Sku.Split('_');

#pragma warning disable AA0139
        Parts.Get(1, ItemNoTxt);
        Parts.Get(2, VariantCodeTxt);
#pragma warning restore AA0139

        ItemNo := ItemNoTxt;
        VariantCode := VariantCodeTxt;
    end;

    internal procedure IsMagentoItem(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        exit((Item.Get(ItemNo)) and (Item."NPR Magento Item"));
    end;
#endif
}