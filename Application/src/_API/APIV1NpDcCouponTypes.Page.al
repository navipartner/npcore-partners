page 6014485 "NPR APIV1 - NpDc Coupon Types"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'npDcCouponTypes';
    DelayedInsert = true;
    EntityName = 'npdcCouponType';
    EntitySetName = 'npdcCouponTypes';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR NpDc Coupon Type";

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
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(referenceNoPattern; Rec."Reference No. Pattern")
                {
                    Caption = 'referenceNoPattern', Locked = true;
                }
                field(discountType; Rec."Discount Type")
                {
                    Caption = 'discountType', Locked = true;
                }
                field(discount; Rec."Discount %")
                {
                    Caption = 'discount', Locked = true;
                }
                field(maxDiscountAmount; Rec."Max. Discount Amount")
                {
                    Caption = 'maxDiscountAmount', Locked = true;
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'discountAmount', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'startingDate', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'endingDate', Locked = true;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'customerNo', Locked = true;
                }
                field(maxUseperSale; Rec."Max Use per Sale")
                {
                    Caption = 'maxUseperSale', Locked = true;
                }
                field(multiUseCoupon; Rec."Multi-Use Coupon")
                {
                    Caption = 'multiUseCoupon', Locked = true;
                }
                field(multiUseQty; Rec."Multi-Use Qty.")
                {
                    Caption = 'multiUseQty', Locked = true;
                }
                field(printTemplateCode; Rec."Print Template Code")
                {
                    Caption = 'printTemplateCode', Locked = true;
                }
                field(printonIssue; Rec."Print on Issue")
                {
                    Caption = 'printonIssue', Locked = true;
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'enabled', Locked = true;
                }
                field(applicationSequenceNo; Rec."Application Sequence No.")
                {
                    Caption = 'applicationSequenceNo', Locked = true;
                }
                field(issueCouponModule; Rec."Issue Coupon Module")
                {
                    Caption = 'issueCouponModule', Locked = true;
                }
                field(validateCouponModule; Rec."Validate Coupon Module")
                {
                    Caption = 'validateCouponModule', Locked = true;
                }
                field(applyDiscountModule; Rec."Apply Discount Module")
                {
                    Caption = 'applyDiscountModule', Locked = true;
                }
                field(couponQtyOpen; Rec."Coupon Qty. (Open)")
                {
                    Caption = 'couponQtyOpen', Locked = true;
                }
                field(archCouponQty; Rec."Arch. Coupon Qty.")
                {
                    Caption = 'archCouponQty', Locked = true;
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
