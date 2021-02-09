codeunit 6151458 "NPR Magento Npxml ItemCrossRef"
{
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get("Xml Template Code", "Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        if not RecRef.Find then
            exit;

        CustomValue := GetItemReferenceNo(RecRef, NpXmlElement."Field No.");
        RecRef.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    var
        Text000: Label 'Unsupported table: %1 %2 - codeunit 6151458  "Magento Npxml Item CrossRef" - NpXml Element: %3 %4';
        NpXmlElement: Record "NPR NpXml Element";

    local procedure GetItemReferenceNo(RecRef: RecordRef; FieldNo: Integer) ItemVariantCode: Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        MagentoItemCustomOption: Record "NPR Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        FieldRef: FieldRef;
        ItemReference: Record "Item Reference";
    begin
        case RecRef.Number of
            DATABASE::"Item Variant":
                begin
                    RecRef.SetTable(ItemVariant);
                    ItemReference.SetRange("Item No.", ItemVariant."Item No.");
                    ItemReference.SetRange("Variant Code", ItemVariant.Code);
                    if ItemReference.FindFirst then
                        exit(ItemReference."Reference No.")
                    else
                        exit(ItemVariant."Item No." + '_' + ItemVariant.Code);
                end;

        end;

        Error(Text000, RecRef.Number, RecRef.Caption, NpXmlElement."Xml Template Code", NpXmlElement."Element Name");
    end;
}

