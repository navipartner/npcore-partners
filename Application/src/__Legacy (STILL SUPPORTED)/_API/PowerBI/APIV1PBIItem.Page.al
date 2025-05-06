page 6059926 "NPR APIV1 PBIItem"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'item';
    EntitySetName = 'items';
    Caption = 'PowerBI Item';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item";
    Extensible = false;
    Editable = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-09-28';
    ObsoleteReason = 'version v2.0 created';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code', Locked = true;
                }
                field(salesQty; Rec."Sales (Qty.)")
                {
                    Caption = 'Sales (Qty.)', Locked = true;
                }
                field(type; Rec."Type")
                {
                    Caption = 'Type', Locked = true;
                }
                field(baseUnitOfMeasure; Rec."Base Unit of Measure")
                {
                    Caption = 'Base Unit of Measure', Locked = true;
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'Unit Cost', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;
                }
                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.', Locked = true;
                }
                field(vendorItemNo; Rec."Vendor Item No.")
                {
                    Caption = 'Vendor Item No.', Locked = true;
                }
                field(inventoryPostingGroup; Rec."Inventory Posting Group")
                {
                    Caption = 'Inventory Posting Group', Locked = true;
                }
                field(itemDiscGroup; Rec."Item Disc. Group")
                {
                    Caption = 'Item Disc. Group', Locked = true;
                }
                field(profit; Rec."Profit %")
                {
                    Caption = 'Profit %', Locked = true;
                }
                field(priceIncludesVat; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT', Locked = true;
                }
                field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'Gen. Prod. Posting Group', Locked = true;
                }
                field(countryRegionOfOriginCode; Rec."Country/Region of Origin Code")
                {
                    Caption = 'Country/Region of Origin Code', Locked = true;
                }
                field(shelfNo; Rec."Shelf No.")
                {
                    Caption = 'Shelf No.', Locked = true;
                }
                field(itemTrackingCode; Rec."Item Tracking Code")
                {
                    Caption = 'Item Tracking Code', Locked = true;
                }
                field(nprItemBrand; Rec."NPR Item Brand")
                {
                    Caption = 'Item Brand', Locked = true;
                }
                field(nprMagentoName; Rec."NPR Magento Name")
                {
                    Caption = 'Magento Name', Locked = true;
                }
                field(nprTicketType; Rec."NPR Ticket Type")
                {
                    Caption = 'Ticket Type';
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}