xmlport 6151198 "NPR NpCs Store Inv."
{
    Caption = 'Collect Store Inventory';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/collect_store_inventory';
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
                textelement(products)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tempitem; Item)
                    {
                        MinOccurs = Zero;
                        XmlName = 'product';
                        UseTemporary = true;
                        fieldattribute(sku; TempItem."Description 2")
                        {
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

                        trigger OnAfterInsertRecord()
                        begin
                            Store2InventoryBuffer();
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
                                fieldattribute(sku; TempItem2.Description)
                                {
                                }
                                textelement(iteminventory)
                                {
                                    XmlName = 'inventory';

                                    trigger OnBeforePassVariable()
                                    begin
                                        Clear(NpCsStoreInventoryBuffer);
                                        if NpCsStoreInventoryBuffer.Get(TempNpCsStore2.Code, TempItem2.Description) then;
                                        ItemInventory := Format(NpCsStoreInventoryBuffer.Inventory, 0, 9);
                                    end;
                                }

                                trigger OnPreXmlItem()
                                begin
                                    TempItem2.Copy(TempItem, true);
                                end;
                            }
                        }
                    }
                }

                trigger OnBeforePassVariable()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
                begin
                    NpCsStoreMgt.SetBufferInventory(NpCsStoreInventoryBuffer);
                    TempNpCsStore2.Copy(TempNpCsStore, true);
                end;

                trigger OnAfterAssignVariable()
                begin
                    currXMLport.Skip();
                end;
            }
        }
    }

    var
        NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary;
        ItemNo: Code[20];

    local procedure Store2InventoryBuffer()
    begin
        TempItem.FindSet();
        repeat
            if not NpCsStoreInventoryBuffer.Get(TempNpCsStore.Code, TempItem."Description 2") then begin
                NpCsStoreInventoryBuffer.Init();
                NpCsStoreInventoryBuffer."Store Code" := TempNpCsStore.Code;
                NpCsStoreInventoryBuffer.Sku := tempitem."Description 2";
                NpCsStoreInventoryBuffer.Insert();
            end;
        until TempItem.Next() = 0;
    end;
}

