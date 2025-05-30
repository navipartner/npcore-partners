﻿codeunit 6151457 "NPR Magento NpXml Ext. Item"
{
    Access = Internal;
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
        if not RecRef.Find() then
            exit;

        CustomValue := GetVariantCode(RecRef);
        RecRef.Close();

        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;

    var
        Text000: Label 'Unsupported table: %1 %2 - codeunit 6059834 "NpXml Value External Item No." - NpXml Element: %3 %4';
        NpXmlElement: Record "NPR NpXml Element";

    local procedure GetVariantCode(RecRef: RecordRef): Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        MagentoItemCustomOption: Record "NPR Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
        PriceListLine: Record "Price List Line";
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
            Database::"Price List Line":
                begin
                    RecRef.SetTable(PriceListLine);
                    if PriceListLine."Variant Code" <> '' then
                        exit(PriceListLine."Asset No." + '_' + PriceListLine."Variant Code")
                    else
                        exit(PriceListLine."Asset No.");
                end;


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
        end;

        Error(Text000, RecRef.Number, RecRef.Caption, NpXmlElement."Xml Template Code", NpXmlElement."Element Name");
    end;
}
