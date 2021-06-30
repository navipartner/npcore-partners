xmlport 6151404 "NPR Magento Inv. Set Api"
{
    Caption = 'Magento Avail. InventoryExport';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/inventory_set';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(retail_inventory_api)
        {
            MaxOccurs = Once;
            textelement(retail_inventory_request)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textattribute(set_code)
                {

                    trigger OnAfterAssignVariable()
                    begin
                        RISRetailInventorySet.Get(set_code);
                        RISRetailInventorySet.SetRecFilter();
                    end;
                }
                textelement(products)
                {
                    MaxOccurs = Once;
                    tableelement(tempitemvariant; "Item Variant")
                    {
                        MinOccurs = Zero;
                        XmlName = 'product';
                        UseTemporary = true;
                        textattribute(sku)
                        {

                            trigger OnAfterAssignVariable()
                            var
                                TempRetailInventoryBuffer2: Record "NPR RIS Retail Inv. Buffer" temporary;
                                RISRetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
                                Position: Integer;
                            begin
                                TempItemVariant.Init();
                                TempItemVariant."Item No." := CopyStr(sku, 1, MaxStrLen(TempItemVariant."Item No."));

                                Position := StrPos(sku, '_');
                                if Position <> 0 then begin
                                    TempItemVariant."Item No." := CopyStr(DelStr(sku, Position), 1, MaxStrLen(TempItemVariant."Item No."));
                                    TempItemVariant.Code := CopyStr(sku, Position + 1, MaxStrLen(TempItemVariant.Code));
                                end;

                                RISRetailInventorySetMgt.ProcessInventorySet(RISRetailInventorySet, TempItemVariant."Item No.", TempItemVariant.Code, TempRetailInventoryBuffer2);
                                if TempRetailInventoryBuffer2.FindSet() then
                                    repeat
                                        LineNo += 1;
                                        TempRetailInventoryBuffer.Init();
                                        TempRetailInventoryBuffer := TempRetailInventoryBuffer2;
                                        TempRetailInventoryBuffer."Location Filter" := Format(TempRetailInventoryBuffer."Line No.");
                                        TempRetailInventoryBuffer."Line No." := LineNo;
                                        TempRetailInventoryBuffer.Insert();
                                    until TempRetailInventoryBuffer2.Next() = 0;
                            end;
                        }
                    }
                }

                trigger OnBeforePassVariable()
                begin
                    currXMLport.Skip();
                end;
            }
            tableelement(risretailinventoryset; "NPR RIS Retail Inv. Set")
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'retail_inventory_response';
                fieldattribute(code; RISRetailInventorySet.Code)
                {
                }
                fieldelement(description; RISRetailInventorySet.Description)
                {
                }
                tableelement(risretailinventorysetentry; "NPR RIS Retail Inv. Set Entry")
                {
                    AutoSave = false;
                    LinkFields = "Set Code" = FIELD(Code);
                    LinkTable = RISRetailInventorySet;
                    XmlName = 'retail_inventory_entry';
                    SourceTableView = SORTING("Set Code", "Line No.") WHERE("Company Name" = FILTER(<> ''), Enabled = CONST(true));
                    fieldattribute(line_no; RISRetailInventorySetEntry."Line No.")
                    {
                    }
                    fieldelement(company_name; RISRetailInventorySetEntry."Company Name")
                    {
                    }
                    textelement(products2)
                    {
                        MaxOccurs = Once;
                        XmlName = 'products';
                        tableelement(tempitemvariant2; "Item Variant")
                        {
                            MinOccurs = Zero;
                            XmlName = 'product';
                            UseTemporary = true;
                            textelement(sku2)
                            {
                                XmlName = 'sku';

                                trigger OnBeforePassVariable()
                                begin
                                    sku2 := TempItemVariant2."Item No.";
                                    if TempItemVariant2.Code <> '' then
                                        sku2 += '_' + TempItemVariant2.Code;
                                end;
                            }
                            textelement(inventory)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    Clear(TempRetailInventoryBuffer);
                                    TempRetailInventoryBuffer.SetRange("Set Code", RISRetailInventorySetEntry."Set Code");
                                    TempRetailInventoryBuffer.SetRange("Location Filter", Format(RISRetailInventorySetEntry."Line No."));
                                    TempRetailInventoryBuffer.SetRange("Item Filter", TempItemVariant2."Item No.");
                                    TempRetailInventoryBuffer.SetFilter("Variant Filter", '=%1', TempItemVariant2.Code);
                                    if TempRetailInventoryBuffer.FindFirst() then;
                                    inventory := Format(TempRetailInventoryBuffer.Inventory, 0, 9);
                                end;
                            }

                            trigger OnPreXmlItem()
                            begin
                                TempItemVariant2.Copy(TempItemVariant, true);
                            end;
                        }
                    }
                }

                trigger OnAfterInitRecord()
                begin
                    currXMLport.Skip();
                end;
            }
        }
    }

    var
        TempRetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary;
        LineNo: Integer;
}