xmlport 6151199 "NPR NpCs Local Inventory"
{
    Caption = 'Collect Local Inventory';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/collect_local_inventory';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(store_inventory)
        {
            textelement(location_filter)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
            }
            textelement(products)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                tableelement(tempitem; Item)
                {
                    MinOccurs = Zero;
                    XmlName = 'product';
                    UseTemporary = true;
                    fieldattribute(sku; TempItem.Description)
                    {
                    }
                    textelement(iteminventory)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'inventory';

                        trigger OnBeforePassVariable()
                        begin
                            ItemInventory := Format(CalcInventory());
                        end;
                    }

                    trigger OnAfterInitRecord()
                    begin
                        if ItemNo = '' then
                            ItemNo := '0'
                        else
                            ItemNo := IncStr(ItemNo);
                        TempItem."No." := ItemNo;
                    end;
                }
            }
        }
    }

    var
        ItemNo: Code[20];

    local procedure CalcInventory() Inventory: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        Sku2ItemVariant(TempItem.Description, ItemVariant);
        if not Item.Get(ItemVariant."Item No.") then
            exit(0);

        Item.SetFilter("Variant Filter", ItemVariant.Code);
        Item.SetFilter("Location Filter", location_filter);
        Item.CalcFields(Inventory, "Qty. on Sales Order");
        Inventory := Item.Inventory - Item."Qty. on Sales Order";
        exit(Inventory);
    end;

    local procedure Sku2ItemVariant(Sku: Text; var ItemVariant: Record "Item Variant")
    var
        ItemReference: Record "Item Reference";
        NpCsDocumentMapping: Record "NPR NpCs Document Mapping";
        ItemNo: Text;
        VariantCode: Text;
        Position: Integer;
        ItemRefNo: Text;
    begin
        ItemNo := UpperCase(Sku);
        Position := StrPos(ItemNo, '_');
        if Position > 0 then begin
            VariantCode := CopyStr(ItemNo, Position + 1);
            ItemNo := DelStr(ItemNo, Position);
        end;

        ItemVariant."Item No." := CopyStr(ItemNo, 1, MaxStrLen(ItemVariant."Item No."));
        ItemVariant.Code := CopyStr(VariantCode, 1, MaxStrLen(ItemVariant.Code));
        if ItemVariant.Find then
            exit;

        ItemRefNo := Sku;
        if StrLen(Sku) <= MaxStrLen(NpCsDocumentMapping."From No.") then begin
            NpCsDocumentMapping.SetRange("From No.", Sku);
            NpCsDocumentMapping.SetRange(Type, NpCsDocumentMapping.Type::"Item Cross Reference No.");
            NpCsDocumentMapping.SetFilter("To No.", '<>%1', '');
            if NpCsDocumentMapping.FindFirst then
                ItemRefNo := NpCsDocumentMapping."To No.";
        end;

        if StrLen(ItemRefNo) <= MaxStrLen(ItemReference."Reference No.") then begin
            ItemReference.SetRange("Reference No.", ItemRefNo);
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetRange("Discontinue Bar Code", false);
            if ItemReference.FindFirst then begin
                ItemVariant."Item No." := ItemReference."Item No.";
                ItemVariant.Code := ItemReference."Variant Code";
                exit;
            end;
        end;
    end;
}

