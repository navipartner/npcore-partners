codeunit 6151347 "NPR POS Action: Scan Coupon B"
{
    Access = Internal;

    procedure ScanCoupon(CouponReferenceNo: Text; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; var RequireSerialNo: Boolean)
    var
        POSSession: Codeunit "NPR POS Session";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        CouponMgt.ScanCoupon(POSSession, CouponReferenceNo);
        IfSerialNoRequired(CouponReferenceNo, Sale, SaleLine, RequireSerialNo);
    end;

    local procedure IfSerialNoRequired(CouponReferenceNo: Text; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; var RequireSerialNo: Boolean)
    var
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
        CouponType: Record "NPR NpDc Coupon Type";
        Item: Record Item;
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        UseSpecificTracking: Boolean;
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
    begin
        if not FindCouponType(CouponReferenceNo, CouponType) then
            exit;

        if not FindExtraCouponItem(CouponType, ExtraCouponItem) then
            exit;

        if not Item.Get(ExtraCouponItem."Item No.") then
            exit;

        RequireSerialNo := NPRPOSTrackingUtils.ItemRequiresSerialNumber(Item, UseSpecificTracking);

        Sale.GetCurrentSale(POSSale);
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetRange("No.", Item."No.");
        POSSaleLine.SetRange("Serial No.", '');
        if POSSaleLine.FindLast() then
            SaleLine.SetPosition(POSSaleLine.GetPosition());

    end;

    local procedure FindCouponType(ReferenceNo: Text; var CouponType: Record "NPR NpDc Coupon Type"): Boolean;
    var
        Coupon: Record "NPR NpDc Coupon";
    begin
        Coupon.SetRange("Reference No.", ReferenceNo);
        if not Coupon.FindFirst() then
            exit(false);

        if not CouponType.Get(Coupon."Coupon Type") then
            exit(false);

        exit(true);
    end;

    local procedure FindExtraCouponItem(CouponType: Record "NPR NpDc Coupon Type"; var ExtraCouponItem: Record "NPR NpDc Extra Coupon Item"): Boolean
    begin
        exit(ExtraCouponItem.Get(CouponType.Code, 10000));
    end;
}