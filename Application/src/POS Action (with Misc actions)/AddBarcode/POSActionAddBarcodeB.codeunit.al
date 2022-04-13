codeunit 6059828 "NPR POS Action: Add Barcode B"
{
    Access = Internal;

    procedure InputBarcode(ReferenceNo: Code[50]; ItemNo: code[20]; VariantCode: Code[10]; ItemUOM: Code[10])
    var
        ItemVariant: Record "Item Variant";
        ItemReference: Record "Item Reference";
        Item: Record Item;
        RecordErr: Label 'Record %1 already exists';
        BarcodeAddedMsg: Label 'Added bar code %1 to item no. %2.';
    begin

        Item.Get(ItemNo);
        ItemReference.Init();
        ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
        ItemReference."Reference No." := ReferenceNo;
        ItemReference."Item No." := Item."No.";
        ItemReference.Description := Item.Description;
        if VariantCode <> '' then begin
            ItemVariant.Get(ItemNo, VariantCode);
            ItemReference."Variant Code" := VariantCode;
            if ItemVariant.Description <> '' then
                ItemReference.Description := ItemVariant.Description;
        end;
        ItemReference."Unit of Measure" := ItemUOM;
        if ItemReference.Insert(true) then
            Message(BarcodeAddedMsg, ReferenceNo, ItemNo)
        else
            Message(RecordErr, ItemReference.RecordId);
    end;

}