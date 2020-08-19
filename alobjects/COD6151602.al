codeunit 6151602 "NpDc Non-POS Coupon Webservice"
{
    // NPR5.51/MHA /20190724  CASE 343352 Object created


    trigger OnRun()
    begin
    end;

        procedure ApplyCouponDiscount(var coupon_application: XMLport "NpDc Ext. Coupon Application")
    var
        TempSalePOS: Record "Sale POS" temporary;
        TempSaleLinePOS: Record "Sale Line POS" temporary;
        TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NpDc Non-POS Application Mgt.";
    begin
        coupon_application.Import;
        coupon_application.GetRequest(TempSalePOS,TempSaleLinePOS,TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.ApplyDiscount(TempSalePOS,TempSaleLinePOS,TempNpDcExtCouponBuffer);

        coupon_application.SetResponse(TempSalePOS,TempSaleLinePOS);
    end;

        procedure CheckCoupons(var coupons: XMLport "NpDc Ext. Coupon")
    var
        NpDcCoupon: Record "NpDc Coupon";
        TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NpDc Non-POS Application Mgt.";
    begin
        coupons.Import;
        coupons.GetCoupons(TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.CheckCoupons(TempNpDcExtCouponBuffer);

        coupons.SetCoupons(TempNpDcExtCouponBuffer);
    end;

        procedure ReserveCoupons(var coupons: XMLport "NpDc Ext. Coupon")
    var
        NpDcCoupon: Record "NpDc Coupon";
        TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NpDc Non-POS Application Mgt.";
    begin
        coupons.Import;
        coupons.GetCoupons(TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.ReserveCoupons(TempNpDcExtCouponBuffer);

        coupons.SetCoupons(TempNpDcExtCouponBuffer);
    end;

        procedure CancelCouponReservations(var coupons: XMLport "NpDc Ext. Coupon")
    var
        NpDcCoupon: Record "NpDc Coupon";
        TempNpDcExtCouponBuffer: Record "NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSApplicationMgt: Codeunit "NpDc Non-POS Application Mgt.";
    begin
        coupons.Import;
        coupons.GetCoupons(TempNpDcExtCouponBuffer);

        NpDcNonPOSApplicationMgt.CancelCouponReservations(TempNpDcExtCouponBuffer);

        coupons.SetCoupons(TempNpDcExtCouponBuffer);
    end;
}

