codeunit 6151591 "NpDc Coupon Module Mgt."
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.51/MHA /20190626  CASE 355406 Added publisher functions OnPostDiscountApplication(), OnCancelDiscountApplication()


    trigger OnRun()
    begin
    end;

    local procedure "--- Init"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitCouponModules(var CouponModule: Record "NpDc Coupon Module")
    begin
    end;

    local procedure "--- Issue Coupon"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasIssueCouponSetup(CouponType: Record "NpDc Coupon Type";var HasIssueSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupIssueCoupon(var CouponType: Record "NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunIssueCoupon(CouponType: Record "NpDc Coupon Type";var Handled: Boolean)
    begin
    end;

    local procedure "--- Validate Coupon"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasValidateCouponSetup(CouponType: Record "NpDc Coupon Type";var HasValidateSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupValidateCoupon(var CouponType: Record "NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunValidateCoupon(SalePOS: Record "Sale POS";Coupon: Record "NpDc Coupon";var Handled: Boolean)
    begin
    end;

    local procedure "--- Apply Discount"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasApplyDiscountSetup(CouponType: Record "NpDc Coupon Type";var HasApplySetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupApplyDiscount(var CouponType: Record "NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunApplyDiscount(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";var Handled: Boolean)
    begin
    end;

    local procedure "--- Coupon Events"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostDiscountApplication(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";Coupon: Record "NpDc Coupon";CouponEntry: Record "NpDc Coupon Entry")
    begin
        //-NPR5.51 [355406]
        //+NPR5.51 [355406]
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelDiscountApplication(Coupon: Record "NpDc Coupon";SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon")
    begin
        //-NPR5.51 [355406]
        //+NPR5.51 [355406]
    end;
}

