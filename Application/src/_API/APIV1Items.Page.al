page 6014501 "NPR APIV1 - Items"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'item';
    EntitySetName = 'items';
    EntityCaption = 'Item';
    EntitySetCaption = 'Items';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }

                field(number; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }

                field(no2; Rec."No. 2")
                {
                    Caption = 'No. 2', Locked = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'DisplayName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(displayName2; Rec."Description 2")
                {
                    Caption = 'DisplayName2', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Description 2"));
                    end;
                }

                field(searchDescription; Rec."Search Description")
                {
                    Caption = 'Search Description', Locked = true;
                }

                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Type));
                    end;
                }

                field(priceUnitConversion; Rec."Price Unit Conversion")
                {
                    Caption = 'Price Unit Conversion', Locked = true;
                }

                field(statisticsGroup; Rec."Statistics Group")
                {
                    Caption = 'Statistics Group', Locked = true;
                }

                field(commissionGroup; Rec."Commission Group")
                {
                    Caption = 'Commission Group', Locked = true;
                }

                field(reorderPoint; Rec."Reorder Point")
                {
                    Caption = 'Reorder Point', Locked = true;
                }

                field(maximumInventory; Rec."Maximum Inventory")
                {
                    Caption = 'Maximum Inventory', Locked = true;
                }

                field(reorderQuantity; Rec."Reorder Quantity")
                {
                    Caption = 'Reorder Quantity', Locked = true;
                }

                field(alternativeItemNo; Rec."Alternative Item No.")
                {
                    Caption = 'Alternative Item No.', Locked = true;
                }

                field(grossWeight; Rec."Gross Weight")
                {
                    Caption = 'Gross Weight', Locked = true;
                }

                field(netWeight; Rec."Net Weight")
                {
                    Caption = 'Net Weight', Locked = true;
                }

                field(unitsPerParcel; Rec."Units per Parcel")
                {
                    Caption = 'Units per Parcel', Locked = true;
                }

                field(unitVolume; Rec."Unit Volume")
                {
                    Caption = 'Unit Volume', Locked = true;
                }

                field(freightType; Rec."Freight Type")
                {
                    Caption = 'Freight Type', Locked = true;
                }

                field(countryRegionPurchasedCode; Rec."Country/Region Purchased Code")
                {
                    Caption = 'Country/Region Purchased Code', Locked = true;
                }

                field(budgetQuantity; Rec."Budget Quantity")
                {
                    Caption = 'Budget Quantity', Locked = true;
                }

                field(budgetedAmount; Rec."Budgeted Amount")
                {
                    Caption = 'Budgeted Amount', Locked = true;
                }

                field(budgetProfit; Rec."Budget Profit")
                {
                    Caption = 'Budget Profit', Locked = true;
                }

                field(durability; Rec.Durability)
                {
                    Caption = 'Durability', Locked = true;
                }

                field(allowInvoiceDisc; Rec."Allow Invoice Disc.")
                {
                    Caption = 'Allow Invoice Disc.', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Allow Invoice Disc."));
                    end;
                }

                field(priceProfitCalculation; Rec."Price/Profit Calculation")
                {
                    Caption = 'Price/Profit Calculation', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Price/Profit Calculation"));
                    end;
                }

                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor No."));
                    end;
                }

                field(vendorItemNo; Rec."Vendor Item No.")
                {
                    Caption = 'Vendor Item No.', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor Item No."));
                    end;
                }
                field(itemCategoryId; Rec."Item Category Id")
                {
                    Caption = 'Item Category Id', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Item Category Id" = BlankGUID then
                            Rec."Item Category Code" := ''
                        else begin
                            if not ItemCategory.GetBySystemId(Rec."Item Category Id") then
                                Error(ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr);

                            Rec."Item Category Code" := ItemCategory.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Item Category Code"));
                        RegisterFieldSet(Rec.FieldNo("Item Category Id"));
                    end;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code', Locked = true;

                    trigger OnValidate()
                    begin
                        if ItemCategory.Code <> '' then begin
                            if ItemCategory.Code <> Rec."Item Category Code" then
                                Error(ItemCategoriesValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Item Category Code" = '' then
                            Rec."Item Category Id" := BlankGUID
                        else begin
                            if not ItemCategory.Get(Rec."Item Category Code") then
                                Error(ItemCategoryCodeDoesNotMatchATaxGroupErr);

                            Rec."Item Category Id" := ItemCategory.SystemId;
                        end;
                    end;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }

                field(blockReason; Rec."Block Reason")
                {
                    Caption = 'Block Reason', Locked = true;
                }

                field(countryRegionOfOriginCode; Rec."Country/Region of Origin Code")
                {
                    Caption = 'Country/Region of Origin Code', Locked = true;
                }

                field(automaticExtTexts; Rec."Automatic Ext. Texts")
                {
                    Caption = 'Automatic Ext. Texts', Locked = true;
                }

                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No. Series', Locked = true;
                }

                field(stockoutWarning; Rec."Stockout Warning")
                {
                    Caption = 'Stockout Warning', Locked = true;
                }

                field(preventNegativeInventory; Rec."Prevent Negative Inventory")
                {
                    Caption = 'Prevent Negative Inventory', Locked = true;
                }

                field(roundingPrecision; Rec."Rounding Precision")
                {
                    Caption = 'Rounding Precision', Locked = true;
                }

                field(gtin; Rec.GTIN)
                {
                    Caption = 'GTIN', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(GTIN));
                    end;
                }
                field(inventory; InventoryValue)
                {
                    Caption = 'Inventory', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Inventory));
                    end;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit Price"));
                    end;
                }

                field(unitListPrice; Rec."Unit List Price")
                {
                    Caption = 'Unit List Price', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit List Price"));
                    end;
                }
                field(priceIncludesTax; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes Tax', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Price Includes VAT"));
                    end;
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'Unit Cost', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit Cost"));
                    end;
                }

                field(standardCost; Rec."Standard Cost")
                {
                    Caption = 'Standard Cost', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Standard Cost"));
                    end;
                }

                field(lastDirectCost; Rec."Last Direct Cost")
                {
                    Caption = 'Last Direct Cost', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Last Direct Cost"));
                    end;
                }

                field(taxGroupId; Rec."Tax Group Id")
                {
                    Caption = 'Tax Group Id', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Tax Group Id" = BlankGUID then
                            Rec."Tax Group Code" := ''
                        else begin
                            if not TaxGroup.GetBySystemId(Rec."Tax Group Id") then
                                Error(TaxGroupIdDoesNotMatchATaxGroupErr);

                            Rec."Tax Group Code" := TaxGroup.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Tax Group Code"));
                        RegisterFieldSet(Rec.FieldNo("Tax Group Id"));
                    end;
                }
                field(taxGroupCode; Rec."Tax Group Code")
                {
                    Caption = 'Tax Group Code', Locked = true;

                    trigger OnValidate()
                    begin
                        if TaxGroup.Code <> '' then begin
                            if TaxGroup.Code <> Rec."Tax Group Code" then
                                Error(TaxGroupValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Tax Group Code" = '' then
                            Rec."Tax Group Id" := BlankGUID
                        else begin
                            if not TaxGroup.Get(Rec."Tax Group Code") then
                                Error(TaxGroupCodeDoesNotMatchATaxGroupErr);

                            Rec."Tax Group Id" := TaxGroup.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Tax Group Code"));
                        RegisterFieldSet(Rec.FieldNo("Tax Group Id"));
                    end;
                }

                field(tariffNo; Rec."Tariff No.")
                {
                    Caption = 'Tariff No.', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tariff No."));
                    end;
                }
                field(baseUnitOfMeasureId; Rec."Unit of Measure Id")
                {
                    Caption = 'Base Unit Of Measure Id', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Id"));
                    end;
                }
                field(baseUnitOfMeasureCode; Rec."Base Unit of Measure")
                {
                    Caption = 'Base Unit Of Measure Code', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Base Unit of Measure"));
                    end;
                }

                field(salesUnitofMeasure; Rec."Sales Unit of Measure")
                {
                    Caption = 'Sales Unit of Measure', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sales Unit of Measure"));
                    end;
                }

                field(purchUnitofMeasure; Rec."Purch. Unit of Measure")
                {
                    Caption = 'Purch. Unit of Measure', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Purch. Unit of Measure"));
                    end;
                }

                field(costingMethod; Rec."Costing Method")
                {
                    Caption = 'Costing Method', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Costing Method"));
                    end;
                }
                field(reserve; Rec.Reserve)
                {
                    Caption = 'Reserve', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Reserve));
                    end;
                }

                field(manufacturerCode; Rec."Manufacturer Code")
                {
                    Caption = 'Manufacturer Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Manufacturer Code"));
                    end;
                }

                field(shelfNo; Rec."Shelf No.")
                {
                    Caption = 'Shelf No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Shelf No."));
                    end;
                }

                field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'Gen. Prod. Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Gen. Prod. Posting Group"));
                    end;
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Prod. Posting Group"));
                    end;
                }

                field(vatBusPostingGrPrice; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    Caption = 'VAT Bus. Posting Gr. (Price)', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Bus. Posting Gr. (Price)"));
                    end;
                }
                field(inventoryPostingGroup; Rec."Inventory Posting Group")
                {
                    Caption = 'Inventory Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Inventory Posting Group"));
                    end;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Global Dimension 1 Code"));
                    end;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Global Dimension 2 Code"));
                    end;
                }

                field(defaultDeferralTemplate; Rec."Default Deferral Template Code")
                {
                    Caption = 'Default Deferral Template Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Default Deferral Template Code"));
                    end;
                }

                field(itemDiscGroup; Rec."Item Disc. Group")
                {
                    Caption = 'Item Discount Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Item Disc. Group"));
                    end;
                }

                field(assemblyPolicy; Rec."Assembly Policy")
                {
                    Caption = 'Assembly Policy', Locked = true;
                }

                field(lowLevelCode; Rec."Low-Level Code")
                {
                    Caption = 'Low-Level Code', Locked = true;
                }

                field(lotSize; Rec."Lot Size")
                {
                    Caption = 'Lot Size', Locked = true;
                }

                field(scrapPct; Rec."Scrap %")
                {
                    Caption = 'Scrap %', Locked = true;
                }

                field(dampenerQuantity; Rec."Dampener Quantity")
                {
                    Caption = 'Dampener Quantity', Locked = true;
                }

                field(serialNos; Rec."Serial Nos.")
                {
                    Caption = 'Serial Nos.', Locked = true;
                }

                field(inventoryValueZero; Rec."Inventory Value Zero")
                {
                    Caption = 'Inventory Value Zero', Locked = true;
                }

                field(discreteOrderQuantity; Rec."Discrete Order Quantity")
                {
                    Caption = 'Discrete Order Quantity', Locked = true;
                }

                field(minimumOrderQuantity; Rec."Minimum Order Quantity")
                {
                    Caption = 'Minimum Order Quantity', Locked = true;
                }

                field(maximumOrderQuantity; Rec."Maximum Order Quantity")
                {
                    Caption = 'Maximum Order Quantity', Locked = true;
                }

                field(safetyStockQuantity; Rec."Safety Stock Quantity")
                {
                    Caption = 'Safety Stock Quantity', Locked = true;
                }

                field(orderMultiple; Rec."Order Multiple")
                {
                    Caption = 'Order Multiple', Locked = true;
                }

                field(safetyLeadTime; Rec."Safety Lead Time")
                {
                    Caption = 'Safety Lead Time', Locked = true;
                }

                field(flushingMethod; Rec."Flushing Method")
                {
                    Caption = 'Flushing Method', Locked = true;
                }

                field(replenishmentSystem; Rec."Replenishment System")
                {
                    Caption = 'Replenishment System', Locked = true;
                }

                field(timeBucket; Rec."Time Bucket")
                {
                    Caption = 'Time Bucket', Locked = true;
                }

                field(reorderingPolicy; Rec."Reordering Policy")
                {
                    Caption = 'Reordering Policy', Locked = true;
                }

                field(includeInventory; Rec."Include Inventory")
                {
                    Caption = 'Include Inventory', Locked = true;
                }

                field(leadTimeCalculation; Rec."Lead Time Calculation")
                {
                    Caption = 'Lead Time Calculation', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Lead Time Calculation"));
                    end;
                }

                field(manufacturingPolicy; Rec."Manufacturing Policy")
                {
                    Caption = 'Manufacturing Policy', Locked = true;
                }

                field(reschedulingPeriod; Rec."Rescheduling Period")
                {
                    Caption = 'Rescheduling Period', Locked = true;
                }

                field(lotAccumulationPeriod; Rec."Lot Accumulation Period")
                {
                    Caption = 'Lot Accumulation Period', Locked = true;
                }
                field(dampenerPeriod; Rec."Dampener Period")
                {
                    Caption = 'Dampener Period', Locked = true;
                }

                field(overflowLevel; Rec."Overflow Level")
                {
                    Caption = 'Overflow Level', Locked = true;
                }

                field(createdFromNonstockItem; Rec."Created From Nonstock Item")
                {
                    Caption = 'Created From Nonstock Item', Locked = true;
                }

                field(purchasingCode; Rec."Purchasing Code")
                {
                    Caption = 'Purchasing Code', Locked = true;
                }
                field(serviceItemGroup; Rec."Service Item Group")
                {
                    Caption = 'Service Item Group', Locked = true;
                }

                field(itemTrackingCode; Rec."Item Tracking Code")
                {
                    Caption = 'Item Tracking Code', Locked = true;
                }

                field(lotNos; Rec."Lot Nos.")
                {
                    Caption = 'Lot Nos.', Locked = true;
                }

                field(expirationCalculation; Rec."Expiration Calculation")
                {
                    Caption = 'Expiration Calculation', Locked = true;
                }

                field(warehouseClassCode; Rec."Warehouse Class Code")
                {
                    Caption = 'Warehouse Class Code', Locked = true;
                }

                field(specialEquipmentCode; Rec."Special Equipment Code")
                {
                    Caption = 'Special Equipment Code', Locked = true;
                }

                field(putAwayTemplateCode; Rec."Put-away Template Code")
                {
                    Caption = 'Put-away Template Code', Locked = true;
                }

                field(putAwayUnitOfMeasureCode; Rec."Put-away Unit of Measure Code")
                {
                    Caption = 'Put-away Unit of Measure Code', Locked = true;
                }

                field(physInvtCountingPeriodCode; Rec."Phys Invt Counting Period Code")
                {
                    Caption = 'Phys Invt Counting Period Code', Locked = true;
                }

                field(useCrossDocking; Rec."Use Cross-Docking")
                {
                    Caption = 'Use Cross-Docking', Locked = true;
                }

                field(purchasingBlocked; Rec."Purchasing Blocked")
                {
                    Caption = 'Purchasing Blocked', Locked = true;
                }

                field(overReceiptCode; Rec."Over-Receipt Code")
                {
                    Caption = 'Over-Receipt Code', Locked = true;
                }

                field(salesBlocked; Rec."Sales Blocked")
                {
                    Caption = 'Sales Blocked', Locked = true;
                }

                field(routingNo; Rec."Routing No.")
                {
                    Caption = 'Routing No.', Locked = true;
                }

                field(productionBomNo; Rec."Production BOM No.")
                {
                    Caption = 'Production BOM No.', Locked = true;
                }

                field(singleLevelMaterialCost; Rec."Single-Level Material Cost")
                {
                    Caption = 'Single-Level Material Cost', Locked = true;
                }

                field(singleLevelCapacityCost; Rec."Single-Level Capacity Cost")
                {
                    Caption = 'Single-Level Capacity Cost', Locked = true;
                }

                field(singleLevelSubcontrdCost; Rec."Single-Level Subcontrd. Cost")
                {
                    Caption = 'Single-Level Subcontrd. Cost', Locked = true;
                }

                field(singleLevelCapOvhdCost; Rec."Single-Level Cap. Ovhd Cost")
                {
                    Caption = 'Single-Level Cap. Ovhd Cost', Locked = true;
                }

                field(singleLevelMfgOvhdCost; Rec."Single-Level Mfg. Ovhd Cost")
                {
                    Caption = 'Single-Level Mfg. Ovhd Cost', Locked = true;
                }

                field(overheadRate; Rec."Overhead Rate")
                {
                    Caption = 'Overhead Rate', Locked = true;
                }

                field(orderTrackingPolicy; Rec."Order Tracking Policy")
                {
                    Caption = 'Order Tracking Policy', Locked = true;
                }
                field(nprGroupSale; Rec."NPR Group sale")
                {
                    Caption = 'Group sale', Locked = true;
                }

                field(critical; Rec.Critical)
                {
                    Caption = 'Critical', Locked = true;
                }

                field(commonItemNo; Rec."Common Item No.")
                {
                    Caption = 'Common Item No.', Locked = true;
                }

                field(nprExplodeBomAuto; Rec."NPR Explode BOM auto")
                {
                    Caption = 'Explode BOM auto', Locked = true;
                }

                field(nprGuaranteeVoucher; Rec."NPR Guarantee voucher")
                {
                    Caption = 'Guarantee voucher', Locked = true;
                }

                field(nprItemBrand; Rec."NPR Item Brand")
                {
                    Caption = 'Item Brand', Locked = true;
                }

                field(nprTicketType; Rec."NPR Ticket Type")
                {
                    Caption = 'Ticket Type', Locked = true;
                }

                field(nprItemAddonNo; ItemAdditionalFields."Item Addon No.")
                {
                    Caption = 'Item AddOn No.', Locked = true;
                }

                field(nprMagentoItem; Rec."NPR Magento Item")
                {
                    Caption = 'Magento Item', Locked = true;
                }

                field(nprMagentoStatus; Rec."NPR Magento Status")
                {
                    Caption = 'Magento Status', Locked = true;
                }

                field(nprAttributeSetID; Rec."NPR Attribute Set ID")
                {
                    Caption = 'NPR Attribute Set ID', Locked = true;
                }

                field(nprMagentoDescription; TempNPRBlob."Buffer 1")
                {
                    Caption = 'Magento Description', Locked = true;
                }

                field(nprMagentoName; Rec."NPR Magento Name")
                {
                    Caption = 'Magento Name', Locked = true;
                }
                field(nprMagentoShortDescription; TempNPRBlob."Buffer 2")
                {
                    Caption = 'Magento Short Description', Locked = true;
                }

                field(nprMagentoBrand; Rec."NPR Magento Brand")
                {
                    Caption = 'Magento Brand', Locked = true;
                }
                field(nprSeoLink; Rec."NPR Seo Link")
                {
                    Caption = 'Seo Link', Locked = true;
                }
                field(nprMetaTitle; Rec."NPR Meta Title")
                {
                    Caption = 'Meta Title', Locked = true;
                }
                field(nprMetaDescription; Rec."NPR Meta Description")
                {
                    Caption = 'Meta Description', Locked = true;
                }
                field(nprProductNewFrom; Rec."NPR Product New From")
                {
                    Caption = 'roduct New From', Locked = true;
                }
                field(nprProductNewTo; Rec."NPR Product New To")
                {
                    Caption = 'Product New To', Locked = true;
                }
                field(nprSpecialPrice; Rec."NPR Special Price")
                {
                    Caption = 'Special Price', Locked = true;
                }
                field(nprSpecialPriceFrom; Rec."NPR Special Price From")
                {
                    Caption = 'Special Price From', Locked = true;
                }
                field(nprSpecialPriceTo; Rec."NPR Special Price To")
                {
                    Caption = 'Special Price To', Locked = true;
                }
                field(nprFeaturedFrom; Rec."NPR Featured From")
                {
                    Caption = 'Featured From', Locked = true;
                }
                field(nprFeaturedTo; Rec."NPR Featured To")
                {
                    Caption = 'Featured To', Locked = true;
                }
                field(nprBackorder; Rec."NPR Backorder")
                {
                    Caption = 'Backorder', Locked = true;
                }
                field(nprDisplayOnly; Rec."NPR Display Only")
                {
                    Caption = 'Display Only', Locked = true;
                }

                field(nprVarietyGroup; Rec."NPR Variety Group")
                {
                    Caption = 'Variety Group', Locked = true;
                }

                field(nprVariety1; Rec."NPR Variety 1")
                {
                    Caption = 'Variety 1', Locked = true;
                }

                field(nprVariety1Table; Rec."NPR Variety 1 Table")
                {
                    Caption = 'Variety 1 Table', Locked = true;
                }

                field(nprVariety2; Rec."NPR Variety 2")
                {
                    Caption = 'Variety 2', Locked = true;
                }

                field(nprVariety2Table; Rec."NPR Variety 2 Table")
                {
                    Caption = 'Variety 2 Table', Locked = true;
                }

                field(nprVariety3; Rec."NPR Variety 3")
                {
                    Caption = 'Variety 3', Locked = true;
                }

                field(nprVariety3Table; Rec."NPR Variety 3 Table")
                {
                    Caption = 'Variety 3 Table', Locked = true;
                }

                field(nprVariety4; Rec."NPR Variety 4")
                {
                    Caption = 'Variety 4', Locked = true;
                }

                field(nprVariety4Table; Rec."NPR Variety 4 Table")
                {
                    Caption = 'Variety  4 Table', Locked = true;
                }

                field(nprNoPrintOnReciept; Rec."NPR No Print on Reciept")
                {
                    Caption = 'No Print on Reciept', Locked = true;
                }

                field(nprPrintTags; Rec."NPR Print Tags")
                {
                    Caption = 'Print Tags', Locked = true;
                }

                field(nprNpreItemRoutingProfile; ItemAdditionalFields."NPRE Item Routing Profile")
                {
                    Caption = 'NPRE Item Routing Profile', Locked = true;
                }

                field(nprCustomDiscountBlocked; Rec."NPR Custom Discount Blocked")
                {
                    Caption = 'Custom Discount Blocked', Locked = true;
                }

                field(nprCrossVarietyNo; Rec."NPR Cross Variety No.")
                {
                    Caption = 'Cross Variety No.', Locked = true;
                }

                field(nprItemStatus; Rec."NPR Item Status")
                {
                    Caption = 'Item Status', Locked = true;
                }

                field(nprMagentoPictVarietyType; Rec."NPR Magento Pict. Variety Type")
                {
                    Caption = 'Magento Pict. Variety Type', Locked = true;
                }

                field(nprDisplayOnlyText; Rec."NPR Display only Text")
                {
                    Caption = 'Display only Text', Locked = true;
                }

                part(baseUnitOfMeasure; "NPR APIV1 - Units of Measure")
                {

#IF BC17            // Multiplicity can be used only with platform version 6.3;
                    Caption = 'Multiplicity=ZeroOrOne', Locked = true;
#ELSE
                    Caption = 'Unit Of Measure', Locked = true;
                    Multiplicity = ZeroOrOne;
#ENDIF
                    EntityName = 'unitOfMeasure';
                    EntitySetName = 'unitsOfMeasure';
                    SubPageLink = SystemId = Field("Unit of Measure Id");
                }
                part(picture; "NPR APIV1 - Pictures")
                {
#IF BC17            // Multiplicity can be used only with platform version 6.3;
                    Caption = 'Multiplicity=ZeroOrOne', Locked = true;
#ELSE
                    Caption = 'Picture', Locked = true;
                    Multiplicity = ZeroOrOne;
#ENDIF
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Item);
                }
                part(defaultDimensions; "NPR APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions', Locked = true;
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = Field(SystemId), "Parent Type" = const(Item);
                }
                part(itemVariants; "NPR APIV1 - Item Variants")
                {
                    Caption = 'Variants', Locked = true;
                    EntityName = 'itemVariant';
                    EntitySetName = 'itemVariants';
                    //SubPageLink = "Item Id" = field(SystemId);
                    SubPageLink = "Item No." = field("No.");
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                    Editable = false;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

    trigger OnAfterGetRecord()
    var
        OStr: OutStream;
    begin
        SetCalculatedFields();

        // get Media fields
        TempNPRBlob.Init();
        if Rec."NPR Magento Desc.".HasValue() then begin
            TempNPRBlob."Buffer 1".CreateOutStream(OStr);
            GetTenantMedia(Rec."NPR Magento Desc.".MediaId, OStr);
        end;
        if Rec."NPR Magento Short Desc.".HasValue() then begin
            TempNPRBlob."Buffer 2".CreateOutStream(OStr);
            GetTenantMedia(Rec."NPR Magento Short Desc.".MediaId, OStr);
        end;

        Rec.GetItemAdditionalFields(ItemAdditionalFields);
    end;

    local procedure GetTenantMedia(MediaId: Guid; var OStr: OutStream)
    var
        TenantMedia: Record "Tenant Media";
        IStr: InStream;
    begin
        TenantMedia.Get(MediaId);
        TenantMedia.CalcFields(Content);
        TenantMedia.Content.CreateInStream(IStr);
        CopyStream(OStr, IStr);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if TempFieldSet.Get(Database::Item, Rec.FieldNo(Inventory)) then
            Error(InventoryCannotBeChangedInAPostRequestErr);

        GraphCollectionMgtItem.InsertItem(Rec, TempFieldSet);

        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Item: Record Item;
    begin

        if TempFieldSet.Get(Database::Item, Rec.FieldNo(Inventory)) then
            UpdateInventory();

        Item.GetBySystemId(Rec.SystemId);

        if Rec."No." = Item."No." then
            Rec.Modify(true)
        else begin
            Item.TransferFields(Rec, false);
            Item.Rename(Rec."No.");
            Rec.TransferFields(Item, true);
        end;

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields(Inventory);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record Field temporary;
        ItemAdditionalFields: Record "NPR Item Additional Fields";
        ItemCategory: Record "Item Category";
        TaxGroup: Record "Tax Group";
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        InventoryValue: Decimal;
        BlankGUID: Guid;
        TempNPRBlob: Record "NPR BLOB buffer" temporary;
        TaxGroupValuesDontMatchErr: Label 'The tax group values do not match to a specific Tax Group.';
        TaxGroupIdDoesNotMatchATaxGroupErr: Label 'The "taxGroupId" does not match to a Tax Group.', Comment = 'taxGroupId is a field name and should not be translated.';
        TaxGroupCodeDoesNotMatchATaxGroupErr: Label 'The "taxGroupCode" does not match to a Tax Group.', Comment = 'taxGroupCode is a field name and should not be translated.';
        ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr: Label 'The "itemCategoryId" does not match to a specific Item Category group.', Comment = 'itemCategoryId is a field name and should not be translated.';
        ItemCategoriesValuesDontMatchErr: Label 'The item categories values do not match to a specific item category.';
        ItemCategoryCodeDoesNotMatchATaxGroupErr: Label 'The "itemCategoryCode" does not match to a Item Category.', Comment = 'itemCategoryCode is a field name and should not be translated.';
        InventoryCannotBeChangedInAPostRequestErr: Label 'Inventory cannot be changed during on insert.';

    local procedure SetCalculatedFields()
    begin
        // Inventory
        InventoryValue := Rec.Inventory;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);
        Clear(InventoryValue);
        TempFieldSet.DeleteAll();
    end;

    local procedure UpdateInventory()
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        Rec.calcfields(Inventory);
        if Rec.Inventory = InventoryValue then
            exit;
        ItemJnlLine.Init();
        ItemJnlLine.Validate("Posting Date", Today());
        ItemJnlLine."Document No." := Rec."No.";

        if Rec.Inventory < InventoryValue then
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");

        ItemJnlLine.Validate("Item No.", Rec."No.");
        ItemJnlLine.Validate(Description, Rec.Description);
        ItemJnlLine.Validate(Quantity, Abs(InventoryValue - Rec.Inventory));

        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
        Rec.Get(Rec."No.");
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Item, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Item;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}

