codeunit 6059985 "NPR POSAction: Coupon Verify B"
{
    Access = Internal;
    procedure VerifyCoupon(ReferenceNo: Text[50])
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcCouponCard: Page "NPR NpDc Coupon Card";
        NotFoundErr: Label '%1 with %2 %3 doesn''t exist.';
    begin
        NpDcCoupon.SetRange("Reference No.", ReferenceNo);
        if not NpDcCoupon.FindFirst() then
            Error(NotFoundErr, NpDcCoupon.TableCaption, NpDcCoupon.FieldCaption("Reference No."), ReferenceNo);

        NpDcCouponCard.Editable(false);
        NpDcCouponCard.SetRecord(NpDcCoupon);
        NpDcCouponCard.RunModal();
    end;
}