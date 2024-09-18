page 6150624 "NPR API V1 Arch. Coupon"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'archivedcoupon';
    EntitySetName = 'archivedcoupons';
    Caption = 'PowerBI Archived Coupons';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;
    Editable = false;
    SourceTable = "NPR NpDc Arch. Coupon";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(applyDiscountModule; Rec."Apply Discount Module")
                {
                    Caption = 'Apply Discount Module';
                }
                field(couponIssued; Rec."Coupon Issued")
                {
                    Caption = 'Coupon Issued';
                }
                field(couponType; Rec."Coupon Type")
                {
                    Caption = 'Coupon Type';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(discount; Rec."Discount %")
                {
                    Caption = 'Discount %';
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'Discount Amount';
                }
                field(discountType; Rec."Discount Type")
                {
                    Caption = 'Discount Type';
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date';
                }
                field(issueCouponModule; Rec."Issue Coupon Module")
                {
                    Caption = 'Issue Coupon Module';
                }
                field(maxUsePerSale; Rec."Max Use per Sale")
                {
                    Caption = 'Max Use per Sale';
                }
                field(maxDiscountAmount; Rec."Max. Discount Amount")
                {
                    Caption = 'Max. Discount Amount';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No. Series';
                }
                field(open; Rec.Open)
                {
                    Caption = 'Open';
                }
                field(posStoreGroup; Rec."POS Store Group")
                {
                    Caption = 'POS Store Group';
                }
                field(printTemplateCode; Rec."Print Template Code")
                {
                    Caption = 'Print Template Code';
                }
                field(referenceNo; Rec."Reference No.")
                {
                    Caption = 'Reference No.';
                }
                field(remainingQuantity; Rec."Remaining Quantity")
                {
                    Caption = 'Remaining Quantity';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
                field(validateCouponModule; Rec."Validate Coupon Module")
                {
                    Caption = 'Validate Coupon Module';
                }
            }
        }
    }
}
