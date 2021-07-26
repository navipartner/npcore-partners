page 6014476 "NPR APIV1 - Camp. Disc. Lines"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'periodDiscountLines';
    DelayedInsert = true;
    EntityName = 'periodDiscountLine';
    EntitySetName = 'periodDiscountLines';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Period Discount Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'startingDate', Locked = true;
                }

                field(startingTime; Rec."Starting Time")
                {
                    Caption = 'startingTime', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'endingDate', Locked = true;
                }
                field(endingTime; Rec."Ending Time")
                {
                    Caption = 'endingTime', Locked = true;
                }
                field(priority; Rec.Priority)
                {
                    Caption = 'priority', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'itemNo', Locked = true;
                }
                field(inventory; Rec.Inventory)
                {
                    Caption = 'inventory', Locked = true;
                }
                field(campaignProfit; Rec."Campaign Profit")
                {
                    Caption = 'campaignProfit', Locked = true;
                }
                field(campaignUnitCost; Rec."Campaign Unit Cost")
                {
                    Caption = 'campaignUnitCost', Locked = true;
                }
                field(campaignUnitPrice; Rec."Campaign Unit Price")
                {
                    Caption = 'campaignUnitPrice', Locked = true;
                }
                field(comment; Rec.Comment)
                {
                    Caption = 'comment', Locked = true;
                }
                field(crossReferenceNo; Rec."Cross-Reference No.")
                {
                    Caption = 'crossReferenceNo', Locked = true;
                }
                field(dateFilter; Rec."Date Filter")
                {
                    Caption = 'dateFilter', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(discount; Rec."Discount %")
                {
                    Caption = 'discount', Locked = true;
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'discountAmount', Locked = true;
                }
                field(distributionItem; Rec."Distribution Item")
                {
                    Caption = 'distributionItem', Locked = true;
                }
                field(globalDimension1Filter; Rec."Global Dimension 1 Filter")
                {
                    Caption = 'globalDimension1Filter', Locked = true;
                }
                field(globalDimension2Filter; Rec."Global Dimension 2 Filter")
                {
                    Caption = 'globalDimension2Filter', Locked = true;
                }
                field(internetSpecialId; Rec."Internet Special Id")
                {
                    Caption = 'internetSpecialId', Locked = true;
                }
                field(locationFilter; Rec."Location Filter")
                {
                    Caption = 'locationFilter', Locked = true;
                }
                field(profit; Rec.Profit)
                {
                    Caption = 'profit', Locked = true;
                }
                field(quantityOnPurchaseOrder; Rec."Quantity On Purchase Order")
                {
                    Caption = 'quantityOnPurchaseOrder', Locked = true;
                }
                field(quantitySold; Rec."Quantity Sold")
                {
                    Caption = 'quantitySold', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                }
                field(turnover; Rec.Turnover)
                {
                    Caption = 'turnover', Locked = true;
                }
                field(unitCostPurchase; Rec."Unit Cost Purchase")
                {
                    Caption = 'unitCostPurchase', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'unitPrice', Locked = true;
                }
                field(unitPriceInclVAT; Rec."Unit Price Incl. VAT")
                {
                    Caption = 'unitPriceInclVAT', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'variantCode', Locked = true;
                }
                field(vendorItemNo; Rec."Vendor Item No.")
                {
                    Caption = 'vendorItemNo', Locked = true;
                }
                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'vendorNo', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
