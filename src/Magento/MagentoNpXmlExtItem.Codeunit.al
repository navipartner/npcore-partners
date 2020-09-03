codeunit 6151457 "NPR Magento NpXml Ext. Item"
{
    // MAG1.21/TS/20151019  CASE 222157 Object created - Custom Values for NpXml for Variant Code
    // MAG1.22/TR/20160420 CASE 238563 Added Custom Option
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

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

        CustomValue := GetVariantCode(RecRef, NpXmlElement."Field No.");
        RecRef.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    var
        Text000: Label 'Unsupported table: %1 %2 - codeunit 6059834 "NpXml Value External Item No." - NpXml Element: %3 %4';
        NpXmlElement: Record "NPR NpXml Element";

    local procedure GetVariantCode(RecRef: RecordRef; FieldNo: Integer) ItemVariantCode: Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        MagentoItemCustomOption: Record "NPR Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        FieldRef: FieldRef;
    begin
        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    exit(Item."No.");
                end;
            DATABASE::"Item Variant":
                begin
                    RecRef.SetTable(ItemVariant);
                    if ItemVariant.Code <> '' then
                        exit(ItemVariant."Item No." + '_' + ItemVariant.Code)
                    else
                        exit(ItemVariant."Item No.");
                end;
            DATABASE::"Sales Price":
                begin
                    RecRef.SetTable(SalesPrice);
                    if SalesPrice."Variant Code" <> '' then
                        exit(SalesPrice."Item No." + '_' + SalesPrice."Variant Code")
                    else
                        exit(SalesPrice."Item No.");
                end;
            DATABASE::"Sales Line Discount":
                begin
                    RecRef.SetTable(SalesLineDiscount);
                    SalesLineDiscount.SetRange(Type, SalesLineDiscount.Type::Item);
                    if SalesLineDiscount."Variant Code" <> '' then
                        exit(SalesLineDiscount.Code + '_' + SalesLineDiscount."Variant Code")
                    else
                        exit(SalesLineDiscount.Code);
                end;

            //-MAG1.22
            DATABASE::"NPR Magento Item Custom Option":
                begin
                    RecRef.SetTable(MagentoItemCustomOption);
                    exit(MagentoItemCustomOption."Item No." + '#' + MagentoItemCustomOption."Custom Option No.");
                end;
            DATABASE::"NPR Magento Itm Cstm Opt.Value":
                begin
                    RecRef.SetTable(MagentoItemCustomOptValue);
                    exit(MagentoItemCustomOptValue."Item No." + '#' + MagentoItemCustomOptValue."Custom Option No." + '_' +
                         Format(MagentoItemCustomOptValue."Custom Option Value Line No."));
                end;
        //+MAG1.22
        end;

        Error(Text000, RecRef.Number, RecRef.Caption, NpXmlElement."Xml Template Code", NpXmlElement."Element Name");
    end;
}

