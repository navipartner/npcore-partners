codeunit 6151591 "NPR NpDc Coupon Module Mgt."
{
    Access = Internal;
    [IntegrationEvent(false, false)]
    procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasIssueCouponSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasIssueSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupIssueCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunIssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasValidateCouponSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasValidateSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupValidateCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunValidateCoupon(SalePOS: Record "NPR POS Sale"; Coupon: Record "NPR NpDc Coupon"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasApplyDiscountSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasApplySetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupApplyDiscount(var CouponType: Record "NPR NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostDiscountApplication(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; Coupon: Record "NPR NpDc Coupon"; CouponEntry: Record "NPR NpDc Coupon Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelDiscountApplication(Coupon: Record "NPR NpDc Coupon"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    begin
    end;
}

