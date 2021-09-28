page 6014477 "NPR APIV1 - Mixed Discounts"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Mixed Discount';
    DelayedInsert = true;
    EntityName = 'mixedDiscount';
    EntitySetName = 'mixedDiscounts';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Mixed Discount";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(mixType; Rec."Mix Type")
                {
                    Caption = 'mixType', Locked = true;
                }
                field(lot; Rec.Lot)
                {
                    Caption = 'lot', Locked = true;
                }
                field(minQuantity; Rec."Min. Quantity")
                {
                    Caption = 'minQuantity', Locked = true;
                }
                field(maxQuantity; Rec."Max. Quantity")
                {
                    Caption = 'maxQuantity', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                }
                field(noSerie; Rec."No. Serie")
                {
                    Caption = 'noSerie', Locked = true;
                }
                field(discountType; Rec."Discount Type")
                {
                    Caption = 'discountType', Locked = true;
                }
                field(startingdate; Rec."Starting date")
                {
                    Caption = 'startingdate', Locked = true;
                }
                field(startingtime; Rec."Starting time")
                {
                    Caption = 'startingtime', Locked = true;
                }
                field(endingdate; Rec."Ending date")
                {
                    Caption = 'endingdate', Locked = true;
                }
                field(endingtime; Rec."Ending time")
                {
                    Caption = 'endingtime', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'globalDimension1Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'globalDimension2Code', Locked = true;
                }
                field(customerDiscGroupFilter; Rec."Customer Disc. Group Filter")
                {
                    Caption = 'customerDiscGroupFilter', Locked = true;
                }
                field(actualDiscountAmount; Rec."Actual Discount Amount")
                {
                    Caption = 'actualDiscountAmount', Locked = true;
                }
                field(actualItemQty; Rec."Actual Item Qty.")
                {
                    Caption = 'actualItemQty', Locked = true;
                }
                field(blockCustomDiscount; Rec."Block Custom Discount")
                {
                    Caption = 'blockCustomDiscount', Locked = true;
                }
                field(campaignRef; Rec."Campaign Ref.")
                {
                    Caption = 'campaignRef', Locked = true;
                }
                field(createdthe; Rec."Created the")
                {
                    Caption = 'createdthe', Locked = true;
                }
                field(itemDiscount; Rec."Item Discount %")
                {
                    Caption = 'itemDiscount', Locked = true;
                }
                field(itemDiscountQty; Rec."Item Discount Qty.")
                {
                    Caption = 'itemDiscountQty', Locked = true;
                }
                field(quantitysold; Rec."Quantity sold")
                {
                    Caption = 'quantitysold', Locked = true;
                }
                field(totalAmount; Rec."Total Amount")
                {
                    Caption = 'totalAmount', Locked = true;
                }
                field(totalAmountExclVAT; Rec."Total Amount Excl. VAT")
                {
                    Caption = 'totalAmountExclVAT', Locked = true;
                }
                field(totalDiscount; Rec."Total Discount %")
                {
                    Caption = 'totalDiscount', Locked = true;
                }
                field(totalDiscountAmount; Rec."Total Discount Amount")
                {
                    Caption = 'totalDiscountAmount', Locked = true;
                }
                field(turnover; Rec.Turnover)
                {
                    Caption = 'turnover', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

                part(mixedDiscountTimeIntervals; "NPR API V1 - Mix. Disc. Int")
                {
                    Caption = 'Period Discount Lines';
                    EntityName = 'mixedDiscountTimeInterval';
                    EntitySetName = 'mixedDiscountTimeIntervals';
                    SubPageLink = "Mix Code" = field(Code);
                }

                part(mixedDiscountLevels; "NPR API V1 - Mix. Disc. Levels")
                {
                    Caption = 'Period Discount Lines';
                    EntityName = 'mixedDiscountLevel';
                    EntitySetName = 'mixedDiscountLevels';
                    SubPageLink = "Mixed Discount Code" = field(Code);
                }

                part(mixedDiscountLines; "NPR API V1 - Mixed Disc. Lines")
                {
                    Caption = 'Period Discount Lines';
                    EntityName = 'mixedDiscountLine';
                    EntitySetName = 'mixedDiscountLines';
                    SubPageLink = Code = field(Code);
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
