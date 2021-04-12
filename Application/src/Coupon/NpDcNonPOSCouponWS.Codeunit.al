codeunit 6151602 "NPR NpDc Non-POS Coupon WS"
{
    procedure ApplyCouponDiscount(var coupon_application: XMLport "NPR NpDc Ext. Coupon Appl.")
    var
        TempSalePOS: Record "NPR POS Sale" temporary;
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
    begin
        coupon_application.Import();
        coupon_application.GetRequest(TempSalePOS, TempSaleLinePOS, TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.ApplyDiscount(TempSalePOS, TempSaleLinePOS, TempNpDcExtCouponBuffer, NpDcNonPOSApplicationMgt);

        coupon_application.SetResponse(TempSalePOS, TempSaleLinePOS);
    end;

    procedure CheckCoupons(var coupons: XMLport "NPR NpDc Ext. Coupon")
    var
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
    begin
        coupons.Import();
        coupons.GetCoupons(TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.CheckCoupons(TempNpDcExtCouponBuffer);

        coupons.SetCoupons(TempNpDcExtCouponBuffer);
    end;

    procedure ReserveCoupons(var coupons: XMLport "NPR NpDc Ext. Coupon")
    var
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
    begin
        coupons.Import();
        coupons.GetCoupons(TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.ReserveCoupons(TempNpDcExtCouponBuffer);

        coupons.SetCoupons(TempNpDcExtCouponBuffer);
    end;

    procedure CancelCouponReservations(var coupons: XMLport "NPR NpDc Ext. Coupon")
    var
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
    begin
        coupons.Import();
        coupons.GetCoupons(TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.CancelCouponReservations(TempNpDcExtCouponBuffer);

        coupons.SetCoupons(TempNpDcExtCouponBuffer);
    end;
}