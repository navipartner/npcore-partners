xmlport 6151405 "NPR Magento Store Inv."
{
    Caption = 'Collect Store Inventory';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/magento_collect_store_inventory';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(store_inventory)
        {
            MaxOccurs = Once;
            textelement(collect_request)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(stock_status)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;

                    trigger OnAfterAssignVariable()
                    begin
                        case LowerCase(stock_status) of
                            'in_stock', '1', 'true', 'yes':
                                begin
                                    StockStatusFilter := StockStatusFilter::"In Stock";
                                end;
                            'out_of_stock', '0', 'false', 'no':
                                begin
                                    StockStatusFilter := StockStatusFilter::"Out of Stock";
                                end;
                            else
                                StockStatusFilter := StockStatusFilter::Any;
                        end;
                    end;
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
                        fieldattribute(item_no; TempItem.Description)
                        {
                        }
                        fieldattribute(variant_code; TempItem."Description 2")
                        {
                            Occurrence = Optional;
                        }
                        fieldelement(requested_qty; TempItem."Reorder Quantity")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            if ItemNo = '' then
                                ItemNo := '0000000001'
                            else
                                ItemNo := IncStr(ItemNo);
                            TempItem."No." := ItemNo;
                        end;

                        trigger OnBeforeInsertRecord()
                        var
                            ItemVariant: Record "Item Variant";
                        begin
                            TempItem."Search Description" := UpperCase(CopyStr(TempItem.Description, 1, MaxStrLen(TempItem."No.")));
                            if TempItem."Description 2" <> '' then
                                TempItem."Search Description" += '_' + UpperCase(CopyStr(TempItem."Description 2", 1, MaxStrLen(ItemVariant.Code)));

                            if TempItem."Reorder Quantity" <= 0 then
                                TempItem."Reorder Quantity" := 1;
                        end;
                    }
                }
                textelement(request_stores)
                {
                    MaxOccurs = Once;
                    XmlName = 'stores';
                    tableelement(tempnpcsstore; "NPR NpCs Store")
                    {
                        MinOccurs = Zero;
                        XmlName = 'store';
                        UseTemporary = true;
                        fieldattribute(code; TempNpCsStore.Code)
                        {
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            if TempNpCsStore.Code = MagentoSetup."NpCs From Store Code" then
                                currXMLport.Skip();
                        end;
                    }
                }

                trigger OnBeforePassVariable()
                begin
                    currXMLport.Skip();
                end;
            }
            textelement(collect_response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(response_stores)
                {
                    MaxOccurs = Once;
                    XmlName = 'stores';
                    tableelement(tempnpcsstore2; "NPR NpCs Store")
                    {
                        MinOccurs = Zero;
                        XmlName = 'store';
                        UseTemporary = true;
                        fieldattribute(code; TempNpCsStore2.Code)
                        {
                        }
                        textelement(all_products_in_stock)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                all_products_in_stock := Format(AllProductsInStock(TempNpCsStore2), 0, 9);
                            end;
                        }
                        textelement(store_products)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'products';
                            tableelement(tempitem2; Item)
                            {
                                MinOccurs = Zero;
                                XmlName = 'product';
                                UseTemporary = true;
                                fieldattribute(item_no; TempItem2.Description)
                                {
                                }
                                fieldattribute(variant_code; TempItem2."Description 2")
                                {
                                    Occurrence = Optional;

                                    trigger OnBeforePassField()
                                    begin
                                        if TempItem2."Description 2" = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(iteminventory)
                                {
                                    XmlName = 'inventory';

                                    trigger OnBeforePassVariable()
                                    begin
                                        Clear(TempNpCsStoreInventoryBuffer);
                                        if TempNpCsStoreInventoryBuffer.Get(TempNpCsStore2.Code, TempItem2."Search Description") then;
                                        ItemInventory := Format(TempNpCsStoreInventoryBuffer.Inventory, 0, 9);
                                    end;
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    Clear(TempNpCsStoreInventoryBuffer);
                                    if TempNpCsStoreInventoryBuffer.Get(TempNpCsStore2.Code, TempItem2."Search Description") then;
                                    case StockStatusFilter of
                                        StockStatusFilter::"In Stock":
                                            begin
                                                if not TempNpCsStoreInventoryBuffer."In Stock" then
                                                    currXMLport.Skip();
                                            end;
                                        StockStatusFilter::"Out of Stock":
                                            begin
                                                if TempNpCsStoreInventoryBuffer."In Stock" then
                                                    currXMLport.Skip();
                                            end;
                                    end;
                                end;

                                trigger OnPreXmlItem()
                                begin
                                    TempItem2.Copy(TempItem, true);
                                end;
                            }
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not HasItems(TempNpCsStore2) then
                                currXMLport.Skip();
                        end;
                    }
                }

                trigger OnBeforePassVariable()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
                begin
                    Clear(TempNpCsStore);
                    if TempNpCsStore.IsEmpty then
                        InitAllStores();

                    Clear(TempItem);
                    if TempItem.IsEmpty then
                        InitAllItems();

                    Clear(TempNpCsStore);
                    if TempNpCsStore.FindSet() then
                        repeat
                            Store2InventoryBuffer();
                        until TempNpCsStore.Next() = 0;

                    NpCsStoreMgt.SetBufferInventory(TempNpCsStoreInventoryBuffer);
                    TempNpCsStore2.Copy(TempNpCsStore, true);
                end;

                trigger OnAfterAssignVariable()
                begin
                    currXMLport.Skip();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        if MagentoSetup.Get() then;
    end;

    var
        MagentoSetup: Record "NPR Magento Setup";
        TempNpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary;
        ItemNo: Code[20];
        StockStatusFilter: Option Any,"In Stock","Out of Stock";

    local procedure Store2InventoryBuffer()
    begin
        TempItem.FindSet();
        repeat
            if not TempNpCsStoreInventoryBuffer.Get(TempNpCsStore.Code, TempItem."Search Description") then begin
                TempNpCsStoreInventoryBuffer.Init();
                TempNpCsStoreInventoryBuffer."Store Code" := TempNpCsStore.Code;
                TempNpCsStoreInventoryBuffer.Sku := TempItem."Search Description";
                TempNpCsStoreInventoryBuffer.Quantity := TempItem."Reorder Quantity";
                TempNpCsStoreInventoryBuffer.Insert();
            end;
        until TempItem.Next() = 0;
    end;

    local procedure InitAllStores()
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        NpCsStore.SetFilter(Code, '<>%1', MagentoSetup."NpCs From Store Code");
        if NpCsStore.FindSet() then
            repeat
                TempNpCsStore.Init();
                TempNpCsStore := NpCsStore;
                TempNpCsStore.Insert();
            until NpCsStore.Next() = 0;
    end;

    local procedure InitAllItems()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Sku: Text;
        LocalItemNo: Code[20];
    begin
        LocalItemNo := '0000000001';

        Item.SetRange("NPR Magento Item", true);
        Item.SetRange(Blocked, false);
        if Item.FindSet() then
            repeat
                ItemVariant.SetRange("Item No.", Item."No.");
                ItemVariant.SetRange("NPR Blocked", false);
                if ItemVariant.FindSet() then begin
                    repeat
                        Sku := ItemVariant."Item No." + '_' + ItemVariant.Code;
                        LocalItemNo := IncStr(LocalItemNo);
                        TempItem.Init();
                        TempItem."No." := LocalItemNo;
                        TempItem."Search Description" := Sku;
                        TempItem.Description := ItemVariant."Item No.";
                        TempItem."Description 2" := ItemVariant.Code;
                        TempItem."Reorder Quantity" := 1;
                        TempItem.Insert();
                    until ItemVariant.Next() = 0;
                end else begin
                    Sku := Item."No.";
                    LocalItemNo := IncStr(LocalItemNo);
                    TempItem.Init();
                    TempItem."No." := LocalItemNo;
                    TempItem."Search Description" := Sku;
                    TempItem.Description := Item."No.";
                    TempItem."Description 2" := '';
                    TempItem."Reorder Quantity" := 1;
                    TempItem.Insert();
                end;
            until Item.Next() = 0;
    end;

    local procedure HasItems(NpCsStore: Record "NPR NpCs Store"): Boolean
    begin
        Clear(TempNpCsStoreInventoryBuffer);
        TempNpCsStoreInventoryBuffer.SetRange("Store Code", NpCsStore.Code);
        case StockStatusFilter of
            StockStatusFilter::"In Stock":
                begin
                    TempNpCsStoreInventoryBuffer.SetRange("In Stock", true);
                end;
            StockStatusFilter::"Out of Stock":
                begin
                    TempNpCsStoreInventoryBuffer.SetRange("In Stock", false);
                end;
        end;

        exit(TempNpCsStoreInventoryBuffer.FindFirst());
    end;

    local procedure AllProductsInStock(NpCsStore: Record "NPR NpCs Store"): Boolean
    begin
        Clear(TempNpCsStoreInventoryBuffer);
        TempNpCsStoreInventoryBuffer.SetRange("Store Code", NpCsStore.Code);
        TempNpCsStoreInventoryBuffer.SetRange("In Stock", false);
        exit(TempNpCsStoreInventoryBuffer.IsEmpty());
    end;
}