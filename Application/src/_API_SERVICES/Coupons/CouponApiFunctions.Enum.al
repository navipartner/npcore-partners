#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059843 "NPR CouponApiFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }
    value(10; CREATE_COUPON)
    {
        Caption = 'Create Coupon';
    }
    value(11; GET_COUPON)
    {
        Caption = 'Get Coupon using ID';
    }
    value(12; DELETE_COUPON)
    {
        Caption = 'Delete Coupon using ID';
    }
    value(13; APPLY_COUPON_DISCOUNT)
    {
        Caption = 'Apply coupon discount';
    }
    value(14; CHECK_COUPON)
    {
        Caption = 'Check coupon';
    }
    value(15; RESERVE_COUPON)
    {
        Caption = 'Reserve coupon';
    }
    value(16; CANCEL_COUPON_RESERVATION)
    {
        Caption = 'Cancel coupon reservation';
    }
    value(17; FIND_COUPON)
    {
        Caption = 'Find coupon';
    }
}
#endif