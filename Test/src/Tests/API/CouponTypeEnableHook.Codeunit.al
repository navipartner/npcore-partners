codeunit 85276 "NPR Coupon Type Enable Hook"
{
    // Test-only hook: enables one coupon type while it is being modified, before the row is written.
    // Bound manually by the test that needs it, so no other write is affected.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _CouponTypeCode: Code[20];

    procedure SetCouponTypeCode(CouponTypeCode: Code[20])
    begin
        _CouponTypeCode := CouponTypeCode;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Type", 'OnBeforeModifyRecEvent', '', false, false)]
    local procedure EnableCouponTypeOnBeforeModifyRec(sender: Codeunit "NPR NpDc Coupon Type"; var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; RunTrigger: Boolean)
    begin
        if (_CouponTypeCode = '') or (CouponTypeBuffer.Code <> _CouponTypeCode) then
            exit;
        CouponTypeBuffer.Enabled := true;
    end;
}
