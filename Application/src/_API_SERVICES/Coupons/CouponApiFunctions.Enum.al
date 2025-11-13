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
}
#endif