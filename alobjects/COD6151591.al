codeunit 6151591 "NpDc Coupon Module Mgt."
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon


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
}

