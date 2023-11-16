page 6151166 "NPR APIV2 PBIItem"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v2.0';
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
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}