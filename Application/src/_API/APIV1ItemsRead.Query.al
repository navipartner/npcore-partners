query 6014410 "NPR APIV1 - Items Read"
{
    Access = Internal;
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'itemRead';
    EntitySetName = 'itemsRead';
    OrderBy = ascending(replicationCounter);
    QueryType = API;
    ReadState = ReadShared;

    elements
    {
        dataitem(item; Item)
        {
            column(id; SystemId)
            {
                Caption = 'Id', Locked = true;
            }
            column(number; "No.")
            {
                Caption = 'No.', Locked = true;
            }
            column(no2; "No. 2")
            {
                Caption = 'No. 2', Locked = true;
            }
            column(displayName; Description)
            {
                Caption = 'DisplayName', Locked = true;
            }
            column(displayName2; "Description 2")
            {
                Caption = 'DisplayName2', Locked = true;
            }
            column(searchDescription; "Search Description")
            {
                Caption = 'Search Description', Locked = true;
            }
            column(type; Type)
            {
                Caption = 'Type', Locked = true;
            }
            column(priceUnitConversion; "Price Unit Conversion")
            {
                Caption = 'Price Unit Conversion', Locked = true;
            }
            column(statisticsGroup; "Statistics Group")
            {
                Caption = 'Statistics Group', Locked = true;
            }
            column(commissionGroup; "Commission Group")
            {
                Caption = 'Commission Group', Locked = true;
            }
            column(reorderPoint; "Reorder Point")
            {
                Caption = 'Reorder Point', Locked = true;
            }
            column(maximumInventory; "Maximum Inventory")
            {
                Caption = 'Maximum Inventory', Locked = true;
            }
            column(reorderQuantity; "Reorder Quantity")
            {
                Caption = 'Reorder Quantity', Locked = true;
            }
            column(alternativeItemNo; "Alternative Item No.")
            {
                Caption = 'Alternative Item No.', Locked = true;
            }
            column(grossWeight; "Gross Weight")
            {
                Caption = 'Gross Weight', Locked = true;
            }
            column(netWeight; "Net Weight")
            {
                Caption = 'Net Weight', Locked = true;
            }
            column(unitsPerParcel; "Units per Parcel")
            {
                Caption = 'Units per Parcel', Locked = true;
            }
            column(unitVolume; "Unit Volume")
            {
                Caption = 'Unit Volume', Locked = true;
            }
            column(freightType; "Freight Type")
            {
                Caption = 'Freight Type', Locked = true;
            }
            column(countryRegionPurchasedCode; "Country/Region Purchased Code")
            {
                Caption = 'Country/Region Purchased Code', Locked = true;
            }
            column(budgetQuantity; "Budget Quantity")
            {
                Caption = 'Budget Quantity', Locked = true;
            }
            column(budgetedAmount; "Budgeted Amount")
            {
                Caption = 'Budgeted Amount', Locked = true;
            }
            column(budgetProfit; "Budget Profit")
            {
                Caption = 'Budget Profit', Locked = true;
            }
            column(durability; Durability)
            {
                Caption = 'Durability', Locked = true;
            }
            column(allowInvoiceDisc; "Allow Invoice Disc.")
            {
                Caption = 'Allow Invoice Disc.', Locked = true;
            }
            column(priceProfitCalculation; "Price/Profit Calculation")
            {
                Caption = 'Price/Profit Calculation', Locked = true;
            }
            column(vendorNo; "Vendor No.")
            {
                Caption = 'Vendor No.', Locked = true;
            }
            column(vendorItemNo; "Vendor Item No.")
            {
                Caption = 'Vendor Item No.', Locked = true;
            }
            column(itemCategoryId; "Item Category Id")
            {
                Caption = 'Item Category Id', Locked = true;
            }
            column(itemCategoryCode; "Item Category Code")
            {
                Caption = 'Item Category Code', Locked = true;
            }
            column(blocked; Blocked)
            {
                Caption = 'Blocked', Locked = true;
            }
            column(blockReason; "Block Reason")
            {
                Caption = 'Block Reason', Locked = true;
            }
            column(countryRegionOfOriginCode; "Country/Region of Origin Code")
            {
                Caption = 'Country/Region of Origin Code', Locked = true;
            }
            column(automaticExtTexts; "Automatic Ext. Texts")
            {
                Caption = 'Automatic Ext. Texts', Locked = true;
            }
            column(noSeries; "No. Series")
            {
                Caption = 'No. Series', Locked = true;
            }
            column(stockoutWarning; "Stockout Warning")
            {
                Caption = 'Stockout Warning', Locked = true;
            }
            column(preventNegativeInventory; "Prevent Negative Inventory")
            {
                Caption = 'Prevent Negative Inventory', Locked = true;
            }
            column(roundingPrecision; "Rounding Precision")
            {
                Caption = 'Rounding Precision', Locked = true;
            }
            column(gtin; GTIN)
            {
                Caption = 'GTIN', Locked = true;
            }
            column(unitPrice; "Unit Price")
            {
                Caption = 'Unit Price', Locked = true;
            }
            column(unitListPrice; "Unit List Price")
            {
                Caption = 'Unit List Price', Locked = true;
            }
            column(priceIncludesTax; "Price Includes VAT")
            {
                Caption = 'Price Includes Tax', Locked = true;
            }
            column(unitCost; "Unit Cost")
            {
                Caption = 'Unit Cost', Locked = true;
            }
            column(standardCost; "Standard Cost")
            {
                Caption = 'Standard Cost', Locked = true;
            }
            column(lastDirectCost; "Last Direct Cost")
            {
                Caption = 'Last Direct Cost', Locked = true;
            }
            column(taxGroupId; "Tax Group Id")
            {
                Caption = 'Tax Group Id', Locked = true;
            }
            column(taxGroupCode; "Tax Group Code")
            {
                Caption = 'Tax Group Code', Locked = true;
            }
            column(tariffNo; "Tariff No.")
            {
                Caption = 'Tariff No.', Locked = true;
            }
            column(baseUnitOfMeasureId; "Unit of Measure Id")
            {
                Caption = 'Base Unit Of Measure Id', Locked = true;
            }
            column(baseUnitOfMeasureCode; "Base Unit of Measure")
            {
                Caption = 'Base Unit Of Measure Code', Locked = true;
            }
            column(salesUnitofMeasure; "Sales Unit of Measure")
            {
                Caption = 'Sales Unit of Measure', Locked = true;
            }
            column(purchUnitofMeasure; "Purch. Unit of Measure")
            {
                Caption = 'Purch. Unit of Measure', Locked = true;
            }
            column(costingMethod; "Costing Method")
            {
                Caption = 'Costing Method', Locked = true;
            }
            column(reserve; Reserve)
            {
                Caption = 'Reserve', Locked = true;
            }
            column(manufacturerCode; "Manufacturer Code")
            {
                Caption = 'Manufacturer Code', Locked = true;
            }
            column(shelfNo; "Shelf No.")
            {
                Caption = 'Shelf No.', Locked = true;
            }
            column(genProdPostingGroup; "Gen. Prod. Posting Group")
            {
                Caption = 'Gen. Prod. Posting Group', Locked = true;
            }
            column(vatProdPostingGroup; "VAT Prod. Posting Group")
            {
                Caption = 'VAT Prod. Posting Group', Locked = true;
            }
            column(vatBusPostingGrPrice; "VAT Bus. Posting Gr. (Price)")
            {
                Caption = 'VAT Bus. Posting Gr. (Price)', Locked = true;
            }
            column(inventoryPostingGroup; "Inventory Posting Group")
            {
                Caption = 'Inventory Posting Group', Locked = true;
            }
            column(globalDimension1Code; "Global Dimension 1 Code")
            {
                Caption = 'Global Dimension 1 Code', Locked = true;
            }
            column(globalDimension2Code; "Global Dimension 2 Code")
            {
                Caption = 'Global Dimension 2 Code', Locked = true;
            }
            column(defaultDeferralTemplate; "Default Deferral Template Code")
            {
                Caption = 'Default Deferral Template Code', Locked = true;
            }
            column(itemDiscGroup; "Item Disc. Group")
            {
                Caption = 'Item Discount Group', Locked = true;
            }
            column(assemblyPolicy; "Assembly Policy")
            {
                Caption = 'Assembly Policy', Locked = true;
            }
            column(lowLevelCode; "Low-Level Code")
            {
                Caption = 'Low-Level Code', Locked = true;
            }
            column(lotSize; "Lot Size")
            {
                Caption = 'Lot Size', Locked = true;
            }
            column(scrapPct; "Scrap %")
            {
                Caption = 'Scrap %', Locked = true;
            }
            column(dampenerQuantity; "Dampener Quantity")
            {
                Caption = 'Dampener Quantity', Locked = true;
            }
            column(serialNos; "Serial Nos.")
            {
                Caption = 'Serial Nos.', Locked = true;
            }
            column(inventoryValueZero; "Inventory Value Zero")
            {
                Caption = 'Inventory Value Zero', Locked = true;
            }
            column(discreteOrderQuantity; "Discrete Order Quantity")
            {
                Caption = 'Discrete Order Quantity', Locked = true;
            }
            column(minimumOrderQuantity; "Minimum Order Quantity")
            {
                Caption = 'Minimum Order Quantity', Locked = true;
            }
            column(maximumOrderQuantity; "Maximum Order Quantity")
            {
                Caption = 'Maximum Order Quantity', Locked = true;
            }
            column(safetyStockQuantity; "Safety Stock Quantity")
            {
                Caption = 'Safety Stock Quantity', Locked = true;
            }
            column(orderMultiple; "Order Multiple")
            {
                Caption = 'Order Multiple', Locked = true;
            }
            column(safetyLeadTime; "Safety Lead Time")
            {
                Caption = 'Safety Lead Time', Locked = true;
            }
            column(flushingMethod; "Flushing Method")
            {
                Caption = 'Flushing Method', Locked = true;
            }
            column(replenishmentSystem; "Replenishment System")
            {
                Caption = 'Replenishment System', Locked = true;
            }
            column(timeBucket; "Time Bucket")
            {
                Caption = 'Time Bucket', Locked = true;
            }
            column(reorderingPolicy; "Reordering Policy")
            {
                Caption = 'Reordering Policy', Locked = true;
            }
            column(includeInventory; "Include Inventory")
            {
                Caption = 'Include Inventory', Locked = true;
            }
            column(leadTimeCalculation; "Lead Time Calculation")
            {
                Caption = 'Lead Time Calculation', Locked = true;
            }
            column(manufacturingPolicy; "Manufacturing Policy")
            {
                Caption = 'Manufacturing Policy', Locked = true;
            }
            column(reschedulingPeriod; "Rescheduling Period")
            {
                Caption = 'Rescheduling Period', Locked = true;
            }
            column(lotAccumulationPeriod; "Lot Accumulation Period")
            {
                Caption = 'Lot Accumulation Period', Locked = true;
            }
            column(dampenerPeriod; "Dampener Period")
            {
                Caption = 'Dampener Period', Locked = true;
            }
            column(overflowLevel; "Overflow Level")
            {
                Caption = 'Overflow Level', Locked = true;
            }
            column(createdFromNonstockItem; "Created From Nonstock Item")
            {
                Caption = 'Created From Nonstock Item', Locked = true;
            }
            column(purchasingCode; "Purchasing Code")
            {
                Caption = 'Purchasing Code', Locked = true;
            }
            column(serviceItemGroup; "Service Item Group")
            {
                Caption = 'Service Item Group', Locked = true;
            }
            column(itemTrackingCode; "Item Tracking Code")
            {
                Caption = 'Item Tracking Code', Locked = true;
            }
            column(lotNos; "Lot Nos.")
            {
                Caption = 'Lot Nos.', Locked = true;
            }
            column(expirationCalculation; "Expiration Calculation")
            {
                Caption = 'Expiration Calculation', Locked = true;
            }
            column(warehouseClassCode; "Warehouse Class Code")
            {
                Caption = 'Warehouse Class Code', Locked = true;
            }
            column(specialEquipmentCode; "Special Equipment Code")
            {
                Caption = 'Special Equipment Code', Locked = true;
            }
            column(putAwayTemplateCode; "Put-away Template Code")
            {
                Caption = 'Put-away Template Code', Locked = true;
            }
            column(putAwayUnitOfMeasureCode; "Put-away Unit of Measure Code")
            {
                Caption = 'Put-away Unit of Measure Code', Locked = true;
            }
            column(physInvtCountingPeriodCode; "Phys Invt Counting Period Code")
            {
                Caption = 'Phys Invt Counting Period Code', Locked = true;
            }
            column(useCrossDocking; "Use Cross-Docking")
            {
                Caption = 'Use Cross-Docking', Locked = true;
            }
            column(purchasingBlocked; "Purchasing Blocked")
            {
                Caption = 'Purchasing Blocked', Locked = true;
            }
            column(overReceiptCode; "Over-Receipt Code")
            {
                Caption = 'Over-Receipt Code', Locked = true;
            }
            column(salesBlocked; "Sales Blocked")
            {
                Caption = 'Sales Blocked', Locked = true;
            }
            column(routingNo; "Routing No.")
            {
                Caption = 'Routing No.', Locked = true;
            }
            column(productionBomNo; "Production BOM No.")
            {
                Caption = 'Production BOM No.', Locked = true;
            }
            column(singleLevelMaterialCost; "Single-Level Material Cost")
            {
                Caption = 'Single-Level Material Cost', Locked = true;
            }
            column(singleLevelCapacityCost; "Single-Level Capacity Cost")
            {
                Caption = 'Single-Level Capacity Cost', Locked = true;
            }
            column(singleLevelSubcontrdCost; "Single-Level Subcontrd. Cost")
            {
                Caption = 'Single-Level Subcontrd. Cost', Locked = true;
            }
            column(singleLevelCapOvhdCost; "Single-Level Cap. Ovhd Cost")
            {
                Caption = 'Single-Level Cap. Ovhd Cost', Locked = true;
            }
            column(singleLevelMfgOvhdCost; "Single-Level Mfg. Ovhd Cost")
            {
                Caption = 'Single-Level Mfg. Ovhd Cost', Locked = true;
            }
            column(overheadRate; "Overhead Rate")
            {
                Caption = 'Overhead Rate', Locked = true;
            }
            column(orderTrackingPolicy; "Order Tracking Policy")
            {
                Caption = 'Order Tracking Policy', Locked = true;
            }
            column(nprGroupSale; "NPR Group sale")
            {
                Caption = 'Group sale', Locked = true;
            }
            column(critical; Critical)
            {
                Caption = 'Critical', Locked = true;
            }
            column(commonItemNo; "Common Item No.")
            {
                Caption = 'Common Item No.', Locked = true;
            }
            column(nprExplodeBomAuto; "NPR Explode BOM auto")
            {
                Caption = 'Explode BOM auto', Locked = true;
            }
            column(nprGuaranteeVoucher; "NPR Guarantee voucher")
            {
                Caption = 'Guarantee voucher', Locked = true;
            }
            column(nprItemBrand; "NPR Item Brand")
            {
                Caption = 'Item Brand', Locked = true;
            }
            column(nprMagentoItem; "NPR Magento Item")
            {
                Caption = 'Magento Item', Locked = true;
            }
            column(nprMagentoStatus; "NPR Magento Status")
            {
                Caption = 'Magento Status', Locked = true;
            }
            column(nprMagentoName; "NPR Magento Name")
            {
                Caption = 'Magento Name', Locked = true;
            }
            column(nprSeoLink; "NPR Seo Link")
            {
                Caption = 'Seo Link', Locked = true;
            }
            column(nprMetaTitle; "NPR Meta Title")
            {
                Caption = 'Meta Title', Locked = true;
            }
            column(nprMetaDescription; "NPR Meta Description")
            {
                Caption = 'Meta Description', Locked = true;
            }
            column(nprProductNewFrom; "NPR Product New From")
            {
                Caption = 'roduct New From', Locked = true;
            }
            column(nprProductNewTo; "NPR Product New To")
            {
                Caption = 'Product New To', Locked = true;
            }
            column(nprSpecialPrice; "NPR Special Price")
            {
                Caption = 'Special Price', Locked = true;
            }
            column(nprSpecialPriceFrom; "NPR Special Price From")
            {
                Caption = 'Special Price From', Locked = true;
            }
            column(nprSpecialPriceTo; "NPR Special Price To")
            {
                Caption = 'Special Price To', Locked = true;
            }
            column(nprFeaturedFrom; "NPR Featured From")
            {
                Caption = 'Featured From', Locked = true;
            }
            column(nprFeaturedTo; "NPR Featured To")
            {
                Caption = 'Featured To', Locked = true;
            }
            column(nprBackorder; "NPR Backorder")
            {
                Caption = 'Backorder', Locked = true;
            }
            column(nprDisplayOnly; "NPR Display Only")
            {
                Caption = 'Display Only', Locked = true;
            }
            column(nprNoPrintOnReciept; "NPR No Print on Reciept")
            {
                Caption = 'No Print on Reciept', Locked = true;
            }
            column(nprPrintTags; "NPR Print Tags")
            {
                Caption = 'Print Tags', Locked = true;
            }
            column(nprCustomDiscountBlocked; "NPR Custom Discount Blocked")
            {
                Caption = 'Custom Discount Blocked', Locked = true;
            }
            column(nprCrossVarietyNo; "NPR Cross Variety No.")
            {
                Caption = 'Cross Variety No.', Locked = true;
            }
            column(nprMagentoPictVarietyType; "NPR Magento Pict. Variety Type")
            {
                Caption = 'Magento Pict. Variety Type', Locked = true;
            }
            column(nprDisplayOnlyText; "NPR Display only Text")
            {
                Caption = 'Display only Text', Locked = true;
            }
            column(lastModifiedDateTime; SystemModifiedAt)
            {
                Caption = 'Last Modified Date', Locked = true;
            }

            dataitem(auxItem; "NPR Auxiliary Item")
            {
                DataItemLink = "Item No." = item."No.";
                SqlJoinType = InnerJoin;
                column(replicationCounter; "Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }
}
