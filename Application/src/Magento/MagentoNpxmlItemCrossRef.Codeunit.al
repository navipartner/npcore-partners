codeunit 6151458 "NPR Magento Npxml ItemCrossRef"
{
    // MAG2.02/TS  /20170214 CASE 257007 Object created - Return barcode

    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        RecRef: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");
        if not RecRef.Find then
            exit;

        CustomValue := GetItemCrossReferenceNo(RecRef, NpXmlElement."Field No.");
        RecRef.Close;

        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify;
    end;

    var
        Text000: Label 'Unsupported table: %1 %2 - codeunit 6151458  "Magento Npxml Item CrossRef" - NpXml Element: %3 %4';
        NpXmlElement: Record "NPR NpXml Element";

    local procedure GetItemCrossReferenceNo(RecRef: RecordRef; FieldNo: Integer) ItemVariantCode: Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
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