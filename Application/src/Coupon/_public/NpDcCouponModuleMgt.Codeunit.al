codeunit 6151591 "NPR NpDc Coupon Module Mgt."
{
    [IntegrationEvent(false, false)]
    internal procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHasIssueCouponSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasIssueSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupIssueCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunIssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHasValidateCouponSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasValidateSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupValidateCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunValidateCoupon(SalePOS: Record "NPR POS Sale"; Coupon: Record "NPR NpDc Coupon"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHasApplyDiscountSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasApplySetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupApplyDiscount(var CouponType: Record "NPR NpDc Coupon Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnPostDiscountApplication(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; Coupon: Record "NPR NpDc Coupon"; CouponEntry: Record "NPR NpDc Coupon Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCancelDiscountApplication(Coupon: Record "NPR NpDc Coupon"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateCoupon(var ReferenceNo: Text)
    begin
    end;

    [Obsolete('Please use event in codeunit "NPR NpRv Module Mgt." OnAfterSendVoucherSelection instead.', '2025-07-13')]
    [IntegrationEvent(false, false)]
    procedure OnAfterSendVoucherSelection(var VoucherEntry: Record "NPR NpRv Voucher Entry"; SalePOS: Record "NPR POS Sale")
    begin
    end;

    [Obsolete('Please use event in codeunit "NPR NpRv Module Mgt." OnAfterSendSalesDocVoucherSelection instead.', '2025-07-13')]
    [IntegrationEvent(false, false)]
    procedure OnAfterSendSalesDocVoucherSelection(var VoucherEntry: Record "NPR NpRv Voucher Entry"; var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoNo: Code[20])
    begin
    end;
}

