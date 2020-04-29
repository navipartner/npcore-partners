codeunit 6151458 "Magento Npxml Item CrossRef"
{
    // MAG2.02/TS  /20170214 CASE 257007 Object created - Return barcode

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get("Xml Template Code","Xml Element Line No.")then
          exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        if not RecRef.Find then
          exit;

        CustomValue := GetItemCrossReferenceNo(RecRef,NpXmlElement."Field No.");
        RecRef.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    var
        Text000: Label 'Unsupported table: %1 %2 - codeunit 6151458  "Magento Npxml Item CrossRef" - NpXml Element: %3 %4';
        NpXmlElement: Record "NpXml Element";

    local procedure GetItemCrossReferenceNo(RecRef: RecordRef;FieldNo: Integer) ItemVariantCode: Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        MagentoItemCustomOption: Record "Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "Magento Item Custom Opt. Value";
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        FieldRef: FieldRef;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        case RecRef.Number of
          DATABASE::"Item Variant":
            begin
              RecRef.SetTable(ItemVariant);
              ItemCrossReference.SetRange("Item No.",ItemVariant."Item No.");
              ItemCrossReference.SetRange("Variant Code",ItemVariant.Code);
              if ItemCrossReference.FindFirst then
                exit(ItemCrossReference."Cross-Reference No.")
              else
                exit(ItemVariant."Item No."+'_'+ItemVariant.Code);
            end;

        end;

        Error(Text000,RecRef.Number,RecRef.Caption,NpXmlElement."Xml Template Code",NpXmlElement."Element Name");
    end;
}

