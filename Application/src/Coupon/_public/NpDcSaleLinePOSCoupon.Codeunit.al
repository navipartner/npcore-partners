codeunit 6248506 "NPR NpDc SaleLinePOSCoupon"
{
    Access = Public;

    var
        _SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";

    procedure SetView(var SaleLinePOSCouponBuff: Record "NPR NpDc SaleLinePOSCouponBuff")
    begin
        _SaleLinePOSCoupon.Reset();
        _SaleLinePOSCoupon.SetView(SaleLinePOSCouponBuff.GetView());
    end;

    procedure GetBySystemId(SystemId: Guid; var SaleLinePOSCouponBuff: Record "NPR NpDc SaleLinePOSCouponBuff") Found: Boolean
    begin
        SaleLinePOSCouponBuff.Reset();
        SaleLinePOSCouponBuff.DeleteAll();

        if not _SaleLinePOSCoupon.GetBySystemId(SystemId) then
            exit;

        PopulateBufferFromRec(SaleLinePOSCouponBuff, _SaleLinePOSCoupon);

        Found := true;
    end;

    procedure FindSet(var SaleLinePOSCouponBuff: Record "NPR NpDc SaleLinePOSCouponBuff") Found: Boolean
    begin
        SaleLinePOSCouponBuff.Reset();
        SaleLinePOSCouponBuff.DeleteAll();

        if not _SaleLinePOSCoupon.FindSet() then
            exit;

        repeat
            PopulateBufferFromRec(SaleLinePOSCouponBuff, _SaleLinePOSCoupon);
        until _SaleLinePOSCoupon.Next() = 0;
        SaleLinePOSCouponBuff.FindFirst();

        Found := true;
    end;

    procedure FindFirst(var SaleLinePOSCouponBuff: Record "NPR NpDc SaleLinePOSCouponBuff") Found: Boolean
    begin
        SaleLinePOSCouponBuff.Reset();
        SaleLinePOSCouponBuff.DeleteAll();

        if not _SaleLinePOSCoupon.FindFirst() then
            exit;

        PopulateBufferFromRec(SaleLinePOSCouponBuff, _SaleLinePOSCoupon);
        Found := true;
    end;

    procedure FindLast(var SaleLinePOSCouponBuff: Record "NPR NpDc SaleLinePOSCouponBuff") Found: Boolean
    begin
        SaleLinePOSCouponBuff.Reset();
        SaleLinePOSCouponBuff.DeleteAll();

        if not _SaleLinePOSCoupon.FindLast() then
            exit;

        PopulateBufferFromRec(SaleLinePOSCouponBuff, _SaleLinePOSCoupon);

        Found := true;
    end;


    local procedure PopulateBufferFromRec(var SaleLinePOSCouponBuff: Record "NPR NpDc SaleLinePOSCouponBuff"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    begin
        SaleLinePOSCouponBuff.Init();
        SaleLinePOSCouponBuff.TransferFields(SaleLinePOSCoupon);
        SaleLinePOSCouponBuff.SystemId := SaleLinePOSCoupon.SystemId;
        SaleLinePOSCouponBuff.Insert(false, false);
    end;
}