xmlport 6151199 "NpCs Local Inventory"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

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
                tableelement(tempitem;Item)
                {
                    MinOccurs = Zero;
                    XmlName = 'product';
                    UseTemporary = true;
                    fieldattribute(sku;TempItem.Description)
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

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        ItemNo: Code[20];

    local procedure CalcInventory() Inventory: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        Sku2ItemVariant(TempItem.Description,ItemVariant);
        if not Item.Get(ItemVariant."Item No.") then
          exit(0);

        Item.SetFilter("Variant Filter",ItemVariant.Code);
        Item.SetFilter("Location Filter",location_filter);
        Item.CalcFields(Inventory,"Qty. on Sales Order");
        Inventory := Item.Inventory - Item."Qty. on Sales Order";
        exit(Inventory);
    end;

    local procedure Sku2ItemVariant(Sku: Text;var ItemVariant: Record "Item Variant")
    var
        ItemCrossReference: Record "Item Cross Reference";
        NpCsDocumentMapping: Record "NpCs Document Mapping";
        ItemNo: Text;
        VariantCode: Text;
        Position: Integer;
        CrossRefNo: Text;
    begin
        ItemNo := UpperCase(Sku);
        Position := StrPos(ItemNo,'_');
        if Position > 0 then begin
          VariantCode := CopyStr(ItemNo,Position + 1);
          ItemNo := DelStr(ItemNo,Position);
        end;

        ItemVariant."Item No." := CopyStr(ItemNo,1,MaxStrLen(ItemVariant."Item No."));
        ItemVariant.Code := CopyStr(VariantCode,1,MaxStrLen(ItemVariant.Code));
        if ItemVariant.Find then
          exit;

        CrossRefNo := Sku;
        if StrLen(Sku) <= MaxStrLen(NpCsDocumentMapping."From No.") then begin
          NpCsDocumentMapping.SetRange("From No.",Sku);
          NpCsDocumentMapping.SetRange(Type,NpCsDocumentMapping.Type::"Item Cross Reference No.");
          NpCsDocumentMapping.SetFilter("To No.",'<>%1','');
          if NpCsDocumentMapping.FindFirst then
            CrossRefNo := NpCsDocumentMapping."To No.";
        end;

        if StrLen(CrossRefNo) <= MaxStrLen(ItemCrossReference."Cross-Reference No.") then begin
          ItemCrossReference.SetRange("Cross-Reference No.",CrossRefNo);
          ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
          ItemCrossReference.SetRange("Discontinue Bar Code",false);
          if ItemCrossReference.FindFirst then begin
            ItemVariant."Item No." := ItemCrossReference."Item No.";
            ItemVariant.Code := ItemCrossReference."Variant Code";
            exit;
          end;
        end;
    end;
}

